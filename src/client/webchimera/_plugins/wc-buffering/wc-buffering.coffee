'use strict'

angular.module 'app.webchimera.plugins.buffering', []

.directive 'wcBuffering', (WC_STATES, WC_UTILS) ->
  restrict: 'E'
  require: '^chimerangular'
  templateUrl: 'webchimera/views/directives/wc-buffering.html'
  link: (scope, elem, attr, chimera) ->

    scope.showSpinner = ->
      scope.spinnerClass = stop: chimera.isBuffering
      elem.css 'display', 'block'

    scope.hideSpinner = ->
      scope.spinnerClass = stop: chimera.isBuffering
      elem.css 'display', 'none'

    scope.setState = (isBuffering) ->
      if isBuffering
        scope.showSpinner()
      else scope.hideSpinner()

    scope.onStateChange = (state) ->
      if state == WC_STATES.STOP
        scope.hideSpinner()

    scope.onPlayerReady = (isReady) ->
      if isReady
        scope.hideSpinner()

    scope.showSpinner()

    scope.$watch ->
      chimera.isReady
    , (newVal, oldVal) ->
      if chimera.isReady == true or newVal != oldVal
        scope.onPlayerReady newVal

    scope.$watch ->
      chimera.currentState
    , (newVal, oldVal) ->
      if newVal != oldVal
        scope.onStateChange newVal

    scope.$watch ->
      chimera.isBuffering
    , (newVal, oldVal) ->
      if newVal != oldVal
        scope.setState newVal