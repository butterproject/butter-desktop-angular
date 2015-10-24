'use strict'

angular.module 'app.webchimera'

.directive 'wcMedia', ($timeout, $sce, WC_UTILS, WC_STATES, wcjsRenderer) ->
  restrict: 'E'
  require: '^chimerangular'
  templateUrl: 'webchimera/views/directives/wc-media.html'
  scope:
    wcSrc: '=?'
  link: (scope, elem, attrs, chimera) ->
    sources = undefined

    # INIT
    chimera.wcjsElement = wcjsRenderer.init elem.find('canvas')[0]
    chimera.sources = scope.wcSrc

    chimera.addListeners()
    
    # FUNCTIONS
    scope.onChangeSource = (newValue, oldValue) ->
      if (!sources or newValue != oldValue) and newValue
        sources = newValue
        
        if chimera.currentState != WC_STATES.PLAY
          chimera.currentState = WC_STATES.STOP
        
        chimera.sources = sources
        scope.changeSource()

    scope.changeSource = ->
      i = 0
      l = sources.length
      
      while i < l
        if sources[i].selected
          chimera.wcjsElement.playlist.add $sce.trustAsResourceUrl(sources[i].src)
          break
        i++

      $timeout ->
        if chimera.autoPlay
          chimera.play()

        chimera.onVideoReady()
        return

    scope.$watch 'wcSrc', scope.onChangeSource
    
    scope.$watch ->
      chimera.sources
    , scope.onChangeSource

    if chimera.isConfig
      scope.$watch ->
        chimera.config
      , ->
        if chimera.config
          scope.wcSrc = chimera.config.sources

