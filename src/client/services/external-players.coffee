'use strict'

angular.module 'app.services'

.constant 'players',
  'VLC':
    name: 'Vlc'
    type: 'vlc'
    cmd: '/Contents/MacOS/VLC'
    switches: '--no-video-title-show'
    subswitch: '--sub-file='
    fs: '-f'
    stop: 'vlc://quit'
    pause: 'vlc://pause'

  'vlc':
    name: 'Vlc'
    type: 'vlc'
    cmd: 'vlc'
    switches: '--no-video-title-show'
    subswitch: '--sub-file='
    fs: '-f'
    stop: 'vlc://quit'
    pause: 'vlc://pause'

  'Fleex player':
    name: 'Fleex player'
    type: 'fleex-player'
    cmd: '/Contents/MacOS/Fleex player'
    filenameswitch: '-file-name '

  'MPlayer OSX Extended':
    name: 'MPlayer OSX Extended'
    type: 'mplayer'
    cmd: '/Contents/Resources/Binaries/mpextended.mpBinaries/Contents/MacOS/mplayer'
    switches: '-font "/Library/Fonts/Arial Bold.ttf"'
    subswitch: '-sub '
    fs: '-fs'

  'mplayer':
    name: 'MPlayer'
    type: 'mplayer'
    cmd: 'mplayer'
    switches: '-really-quiet'
    subswitch: '-sub '
    fs: '-fs'

  'mpv':
    name: 'mpv'
    type: 'mpv'
    switches: '--no-terminal'
    subswitch: '--sub-file='
    fs: '--fs'

  'MPC-HC':
    name: 'MPC-HC'
    type: 'mpc-hc'
    switches: ''
    subswitch: '/sub '
    fs: '/fullscreen'

  'MPC-HC64':
    name: 'MPC-HC64'
    type: 'mpc-hc'
    switches: ''
    subswitch: '/sub '
    fs: '/fullscreen'

  'MPC-BE':
    name: 'MPC-BE'
    type: 'mpc-be'
    switches: ''
    subswitch: '/sub '
    fs: '/fullscreen'

  'MPC-BE64':
    name: 'MPC-BE64'
    type: 'mpc-be'
    switches: ''
    subswitch: '/sub '
    fs: '/fullscreen'

  'SMPlayer':
    name: 'SMPlayer'
    type: 'smplayer'
    switches: ''
    subswitch: '-sub '
    fs: '-fs'
    stop: 'smplayer -send-action quit'
    pause: 'smplayer -send-action pause'

  'Bomi':
    name: 'Bomi'
    type: 'bomi'
    switches: ''
    subswitch: '--set-subtitle '
    fs: '--action window/enter-fs'

.constant 'readdirp', require 'readdirp'
.constant 'child', require 'child_process'

.factory 'deviceScan', ($log, $q, players, child, readdirp, nodeFs, path, Settings) ->
  ->
    defer = $q.defer()

    playerKeys = Object.keys players

    searchPaths =
      linux: []
      darwin: []
      win32: []

    addPath = (path) ->
      if nodeFs.existsSync(path)
        searchPaths[process.platform].push path

    # linux
    addPath '/usr/bin'
    addPath '/usr/local/bin'

    # darwin
    addPath '/Applications'
    addPath process.env.HOME + '/Applications'

    # win32
    addPath process.env.SystemDrive + '\\Program Files\\'
    addPath process.env.SystemDrive + '\\Program Files (x86)\\'
    addPath process.env.LOCALAPPDATA + '\\Apps\\2.0\\'

    folderName = ''
    birthtimes = {}

    angular.forEach searchPaths[process.platform], (folderName) ->
      folderName = path.resolve(folderName)

      fileStream = readdirp(
        root: folderName
        fileFilter: playerKeys
        depth: 3)

      fileStream.on 'data', (d) ->
        birthtime = d.stat.birthtime
        previousBirthTime = birthtimes[d.name]

        if !previousBirthTime or (birthtime > previousBirthTime)

          if !previousBirthTime
            Settings.avaliableDevices[d.name] =
              type: 'external-' + players[d.name].type
              name: players[d.name].name
              key: d.name
              path: d.fullPath
          else
            Settings.avaliableDevices[d.name].path = d.fullPath
            $log.info 'Updated External Player: ' + d.name + ' with more recent version found in ' + d.fullParentDir

          birthtimes[d.name] = birthtime

      fileStream.on 'end', ->
        defer.resolve()
        $log.info "Available devices are :"
        for id, device of Settings.avaliableDevices
          $log.info "- " + device.name + " (type: " + device.type + ", path: " + device.path + ")"

    defer.promise
