'use strict'

angular.module 'app.webchimera'

.directive 'wcNativeControls', ->
  restrict: 'A'
  require: '^chimerangular'
  link: 
    pre: (scope, elem, attr, chimera) ->
      controls = undefined

      scope.setControls = (value) ->
        angular.noop()

      if chimera.isConfig
        scope.$watch ->
          chimera.config
        , ->
          if chimera.config
            scope.setControls chimera.config.controls
      else
        scope.$watch attr.wcNativeControls, (newValue, oldValue) ->
          if (!controls or newValue != oldValue) and newValue
            controls = newValue
            scope.setControls controls
          else scope.setControls()
