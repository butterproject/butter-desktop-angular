'use strict'

angular.module 'app.browser', []

.controller 'browserController', ($scope, $interval, VODO, playerConfig) ->
  vm = this

  vm.loading = false 

  bgCycler = null

  api = switch $scope.type
    when 'Movies'
      VODO
#    when 'Anime'
#      Haruhichan
    else null

  vm.activeBgImageIndex = 0

  vm.selectDetail = (item) ->
    playerConfig.merge 
      id: item._id
      type: item.type
      subtype: item.subtype
      title: item.title

  vm.cycleBgImages = ->
    if bgCycler
      $interval.cancel bgCycler

    cycle = ->
      if vm.bgImages
        selectedKey = vm.activeBgImageIndex++ % vm.bgImagesKeys.length
        vm.backdrop = vm.bgImages[vm.bgImagesKeys[selectedKey]].images?.fanart

    bgCycler = $interval cycle, 10000

    cycle()
  
  getBackdrop = (results) ->
    console.log results
    vm.bgImages = results
    vm.bgImagesKeys = Object.keys results
    vm.cycleBgImages()

  vm.currentFilters = 
    page: 1

  fetchData = ->
    if not vm.loading 
      vm.loading = true 

      if api 
        api.fetch(vm.currentFilters).then (resp) ->
          getBackdrop resp.results
          vm.data = resp.results
          vm.loading = false 

  vm.loadMoreItems = ->
    vm.currentFilters.page = vm.currentFilters.page + 1
    fetchData()

  vm.onChange = (filter) ->
    vm.currentFilters = angular.merge vm.currentFilters, filter.params
    vm.data = {}
    fetchData()

  fetchData()

  $scope.$on '$destroy', ->
    $interval.cancel bgCycler

  return 
