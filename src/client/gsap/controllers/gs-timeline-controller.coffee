'use strict'

angular.module 'app.gsTimelines'

.controller 'TimeLineController', ($scope, $element, $q, $timeout, $timeline, $log, gsUtils) ->
  vm = this

  timeline = null
  
  children = []
  steps = []
  
  pendingRebuild = null
  bouncedRebuild = null
  
  debounce = gsUtils.$debounce($timeout)
  
  parentController = $element.parent().controller('gsTimeline')

  asyncRebuild = ->
    rebuildTimeline = ->
      try
        # No rebuilding while active...
        if timeline and timeline.isActive()
          timeline.kill()
        
        # Build or update the TimelineMax instance
        timeline = $timeline.makeTimeline(
          id: $scope.id
          timeline: timeline
          steps: steps
          children: children
          target: findTimelineTarget()
          timeScale: +$scope.timeScale or 1.0)
        
        # Register for easy lookups later...
        $timeline.register timeline, $scope.id, $scope.state
        
        # Add to parent as child timeline (if parent exists)
        if parentController
          parentController.addChild timeline, $scope.position
        
        # Then resolve promise (for external requests)
        delete $timeline.$$dirty
        pendingRebuild.resolve timeline
      catch e
        pendingRebuild.reject e
      finally
        pendingRebuild = null
      
      return

    pendingRebuild = pendingRebuild or $q.defer()
    bouncedRebuild = bouncedRebuild or debounce(rebuildTimeline)

    # Keep debouncing...
    bouncedRebuild()
    
    # Temporarily mark this as dirty...
    if timeline != null
      timeline.$$dirty = pendingRebuild.promise
    
    return

  findTimelineTarget = ->
    target = $scope.target

    hasValidTarget = (element) ->
      target = element.attr('target')
      angular.isDefined(target) and target != ''

    if !angular.isDefined(target) or target == ''
      parent = $element.parent()
      timelineCntrl = parent.controller 'gsTimeline'
      
      isRoot = !timelineCntrl
      
      while timelineCntrl
        if hasValidTarget(parent)
          target = parent.attr 'target'
          break
        
        parent = angular.element(parent.parent())
        timelineCntrl = parent.controller('gsTimeline')

    target

  vm.addChild = (timeline, position) ->
    try
      # If not already registered...
      if children.indexOf(timeline) < 0
        children.push
          timeline: timeline
          position: position
    finally
      asyncRebuild()

    return

  vm.addResolve = (callback) ->
    timeline = timeline or $timeline.makeTimeline()
    timeline.$$resolveWith = callback

    return

  vm.addStep = (step) ->
    try
      if steps.indexOf(step) < 0
        steps.push step
    finally
      asyncRebuild()

    return

  vm.addCallback = (fn, position) ->
    wrapCallback = (fn) ->
      (tl) ->
        $q.when(fn()).then ->
          tl.resume()
          return
        return

    vm.addStep
      callback: wrapCallback(fn)
      position: position
      params: [ '{self}' ]

    return

  $scope.$watch 'timeScale', (current, previous) ->
    if current != previous
      if previous != ''
        $log.debug "timeScale( #{previous} -> #{current} )" 
      else 
        $log.debug "timeScale( #{current} )"
      asyncRebuild()

    return

  vm.timeline = ->
    if pendingRebuild then pendingRebuild.promise else $q.when(timeline)

  return