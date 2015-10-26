'use strict'

angular.module 'app.services'

.directive 'ptLazyContainer', (ptLazyService) ->
  restrict: 'AC'
  controller: 'ptLazyController as lazy'
  link: (scope, element, attrs, controller) ->
    ptLazyService.trackIsVisibleContainer controller
    
    scope.$on '$destroy', ->
      ptLazyService.untrackIsVisibleContainer controller

.controller 'ptLazyController', ($element, ptLazyService) ->
  @items = []

  @scrollElement = null 

  @addItem = (item) ->
    @items.push item

  @removeItem = (item) ->
    @items = (i for i in @items when i isnt item)

  @checkIsVisible = (event) =>
    ptLazyService.checkIsVisible (i for i in @items), $element[0], event

  @

.directive 'ptLazyScroll', (ptLazyService) ->
  restrict: 'A'
  require: '^ptLazyContainer'
  link: (scope, element, attrs, containerController) ->
    ptLazyService.setScrollElement element, scope.type 

    element.bind 'scroll', containerController.checkIsVisible

    scope.$on '$destroy', ->
      element.unbind 'scroll', containerController.checkIsVisible

.directive 'ptLazyItem', ($parse, ptLazyService) ->
  restrict: 'A'
  require: '?^ptLazyContainer'
  link: (scope, element, attrs, containerController) ->
    return unless attrs.ptLazyItem

    ptLazyFunc = $parse attrs.ptLazyItem
    
    item =
      element: element
      wasVisible: no
      offset: 0
      callback: ($visible) -> 
        scope.$evalAsync =>
          ptLazyFunc scope, $visible: $visible
    
    containerController?.addItem item

    setTimeout containerController?.checkIsVisible

    scope.$on '$destroy', ->
      containerController?.removeItem item

.factory 'ptLazyService', ($q) ->
  _windowEventsHandlerBinded = no

  _containersControllers = []
  _scrollContainers = {}

  triggerIsVisibleCallback = (item, visible, isTopVisible, isBottomVisible) ->
    if visible
      elOffsetTop = item.element[0].getBoundingClientRect().top + window.pageYOffset
      isPartVisible = (isTopVisible and isBottomVisible and 'neither') or (isTopVisible and 'top') or (isBottomVisible and 'bottom') or 'both'

      unless item.wasVisible and item.wasVisible is isPartVisible and elOffsetTop is item.lastOffsetTop
        item.lastOffsetTop = elOffsetTop
        item.wasVisible = isPartVisible
        item.callback true
    else if item.wasVisible
      item.wasVisible = no
      item.callback false

  # The main function to check if the given items are in view relative to the provided container.
  checkIsVisible: (items, container, event) ->
    # It first calculate the viewport.
    viewport =
      top: 0
      bottom: window.innerHeight
    # Restrict viewport if a container is specified.
    if container and container isnt window
      bounds = container.getBoundingClientRect()

      # Shortcut to all item not in view if container isn't itself.
      if bounds.top > viewport.bottom or bounds.bottom < viewport.top
        triggerIsVisibleCallback(item, false) for item in items
        return

      # Actual viewport restriction.
      viewport.top = bounds.top if bounds.top > viewport.top
      viewport.bottom = bounds.bottom if bounds.bottom < viewport.bottom

    # Calculate inview status for each item.
    for item in items
      # Get the bounding top and bottom of the element in the viewport.
      element = item.element[0]
      bounds = element.getBoundingClientRect()

      # Apply offset.
      boundsTop = bounds.top + parseInt(item.offset?[0] ? item.offset)
      boundsBottom = bounds.bottom + parseInt(item.offset?[1] ? item.offset)

      # Calculate parts in view.
      if boundsTop < viewport.bottom and boundsBottom >= viewport.top
        triggerIsVisibleCallback(item, true, boundsBottom > viewport.bottom, boundsTop < viewport.top)
      else
        triggerIsVisibleCallback(item, false)


  setScrollElement: (el, id) ->
    _scrollContainers[id] = el

  getScrollElement: (id) -> 
    $q.when _scrollContainers[id]

  trackIsVisibleContainer: (controller) ->
    _containersControllers.push controller

  untrackIsVisibleContainer: (container) ->
    _containersControllers = (c for c in _containersControllers when c isnt container)