'use strict'

angular.module 'app.plugins'

.factory 'promiseRequest', ($interpolate, $injector, $http, $q) ->
  getUrl = (engine, type, param, param2) ->
    engine.base + $interpolate(engine.endpoints[type], query: param)

  getParser = (engine, type) ->
    if type of parsers then engine.parsers[type] else (data) ->
      data.data

  search: (engine, type, param, param2, promise) ->
    torrentEngine = $injector.get engine

    url = getUrl torrentEngine, type, param, param2
    parser = getParser torrentEngine, type

    if torrentEngine.activeSearchRequest
      @cancelSearch engine

    torrentEngine.activeSearchRequest = $q.defer()

    $http
      method: 'GET'
      url: url
      timeout: if promise then promise else 30000
      cache: true
    .then (result) ->
      torrentEngine.activeSearchRequest.resolve parser(result)

    torrentEngine.activeSearchRequest.promise

  cancelSearch: (engine) ->
    { activeSearchRequest } = $injector.get engine

    if activeSearchRequest and activeSearchRequest.resolve
      activeSearchRequest.reject 'search abort'
      activeSearchRequest = false
    activeSearchRequest = $q.defer()