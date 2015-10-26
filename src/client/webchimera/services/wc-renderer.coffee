'use strict'

angular.module 'app.webchimera'

.factory 'Texture', ->
  class Texture 
    constructor: (gl, width, height) ->
      @gl = gl
      @width = width
      @height = height
      @texture = gl.createTexture()
      
      gl.bindTexture gl.TEXTURE_2D, @texture
      gl.texImage2D gl.TEXTURE_2D, 0, gl.LUMINANCE, width, height, 0, gl.LUMINANCE, gl.UNSIGNED_BYTE, null
      gl.texParameteri gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR
      gl.texParameteri gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR
      gl.texParameteri gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE
      gl.texParameteri gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE
      
      return

    bind: (n, program, name) ->
      gl = @gl
      
      gl.activeTexture [
        gl.TEXTURE0
        gl.TEXTURE1
        gl.TEXTURE2
      ][n]
      
      gl.bindTexture gl.TEXTURE_2D, @texture
      gl.uniform1i gl.getUniformLocation(program, name), n
      
      return

    fill: (data) ->
      gl = @gl
      gl.bindTexture gl.TEXTURE_2D, @texture
      gl.texImage2D gl.TEXTURE_2D, 0, gl.LUMINANCE, @width, @height, 0, gl.LUMINANCE, gl.UNSIGNED_BYTE, data
      
      return

