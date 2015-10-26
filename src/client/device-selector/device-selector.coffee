'use strict'

angular.module 'app.device-selector', []

.directive 'ptDeviceSelector', ->
  scope: { selected: '=' }
  bindToController: true
  templateUrl: 'device-selector/device-selector.html'
  controller: 'deviceSelectController as devices'

.controller 'deviceSelectController', (Settings) ->
  vm = this

  vm.items = Settings.avaliableDevices
  vm.selected = if Settings.chosenPlayer? then Settings.chosenPlayer else "local"
  console.log vm.items
  console.log vm.selected
  vm.openMenu = ($mdOpenMenu, event) ->
    originatorEv = event
    $mdOpenMenu event

  vm.setItem = (id) ->
    Settings.chosenPlayer = vm.selected = id

  vm.setItem vm.selected

  return
