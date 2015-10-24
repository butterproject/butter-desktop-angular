'use strict'

module.exports = (io, torrentStore) ->
  io.sockets.on 'connection', (socket) ->
    socket.on 'pause', (infoHash) ->
      torrent = torrentStore.get(infoHash)
      
      if torrent and torrent.swarm
        torrent.swarm.pause()

    socket.on 'resume', (infoHash) ->
      torrent = torrentStore.get(infoHash)
      
      if torrent and torrent.swarm
        torrent.swarm.resume()

    socket.on 'select', (infoHash, file) ->
      torrent = torrentStore.get(infoHash)
      
      if torrent and torrent.files
        file = torrent.files[file]
        file.select()

    socket.on 'deselect', (infoHash, file) ->
      torrent = torrentStore.get(infoHash)
      
      if torrent and torrent.files
        file = torrent.files[file]
        file.deselect()