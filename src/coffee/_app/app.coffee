'use strict'

angular.module 'app', [
  # vendor
  'ngSanitize'
  'ngMaterial'
  'ngAnimate'
  'ngAria'

  'socket-io'
  'xmlrpc'

  'app.about'
  'app.bookmarks'
  'app.browser'
  'app.common-directives'
  'app.containers'
  'app.detail'
  'app.device-selector'
  'app.filter-bar'
  'app.header'
  'app.gsTimelines' 
  'app.page-header'
  'app.plugins'
  'app.play-torrent'
  'app.providers'
  'app.quality-icon'
  'app.quality-selector'
  'app.services'
  'app.settings'
  'app.streamer'
  'app.torrents'
  'app.webchimera'
  
]

.config ($compileProvider, $httpProvider, $mdThemingProvider) ->

  $compileProvider.debugInfoEnabled true

