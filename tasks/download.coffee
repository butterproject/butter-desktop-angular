fs       = require 'fs'
path     = require 'path'
os       = require 'os'
wrench   = require 'wrench'
GitHub   = require 'github-releases'
Progress = require 'progress'

manifest = require '../package.json'

module.exports = (grunt) ->
  # version to download 
  version = '0.33.3'

  # Flags to keep track of downloads
  downloaded =
    darwin64: false
    linux32: false
    linux64: false
    win32: false

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

  getApmPath = (platform) ->
    apmPath = path.join 'apm', 'node_modules', 'atom-package-manager', 'bin', 'apm'
    apmPath = 'apm' unless grunt.file.isFile apmPath

    if platform is 'win32' then "#{apmPath}.cmd" else apmPath

  getAtomShellVersion = (directory) ->
    versionPath = path.join directory, 'version'
    if grunt.file.isFile versionPath
      grunt.file.read(versionPath).trim()
    else
      null

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
      DecompressZip = require('decompress-zip')
      unzipper = new DecompressZip(zipPath)
      unzipper.on 'error', callback
      unzipper.on 'extract', ->
        fs.closeSync unzipper.fd
        fs.unlinkSync zipPath

        # Make sure atom/electron is executable on Linux
        if process.platform is 'linux'
          electronAppPath = path.join(directoryPath, 'electron')
          fs.chmodSync(electronAppPath, '755') if fs.existsSync(electronAppPath)

          atomAppPath = path.join(directoryPath, 'atom')
          fs.chmodSync(atomAppPath, '755') if fs.existsSync(atomAppPath)

        callback null
      unzipper.extract(path: directoryPath)

  downloadAndUnzip = (inputStream, zipFilePath, callback) ->
    wrench.mkdirSyncRecursive(path.dirname(zipFilePath))

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

  rebuildNativeModules = (dist, apm, previousVersion, currentVersion, needToRebuild, callback, appDir) ->
    if currentVersion isnt previousVersion and needToRebuild
      grunt.verbose.writeln "Rebuilding native modules for new electron version #{currentVersion}."
      apm = getApmPath(dist)

      # When we spawn apm, we still want to use the global environment variables
      options = env: {}
      options.env[key] = value for key, value of process.env
      options.env.ATOM_NODE_VERSION = currentVersion.substr(1)

      # If the appDir has been set, then that is where we want to perform the rebuild.
      # it defaults to the current directory
      options.cwd = appDir if appDir
      spawn {cmd: apm, args: ['rebuild'], opts: options}, callback
    else
      callback()

  # Download the Electron binary for a platform
  [
    ['darwin', 'x64', 'darwin64', './electron/darwin64']
    ['linux', 'ia32', 'linux32', './electron/linux32/opt/' + manifest.name]
    ['linux', 'x64', 'linux64', './electron/linux64/opt/' + manifest.name]
    ['win32', 'ia32', 'win32', './electron/win32']
    ['win32', 'x64', 'win64', './electron/win64']
  ].forEach (release) ->
    [platform, arch, dist, outputDir] = release

    grunt.registerTask 'download:' + dist, 'Download electron',  ->
      downloadDir = path.join os.tmpdir(), 'grunt-electron'
      symbols = false
      rebuild = false
      apm = getApmPath(dist)
      distVersion = "v#{version}"
      versionDownloadDir = path.join(downloadDir, distVersion, dist)
      appDir = process.cwd()

      done = @async()

      # Do nothing if the desired version of electron is already installed.
      currentAtomShellVersion = getAtomShellVersion(outputDir)
      return done() if currentAtomShellVersion is distVersion

      # Install a cached download of electron if one is available.
      if getAtomShellVersion(versionDownloadDir)?
        grunt.verbose.writeln("Installing cached electron #{distVersion}.")
        copyDirectory(versionDownloadDir, outputDir)
        rebuildNativeModules dist, apm, currentAtomShellVersion, distVersion, rebuild, done, appDir
        return

      # Request the assets.
      github = new GitHub({repo: 'atom/electron'})
      github.getReleases tag_name: distVersion, (error, releases) ->
        unless releases?.length > 0
          grunt.log.error "Cannot find electron #{distVersion} from GitHub", error
          return done false


        atomShellAssets = releases[0].assets.filter ({name}) -> name.indexOf('atom-shell-') is 0
        if atomShellAssets.length > 0
          projectName = 'atom-shell'
        else
          projectName = 'electron'

        # Which file to download
        filename =
          if symbols
            "#{projectName}-#{distVersion}-#{platform}-#{arch}-symbols.zip"
          else
            "#{projectName}-#{distVersion}-#{platform}-#{arch}.zip"

        # Find the asset of current platform.
        for asset in releases[0].assets when asset.name is filename
          github.downloadAsset asset, (error, inputStream) ->
            if error?
              grunt.log.error "Cannot download electron #{distVersion}", error
              return done false

            # Save file to cache.
            grunt.verbose.writeln "Downloading electron #{distVersion}."
            downloadAndUnzip inputStream, path.join(versionDownloadDir, "#{projectName}.zip"), (error) ->
              if error?
                grunt.log.error "Failed to download electron #{distVersion}", error
                return done false

              grunt.verbose.writeln "Installing electron #{distVersion}."
              copyDirectory(versionDownloadDir, outputDir)

              rebuildNativeModules dist, apm, currentAtomShellVersion, distVersion, rebuild, done, appDir

              if dist is 'darwin64'
                fs.renameSync outputDir + '/Electron.app', outputDir + '/' + manifest.productName + '.app'

          return

        grunt.log.error "Cannot find #{filename} in electron #{distVersion} release"
        done false

  # Download the Electron binaries for all platforms
  grunt.registerTask 'download', [
    'download:darwin64'
    'download:linux32'
    'download:linux64'
    'download:win32'
  ]
