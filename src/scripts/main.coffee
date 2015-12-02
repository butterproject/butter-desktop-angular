app      = require 'app'
main     = require './application'
manifest = require '../package.json'
path     = require 'path'
getPort  = require 'get-port'

process.on 'uncaughtException', (error) ->
  console.error error.stack

do ->
  app.on 'ready', ->
    getPort().then (port) ->
      global.application = new main manifest, port
      global.streamer = require(path.resolve(__dirname, '..', 'server/streamServer.js'))(port)