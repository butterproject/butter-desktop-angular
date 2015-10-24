'use strict'

torrentProgress = require './torrentProgress'
torrentStats    = require './torrentStats'
torrentUtils    = require './torrentUtils'

throttle = require './throttle'

module.exports = (io, torrentStore) ->
  torrents = {}
  subscriptions = []

  listen = (infoHash, torrent) ->
    emit = (event, data = null) ->
      io.sockets.emit infoHash, event, data

    notifyProgress = ->
      emit 'download', torrentProgress torrent

    notifySelection = ->
      pieceLength = torrent.torrent.pieceLength

      emit 'selection', torrent.files.map (f) ->
        start = f.offset / pieceLength | 0
        end = (f.offset + f.length - 1) / pieceLength | 0
        
        torrent.selection.some (s) ->
          s.from <= start and s.to >= end
    
    emit 'verifying', torrentStats(torrent)

    if torrent.ready
      emit 'ready', torrentUtils.serialize torrent
      throttle notifyProgress, 1000

    torrent.once 'ready', ->
      emit 'ready', torrentUtils.serialize torrent

    torrent.on 'uninterested', ->
      emit 'uninterested'
      throttle notifySelection, 2000

    torrent.on 'interested', ->
      emit 'interested'
      throttle notifySelection, 2000

    interval = setInterval ->
      emit 'stats', torrentStats(torrent)
      throttle notifySelection, 2000
    , 1000

    torrent.on 'verify', throttle notifyProgress, 1000

    torrent.once 'destroyed', ->
      clearInterval interval
      emit 'destroyed'

  torrentStore.on 'torrent', (infoHash, torrent) ->
    if infoHash not in subscriptions
      torrents[infoHash] = torrent
    else listen infoHash, torrent

  io.sockets.on 'connection', (socket) ->
    socket.on 'subscribe', (hash) ->
      torrent = torrents[hash]

      if torrent
        if torrent.ready
          listen hash, torrent
        else torrent.once 'verifying', ->
          listen hash, torrent
      else subscriptions.push hash

