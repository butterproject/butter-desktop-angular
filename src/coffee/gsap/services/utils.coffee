'use strict'

angular.module 'app.gsTimelines'

.factory 'gsUtils', ->
  makeQuery: (source, targets) ->
    (selector) ->
      selector = selector or source.target
      element = targets[selector]

      if !element
        # Cache the querySelector DOM element for reuse
        targets[selector] = element = $(selector)
      
      element

  toJSON: (style) ->
    result = {}
    pairs = if !style then [] else style.replace(/\s+/g, '').split(/;/g)

    isObject = (it) ->
      it.indexOf('{') > -1 and it.indexOf('}') > -1

    extractObject = (it) ->
      matches = it.match(/[\s]*([A-Za-z]+)[\s]*\:[\s]*\{(.*)\}/)
      key = matches[1]
      value = @toJSON(String(matches[2]).replace(/,/g, ';').replace(/\"/g, ''))
    
      [key, value]
    
    pairs.forEach (it) =>
      if it.length
        it = if !isObject(it) then it.split(':') else extractObject(it)
        key = @stripQuotes(it[0])
        value = it[1]
        result[key] = if angular.isString(value) then @stripQuotes(value) else value
      return
    result

  keyValue: (map, key, defVal) ->
    if angular.isDefined(map[key]) and map[key].length > 0 then map[key] else defVal

  stripQuotes: (source) ->
    source.replace(/\"/g, '').replace /\'/g, ''

  getKeys: (source) ->
    results = []
    for key of source
      if source.hasOwnProperty(key)
        results.push key
    results

  $debounce: ($timeout, invokeApply) ->
    (func, wait, scope) ->
      timer = undefined
      ->
        context = scope
        args = Array::slice.call(arguments)
        $timeout.cancel timer
        timer = $timeout((->
          timer = undefined
          func.apply context, args
          return
        ), wait or 10, invokeApply)
        return

  isStateReversal: (state) ->
    state[0] == '-'

  stripStateReversal: (state) ->
    if state[0] == '-' then state.substr(1) else state
