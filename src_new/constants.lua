Class = require 'libs.core.middleclass'
require 'libs.core.colors'
require 'libs.core.util'

--constants
ALPHABET = {
    "a", "b", "c", "d", "e", 
    "f","g", "h", "i", "j", 
    "k", "l", "m", "n", "o", 
    "p", "q", "r", "s", "t", 
    "u", "v", "w", "x", "y", 
    "z"
}
DIRECTIONS = {
    up          = {dx=0,    dy=-1}, 
    down        = {dx=0,    dy=1}, 
    left        = {dx=-1,   dy=0}, 
    right       = {dx=1,    dy=0}, 
    downleft    = {dx=-1,   dy=-1}, 
    upleft      = {dx=1,    dy=-1}, 
    downright   = {dx=-1,   dy=1}, 
    upright     = {dx=1,    dy=1}, 
    none        = {dx=0,    dy=0}
}

--io
SAVE_FILE = "save.rl"
CONFIG_FILE = "config.rl"

--game
CONFIG_DEFAULT = {fullscreen=false, tutorial=true}
END_FLOOR = 10