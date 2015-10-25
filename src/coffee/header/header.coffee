'use strict'

remote = require 'remote'

angular.module 'app.header', []

.directive 'ptHeader', ->
  restrict: 'E'
  templateUrl: 'header/header.html'
  controller: 'ptHeaderCtrl as title'

.controller 'ptHeaderCtrl', ($scope, $rootScope, titleButtons, AdvSettings, $location) ->
  vm = this

  vm.platform = process.platform
  vm.buttons = titleButtons[process.platform]
  vm.name = AdvSettings.get('branding').name

  vm.max = ->
    window = remote.getCurrentWindow()
    if window.isFullScreen()
      vm.fullscreen()
    else
      if window.isMaximized()
        window.unmaximize()
      else
        window.maximize()

  vm.min = ->
    window = remote.getCurrentWindow()
    window.minimize()

  vm.close = ->
    window = remote.getCurrentWindow()
    window.close()

  vm.fullscreen = ->
    window.setFullScreen(vm.state.fullscreen)

  return
