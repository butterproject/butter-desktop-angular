'use strict'

angular.module 'app.services'

.factory '$Vibrant', ($q, Vibrant, ColorMap) ->

  get: (image, title) ->
    defer = $q.defer()

    vibrant = new Vibrant image, title

    defer.resolve
      theme: vibrant.name
      'background-color': vibrant.color.value
      color: vibrant.color.contrast
      fab: null

    defer.promise

.factory 'Swatch', ->
  class Swatch
    constructor: (rgb, population) ->
      @rgb = rgb
      @population = population

.constant 'quantize', require 'quantize'

.factory 'Vibrant', (quantize, VibrantUtils, Swatch, CanvasImage, ColorMap) ->
  class Vibrant
    quantize: quantize

    constructor: (sourceImage, name) ->
      image = new CanvasImage sourceImage

      try
        imageData = image.getImageData()
        
        pixels = imageData.data
        pixelCount = image.getPixelCount()

        allPixels = []
        i = 0

        while i < pixelCount
          offset = i * 4

          r = pixels[offset + 0]
          g = pixels[offset + 1]
          b = pixels[offset + 2]
          a = pixels[offset + 3]

          allPixels.push [r, g, b]

          i = i + 4

        cmap = @quantize allPixels, 10
        
        _swatches = cmap.vboxes.map (vbox) =>
          new Swatch vbox.color, vbox.vbox.count()

        best = swatch: { population: Number.MAX_VALUE }, calc: 0 

        for swatch in _swatches
          if swatch?.rgb
            hsv = VibrantUtils.RGBtoHSV swatch.rgb

            if best.calc < hsv[1] * hsv[2]
              if swatch.population > 20 and swatch.population < best.swatch.population 
                best = swatch: swatch, calc: hsv[1] * hsv[2]

        color = best.swatch.rgb

        { @name, @color } = ColorMap { R: color[0], G: color[1], B: color[2] }

        @color = 
          contrast: @rgba @color.contrast 
          value: @rgba @color.value 

      # Clean up
      finally
        image.removeCanvas()

    rgba: (array) ->
      if array.length is 4 
        'rgba(' + array.join() + ')'
      else 
        'rgb(' + array.join() + ')'


.factory 'VibrantUtils', ->
  RGBtoHSV: (rgb, hsv = []) ->
    [ red, green, blue ] = rgb
    min = Math.min(red, green, blue)
    max = Math.max(red, green, blue)
    
    delta = max - min
    
    v = max / 255
    
    if !delta
      hsv[0] = 0
      hsv[1] = 0
      hsv[2] = v
      
      return hsv
    
    s = delta / max
    h = undefined
    
    if red == max
      h = (green - blue) / delta
    else if green == max
      h = 2 + (blue - red) / delta
    else
      h = 4 + (red - green) / delta
    
    h *= 60
    
    if h < 0
      h += 360
    
    hsv[0] = h
    hsv[1] = s
    hsv[2] = v
    
    hsv

.factory 'CanvasImage', ->
  class CanvasImage
    constructor: (image) ->
      @canvas = angular.element('<canvas></canvas>')[0]
      @context = @canvas.getContext '2d'

      @width = @canvas.width = image.width
      @height = @canvas.height = image.height

      @context.drawImage image, 0, 0, @width, @height

    getPixelCount: ->
      @width * @height

    getImageData: ->
      @context.getImageData 0, 0, @width, @height

    removeCanvas: ->
      @canvas.remove()

