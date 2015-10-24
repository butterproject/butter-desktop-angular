'use strict'

angular.module 'app.providers'

.factory 'TraktTv', ($http, $q, ipc, AdvSettings, Settings) ->
  authenticated = false

  API_ENDPOINT = 'https://api-v2launch.trakt.tv'
  CLIENT_ID = 'c7e20abc718e46fc75399dd6688afca9ac83cd4519c9cb1fba862b37b8640e89'
  CLIENT_SECRET = '476cf15ed52542c2c8dc502821280aa5f61a012db57f1ed1f479aaf88ab385cb'
  REDIRECT_URI = 'urn:ietf:wg:oauth:2.0:oob'

  self = this

  ###
  # Trakt v2
  # METHODS (http://docs.trakt.apiary.io/)
  ###
  api = (method, endpoint, params) ->
    defer = $$q.defer()

    $http 
      method: method
      url: API_ENDPOINT + endpoint
      params: params
      headers:
        'Authorization': 'Bearer ' + Settings.traktToken
        'trakt-api-version': '2'
        'trakt-api-key': CLIENT_ID
    .success (data) ->
      if not data
        defer.reject error
      else defer.resolve data
    .error (err) ->
      defer.reject err
      
    defer.promise

  get: (endpoint, getVariables) ->
    api 'GET', endpoint, getVariables

  post: (endpoint, postVariables) ->
    api 'POST', endpoint, postVariables

  calendars: 
    myShows: (startDate, days) ->
      endpoint = 'calendars/my/shows'
      
      if startDate and days
        endpoint += '/' + startDate + '/' + days
      
      @get(endpoint).then (item) ->
        calendar = []

        for i of item
          calendar.push
            show_title: item[i].show.title
            show_id: item[i].show.ids.imdb
            aired: item[i].first_aired.split('T')[0]
            episode_title: item[i].episode.title
            season: item[i].episode.season
            episode: item[i].episode.number

        calendar
  
  movies:
    summary: (id) ->
      @get 'movies/' + id, extended: 'full,images'
    people: (id) ->
      @get 'movies/' + id + '/people'
    aliases: (id) ->
      @get 'movies/' + id + '/aliases'
    translations: (id, lang) ->
      @get 'movies/' + id + '/translations/' + lang
    comments: (id) ->
      @get 'movies/' + id + '/comments'
    related: (id) ->
      @get 'movies/' + id + '/related'
  
  recommendations:
    movies: -> 
      @get('recommendations/movies')
    shows: -> 
      @get('recommendations/shows')

  scrobble: (action, type, id, progress) ->
    if type == 'movie'
      return @post('scrobble/' + action,
        movie: ids: imdb: id
        progress: progress)
    
    if type == 'episode'
      return @post('scrobble/' + action,
        episode: ids: tvdb: id
        progress: progress)
    
    return

  search: (query, type, year) ->
    @get 'search',
      query: query
      type: type
      year: year

  shows:
    summary: (id) ->
      @get 'shows/' + id, extended: 'full,images'
    
    people: (id) ->
      @get 'shows/' + id + '/people', extended: 'images'
    
    aliases: (id) ->
      @get 'shows/' + id + '/aliases'
    
    translations: (id, lang) ->
      @get 'shows/' + id + '/translations/' + lang
    
    comments: (id) ->
      @get 'shows/' + id + '/comments'
    
    watchedProgress: (id) ->
      if !id
        return $$q.reject()
      
      @get('shows/' + id + '/progress/watched')
    
    updates: (startDate) ->
      @get('shows/updates/' + startDate)
    
    related: (id) ->
      @get 'shows/' + id + '/related'
  
  episodes: 
    summary: (id, season, episode) ->
      @get 'shows/' + id + '/seasons/' + season + '/episodes/' + episode, extended: 'full,images'
    
  seasons: 
    summary: (id) ->
      @get 'shows/' + id + '/seasons', extended: 'images'
    
  sync:
    lastActivities: ->
      @get('sync/last_activities')
    
    playback: (type, id) ->
      defer = $$q.defer()
      
      if type == 'movie'
        @get('sync/playback/movies', limit: 50).then((results) ->
          results.forEach (result) ->
            if result.movie.ids.imdb.toString() == id
              defer.resolve result.progress
        ).catch (err) ->
          defer.reject err

      if type == 'episode'
        @get('sync/playback/episodes', limit: 50).then((results) ->
          results.forEach (result) ->
            if result.episode.ids.tvdb.toString() == id
              defer.resolve result.progress
        ).catch (err) ->
          defer.reject err

      defer.promise
    
    getWatched: (type) ->
        @get('sync/watched/' + type)
    
    addToHistory: (type, id) ->
      if type == 'movie'
        return @post('sync/history', movies: [ { ids: imdb: id } ])
      
      if type == 'episode'
        return @post('sync/history', episodes: [ { ids: tvdb: id } ])
    
    removeFromHistory: (type, id) ->
      if type == 'movie'
        return @post('sync/history/remove', movies: [ { ids: imdb: id } ])
      
      if type == 'episode'
        return @post('sync/history/remove', episodes: [ { ids: tvdb: id } ])

  ###
  #  General
  # FUNCTIONS
  ###
  oauth:
    authenticate: ->
      defer = $q.defer()

      @oauth.authorize().then((token) ->
        self.post('oauth/token',
          code: token
          client_id: CLIENT_ID
          client_secret: CLIENT_SECRET
          redirect_uri: REDIRECT_URI
          grant_type: 'authorization_code').then (data) ->
          
          if data.access_token and data.expires_in and data.refresh_token
            Settings.traktToken = data.access_token
            
            AdvSettings.set 'traktToken', data.access_token
            AdvSettings.set 'traktTokenRefresh', data.refresh_token
            AdvSettings.set 'traktTokenTTL', (new Date).valueOf() + data.expires_in * 1000
            
            self.authenticated = true

            defer.resolve true
          else
            AdvSettings.set 'traktToken', ''
            AdvSettings.set 'traktTokenTTL', ''
            AdvSettings.set 'traktTokenRefresh', ''
            defer.reject 'sent back no token'

      ).catch (err) ->
        defer.reject err

      defer.promise
    
    #authorize: ->
    #  defer = $q.defer()
    #  
    #  url = false
    #  API_URI = 'http://trakt.tv'
    #  OAUTH_URI = API_URI + '/oauth/authorize?response_type=code&client_id=' + CLIENT_ID
    #
    #  window.loginWindow = gui.Window.open(OAUTH_URI + '&redirect_uri=' + encodeURIComponent(REDIRECT_URI),
    #    position: 'center'
    #    focus: true
    #    title: 'Trakt.tv'
    #    icon: 'src/app/images/icon.png'
    #    toolbar: false
    #    resizable: false
    #    show_in_taskbar: false
    #    width: 600
    #    height: 600)
    #  
    #  window.loginWindow.on 'loaded', ->
    #    url = window.loginWindow.window.document.URL
    #    
    #    if url.indexOf('&') == -1 and url.indexOf('auth/signin') == -1
    #      if url.indexOf('oauth/authorize/') != -1
    #        url = url.split('/')
    #        url = url[url.length - 1]
    #      else
    #        ipc.send 'open-url-in-external', url
    #      @close true
    #    else
    #      url = false
    #    return
    #  
    #  window.loginWindow.on 'closed', ->
    #    if url
    #      defer.resolve url
    #    else
    #      AdvSettings.set 'traktToken', ''
    #      AdvSettings.set 'traktTokenTTL', ''
    #      AdvSettings.set 'traktTokenRefresh', ''
    #      defer.reject 'Trakt window closed without exchange token'
    #    return
    #  defer.promise

    checkToken: ->
      if Settings.traktTokenTTL <= (new Date).valueOf() and Settings.traktTokenRefresh != ''
        $log.info 'Trakt: refreshing access token'
        @_authenticationPromise = self.post('oauth/token',
          refresh_token: Settings.traktTokenRefresh
          client_id: CLIENT_ID
          client_secret: CLIENT_SECRET
          grant_type: 'refresh_token').then((data) ->
          if data.access_token and data.expires_in and data.refresh_token
            Settings.traktToken = data.access_token
            AdvSettings.set 'traktToken', data.access_token
            AdvSettings.set 'traktTokenRefresh', data.refresh_token
            AdvSettings.set 'traktTokenTTL', (new Date).valueOf() + data.expires_in * 1000
            self.authenticated = true
            App.vent.trigger 'system:traktAuthenticated'
            true
          else
            AdvSettings.set 'traktToken', ''
            AdvSettings.set 'traktTokenTTL', ''
            AdvSettings.set 'traktTokenRefresh', ''
            false
        )
      else if Settings.traktToken != ''
        @authenticated = true
        App.vent.trigger 'system:traktAuthenticated'
      return

  syncTrakt:
    isSyncing: ->
      @syncing and @syncing.isPending()
    
    all: ->
      AdvSettings.set 'traktLastSync', (new Date).valueOf()
      @syncing = $q.all([
        self.syncTrakt.movies()
        self.syncTrakt.shows()
      ])
    
    movies: ->
      @sync.getWatched('movies').then((data) ->
        watched = []
        if data
          movie = undefined
          for m of data
            try
              #some movies don't have imdbid
              movie = data[m].movie
              watched.push movie.ids.imdb.toString()
              App.vent.trigger 'watched', 'add', 'movie', movie.ids.imdb.toString()
            catch e
              $log.warn 'Cannot sync a movie (' + data[m].movie.title + '), the problem is: ' + e.message + '. Continuing sync without this movie...'
        watched
      ).then (traktWatched) ->
        $log.debug 'Trakt: marked %s movie(s) as watched', traktWatched.length
        true
    
    shows: ->
      @sync.getWatched('shows').then((data) ->
        # Format them for insertion
        watched = []
        if data
          show = undefined
          season = undefined
          for d of data
            show = data[d]
            for s of show.seasons
              season = show.seasons[s]
              try
                #some shows don't return IMDB
                for e of season.episodes
                  value = 
                    tvdb_id: show.show.ids.tvdb.toString()
                    imdb_id: show.show.ids.imdb.toString()
                    season: season.number.toString()
                    episode: season.episodes[e].number.toString()
                  watched.push value
              catch e
                $log.warn 'Cannot sync a show (' + show.show.title + '), the problem is: ' + e.message + '. Continuing sync without this show...'
                break
        watched
      ).then (traktWatched) ->
        # Insert them locally
        $log.debug 'Trakt: marked %s episode(s) as watched', traktWatched.length
        true

  resizeImage: (imageUrl, size) ->
    if imageUrl == undefined
      return imageUrl
    
    uri = URI(imageUrl)
    ext = uri.suffix()
    
    file = uri.filename().split('.' + ext)[0]
    
    # Don't resize images that don't come from trakt
    #  eg. YTS Movie Covers
    if imageUrl.indexOf('placeholders/original/fanart') != -1
      return 'images/bg-header.jpg'.toString()
    else if imageUrl.indexOf('placeholders/original/poster') != -1
      return 'images/posterholder.png'.toString()
    else if uri.domain() != 'trakt.us'
      return imageUrl
    
    existingIndex = 0
    
    if (existingIndex = file.search('-\\d\\d\\d$')) != -1
      file = file.slice(0, existingIndex)
    
    # reset
    uri.pathname uri.pathname().toString().replace(/thumb|medium/, 'original')
    
    if !size
      if ScreenResolution.SD or ScreenResolution.HD
        uri.pathname uri.pathname().toString().replace(/original/, 'thumb')
      else if ScreenResolution.FullHD
        uri.pathname uri.pathname().toString().replace(/original/, 'medium')
      else if ScreenResolution.QuadHD or ScreenResolution.UltraHD or ScreenResolution.Retina
        #keep original
      else
        #default to medium
        $log.debug 'ScreenResolution unknown, using \'medium\' image size'
        uri.pathname uri.pathname().toString().replace(/original/, 'medium')
    else
      if size == 'thumb'
        uri.pathname uri.pathname().toString().replace(/original/, 'thumb')
      else if size == 'medium'
        uri.pathname uri.pathname().toString().replace(/original/, 'medium')
      else
        #keep original
    if imageUrl == undefined
      'images/posterholder.png'.toString()
    else
      uri.filename(file + '.' + ext).toString()

