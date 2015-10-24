torrentProgress = require './torrentProgress'

regexPattern = /^((?!sample).)*\.(3g2|3gp|3gpp|asf|asx|avi|dvb|f4v|fli|flv|fvt|h261|h263|h264|jpgm|jpgv|mp4|jpm|m1v|m2v|m4u|m4v|mj2|mjp2|mk3d|mks|mkv|mng|mov|movie|mpe|mpeg|mpg|mxu|ogv|pyv|qt|smv|uvh|uvm|uvp|uvs|uvu|uvv|uvvh|uvvm|uvvp|uvvs|uvvu|uvvv|viv|vob|webm|wm|wmv|wmx|wvx)$/gmi

exports.isVideo = (file) ->
  regexPattern.test file.replace /\s+/g,''

exports.serializeFiles = (torrent) ->
  torrentFiles = torrent.files
  pieceLength = torrent.torrent.pieceLength
  
  cleanedTorrentFiles = []

  for torrentFile in torrentFiles
    if exports.isVideo torrentFile.name 

      start = torrentFile.offset / pieceLength | 0
      end = (torrentFile.offset + torrentFile.length - 1) / pieceLength | 0
      
      cleanedTorrentFiles.push 
        name: torrentFile.name
        path: torrentFile.path
        src: 'http://127.0.0.1:' + process.argv[2] + '/torrents/' + torrent.infoHash + '/files/' + encodeURIComponent(torrentFile.path)
        length: torrentFile.length
        offset: torrentFile.offset
        selected: torrent.selection.some (s) ->
          s.from <= start and s.to >= end

  cleanedTorrentFiles

exports.serialize = (torrent) ->
  if !torrent.torrent
    return { infoHash: torrent.infoHash }

  infoHash: torrent.infoHash
  name: torrent.torrent.name
  interested: torrent.amInterested
  ready: torrent.ready
  files: exports.serializeFiles torrent
  progress: torrentProgress torrent

exports.serializeObject = (torrents) ->
  object = {}

  for indx, torrent of torrents
    object[indx] = exports.serialize torrent

  object