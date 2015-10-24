'use strict'

angular.module 'app.plugins'

.constant 'Torrentz', ->
  base: 'https://torrentz.eu'

  endpoints:
    search: '/search?f={{ query }}'
    details: '/{{ id }}'
  
  selectors:
    resultContainer: 'div.results dl'
    releasename: ['dt a', 'innerText'] 
    magneturl: ['dt a', 'href', (a) -> 'magnet:?xt=urn:sha1:' + a.substring(1)] 
    size: ['dd span.s', 'innerText'] 
    seeders: ['dd span.u', 'innerText'] 
    leechers: ['dd span.d', 'innerText'] 
    detailUrl: ['dt a', 'href']

.run (BrowserEngines, Torrentz) ->
  BrowserEngines.registerGenericEngine 'Torrentz', Torrentz