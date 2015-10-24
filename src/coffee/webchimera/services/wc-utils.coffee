'use strict'

angular.module 'app.webchimera'

.service 'WC_UTILS', ($window) ->
  ###*
  # There's no offsetX in Firefox, so we fix that.
  # Solution provided by Jack Moore in this post:
  # http://www.jacklmoore.com/notes/mouse-position/
  # @param $event
  # @returns {*}
  ###
  @fixEventOffset = ($event) ->
    matchedFF = navigator.userAgent.match(/Firefox\/(\d+)/i)

    if matchedFF and Number.parseInt(matchedFF.pop()) < 39
      style = $event.currentTarget.currentStyle or window.getComputedStyle($event.target, null)
      borderLeftWidth = parseInt(style['borderLeftWidth'], 10)
      borderTopWidth = parseInt(style['borderTopWidth'], 10)
      rect = $event.currentTarget.getBoundingClientRect()
      offsetX = $event.clientX - borderLeftWidth - (rect.left)
      offsetY = $event.clientY - borderTopWidth - (rect.top)
      $event.offsetX = offsetX
      $event.offsetY = offsetY
    $event

  ###*
  # Inspired by Paul Irish
  # https://gist.github.com/paulirish/211209
  # @returns {number}
  ###
  @getZIndex = ->
    zIndex = 1
    elementZIndex = undefined
    tags = document.getElementsByTagName('*')
    
    i = 0
    l = tags.length
    
    while i < l
      elementZIndex = parseInt(window.getComputedStyle(tags[i])['z-index'])
      if elementZIndex > zIndex
        zIndex = elementZIndex + 1
      i++
    
    zIndex

  ###*
  # Test the browser's support for HTML5 localStorage.
  # @returns {boolean}
  ###
  @supportsLocalStorage = ->
    testKey = 'chimerangular-test-key'
    storage = $window.sessionStorage
    
    try
      storage.setItem testKey, '1'
      storage.removeItem testKey
      return 'localStorage' of $window and $window['localStorage'] != null
    catch e
      return false

    return

  return

