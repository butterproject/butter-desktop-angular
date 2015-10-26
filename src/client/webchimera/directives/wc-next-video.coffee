'use strict'

angular.module 'app.webchimera'

.directive 'wcNextVideo', ($timeout) ->
  restrict: 'E'
  require: '^chimerangular'
  templateUrl: 'webchimera/views/directives/wc-next-video.html'
  scope:
    wcNext: '='
    wcTime: '=?'
  link: (scope, elem, attr, chimera) ->
    max = scope.wcTime or 5000

    current = 0
    currentVideo = 0

    timer = null
    isCompleted = false

    nextVideos = []

    onLoadData = (episodes) ->
      nextVideos = episodes

    count = ->
      current += 10
      
      if current >= max
        $timeout.cancel timer

        chimera.autoPlay = true
        chimera.isCompleted = false

        current = 0
        isCompleted = false

        currentVideo++
        
        if currentVideo is nextVideos.length
          currentVideo = 0
      else
        timer = $timeout(count.bind(this), 10)

    cancelTimer = ->
      $timeout.cancel timer
      
      current = 0
      isCompleted = false

    onComplete = (newVal) ->
      isCompleted = newVal

      if newVal
        timer = $timeout(count.bind(this), 10)

    scope.$watch ->
      chimera.isCompleted
    , onComplete

    scope.$watch 'wcNext', onLoadData