del = require 'del'

module.exports = (grunt) ->

  # Remove the build directory
  grunt.registerTask 'purge:build', 'Remove the build directory', ->
    del './build', @async()

  # Remove the cache directory
  grunt.registerTask 'purge:cache', 'Remove the cache directory', ->
    del './cache', @async()

  # Remove the dist directory
  grunt.registerTask 'purge:dist', 'Remove the dist directory', ->
    del './dist', @async()

  # Remove the build, cache and dist directories
  grunt.registerTask 'purge', [
    'purge:build'
    'purge:cache'
    'purge:dist'
  ]
