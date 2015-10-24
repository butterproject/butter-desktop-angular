'use strict'

angular.module 'app.gsTimelines'

.directive 'gsTimeline', ($parse, $$gsStates) ->
  counter = 1

  restrict: 'E'
  scope: timeScale: '@?'
  require: '^?gsTimeline'
  controller: 'TimeLineController'
  link: (scope, element, attr, controller) ->

    prepareResolve = ->
      if angular.isDefined(attr.resolve)
        context = scope.$parent
        fn = $parse(attr['resolve'], null, true)
        
        controller.addResolve ->
          fn context
      
      return

    prepareStateWatch = ->
      if angular.isDefined(attr.state)
        $$gsStates.addTimeline
          scope: scope
          state: attr.state
          controller: controller
          parentController: element.parent().controller 'gsTimeline'
          
      return

    scope.id = attr.id or attr.state or 'timeline_' + counter++
    scope.position = attr.position or 0
    scope.timeScale = scope.timeScale or 1.0
    scope.state = attr.state
    scope.target = attr.target

    prepareResolve()
    prepareStateWatch()
