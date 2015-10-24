'use strict'

angular.module 'app.containers'

.directive 'ptMetaContainer', ->
  restrict: 'E'
  scope: { show: '=' }
  templateUrl: 'containers/meta/meta-container.html'
