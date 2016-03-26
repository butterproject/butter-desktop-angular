'use strict'

angular.module 'app.settings'

.factory 'Settings', (os, data_path, path) ->
  brand =     name: 'Butter'
  # Branding

  branding: brand

  # User interface
  language: 'en'
  translateSynopsis: true
  coversShowRating: true
  watchedCovers: 'fade'
  showAdvancedSettings: false

  postersMinWidth: 134
  postersMaxWidth: 294
  postersMinFontSize: 0.8
  postersMaxFontSize: 1.3
  postersSizeRatio: 196 / 134
  postersWidth: @postersMinWidth
  postersJump: [134, 154, 174, 194, 214, 234, 254, 274, 294]

  #Playback
  alwaysFullscreen: false
  playNextEpisodeAuto: true
  chosenPlayer: 'local'
  avaliableDevices:
    'local':
      type: 'local'
      name: brand.name
      path: null

  # Advanced UI
  alwaysOnTop: false
  theme: 'Official_-_Dark_theme'
  ratingStars: true

  #trigger on click in details
  startScreen: 'Movies'
  lastTab: ''

  # Quality
  shows_default_quality: '720p'
  movies_default_quality: '1080p'
  moviesShowQuality: false
  movies_quality: 'all'

  # Subtitles
  subtitle_language: 'none'
  subtitle_size: '28px'
  subtitle_color: '#ffffff'
  subtitle_decoration: 'Outline'
  subtitle_font: 'Arial'

  # More options
  httpApiPort: 8008
  httpApiUsername: 'butter'
  httpApiPassword: 'butter'

  # Trakt.tv
  traktToken: ''
  traktTokenRefresh: ''
  traktTokenTTL: ''
  traktTvVersion: '0.0.2'
  traktLastSync: ''
  traktLastActivities: ''
  traktSyncOnStart: true
  traktPlayback: true

  # TVShow Time
  tvstAccessToken: ''

  # Advanced options
  connectionLimit: 100
  dhtLimit: 500
  streamPort: 0

  # 0 = Random
  tmpLocation: path.join(os.tmpDir(), 'Butter')
  databaseLocation: path.join(data_path, 'data')
  deleteTmpOnClose: true
  automaticUpdating: true
  events: true
  minimizeToTray: false
  bigPicture: false

  # Features
  activateTorrentCollection: true
  activateWatchlist: true
  activateVpn: true
  activateRandomize: true
  onlineSearchEngine: 'KAT'

  # Ratio
  totalDownloaded: 0
  totalUploaded: 0

  # VPN
  vpn: false
  vpnUsername: ''
  vpnPassword: ''

  vodoAPI:
    url: 'http://vodo.net/popcorn'

  tvshowAPI:
    url: 'http://eztvapi.re/'
    index: 0
    proxies: [
      {
        url: 'http://eztvapi.re/'
        ssl: false
        fingerprint: /"status":"online"/
      }
      {
        url: 'http://api.butterproject.org/'
        ssl: false
        fingerprint: /"status":"online"/
      }
      {
        url: 'http://tv.ytspt.re/'
        ssl: false
        fingerprint: /"status":"online"/
      }
    ]

  updateEndpoint:
    url: 'https://butterproject.org/'
    index: 0

  # App Settings
  dbversion: '0.1.0'
  font: 'tahoma'

  defaultWidth: Math.round(window.screen.availWidth * 0.8)
  defaultHeight: Math.round(window.screen.availHeight * 0.8)

  # Miscellaneous
  playerSubPosition: '0px'
  playerVolume: '1'
  tv_detail_jump_to: 'next'
