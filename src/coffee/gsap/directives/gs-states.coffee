'use strict'

angular.module 'app.gsTimelines'

.service '$$gsStates', ($timeline, $log, $rootScope, gsUtils) ->
  { isStateReversal, stripStateReversal } = gsUtils

  registry = {}

  scopeFor = (state) ->
    data = registry[state]
    if data then data.scope else undefined

  watchState = (state) ->
    $log.debug 'TimelineStates::watchState( state = ' + state + ' )'
    
    parent = scopeFor(state).$parent
    parent.state = parent.state or undefined
    
    unwatch = parent.$watch 'state', (current, previous) ->
      if state == ''
        return
    
      if current == previous
        return
    
      if current == undefined
        return
    
      $rootScope.$evalAsync ->
        shouldReverse = isStateReversal(current)
    
        $timeline(state).then (timeline) ->
          current = stripStateReversal(current)
          $log.debug '>> TimelineStates::triggerTimeline( state = ' + current + ')'
    
          if current == state
            if shouldReverse
              timeline.reverse()
            else
              timeline.restart()

    parent.$on '$destroy', unwatch

    return

  addTimeline: (data) ->
    state = data.state
    
    if state and state.length
      registry[state] = data

      if !data.parentController
        watchState state

    return