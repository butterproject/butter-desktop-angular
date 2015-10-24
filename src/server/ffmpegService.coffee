'use strict'

ffmpeg = require 'fluent-ffmpeg'
nodeFs = require 'fs'
pump   = require 'pump'
$q     = require 'Q'

exports.ffmpegService =
  (req, res, torrent, file) ->
    param = req.query.ffmpeg

    probe = ->
      defer = $q.defer()
      filePath = path.join torrent.path, file.path
      
      nodeFs.exists filePath, (exists) ->
        if !exists
          return defer.reject 'File doesn`t exist.'
        
        ffmpeg.ffprobe filePath, (err, metadata) ->
          if err
            defer.reject err.toString()

          defer.resolve metadata

      defer.promise

    remux = ->
      res.type 'video/webm'

      command = ffmpeg(file.createReadStream())
        .videoCodec('libvpx')
        .audioCodec('libvorbis')
        .format('webm')
        .audioBitrate(128)
        .videoBitrate(1024)
        .outputOptions [
          #'-threads 2'
          '-deadline realtime'
          '-error-resilient 1'
        ]

      pump command, res

    switch param
      when 'probe'
        return probe()
      when 'remux'
        return remux()
      else res.send 501, 'Not supported.'
