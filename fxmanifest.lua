author 'MrFreex'
description "Does some basics things that ol' good utility did "

fx_version "cerulean"
game 'gta5'

shared_script "config.lua"

client_scripts {
    '@utility_lib/client/native.lua',
    "modules/*/shared.lua",
    'modules/*/client.lua',
}
server_scripts {
    "@utility_lib/server/native.lua",
    "modules/*/shared.lua",
    "modules/*/server.lua"
}

files {
    "export/**.lua"
}