'use strict'

angular.module 'app.containers'

.directive 'ptPeopleContainer', ->
  restrict: 'E'
  scope: { people: '=' }
  templateUrl: 'containers/people/people-container.html'
