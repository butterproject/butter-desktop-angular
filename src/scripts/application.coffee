app     = require 'app'
path    = require 'path'
shell   = require 'shell'
window  = require 'browser-window'

{ EventEmitter } = require 'events'

AppMenu = require './app-menu'
AppWindow = require './app-window'

class Application extends EventEmitter
  constructor: (manifest, port, options) ->
    super()

    @manifest = manifest
    @port = port
    @options = options

    app.on 'window-all-closed', ->
      if process.platform isnt 'darwin'
        app.quit()

    @menu = @createMenu()
    @menu.makeDefault()

    @mainWindow = new AppWindow options, port
    @mainWindow.loadUrl 'file://' + path.resolve __dirname, '..', 'index.html'

  createMenu: ->
    menu = new AppMenu()

    menu.on 'application:quit', ->
      app.quit()

    menu.on 'application:open-url', (menuItem) ->
      shell.openExternal menuItem.url

    menu.on 'window:reload', ->
      window.getFocusedWindow().reload()

    menu.on 'window:toggle-full-screen', ->
      focusedWindow = window.getFocusedWindow()
      focusedWindow.setFullScreen not focusedWindow.isFullScreen()

    menu.on 'window:toggle-dev-tools', ->
      window.getFocusedWindow().toggleDevTools()

    menu

module.exports = Application
