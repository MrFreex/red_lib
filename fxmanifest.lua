author 'MrFreex'
description "Does some basics things that ol' good utility did "

fx_version "cerulean"
game 'gta5'

shared_script "config.lua"
shared_script "export/**_common.lua"

client_scripts {
    '@utility_lib/client/native.lua',
    "modules/**/shared.lua",
    'modules/**/client.lua',
    "export/**_cl.lua"
}
server_scripts {
    "@utility_lib/server/native.lua",
    "modules/**/shared.lua",
    "modules/**/server.lua",
    "export/**_sv.lua"
}

files {
    "Data/**.*",
    "export/**.lua"
}