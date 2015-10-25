'use strict'

angular.module 'app.services'

.config ($mdIconProvider) ->
  # Register a default set of SVG icon definitions
  $mdIconProvider.icon 'device:airplay', 'images/icons/devices/airplay-icon.svg'
  $mdIconProvider.icon 'device:xbmc', 'images/icons/devices/airplay-xbmc-icon.svg'
  $mdIconProvider.icon 'device:chromecast', 'images/icons/devices/chromecast-icon.svg'
  $mdIconProvider.icon 'device:dlna', 'images/icons/devices/dlna-icon.svg'
  $mdIconProvider.icon 'device:bomi', 'images/icons/devices/external-bomi-icon.svg'
  $mdIconProvider.icon 'device:fleex', 'images/icons/devices/external-fleex-player-icon.svg'
  $mdIconProvider.icon 'device:external', 'images/icons/devices/external-icon.svg'
  $mdIconProvider.icon 'device:mpc-hc', 'images/icons/devices/external-mpc-hc-icon.svg'
  $mdIconProvider.icon 'device:mplayer', 'images/icons/devices/external-mplayer-icon.svg'
  $mdIconProvider.icon 'device:mpv', 'images/icons/devices/external-mpv-icon.svg'
  $mdIconProvider.icon 'device:smplayer', 'images/icons/devices/external-smplayer-icon.svg'
  $mdIconProvider.icon 'device:vlc', 'images/icons/devices/external-vlc-icon.svg'
  $mdIconProvider.icon 'device:local', 'images/icons/devices/local-icon.svg'

  $mdIconProvider.icon 'topbar:close-color', 'images/icons/topbar/close-color.svg'
  $mdIconProvider.icon 'topbar:max-color', 'images/icons/topbar/max-color.svg'
  $mdIconProvider.icon 'topbar:min-color', 'images/icons/topbar/min-color.svg'

.run ($http, $templateCache) ->
  # Cache icons
  # Pre-fetch icons sources by URL and cache in the $templateCache...
  # subsequent $http calls will look there first.
  urls = [
    'images/icons/devices/airplay-icon.svg'
    'images/icons/devices/airplay-xbmc-icon.svg'
    'images/icons/devices/chromecast-icon.svg'
    'images/icons/devices/dlna-icon.svg'
    'images/icons/devices/external-bomi-icon.svg'
    'images/icons/devices/external-fleex-player-icon.svg'
    'images/icons/devices/external-icon.svg'
    'images/icons/devices/external-mpc-hc-icon.svg'
    'images/icons/devices/external-mplayer-icon.svg'
    'images/icons/devices/external-mpv-icon.svg'
    'images/icons/devices/external-smplayer-icon.svg'
    'images/icons/devices/external-vlc-icon.svg'
    'images/icons/devices/local-icon.svg'

    'images/icons/topbar/close-color.svg'
    'images/icons/topbar/max-color.svg'
    'images/icons/topbar/min-color.svg'
  ]
  angular.forEach urls, (url) ->
    $http.get url, cache: $templateCache
