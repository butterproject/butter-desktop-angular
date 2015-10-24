'use strict'

EventEmitter = require('events').EventEmitter
nodeFs       = require 'fs'
mkdirp       = require 'mkdirp'
parseTorrent = require 'parse-torrent'
path         = require 'path'
$q           = require 'q'
util         = require 'util'

streamerEngine = require './streamerEngine'

class torrentStore extends EventEmitter
  constructor: ->
    super()

    @homePath    = process.env[(if process.platform == 'win32' then 'USERPROFILE' else 'HOME')]

    @storagePath = path.join @homePath, '.config', 'streamer'
    @storageFile = path.join @storagePath, 'torrents.json'

    @torrents = {}

    #mkdirp @storagePath, (err) =>
    #  if err then throw err
    #  
    #  if nodeFs.existsSync @storageFile
    #    nodeFs.readFile @storageFile, (err, data) =>
    #      if err then throw err
    #
    #      torrents = JSON.parse data
    #      console.log 'resuming from previous state'
    #      
    #      torrents.forEach (infoHash) =>
    #        @load infoHash

  add: (link) ->
    defer = $q.defer()

    torrent = parseTorrent link

    if torrent
      infoHash = torrent.infoHash
      
      if @torrents[infoHash]
        defer.resolve torrent
      else
        console.log 'adding ' + infoHash
        
        try
          e = streamerEngine torrent
          @torrents[infoHash] = e
          @emit 'torrent', infoHash, e
          @save()
          defer.resolve e
        catch e then defer.reject e
    else defer.reject err
      
    defer.promise

  save: ->
    mkdirp @storagePath, (err) =>
      if err then throw err

      state = Object.keys(@torrents).map (infoHash) ->
        infoHash
      
      nodeFs.writeFile @storageFile, JSON.stringify(state), (err) ->
        if err then throw err

  load: (infoHash) ->
    console.log 'loading ' + infoHash
    e = streamerEngine infoHash: infoHash
    @emit 'torrent', infoHash, e
    @torrents[infoHash] = e

  shutdown: (signal) ->
    keys = Object.keys @torrents
    
    if keys.length
      key = keys[0]
      torrent = @torrents[key]
    
      torrent.destroy =>
        delete @torrents[key]

      process.nextTick @shutdown

  get: (infoHash) ->
    @torrents[infoHash]

  remove: (infoHash) ->
    torrent = @torrents[infoHash]
    torrent.destroy()

    torrent.remove =>
      torrent.emit 'destroyed'
      delete @torrents[infoHash]
      @save()

  hashList: -> @torrents

  list: ->
    Object.keys(@torrents).map (infoHash) =>
      @torrents[infoHash]

module.exports = new torrentStore()
