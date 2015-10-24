angular.module 'app.services'

.provider '$mdColors', ($mdColorPalette) ->
  style = angular.element '<style></style>'

  document.head.appendChild style[0]
  
  stylesheet = style[0].sheet
  index = 0 
 
  colorToRgbaArray = (clr) ->
    if angular.isArray(clr) and clr.length == 3
      return clr
    
    if /^rgb/.test(clr)
      return clr.replace(/(^\s*rgba?\(|\)\s*$)/g, '').split(',').map (value, i) ->
        if i == 3 then parseFloat(value, 10) else parseInt(value, 10)
    
    if clr.charAt(0) == '#'
      clr = clr.substring(1)
    
    if !/^([a-fA-F0-9]{3}){1,2}$/g.test(clr)
      return
     
    dig = clr.length / 3
    
    red = clr.substr(0, dig)
    grn = clr.substr(dig, dig)
    blu = clr.substr(dig * 2)
    
    if dig == 1
      red += red
      grn += grn
      blu += blu
    
    [ parseInt(red, 16), parseInt(grn, 16), parseInt(blu, 16) ]  

  DARK_CONTRAST_COLOR = colorToRgbaArray 'rgba(0,0,0,0.87)'
  LIGHT_CONTRAST_COLOR = colorToRgbaArray 'rgba(255,255,255,0.87'
  STRONG_LIGHT_CONTRAST_COLOR = colorToRgbaArray 'rgb(255,255,255)'

  addCustomStyle = (cssname, name, color, contrast = '') ->
    if contrast
      contrast = "color: #{contrast}"

    stylesheet.insertRule ".md-#{cssname}-#{name}.text { #{contrast} !important }", index
    stylesheet.insertRule ".md-#{cssname}-#{name}.background { background-color: #{color}; #{contrast} }", index + 1

    index += 2

    return

  clearStyleSheet = ->
    while stylesheet.cssRules.length > 0
      stylesheet.deleteRule 0

  colorNames: []
  colorStore: {}

  colorSelected: null

  themeNames: []
  themeStore: {}

  getContrastColor: (palette, hueName) ->

    { contrastDefaultColor, contrastLightColors, contrastStrongLightColors, contrastDarkColors } = palette

    if angular.isString contrastLightColors
      contrastLightColors = contrastLightColors.split ' '
    
    if angular.isString contrastStrongLightColors
      contrastStrongLightColors = contrastStrongLightColors.split ' '
    
    if angular.isString contrastDarkColors
      contrastDarkColors = contrastDarkColors.split ' '

    if contrastDefaultColor is 'light'
      if contrastDarkColors?.indexOf(hueName) > -1
        DARK_CONTRAST_COLOR
      else
        if contrastStrongLightColors?.indexOf(hueName) > -1 
          STRONG_LIGHT_CONTRAST_COLOR 
        else 
          LIGHT_CONTRAST_COLOR
    else
      if contrastLightColors?.indexOf(hueName) > -1
        if contrastStrongLightColors?.indexOf(hueName) > -1
          STRONG_LIGHT_CONTRAST_COLOR 
        else 
          LIGHT_CONTRAST_COLOR
      else
        DARK_CONTRAST_COLOR

  storeAndLoadPalettes: (colors, themes, primaryPalette) ->
    @colorStore = colors
    @themeStore = themes

    @colorNames = Object.keys colors 
    @themeNames = Object.keys themes

    @loadPalette primaryPalette

  loadPalette: (newPalette) ->
    if @colorSelected
      clearStyleSheet()

    @colorSelected = newPalette

    for name, color of @colorStore[newPalette]
      addCustomStyle 'fg', name, color.value, color.contrast
      addCustomStyle 'bg', name, color.value, color.contrast

    for themeName, theme of @themeStore
      cleanedThemeName = if themeName is 'default' then '' else themeName + '-' 
      
      for groupName, group of theme 
        for name, color of group 
          addCustomStyle cleanedThemeName + groupName, name, color.value, color.contrast

    return

  $get: ->
    colorNames: @colorNames
    colorStore: @colorStore
    
    colorSelected: @colorSelected

    themeNames: @themeNames
    themeStore: @themeStore
      
    loadPalette: @loadPalette
 
