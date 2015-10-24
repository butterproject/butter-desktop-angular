'use strict'

angular.module 'app.plugins'

.factory 'GenericEngine', ($q, $http, $interpolate, $injector) ->
  getUrl = (config, type, param) ->
    $interpolate config.endpoints[type], param

  class GenericEngine
    constructor: (@config) ->
      @activeRequest = null

      executeSearch: (query, timeout) ->
        if !timeout
          timeout = $q.defer()
        
        $http
          method: 'GET'
          url: getUrl @config, 'search', query: query
          cache: false
          timeout: timeout.promise

      search: (query, noCancel) ->
        query = query.replace /\'/g, ''
        d = $q.defer()
        
        if noCancel != true and activeRequest
          activeRequest.resolve()
        
        activeRequest = $q.defer()
        
        @executeSearch query, activeRequest
          .then (response) ->
            d.resolve parseSearch @config, response
          .catch (err) =>
            if err.status == 404
              d.resolve []
            else d.reject err

        d.promise

      torrentDetails: (id) ->
        $http
          method: 'GET'
          url: getUrl @config, 'details', id: id
          cache: true
        .success (response) ->
          result: @parseDetails response

      return
