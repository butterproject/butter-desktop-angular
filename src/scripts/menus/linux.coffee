{ name, version } = require '../../package.json'

module.exports = [
  {
    label: '&File'
    submenu: [
      { label: '&Settings', command: 'application:show-settings' }
      { label: '&Quit', accelerator: 'Ctrl+Q', command: 'application:quit' }
    ]
  }

  {
    label: '&View'
    submenu: [
      { label: '&Reload', accelerator: 'Ctrl+R', command: 'window:reload' }
      { label: 'Toggle &Full Screen', accelerator: 'F11', command: 'window:toggle-full-screen' }
      { label: 'Toggle &Developer Tools', accelerator: 'Alt+Ctrl+I', command: 'window:toggle-dev-tools' }
    ]
  }

  {
    label: '&Help'
    submenu: [
      { label: 'Version ' + version, enabled: false }
      { label: 'Check for Update', command: 'application:check-for-update' }
      { type: 'separator' }
      { label: '&Report Issue', command: 'application:open-url', url: 'https://git.popcorntime.io/popcorntime/desktop/issues' }
      { label: '&Suggest Feature', command: 'application:open-url', url: 'https://git.popcorntime.io/popcorntime/desktop/issues' }
    ]
  }
]
