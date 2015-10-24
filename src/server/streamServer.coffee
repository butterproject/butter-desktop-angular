'use strict'

bodyParser    = require 'body-parser'
express       = require 'express'
socket        = require 'socket.io'
http          = require 'http'
torrentStore  = require './torrentStore'

module.exports = (port) ->
  process.argv[2] = port 

  expressApp = express()

  expressApp.use bodyParser.urlencoded({ extended: false })
  expressApp.use bodyParser.json()

  console.log 'express listening at ' + port

  expressApp.use (req, res, next) ->
    res.header 'Access-Control-Allow-Origin', '*'
    res.header 'Access-Control-Allow-Methods', 'OPTIONS, POST, GET, PUT, DELETE'
    res.header 'Access-Control-Allow-Headers', 'Origin, X-Requested-With, Content-Type, Accept'
    
    next()

  routeHandlers = require('./routeHandlers')(torrentStore)

  findTorrent = (req, res, next) ->
    torrent = req.torrent = torrentStore.get(req.params.infoHash)

    if !torrent
      return res.send 404

    next()

  expressApp.all '/torrents/:infoHash/files/:path([^"]+)', findTorrent, routeHandlers.streamTorrent

  expressApp.delete '/torrents/:infoHash', findTorrent, routeHandlers.deleteTorrent

  expressApp.get '/torrents', routeHandlers.getAllTorrents
  expressApp.get '/torrents/:infoHash', findTorrent, routeHandlers.getTorrent
  expressApp.get '/torrents/:infoHash/stats', findTorrent, routeHandlers.torrentStats
  expressApp.get '/torrents/:infoHash/files', findTorrent, routeHandlers.getM3UPlaylist

  expressApp.post '/torrents', routeHandlers.addTorrent
  expressApp.post '/torrents/:infoHash/start/:index?', findTorrent, routeHandlers.startTorrent
  expressApp.post '/torrents/:infoHash/stop/:index?', findTorrent, routeHandlers.stopTorrent
  expressApp.post '/torrents/:infoHash/pause', findTorrent, routeHandlers.pauseSwarm
  expressApp.post '/torrents/:infoHash/resume', findTorrent, routeHandlers.resumeSwarm
  #expressApp.post '/upload', multipart(), routeHandlers.uploadTorrent

  server = http.createServer expressApp

  io = socket.listen server

  require('./socketServer')(io, torrentStore)
  require('./socketActions')(io, torrentStore)

  server.listen port

  #process.send 'started'
  return