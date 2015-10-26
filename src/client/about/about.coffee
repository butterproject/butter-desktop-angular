'use strict'

angular.module 'app.about', []

.directive 'ptAbout', ->
  bindToController: true
  templateUrl: 'about/about.html'
  controller: 'aboutController as about'

.controller 'aboutController', (AdvSettings) ->
  vm = this

  vm.name = AdvSettings.get('branding').name

  vm.social_buttons =
    'website':
      'url': 'http://butterproject.org'
      'label': 'Butter Website'
    'blog':
      'url': 'http://blog.butterproject.org'
      'label': 'Butter Blog'
    'discuss':
      'url': 'http://discuss.butterproject.org'
      'label': 'Butter Forum'
    'facebook':
      'url': 'http://www.fb.com/ButterProjectOrg'
      'label': 'Butter Facebook'
    'twitter':
      'url': 'http://twitter.com/butterproject'
      'label': 'Butter Twitter'
    'google-plus':
      'url': 'https://plus.google.com/communities/111003619134556931561'
      'label': 'Butter Google+'
    'github':
      'url': 'https://github.com/butterproject/butter'
      'label': 'Butter GitHub'


