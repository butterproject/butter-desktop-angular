'use strict'

angular.module 'app.plugins'

.constant 'KickAssTorrents', 
  base: 'https://kat.cr'
  
  endpoints:
    search: '/usearch/{{ query }}/?field=seeders&sorder=desc'
    details: '/torrent/{{ id }}'
  
  selectors:
    resultContainer: 'table.data tr[id^=torrent]'
    releasename: ['div.torrentname a.cellMainLink', 'innerText']
    magneturl: ['a[title="Torrent magnet link"]', 'href']
    size: ['td:nth-child(2)', 'innerText']
    seeders: ['td:nth-child(5)', 'innerHTML'] 
    leechers: ['td:nth-child(6)', 'innerHTML'] 
    detailUrl: ['div.torrentname a.cellMainLink', 'href']

.run (BrowserEngines, KickAssTorrents) ->
  BrowserEngines.registerGenericEngine 'KickAssTorrents', KickAssTorrents