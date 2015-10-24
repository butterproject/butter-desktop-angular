'use strict'

angular.module 'app.webchimera'

.directive 'wcTracks', ->
  restrict: 'A'
  require: '^chimerangular'
  link: 
    pre: (scope, elem, attr, chimera) ->
      tracks = undefined
      trackText = undefined
      i = undefined
      l = undefined

      scope.changeSource = ->
        # Remove previous tracks
        oldTracks = chimera.wcjsElement.children()
        i = 0
        l = oldTracks.length
        
        while i < l
          if oldTracks[i].remove
            oldTracks[i].remove()
          i++

        # Add new tracks
        if tracks
          i = 0
          l = tracks.length
          
          while i < l
            trackText = ''
            trackText += '<track '
            
            # Add track properties
            for prop of tracks[i]
              trackText += prop + '="' + tracks[i][prop] + '" '
            
            trackText += '></track>'
            chimera.wcjsElement.append trackText
            i++

      scope.setTracks = (value) ->
        # Add tracks to the chimera to have it available for other plugins (like controls)
        tracks = value
        chimera.tracks = value

        scope.changeSource()

      if chimera.isConfig
        scope.$watch ->
          chimera.config
        , ->
          if chimera.config
            scope.setTracks chimera.config.tracks
      else
        scope.$watch attr.wcTracks, (newValue, oldValue) ->
          if !tracks or newValue != oldValue
            scope.setTracks newValue
