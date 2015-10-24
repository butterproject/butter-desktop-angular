'use strict'

angular.module 'app.providers', []

.factory 'timeoutCache', ($cacheFactory, $timeout) ->
  timeouts = {}
  
  cache = $cacheFactory 'timeoutCache'

  ticktock = (id, lifespan) ->
    if timeouts[id]
      $timeout.cancel timeouts[id]

    timeouts[id] = $timeout ->
      cache.remove id
      delete timeouts[id]
    , lifespan, false
  
  (lifespan) ->
    get: (id) ->
      ticktock id, lifespan
      cache.get id

    put: (id, value) ->
      ticktock id, lifespan
      cache.put id, value

    remove: (id) ->
      if timeouts[id]
        $timeout.cancel timeouts[id]
        delete timeouts[id]
      cache.remove id

    removeAll: ->
      angular.forEach timeouts, (timeout, id) ->
        $timeout.cancel timeout
        delete timeouts[id]
      cache.removeAll()

    destroy: ->
      @removeAll()
      cache.destroy()
