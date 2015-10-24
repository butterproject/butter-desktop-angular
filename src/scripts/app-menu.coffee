Menu = require 'menu'

{ EventEmitter } = require 'events'

class AppMenu extends EventEmitter
  constructor: ->
    super()

    template = require './menus/' + process.platform

    @wireUpCommands template
    @menu = Menu.buildFromTemplate template

  makeDefault: ->
    Menu.setApplicationMenu @menu

  wireUpCommands: (submenu) ->
    submenu.forEach (item) => 
      if item.command
        existingOnClick = item.click

        item.click = => 
          @emit item.command, item

          if existingOnClick
            existingOnClick()

      if item.submenu
        @wireUpCommands item.submenu

module.exports = AppMenu
