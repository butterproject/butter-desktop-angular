'use strict'

angular.module 'app.containers'

.directive 'ratingContainer', ->
  restrict: 'A'
  scope: { rating: '=' }
  bindToController: true
  templateUrl: 'containers/rating/rating-container.html'
  controller: 'ratingCtrl as rating'

.controller 'ratingCtrl', ->
  vm = this

  # vm.rating.percentage is actually a value [1..10]
  vm.rounded = Math.round(vm.rating.percentage) / 2

  vm.stars = [1..5].map (i) ->
    if i > vm.rounded then (if vm.rounded % 1 > 0 and Math.ceil(vm.rounded) is i then 'star_half' else 'star_border') else 'star'

  return
