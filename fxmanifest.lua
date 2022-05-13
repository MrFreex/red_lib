author 'MrFreex'
description "Does some basics things that ol' good utility did "

fx_version "cerulean"
lua54 'yes'
use_fxv2_oal 'yes'
game 'gta5'

shared_script "config.lua"
shared_script "shared.lua"


--// UI

ui_page "web/index.html"

client_scripts {
    '@utility_lib/client/native.lua',
    "export/**_common.lua",
    "export/**_cl.lua",
    "modules/**/shared.lua",
    'modules/**/client.lua'
}


server_scripts {
    "@utility_lib/server/native.lua",
    "export/**_common.lua",
    "export/**_sv.lua",
    "modules/**/shared.lua",
    "modules/**/server.lua"
}



files {
    "Data/**.*",
    "export/**.lua",
    "web/**.*"
}