.factory 'Ciede2000', ->
  { sqrt, pow, cos, atan2, sin, abs, exp, PI } = Math

  degrees = (n) ->
    n * 180 / PI

  radians = (n) ->
    n * PI / 180

  (c1, c2) ->
    # Get L,a,b values for color 1
    L1 = c1.L
    a1 = c1.a
    b1 = c1.b

    # Get L,a,b values for color 2
    L2 = c2.L
    a2 = c2.a
    b2 = c2.b
    
    # Weight factors
    kL = 1
    kC = 1
    kH = 1

    ###*
    # Step 1: Calculate C1p, C2p, h1p, h2p
    ###
    C1 = sqrt(pow(a1, 2) + pow(b1, 2)) #(2)
    C2 = sqrt(pow(a2, 2) + pow(b2, 2)) #(2)
    
    a_C1_C2 = (C1 + C2) / 2.0 #(3)
    G = 0.5 * (1 - sqrt(pow(a_C1_C2, 7.0) / (pow(a_C1_C2, 7.0) + pow(25.0, 7.0)))) #(4)
    
    a1p = (1.0 + G) * a1 #(5)
    a2p = (1.0 + G) * a2 #(5)
    
    C1p = sqrt(pow(a1p, 2) + pow(b1, 2)) #(6)
    C2p = sqrt(pow(a2p, 2) + pow(b2, 2)) #(6)

    hp_f = (x, y) ->
      if x == 0 and y == 0
        0
      else
        tmphp = degrees(atan2(x, y))
        if tmphp >= 0
          tmphp
        else
          tmphp + 360

    h1p = hp_f(b1, a1p) #(7)
    h2p = hp_f(b2, a2p) #(7)

    dLp = L2 - L1 #(8)
    dCp = C2p - C1p #(9)

    dhp_f = (C1, C2, h1p, h2p) ->
      if C1 * C2 == 0
        return 0
      else if abs(h2p - h1p) <= 180
        return h2p - h1p
      else if h2p - h1p > 180
        return h2p - h1p - 360
      else if h2p - h1p < -180
        return h2p - h1p + 360
      else
        throw new Error
      
      return

    dhp = dhp_f(C1, C2, h1p, h2p) #(10)
    dHp = 2 * sqrt(C1p * C2p) * sin(radians(dhp) / 2.0) #(11)

    a_L = (L1 + L2) / 2.0 #(12)
    a_Cp = (C1p + C2p) / 2.0 #(13)

    a_hp_f = (C1, C2, h1p, h2p) -> #(14)
      if C1 * C2 == 0
        return h1p + h2p
      else if abs(h1p - h2p) <= 180
        return (h1p + h2p) / 2.0
      else if abs(h1p - h2p) > 180 and h1p + h2p < 360
        return (h1p + h2p + 360) / 2.0
      else if abs(h1p - h2p) > 180 and h1p + h2p >= 360
        return (h1p + h2p - 360) / 2.0
      else
        throw new Error
      return

    a_hp = a_hp_f(C1, C2, h1p, h2p) #(14)
    T = 1 - (0.17 * cos(radians(a_hp - 30))) + 0.24 * cos(radians(2 * a_hp)) + 0.32 * cos(radians(3 * a_hp + 6)) - (0.20 * cos(radians(4 * a_hp - 63))) #(15)
    d_ro = 30 * exp(-pow((a_hp - 275) / 25, 2)) #(16)
    RC = sqrt(pow(a_Cp, 7.0) / (pow(a_Cp, 7.0) + pow(25.0, 7.0))) #(17)
    SL = 1 + 0.015 * pow(a_L - 50, 2) / sqrt(20 + pow(a_L - 50, 2.0)) #(18)
    SC = 1 + 0.045 * a_Cp #(19)
    SH = 1 + 0.015 * a_Cp * T #(20)
    RT = -2 * RC * sin(radians(2 * d_ro)) #(21)
    dE = sqrt(pow(dLp / (SL * kL), 2) + pow(dCp / (SC * kC), 2) + pow(dHp / (SH * kH), 2) + RT * dCp / (SC * kC) * dHp / (SH * kH)) #(22)
    dE

