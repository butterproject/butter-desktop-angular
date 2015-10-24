'use strict'

angular.module 'app.streamer'

.provider 'serverPort', ->
  port = null

  setPort: (newport) ->
    port = newport 

  $get: -> port 

.config (serverPortProvider) ->
  ipc = require 'ipc'

  port = ipc.sendSync 'get-port', null

  serverPortProvider.setPort port  

.run (socketServer, torrentProvider) ->
  socketServer.start().then ->
    torrentProvider.getAllTorrents()

.factory 'socketServer', (socketFactory, $q, serverPort) ->
  connection: null

  start: ->
    if not @connection 
      @connection = socketFactory ioSocket: io "http://127.0.0.1:#{serverPort}/"
    $q.when()