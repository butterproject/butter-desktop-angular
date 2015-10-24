'use strict'

module.exports = (torrent) ->
  swarm = torrent.swarm
  
  notChoked = (prev, wire) ->
    prev + !wire.peerChoking

  peers:
    total: swarm.wires.length
    unchocked: swarm.wires.reduce notChoked, 0
  
  traffic:
    down: swarm.downloaded
    up: swarm.uploaded
  
  speed:
    down: swarm.downloadSpeed()
    up: swarm.uploadSpeed()
  
  queue: swarm.queued
  paused: swarm.paused
  