'use strict'

angular.module 'app.providers'

.factory 'VODO', ($q, $http, AdvSettings, Settings, timeoutCache) ->
  movies = []
  movieIds = {}

  any = (list, fn) ->
    idx = 0
    while idx < list.length
      if fn(list[idx])
        return true
      idx += 1
    false

  formatTorrents = (data) ->
    torrentsObject = {}
    torrentsObject[data.Quality] =
          url: data.url
          size: data.Size
          filesize: data.SizeByte
          seeds: data.TorrentPeers
          peers: data.TorrentSeeds

    torrentsObject

  format = (data) ->
    for idx, movie of data.downloads
      torrents = formatTorrents movie

      if torrents and not movieIds[movie.ImdbCode]?
        movieIds[movie.ImdbCode] = idx

        movies.push
          _id: movie.ImdbCode
          title: movie.MovieTitleClean
          year: movie.MovieYear
          genres: movie.Genre.split(',')
          rating:
            percentage: movie.Rating / 10
          runtime: movie.Runtime
          images:
            poster: movie.CoverImage
            banner: movie.CoverImage
            fanart: movie.CoverImage
          synopsis: movie.Synopsis
          trailer: 'https://www.youtube.com/watch?v=' + movie.yt_trailer_code or false
          certification: movie.mpa_rating
          torrents: torrents
          actors: movie.actors,
          directors: movie.directors
          type: 'movie'

    results: movies or null
    hasMore: data.movie_count > data.page_number * data.limit

  name: 'VODO'

  fetch: (filters = {}) ->
    defer = $q.defer()

    params =
      sort_by: 'seeds'
      limit: 50
      with_rt_ratings: true
      page: filters.page
      quality: Settings.movies_quality or 'all'
      lang: Settings.language if Settings.translateSynopsis

    if filters?.sort_by isnt 'seeds' and filters?.sort_by
      params.sort_by = switch filters.sort_by
        when 'last added' then 'date_added'
        when 'trending' then 'trending_score'
        else filters.sort_by

    if filters?.order_by isnt 1 and filters?.order_by
      params.order_by = 'desc'

    if filters?.genre isnt 'All' and filters?.genre
      params.genre = filters?.genre

    if filters?.query
      params.query_term = filters?.query

    $http
      method: 'GET'
      url: AdvSettings.get('vodoAPI').url
      params: params
      cache: timeoutCache 10 * 60 * 1000
    .success (data) ->
      if !data or data.error and data?.error != 'No movies found'
        err = if data then data.error else 'No data returned'
        $log.error 'API error:', err
        defer.reject err
      else
        defer.resolve format data

    defer.promise

  random: ->
    defer = $q.defer()

    request = cloudFlareApi 'http://cloudflare.com/api/v2/get_random_movie.json?' + Math.round((new Date).valueOf() / 1000)

    request.then ((data) ->
      if !data or data.status is 'error'
        err = if data then data.status_message else 'No data returned'
        defer.reject err
      else defer.resolve data.data
    ), ((err) ->
      defer.reject err or 'Status Code is above 400'
    )

    defer.promise

  extractIds: ->
    movies.map (item) -> item['_id']

  detail: (torrent_id) ->
        console.error torrent_id, movies
        $q.when data: movies[movieIds[torrent_id]]
