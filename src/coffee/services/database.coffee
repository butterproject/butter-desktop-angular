'use strict'

angular.module 'app.services'

.factory 'Database', (Datastore, data_path) ->
  db = {}

  TTL = 1000 * 60 * 60 * 24

  startupTime = window.performance.now()

  promisifyDatastore = (datastore) ->
    datastore.insert = Q.denodeify(datastore.insert, datastore)
    datastore.update = Q.denodeify(datastore.update, datastore)
    datastore.remove = Q.denodeify(datastore.remove, datastore)

  console.debug 'Database path: ' + data_path
  process.env.TZ = 'America/New_York'

  # set same api tz
  db.bookmarks = new Datastore(
    filename: path.join data_path, 'data/bookmarks.db'
    autoload: true
  )

  db.settings = new Datastore(
    filename: path.join data_path, 'data/settings.db'
    autoload: true
  )

  db.tvshows = new Datastore(
    filename: path.join data_path, 'data/shows.db'
    autoload: true
  )

  db.movies = new Datastore(
    filename: path.join data_path, 'data/movies.db'
    autoload: true
  )

  db.watched = new Datastore(
    filename: path.join data_path, 'data/watched.db'
    autoload: true
  )

  promisifyDatastore db.bookmarks
  promisifyDatastore db.settings
  promisifyDatastore db.tvshows
  promisifyDatastore db.movies
  promisifyDatastore db.watched
  
  # Create unique indexes for the various id's for shows and movies
  db.tvshows.ensureIndex
    fieldName: 'imdb_id'
    unique: true
  
  db.tvshows.ensureIndex
    fieldName: 'tvdb_id'
    unique: true
  
  db.movies.ensureIndex
    fieldName: 'imdb_id'
    unique: true
  
  db.movies.removeIndex 'imdb_id'
  db.movies.removeIndex 'tmdb_id'
  
  db.bookmarks.ensureIndex
    fieldName: 'imdb_id'
    unique: true
  
  # settings key uniqueness
  db.settings.ensureIndex
    fieldName: 'key'
    unique: true

  extractIds = (items) ->
    items.map (item) -> item['imdb_id']

  extractMovieIds = (items) ->
    items.map (item) -> item['movie_id']

  # This utilizes the exec function on nedb to turn function calls into promises
  promisifyDb = (obj) ->
    $q (resolve, reject) ->
      obj.exec (error, result) ->
        if error
          reject error
        else resolve result
      return

  addMovie: (data) ->
    db.movies.insert data
  
  deleteMovie: (imdb_id) ->
    db.movies.remove imdb_id: imdb_id
  
  getMovie: (imdb_id) ->
    promisifyDb db.movies.findOne(imdb_id: imdb_id)
  
  addBookmark: (imdb_id, type) ->
    App.userBookmarks.push imdb_id
  
    db.bookmarks.insert
      imdb_id: imdb_id
      type: type
  
  deleteBookmark: (imdb_id) ->
    App.userBookmarks.splice App.userBookmarks.indexOf(imdb_id), 1
    db.bookmarks.remove imdb_id: imdb_id
  
  deleteBookmarks: ->
    db.bookmarks.remove {}, multi: true
  
  deleteWatched: ->
    db.watched.remove {}, multi: true
  
  getBookmarks: (data) ->
    page = data.page - 1
    byPage = 50
    offset = page * byPage
    query = {}
    promisifyDb db.bookmarks.find(query).skip(offset).limit(byPage)
  
  getAllBookmarks: ->
    promisifyDb(db.bookmarks.find({})).then (data) ->
      bookmarks = []
      if data
        bookmarks = extractIds(data)
      bookmarks
  
  markMoviesWatched: (data) ->
    db.watched.insert data
  
  markMovieAsWatched: (data) ->
    if data.imdb_id
      App.watchedMovies.push data.imdb_id
      
      return db.watched.insert(
        movie_id: data.imdb_id.toString()
        date: new Date
        type: 'movie')

    $log.warn 'This shouldn\'t be called'
    
    $q.when
  
  markMovieAsNotWatched: (data) ->
    App.watchedMovies.splice App.watchedMovies.indexOf(data.imdb_id), 1
    db.watched.remove movie_id: data.imdb_id.toString()
  
  getMoviesWatched: ->
    promisifyDb db.watched.find type: 'movie'
  
  addTVShow: (data) ->
    db.tvshows.insert data
  
  updateTVShow: (data) ->
    db.tvshows.update { imdb_id: data.imdb_id }, data
  
  markEpisodeAsWatched: (data) ->
    promisifyDb(db.watched.find(tvdb_id: data.tvdb_id.toString())).then (response) ->
      if response.length == 0
        App.watchedShows.push data.imdb_id.toString()
    .then ->
      db.watched.insert
        tvdb_id: data.tvdb_id.toString()
        imdb_id: data.imdb_id.toString()
        season: data.season.toString()
        episode: data.episode.toString()
        type: 'episode'
        date: new Date

  markEpisodesWatched: (data) ->
    db.watched.insert data
  
  markEpisodeAsNotWatched: (data) ->
    promisifyDb(db.watched.find(tvdb_id: data.tvdb_id.toString())).then (response) ->
      if response.length is 1
        App.watchedShows.splice App.watchedShows.indexOf(data.imdb_id.toString()), 1
    .then ->
      db.watched.remove
        tvdb_id: data.tvdb_id.toString()
        imdb_id: data.imdb_id.toString()
        season: data.season.toString()
        episode: data.episode.toString()

  checkEpisodeWatched: (data) ->
    promisifyDb db.watched.find(
      tvdb_id: data.tvdb_id.toString()
      imdb_id: data.imdb_id.toString()
      season: data.season.toString()
      episode: data.episode.toString()
    ).then (data) ->
      data != null and data.length > 0
  
  getEpisodesWatched: (tvdb_id) ->
    promisifyDb db.watched.find tvdb_id: tvdb_id.toString()
  
  getAllEpisodesWatched: ->
    promisifyDb db.watched.find type: 'episode'
  
  deleteTVShow: (imdb_id) ->
    db.tvshows.remove imdb_id: imdb_id
  
  getTVShow: (data) ->
    promisifyDb db.tvshows.findOne _id: data.tvdb_id

  getTVShowByImdb: (imdb_id) ->
    promisifyDb db.tvshows.findOne imdb_id: imdb_id
  
  getSetting: (data) ->
    promisifyDb db.settings.findOne key: data.key 
  
  getSettings: ->
    promisifyDb db.settings.find {}
  
  getUserInfo: ->
    bookmarks = @getAllBookmarks().then (data) ->
      App.userBookmarks = data

    movies = @getMoviesWatched().then (data) ->
      App.watchedMovies = extractMovieIds(data)

    episodes = @getAllEpisodesWatched().then (data) ->
      App.watchedShows = extractIds(data)

    $q.all [ bookmarks, movies, episodes ]
  
  writeSetting: (data) ->
    @getSetting(key: data.key).then (result) ->
      if result
        db.settings.update { 'key': data.key }, { $set: 'value': data.value }, {}
      else db.settings.insert data
  
  resetSettings: ->
    db.settings.remove {}, multi: true
  
  deleteDatabases: ->
    fs.unlinkSync path.join(data_path, 'data/watched.db')
    fs.unlinkSync path.join(data_path, 'data/movies.db')
    fs.unlinkSync path.join(data_path, 'data/bookmarks.db')
    fs.unlinkSync path.join(data_path, 'data/shows.db')
    fs.unlinkSync path.join(data_path, 'data/settings.db')
    
    $q (resolve, reject) ->
      req = indexedDB.deleteDatabase(App.Config.cache.name)

      req.onsuccess = -> resolve()
      req.onerror = -> reject()

  initialize: ->
    @getUserInfo().then(@getSettings).then (data) ->
      if data != null
        for key of data
          Settings[data[key].key] = data[key].value
      else
        win.warn 'is it possible to get here'
      
      # new install?
      if Settings.version == false
        window.__isNewInstall = true

      AdvSettings.checkApiEndpoints [
        Settings.tvshowAPI
        Settings.updateEndpoint
      ]

    .then ->
      # set app language
      window.setLanguage Settings.language

      # set hardware settings and usefull stuff
      AdvSettings.setup()
    .then ->
      App.Trakt = App.Config.getProvider 'metadata'
      App.TVShowTime = App.Config.getProvider 'tvst'
      
      # check update
      updater = new (App.Updater)
    
      updater.update().catch (err) ->
        win.error 'updater.update()', err

      # we look if VPN is connected
      App.VPNClient.isRunning()
    
    .catch (err) ->
      win.error 'Error starting up', err
