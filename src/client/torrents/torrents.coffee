'use strict'

angular.module 'app.torrents', []

.directive 'ptTorrentItem', ->
  restrict: 'E'
  scope: { data: '=' }
  controllerAs: 'torrent'
  bindToController: true
  templateUrl: 'torrents/torrents.html'
  controller: ($scope, torrentProvider, socketServer) ->
    vm = this

    vm.download = ->
      if vm.link
        Torrent.save(link: vm.link).$promise.then (torrent) ->
          loadTorrent torrent.infoHash
        vm.link = ''

    vm.pause = (torrent, $event) ->
      $event.stopPropagation() 
      socketServer.emit (if torrent.stats.paused then 'resume' else 'pause'), torrent.infoHash

    vm.remove = (torrent) ->
      Torrent.remove infoHash: torrent.infoHash
      delete vm.data[torrent.infoHash]

    return 

.controller 'torrentsController', ($interval, $resource, $q, socketServer, streamServer, torrentProvider) ->
  vm = this

  vm.keypress = (e) ->
    if e.which == 13
      vm.download()
    return

  vm.select = (torrent, file) ->
    socketServer.emit (if file.selected then 'deselect' else 'select'), torrent.infoHash, torrent.files.indexOf(file)

  return 

