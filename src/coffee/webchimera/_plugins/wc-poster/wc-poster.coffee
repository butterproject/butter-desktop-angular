'use strict'

angular.module 'app.webchimera.plugins.poster', []

.directive 'wcPoster', ->
  restrict: 'E'
  require: '^chimerangular'
  scope: { poster: '=?' }
  templateUrl: 'webchimera/views/directives/wc-poster.html'
  link: (scope, elem, attr, chimera) ->
    scope.chimera = chimera
