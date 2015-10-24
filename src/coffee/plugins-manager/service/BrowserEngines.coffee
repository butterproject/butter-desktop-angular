'use strict'

angular.module 'app.plugins'

.factory 'BrowserEngines', ($log, $q, GenericEngine) ->
  engines = {}

  registerGenericEngine: (name, factory) ->
    @registerEngine name, new GenericEngine factory 

  registerEngine: (name, implementation) ->
    if name of engines
      $log.info 'Updating torrent search engine', name 
    else
      $log.info 'Registering torrent search engine:', name
    
    engines[name] = implementation

    return
  
  getSearchEngines: ->
    engines

  getSearchEngine: (engine) ->
    engines[engine]

  removeSearchEngine: (name) ->
    if name of engines
      delete engines[name]

  findEpisode: (serie, episode) ->
    $log.info serie, episode 

  search: (query, TVDB_ID, options) ->
    $log.info query, TVDB_ID, options 
