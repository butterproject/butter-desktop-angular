'use strict'

angular.module 'app.gsTimelines'

.directive 'gsScale', ($window, $timeout, gsUtils) ->
  restrict: 'A'
  link: (scope, element, attr) ->

    watchResize = (targetFn) ->
      win = angular.element($window)

      debounce = gsUtils.$debounce($timeout, true)
      onResizeFn = debounce(targetFn, 30)

      win.bind 'resize', onResizeFn

      ->
        win.unbind 'resize', onResizeFn
        return

    fixedScale = if attr['gsScale'] then parseFloat(attr['gsScale']) else NaN
    isLocked = !isNaN(fixedScale)
    timeline = new TimelineMax

    adjustScaling = ->
      win = 
        width: $window.innerWidth - 20
        height: $window.innerHeight - 20
      
      stage = 
        width: element[0].clientWidth
        height: element[0].clientHeight
      
      scaling = Math.min(win.height / stage.height, win.width / stage.width)
      selector = '#' + attr.id
      
      # Scale and FadeIn entire stage for better UX
      timeline.clear(true).set(selector,
        scale: if isLocked then fixedScale else scaling
        transformOrigin: '0 0 0').to selector, 0.5, opacity: 1
      
      return

    adjustScaling()

    if !isLocked
      # Watch resize; remove watcher during tear down.
      scope.$on '$destroy', watchResize(adjustScaling)
      
    return
