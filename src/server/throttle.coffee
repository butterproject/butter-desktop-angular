'use strict'

module.exports = (func, wait) ->
  ctx = undefined
  args = undefined
  rtn = undefined
  timeoutID = undefined

  last = 0

  call = ->
    timeoutID = 0
    last = +new Date
    rtn = func.apply(ctx, args)
    ctx = null
    args = null
    return

  ->
    ctx = this
    args = arguments
    delta = new Date - last
    
    if !timeoutID
      if delta >= wait
        call()
      else timeoutID = setTimeout(call, wait - delta)
    
    rtn