'use strict'

angular.module 'app.quality-selector', []

.directive 'ptQualitySelector', ->
  scope: { torrents: '=', selected: '=' }
  bindToController: { list: '=' }
  templateUrl: 'quality-selector/quality-selector.html'
  controller: 'qualityCtrl as quality'

.controller 'qualityCtrl', ($scope) ->
  vm = this

  # If no selection or selection is not in the list: get first element in the list
  for key of vm.list
    vm.selected = key unless vm.selected and vm.list.indexOf(vm.selected) isnt -1
    break

  vm.openMenu = ($mdOpenMenu, event) ->
    originatorEv = event
    $mdOpenMenu event

  vm.setItem = (quality) ->
    vm.selected = quality

  vm.setItem vm.selected

  return
