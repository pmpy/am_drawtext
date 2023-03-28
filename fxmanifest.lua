fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'Manny#4117'
description 'Draw Text UI'
version '1.0'

client_scripts {
    'client/cl_init.lua',
    -- 'client/cl_example.lua'
}

ui_page 'html/index.html'

files {
	'html/index.html',
	'html/script/*.js',
	'html/css/*.css'
}

exports {
    'displayText',
    'hideText'
}