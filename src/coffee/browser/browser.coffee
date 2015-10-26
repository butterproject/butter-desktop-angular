'use strict'
clipboard = require('clipboard')

angular.module 'app.browser', []

.controller 'browserController', ($scope, $interval, $window, VODO, playerConfig) ->
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

  # Handle drag and drop event
  angular.element($window).bind 'dragenter', (event) ->
    event.preventDefault()
    event.stopPropagation()
    false
  angular.element($window).bind 'dragover', (event) ->
    event.preventDefault()
    event.stopPropagation()
    false
  angular.element($window).bind 'drop', (event) ->

    if event.handled != true

      event.preventDefault()
      event.stopPropagation()

      # Only take the first file in case there is multiple
      file = event.dataTransfer.files[0]
      reader = new FileReader
      reader.readAsText file

      # From here we need to do several things
      # 1. Check wether the file is a torrent file
      # 2. If it does -> play the torrent
      # 3. If it doesn't -> display a warning message to the user
      reader.onload = ((file) ->
        (e) ->
          console.log file.name
          console.log file.type
          console.log file.size
          console.log file.lastModifiedDate
          # console.log reader.result
          return
      )(file)

    else
      event.handled = true

    false

  # Handle Ctrl+V to paste magnet link
  vm.ctrlDown = false
  vm.ctrlKey = 17
  vm.vKey = 86

  $scope.keyDownFunc = ($event) ->
    if vm.ctrlDown and $event.keyCode == vm.vKey
      # From here we need to do several things
      # 1. Check wether the string is a valid magnet link
      # 2. If it does -> play the torrent
      # 3. If it doesn't -> display a warning message to the user

      console.log 'Looking for a magnet link in the following string : ' + clipboard.readText()
    return

  angular.element($window).bind 'keyup', ($event) ->
    if vm.keyCode == vm.ctrlKey
      $scope.ctrlDown = false
    $scope.$apply()
    return

  angular.element($window).bind 'keydown', ($event) ->
    if $event.keyCode == vm.ctrlKey
      vm.ctrlDown = true
    $scope.$apply()
    return

  return
