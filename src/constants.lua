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
SLOTS = {
    left_hand = 1,
    right_hand = 2,
    left_arm = 3,
    right_arm = 4,
    body = 5,
    legs = 6,
    feet = 7,
    neck = 8,
    face = 9,
    head = 10,
    back = 11
}

--system
MAP_WIDTH = 78
MAP_HEIGHT = 43

--screen
STAT_DRAW_Y = 0
INVENTORY_WIDTH = 60

--io
SAVE_FILE = "save.rl"
CONFIG_FILE = "config.rl"

--game
CONFIG_DEFAULT = {fullscreen=false, tutorial=true}
END_FLOOR = 10

---character
LEVEL_UP_BASE = 200
LEVEL_UP_FACTOR = 150
PLAYER_VISIBILITY_RANGE = 10

--map
ROOM_MAX_SIZE = 10
ROOM_MIN_SIZE = 6
MAX_ROOMS = 30
FLOOR_COLOR = colors.grey_6
WALL_COLOR = colors.dark_orange