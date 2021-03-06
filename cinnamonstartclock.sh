#!/bin/sh
#to enable debug mode uncomment the string below
#set -x
# Author: Oliver Rex, http://triforceweb.com/
# get this script latest version: wget -q http://triforceweb.com/timeCINNAMON.sh
###DISCLAIMER: in case of fire - steal, kill, fuck the geese, wait for a dial tone response
while true; do
sleep 1
timevalue=$(TZ=":Europe/Kiev" date +%T)
content='{
    "overlay-key": '{'
        "type": "keybinding",
        "description": "Keyboard shortcut to open and close the menu",
        "default": "Super_L::Super_R",
        "value": "Super_L::Super_R"
    '}',
    "menu-icon-custom": '{'
        "type": "checkbox",
        "default": false,
        "description": "Use a custom icon",
        "tooltip": "Unchecking this allows the theme to set the icon",
        "value": false
    '}',
    "menu-icon": '{'
        "type": "iconfilechooser",
        "default": "/usr/share/cinnamon/theme/menu-symbolic.svg",
        "description": "Icon",
        "tooltip": "Select an icon to show in the panel.",
        "dependency": "menu-icon-custom",
        "indent": "true",
        "value": "/usr/share/cinnamon/theme/menu-symbolic.svg"
    '}',
    "menu-label": '{'
        "type": "entry",
        "default": "Menu",
        "description": "Text",
        "tooltip": "Enter custom text to show in the panel.",
        "value": "'$timevalue'"
    '}',
    "show-category-icons": '{'
        "type": "checkbox",
        "default": true,
        "description": "Show category icons",
        "tooltip": "Choose whether or not to show icons on categories.",
        "value": true
    '}',
    "show-application-icons": '{'
        "type": "checkbox",
        "default": true,
        "description": "Show application icons",
        "tooltip": "Choose whether or not to show icons on applications.",
        "value": true
    '}',
    "favbox-show": '{'
        "type": "checkbox",
        "default": true,
        "description": "Show favorites and quit options",
        "tooltip": "Choose whether or not to show the left pane of the menu.",
        "value": true
    '}',
    "show-places": '{'
        "type": "checkbox",
        "default": true,
        "description": "Show bookmarks and places",
        "tooltip": "Choose whether or not to show bookmarks and places in the menu.",
        "value": true
    '}',
    "enable-autoscroll": '{'
        "type": "checkbox",
        "default": true,
        "description": "Enable autoscrolling in application list",
        "tooltip": "Choose whether or not to enable smooth autoscrolling in the application list.",
        "value": true
    '}',
    "search-filesystem": '{'
        "type": "checkbox",
        "default": false,
        "description": "Enable filesystem path entry in search box",
        "tooltip": "Allows path entry in the menu search box.",
        "value": false
    '}',
    "activate-on-hover": '{'
        "type": "checkbox",
        "default": false,
        "description": "Open the menu when I move my mouse over it",
        "tooltip": "Enable opening the menu when the mouse enters the applet",
        "value": false
    '}',
    "hover-delay": '{'
        "type": "spinbutton",
        "default": 0,
        "min": 0,
        "max": 1000,
        "step": 50,
        "units": "milliseconds",
        "description": "Menu hover delay:",
        "tooltip": "Delay between switching categories",
        "value": 0
    '}',
    "menu-editor-button": '{'
        "type": "button",
        "description": "Open the menu editor",
        "callback": "_launch_editor",
        "tooltip": "Press this button to customize your menu entries."
    '}',
    "__md5__": "9d111b39aa077120563a44787dac6a20"
}'


echo "$content" > "${HOME}/.cinnamon/configs/menu@cinnamon.org/0.json" 
touch -m "${HOME}/.cinnamon/configs/menu@cinnamon.org/0.json"
done