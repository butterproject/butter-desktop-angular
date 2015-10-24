'use strict'

angular.module 'app.plugins'

.constant 'Nyaa', 
  base: 'http://www.nyaa.se'

  endpoints: 
    search: '/?page=search&sort=2&term={{ query }}'

  noMagnet: true
  
  selectors:
    resultContainer: 'tr.tlistrow'
    releasename: ['td.tlistname a', 'innerText'] 
    torrentUrl: ['td.tlistdownload a', 'href'] 
    size: ['td.tlistsize', 'innerText'] 
    seeders: ['td.tlistsn', 'innerHTML'] 
    leechers: ['td.tlistln', 'innerHTML'] 
    detailUrl: ['td.tlistname a', 'href']

.run (BrowserEngines, Nyaa) ->
  BrowserEngines.registerGenericEngine 'Nyaa', Nyaa