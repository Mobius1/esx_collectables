fx_version 'adamant'

game 'gta5'

description 'ESX Collectables'

author 'Karl Saunders'

version '1.2.0'

server_scripts {
    '@async/async.lua',
    '@mysql-async/lib/MySQL.lua',
    '@es_extended/locale.lua',
    'locales/en.lua',
    'config.lua',
    'server/utils.lua',
    'server/main.lua'
}

client_scripts {
    '@es_extended/locale.lua',
    'locales/en.lua',
    'config.lua',
    'client/utils.lua',
    'client/main.lua'
}

dependencies {
    'es_extended',
}