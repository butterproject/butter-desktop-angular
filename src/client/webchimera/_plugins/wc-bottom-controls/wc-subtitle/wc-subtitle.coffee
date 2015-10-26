'use strict'

angular.module 'app.webchimera.plugins.controls'

.directive 'wcSubtitle', ->
  restrict: 'E'
  scope: { subtitles: '=', currentSubtitle: '=' }
  require: '^chimerangular'
  template: '''
    <button class="iconButton" ng-click="onClick()" aria-label='Closed Caption' type='button'>
      <md-icon md-font-set="material-icons">closed_caption</md-icon>
    </button>
    <wc-subtitle-selector></<wc-subtitle-selector>'''
  link: (scope, elem, attr, chimera) ->

    scope.onClick = ->
      scope.$evalAsync ->
        scope.subtitleVisibility = 'visible'
        return
      return

    onMouseLeaveSubtitle = ->
      scope.$evalAsync ->
        scope.subtitleVisibility = 'hidden'
        return
      return

    scope.subtitleVisibility = 'hidden'

    elem.bind 'mouseleave', onMouseLeaveSubtitle

.directive 'wcSubtitleSelector', ->
  restrict: 'E'
  require: '^chimerangular'
  template: '''
    <ul>
      <li ng-repeat="subtitle in subtitles" ng-class="{ 'active': currentSubtitle.name === subtitle.name }" ng-click="changeSubtitle(subtitle)">
        {{ subtitle.name }}
      </li>
    </ul>'''
  link: (scope, elem, attr, chimera) ->

    scope.changeSubtitle = (subtitle) ->
      scope.currentSubtitle = subtitle
      scope.subtitleVisibility = 'hidden'
      chimera.wcjsElement.playlist.add $sce.trustAsResourceUrl(subtitle.url)
      return

    onChangeVisibility = (value) ->
      elem.css 'visibility', value
      return

    scope.$watch 'subtitleVisibility', onChangeVisibility

    return
