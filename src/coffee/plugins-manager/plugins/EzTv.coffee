'use strict'

angular.module 'app.plugins'

.factory 'EzTv', (promiseRequest) ->
  base: 'http://eztvapi.re/'

  endpoints:
    search: 'shows/{{ query }}'

  parsers:
    list: (data) ->
      shows = []

      for show, idx in data 
        if not showIds[show._id]?
          show.type = 'show'
          showIds[show._id] = idx 
          shows.push show 

      shows

  search: (filters) ->

    params = 
      sort: 'trending'
      limit: '50'
      keywords: filters?.query or null
      genre: filters?.genre or null
      order: filters?.order or null

    if filters?.sort_by isnt 'trending' and filters?.sort_by
      params.sort = filters?.sort_by 

    promiseRequest.search 'EzTv', 'list', (filters?.page or 1), params

.run (BrowserEngines, EzTv) ->
  BrowserEngines.registerEngine 'EzTv', EzTv

