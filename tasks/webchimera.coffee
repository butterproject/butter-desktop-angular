fs       = require 'fs'
path     = require 'path'
os       = require 'os'
wrench   = require 'wrench'
GitHub   = require 'github-releases'
Progress = require 'progress'

module.exports = (grunt) ->
  # version to download 
  version = '0.1.35'
  runtime = 'electron'
  runtimeVersion = '0.33.3'

  # Flags to keep track of downloads
  downloaded =
    darwin64: false
    linux32: false
    linux64: false
    win32: false

  dirExistsSync = (d) ->
    try
      fs.statSync d
      return true
    catch er
      return false
    return

  spawn = (options, callback) ->
    childProcess = require 'child_process'
    
    stdout = []
    stderr = []
    
    error = null
    
    proc = childProcess.spawn options.cmd, options.args, options.opts
    
    proc.stdout.on 'data', (data) -> stdout.push data.toString()
    proc.stderr.on 'data', (data) -> stderr.push data.toString()
    
    proc.on 'error', (processError) -> error = processError
    
    proc.on 'exit', (code, signal) ->
      error ?= new Error(signal) if code != 0
      results = stderr: stderr.join(''), stdout: stdout.join(''), code: code
      grunt.log.error results.stderr if code != 0
      callback error, results, code

  copyDirectory = (fromPath, toPath) ->
    wrench.mkdirSyncRecursive toPath 

    wrench.copyDirSyncRecursive fromPath, toPath,
      forceDelete: true
      excludeHiddenUnix: false
      inflateSymlinks: false

  unzipFile = (zipPath, callback) ->
    grunt.verbose.writeln "Unzipping #{path.basename(zipPath)}."
    
    directoryPath = path.dirname zipPath

    if process.platform is 'darwin'
      # The zip archive of darwin build contains symbol links, only the "unzip"
      # command can handle it correctly.
      spawn {cmd: 'unzip', args: [zipPath, '-d', directoryPath]}, (error) ->
        fs.unlinkSync zipPath
        callback error
    else
      DecompressZip = require 'decompress-zip'
      
      unzipper = new DecompressZip zipPath
      unzipper.on 'error', callback
      
      unzipper.on 'extract', ->
        fs.closeSync unzipper.fd
        fs.unlinkSync zipPath
        callback null

      unzipper.extract path: directoryPath

  downloadAndUnzip = (inputStream, zipFilePath, callback) ->
    wrench.mkdirSyncRecursive path.dirname(zipFilePath)

    unless process.platform is 'win32'
      len = parseInt(inputStream.headers['content-length'], 10)
      progress = new Progress('downloading [:bar] :percent :etas', {complete: '=', incomplete: ' ', width: 20, total: len})

    outputStream = fs.createWriteStream(zipFilePath)
    
    inputStream.pipe outputStream
    inputStream.on 'error', callback
    
    outputStream.on 'error', callback
    outputStream.on 'close', unzipFile.bind this, zipFilePath, callback
    
    inputStream.on 'data', (chunk) ->
      return if process.platform is 'win32'

      process.stdout.clearLine?()
      process.stdout.cursorTo?(0)
      progress.tick(chunk.length)

  # Download the WebChimera binary for a platform
  [
    ['osx', 'x64', 'osx', './wcjs']
    ['linux', 'x64', 'linux', './wcjs']
    ['win', 'ia32', 'win', './wcjs']
  ].forEach (release) ->
    [platform, arch, dist, outputDir] = release

    outputDir = path.join outputDir, version, dist

    grunt.registerTask 'webchimera:' + dist, 'webchimera WebChimera.js',  ->
      done = @async()

      cacheDir = path.join os.tmpdir(), 'grunt-webchimera'
      distVersion = "v#{version}"
      versionCacheDir = path.join(cacheDir, distVersion, dist)

      # Do nothing if the desired version of WebChimera.js is already installed.
      if dirExistsSync(outputDir) and dirExistsSync(versionCacheDir)
        return done()

      # Install a cached download of WebChimera.js if one is available.
      if dirExistsSync(versionCacheDir)
        grunt.verbose.writeln("Installing cached WebChimera.js #{distVersion}.")
        copyDirectory(versionCacheDir, outputDir)
        done()
        return

      # Request the assets.
      github = new GitHub repo: 'RSATom/WebChimera.js'
      
      github.getReleases tag_name: distVersion, (error, releases) ->
        unless releases?.length > 0
          grunt.log.error "Cannot find WebChimera.js #{distVersion} from GitHub", error
          return done false

        projectName = 'WebChimera.js'

        # Which file to download
        filename = "#{projectName}_#{runtime}_#{runtimeVersion}_#{arch}_#{platform}.zip"

        # Find the asset of current platform.
        for asset in releases[0].assets when asset.name is filename
          github.downloadAsset asset, (error, inputStream) ->
            if error?
              grunt.log.error "Cannot download WebChimera.js #{distVersion}", error
              return done false

            # Save file to cache.
            grunt.verbose.writeln "Downloading WebChimera.js #{distVersion}."
            
            downloadAndUnzip inputStream, path.join(versionCacheDir, filename), (error) ->
              if error?
                grunt.log.error "Failed to download WebChimera.js #{distVersion}", error
                return done false

              grunt.verbose.writeln "Installing WebChimera.js #{distVersion}."
              copyDirectory(versionCacheDir, outputDir)
              done()
          return

        grunt.log.error "Cannot find #{filename} in electron #{distVersion} release"
        done false

  # Download the WebChimera binaries for all platforms
  grunt.registerTask 'webchimera', [
    'webchimera:osx'
    'webchimera:linux'
    'webchimera:win'
  ]