.factory 'Color2LAB', ->
  { pow, sqrt } = Math

  rgb_to_xyz = (c) ->
    R = c.R / 255
    G = c.G / 255
    B = c.B / 255
    
    if R >

     0.04045
      R = pow((R + 0.055) / 1.055, 2.4)
    else
      R = R / 12.92
    
    if G > 0.04045
      G = pow((G + 0.055) / 1.055, 2.4)
    else
      G = G / 12.92
    
    if B > 0.04045
      B = pow((B + 0.055) / 1.055, 2.4)
    else
      B = B / 12.92
    
    R *= 100
    G *= 100
    B *= 100

    X = R * 0.4124 + G * 0.3576 + B * 0.1805
    Y = R * 0.2126 + G * 0.7152 + B * 0.0722
    Z = R * 0.0193 + G * 0.1192 + B * 0.9505
    
    X: X, Y: Y, Z: Z

  xyz_to_lab = (c) ->
    ref_Y = 100.000
    ref_Z = 108.883
    ref_X = 95.047
    
    Y = c.Y / ref_Y
    Z = c.Z / ref_Z
    X = c.X / ref_X
    
    if X > 0.008856
      X = pow(X, 1 / 3)
    else
      X = 7.787 * X + 16 / 116
    
    if Y > 0.008856
      Y = pow(Y, 1 / 3)
    else
      Y = 7.787 * Y + 16 / 116
    
    if Z > 0.008856
      Z = pow(Z, 1 / 3)
    else
      Z = 7.787 * Z + 16 / 116
    
    L = 116 * Y - 16
    a = 500 * (X - Y)
    b = 200 * (Y - Z)
    
    L: L, a: a, b: b
  
  (c) ->
    xyz_to_lab rgb_to_xyz c

.factory 'ColorMap', (Ciede2000, Color2LAB, Material500Colours, $mdColorPalette) ->
  (color1) ->
    c = {}

    c1 = Color2LAB color1
    
    best_color_diff = Number.MAX_VALUE
    best_color = null

    idx2 = 0
    
    while idx2 < Material500Colours.length
      c2 = Material500Colours[idx2]

      current_color_diff = Ciede2000 c1, c2
      
      if current_color_diff < best_color_diff
        best_color = c2
        best_color_diff = current_color_diff

      idx2 += 1

    name: best_color.name, color: $mdColorPalette[best_color.name]['500']

.constant 'Material500Colours', [
  {
    name: 'red'
    L: 55.597623805632196
    a: 66.02534962294565
    b: 47.67059024235504
  }
  {
    name: 'pink'
    L: 50.86577347241479
    a: 74.6199065947189
    b: 15.343163604303445
  }
  {
    name: 'purple'
    L: 40.660103813622
    a: 64.03186997217928
    b: -48.07129385824492
  }
  {
    name: 'deep-purple'
    L: 36.60936712952936
    a: 47.30703935240002
    b: -59.12013560199584
  }
  {
    name: 'indigo'
    L: 38.33649398480265
    a: 25.58621198743974
    b: -55.28851437211867
  }
  {
    name: 'blue'
    L: 60.433289732834254
    a: 2.091062791193421
    b: -55.11629546778396
  }
  {
    name: 'light-blue'
    L: 65.69174941569261
    a: -9.601934081053255
    b: -47.34780850801761
  }
  {
    name: 'cyan'
    L: 69.97923505510704
    a: -30.671964628371462
    b: -23.192855151542368
  }
  {
    name: 'teal'
    L: 55.67520387407937
    a: -36.6563419582952
    b: -2.1298509952404787
  }
  {
    name: 'green'
    L: 63.97882318243629
    a: -48.54337881676557
    b: 39.73058816424629
  }
  {
    name: 'light-green'
    L: 44.6977987543611
    a: 49.70786556634471
    b: -52.858633663592784
  }
  {
    name: 'lime'
    L: 49.803926614735516
    a: 85.18681368430087
    b: -58.517902696481
  }
  {
    name: 'yellow'
    L: 92.12832188698677
    a: -10.831018612752263
    b: 80.91070359504107
  }
  {
    name: 'amber'
    L: 81.5193230003677
    a: 9.40449215448319
    b: 82.69790568440067
  }
  {
    name: 'orange'
    L: 72.03857963077364
    a: 30.685930190151367
    b: 77.09286758360345
  }
  {
    name: 'deep-orange'
    L: 60.06169839781482
    a: 61.6635751419034
    b: 61.55235492143441
  }
  {
    name: 'brown'
    L: 39.6306605621716
    a: 13.141535529969634
    b: 13.526758634248893
  }
  {
    name: 'grey'
    L: 65.1142450374671
    a: 0.003678461057199378
    b: -0.007278034741187156
  }
  {
    name: 'blue-grey'
    L: 50.708384652491944
    a: -6.833854301632803
    b: -10.961943818519204
  }
] 