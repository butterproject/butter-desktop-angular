'use strict'

angular.module 'app.webchimera.plugins.controls'

.directive 'wcVolumeBar', (WC_UTILS) ->
  restrict: 'E'
  require: '^chimerangular'
  templateUrl: 'webchimera/views/directives/wc-volume-bar.html'
  link: (scope, elem, attr, chimera) ->
    isChangingVolume = false
    
    volumeBackElem = angular.element(elem[0].getElementsByClassName('volumeBackground'))
    volumeValueElem = angular.element(elem[0].getElementsByClassName('volumeValue'))

    scope.onClickVolume = (event) ->
      event = WC_UTILS.fixEventOffset(event)
      volumeHeight = parseInt(volumeBackElem.prop('offsetHeight'))
      
      value = event.offsetY * 100 / volumeHeight
      volValue = 1 - value / 100
      
      chimera.setVolume volValue

    scope.onMouseDownVolume = ->
      isChangingVolume = true

    scope.onMouseUpVolume = ->
      isChangingVolume = false

    scope.onMouseLeaveVolume = ->
      isChangingVolume = false

    scope.onMouseMoveVolume = (event) ->
      if isChangingVolume
        event = WC_UTILS.fixEventOffset(event)
        volumeHeight = parseInt(volumeBackElem.prop('offsetHeight'))
        
        value = event.offsetY * 100 / volumeHeight
        volValue = 1 - value  / 100
        
        chimera.setVolume volValue

    scope.updateVolumeView = (value) ->
      value = value * 100
      
      volumeValueElem.css 'height', value + '%'
      volumeValueElem.css 'top', 100 - value + '%'

    scope.onChangeVisibility = (value) ->
      elem.css 'visibility', value

    elem.css 'visibility', scope.volumeVisibility
    scope.$watch 'volumeVisibility', scope.onChangeVisibility
    
    #Update the volume bar on initialization, then watch for changes
    scope.updateVolumeView chimera.volume
    
    scope.$watch ->
      chimera.volume
    , (newVal, oldVal) ->
      if newVal != oldVal
        scope.updateVolumeView newVal
