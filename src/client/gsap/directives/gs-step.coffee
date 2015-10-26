'use strict'

angular.module 'app.gsTimelines'

.directive 'gsStep', ->
  restrict: 'E'
  scope:
    className: '@?'
    duration: '@?'
    markPosition: '@?'
    position: '@?'
    style: '@'
  require: '^gsTimeline'
  compile: (tElement, tAttrs, transclude) ->
    if angular.isDefined tAttrs.style
      tAttrs.style = tAttrs.style.replace /,/g, ';'
    
    (scope, element, attr, ctrl) ->
      scope.target = attr.target
      
      scope.$watch 'style', ->
        ctrl.addStep scope
        return
        
      return
