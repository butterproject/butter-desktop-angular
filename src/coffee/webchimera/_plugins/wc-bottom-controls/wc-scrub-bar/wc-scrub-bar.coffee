'use strict'

angular.module 'app.webchimera.plugins.controls'

.filter 'formatTime', ->
  (input) ->
    input = Math.floor(input/1000)

    #Less than an hour
    if input < 3600
      minutes = Math.floor(input / 60)
      seconds = input - (minutes * 60)
      minutes + ':' + ('0' + seconds).slice(-2)
    else
      hours = Math.floor(input / 3600)
      minutes = Math.floor((input - (hours * 3600)) / 60)
      seconds = input - (hours * 3600) - (minutes * 60)
      hours + ':' + ('0' + minutes).slice(-2) + ':' + ('0' + seconds).slice(-2)

.directive 'wcScrubBar', (WC_STATES, WC_UTILS) ->
  restrict: 'E'
  require: '^chimerangular'
  transclude: true
  templateUrl: 'webchimera/views/directives/wc-scrub-bar.html'
  link: (scope, elem, attr, chimera) ->
    isSeeking = false
    isPlaying = false
    isPlayingWhenSeeking = false
    
    touchStartX = 0
    
    LEFT = 37
    RIGHT = 39
    NUM_PERCENT = 5
    
    scope.chimera = chimera

    scope.ariaTime = (time) ->
      Math.round time

    scope.onScrubBarTouchStart = ($event) ->
      event = $event.originalEvent or $event
      touches = event.touches
      touchX = undefined
      
      if WC_UTILS.isiOSDevice()
        touchStartX = (touches[0].clientX - (event.layerX)) * -1
      else
        touchStartX = event.layerX
      
      touchX = touches[0].clientX + touchStartX - (touches[0].target.offsetLeft)
      isSeeking = true
      
      if isPlaying
        isPlayingWhenSeeking = true
      
      chimera.pause()
      chimera.seekTime touchX * chimera.wcjsElement.length / elem[0].scrollWidth
      
      scope.$apply()
      return

    scope.onScrubBarTouchEnd = ($event) ->
      event = $event.originalEvent or $event
      
      if isPlayingWhenSeeking
        isPlayingWhenSeeking = false
        chimera.play()
      
      isSeeking = false
      scope.$apply()
      return

    scope.onScrubBarTouchMove = ($event) ->
      event = $event.originalEvent or $event
      touches = event.touches
      touchX = undefined
      
      if isSeeking
        touchX = touches[0].clientX + touchStartX - (touches[0].target.offsetLeft)
        chimera.seekTime touchX * chimera.wcjsElement.length / elem[0].scrollWidth
      
      scope.$apply()
      return

    scope.onScrubBarTouchLeave = (event) ->
      isSeeking = false
      scope.$apply()
      return

    scope.onScrubBarMouseDown = (event) ->
      event = WC_UTILS.fixEventOffset(event)
      isSeeking = true
      
      if isPlaying
        isPlayingWhenSeeking = true
      
      chimera.pause()
      chimera.seekTime event.offsetX * (chimera.wcjsElement.length / 1000) / elem[0].scrollWidth
      scope.$apply()
      return

    scope.onScrubBarMouseUp = (event) ->
      #event = WC_UTILS.fixEventOffset(event);
      if isPlayingWhenSeeking
        isPlayingWhenSeeking = false
        chimera.play()
      
      isSeeking = false
      
      #chimera.seekTime(event.offsetX * chimera.wcjsElement[0].duration / elem[0].scrollWidth);
      scope.$apply()
      return

    scope.onScrubBarMouseMove = (event) ->
      if isSeeking
        event = WC_UTILS.fixEventOffset(event)
        chimera.seekTime event.offsetX * chimera.wcjsElement.length / elem[0].scrollWidth
      
      scope.$apply()
      return

    scope.onScrubBarMouseLeave = (event) ->
      isSeeking = false
      scope.$apply()
      return

    scope.onScrubBarKeyDown = (event) ->
      currentPercent = chimera.currentTime / chimera.totalTime * 100
      
      if event.which == LEFT or event.keyCode == LEFT
        chimera.seekTime currentPercent - NUM_PERCENT, true
        event.preventDefault()
      else if event.which == RIGHT or event.keyCode == RIGHT
        chimera.seekTime currentPercent + NUM_PERCENT, true
        event.preventDefault()
      
      return

    scope.setState = (newState) ->
      if !isSeeking
        switch newState
          when WC_STATES.PLAY
            isPlaying = true
          when WC_STATES.PAUSE
            isPlaying = false
          when WC_STATES.STOP
            isPlaying = false

    scope.$watch ->
      chimera.currentState
    , (newVal, oldVal) ->
      if newVal != oldVal
        scope.setState newVal

    elem.bind 'mousedown', scope.onScrubBarMouseDown
    elem.bind 'mouseup', scope.onScrubBarMouseUp
    elem.bind 'mousemove', scope.onScrubBarMouseMove
    elem.bind 'mouseleave', scope.onScrubBarMouseLeave
