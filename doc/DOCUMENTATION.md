Technical Documentation
======

Table of Contents
------
* [States](#states)
  * [pre_game](#pre-game)
  * [playing](#playing)
  * [menu](#menu)
  * [paused](#paused)
  * [cutscene](#cutscene)
* [Tables](#tables)
    * [game](#game)
    * [game.map](#gamemap)
    * [game.player](#gameplayer)
    * [config](#config)
* [Classes](#classes)
    * [Tile](#tile)
    * [Rect](#rect)
    * [GameObject](#gameobject)
    * [Fighter](#fighter)
    * [BasicMonster](#basicmonster)
    * [Item](#item)
    * [Equipment](#equipment)
    * [Invocation](#invocation)
    * [ConfusedMonster](#confusedmonster)

---

## States
The overarching system by which the game runs is it's **state**. Depending on the `game.states.base`, the engine will draw screens or objects, will take certain actions and various input methods will be accepted. The following states are acceptable:

### pre_game
This is the state the game finds itself in *prior* to starting a game. A player can *start a new game*, *load a game* or *edit the configurations* from this menu. The substate `game.states.pre_game` can have the values .

### playing
This is the main state in which the game will find itself. In this state the player can *directly control his character*, *open a menu*, or *interact with the world*. The substate `game.states.playing` can have the values `active`, `waiting`, `casting` and `dead`.

### menu
This state, while in-game, stops all the objects in the world from acting while the player moves through the menu(s). The world and objects are still drawn. The substate `game.states.menu` can have the values `inventory` and `dropping`.

### paused
This state is similar to the menu state, but only has a single possible menu. It allows the player to exit the game. It has no substates.

### cutscene
This is a special state, in case of drawing non-standard objects to the screen. The substate `game.states.cutscene` can have the value `begin`.

---

## Tables
Lua, and by extension Love2D, runs on tables. Because it's hard to get all the properties of a table, I'm documenting them here.

### game
The `game` table is the table containing most major variables. See this as a sort of meta table. It contains other meta tables: `console`, `map`, `player` and `states`. It also contains the table objects, and the variable container `state`. It also contains the functions `new_game`, `save_game`, `load_game` and `make_map`.

### game.map
The `game.map` meta table contains: the `tilemap` table, a collection of tiles; the `drawmap` table, a drawable variant of the tilemap; the `objects` table, keeping track of all the game's objects; the `stairs` object; the functions `place_objects`, `is_blocked`, `find_object`, and `objects_in_range`.

### game.player
The `game.player` meta table contains: the `character` GameObject; the `inventory` table; the functions `visible_range`, and `move`.

### Config
The config table contains: the configuration booleans; the functions `save_config` and `load_config`.

---

## Classes
Some generalized functionality is available through classes. The following classes are available:

### Tile
A tile is a single space on the map. It holds the properties `blocked`, `block_sight` and `visibility`. It holds no functions.

### Rect
A rectangle is a rectangular room. It holds the properties `x1`, `x2`, `y1`, and `y2`. It holds the functions `center` and `intersect`.

### GameObject
A gameobject is an interactable object in the map, most of whom's functionality is derived from composition. It holds the properties `x`, `y`, `char`, `name`, `color`, `blocks`, `fighter`, `ai`, `item`, `equipment` and `colortext`. It has the functions `move`, `draw`, `distance_to` and `move_towards`.

### fighter
A fighter is a component of a GameObject that is either the player or an NPC. It contains the variables `base_max_hp`, `base_defense`, `base_power`, `hp` and `xp`. It contains the variable functions `death_function`, `max_hp.get`, `defense.get` and `power.get`. It holds the table `invocations`. It has the member functions `take_damage`, `attack` and `heal`.

### BasicMonster
A basicmonster is an AI for an NPC GameObject. It holds no properties. It has the function `take_turn`.

### item
An item is a GameObject component that makes it able to be picked up and used. It holds the variable function `use_function` and the table `var`. `var` can be used for a variety of functions. 

### Equipment


### Invocation
has `var`

### ConfusedMonster


