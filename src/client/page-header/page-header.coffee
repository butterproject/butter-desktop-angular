'use strict'

angular.module 'app.page-header', []

.directive 'ptPageHeader', ->
  restrict: 'E'
  templateUrl: 'page-header/page-header.html'
  scope: { title: '=', goBack: '&', torrentId: '=?' }
  bindToController: true
  controller: 'pageHeaderController as header'

.controller 'pageHeaderController', ->
  vm = this

  vm.torrentId = null
