'use strict'

angular.module 'app.plugins'

.constant 'ThePirateBay', 
  base: 'https://thepiratebay.cr'

  endpoints:                                                                          
    search: '/search/{{ query }}/0/7/0'                                                        
    details: '/torrent/{{ id }}'                                                             
  
  selectors:                                                                         
    resultContainer: 'searchResult tbody tr'                                    
    releasename: ['td:nth-child(2) > div', 'innerText', (text) -> text.trim()]                      
    magneturl: ['td:nth-child(2) > a', 'href']
    size: ['td:nth-child(2) .detDesc', 'innerText', (text) -> text.split(' ')[1].split(' ')[1]]
    seeders: ['td:nth-child(3)', 'innerHTML']
    leechers: ['td:nth-child(4)', 'innerHTML']
    detailUrl: ['a.detLink', 'href']

.run (BrowserEngines, ThePirateBay) ->
  BrowserEngines.registerGenericEngine 'ThePirateBay', ThePirateBay