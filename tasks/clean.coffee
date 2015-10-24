fs = require 'fs-extra'
del = require 'del'

manifest = require '../package.json'

module.exports = (grunt) ->

  # Remove the default_app folder and the default icon inside the darwin64 build
  grunt.registerTask 'clean:build:darwin64', 'Remove the default_app folder and the default icon inside the darwin64 build', ->
    done = @async()

    grunt.task.run ['download:darwin64']

    del [
      './build/darwin64/' + manifest.productName + '.app/Contents/Resources/default_app'
      './build/darwin64/' + manifest.productName + '.app/Contents/Resources/atom.icns'
    ], done

  # Remove the default_app folder inside the linux builds
  ['linux32', 'linux64'].forEach (dist) ->
    grunt.registerTask 'clean:build:' + dist, 'Remove the default_app folder inside the linux builds', ->
      done = @async()

      grunt.task.run ['download:' + dist]

      del './build/' + dist + '/opt/' + manifest.name + '/resources/default_app', done

  # Remove the default_app folder inside the win32 build
  grunt.registerTask 'clean:build:win32', 'Remove the default_app folder inside the win32 build', ->
    done = @async()

    grunt.task.run ['download:win32']

    del './build/win32/resources/default_app', done

  # Clean build for all platforms
  grunt.registerTask 'clean:build', [
    'clean:build:darwin64'
    'clean:build:linux32'
    'clean:build:linux64'
    'clean:build:win32'
  ]

  # Clean all the dist files for darwin64 and make sure the dir exists
  grunt.registerTask 'clean:dist:darwin64', 'Clean all the dist files for darwin64 and make sure the dir exists', ->
    done = @async()

    del './dist/' + manifest.productName + '.dmg', ->
      fs.ensureDir './dist', done

  # Just ensure the dir exists
  ['linux32', 'linux64', 'win32'].forEach (dist) ->
    grunt.registerTask 'clean:dist:' + dist, 'Just ensure the dir exists', ->
      done = @async()

      fs.ensureDir './dist', done

  # Clean dist for all platforms
  grunt.registerTask 'clean:dist', [
    'clean:dist:darwin64'
    'clean:dist:linux32'
    'clean:dist:linux64'
    'clean:dist:win32'
  ]
