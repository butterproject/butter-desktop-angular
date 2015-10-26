'use strict'

angular.module 'app.filter-bar', []

.directive 'ptFilterBar', ->
  restrict: 'E'
  scope: { type: '=', onChange: '&' }
  bindToController: true
  templateUrl: 'filter-bar/filter-bar.html'
  controller: 'filterCtrl as filters'

.controller 'filterCtrl', ($scope, genres, sorters, types) ->
  vm = this

  vm.menuOpen = null

  vm.list = 
    sorters: sorters[vm.type]
    types: types[vm.type]
    genres: genres[vm.type]

  $scope.$watchCollection 'filters.params', (newParams, oldParams) ->
    if not angular.equals(newParams, oldParams) and angular.isDefined oldParams
      vm.onChange params: newParams

  return

.directive 'ptFilterBarItem', ->
  restrict: 'E'
  bindToController: true
  scope: { items: '=?', selected: '=', label: '@', menuOpen: '=' }
  templateUrl: "filter-bar/filter-bar-item.html"
  controller: 'filterBarItemController as filter'

.controller 'filterBarItemController', ->
  vm = this

  if not vm.selected
    vm.selected = vm.items[0]

  return
  
