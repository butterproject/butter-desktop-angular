'use strict'

angular.module 'app.webchimera.plugins.controls'

.directive 'wcScrubBarCurrentTime', ->
  restrict: 'E'
  require: '^chimerangular'
  link: (scope, elem, attr, chimera) ->
    percentTime = 0

    scope.onUpdateTime = (newCurrentTime) ->
      if typeof newCurrentTime == 'number' and chimera.totalTime
        percentTime = 100 * (newCurrentTime / chimera.totalTime)
        elem.css 'width', percentTime + '%'
      else elem.css 'width', 0

    scope.$watch ->
      chimera.currentTime
    , (newVal, oldVal) ->
      scope.onUpdateTime newVal
