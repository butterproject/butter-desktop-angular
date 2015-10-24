'use strict'

angular.module 'app.common-directives'

.directive 'ptParallax', ($window, ptLazyService) ->
  restrict: 'A'
  link: (scope, elem, attrs) ->
    parent = null

    ratio = (first, second) ->
      r = first / second
      
      if r < 0 then return 0
      if r > 1 then return 1
      
      Number r.toString().match /^\d+(?:\.\d{0,2})?/

    setPosition = ->
      unless document.body.style.position is 'fixed'
        calcValY = parent.scrollTop * (attrs.parallaxRatio or 1)

        switch attrs.ptParallax
          when 'fade'
            transform = ratio calcValY, elem[0].clientHeight
            
            elem.css 'opacity', 1 - transform

          when 'background'
            calcValY = elem.prop('offsetTop') - calcValY

            elem.css 'background-position', '50% ' + calcValY + 'px'

          when 'sticky'
            transform = ratio parent.scrollTop, elem.parent()[0].offsetTop

            elem.css 'top', -Math.abs(elem.parent()[0].offsetTop) + 'px'
            elem.css 'padding-top', elem.parent()[0].offsetTop + 'px'
            
            elem.css 'left', '100px'
            elem.css 'right', '0px'

            if transform >= 1
              elem.css 'position', 'fixed'
            else 
              elem.css 'position', null
              elem.css 'left', '0px'

            elem.css 'background-color', 'rgba(0, 0, 0,' + transform + ')'

        return

    throttleOnAnimationFrame = (func) ->
      ->
        context = this
        args = arguments
        
        $window.cancelAnimationFrame timeout
        
        timeout = $window.requestAnimationFrame ->
          func.apply context, args
          timeout = null

    ptLazyService.getScrollElement(scope.type).then (parentElement) ->
      parent = parentElement[0]

      throttledScroll = throttleOnAnimationFrame setPosition

      if attrs.ptParallax is 'background'
        angular.element($window).bind 'load', ->
          setPosition()
          scope.$apply()
      else setPosition()

      parentElement.on 'scroll resize', throttledScroll

      scope.$on '$destroy', ->
        parentElement.off 'resize scroll', throttledScroll

      throttledScroll()

    return