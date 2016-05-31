'use strict'

angular.module 'app.about', []

.controller 'aboutController', (AdvSettings) ->
  vm = this

  vm.name = AdvSettings.get('branding').name

# Social Links and Buttons
  vm.social_buttons =
    'website':
      'url': 'http://butterproject.org'
      'label': 'Butter Website'
    'blog':
      'url': 'http://blog.butterproject.org'
      'label': 'Butter Blog'
    'discuss':
      'url': 'https://www.reddit.com/r/ButterProject'
      'label': 'Butter Forum'
    'facebook':
      'url': 'https://www.facebook.com/ButterProjectOrg'
      'label': 'Butter Facebook'
    'twitter':
      'url': 'https://twitter.com/butterproject'
      'label': 'Butter Twitter'
    'google-plus':
      'url': 'https://plus.google.com/communities/111003619134556931561'
      'label': 'Butter Google+'
    'github':
      'url': 'https://github.com/butterproject/butter'
      'label': 'Butter GitHub'

.controller 'changelogController', ($scope, $http) ->
  $http.get('../../CHANGELOG.md').then ((response) ->
    $scope.content = response.data
    return
  ), (response) ->
    $scope.content = 'No Changelog file found!'
    return

  return
