'use strict'

angular.module 'app.common-directives'

.directive 'mdSearchAutocomplete', ($animateCss, $timeout, $q) ->
  controller: ->
  controllerAs: 'search'
  scope:
    searchText: '=?text'
    textChange: '&?textChange'
  bindToController: true
  template: '''
    <md-button class="md-icon-button" style="float: left" aria-label="Open Search" ng-click="searchIconClicked($event)">
      <md-icon style="font-size: 3em; color: white; height: 1em; width: 1em" md-font-set="material-icons">search</md-icon>
    </md-button>

    <md-input-container style="float: right; padding: 0px;" md-no-float flex>
      <input class="md-black-primary-default text" md-contrast md-style="{'border-color': 'black.primary'}" style="padding: 0px; line-height: 40px" type="search"
          ng-change="search.textChange()"
          ng-model="search.searchText"
          ng-blur="onBlur($event)"/>
    </md-input-container>'''
  link: (scope, element, attrs, ctrl) ->
    input = element.find 'input'
    inputContainer = element.find 'md-input-container'
    
    timeout = null

    animateElement = (toWidth) ->
      defer = $q.defer()
    
      if not timeout
        timeout = $timeout ->
          $animateCss inputContainer,
            from: width: inputContainer.prop 'clientWidth'
            to: width: toWidth
            easing: 'cubic-bezier(0.35, 0, 0.25, 1)'
            duration: 0.4
          .start().done -> 
            defer.resolve()
            timeout = null
        , 225, false
      else defer.reject()

      defer.promise

    scope.onBlur = ($event) -> 
      animateElement '0px'

    scope.searchIconClicked = ($event) ->  
      ctrl.searchText = null
      animateElement('240px').then ->
        input.focus()
      
      return

    inputContainer.css width: '0px'
