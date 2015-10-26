'use strict'

angular.module 'app.common-directives'

.directive 'extOpen', (ipc) ->
  scope: { link: '=' }
  link: (scope, element, attrs) ->
    open = ->
      ipc.send 'open-url-in-external', scope.link

    element.on 'click', open

    scope.$on '$destroy', ->
      element.off 'click', open
