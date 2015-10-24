#manifest = require '../package.json'

module.exports = (grunt) ->
  manifest = grunt.package

  [
    ['darwin64', './build/darwin64/' + manifest.productName + '.app/Contents/Resources/app']
    ['linux32', './build/linux32/opt/' + manifest.name + '/resources/app']
    ['linux64', './build/linux64/opt/' + manifest.name + '/resources/app']
    ['win32', './build/win32/resources/app']
  ].forEach (item) ->
    [dist, dir] = item

    # Compile menus
    grunt.registerTask 'compile:' + dist + ':menus', 'Compile menus', ->
      grunt.task.run ['clean:build:' + dist]

      #gulp.src './src/menus/**/*.cson'
      #.pipe mustache manifest
      #.pipe gulp.dest dir + '/menus'

    # Compile styles
    grunt.registerTask 'compile:' + dist + ':styles', 'Compile styles', ->
      grunt.task.run ['clean:build:' + dist]

      #gulp.src './src/styles/**/*.less'
      #.pipe gulp.dest dir + '/styles'

    # Compile scripts
    grunt.registerTask 'compile:' + dist + ':scripts', 'Compile scripts', ->
      grunt.task.run ['clean:build:' + dist]

      # './src/scripts/**/*.js'
      # gulp.dest dir + '/scripts'

    # Move html files
    grunt.registerTask 'compile:' + dist + ':html', 'Move html files', ->
      grunt.task.run ['clean:build:' + dist]

      #gulp.src './src/html/**/*.html'

    # Move the node modules
    grunt.registerTask 'compile:' + dist + ':deps', 'Move the node modules', ->
      grunt.task.run ['clean:build:' + dist]

      #gulp.src './src/node_modules/**/*'
      #gulp.dest dir + '/node_modules'

    # Move package.json
    grunt.registerTask 'compile:' + dist + ':package', 'Move package.json', ->
      grunt.task.run ['clean:build:' + dist]
      #grunt.task.run ['copy:package_json:' + dist]

    # Compile everything
    grunt.registerTask 'compile:' + dist, [
      'compile:' + dist + ':menus'
      'compile:' + dist + ':styles'
      'compile:' + dist + ':scripts'
      'compile:' + dist + ':html'
      'compile:' + dist + ':deps'
      'compile:' + dist + ':package'
    ]

  # Compile for all platforms
  grunt.registerTask 'compile', [
    'compile:darwin64'
    'compile:linux32'
    'compile:linux64'
    'compile:win32'
  ]
