'use strict'

angular.module 'app.webchimera'

.constant 'WC_STATES',
  PLAY: 'play'
  PAUSE: 'pause'
  STOP: 'stop'

.constant 'WC_VOLUME_KEY', 'chimerangularVolume'

.constant 'WC_FULLSCREEN_APIS', 
  w3:
    enabled: 'fullscreenEnabled'
    element: 'fullscreenElement'
    request: 'requestFullscreen'
    exit: 'exitFullscreen'
    onchange: 'fullscreenchange'
    onerror: 'fullscreenerror'
  newWebkit:
    enabled: 'webkitFullscreenEnabled'
    element: 'webkitFullscreenElement'
    request: 'webkitRequestFullscreen'
    exit: 'webkitExitFullscreen'
    onchange: 'webkitfullscreenchange'
    onerror: 'webkitfullscreenerror'
  oldWebkit:
    enabled: 'webkitIsFullScreen'
    element: 'webkitCurrentFullScreenElement'
    request: 'webkitRequestFullScreen'
    exit: 'webkitCancelFullScreen'
    onchange: 'webkitfullscreenchange'
    onerror: 'webkitfullscreenerror'
  moz:
    enabled: 'mozFullScreen'
    element: 'mozFullScreenElement'
    request: 'mozRequestFullScreen'
    exit: 'mozCancelFullScreen'
    onchange: 'mozfullscreenchange'
    onerror: 'mozfullscreenerror'
  ios:
    enabled: 'webkitFullscreenEnabled'
    element: 'webkitFullscreenElement'
    request: 'webkitEnterFullscreen'
    exit: 'webkitExitFullscreen'
    onchange: 'webkitfullscreenchange'
    onerror: 'webkitfullscreenerror'
  ms:
    enabled: 'msFullscreenEnabled'
    element: 'msFullscreenElement'
    request: 'msRequestFullscreen'
    exit: 'msExitFullscreen'
    onchange: 'MSFullscreenChange'
    onerror: 'MSFullscreenError'

.constant 'defaultPlayerConfig', 
  controls: false
  loop: false
  autoPlay: true
  autoHide: true
  autoHideTime: 3000
  preload: 'auto'
  sources: null
  tracks: []
  poster: null

.factory 'playerConfig', (defaultPlayerConfig) ->
  config: angular.copy defaultPlayerConfig

  reset: -> 
    @config = angular.copy defaultPlayerConfig

  merge: (config) ->
    @config = angular.merge @config, config 

