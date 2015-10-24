'use strict'

angular.module 'app.header', []

.directive 'ptHeader', ->
  restrict: 'E'
  templateUrl: 'header/header.html'
  controller: 'ptHeaderCtrl as title'

.controller 'ptHeaderCtrl', ($scope, $rootScope, titleButtons, ipc, AdvSettings, $location) ->
  vm = this

  vm.platform = process.platform
  vm.buttons = titleButtons[process.platform]
  vm.name = AdvSettings.get('branding').name

  vm.state = 
    fullscreen: false
    maximized: false

  vm.max = ->
    if vm.state.fullscreen
      vm.fullscreen()
    else
      if window.screen.availHeight <= ipc.height
        ipc.send 'unminimize'
        vm.state.maximized = false
      else
        ipc.send 'maximize'
        vm.state.maximized = true

  vm.min = ->
    ipc.send 'minimize'

  vm.close = ->
    ipc.send 'close'

  vm.fullscreen = ->
    ipc.send 'toggleFullscreen'
    vm.state.fullscreen = true

  return
