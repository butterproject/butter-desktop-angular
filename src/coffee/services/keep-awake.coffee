'use strict'

angular.module 'app.services'

.factory 'keepAwake', ->
  video = null

  stop = ->
    if video isnt null
      video.pause()
      video.src = ''

  start: ->
    if video is null
      video = document.createElement 'video'
      
      document.body.appendChild video
      
      video.id = 'keep-awake-video'
      video.src = 'data:video/webm;base64,GkXfo0AgQoaBAUL3gQFC8oEEQvOBCEKCQAR3ZWJtQoeBAkKFgQIYU4BnQI0VSalmQCgq17FAAw9CQE2AQAZ3aGFtbXlXQUAGd2hhbW15RIlACECPQAAAAAAAFlSua0AxrkAu14EBY8WBAZyBACK1nEADdW5khkAFVl9WUDglhohAA1ZQOIOBAeBABrCBCLqBCB9DtnVAIueBAKNAHIEAAIAwAQCdASoIAAgAAUAmJaQAA3AA/vz0AAA='
      video.loop = true
    
    video.play()