'use strict'

angular.module 'app.webchimera.plugins.analytics', [ 'angulartics' ]

.directive 'wcAnalytics', ($analytics, WC_STATES) ->
  restrict: 'E'
  require: '^chimerangular'
  scope: 
    wcTrackInfo: '=?'
  link: (scope, elem, attr, chimera) ->
    info = null
    currentState = null
    totalMiliseconds = null

    progressTracks = []
    scope.chimera = chimera

    scope.trackEvent = (eventName) ->
      $analytics.eventTrack eventName, info

    scope.onPlayerReady = (isReady) ->
      if isReady
        scope.trackEvent 'ready'

    scope.onChangeState = (state) ->
      currentState = state

      switch state
        when WC_STATES.PLAY
          if scope.wcTrackInfo.events.play
            scope.trackEvent 'play'
        when WC_STATES.PAUSE
          if scope.wcTrackInfo.events.pause
            scope.trackEvent 'pause'
        when WC_STATES.STOP
          if scope.wcTrackInfo.events.stop
            scope.trackEvent 'stop'

    scope.onCompleteVideo = (isCompleted) ->
      if isCompleted
        scope.trackEvent 'complete'

    scope.onUpdateTime = (newCurrentTime) ->
      if progressTracks.length > 0 and newCurrentTime >= progressTracks[0].jump
        scope.trackEvent 'progress ' + progressTracks[0].percent + '%'
        progressTracks.shift()

    scope.updateTrackInfo = (newVal) ->
      if scope.wcTrackInfo.category
        info.category = scope.wcTrackInfo.category
      
      if scope.wcTrackInfo.label
        info.label = scope.wcTrackInfo.label

    scope.addWatchers = ->
      if scope.wcTrackInfo.category or scope.wcTrackInfo.label
        info = {}
        scope.updateTrackInfo scope.wcTrackInfo
      
      scope.$watch 'wcTrackInfo', scope.updateTrackInfo, true
      
      # Add ready track event
      if scope.wcTrackInfo.events.ready
        scope.$watch ->
          chimera.isReady
        , (newVal, oldVal) ->
          scope.onPlayerReady newVal

      # Add state track event
      if scope.wcTrackInfo.events.play or scope.wcTrackInfo.events.pause or scope.wcTrackInfo.events.stop
        scope.$watch ->
          chimera.currentState
        , (newVal, oldVal) ->
          if newVal != oldVal
            scope.onChangeState newVal

      # Add complete track event
      if scope.wcTrackInfo.events.complete
        scope.$watch ->
          chimera.isCompleted
        , (newVal, oldVal) ->
          scope.onCompleteVideo newVal

      # Add progress track event
      if scope.wcTrackInfo.events.progress
        scope.$watch ->
          chimera.currentTime
        , (newVal, oldVal) ->
          scope.onUpdateTime newVal / 1000

        totalTimeWatch = scope.$watch ->
          chimera.totalTime
        , (newVal, oldVal) ->
          totalMiliseconds = newVal / 1000
          
          if totalMiliseconds > 0
            totalTracks = scope.wcTrackInfo.events.progress - 1
            progressJump = Math.floor(totalMiliseconds / scope.wcTrackInfo.events.progress)
            i = 0
            
            while i < totalTracks
              progressTracks.push
                percent: (i + 1) * scope.wcTrackInfo.events.progress
                jump: (i + 1) * progressJump
              i++

            totalTimeWatch()

    if chimera.isConfig
      scope.$watch 'chimera.config', ->
        if scope.chimera.config
          scope.wcTrackInfo = scope.chimera.config.plugins.analytics
          scope.addWatchers()
    else scope.addWatchers()

