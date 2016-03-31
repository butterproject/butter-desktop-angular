'use strict'

angular.module 'app.about', []

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

      vm.releases = [
  {
    'name': "0.3.8 Beta - There's nothing on TV - 09 July 2015"
    'notes':
    "BugFixes:
    - Fullscreen consistent while playing
    - Multi-screen support
    - Windows 8.1 : the app doesn't go under the taskbar anymore
    - " & " in titles are now correctly handled
    - Local subtitles should now always load correctly
    - UI fixes
    - More descriptive error messages and logs
    - Fix 'Open the app in last-open tab'
    - Mac OS: fix mousewheel inverted
    - Mac OS: Menu support
    - Fix some issues with Keyboard navigation
    - Allow to hide the updater notification
    - Fix an issue corrupting cache if used on an external HDD
    - Improvements in subtitle encoding
    - Autoplay fixes
    - Trakt.tv is back!
    - Torrenting enhanced (finding more peers and better seeding)
    - Remote control (httpapi) fixes
    - Open TV Details 'jump to' fixed
    - More subtitles results for TV Series
    - Download progress in the player now works for single file taken out of multifile torrents
    - Images positionning in Movies & TV Series details
    - Anime: fixes an issue where series got no episodes & movies no links
    - Subtitles: most external torrents should be matched with subtitles now
    - Arabic fonts (aljazeera & khalid art) can now be used to correctly display arabic subtitles
    - Fix most issues with remotes.
    - Fix the Popcorn Time player when watching trailers.

    New Features:

    - Node Webkit 12.1 (now known as nw.js)
    - Cancel 'Play Next Episode'
    - Select your subtitles Font, and/or add a solid background to them.
    - New subtitles for: Norwegian, Vietnamese
    - Report bugs & issues from within the app (open the 'About' page)
    - Mark as seen/unseen in Movie Details screen
    - No more ads from Youtube
    - Stream subtitles with DLNA/UPnP
    - Search Strike or KickassTorrents (torrent portals) and save some torrents for later
    - Allow SSA/ASS subtitles, along with TXT (mostly Chinese & Polish - needs testing)
    - The app will now remember: last chosen quality, player, subtitles position, volume
    - Mark an entire TV Series as watched
    - Choose the application install directory (provided that it doesn't need admin rights)
    - Play local video files in PT Player (mp4, avi, mov, mkv)
    - Windows: launcher allowing to use PT as default for torrents/magnets/video files
    - Support for multimedia keys
    - Launch external players in Fullscreen
    - Minimize to tray
    - Translated synopsis (overview) for TV Series & Movies
    - Calculation of the P2P exchange ratio of the entire app traffic
    - FakeSkan (bitsnoop) will now warn you if an external torrent was flagged as 'fake'
    - 'Randomize' button allowing to open a random movie
    - Start Popcorn Time minimized with ''-m' flag
    - 1080p TV Shows are here !
    - 'Big Picture Mode' will allow you to read Popcorn Time's texts from your couch
    - TVShow Time integration
    - Display a warning if the HDD is almost full
    - Sort by 'Trending' on movies & tv shows
    - Correctly display the sizes for your OS and language (ex: 32.5MiB in Linux English, 32.5Mo on Windows Spanish, 34.1MB in OSX English)'
  }
  {
    'name': '0.3.7 Beta - The Car Won't Start - 15 January 2015'
    'notes': '
    BugFixes:

    - Fall back to Sequential ID when AirPlay devices do not respond to ServerInfo queries
    - Rebuild the new built-in VPN Client
    - Renamed "External" to "ExtPlayer" to avoid confusion with non-local devices
    - Fix the movie cover resizing code and garbage collect the cache to ensure old metadata isn't used
    - Greatly improves the built-in DLNA detection
    - Fix retina display for Ultra HD screens
    - Properly hide the spinner in cases where an error occurs
    - Always show the FileSelector if TorrentCol is active. Fixes PT-1575
    - Fix subtitle error handling in the streamer
    - Prevent the app from getting stuck on "Waiting for Subtitles" if subtitle discovery fails
    - Fix the HTTP API / Remote API
    - Improved IP-Detection for all external devices. Fixes PT-1440
    - Fix the issue where the Ukrainian flag was displayed instead of the Armenian flag
    - Fixed TV Show covers not showing up due to Trakt shutting down Slurm Image Server

    New Features:

    - Calculate the remaining time before stream download completion
    - Added a 'Magnet' icon in the details pane to allow copying of the magnet link
    - Added the ability to save the .torrent files and magnet links in-app for later'
  }
  {
    'name': '0.3.6 Beta - The Christmas Tree Is Up  - 25 December 2014'
    'notes': 'Bugfixes:

    - Changed encoding of VTT Subtitles file to UTF-8. Fixes playback of all subtitle languages on external devices.
    - Fixed the bug where streams played on the wrong device when you have multiple AirPlay devices
    - Temporarily Fixed IP address in Media URL for external devices
    - Reworked the updater to use our DNS servers so it continues to work even with issues
    - Automatically close the player on Chromecast when media playback has finished
    - Fixed the Chromecast reconnection issue when stopping and starting a new session
    - Made further fixes to the 'Waiting for Subtitles' bug
    - Reworked and fixed multiple issues with Chromecast Status-Updater
    - Updated the Chromecast module to use a refactored Chromecast-js
    - Added in a BitTorrent PeerID specific to Popcorn Time
    - Fixed problems with Watchtrailer, should fix issue PT-1333
    - Various other minor bugfixes

    New Features:

    - Torrent Health now automatically updates
    - Added an option to disable updates
    - Added a built in OpenVPN client
    - Small event's celebration
    - Added a 'download progress' status
    "
  }
    {
      'name': '0.3.6 Beta - The Christmas Tree Is Up  - 25 December 2014'
      'notes': "Bugfixes:

      - Changed encoding of VTT Subtitles file to UTF-8. Fixes playback of all subtitle languages on external devices.
      - Fixed the bug where streams played on the wrong device when you have multiple AirPlay devices
      - Temporarily Fixed IP address in Media URL for external devices
      - Reworked the updater to use our DNS servers so it continues to work even with issues
      - Automatically close the player on Chromecast when media playback has finished
      - Fixed the Chromecast reconnection issue when stopping and starting a new session
      - Made further fixes to the 'Waiting for Subtitles' bug
      - Reworked and fixed multiple issues with Chromecast Status-Updater
      - Updated the Chromecast module to use a refactored Chromecast-js
      - Added in a BitTorrent PeerID specific to Popcorn Time
      - Fixed problems with Watchtrailer, should fix issue PT-1333
      - Various other minor bugfixes

      New Features:

      - Torrent Health now automatically updates
      - Added an option to disable updates
      - Added a built in OpenVPN client
      - Small event's celebration
      - Added a 'download progress' status
      "
    }
      {
        'name': "0.3.5 Beta - We're Snowden In - 09 november 2014"
        'notes': "Bugfixes:

      - Automatically sync Trakt on start
      - New search bar
      - Custom color for subtitles
      - New window's width/height calculation
      - New official theme: 'FlaX'
      - PNG's optimization
      - You can now choose your player with external torrents/magnets

      - Fixed invalid Certificate Fingerprints in the app not verifying causing requests to fail
      - Caught when the 'Theme' var in Database didn't exist upon upgrading
      - Fixed movies not loading because Trakt started replying with 404s
      - Fixing bookmarks that don't work on the list page for TV Shows and Anime
      - Remove 'Blown up' look for Retina but leave it in place for QFHD due to it's size
      - Fixed the updater for Popcorn Time in linux
        "
      }
        {
          'name': "0.3.4 Beta - It's Cold Outside - 06 october 2014"
          'notes': "Bugfixes:

      After the introduction of the Remote Control API on 0.3.3,
      these remotes have been created by our awesome users go grab the one you
      like best at http://discuss.popcorntime.io/t/list-of-popcorn-time-remote-controls/2044

      - Now comes with release names
      - More resiliant to APIs falling down
      - HiDPI support, scales properly on 1080p, 2k/Retina and 4k/QHD screens.
      - Update vectorial 'about' view.
      - New watchlist view, automatically synced to trakt.
      - Better caching of network calls, makes the app more snappy.
      - [TV] Auto-Play next episode.
      - New themes infrastructure allows for easier integration with community
        themes.
      - New translation infrastructure allows for easier integration with community
        translations.
      - A lot of bugfixes and under-the-hood changes.
      - All dependencies have been updated.
      - [ALPHA] Anime Tab, thanks to the haruhichan people!
      - [ALPHA] ChromeCast now supports subtitles and cover images.
              "
        }
]

  return
