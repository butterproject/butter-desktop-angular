'use strict'

angular.module 'app.common-directives'

.directive 'ptPanel', ($compile, $timeout, $templateCache, $controller, $rootScope) ->
  restrict: 'E'
  transclude: true
  template: '''
    <pt-header></pt-header>

    <pt-sidebar class="md-black-primary-default background">
      <nav>
        <md-button id="nav-{{ pane.ctrl }}" layout="row" ng-repeat="(name, pane) in ::ctrl.panes" ng-click="ctrl.select(pane)" ng-class="{ selected: pane.selected }">
          <md-icon class="md-black-primary-default text" md-font-set="material-icons">{{ :: pane.icon }}</md-icon>
          <span flex>{{ :: pane.title }}</span>
        </md-button>
      </nav>
    </pt-sidebar>

    <div ng-transclude></div>'''
  controllerAs: 'ctrl'
  controller: ($element, $scope, $timeout) ->
    vm = this

    vm.panes = {}
    vm.templates = {}

    vm.currentPane = null
    vm.lastPane = null

    vm.select = (pane) ->
      if vm.currentPane
        element = vm.currentPane.element         
        element.css 'display', 'none'

        vm.currentPane.selected = false 
        vm.lastPane = vm.currentPane

      pane.selected = true
      vm.currentPane = pane

      element = pane.element 
      element.css 'display', 'block'

      return

    timeout = null

    vm.addPane = (pane) -> 
      if pane.selected is 'true'
        vm.currentPane = pane

      if timeout 
        $timeout.cancel 

      timeout = $timeout ->
        $scope.loaded = true
      , 2000

      vm.panes[pane.title] = pane

      if not vm.templates[pane.title]
        paneElement = angular.element '<pt-content pt-lazy-container="' + pane.title + '" pt-lazy-scroll style="overflow: auto; display: none;"></pt-content>'
        paneElement.append $templateCache.get pane.src      

        vm.templates[pane.src] = $compile paneElement

      templateScope = $rootScope.$new()
      templateScope.type = pane.title 

      templateCtrl = $controller(pane.ctrl + 'Controller as ' + pane.ctrl, $scope: templateScope)

      vm.templates[pane.src] templateScope, (clone) -> 
        clone.data '$ngControllerController', templateCtrl

        vm.panes[pane.title].element = clone

        $element.append clone

        if pane.selected is 'true' 
          clone.css 'display', 'block'
        else clone.css 'display', 'none'

      return
    return

.directive 'ptPane', ($parse) ->
  require: '^ptPanel'
  restrict: 'E'
  scope: { }
  link: (scope, element, attrs, panelCtrl) ->
    panelCtrl.addPane attrs
