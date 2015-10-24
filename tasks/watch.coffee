cp = require 'child_process'

manifest = require '../package.json'

livereload = require 'electron-livereload'
electron = livereload.server()

module.exports = (grunt) ->

  # Watch files and reload the app on changes
  [
    ['darwin64', './build/darwin64/' + manifest.productName + '.app/Contents/MacOS/' + manifest.productName]
    ['linux32', './build/linux32/opt/' + manifest.name + '/' + manifest.name]
    ['linux64', './build/linux64/opt/' + manifest.name + '/' + manifest.name]
    ['win32', './build/win32/' + manifest.productName + '.exe']
  ].forEach (item) ->
    [dist, runnablePath] = item

    grunt.initConfig 
      watch: 
        options: 
          nospawn : true
        menus:
          files: ['./src/menus/**/*'], tasks: ['compile:' + dist + ':menus', 'restart-electron']
        styles: 
          files: ['./src/styles/**/*'], tasks: ['compile:' + dist + ':styles', 'restart-electron']
        scripts:
          files: ['./src/scripts/**/*'], tasks: ['compile:' + dist + ':scripts', 'restart-electron']
        html:
          files: ['./src/html/**/*'], tasks: ['compile:' + dist + ':html', 'restart-electron']
        deps:
          files: ['./src/node_modules/**/*'], tasks: ['compile:' + dist + ':deps', 'restart-electron']
        package: 
          files: './src/package.json', tasks: ['compile:' + dist + ':package', 'restart-electron']

    grunt.registerTask 'restart-electron', ->
      electron.restart()
      return

    grunt.registerTask 'reload-electron', ->
      electron.reload()
      return

    grunt.registerTask 'watch:' + dist, 'Watch files and reload the app on changes on ' + dist , ->
      grunt.tasks.run ['build:' + dist]

      # Start livereload
      electron.start()
      grunt.task.run 'watch'
