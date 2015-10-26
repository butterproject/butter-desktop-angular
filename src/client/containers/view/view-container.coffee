'use strict'

angular.module 'app.containers'

.directive 'ptViewContainer', ->
  restrict: 'E'
  transclude: true
  template: '<div class="main-container" ng-transclude></div>'
  controller: 'ptViewController as view'

.controller 'ptViewController', (Settings, $sce, torrentProvider, $state) ->
  vm = this

  vm.state = $state

  return
