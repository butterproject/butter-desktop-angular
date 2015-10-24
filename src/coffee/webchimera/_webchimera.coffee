'use strict'

angular.module 'app.webchimera', [
  'app.webchimera.plugins.controls'
  'app.webchimera.plugins.top-controls'
  'app.webchimera.plugins.buffering'
  'app.webchimera.plugins.overlayplay'
  'app.webchimera.plugins.poster'
  'app.webchimera.plugins.torrent-info'
]

.directive 'ptDetail', ->
  restrict: 'E'
  templateUrl: 'webchimera/webchimera.html'
  controller: 'detailCtrl as chimera'

.controller 'detailCtrl', (playerService, $scope, playerConfig, $rootScope) ->
  vm = this

  vm.config = playerConfig.config
  
  vm.player = 
    id: null

  $scope.$watch 'chimera.torrent.ready', (readyState) ->
    vm.config.controls = readyState

  $scope.$watchCollection 'chimera.player', (newPlayer, oldPlayer) ->
    if $rootScope.type is 'show'
      playerService.sortNextEpisodes(newPlayer).then (data) ->
        vm.config.next = data

  return