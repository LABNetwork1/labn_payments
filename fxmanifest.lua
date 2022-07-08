fx_version "adamant"

game "gta5"

lua54 "yes"

shared_scripts {"@es_extended/imports.lua", "@ox_lib/init.lua"}

server_scripts {"@oxmysql/lib/MySQL.lua", "server/*.lua"}

client_scripts {"client/*.lua", "config.lua"}

dependency "es_extended"
