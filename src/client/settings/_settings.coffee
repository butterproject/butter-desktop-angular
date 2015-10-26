'use strict'

angular.module 'app.settings', []

.directive 'ptSettingsContainer', ->
  restrict: 'E'
  templateUrl: (element, attrs) ->
    'settings/templates/settings-' + attrs.template + '.html'

.controller 'settingsController', ($scope, $http, $rootScope, $q, path, Settings) ->
  vm = this

  vm.goBack = ->
    
  vm.config = Settings

  vm.tv_detail_jump_to = 
    firstUnwatched: 'First Unwatched Episode'
    next: 'Next Episode In Series'

  vm.overallRatio = ->
    ratio = (vm.settings.totalUploaded / vm.settings.totalDownloaded).toFixed(2)
    if isNaN(ratio) then (ratio = 'None') else ratio
    ratio

  vm.load = ->
    $http.get('/containers/settings/settings').success (data) ->
      vm.settings = data
 
  vm.sub_sizes = ["20px","22px","24px","26px","28px","30px","32px","34px","36px","38px","48px","50px","52px","54px","56px","58px","60px"]

  vm.watch_type = 
    none: 'Show'
    fade: 'Fade'
    hide: 'Hide'

  vm.sub_deco = ["None", "Outline", "Opaque Background"]

  vm.arr_fonts = [
    { name: 'AljazeeraMedExtOf', id: 'aljazeera' }
    { name: 'Deja Vu Sans', id: 'dejavusans' }
    { name: 'Droid Sans', id: 'droidsans' }
    { name: 'Comic Sans MS', id: 'comic' }
    { name: 'Georgia', id: 'georgia' }
    { name: 'Geneva', id: 'geneva' }
    { name: 'Helvetica', id: 'helvetica' }
    { name: 'Khalid Art', id: 'khalid' }
    { name: 'Lato', id: 'lato' }
    { name: 'Montserrat', id: 'montserrat' }
    { name: 'OpenDyslexic', id: 'opendyslexic' }
    { name: 'Open Sans', id: 'opensans' }
    { name: 'PT Sans',id: 'pts' }
    { name: 'Tahoma', id: 'tahoma' }
    { name: 'Trebuchet MS', id: 'trebuc' }
    { name: 'Roboto',id: 'roboto' }
    { name: 'Ubuntu', id: 'ubuntu' }
    { name: 'Verdana', id: 'verdana' }
  ]

  vm.font_folders = 
    win32:  '/Windows/fonts'
    darwin: '/Library/Fonts'
    linux:  '/usr/share/fonts'

  vm.font_folder = path.resolve vm.font_folders[process.platform]

  files = []

  recursive = (dir) ->
    if fs.statSync(dir).isDirectory()
      fs.readdirSync(dir).forEach (name) ->
        newdir = path.join(dir, name)
        recursive newdir
        return
    else
      files.push dir
    return

  try
    recursive vm.font_folder
  catch e

  vm.avail_fonts = [ 'Arial' ]

  for i of vm.arr_fonts
    for key of files
      found = files[key].toLowerCase()
      toFind = vm.arr_fonts[i].id

      if found.indexOf(toFind) != -1
        vm.avail_fonts.push vm.arr_fonts[i].name
        break

  return
