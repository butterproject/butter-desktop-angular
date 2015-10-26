'use strict'

angular.module 'app.gsTimelines'

.factory 'logBuild', ($log, gsUtils) ->
  { keyValue } = gsUtils

  (source, targets) ->
    $log.debug ">> TimelineBuilder::makeTimeline() invoked by $timeline(#{source.timeline.data.id})"
    
    source.steps.forEach (step) ->
      frameLabel = keyValue(step, 'markPosition')
      position = keyValue(step, 'position', '')
      styles = toJSON(keyValue(step, 'style'))
      hasDuration = ! !keyValue(step, 'duration')
      duration = if hasDuration then keyValue(step, 'duration') else 0
    
      if frameLabel
        $log.debug "addLabel(#{[frameLabel ]}"
      else if hasDuration
        $log.debug "timeline.set( #{ step.target }, #{duration},  #{JSON.stringify(styles)}, #{position} )"
      else
        $log.debug "timeline.set( #{step.target}, #{JSON.stringify(styles)} )"
    
      return
    
    source.children.forEach (it) ->
      if it.timeline
        $log.debug "$timeline(#{source.timeline.data.id}).addChild(#{it.timeline.data.id})"

    source.timeline