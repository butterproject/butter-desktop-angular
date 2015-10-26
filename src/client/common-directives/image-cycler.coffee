'use strict'

angular.module 'app.common-directives'

.directive 'backgroundCycler', ($compile, $animate, $q) ->
  restrict: 'E'
  link: (scope, element, attr) ->
    image = null
    imageScope = null

    $animate.enabled element

    scope.$watch 'browser.backdrop', (newImageUrl) ->
      if newImageUrl
        newScope = scope.$new()
        newScope.url = newImageUrl
        
        animations = []

        if image
          animations.push $animate.leave image

        image = angular.element '<background-image></background-image>'
        newImage = $compile(image) newScope
        
        animations.push $animate.enter newImage, element, null

        $q.all(animations).then ->
          if imageScope
            imageScope.$destroy()
          imageScope = newScope

        return

.directive 'backgroundImage', ($compile, $animate) ->
  restrict: 'E'
  template: '<div class="bg-image" pt-parallax="background" parallax-ratio="1.22"></div>'
  replace: true
  scope: true
  link: (scope, element, attr) ->
    if scope.url
      element.css 'background-image': 'url(' + scope.url + ')'
    return
