'use strict'

angular.module 'app.services'

.config ($httpProvider) ->
  $httpProvider.interceptors.push 'xmlHttpInterceptor'

.factory 'xmlHttpInterceptor', ($q, xmlFilter) ->
  response: (data) ->
    if data 
      data.xml = xmlFilter(data.data)
      data
    else $q.when data

.factory 'xmlParser', ($window) ->

    ActiveXObject = ->
      @parser = new ($window.ActiveXObject)('Microsoft.XMLDOM')
      return

    ActiveXObject::parse = (data) ->
      @parser.async = false
      @parser.loadXml data

    DOMParser = ->
      @parser = new ($window.DOMParser)
      return

    DOMParser::parse = (data) ->
      @parser.parseFromString data, 'text/xml'

    if $window.DOMParser
      return new DOMParser

    if $window.ActiveXObject
      return new ActiveXObject
    
    throw Error 'Cannot parser XML in this environment.'

  .filter 'xml', (xmlParser) ->
    (input) ->
      parsedInput = xmlParser.parse input
      angular.element parsedInput
