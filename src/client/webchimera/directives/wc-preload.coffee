'use strict'

angular.module 'app.webchimera'

.directive 'wcPreload', ->
  restrict: 'A'
  require: '^chimerangular'
  link: 
    pre: (scope, elem, attr, chimera) ->
      preload = undefined

      scope.setPreload = (value) ->
        angular.noop()
           
      if chimera.isConfig
        scope.$watch ->
          chimera.config
        , ->
          if chimera.config
            scope.setPreload chimera.config.preload
      else
        scope.$watch attr.wcPreload, (newValue, oldValue) ->
          if (!preload or newValue != oldValue) and newValue
            preload = newValue
            scope.setPreload preload
          else scope.setPreload()
