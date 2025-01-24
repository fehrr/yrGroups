fx_version "bodacious"
game "gta5"

name "yrGarages"
author "Yuri Resources"

ui_page "web-side/index.html"

client_scripts {
    "@vrp/lib/utils.lua",
    "client-side/client.lua"
}

server_scripts {
    "@vrp/lib/utils.lua",
    "server-side/server.lua"
}

files {
    "config.lua",
    "**/**.**"
}