.config ($mdThemingProvider, $mdColorsProvider) ->
  $mdThemingProvider.definePalette 'white',
    50: '#ffffff'
    100: '#ffffff'
    200: '#ffffff'
    300: '#ffffff'
    400: '#ffffff'
    500: '#ffffff'
    600: '#ffffff'
    700: '#ffffff'
    800: '#ffffff'
    900: '#ffffff'
    A100: '#ffffff'
    A200: '#ffffff'
    A400: '#ffffff'
    A700: '#ffffff'
    contrastDefaultColor: 'dark'

  $mdThemingProvider.definePalette 'dark',
    50: '#e8e8e9'
    100: '#babbbc'
    200: '#8c8e90'
    300: '#65686b'
    400: '#3e4346'
    500: '#181d21'
    600: '#15191d'
    700: '#121619'
    800: '#0f1215'
    900: '#0c0f11'
    A100: '#babbbc'
    A200: '#8c8e90'
    A400: '#3e4346'
    A700: '#050607'
    contrastDefaultColor: 'light'
    contrastDarkColors: '50 100 200'
    contrastStrongLightColors: ' 500 600 300'
    contrastLightColors: '700 800 900 A100 A200 A400'

  $mdThemingProvider.theme 'black'
    .primaryPalette 'dark', default: '900' 
    .dark()

  $mdThemingProvider
    .theme 'default' 
    .primaryPalette 'white', default: '900' 
    .backgroundPalette 'dark', default: '700' 
    .dark()

  colorStore = {}

  parsePalette = (paletteName, palette) ->
    paletteContrast = palette 
    hueColors = $mdThemingProvider._THEMES['default'].colors['primary'].hues

    colors = {}

    addHue = (hueName) ->
      contrastColor = $mdThemingProvider._rgba $mdColorsProvider.getContrastColor(palette, hueColors[hueName])
      colors[hueName] = value: palette[hueColors[hueName]], contrast: contrastColor

    copyColors = (colorName) ->
      if /#([0-9A-Fa-f]{3}|[0-9A-Fa-f]{6})\b/.test(palette[colorName])
        contrastColor = $mdThemingProvider._rgba $mdColorsProvider.getContrastColor(palette, colorName)
        colors[colorName] = value: palette[colorName], contrast: contrastColor
      return

    colorStore[paletteName] = colors
    
    Object.keys(palette).forEach copyColors
    Object.keys(hueColors).forEach addHue
    
    return
  
  for paletteName, palette of $mdThemingProvider._PALETTES
    parsePalette paletteName, palette

  themeStore = {}

  parseTheme = (themeName) ->
    themeColorGroups = $mdThemingProvider._THEMES[themeName].colors
    
    colors = {}

    defineColors = (themeGroup) ->
      themeStore[themeName][themeGroup] ?= {}

      definedColors = colorStore[themeColorGroups[themeGroup].name]

      for item, value of themeColorGroups[themeGroup].hues
        themeStore[themeName][themeGroup][item] = definedColors[value]

      return

    themeStore[themeName] ?= {}

    Object.keys(themeColorGroups).forEach defineColors
    
    return

  Object.keys($mdThemingProvider._THEMES).forEach parseTheme

  primaryPalette = $mdThemingProvider._THEMES['default'].colors.primary.name
  
  $mdColorsProvider.storeAndLoadPalettes colorStore, themeStore, primaryPalette

  return

.directive 'mdStyle', ($mdColors, $parse) ->
  restrict: 'A'
  link: (scope, element, attrs) ->
    { colorSelected, colorStore, colorNames, themeStore, themeNames } = $mdColors

    parsedStyles = $parse attrs.mdStyle
    styles = parsedStyles()

    for cssName, cssValue of styles
      [color, hue, hue2] = cssValue.split '.'

      if color in ['primary', 'accent', 'background', 'foreground', 'warn']
        color = themeStore['default'][color]
      else if color not in colorNames
        color = colorSelected

        if themeStore[color]
          color = themeStore[color]

          if hue2 
            color = color[hue][hue2]
          else 
            color = color[hue]['default']

      color = colorStore[color] or color
      colorObject = color[hue] or color.default

      if colorObject 
        if cssName is 'background-color'
          element.css 'color', colorObject.contrast

        if angular.isString attrs.mdContrast
          element.css cssName, colorObject.contrast
        else 
          element.css cssName, colorObject.value
