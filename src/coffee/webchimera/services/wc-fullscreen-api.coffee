'use strict'

angular.module 'app.webchimera'

.service 'wcFullscreen', (WC_UTILS, WC_FULLSCREEN_APIS) ->
  # Native fullscreen polyfill
  polyfill = null

  APIS = WC_FULLSCREEN_APIS

  isFullScreen = ->
    document[polyfill.element] != null

  for browser of APIS
    if APIS[browser].enabled of document
      polyfill = APIS[browser]
      break

  @isAvailable = polyfill != null

  if polyfill
    @onchange = polyfill.onchange
    @onerror = polyfill.onerror
    @isFullScreen = isFullScreen

    @exit = ->
      document[polyfill.exit]()
      return

    @request = (elem) ->
      elem[polyfill.request]()
      return

  return
