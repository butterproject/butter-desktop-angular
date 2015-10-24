'use strict'

angular.module 'app.about', []

.controller 'aboutController', (AdvSettings) ->
        vm = this

        vm.name = AdvSettings.get('branding').name
