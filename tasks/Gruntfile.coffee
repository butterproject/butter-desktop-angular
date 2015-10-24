
module.exports = (grunt) ->

  grunt.initConfig

    config:
      env: 'dev'
      pkg: grunt.file.readJSON 'package.json'
      
      path:
        dist: 'dist'
        cache: 'cache'
        icons: 'src/icons'
 
  # load the tasks
  grunt.loadTasks __dirname + '/tasks'


  return