'use strict'

crypto = require 'crypto'
path   = require 'path'
semver = require 'semver'
getport = require 'get-port'

homePath = process.env[(if process.platform == 'win32' then 'USERPROFILE' else 'HOME')]
tmpLocation = path.join homePath, 'tmp', 'streamer'

getport (err, newport) ->
  exports.streamOptions.port = newport 

getPeerID = ->
  version = semver.parse '0.0.5'

  torrentVersion = [
    version.major
    version.minor
    version.patch
    (if version.prerelease.length then version.prerelease[0] else 0)
  ].join ''

  torrentPeerId = [
    'PT'
    torrentVersion
    crypto.pseudoRandomBytes(6).toString('hex')
  ].join '-'

  torrentPeerId

exports.streamOptions =
  connections: 1000
  dht: true
  port: null
  id: getPeerID()
  name: 'Butter'
  path: tmpLocation
  verify: false
  tracker: true
  trackers: [
    'udp://tracker.openbittorrent.com:80'
    'http://tracker.yify-torrents.com'
    'udp://tracker.publicbt.org:80'
    'udp://tracker.coppersurfer.tk:6969'
    'udp://tracker.leechers-paradise.org:6969'
    'udp://open.demonii.com:1337'
    'udp://p4p.arenabg.ch:1337'
    'udp://p4p.arenabg.com:1337'
    'udp://tracker.ccc.de:80'
  ]
