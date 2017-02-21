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
STATE = {
    pre_game=1,
    playing=2,
    menu=3,
    paused=4,
    cutscene=5
}
PRE_GAME_STATE = {
    main=1,
    config=2,
    new_game=3,
    load_game=4,
    exit=5
}
PLAYING_STATE = {
    active=1,
    waiting=2,
    casting=3,
    dead=4
}
MENU_STATE = {
    inventory=1,
    dropping=2,
    level_up=3
}
CUTSCENE_STATE = {
    begin=1,
    won=2,
    dead=3
}

--system
SCALE = 16
SCREEN_WIDTH = 80
SCREEN_HEIGHT = 50
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

---spells
SPELL_RANGE = 6
------lightning
LIGHTNING_DAMAGE = 50
LIGHTNING_STORM_RANGE = 5
------confusion
CONFUSION_DURATION = 30
------fireball
FIREBALL_DAMAGE = 25
------strength
STRENGTH_BONUS = 5
STRENGTH_DURATION = 4
------regeneration
REGEN_DURATION = 6

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