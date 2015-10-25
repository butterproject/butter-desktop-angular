'use strict'

angular.module 'app.services'

.config ($mdIconProvider) ->
  # Devices
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

  # System
  $mdIconProvider.icon 'topbar:close-color', 'images/icons/topbar/close-color.svg'
  $mdIconProvider.icon 'topbar:max-color', 'images/icons/topbar/max-color.svg'
  $mdIconProvider.icon 'topbar:min-color', 'images/icons/topbar/min-color.svg'

  # Social
  $mdIconProvider.icon 'social:blog', 'images/icons/social/blog.svg'
  $mdIconProvider.icon 'social:discuss', 'images/icons/social/discuss.svg'
  $mdIconProvider.icon 'social:facebook', 'images/icons/social/facebook.svg'
  $mdIconProvider.icon 'social:github', 'images/icons/social/github.svg'
  $mdIconProvider.icon 'social:google-plus', 'images/icons/social/google-plus.svg'
  $mdIconProvider.icon 'social:twitter', 'images/icons/social/twitter.svg'
  $mdIconProvider.icon 'social:website', 'images/icons/social/website.svg'


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

    'images/icons/social/blog.svg'
    'images/icons/social/discuss.svg'
    'images/icons/social/facebook.svg'
    'images/icons/social/github.svg'
    'images/icons/social/google-plus.svg'
    'images/icons/social/twitter.svg'
    'images/icons/social/website.svg'

  ]
  angular.forEach urls, (url) ->
    $http.get url, cache: $templateCache
