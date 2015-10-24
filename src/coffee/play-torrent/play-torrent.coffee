'use strict'

angular.module 'app.play-torrent', []

.directive 'ptPlayTorrent', (torrentProvider) ->
  restrict: 'E'
  bindToController: { torrentLink: '=', episode: '=', quality: '=' , device: '=', detail: '=' }
  scope: { torrent: '=', player: '=' }
  templateUrl: 'play-torrent/play-torrent.html'
  controller: 'playTorrentController as ctrl'
  link: (scope, element, attrs) ->
    ctrl = scope.ctrl

    scope.startTorrent = ->
      scope.player = ctrl

      torrentProvider.addTorrentLink(ctrl.torrentLink).then (resp) ->
        torrentProvider.getTorrent(resp.data.infoHash).then (torrentDetail) ->
          scope.torrent = torrentDetail
          scope.torrent.listen()
      
      return

.controller 'playTorrentController', (Settings, torrentProvider) ->
  vm = this

  return
