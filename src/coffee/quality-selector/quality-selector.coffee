'use strict'

angular.module 'app.quality-selector', []

.directive 'ptQualitySelector', ->
  restrict: 'A'
  scope: { torrents: '=', selected: '=' }
  bindToController: true
  templateUrl: 'quality-selector/quality-selector.html'
  controller: 'qualityCtrl as quality'

.controller 'qualityCtrl', ($scope) ->
  vm = this

  # I dont knwy but in the template, quality.torrents is empty...
  # So I fake it for now...
  vm.fakelist = {"480p": "blablab", "720p": "blablab", "1080p": "blablab"}
  vm.selected = '480p' unless vm.selected

  vm.openMenu = ($mdOpenMenu, event) ->
    originatorEv = event
    $mdOpenMenu event

  vm.setItem = (quality) ->
    vm.selected = quality

  vm.setItem vm.selected

  return
