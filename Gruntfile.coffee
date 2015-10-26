os = require 'os'
livereload = require 'electron-livereload'

electron = livereload.server()

platform  = os.platform()
{ normalize, sep } = require 'path'

if platform is 'darwin'
  platform = 'osx'

if platform in [ 'linux', 'osx' ]
  platform = platform + os.arch().replace 'x', ''

module.exports = (grunt) ->

  grunt.initConfig

    config:
      platform: platform
      env: 'dev'
      pkg: grunt.file.readJSON 'package.json'

    clean:
      build: src: [ 'build' ]
      dist: src: [ 'dist' ]

    coffee:
      app:
        options:
          bare: true
          join: true
        files: 'build/js/app.js': ['src/client/*.coffee', 'src/client/**/**.coffee']
      server:
        expand: true
        flatten: true
        cwd: 'src/server'
        src: [ '*.coffee' ]
        dest: 'build/server/'
        ext: '.js'
      main:
        expand: true
        cwd: 'src/scripts'
        src: [ '**/*.coffee' ]
        dest: 'build/scripts/'
        ext: '.js'

    watch:
      options:
        nospawn : true
      client:
        files: ['src/client/*.client', 'src/client/**/*.coffee',
                'src/client/*.html', 'src/client/**/*.html'],
        tasks: ['coffee', 'ngtemplates', 'ngAnnotate', 'restart-electron']
      stylus:
        files: ['src/**/*.styl'],
        tasks: ['stylus', 'restart-electron']
      server:
        files: ['src/server/*.coffee', 'src/server/**/*.coffee'],
        tasks: ['coffee', 'restart-electron']

    # https://www.npmjs.com/package/grunt-angular-templates
    ngtemplates:
      ng:
        cwd: 'src/client'
        src: ['**/*.html']
        dest: 'build/js/templates.js'

    # https://www.npmjs.com/package/grunt-ng-annotate
    ngAnnotate:
      build:
        files: 'build/js/app.js': ['build/js/app.js']

    concat:
      js:
        src: [
          'src/vendor/js/**/*.js'
          'src/vendor/js/**'
        ]
        dest: 'build/js/vendor.js'

      css:
        src: [
          'src/vendor/css/**/*.css'
          'src/vendor/css/**'
        ]
        dest: 'build/css/vendor.css'

    stylus:
      build:
        options:
          'resolve url': true
          use: [ 'nib' ]
          compress: false
          paths: [ '/styl' ]

        expand: true
        join: true
        files: 'build/css/app.css': ['src/**/*.styl', 'src/**/**.styl']

    'string-replace':
      main_script:
        files:
          'build/package.json': 'package.json'
        options:
          replacements:
            [ {
              pattern: 'build/scripts/main.js'
              replacement: 'scripts/main.js'
            } ]

    copy:
      main:
        files: [
          { expand: true, cwd: 'src/assets/', src: ['**'], dest: 'build' }
        ]
      server:
        src: ['src/server/package.json']
        dest: 'build/server/package.json'
      node_modules:
        files: [
          { expand: true, cwd: 'node_modules/', src: ['**'], dest: 'build/node_modules' }
        ]

    electron:
      options:
        name: 'Butter'
        dir: 'build'
        out: 'dist'
        version: '0.34.1'
        overwrite: true
        ignore: []
        app_version: "0.4.dev"
      linux64:
        options:
          platform: 'linux'
          arch: 'x64'
      linux32:
        options:
          platform: 'linux'
          arch: 'ia32'
      darwin:
        options:
          platform: 'darwin'
          arch: 'x64'
          # icon: ""
      win32:
        options:
          platform: 'win32'
          arch: 'x64'
          # icon: ""

  # load the tasks
  require('load-grunt-tasks') grunt
  grunt.loadNpmTasks 'grunt-string-replace'

  grunt.registerTask 'default', ->
    grunt.task.run 'build'
    grunt.task.run 'start'

  grunt.registerTask 'restart-electron', ->
    electron.restart()
    return

  grunt.registerTask 'reload-electron', ->
    electron.reload()
    return

  grunt.registerTask 'copyDeps', ->
    grunt.task.run 'copy:main'
    grunt.task.run 'copy:server'
    grunt.task.run 'copy:node_modules'

  # define the main tasks
  grunt.registerTask 'build', (env) ->
    env = env or 'dev'
    grunt.config.set 'config.env', env

    grunt.task.run 'clean:build'
    grunt.task.run 'string-replace:main_script'
    grunt.task.run 'coffee'
    grunt.task.run 'ngtemplates:ng'
    grunt.task.run 'ngAnnotate:build'
    grunt.task.run 'stylus:build'
    grunt.task.run 'concat'
    grunt.task.run 'copyDeps'

  grunt.registerTask 'start', (env) ->
    electron.start()
    grunt.task.run 'watch'

  grunt.registerTask 'dev', (env) ->
    process.env.NODE_ENV = 'dev'
    grunt.task.run 'build'
    grunt.task.run 'start'
    return

  grunt.event.on 'watch', (action, filepath, target) ->
    grunt.log.writeln target + ': ' + filepath + ' has ' + action
    return

  grunt.registerTask 'package', ->
    grunt.task.run 'electron:linux64'
    grunt.task.run 'electron:linux32'
    grunt.task.run 'electron:darwin'
    grunt.task.run 'electron:win32'

