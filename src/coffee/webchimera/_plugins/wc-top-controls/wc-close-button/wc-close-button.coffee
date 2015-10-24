'use strict'

angular.module 'app.webchimera.plugins.top-controls'

.directive 'wcCloseButton', ->
  restrict: 'E'
  require: '^chimerangular'
  templateUrl: 'webchimera/views/directives/wc-close-button.html'
  link: (scope, elem, attr, chimera) ->
    scope.onClosePlayer = ->
      chimera.stop()