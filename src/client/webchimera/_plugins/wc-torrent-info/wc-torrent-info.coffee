'use strict'

angular.module 'app.webchimera.plugins.torrent-info', []

.directive 'wcTorrentInfo', ->
  restrict: 'E'
  require: '^chimerangular'
  scope: { torrent: '=?wcTorrent', player: '=?wcPlayer'  }
  templateUrl: 'webchimera/views/directives/wc-torrent-info.html'
  link: (scope, elem, attr, chimera) ->

    scope.stopPlaying = ->
      chimera.stop()
