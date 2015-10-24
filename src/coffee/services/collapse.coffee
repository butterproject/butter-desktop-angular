angular.module 'app.services'

.factory '$mdCollapse', ($animateCss) ->

  expand: (element) ->

    expandDone = ->
      element
        .removeClass 'collapsing'
        .addClass 'collapse'
        .css height: 'auto'

      return

    element
      .removeClass 'collapse'
      .addClass 'collapsing'
      .attr 'aria-expanded', true
      .attr 'aria-hidden', false

    $animateCss element,
      addClass: 'in'
      easing: 'ease'
      to: height: element[0].scrollHeight + 'px'
    .start()
    .done expandDone

    return

  collapse: (element) ->

    collapseDone = ->
      element
        .css height: '0'
        .removeClass 'collapsing'
        .addClass 'collapse'

      return
    
    element
      .css height: element[0].scrollHeight + 'px'
      .removeClass 'collapse'
      .addClass 'collapsing'
      .attr 'aria-expanded', false
      .attr 'aria-hidden', true

    $animateCss element,
      removeClass: 'in'
      to: height: '0px'
    .start()
    .done collapseDone

    return 
