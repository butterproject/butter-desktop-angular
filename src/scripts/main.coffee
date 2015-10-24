app      = require 'app'
main     = require './application'
manifest = require '../../package.json'
path = require 'path'

child_process = require 'child_process'
getPort       = require 'get-port'

process.on 'uncaughtException', (error) -> 
  console.error error.stack

do ->
  app.on 'ready', ->
    getPort (err, port) ->
      global.application = new main manifest, port

      global.streamer = require(path.resolve(__dirname, '..', 'server/streamServer.js'))(port)

      #global.streamer = child_process.fork path.resolve(__dirname, '..', 'server/streamServer.js'), [port]
      #global.streamer.on 'message', (msg) ->
      #  if msg is 'started'
      #    console.log msg
      #  return

      return
    return
  return
  