.factory 'wcjsRenderer', (Texture, os) ->
  wcAddon = require 'wcjs-prebuilt'
    
  render = (canvas, videoFrame, vlc) ->
    if !vlc.playing
      return
    
    gl = canvas.gl
    len = videoFrame.length
    
    videoFrame.y.fill videoFrame.subarray(0, videoFrame.uOffset)
    videoFrame.u.fill videoFrame.subarray(videoFrame.uOffset, videoFrame.vOffset)
    videoFrame.v.fill videoFrame.subarray(videoFrame.vOffset, len)
    
    gl.drawArrays gl.TRIANGLE_STRIP, 0, 4
    
    return

  renderFallback = (canvas, videoFrame) ->
    buf = canvas.img.data
    
    width = videoFrame.width
    height = videoFrame.height
    
    i = 0
    
    while i < height
      j = 0
      while j < width
        o = (j + width * i) * 4
        buf[o + 0] = videoFrame[o + 2]
        buf[o + 1] = videoFrame[o + 1]
        buf[o + 2] = videoFrame[o + 0]
        buf[o + 3] = videoFrame[o + 3]
        ++j
      ++i
    
    canvas.ctx.putImageData canvas.img, 0, 0

    return

  setupCanvas = (canvas, vlc, fallbackRenderer) ->
    if !fallbackRenderer
      canvas.gl = canvas.getContext('webgl')

    gl = canvas.gl
    
    if !gl or fallbackRenderer
      console.log if fallbackRenderer then 'Fallback renderer forced, not using WebGL' else 'Unable to initialize WebGL, falling back to canvas rendering'
      vlc.pixelFormat = vlc.RV32
      canvas.ctx = canvas.getContext('2d')
      delete canvas.gl
      # in case of fallback renderer
      return
    
    vlc.pixelFormat = vlc.I420
    canvas.I420Program = gl.createProgram()
    program = canvas.I420Program
    
    vertexShaderSource = [
      'attribute highp vec4 aVertexPosition;'
      'attribute vec2 aTextureCoord;'
      'varying highp vec2 vTextureCoord;'
      'void main(void) {'
      ' gl_Position = aVertexPosition;'
      ' vTextureCoord = aTextureCoord;'
      '}'
    ].join('\n')
    
    vertexShader = gl.createShader(gl.VERTEX_SHADER)
    
    gl.shaderSource vertexShader, vertexShaderSource
    gl.compileShader vertexShader
    
    fragmentShaderSource = [
      'precision highp float;'
      'varying lowp vec2 vTextureCoord;'
      'uniform sampler2D YTexture;'
      'uniform sampler2D UTexture;'
      'uniform sampler2D VTexture;'
      'const mat4 YUV2RGB = mat4'
      '('
      ' 1.1643828125, 0, 1.59602734375, -.87078515625,'
      ' 1.1643828125, -.39176171875, -.81296875, .52959375,'
      ' 1.1643828125, 2.017234375, 0, -1.081390625,'
      ' 0, 0, 0, 1'
      ');'
      'void main(void) {'
      ' gl_FragColor = vec4( texture2D(YTexture, vTextureCoord).x, texture2D(UTexture, vTextureCoord).x, texture2D(VTexture, vTextureCoord).x, 1) * YUV2RGB;'
      '}'
    ].join('\n')

    fragmentShader = gl.createShader(gl.FRAGMENT_SHADER)
    
    gl.shaderSource fragmentShader, fragmentShaderSource
    gl.compileShader fragmentShader
    
    gl.attachShader program, vertexShader
    gl.attachShader program, fragmentShader
    
    gl.linkProgram program
    gl.useProgram program
    
    if !gl.getProgramParameter(program, gl.LINK_STATUS)
      console.log 'Shader link failed.'
    
    vertexPositionAttribute = gl.getAttribLocation(program, 'aVertexPosition')
    
    gl.enableVertexAttribArray vertexPositionAttribute
    
    textureCoordAttribute = gl.getAttribLocation(program, 'aTextureCoord')
    
    gl.enableVertexAttribArray textureCoordAttribute
    
    verticesBuffer = gl.createBuffer()
    
    gl.bindBuffer gl.ARRAY_BUFFER, verticesBuffer
    gl.bufferData gl.ARRAY_BUFFER, new Float32Array([1.0, 1.0, 0.0, -1.0, 1.0, 0.0, 1.0, -1.0, 0.0, -1.0, -1.0, 0.0, ]), gl.STATIC_DRAW
    gl.vertexAttribPointer vertexPositionAttribute, 3, gl.FLOAT, false, 0, 0
    
    texCoordBuffer = gl.createBuffer()
    
    gl.bindBuffer gl.ARRAY_BUFFER, texCoordBuffer
    gl.bufferData gl.ARRAY_BUFFER, new Float32Array([1.0, 0.0, 0.0, 0.0, 1.0, 1.0, 0.0, 1.0 ]), gl.STATIC_DRAW
    gl.vertexAttribPointer textureCoordAttribute, 2, gl.FLOAT, false, 0, 0

    return

  frameSetup = (canvas, width, height, pixelFormat, videoFrame) ->
    gl = canvas.gl
    
    canvas.width = width
    canvas.height = height
    
    if !gl
      canvas.img = canvas.ctx.createImageData(width, height)
      return
    
    program = canvas.I420Program

    gl.viewport 0, 0, gl.drawingBufferWidth, gl.drawingBufferHeight

    videoFrame.y = new Texture(gl, width, height)
    videoFrame.u = new Texture(gl, width >> 1, height >> 1)
    videoFrame.v = new Texture(gl, width >> 1, height >> 1)

    videoFrame.y.bind 0, program, 'YTexture'
    videoFrame.u.bind 1, program, 'UTexture'
    videoFrame.v.bind 2, program, 'VTexture'

    return

  init: (canvas, params = {}, fallbackRenderer) ->
    @_canvas = canvas
    
    vlc = wcAddon.createPlayer(params)

    setupCanvas canvas, vlc, fallbackRenderer

    vlc.onFrameSetup = (width, height, pixelFormat, videoFrame) ->
      frameSetup canvas, width, height, pixelFormat, videoFrame
      
      canvas.addEventListener 'webglcontextlost', ((event) ->
        event.preventDefault()
        return
      ), false

      canvas.addEventListener 'webglcontextrestored', ((w, h, p, v) ->
        (event) ->
          setupCanvas canvas, vlc
          frameSetup canvas, w, h, p, v
          return
      )(width, height, pixelFormat, videoFrame), false

      return

    setFrame = this

    vlc.onFrameReady = (videoFrame) ->
      (if canvas.gl then render else renderFallback) canvas, videoFrame, vlc
      setFrame._lastFrame = videoFrame
      return

    vlc

  clearCanvas: ->
    if @_lastFrame
      gl = @_canvas.gl
      
      arr1 = new Uint8Array(@_lastFrame.uOffset)
      arr2 = new Uint8Array(@_lastFrame.vOffset - (@_lastFrame.uOffset))
      
      i = 0
      
      while i < arr2.length
        arr2[i] = 128
        ++i
      
      @_lastFrame.y.fill arr1
      @_lastFrame.u.fill arr2
      @_lastFrame.v.fill arr2
      
      gl.drawArrays gl.TRIANGLE_STRIP, 0, 4
    
    return

  _lastFrame: false
  _canvas: false
