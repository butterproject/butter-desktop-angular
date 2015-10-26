'use strict'

angular.module 'app.services'

.factory 'torrentHealth', ($q, torrenthealth) ->
  (torrentLink) ->
    defer = $q.defer()

    torrentHealthRestarted = 0

    getTorrent = ->
      torrenthealth(torrentLink, timeout: 1000).then (torrent) ->
        if torrent.seeds is 0 and torrentHealthRestarted < 5
          torrentHealthRestarted++
          getTorrent()
        else if torrent.seeds isnt 0 
          defer.resolve torrent
        else defer.reject()

    getTorrent()

    defer.promise
