'use strict'

angular.module 'app.detail', []

.directive 'wcDetail', ->
  scope: { player: '=', config: '=', torrent: '=' }
  bindToController: true
  restrict: 'E'
  templateUrl: 'detail/detail.html'
  controller: 'detailController as detail'

.controller 'detailController', ($scope, $filter, defaultPlayerConfig, $timeout, Settings, VODO) ->
  vm = this

  vm.currentDevice = Settings.chosenPlayer
  vm.currentQuality = '0'
  vm.currentTorrent = null

  vm.seasons = {}
  vm.selectedSeason = null

  api = null

  $scope.$watch 'detail.config.id', (newConfig) ->
    if newConfig
      vm.torrentId = vm.config.id
      vm.trakt_url = 'http://www.imdb.com/title/' + vm.config.id
      vm.type = vm.config.type
      api = VODO

#      if vm.config.subtype
#        api = Haruhichan
#      else
#        api = #switch vm.config.type
#          when 'show'
#            TVApi
#          else VODO

      getTorrentDetails vm.config.id, vm.config.type

  vm.goBack = ->
    vm.config.id = null
    vm.config.poster = null
    vm.data = null

  vm.selectSeason = (season) ->
    seasonIndex = '' + vm.selectedSeason

    if vm.seasons[seasonIndex]
      for first of vm.seasons[seasonIndex]
        vm.selected = vm.seasons[seasonIndex][first]
        break
    else vm.selected = vm.currentTorrent = null

    vm.currentQuality = '0'

  getTorrentDetails = (newTorrent, type) ->
    api.detail(newTorrent, type).then (resp) ->

      vm.data = resp.data
      vm.config.poster = $filter('traktSize')(resp.data.images.fanart, 'medium', vm.type)

      if vm.type is 'show'
        angular.forEach resp.data.episodes, (value, currentEpisode) ->
          vm.seasons[value.season] ?= {}
          vm.seasons[value.season][value.episode] = value
      else
        vm.selected = resp.data

        for key, first of resp.data.torrents
          vm.currentQuality = key
          break

  $scope.$watch 'detail.selected.torrents[detail.currentQuality]', (newTorrent) ->
    vm.currentTorrent = newTorrent

  if vm.type is 'show'
    $scope.$watch 'detail.selectedSeason', (newSeason) ->
      vm.selectSeason newSeason

  return
