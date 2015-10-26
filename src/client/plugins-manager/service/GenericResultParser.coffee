'use strict'

angular.module 'app.plugins'

.factory 'GenericResultParser', ($q) ->
  getPropertyForSelector = (parentNode, propertyConfig) ->
    node = parentNode.querySelector propertyConfig[0]
    
    if !node
      return $q.when null
    
    if node.getAttribute(propertyConfig[1]) isnt null
      propertyValue = node.getAttribute propertyConfig[1]
    else 
      propertyValue = node[propertyConfig[1]]
    
    if propertyConfig.length is 3 and propertyConfig[2] isnt null and angular.isFunction propertyConfig[2]
      $q.when propertyConfig[2](propertyValue) 
    else 
      $q.when propertyValue

  (config, result) ->
    defer = $q.defer()

    parser = new DOMParser

    doc = parser.parseFromString result.data, 'text/html'
    selectors = config.selectors
    results = doc.querySelectorAll selectors.resultContainer
    
    outputPromise = []

    i = 0
    
    while i < results.length
      outputPromise.push(
        dfd = $q.defer()

        getPropertyForSelector(results[i], selectors.releasename).then (releasename) ->
      
          if releasename == null
            i++
          else
        
            out =
              size: getPropertyForSelector results[i], selectors.size
              seeders: getPropertyForSelector results[i], selectors.seeders
              leechers: getPropertyForSelector results[i], selectors.leechers
              detailUrl: getPropertyForSelector results[i], selectors.detailUrl

            if config.noMagnet == true
              out.torrentUrl = getPropertyForSelector(results[i], selectors.torrentUrl)
            else
              out.magneturl = getPropertyForSelector(results[i], selectors.magneturl)
              magnetHash = out.magneturl.match /([0-9ABCDEFabcdef]{40})/
          
              if magnetHash and magnetHash.length
                out.torrent = 'http://torcache.gs/torrent/' + magnetHash[0].toUpperCase() + '.torrent?title=' + encodeURIComponent(out.releasename.trim())
            
            $q.all(out).then (output) ->
              dfd.resolve out 

          dfd.promise 
        )
      i++
    
    $q.all(outputPromise).then (output) ->
      defer.resolve output

    defer.promise 
