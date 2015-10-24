'use strict'

angular.module 'app.quality-icon', []

.directive 'qualityIcon', ->
  restrict: 'A'
  scope: { torrent: '=' }
  bindToController: true
  templateUrl: 'quality-icon/quality-icon.html'
  controller: 'qualityIconCtrl as quality'

.controller 'qualityIconCtrl', (torrentHealth, $filter, $scope) ->
  vm = this
  
  torrentHealthRestarted = 0

  onSuccess = (torrent) ->
    vm.health = $filter('calcHealth')(torrent)
    vm.ratio = if torrent.peers > 0 then torrent.seeds / torrent.peers else +torrent.seeds

  onError = -> vm.health = 'none' 

  vm.getTorrentHealth = (newTorrent) ->
    vm.health = null

    if newTorrent.substring(0, 8) is 'magnet:?'
      torrentLink = newTorrent.split('&tr')[0] + '&tr=udp://tracker.openbittorrent.com:80/announce' + '&tr=udp://open.demonii.com:1337/announce' + '&tr=udp://tracker.coppersurfer.tk:6969'
     
      torrentHealth(torrentLink).then onSuccess, onError

  $scope.$watch 'quality.torrent', (newTorrent) ->
    vm.getTorrentHealth newTorrent.url 

  return