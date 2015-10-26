'use strict'

angular.module 'app.plugins'

.factory 'Strike', (promiseRequest) ->
  base: 'https://getstrike.net/api/v2/torrents/'

  endpoints:
    search: 'search/?phrase={{ query }}'

  parsers:
    list: (data) ->
      output = []
      torrents = data.torrents
      
      i = 0
      
      while i < torrents.length
        out = 
          magneturl: torrents[i].magnet_uri
          releasename: torrents[i].torrent_title
          size: Math.round((torrents[i].size / 1024 / 1024 + 0.00001) * 100) / 100 + ' MB'
          seeders: torrents[i].seeds
          leechers: torrents[i].leeches
          detailUrl: torrents[i].page
        
        magnetHash = out.magneturl.match /([0-9ABCDEFabcdef]{40})/
        
        if magnetHash and magnetHash.length
          out.torrent = 'http://torcache.gs/torrent/' + magnetHash[0].toUpperCase() + '.torrent?title=' + encodeURIComponent(out.releasename.trim())
          output.push out
        i++

      output

  search: (query) ->
    promiseRequest.search 'Strike', 'list', query.trim()

.run (BrowserEngines, Strike) ->
  BrowserEngines.registerEngine 'Strike', Strike

