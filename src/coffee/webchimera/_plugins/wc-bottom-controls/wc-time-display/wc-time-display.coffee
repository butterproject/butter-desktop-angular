'use strict'

angular.module 'app.webchimera.plugins.controls'

.directive 'wcTimeDisplay', ->
  require: '^chimerangular'
  restrict: 'E'
  link: (scope, elem, attr, chimera) ->
    scope.currentTime = chimera.currentTime
    scope.timeLeft = chimera.timeLeft
    scope.totalTime = chimera.totalTime
    scope.isLive = chimera.isLive

    scope.$watch ->
      chimera.currentTime
    , (newVal, oldVal) ->
      scope.currentTime = newVal

    scope.$watch ->
      chimera.timeLeft
    , (newVal, oldVal) ->
      scope.timeLeft = newVal

    scope.$watch ->
      chimera.totalTime
    , (newVal, oldVal) ->
      scope.totalTime = newVal

    scope.$watch ->
      chimera.isLive
    , (newVal, oldVal) ->
      scope.isLive = newVal
