'use strict'

streamOptions = require './streamOptions'

torrentStream = require 'torrent-stream'

module.exports = (torrent) ->
  engine = torrentStream torrent, streamOptions

  engine.once 'verifying', ->
    console.log 'verifying ' + engine.infoHash

    engine.files.forEach (file, i) ->
      console.log i + ' ' + file.name

  engine.once 'verify', ->
    engine.verified = true

  engine.once 'ready', ->
    engine.ready = true
    
    # select the largest file
    file = engine.files.reduce (a, b) ->
      if a.length > b.length then a else b

    file.select()
    
  #engine.on 'uninterested', ->
  #  console.log 'uninterested ' + engine.infoHash
    
  #engine.on 'interested', ->
  #  console.log 'interested ' + engine.infoHash
    
  #engine.on 'idle', ->
  #  console.log 'idle ' + engine.infoHash
    
  #engine.on 'error', (e) ->
  #  console.log 'error ' + engine.infoHash + ': ' + e
    
  engine.once 'destroyed', ->
    console.log 'destroyed ' + engine.infoHash
    engine.removeAllListeners()
    
  engine.listen streamOptions.port, ->
    console.log 'listening ' + engine.infoHash + ' on port ' + engine.port
    
  engine
