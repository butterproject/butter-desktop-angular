'use strict'

angular.module 'app.services', []

.factory 'ScreenResolution', ->
  SD: window.screen.width < 1280 or window.screen.height < 720
  HD: window.screen.width >= 1280 and window.screen.width < 1920 or window.screen.height >= 720 and window.screen.height < 1080
  FullHD: window.screen.width >= 1920 and window.screen.width < 2000 or window.screen.height >= 1080 and window.screen.height < 1600
  UltraHD: window.screen.width >= 2000 or window.screen.height >= 1600
  QuadHD: window.screen.width >= 3000 or window.screen.height >= 1800
  Standard: window.devicePixelRatio <= 1
  Retina: window.devicePixelRatio > 1

.constant 'titleButtons',  
  win32: ['min', 'max', 'close']
  darwin: ['close', 'min', 'max']
  linux: ['min', 'max', 'close']

.run (ipc, Settings, ScreenResolution, $timeout, deviceScan, $templateCache) ->

  zoom = 0
  screen = window.screen
  
  if ScreenResolution.QuadHD
    zoom = 2

  width = parseInt(if localStorage.width then localStorage.width else Settings.defaultWidth)
  height = parseInt(if localStorage.height then localStorage.height else Settings.defaultHeight)
  
  x = parseInt(if localStorage.posX then localStorage.posX else -1)
  y = parseInt(if localStorage.posY then localStorage.posY else -1)
 
  # reset app width when the width is bigger than the available width
  if screen.availWidth < width
    width = screen.availWidth
  
  # reset app height when the width is bigger than the available height
  if screen.availHeight < height
    height = screen.availHeight
  
  # reset x when the screen width is smaller than the window x-position + the window width
  if x < 0 or x + width > screen.width
    x = Math.round((screen.availWidth - width) / 2)
  
  # reset y when the screen height is smaller than the window y-position + the window height
  if y < 0 or y + height > screen.height
    y = Math.round((screen.availHeight - height) / 2)

  ipc.send 'ready', 
    size: [width, height]
    coords: [x, y] 
    zoom: zoom

  $timeout -> 
    deviceScan()
  , 1500, false

  return
