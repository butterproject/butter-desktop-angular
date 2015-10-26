'use strict'

angular.module 'app.webchimera.plugins.controls'

.directive 'wcScrubBarCuePoints', ->
  restrict: 'E'
  require: '^chimerangular'
  templateUrl: 'webchimera/views/directives/wc-scrub-bar-cue-points.html'
  scope: 'wcCuePoints': '='
  link: (scope, elem, attr, chimera) ->

    scope.onPlayerReady = ->
      scope.updateCuePoints scope.wcCuePoints

    scope.updateCuePoints = (cuePoints) ->
      totalWidth = undefined

      if cuePoints
        totalWidth = parseInt(elem[0].clientWidth)
        i = 0
        l = cuePoints.length
        
        while i < l
          cuePointDuration = (cuePoints[i].timeLapse.end - (cuePoints[i].timeLapse.start)) * 1000
          position = cuePoints[i].timeLapse.start * 100 / chimera.totalTime * 1000 + '%'
          percentWidth = 0
          
          if typeof cuePointDuration == 'number' and chimera.totalTime
            percentWidth = cuePointDuration * 100 / chimera.totalTime + '%'
          
          cuePoints[i].$$style =
            width: percentWidth
            left: position
          
          i++

    scope.$watch 'wcCuePoints', scope.updateCuePoints
    
    scope.$watch ->
      chimera.totalTime
    , (newVal, oldVal) ->
      if newVal > 0
        scope.onPlayerReady()

