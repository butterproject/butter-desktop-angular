'use strict'

angular.module 'app.webchimera'

.directive 'wcLoop', ->
  restrict: 'A'
  require: '^chimerangular'
  link: 
    pre: (scope, elem, attr, chimera) ->
      lp = undefined

      scope.setLoop = (value) ->
        angular.noop()
        
      if chimera.isConfig
        scope.$watch ->
          chimera.config
        , ->
          if chimera.config
            scope.setLoop chimera.config.loop
      else
        scope.$watch attr.wcLoop, (newValue, oldValue) ->
          if (!lp or newValue != oldValue) and newValue
            lp = newValue
            scope.setLoop lp
          else scope.setLoop()
