'use strict'

angular.module 'app.webchimera.plugins.dash', []

.directive 'wcDash', ->
  restrict: 'A'
  require: '^chimerangular'
  link: (scope, elem, attr, chimera) ->
    context = undefined
    player = undefined

    scope.isDASH = (url) ->
      if url.indexOf
        return url.indexOf('.mpd') > 0

    scope.onSourceChange = (url) ->
      # It's DASH, we use Dash.js
      if scope.isDASH(url)
        context = new (Dash.di.DashContext)
        player = new MediaPlayer(context)
        player.setAutoPlay chimera.autoPlay
        player.startup()
        player.attachView chimera.wcjsElement
        player.attachSource url
      else
        if player
          player.reset()
          player = null

    scope.$watch ->
      chimera.sources
    , (newVal, oldVal) ->
      scope.onSourceChange newVal[0].src
