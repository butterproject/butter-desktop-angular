'use strict'

angular.module 'app.services'

.factory 'playerService', ($q) ->
  findTorrentUrl = (episode, selected, defaultQuality) ->
    if defaultQuality isnt '0'
      quality = episode.torrents[defaultQuality]
      if quality then return torrent.url
    episode.torrents[0].url

  sortNextEpisodes: (player) ->
    return $q.reject() unless player?.detail

    show = player.detail

    selected = player.episode
    defaultQuality = player.quality 

    playNextEpisodes = []

    for episode in show.episodes
      if (episode.episode >= selected.episode and episode.season is selected.season) or (episode.season > selected.season)
        playNextEpisodes.push
          title: episode.title
          season: episode.season
          episode: episode.episode
          torrent: findTorrentUrl episode, selected, defaultQuality

    $q.when playNextEpisodes
