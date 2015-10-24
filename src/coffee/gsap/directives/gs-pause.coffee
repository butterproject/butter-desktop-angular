'use strict'

angular.module 'app.gsTimelines'

.directive 'gsPause', ->
  restrict: 'E'
  scope:
    resolve: '&'
    position: '@'
  require: '^gsTimeline'
  link: (scope, element, attr, ctrl) ->
    ctrl.addCallback scope.resolve, scope.position
    return
