fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name        'cx-hud'
author      'Cxsper'
description 'this is a hud i guess'
version     '1.2.6'

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/vehicle.css',
    'html/menu.css',
    'html/app.js',
    'html/logo.js',
    'html/logo-animation-transparent.png',
    'html/vehicle.js',
    'html/hud-menu.js',
    'html/editor.css',
    'html/editor.js',
    'html/radio-list.css',
    'html/notifications.css',
    'html/notifications.js',
    'html/sounds/success.mp3',
    'html/sounds/error.mp3',
    'html/sounds/warning.mp3',
    'stream/minimap.gfx',
    'stream/minimap.ytd',
    'stream/squaremap.ytd',
}

shared_scripts {
    'helpers/patch_update.js',
    '@ox_lib/init.lua',
    'config.lua',
}

client_scripts {
    'client/utils.lua',
    'client/buffs.lua',
    'client/minimap.lua',
    'client/vehicle.lua',
    'client/weapon_data.lua',
    'client/weapon.lua',
    'client/seatbelt.lua',
    'client/lights.lua',
    'client/status.lua',
    'client/nui.lua',
    'client/notifications.lua',
    'client/events.lua',
    'client/main.lua',
}

server_scripts {
    'server/default_layout.lua',
    --'server/version.lua',
}

optional_dependencies {
    --'jg-stress-addon',
    --'ps-buffs',
}
