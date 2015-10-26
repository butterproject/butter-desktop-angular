'use strict'

angular.module 'app.plugins'

.factory 'ShowRSS', ($q, $http) ->
  base: 'https://showrss.info/'
  
  endpoints: 
    list: '?cs=browse'
    serie: '?cs=browse&show={{ query }}'

  parsers: 
    list: (result) ->
      parser = new DOMParser

      doc = parser.parseFromString result.data, 'text/html'
      results = doc.querySelectorAll 'select option'
      
      output = {}
      
      Array::map.call results, (node) ->
        if node.value == ''
          return

        output[node.innerText.trim()] = node.value
        return
      
      output
    
    serie: (result) ->
      parser = new DOMParser

      doc = parser.parseFromString(result.data, 'text/html')
      results = doc.querySelectorAll('#show_timeline div.showentry > a')
      
      output = []
      
      Array::map.call results, (node) ->
        out = 
          magneturl: node.href
          releasename: node.innerText
          size: 'n/a'
          seeders: 'n/a'
          leechers: 'n/a'
          detailUrl: doc.querySelector('a[href^=\'/?cs=browse&\']').href
        
        magnetHash = out.magneturl.match(/([0-9ABCDEFabcdef]{40})/)
        
        if magnetHash and magnetHash.length
          out.torrent = 'http://torcache.gs/torrent/' + magnetHash[0].toUpperCase() + '.torrent?title=' + encodeURIComponent(out.releasename.trim())
          output.push out

        return

      output

  search: (query) ->
    if !query.toUpperCase().match(/S([0-9]{1,2})E([0-9]{1,3})/)
      $q.reject 'Sorry, ShowRSS only works for queries in format : \'Seriename SXXEXX\''

    promiseRequest.search('ShowRSS', 'list').then (results) ->
      found = Object.keys(results).filter (value) ->
        query.indexOf(value) == 0

      if found.length
        serie = found[0]
        
        promiseRequest.search('ShowRSS', 'serie', results[found[0]]).then (results) ->
          seasonepisode = query.replace(serie, '').trim().toUpperCase()
          parts = seasonepisode.match(/S([0-9]{1,2})E([0-9]{1,3})/)
          
          if seasonepisode.length == 0
            return results
          
          seasonepisode = seasonepisode.replace('S' + parts[1], parseInt(parts[1], 10)).replace('E' + parts[2], 'x' + parts[2])
          searchparts = seasonepisode.split(' ')
          
          results.filter (el) ->
            if searchparts.length > 1 and el.releasename.indexOf(searchparts[1]) == -1
              return false
            
            el.releasename.indexOf(searchparts[0]) > -1
      
      else []

.run (BrowserEngines, ShowRSS) ->
  BrowserEngines.registerEngine 'ShowRSS', ShowRSS
