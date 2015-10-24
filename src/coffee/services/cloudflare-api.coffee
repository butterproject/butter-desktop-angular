'use strict'

angular.module 'app.services'

.factory 'cloudFlareApi', ($q, request, timeoutCache)->

  cache = timeoutCache 10 * 60 * 1000

  (url, params) ->
    defer = $q.defer()

    cachedData = cache.get url + JSON.stringify params

    if cachedData
      defer.resolve cachedData
    else
      request
        uri: url
        qs: params
        headers:
          'Host': 'xor.image.yt'
          'User-Agent': 'Mozilla/5.0 (Linux) AppleWebkit/534.30 (KHTML, like Gecko) PT/3.8.0'
        strictSSL: false
        json: true
        timeout: 10000
      , (err, res, data) ->
        if err or res.statusCode >= 400
          defer.reject err
        else 
          cache.put url + JSON.stringify params, data
          defer.resolve data

    defer.promise
