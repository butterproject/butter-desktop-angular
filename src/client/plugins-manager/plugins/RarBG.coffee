'use strict'

angular.module 'app.plugins'

.factory 'RarBG', (promiseRequest, $q) ->
  activeTokenRequest: false
  activeToken: null 

  base: 'https://torrentapi.org/pubapi_v2.php?app_id=PopCornTime&'
  
  endpoints:
    search: 'token=krb6yz4fu1&mode=search&search_string={{ query }}&sort=seeders&limit=25&format=json_extended'
    token: 'get_token=get_token&format=json_extended'

  parsers:
    search: (result) ->
      output = []

      if result.data.error
        return []
      
      result.data.torrent_results.map (hit) ->
        out = 
          magneturl: hit.download
          releasename: hit.title
          size: Math.round((hit.size / 1024 / 1024 + 0.00001) * 100) / 100 + ' MB'
          seeders: hit.seeders
          leechers: hit.leechers
          detailUrl: hit.info_page
        
        magnetHash = out.magneturl.match(/([0-9ABCDEFabcdef]{40})/)
        
        if magnetHash and magnetHash.length
          out.torrent = 'http://torcache.gs/torrent/' + magnetHash[0].toUpperCase() + '.torrent?title=' + encodeURIComponent(out.releasename.trim())
          output.push out

      output
    
    token: (result) ->
      result.data

  getToken: ->
    if !@activeTokenRequest and !@activeToken
      @activeTokenRequest = promiseRequest.search('RarBG', 'token').then (token) =>
        @activeToken = token.token
        token.token
      
    else if @activeToken
      $q.when @activeToken

    @activeTokenRequest

  search: (what) ->
    @getToken().then (token) ->
      promiseRequest.search('RarBG', 'search', token, what).then (results) ->
        results
  
.run (BrowserEngines, RarBG) ->
  BrowserEngines.registerEngine 'RarBG', RarBG

