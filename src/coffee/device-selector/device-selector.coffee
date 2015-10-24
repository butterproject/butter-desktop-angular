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

  vm.toggleMenu = ($event) ->
    $event.stopPropagation()
    vm.menuOpen = !vm.menuOpen

  vm.setItem = (item, $event) ->
    vm.toggleMenu $event
    Settings.chosenPlayer = vm.selected = item
    
  return