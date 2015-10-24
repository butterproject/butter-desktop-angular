'use strict'

torrentUtils    = require './torrentUtils'

module.exports = (torrent) ->
  buffer = torrent.bitfield.buffer

  progress = []
  counter = 0
  downloaded = true

  i = 0

  while i < buffer.length
    p = buffer[i]

    if downloaded and p > 0 or !downloaded and p == 0
      counter++
    else
      progress.push counter
      counter = 1
      downloaded = !downloaded

    i++

  progress.push counter

  progress
    .map (p) -> p * 100 / buffer.length
    .filter (p, i) -> 
      if torrent.files[i]?.name
        torrentUtils.isVideo torrent.files[i].name
