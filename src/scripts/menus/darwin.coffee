{ name, version } = require '../../package.json'

module.exports = [
  {
    label: name
    submenu: [
      { label: 'About ' + name, selector: 'orderFrontStandardAboutPanel:' }
      { label: 'Version ' + version, enabled: false }
      { label: 'Check for Update', command: 'application:check-for-update' }
      { type: 'separator' }
      { label: 'Preferences...', command: 'application:show-settings' }
      { label: 'Services', submenu: [] }
      { type: 'separator' }
      { label: 'Hide ' + name, accelerator: 'Command+H', selector: 'hide:' }
      { label: 'Hide Others', accelerator: 'Command+Shift+H', selector: 'hideOtherApplications:' }
      { label: 'Show All', selector: 'unhideAllApplications:' }
      { type: 'separator' }
      { label: 'Quit', accelerator: 'Command+Q', command: 'application:quit' }
    ]
  }

  {
    label: 'Edit'
    submenu: [
      { label: 'Undo', accelerator: 'Command+Z', selector: 'undo:' }
      { label: 'Redo', accelerator: 'Shift+Command+Z', selector: 'redo:' }
      { type: 'separator' }
      { label: 'Cut', accelerator: 'Command+X', selector: 'cut:' }
      { label: 'Copy', accelerator: 'Command+C', selector: 'copy:' }
      { label: 'Paste', accelerator: 'Command+V', selector: 'paste:' }
      { label: 'Select All', accelerator: 'Command+A', selector: 'selectAll:' }
    ]
  }

  {
    label: 'View'
    submenu: [
      { label: 'Reload', accelerator: 'Command+R', command: 'window:reload' }
      { label: 'Toggle Full Screen', accelerator: 'Ctrl+Command+F', command: 'window:toggle-full-screen' }
      { label: 'Toggle Developer Tools', accelerator: 'Alt+Command+I', command: 'window:toggle-dev-tools' }
    ]
  }

  {
    label: 'Window'
    submenu: [
      { label: 'Minimize', accelerator: 'Command+M', selector: 'performMiniaturize:' }
      { label: 'Zoom', accelerator: 'Alt+Command+Ctrl+M', selector: 'zoom:' }
      { type: 'separator' }
      { label: 'Close', accelerator: 'Command+W', selector: 'performClose:' }
    ]
  }

  {
    label: 'Help'
    submenu: [
      { label: 'Report Issue', command: 'application:open-url', url: 'https://git.popcorntime.io/popcorntime/desktop/issues' }
      { label: 'Suggest Feature', command: 'application:open-url', url: 'https://git.popcorntime.io/popcorntime/desktop/issues' }
    ]
  }
]
