'use strict'

angular.module 'app.gsTimelines'

.service '$timeline', ($log, $q, gsUtils) ->
  { stripStateReversal } = gsUtils 
  
  counter = 0
  
  targets = {}
  cache = {}
  
  self = 
    state: findByState
    id: findById
    register: register
    makeTimeline: makeTimeline

  registerCallbacks = (callbacks) ->
    (tl) ->
      if callbacks
        events = getKeys(callbacks)
        
        events.forEach (key) ->
          tl.eventCallback key, callbacks[key] or angular.noop, [ '{self}' ]
          return

      tl

  resolveBeforeUse = (tl) ->
    callback = tl.$$resolveWith or angular.noop
    
    $q.when(callback()).then ->
      tl

  waitForRebuild = (tl) ->
    if tl and tl.$$dirty then tl.$$dirty else tl

  $timeline = (id, callbacks) ->
    if angular.isDefined(id)
      id = stripStateReversal(id)
      promise = if hasState(id) then findByState(id) else findById(id)
      return promise.then(waitForRebuild).then(registerCallbacks(callbacks)).then(resolveBeforeUse)

    self

  makeTimeline = (source, flushTargets) ->
    source = source or
      steps: []
      children: []
    
    targets = if flushTargets then {} else targets
    
    querySelector = makeQuery(source, targets)
    
    timeline = source.timeline or new TimelineMax(
      paused: true
      data: id: source.id or counter++)
    
    timeline.clear(true).timeScale source.timeScale or 1.0
    timeline.data.id = source.id or timeline.data.id
    
    source.timeline = timeline
    source.steps = source.steps or []
    source.children = source.children or []
    
    source.steps.forEach (step) ->
      element = querySelector(step.target)
      callback = keyValue(step, 'callback', null)
      position = keyValue(step, 'position', null)
      frameLabel = keyValue(step, 'markPosition')
      styles = toJSON(updateZIndex(keyValue(step, 'style')))
      duration = getDuration(step, styles)
      styles = updateEasing(updateBounds(styles))
      
      if callback
        timeline.addPause position, callback, [ timeline ]
      else if frameLabel
        timeline.addLabel frameLabel, position
      else if duration == 0
        timeline.set element, styles
      else if useTweenMax(styles)
        timeline.append TweenMax.to(element, duration, styles), position
      else
        timeline.to element, +duration, styles, position or timeline.totalDuration()
      return
    
    source.children.forEach (it) ->
      child = it.timeline
      position = keyValue(it, 'position', null)
    
      if child
        child.paused false

        if !position
          timeline.append child
        else
          timeline.insert child, position
      return

    logBuild source, targets, $log

  getDuration = (step, styles) ->
    duration = keyValue(step, 'duration', 0)
    
    if duration == 0
      hasPosition = ! !keyValue(step, 'position')
    
      forceDuration = styles.zIndex or styles.className or styles.display
      forceDuration = forceDuration or hasPosition
    
      if forceDuration
        duration = '0.001'
    
    duration

  useTweenMax = (styles) ->
    needTweenMax = false

    if angular.isDefined(styles.yoyo)
      needTweenMax = true
      styles.yoyo = Boolean(styles.yoyo)

    if angular.isDefined(styles.repeat)
      needTweenMax = true
      styles.repeat = +styles.repeat

    needTweenMax

  updateZIndex = (styles) ->
    if angular.isString(styles) then styles.replace(/z-index/g, 'zIndex') else styles

  updateBounds = (styles) ->
    if styles.bounds
      ['left, top, width, height'].forEach (key) ->
        value = styles.bounds[key]
        
        if angular.isDefined(value)
          styles[key] = value
        return
    
    delete styles.bounds
    styles

  updateEasing = (styles) ->
    warning = 'TimelineBuilder::makeTimeline() - ignoring invalid easing `{0}` '
    invalid = true
    easing = styles.ease or ''

    exitOnInvalid = (key, inst) ->
      if angular.isUndefined(inst[key])
        $log.warn warning.supplant([ easing ])
        throw new Error('invalid ease')
      return

    try
      if easing.length
        inst = window
        keys = easing.split('.')
        
        keys.forEach (key) ->
          exitOnInvalid key, inst
          inst = inst[key]
          return
        
        invalid = if ! !inst then false else true
        styles.ease = inst
    catch e

    finally
      if invalid
        delete styles.ease

    styles

  findById = (id) ->
    deferred = $q.defer()
    timeline = cache[id]
    
    if timeline
      deferred.resolve timeline
    else
      deferred.reject 'Timeline( id == ' + id + ' ) was not found.'
    
    deferred.promise

  findByState = (state) ->
    deferred = $q.defer()

    angular.forEach cache, (it) ->
      if angular.isDefined(it.$$state)
        if it.$$state == state
          timeline = it
      return

    if timeline
      deferred.resolve timeline
    else
      deferred.reject 'Timeline( state == \'{0}\' ) was not found.'.supplant([ state ])
    
    deferred.promise

  hasState = (state) ->
    found = false
    
    angular.forEach cache, (it) ->
      if angular.isDefined(it.$$state)
        if it.$$state == state
          found = true
      return
    found

  register = (timeline, id, state) ->
    if timeline and id and id.length
      cache[id] = timeline
      
      if angular.isDefined(state)
        timeline.$$state = state

    return

  angular.forEach self, (fn, key) ->
    $timeline[key] = fn
    return

  $timeline