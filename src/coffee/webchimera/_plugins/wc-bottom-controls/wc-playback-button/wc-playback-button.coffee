'use strict'

angular.module 'app.webchimera.plugins.controls'

.directive 'wcPlaybackButton', (WC_UTILS) ->
  restrict: 'E'
  require: '^chimerangular'
  templateUrl: 'webchimera/views/directives/wc-playback-button.html'
  link: (scope, elem, attr, chimera) ->
    scope.playback = '1.0'

    scope.onClickPlayback = ->
      playbackOptions = ['.5', '1.0', '1.5', '2.0']

      nextPlaybackRate = playbackOptions.indexOf(scope.playback) + 1
      
      if nextPlaybackRate >= playbackOptions.length
        scope.playback = playbackOptions[0]
      else
        scope.playback = playbackOptions[nextPlaybackRate]
      
      chimera.setPlayback scope.playback

    scope.$watch ->
      chimera.playback
