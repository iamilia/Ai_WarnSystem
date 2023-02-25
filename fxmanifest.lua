--[[ FX Information ]]--
fx_version "cerulean"
lua54        'yes'
games        { 'rdr3', 'gta5' }

--[[ Resource Information ]]--
name         'Warn_System'
author       '^AI#1022'
version      '1.0.0'
license      'LGPL-3.0-or-later'
repository   'https://github.com/iamilia/Ai_WarnSystem'
description  'A Warn System StandLone .'

--[[ Manifest ]]--
dependencies {
	"/server:6200",
    "oxmysql",
}



shared_scripts {
    "config.lua"
}

server_scripts {
    "@oxmysql/lib/MySQL.lua",
    "server/functions.lua",
    "server/main.lua"
}

client_scripts {
    "client/functions.lua",
    "client/main.lua"
}


files {
  "html/index.html",
  "html/*.js",
  "html/*.css"
}


ui_page "html/index.html"
                  