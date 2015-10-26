'use strict'

angular.module 'app.webchimera'

.service 'wcNextVideoService', ($http, $q, $sce) ->
  deferred = $q.defer()

  @loadData = (url) ->
    $http.get(url).then @onLoadData.bind(this), @onLoadError.bind(this)
    deferred.promise

  @onLoadData = (response) ->
    result = []
    i = 0
    l = response.data.length
    
    while i < l
      mediaSources = []
      mi = 0
      ml = response.data[i].length
    
      while mi < ml
        mediaFile = 
          src: $sce.trustAsResourceUrl response.data[i][mi].src
          type: response.data[i][mi].type
        mediaSources.push mediaFile
        mi++
    
      result.push mediaSources
      i++
    
    deferred.resolve result

  @onLoadError = (error) ->
    deferred.reject error

  @