'use strict'

angular.module 'app.webchimera'

.service 'wcConfigLoader', ($http, $q, $sce) ->

  @loadConfig = (url) ->
    deferred = $q.defer()
    
    $http.get url
      method: 'GET'
      url: url
    .success (response) ->
      result = response.data
      i = 0
      l = result.sources.length
      
      while i < l
        result.sources[i].src = $sce.trustAsResourceUrl result.sources[i].src
        i++

      deferred.resolve result
    .error -> deferred.reject()

    deferred.promise

  return
