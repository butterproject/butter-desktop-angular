'use strict'

angular.module 'app.webchimera.plugins.imaads', []

.directive 'wcImaAds', ($window, WC_STATES) ->
  restrict: 'E'
  require: '^chimerangular'
  scope:
    wcNetwork: '=?'
    wcUnitPath: '=?'
    wcCompanion: '=?'
    wcCompanionSize: '=?'
    wcAdTagUrl: '=?'
    wcSkipButton: '=?'
  link: (scope, elem, attr, chimera) ->
    adDisplayContainer = new (google.ima.AdDisplayContainer)(elem[0])
    adsLoader = new (google.ima.AdsLoader)(adDisplayContainer)
    
    adsManager = null
    adsLoaded = false
    
    w = undefined
    h = undefined

    onContentEnded = ->
      adsLoader.contentComplete()

    currentAd = 0
    skipButton = angular.element(scope.wcSkipButton)
    scope.chimera = chimera

    scope.onPlayerReady = (isReady) ->
      if isReady
        chimera.wcjsElement.events.on 'ended', onContentEnded
        adsLoader.addEventListener google.ima.AdsManagerLoadedEvent.Type.ADS_MANAGER_LOADED, scope.onAdsManagerLoaded, false, this
        adsLoader.addEventListener google.ima.AdErrorEvent.Type.AD_ERROR, scope.onAdError, false, this
        scope.loadAds()

    scope.onUpdateAds = (newVal, oldVal) ->
      if newVal != oldVal
        scope.loadAds()
        chimera.pause()
        adDisplayContainer.initialize()
        scope.requestAds scope.wcAdTagUrl

    scope.loadAds = ->
      if scope.wcCompanion
        googletag.cmd.push ->
          googletag.defineSlot('/' + scope.wcNetwork + '/' + scope.wcUnitPath, scope.wcCompanionSize, scope.wcCompanion).addService(googletag.companionAds()).addService googletag.pubads()
          googletag.companionAds().setRefreshUnfilledSlots true
          googletag.pubads().enableVideoAds()
          googletag.enableServices()

    scope.onUpdateState = (newState) ->
      switch newState
        when WC_STATES.PLAY
          if !adsLoaded
            chimera.pause()
            adDisplayContainer.initialize()
            scope.requestAds scope.wcAdTagUrl
            adsLoaded = true
        when WC_STATES.STOP
          adsLoader.contentComplete()

    scope.requestAds = (adTagUrl) ->
      # Show only to get computed style in pixels
      scope.show()

      adsRequest = new (google.ima.AdsRequest)
      computedStyle = $window.getComputedStyle(elem[0])
      
      adsRequest.adTagUrl = adTagUrl
      adsRequest.linearAdSlotWidth = parseInt(computedStyle.width, 10)
      adsRequest.linearAdSlotHeight = parseInt(computedStyle.height, 10)
      adsRequest.nonLinearAdSlotWidth = parseInt(computedStyle.width, 10)
      adsRequest.nonLinearAdSlotHeight = parseInt(computedStyle.height, 10)
      
      adsLoader.requestAds adsRequest
      return

    scope.onAdsManagerLoaded = (adsManagerLoadedEvent) ->
      scope.show()
      adsManager = adsManagerLoadedEvent.getAdsManager(chimera.wcjsElement[0])
      scope.processAdsManager adsManager
      return

    scope.processAdsManager = (adsManager) ->
      w = chimera.chimerangularElement[0].offsetWidth
      h = chimera.chimerangularElement[0].offsetHeight
      
      # Attach the pause/resume events.
      adsManager.addEventListener google.ima.AdEvent.Type.CONTENT_PAUSE_REQUESTED, scope.onContentPauseRequested, false, this
      adsManager.addEventListener google.ima.AdEvent.Type.CONTENT_RESUME_REQUESTED, scope.onContentResumeRequested, false, this
      adsManager.addEventListener google.ima.AdEvent.Type.SKIPPABLE_STATE_CHANGED, scope.onSkippableStateChanged, false, this
      adsManager.addEventListener google.ima.AdEvent.Type.ALL_ADS_COMPLETED, scope.onAllAdsComplete, false, this
      adsManager.addEventListener google.ima.AdEvent.Type.COMPLETE, scope.onAdComplete, false, this
      adsManager.addEventListener google.ima.AdErrorEvent.Type.AD_ERROR, scope.onAdError, false, this
      adsManager.init w, h, google.ima.ViewMode.NORMAL
      adsManager.start()

    scope.onSkippableStateChanged = ->
      isSkippable = adsManager.getAdSkippableState()
      
      if isSkippable
        skipButton.css 'display', 'block'
      else skipButton.css 'display', 'none'

    scope.onClickSkip = ->
      adsManager.skip()

    scope.onContentPauseRequested = ->
      scope.show()
      chimera.wcjsElement.events.on 'ended', onContentEnded
      chimera.pause()

    scope.onContentResumeRequested = ->
      cchimera.wcjsElement.events.on 'ended', onContentEnded
      chimera.play()
      scope.hide()

    scope.onAdError = ->
      if adsManager
        adsManager.destroy()
      
      scope.hide()
      chimera.play()

    scope.onAllAdsComplete = ->
      scope.hide()
      
      # The last ad was a post-roll
      if adsManager.getCuePoints().join().indexOf('-1') >= 0
        chimera.stop()

    scope.onAdComplete = ->
      # TODO: Update view with current ad count
      currentAd++

    scope.show = ->
      elem.css 'display', 'block'
      return

    scope.hide = ->
      elem.css 'display', 'none'
      return

    skipButton.bind 'click', scope.onClickSkip
    elem.prepend skipButton
    
    angular.element($window).bind 'resize', ->
      w = chimera.chimerangularElement[0].offsetWidth
      h = chimera.chimerangularElement[0].offsetHeight
      
      if adsManager
        if chimera.isFullScreen
          adsManager.resize w, h, google.ima.ViewMode.FULLSCREEN
        else adsManager.resize w, h, google.ima.ViewMode.NORMAL

    if chimera.isConfig
      scope.$watch 'chimera.config', ->
        if scope.chimera.config
          scope.wcNetwork = scope.chimera.config.plugins['ima-ads'].network
          scope.wcUnitPath = scope.chimera.config.plugins['ima-ads'].unitPath
          scope.wcCompanion = scope.chimera.config.plugins['ima-ads'].companion
          scope.wcCompanionSize = scope.chimera.config.plugins['ima-ads'].companionSize
          scope.wcAdTagUrl = scope.chimera.config.plugins['ima-ads'].adTagUrl
          scope.wcSkipButton = scope.chimera.config.plugins['ima-ads'].skipButton
          scope.onPlayerReady true
    else
      scope.$watch 'wcAdTagUrl', scope.onUpdateAds.bind(scope)
    
    scope.$watch ->
      chimera.isReady
    , (newVal, oldVal) ->
      if chimera.isReady == true or newVal != oldVal
        scope.onPlayerReady newVal

    scope.$watch ->
      chimera.currentState
    , (newVal, oldVal) ->
      if newVal != oldVal
        scope.onUpdateState newVal
