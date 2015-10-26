'use strict'

angular.module 'app.settings'

.factory 'AdvSettings', (Settings, tls, url, ipc) ->
  get: (variable) ->
    if typeof Settings[variable] != 'undefined'
      return Settings[variable]
    false
  
  set: (variable, newValue) ->
    Settings[variable] = newValue

  setup: ->
    @performUpgrade()
    @getHardwareInfo()
  
  getHardwareInfo: ->
    if /64/.test(process.arch)
      @set 'arch', 'x64'
    else @set 'arch', 'x86'
    
    switch process.platform
      when 'darwin' then @set 'os', 'mac'
      when 'win32' then @set 'os', 'windows'
      when 'linux' then @set 'os', 'linux'
      else @set 'os', 'unknown'

    $q.when
  
  getNextApiEndpoint: (endpoint) ->
    if endpoint.index < endpoint.proxies.length - 1
      endpoint.index++
    else endpoint.index = 0
    
    endpoint.ssl = undefined
    
    angular.extend endpoint, endpoint.proxies[endpoint.index]
    
    endpoint
  
  checkApiEndpoints: (endpoints) ->
    $q.all endpoints.map (endpoint) =>
      @checkApiEndpoint endpoint

  checkApiEndpoint: (endpoint, defer) ->

    tryNextEndpoint = =>
      if endpoint.index < endpoint.proxies.length - 1
        endpoint.index++
        @checkApiEndpoint endpoint, defer
      else
        endpoint.index = 0
        endpoint.ssl = undefined
        angular.extend endpoint, endpoint.proxies[endpoint.index]
        defer.resolve()
      return

    defer ?= $q.defer()

    endpoint.ssl = undefined
    angular.extend endpoint, endpoint.proxies[endpoint.index]
    url = uri.parse(endpoint.url)
    
    win.debug 'Checking %s endpoint', url.hostname
    
    if endpoint.ssl == false
      $http.get({ hostname: url.hostname }).success (data) ->
        # Doesn't match the expected response
        if !_.isRegExp(endpoint.fingerprint) or !endpoint.fingerprint.test(data.toString('utf8'))
          win.warn '[%s] Endpoint fingerprint %s does not match %s', url.hostname, endpoint.fingerprint, data.toString('utf8')
          tryNextEndpoint()
        else defer.resolve()
      .error (e) ->
        win.warn '[%s] Endpoint failed [%s]', url.hostname, e.message
        tryNextEndpoint()
    else
      tls.connect 443, url.hostname, {
        servername: url.hostname
        rejectUnauthorized: false
      }, ->
        @setTimeout 0
        @removeAllListeners 'error'
        if !@authorized or @authorizationError or @getPeerCertificate().fingerprint != endpoint.fingerprint
          # "These are not the certificates you're looking for..."
          # Seems like they even got a certificate signed for us :O
          win.warn '[%s] Endpoint fingerprint %s does not match %s', url.hostname, endpoint.fingerprint, @getPeerCertificate().fingerprint
          tryNextEndpoint()
        else
          defer.resolve()
        @end()
        return
      .error (e) ->
        win.warn '[%s] Endpoint failed [%s]', url.hostname, e.message
        @setTimeout 0
        tryNextEndpoint()

    defer.promise

  performUpgrade: ->
    # This gives the official version (the package.json one)
    ipc.send 'version', (version) => 
      currentVersion = version
    
      if currentVersion != @get('version')
        # Nuke the DB if there's a newer version
        # Todo: Make this nicer so we don't lose all the cached data
        cacheDb = openDatabase('cachedb', '', 'Cache database', 50 * 1024 * 1024)
        
        cacheDb.transaction (tx) ->
          tx.executeSql 'DELETE FROM subtitle'
          tx.executeSql 'DELETE FROM metadata'

        # Add an upgrade flag
        window.__isUpgradeInstall = true
    
      @set 'version', currentVersion

    ipc.send 'releaseName', (name) => 
      @set 'releaseName', name

    return
