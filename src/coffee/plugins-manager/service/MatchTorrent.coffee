'use strict'

angular.module 'app.plugins'

.factory 'matchTorrent', ($q, Trakt) ->
  (file, torrent) ->
    dfd = $q.defer()

    data = {}

    checkTraktSearch = (trakt, filename) ->
      traktObj = trakt.match(/[\w+\s+]+/ig)[0].split(' ')
      
      traktObj.forEach (word) ->
        if word.length >= 4
          regxp = new RegExp(word.slice(0, 3), 'ig')
          if filename.replace(/\W/ig, '').match(regxp) == null
            return $q.reject(new Error('Trakt search result did not match the filename'))

      $q.when()

    searchMovie = (title) ->
      defer = $q.defer()

      Trakt.search title, 'movie'
        .then (summary) ->
          if !summary or summary.length == 0
            defer.reject new Error('Unable to fetch data from Trakt.tv')
          else
            checkTraktSearch summary[0].movie.title, data.filename
              .then ->

                defer.resolve
                  movie:
                    type: 'movie'
                    image: summary[0].movie.images.fanart.medium
                    imdbid: summary[0].movie.ids.imdb
                    title: summary[0].movie.title

              .catch (err) ->
                data.error = err.message
                defer.resolve data
                return
          return
        .catch (err) ->
          defer.reject new Error('An error occured while trying to get subtitles')

      defer.promise

    searchEpisode = (title, season, episode) ->
      defer = $q.defer()

      if !title or !season or !episode
        return defer.reject(new Error('Title, season and episode need to be passed'))
      
      # find a matching show
      Trakt.shows.summary title
        .then (summary) ->
          if !summary or summary.length == 0
            defer.reject(new Error('Unable to fetch data from Trakt.tv'))
          else
            # find the corresponding episode
            Trakt.episodes.summary title, season, episode
              .then (episodeSummary) ->
                if !episodeSummary
                  defer.reject(new Error('Unable to fetch data from Trakt.tv'))
                else
                  defer.resolve
                    type: 'episode'
                    imdbid: summary.ids.imdb
                    tvdbid: summary.ids.tvdb
                    title: summary.title
                    show:
                      episode:
                        image: episodeSummary.images.screenshot.full
                        season: episodeSummary.season.toString()
                        episode: episodeSummary.number.toString()
                        tvdbid: episodeSummary.ids.tvdb
                        title: episodeSummary.title
              .catch (err) -> defer.reject new Error 'Error while looking for metadata'
        .catch (err) -> defer.reject new Error 'Error while looking for metadata'
   
      defer.promise

    injectTorrent = (file, torrent) ->
      defer = $q.defer()

      if !torrent
        $q.when file
      else 
        to_re = torrent.match(/.*?(complete.series|complete.season|s\d+|season|\[|hdtv|\W\s)/i)

        if to_re == null or to_re[0] == ''
          torrentparsed = torrent
        else
          torrentparsed = to_re[0].replace(to_re[1], '')

        torrent_regx = new RegExp(torrentparsed.split(/\W/)[0], 'ig')
        torrent_match = file.match(torrent_regx)

        if torrent_match == null
          file = torrentparsed + ' ' + file

        $q.when file

    formatTitle = (title) ->
      formatted = {}
      
      # regex match
      se_re = title.match(/(.*)S(\d\d)E(\d\d)/i)
      
      # regex try (ex: title.s01e01)
      if se_re != null
        formatted.episode = se_re[3]
        formatted.season = se_re[2]
        formatted.title = se_re[1]
      else
        se_re = title.match(/(.*)(\d\d\d\d)+\W/i)
        
        # try another regex (ex: title.0101)
        if se_re != null
          formatted.episode = se_re[2].substr(2, 4)
          formatted.season = se_re[2].substr(0, 2)
          formatted.title = se_re[1]
        else
          se_re = title.match(/(.*)(\d\d\d)+\W/i)
          
          # try yet another (ex: title.101)
          if se_re != null
            formatted.episode = se_re[2].substr(1, 2)
            formatted.season = se_re[2].substr(0, 1)
            formatted.title = se_re[1]
          else
            se_re = title.replace(/\[|\]|\(|\)/, '').match(/.*?0*(\d+)?[xE]0*(\d+)/i)
            
            # try a last one (ex: 101, or 1x01)
            if se_re != null
              formatted.episode = se_re[2]
              formatted.season = se_re[1]
              formatted.title = se_re[0].replace(/0*(\d+)?[xE]0*(\d+)/i, '')
            else
              # nothing worked :(
      
      # format
      formatted.title = formatted.title or title.replace(/\..+$/, '')
      
      # remove extension;
      formatted.title = formatted.title.replace(/[\.]/g, ' ').replace(/^\[.*\]/, '').replace(/[^\w ]+/g, '').replace(RegExp(' +', 'g'), '-').replace(/_/g, '-').replace(/\-$/, '').replace(/\s.$/, '').replace(/^\./, '').replace(/^\-/, '')
      
      # starts with '-' just in case
      if !formatted.title or formatted.title.length == 0
        formatted.title = title
      
      $q.when formatted
 
    injectQuality = (title) ->
      # 480p
      if title.match(/480[pix]/i)
        return '480p'
      
      # 720p
      if title.match(/720[pix]/i) and !title.match(/dvdrip|dvd\Wrip/i)
        return '720p'
      
      # 1080p
      if title.match(/1080[pix]/i)
        return '1080p'
      
      # not found, trying harder
      if title.match(/DSR|DVDRIP|DVD\WRIP/i)
        return '480p'
      
      if title.match(/hdtv/i) and !title.match(/720[pix]/i)
        return '480p'
      
      false

    # function starts here
    if !file and !torrent
      # reject on missing input
      defer.reject new Error('File name is required')
    else
      # inject torrent title if not in filename
      injectTorrent file, torrent 
        .then (parsed) ->
          title = parsed.replace(/\[rartv\]/i, '').replace(/\[PublicHD\]/i, '').replace(/\[ettv\]/i, '').replace(/\[eztv\]/i, '').replace(/[\s]/g, '.')

          data.filename = file
          quality = injectQuality(file)
          
          if quality
            data.quality = quality
          
          formatTitle parsed
            .then (obj) ->
              searchEpisode obj.title, obj.season, obj.episode
                .then (result) ->
                  result.filename = data.filename
                  defer.resolve result
                .catch (error) ->
                  searchMovie obj.title
                    .then (result) ->
                      result.filename = data.filename
                      defer.resolve result
                    .catch (error) ->
                      data.error = error.message
                      defer.resolve data
            .catch (error) ->
              data.error = error.message
              defer.resolve data
        .catch (error) ->
          data.error = error.message
          defer.resolve data

    defer.promise
