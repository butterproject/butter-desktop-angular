angular.module 'app.gsTimelines'

.controller 'RevealController', ($scope, catalog, $timeline, $timeout, $q, $log) ->
  showDetails = (album) ->
    request = promiseToNotify 'zoom', 'complete.'
    
    $timeline 'zoom',
      onUpdate: makeNotify 'zoom', 'updating...'
      onComplete: request.notify

    $scope.state = 'zoom'
    $scope.album = album
    
    request.promise

  hideDetails = ->
    $timeline 'zoom',
      onUpdate: makeNotify 'zoom', 'reversing...'
      onReverseComplete: makeNotify 'zoom', 'reversed.'
      
    $scope.state = ''

  promiseToNotify = (direction, action) ->
    deferred = $q.defer()

    promise: deferred.promise
    notify: (tl) ->
      $log.debug "tl(#{ direction })(#{ action } or 'finished')"
      
      deferred.resolve tl

  makeNotify = (direction, action) ->
    (tl) ->
      $log.debug "tl(#{ direction })(#{ action } or 'finished')"
      
  wait = (delay, value) ->
    deferred = $q.defer()
    
    $timeout ->
      deferred.resolve value or true
    , delay, false
    
    deferred.promise

  $scope.catalog = catalog
  $scope.album = catalog[0]

  $scope.showDetails = showDetails
  $scope.hideDetails = hideDetails
  
  wait 1200
    .then ->
      showDetails $scope.album
    .then ->
      wait 300
    .then hideDetails
    
  return

.constant 'catalog', [
  {
    className: 'pharrell'
    
    aria:
      artist: 'Pharrell Williams'
      album: 'GIRL'
    
    from:
      left: 517
      top: 303
      width: 338
      height: 299
    
    to:
      left: 106
      top: 229
      width: 641
      height: 547
    
    switchOver:
      width: 242
      height: 243
      top: 240
      left: 320
      
    playlist: 'http://solutionoptimist-bucket.s3.amazonaws.com/kodaline/pharrell/playlist.png'
  }
]