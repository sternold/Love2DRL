--modules
require("lib//Serialization//tablepersistence")
local class = require "lib//middleclass"
local G = love.graphics

--constants
ALPHABET = {"a", "b", "c", "d", "e", "f","g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"}
DIRECTION = {{0, -1}, {0,1}, {-1,0}, {1,0},{-1,-1},{1,-1},{-1,1},{1,1},{0,0}}
SAVE_FILE = "save.rl"
SCALE = 16
SCREEN_WIDTH = 80
SCREEN_HEIGHT = 50
MAP_WIDTH = 78
MAP_HEIGHT = 43
ROOM_MAX_SIZE = 10
ROOM_MIN_SIZE = 6
MAX_ROOMS = 30
BAR_WIDTH = 20
STAT_Y = 0
INVENTORY_WIDTH = 60
PLAYER_VISIBLE_RANGE = 10
HEAL_AMOUNT = 20
SPELL_RANGE = 6
LIGHTNING_DAMAGE = 50
LIGHTNING_STORM_RANGE = 5
CONFUSION_DURATION = 30
FIREBALL_DAMAGE = 25
STRENGTH_BONUS = 5
STRENGTH_DURATION = 4
LEVEL_UP_BASE = 200
LEVEL_UP_FACTOR = 150

--colors
color_player = {200, 50, 50, 255}
color_black = {255, 255, 255, 255}
color_white = {255, 255, 255, 255}
color_green = {0, 250, 0, 255}
color_dark_green = {0, 150, 0, 255}
color_red = {250, 0, 0, 255}
color_dark_red = {150, 0, 0, 255}
color_blue = {25, 25, 250, 255}
color_dark_blue = {10, 10, 150, 255}
color_yellow = {200, 200, 0, 255}
color_dark_yellow = {125, 125, 0, 245}
color_violet = {200, 0, 150, 255}
color_grey = {200, 200, 200, 255}
color_grey_translucent = {200, 200, 200, 200}

--fog of war
fog_dark = {0, 0, 0, 255}
fog_visited = {0, 0, 0, 150}
fog_visible = {0, 0, 0, 0}

--variables
gameobjects = {}
player_start_x = 0
player_start_y = 0
worldactive = false
objectmap = {}
game_state = ""
player_action = ""
menu_active = false
monster_count = -1
aimable_spell = nil
direction = "none"
dungeon_level = 1

inventory = {}

--TILE
Tile = class("Tile")
function Tile:initialize (blocked, block_sight)
    self.blocked = blocked
    self.block_sight = block_sight or blocked
    self.visibility = fog_dark
end

--RECT
Rect =  class('Rect')
function Rect:initialize(x, y, w, h)
    self.x1 = x
    self.y1 = y
    self.x2 = x + w
    self.y2 = y + h
end

function Rect:center()
    cx = math.floor((self.x1 + self.x2) / 2)
    cy = math.floor((self.y1 + self.y2) / 2)
    return cx, cy
end

function Rect:intersect(other)
    return (self.x1 <= other.x2 and self.x2 >= other.x1 and self.y1 <= other.y2 and self.y2 >= other.y1)
end

--GAMEOBJECT
GameObject = class('GameObject')
function GameObject:initialize(x, y, char, name, color, blocks, fighter, ai, item)
    self.x = x
    self.y = y
    self.char = char
    self.name = name
    self.color = color
    self.blocks = blocks or false
    self.fighter = fighter or nil
    if self.fighter ~= nil then
        self.fighter.owner = self
    end
    self.ai = ai or nil
    if self.ai ~= nil then
        self.ai.owner = self
    end
    self.item = item or nil
    if self.item ~= nil then
        self.item.owner = self
    end
    self.invocations = {}
    self.colortext = G.newText(G.getFont(), {color, char})
end

function GameObject:move(dx, dy)
    if not is_blocked(self.x + dx, self.y + dy) then
        self.x = self.x + dx
        self.y = self.y + dy
    end
end

function GameObject:draw()
    if objectmap[self.x][self.y].visibility == fog_visible then
        G.draw(self.colortext, self.x*SCALE, self.y*SCALE)
    end
end

function GameObject:move_towards(target_x, target_y)
    local dx = target_x - self.x
    local dy = target_y - self.y
    local distance = math.sqrt(math.pow(dx, 2) + math.pow(dy, 2))

    --this should be round, but it's lua
    dx = round(dx / distance)
    dy = round(dy / distance)
    self:move(dx, dy)
end

function GameObject:distance_to(other)
    local dx = other.x - self.x
    local dy = other.y - self.y
    return math.sqrt(math.pow(dx, 2) + math.pow(dy, 2))
end

--FIGHTER
Fighter = class('Fighter')
function Fighter:initialize(hp, defense, power, xp, death_function)
    self.max_hp = hp
    self.hp = hp
    self.defense = defense
    self.power = power
    self.xp = xp
    self.death_function = death_function or nil
end

function Fighter:take_damage(damage)
    if damage > 0 then
        self.hp = self.hp - damage
        if self.hp <= 0 then
            dfunc = self.death_function
            if dfunc ~= nil then
                dfunc(self.owner)
            end
        end
    end
end

function Fighter:attack(target)
    local damage = self.power - target.fighter.defense
 
        if damage > 0 then
            console_print(self.owner.name .. ' attacks ' .. target.name .. ' for ' .. damage .. ' hit points.')
            target.fighter:take_damage(damage)
        else
            console_print(self.owner.name .. ' attacks ' .. target.name .. ' but it has no effect!')
        end
end

function Fighter:heal(amount)
    self.hp = self.hp + amount
    if self.hp > self.max_hp then
        self.hp = self.max_hp
    end
end

function player_death(target)
    game_state = "dead"

    target.char = '%'
    target.color = color_dark_red
    target.colortext = G.newText(G.getFont(),{target.color, target.char})
    draw_screen()
end

function monster_death(target)
    console_print(target.name .. ' is dead!', color_dark_red)
    player.fighter.xp = player.fighter.xp + target.fighter.xp
    target.char = '%'
    target.color = color_dark_red
    target.colortext = G.newText(G.getFont(),{target.color, target.char})
    target.blocks = false
    target.fighter = nil
    target.ai = nil
    target.name = 'remains of ' .. monster.name
    monster_count = monster_count - 1
    check_level_up()
end

--BASICMONSTER
BasicMonster = class('BasicMonster')
function BasicMonster:initialize()
end

function BasicMonster:take_turn()
    monster = self.owner
    
    if objectmap[self.owner.x][self.owner.y].visibility == fog_visible then
        if monster:distance_to(player) >= 2 then
            monster:move_towards(player.x, player.y)
        elseif player.fighter.hp > 0 then
            monster.fighter:attack(player)
        end
    end
end

--ITEM
Item = class('Item')
function Item:initialize(use_function)
    self.use_function = use_function
end

function Item:pick_up()
    if table.maxn(inventory) >= 26 then
        console_print("Your inventory is full.")
    else
        table.insert(inventory, self.owner)
        table.remove(gameobjects, index_of(gameobjects, self.owner))
        console_print("You picked up a " .. self.owner.name .. "!", self.owner.color)
    end
end

function Item:use()
    if self.use_function ~= nil then
        if self.use_function() ~= "cancelled" then
            table.remove(inventory, index_of(inventory, self.owner))
        end
    else
        console_print("The " .. self.owner.name .. " cannot be used.")
    end
end

function Item:drop()
    table.insert(gameobjects, self.owner)
    table.remove(inventory, index_of(self.owner))
    self.owner.x = player.x
    self.owner.y = player.y
    console_print("you dropped a " .. self.owner.name .. ".", self.owner.color)
end

function cast_heal()
    if player.fighter.hp == player.fighter.max_hp then
        console_print("You're already at full health.", color_green)
        return "cancelled"
    end
    console_print("You're starting to feel better!", color_violet)
    player.fighter:heal(HEAL_AMOUNT)
end

function cast_lightning()
    local monster = closest_monster(SPELL_RANGE)
    if monster == nil then
        console_print("No enemy in range.")
        return "cancelled"
    end

    console_print("A lightning bolt strikes the " .. monster.name .. ", dealing " .. LIGHTNING_DAMAGE .. " damage!", color_yellow)
    monster.fighter:take_damage(LIGHTNING_DAMAGE)
end

function cast_fireball()
    game_state = "aiming"
    if direction == "none" then
        aimable_spell = cast_fireball
    else
        target = find_target(direction)
        if target == "wrong_direction" then
            console_print("Wrong key.")
        elseif target ~= nil then
            console_print("The " .. target.name .. " takes " .. FIREBALL_DAMAGE .. " fire damage!", color_red)
            target.fighter:take_damage(FIREBALL_DAMAGE)
            game_state = "playing"
            direction = "none"
            aimable_spell = nil
            draw_screen()
        else
            console_print("The fireball splashes against the wall.")
            game_state = "playing"
            direction = "none"
            aimable_spell = nil
            draw_screen()
        end
    end
end

function cast_confusion()
    local monster = closest_monster(SPELL_RANGE)
    if monster == nil then
        console_print("No enemy in range.")
        return "cancelled"
    end

    console_print("The " .. monster.name .. " seems dazed and confused!", color_violet)
    add_invocation(monster, CONFUSION_DURATION, invoke_confusion)
end

function cast_strength()
    console_print("The " .. player.name .. " grows stronger!", color_player)
    add_invocation(player, STRENGTH_DURATION, invoke_strength)
end

function cast_lightning_storm()
    local gobjects = gameobjects_in_range(player.x, player.y, LIGHTNING_STORM_RANGE)
    if table.maxn(gobjects) == 0 then
        console_print(table.maxn(gobjects))
        console_print("No enemy in range.")
        return "cancelled"
    end
    local monsters = {}
    for k, v in pairs(gobjects)do
        if v.ai ~= nil then
            table.insert(monsters, v)
        end
    end

    console_print("A lightning storm strikes " .. table.maxn(monsters) .. " targets, dealing " .. LIGHTNING_DAMAGE .. " damage to each!", color_yellow)
    for k, v in pairs(monsters) do
        v.fighter:take_damage(LIGHTNING_DAMAGE)
    end
end

--INVOCATION
Invocation = class('Invocation')
function Invocation:initialize(duration, invoke_function)
    self.duration = duration
    self.timer = 0
    self.invoke_function = invoke_function
end

function Invocation:invoke()
    self.invoke_function(self, true)
    self.timer = self.timer + 1
    if(self.timer >= self.duration) then
        self.invoke_function(self, false)
    end
end

function invoke_confusion(invocation, state)
    if invocation.old_ai == nil and state then
        invocation.old_ai = invocation.owner.ai
        new_ai = ConfusedMonster()
        new_ai.owner = invocation.owner 
        invocation.owner.ai = new_ai
    elseif not state then
        console_print("The confusion has ended.", color_green)
        invocation.owner.ai = invocation.old_ai
        table.remove(invocation.owner.invocations, index_of(invocation))
    end
end

function invoke_strength(invocation, state)
    if not invocation.fired and state then
        invocation.old_pwr = invocation.owner.fighter.power
        new_pwr = invocation.owner.fighter.power + STRENGTH_BONUS
        invocation.owner.fighter.power = new_pwr
        invocation.fired = true
    elseif not state then
        console_print(invocation.owner.name .. " no longer feels powerful.", color_player)
        invocation.owner.fighter.power = invocation.old_pwr
        table.remove(invocation.owner.invocations, index_of(invocation))
    end
end

function add_invocation(target, duration, invoke_function)
    local inv = Invocation(duration, invoke_function)
    inv.owner = target
    table.insert(target.invocations, inv)
end

--CONFUSEDMONSTER
ConfusedMonster = class('ConfusedMonster')
function ConfusedMonster:initialize()
end

function ConfusedMonster:take_turn()
    console_print("The " .. self.owner.name .. " stumbles around!", color_violet)
    self.owner:move(love.math.random(-1, 1), love.math.random(-1, 1))
end

--LOVE
function love.run()
    if love.math then
		love.math.setRandomSeed(os.time())
    end
 
	if love.load then love.load(arg) end
 
	-- We don't want the first frame's dt to include time taken by love.load.
	if love.timer then love.timer.step() end
 
	local dt = 0

    if love.graphics and love.graphics.isActive() then
		love.graphics.clear(love.graphics.getBackgroundColor())
		love.graphics.origin()
		if love.draw then love.draw() end
		love.graphics.present()
	end
 
	-- Main loop time.
	while true do
		-- Process events.
		if love.event then
			love.event.pump()
			for name, a,b,c,d,e,f in love.event.poll() do
				if name == "quit" then
					if not love.quit or not love.quit() then
						return a
					end
				end
				love.handlers[name](a,b,c,d,e,f)
			end
		end
 
		-- Update dt, as we'll be passing it to update
		if love.timer then
			love.timer.step()
			dt = love.timer.getDelta()
		end
 
		-- Call update and draw
		if love.update then love.update(dt) end -- will pass 0 if love.timer is disabled
 
		if love.timer then love.timer.sleep(0.001) end
	end
end

function love.load()
    --options
    love.window.setTitle("The Tomb of King LOVE")
    love.window.setMode(SCREEN_WIDTH*SCALE, SCREEN_HEIGHT*SCALE)
    love.keyboard.setKeyRepeat(true)
    G.setFont(G.newFont("PS2P-R.ttf", SCALE))

    --initialize
    game_state = "menu"
    player_action = "main"
    draw_screen()
end

function love.update(dt)
    if worldactive and game_state == "playing" and player_action ~= "didnt-take-turn" then
        for key,value in pairs(gameobjects) do 
            if value.ai ~= nil then
                for k, v in pairs(value.invocations) do
                    v:invoke()
                end
                value.ai:take_turn()
            end 
        end
        for k, v in pairs(player.invocations) do
            v:invoke()
        end
        draw_screen()
        worldactive = false
    elseif game_state == "casting" then
        if aimable_spell ~= nil then
            aimable_spell()
        end
    end

    if monster_count == 0 and game_state == "playing" then
        console_print("The floor seems quiet. Too quiet...", color_green)
        draw_screen()
        monster_count = monster_count - 1
    end 

    if player_action == "exit" then
        save_game()
        love.event.quit()
    end
end

function love.draw()
    if player_action ~= "main" then
        --draw map
        G.draw(drawablemap, 1, 3)

        --draw player
        for key,value in pairs(gameobjects) do 
            if value ~= player then
                value:draw()
            end
        end
        player:draw()
        fog_of_war()

        console_draw()
        stats_draw()

        if game_state == "menu" then
            inventory_menu(player.name .. "'s Inventory")
        elseif game_state == "aiming" then
            if direction == "up" then
                text_draw("*", player.x, player.y - 1, color_yellow, 0, 0)
            elseif direction == "down" then
                text_draw("*", player.x, player.y + 1, color_yellow, 0, 0)
            elseif direction == "left" then
                text_draw("*", player.x - 1, player.y, color_yellow, 0, 0)
            elseif direction == "right" then
                text_draw("*", player.x + 1, player.y, color_yellow, 0, 0)
            end
        elseif game_state == "dead" then
            game_over("Death is inevitable.")
        elseif game_state == "won" then
            game_over("A WINNER IS YOU!")
        end
    else
        if game_state == "menu" then
            main_menu()
        end
    end 
end

function love.keypressed(key)
    if game_state == "playing" then
        worldactive = true
        if key == "left" or key == "kp4" then
            player_move_or_attack(-1, 0)
            player_action = "left"
        elseif key == "right" or key == "kp6" then
            player_move_or_attack(1, 0)
            player_action = "right"
        elseif key == "up" or key == "kp8" then
            player_move_or_attack(0, -1)
            player_action = "up"
        elseif key == "down" or key == "kp2" then
            player_move_or_attack(0, 1)
            player_action = "down"
        elseif key == "g" then
            for key, value in pairs(gameobjects) do
                if value.item ~= nil and value.x == player.x and value.y == player.y then
                    value.item:pick_up()
                    break
                end
            end
            player_action = "pickup"
        elseif key == "," then
            if player.x == stairs.x and player.y == stairs.y then
                next_level()
            end
        else
            worldactive = false
            player_action = "didnt-take-turn"
        end
    elseif game_state == "menu" then
        if inventory[index_of(ALPHABET, key)] ~= nil then
            if player_action == "inventory" then
                game_state = "playing"
                inventory[index_of(ALPHABET, key)].item:use();
                draw_screen()
            elseif player_action == "drop" then
                game_state = "playing"
                inventory[index_of(ALPHABET, key)].item:drop();
                draw_screen()
            end
            player_action = "didnt-take-turn"
        elseif player_action == "main" then
            choice = index_of(ALPHABET, key)
            if choice == 1 then
                new_game()
            elseif choice == 2 then
                load_game()
            elseif choice == 3 then
                player_action = "exit"
            end
        else 
            game_state = "playing"
            draw_screen()
        end
    elseif game_state == "aiming" then
        if key == "c" then
            game_state = "casting"
        else
            if key == "left" or key == "kp4" then
                direction = "left"
            elseif key == "right" or key == "kp6" then
                direction = "right"
            elseif key == "up" or key == "kp8" then
                direction = "up"
            elseif key == "down" or key == "kp2" then
                direction = "down"
            end
        end
        draw_screen()
    elseif game_state == "dead" then
        if key == "r" then
            new_game()
        end
    end
    if key == "escape" then
        player_action = "exit"
    elseif key == "i" and player_action ~= "drop" then
        if game_state == "playing" then
            game_state = "menu"
            player_action = "inventory"
        end
        draw_screen()
    elseif key == "d" and player_action ~= "inventory" then
        if game_state == "playing" then
            game_state = "menu"
            player_action = "drop"
        end
        draw_screen()
    end
end

function draw_screen()
    --draw screen when moving
    if love.graphics and love.graphics.isActive() then
        love.graphics.clear(love.graphics.getBackgroundColor())
        love.graphics.origin()
        if love.draw then love.draw() end
        love.graphics.present()
    end
end

---FUNCTIONS

--INIT 
function new_game()
    game_state = "playing"  
    player_action = nil  
    inventory = {}
    console_log = {}
    make_map()

    local fighter_component = Fighter(100, 1, 4, 0, player_death)
    player = GameObject(player_start_x, player_start_y, "@", "player", color_player, true, fighter_component, nil)
    player.level = 1
    visible_range(PLAYER_VISIBLE_RANGE)

    --make map into a single image
    drawablemap = map_to_image(objectmap)

    console_print("Welcome stranger, be prepared to perish in the tombs of LOVE!", color_red)
    draw_screen()
end

function next_level()
    console_print("You take a moment to rest...", color_blue)
    player.fighter:heal(round(player.fighter.max_hp / 2))
    console_print("You descent deeper into the tomb of king LOVE...", color_red)
    make_map()
    player.x = player_start_x
    player.y = player_start_y
    visible_range(PLAYER_VISIBLE_RANGE)
    drawablemap = map_to_image(objectmap)
    dungeon_level = dungeon_level + 1
    draw_screen()
end

function save_game()
    if love.filesystem.isFile(SAVE_FILE) then
        love.filesystem.remove(SAVE_FILE)
    end
    love.filesystem.newFile(SAVE_FILE)
    local savedata = {}
    table.insert(savedata, 1, objectmap)
    table.insert(savedata, 3, gameobjects)
    table.insert(savedata, 4, player)
    table.insert(savedata, 5, inventory)
    table.insert(savedata, 6, console_log)
    table.insert(savedata, 7, game_state)
    local buf = persistence.store(love.filesystem.getSaveDirectory() .. "//" .. SAVE_FILE, savedata)
    --todo
end

function load_game()
    if love.filesystem.isFile(SAVE_FILE) then
        local savedata = persistence.load(love.filesystem.getSaveDirectory() .. "//" .. SAVE_FILE)
        --load map
        objectmap = {}
        local lobjectmap = savedata[1]
        for x, arr in pairs(lobjectmap) do
            objectmap[x] = {}
            for y, til in pairs(arr) do
                objectmap[x][y] = Tile(til.blocked, til.block_sight)
                objectmap[x][y].visibility = til.visibility
            end 
        end
        
        --load objects [dont forget invocations]
        gameobjects = {}
        local lgameobjects = savedata[3]
        for k,v in pairs(lgameobjects) do
            local lfighter = nil
            local lai = nil
            local litem = nil
            if v.fighter ~= nil then
                lfighter = Fighter(v.fighter.max_hp, v.fighter.defense, v.fighter.power, v.fighter.xp, monster_death)
                lfighter.hp = v.fighter.hp
            end
            if v.ai ~= nil then
                lai = BasicMonster()
            end
            if v.item ~= nil then
                litem = Item(v.item.use_function)
            end
            local lgameobject = GameObject(v.x, v.y, v.char, v.name, v.color, v.blocks, lfighter, lai, litem)
            for k1, inv in pairs(v.invocations) do
                local linv = Invocation(inv.duration, inv.invoke_function)
                linv.timer = inv.timer
                table.insert(lgameobject.invocations, linv)
            end
            table.insert(gameobjects, lgameobject)
        end
        
        --load player
        local lplayer = savedata[4]
        local lfighter = lplayer.fighter
        local fighter = Fighter(lfighter.max_hp, lfighter.defense, lfighter.power, lfighter.xp, player_death)
        fighter.hp = lfighter.hp
        player = GameObject(lplayer.x, lplayer.y, lplayer.char, "player", color_player, true, fighter, nil, nil)
        player.level = lplayer.level
        
        --load inventory
        inventory = {}
        local linventory = savedata[5]
        for k,v in pairs(linventory) do
            local litem_component = Item(v.item.use_function)
            local litem = GameObject(v.x, v.y, v.char, v.name, v.color, false, nil, nil, litem_component)
            table.insert(inventory, litem)
        end
        
        --load console_log
        console_log = savedata[6]
        
        --load game_state
        game_state = savedata[7]

        --load stairs
        for k, v in pairs(gameobjects) do
            if v.name == "stairs" then
                stairs = v
            end
        end 
        
        drawablemap = map_to_image(objectmap)
        player_action = nil  
        visible_range(PLAYER_VISIBLE_RANGE)
        draw_screen()
    else
        print("No save data found.")    
    end
end

--UTIL
function round(number)
    local toround = number - math.floor(number)
    if toround >= .5 then
        return math.ceil(number)
    else
        return math.floor(number)
    end
end

function console_print(string, color)
    print(string)
    table.insert(console_log, {string, color})
end

function menu(header, options, width)
    if table.maxn(options) > 26 then
        error("Cannot have a menu with more than 26 options")
    end
    local x = 2
    local y = 2
    local height = table.maxn(options) + 2
    rect_draw("fill", x, y, width, height, color_grey_translucent)
    rect_draw("line", x, y, width, height, color_grey)
    text_draw(header, x, y, color_white, 4, 4)
    for k, v in pairs(options) do
        text_draw("(" .. ALPHABET[k] .. ") " .. v, x, y + k, color_white, 4, 4)
    end
end

function inventory_menu(header)
    local options = {}
    if table.maxn(inventory) ==0 then
        table.insert(options, "Inventory is empty.")
    else
        for key, value in pairs(inventory) do
            table.insert(options, value.name)
        end
    end
    menu(header, options, INVENTORY_WIDTH)
end

function main_menu()
    menu("TOMB OF KING LOVE by Sternold", {"New Game", "Continue", "Quit"}, 31)
end

function index_of(table, object)
    for key, value in pairs(table) do
        if value == object then
            return key
        end
    end
    return nil
end

function find_gameobject(x, y)
    for k, v in pairs(gameobjects) do
        if v.x == x and v.y == y then
            return v
        end
    end
    return nil
end

function closest_monster(max_range)
    local closest_enemy = nil
    local closest_dist = max_range + 1
 
    for key, value in pairs(gameobjects) do
        if value.fighter ~= nil and value ~= player then
            dist = player:distance_to(value)
            if dist < closest_dist then
                closest_enemy = value
                closest_dist = dist
            end
        end
    end
    if closest_enemy ==nil then
        return closest_enemy
    elseif objectmap[closest_enemy.x][closest_enemy.y].visibility == fog_visible then
        return closest_enemy
    else
        return nil
    end
end

function find_target(direction)
    if direction == "up" then
        for y = player.y, 0, -1 do
            if objectmap[player.x][y].blocked then
                break
            end
            for k, v in pairs(gameobjects) do
                if v.x == player.x and v.y == y and v.ai ~= nil then
                    return v
                end
            end
        end
    elseif direction == "down" then
        for y = player.y, MAP_HEIGHT do
            if objectmap[player.x][y].blocked then
                break
            end
            for k, v in pairs(gameobjects) do
                if v.x == player.x and v.y == y and v.ai ~= nil then
                    return v
                end
            end
        end
    elseif direction == "left" then
        for x = player.x, 0, -1 do
            if objectmap[x][player.y].blocked then
                break
            end
            for k, v in pairs(gameobjects) do
                if v.x == x and v.y == player.y and v.ai ~= nil then
                    return v
                end
            end
        end
    elseif direction == "right" then
        for x = player.x, MAP_WIDTH do
            if objectmap[x][player.y].blocked then
                break
            end
            for k, v in pairs(gameobjects) do
                if v.x == x and v.y == player.y and v.ai ~= nil then
                    return v
                end
            end
        end
    else
        return 'wrong_direction'
    end
end

function gameobjects_in_range(originx, originy, range)
    local targets = {}
    for x = originx - range, originx + range do
        for y = originy - range, originy + range do
            gob = find_gameobject(x, y)
            if gob ~= nil then
                table.insert(targets, gob)
            end
        end
    end 
    return targets
end

function random_choice(collection)
    local sum = 0
    for k,v in pairs(collection) do
        sum = sum + v
    end
    local dice = love.math.random(0, sum)
    sum = 0
    for k,v in pairs(collection) do
        sum = sum + v
        if dice <= sum then
            return k
        end
    end
end

--DRAWING
function fog_of_war()
    for x,arr in pairs(objectmap) do
        for y, til in pairs(arr) do
            rect_draw("fill", x, y, 1, 1, til.visibility)
        end
    end
end

function console_draw()
    local count = table.maxn(console_log)
    local max = 1
    if count < 5 then
        max = count
    else
        max = 5
    end
    for i=1, max do
        text_draw(console_log[count + 1 - i][1], 1, SCREEN_HEIGHT - i - 1, console_log[count + 1 - i][2] or nil, 0, 2)
    end
end

function stats_draw()
    --level
    text_draw("LvL " .. player.level, 1, STAT_Y, color_white, 0, 4)
    
    --HP
    bar_draw(7, STAT_Y, BAR_WIDTH, "HP", player.fighter.hp, player.fighter.max_hp, color_red, color_grey)

    --xp
    text_draw(player.fighter.xp .. "/" .. (LEVEL_UP_BASE + player.level * LEVEL_UP_FACTOR) .. "EXP", 28, STAT_Y, color_white, 0, 4) 

    --Attributes
    text_draw("PWR:" .. player.fighter.power, 41, STAT_Y, color_white, 0, 4)
    text_draw("DEF:" .. player.fighter.defense, 47, STAT_Y, color_white, 0, 4)
    
    --Dungeon level
    text_draw("Floor " .. dungeon_level, SCREEN_WIDTH - 10, STAT_Y, color_white, 0, 4)
end

function bar_draw(x, y, total_width, name, value, maximum, bar_color, back_color)
    --render a bar (HP, experience, etc). first calculate the width of the bar
    local bar_width = round(value / maximum * total_width)
 
    --render the background first
    rect_draw("fill", x, y, total_width, 1, back_color)
 
    --now render the bar on top
    rect_draw("fill", x, y, bar_width, 1, bar_color)

    local string = name .. ": " .. value .. "/" .. maximum
    text_draw(string, x, y, color_white, 4, 4)
end

function rect_draw(mode, x, y, w, h, color)
    G.setColor(color)
    G.rectangle(mode, x * SCALE, y * SCALE, w * SCALE, h * SCALE)
    G.setColor(color_black)
end

function text_draw(text, x, y, color, xoff, yoff)
    G.draw(G.newText(G.getFont(), {color or color_white, text}), x * SCALE + xoff, y * SCALE + yoff)
end

function game_over(text)
        rect_draw("fill", 0, 0, SCREEN_WIDTH, SCREEN_HEIGHT, {0,0,0,200})
        console_print(text, color_yellow)
        G.draw(G.newText(G.getFont(), {color_white, text}), ((round(SCREEN_WIDTH / 2)) - 10) * SCALE, (round(SCREEN_HEIGHT / 2)) * SCALE)
end

--MAP
function make_map()
    gameobjects = {}
    objectmap = {}
    
    for x=1, MAP_WIDTH, 1 do
        table.insert(objectmap, x, {}) 
        for y=1, MAP_HEIGHT, 1 do
            table.insert(objectmap[x], y, Tile(true)) 
        end
    end

    --random dungeon generation
    local rooms = {}
    local x = 0
    local y = 0
    monster_count = monster_count + 1
    for rums=0, MAX_ROOMS do
        --random width and height
        local w = love.math.random(ROOM_MIN_SIZE, ROOM_MAX_SIZE)
        local h = love.math.random(ROOM_MIN_SIZE, ROOM_MAX_SIZE)
        --random position without going out of the boundaries of the map
        x = love.math.random(1, MAP_WIDTH - w - 1)
        y = love.math.random(1, MAP_HEIGHT - h - 1)

        local new_room = Rect(x, y, w, h)
        local failed = false
        for x=1, table.maxn(rooms) do
            if new_room:intersect(rooms[x]) then
                failed = true
                break
            end
        end
        if(not failed) then
            create_room(new_room)
            place_objects(new_room)
            new_x, new_y = new_room:center()

            if table.maxn(rooms) == 0 then
                player_start_x = new_x
                player_start_y = new_y
            else    
                prev_x, prev_y = rooms[table.maxn(rooms)]:center()

                if love.math.random(0, 1) == 1 then
                    create_h_tunnel(prev_x, new_x, prev_y)
                    create_v_tunnel(prev_y, new_y, new_x)
                else
                    create_v_tunnel(prev_y, new_y, prev_x)
                    create_h_tunnel(prev_x, new_x, new_y)
                end
                     
            end
            table.insert(rooms, new_room)
        end
    end
    while objectmap[x][y].blocked do
        dx = love.math.random(-1, 1)
        dy = love.math.random(-1, 1)
        if objectmap[x + dx] == nil or objectmap[x + dx][y + dy] == nil then
            x = love.math.random(2, MAP_WIDTH - 1)
            y = love.math.random(2, MAP_HEIGHT - 1)
        end
        x = x + dx
        y = y + dy
    end
    stairs = GameObject(x, y, "<", "stairs", color_white)
    table.insert(gameobjects, stairs)
end

function create_room(room)
    for x=room.x1+1, room.x2 do
        for y=room.y1+1, room.y2 do
            objectmap[x][y].blocked = false
            objectmap[x][y].block_sight = false
        end
    end
end

function create_h_tunnel(x1, x2, y)
    for x=math.min(x1, x2), math.max(x1, x2) do
        objectmap[x][y].blocked = false
        objectmap[x][y].block_sight = false
    end
end

function create_v_tunnel(y1, y2, x)
    for y=math.min(y1, y2), math.max(y1, y2) do
        objectmap[x][y].blocked = false
        objectmap[x][y].block_sight = false
    end
end

function place_objects(room)
    --MONSTERS
    local max_monsters = from_dungeon_level({{1, 2}, {4, 3}, {6, 5}})
 
    local monster_chances = {}
    monster_chances['orc'] = 80  
    monster_chances['troll'] = from_dungeon_level({{3, 15}, {5, 30}, {7, 60}})
 
    --ITEMS
    local max_items = from_dungeon_level({{1, 1}, {4, 2}})
 
    local item_chances = {}
    item_chances['heal'] = 35 
    item_chances['lightning'] = from_dungeon_level({{3, 10}})
    item_chances['fireball'] =  from_dungeon_level({{2, 20}})
    item_chances['confuse'] =   from_dungeon_level({{2, 10}})
    item_chances['strength'] =   from_dungeon_level({{3, 20}})
    item_chances['lightning_storm'] =   from_dungeon_level({{5, 5}})

    local num_monsters = love.math.random(0, max_monsters)

    for i=0, num_monsters do
        --choose random spot for this monster
        local x = love.math.random(room.x1+1, room.x2-1)
        local y = love.math.random(room.y1+1, room.y2-1)
        
         if not is_blocked(x, y) then
            local monster = nil
            local choice = random_choice(monster_chances) 
            if choice == "orc" then
                local fighter_component = Fighter(20, 0, 4, 35, monster_death)
                local ai_component = BasicMonster()
                monster = GameObject(x, y, "o", "Orc", color_green, true, fighter_component, ai_component)
            elseif choice == "troll" then
                local fighter_component = Fighter(30, 2, 8, 50, monster_death)
                local ai_component = BasicMonster()
                monster = GameObject(x, y, "T", "Troll", color_dark_green, true, fighter_component, ai_component)
            end
            monster_count = monster_count + 1
            table.insert(gameobjects, monster)
        end 
    end

    --choose random number of items
    local num_items = love.math.random(0, max_items)
 
    for i=0, num_items do
        --choose random spot for this item
        local x = love.math.random(room.x1+1, room.x2-1)
        local y = love.math.random(room.y1+1, room.y2-1)
 
        --only place it if the tile is not blocked
        if not is_blocked(x, y) then
            local item = nil
            local choice = random_choice(item_chances) 
            if choice == "heal" then
                local item_component = Item(cast_heal)
                item = GameObject(x, y, '!', 'healing potion', color_violet, false, nil, nil, item_component)
            elseif choice == "confuse" then
                local item_component = Item(cast_confusion)
                item = GameObject(x, y, '#', 'Scroll of Confusion', color_violet, false, nil, nil, item_component)   
            elseif choice == "fireball" then
                local item_component = Item(cast_fireball)
                item = GameObject(x, y, '#', 'Scroll of Fireball', color_dark_red, false, nil, nil, item_component)   
            elseif choice == "strength" then
                local item_component = Item(cast_strength)
                item = GameObject(x, y, '#', "Scroll of Giant's Strength", color_player, false, nil, nil, item_component)   
            elseif choice == "lightning" then
                local item_component = Item(cast_lightning)
                item = GameObject(x, y, '#', 'Scroll of Lighning Bolt', color_yellow, false, nil, nil, item_component)
            elseif choice == "lightning_storm" then
                local item_component = Item(cast_lightning_storm)
                item = GameObject(x, y, '#', 'Scroll of Lightning Storm', color_dark_yellow, false, nil, nil, item_component)
            end
            table.insert(gameobjects, item)
        end
    end
end

function map_to_image(map)
    local text = G.newText(G.getFont(), "")
    for i=1, table.maxn(map) do
        for j=1, table.maxn(map[i]) do
            tile = map[i][j]
            local colortext = tile_to_colortext(tile)           
            text:add(colortext, i*SCALE, j*SCALE)
        end
    end
    return text
end

function tile_to_colortext(tile)
    local wall = tile.blocked
    local colortext = {{255, 255, 255, 255}, "?"}
    if wall then
        colortext = {color_dark_blue, "#"}
    else
        colortext = {color_blue, "."}
    end 
    return colortext
end

--MOVEMENT
function is_blocked(x, y)
    if objectmap[x][y].blocked then
        return true
    end
    for key,value in pairs(gameobjects) do 
        if value.blocks and value.x == x and value.y == y then
            return true
        end
    end
 
    return false
end

function player_move_or_attack(dx, dy)
    local x = player.x + dx
    local y = player.y + dy

    local target = nil
    for key,value in pairs(gameobjects) do 
        if value.fighter ~= nil and value.x == x and value.y == y then
            target = value
            break
        end
    end

    if target ~= nil then
            print(target.fighter.hp .. "/" .. target.fighter.max_hp)
        player.fighter:attack(target)
    else
        player:move(dx, dy)
        visible_range(PLAYER_VISIBLE_RANGE)
    end
end

function visible_range(range)
    objectmap[player.x][player.y].visibility = fog_visible

    for x, arr in pairs(objectmap) do
        for y, til in pairs(arr) do
            if til.visibility == fog_visible then
                til.visibility = fog_visited
            end
        end
    end

    for k,v in pairs(DIRECTION) do
        fov_cast_light(1, 1, 0, 0, v[1], v[2], 0, range)
        fov_cast_light(1, 1, 0, v[1], 0, 0, v[2], range)
    end
end

function fov_cast_light(row, cstart, cend, xx, xy, yx, yy, range)
    local startx = player.x
    local starty = player.y
    local radius = range
    local start = cstart
    
    local new_start = 0
    if start < cend then
        return
    end

    local width = table.maxn(objectmap)
    local height = table.maxn(objectmap[1])

    local blocked = false
    for distance = row, radius do
        local deltay = distance * -1
        for deltax = distance * -1, 0 do
            local currentx = startx + deltax * xx + deltay * xy
            local currenty = starty + deltax * yx + deltay * yy
            local leftslope = (deltax - .5) / (deltay +.5)
            local rightslope = (deltax + .5) / (deltay - .5)

            if not (currentx >= 0 and currenty >= 0 and currentx < width and currenty < height) or start < rightslope then
                --Continue
            elseif cend > leftslope then
                break;
            else
                if square_radius(deltax, deltay, 0) <= radius then
                    objectmap[currentx][currenty].visibility = fog_visible
                end

                if blocked then
                    if objectmap[currentx][currenty].block_sight then
                        new_start = rightslope
                        --Continue
                    else 
                        blocked = false
                        start = new_start
                    end
                else
                    if objectmap[currentx][currenty].block_sight and distance < radius then
                        blocked = true
                        fov_cast_light(distance + 1, start, leftslope, xx, xy, yx, yy, range)
                        new_start = rightslope
                    end
                end
            end
        end
        if blocked then
            break
        end
    end
end

function square_radius(x, y, z)
    local dx = math.abs(x)
    local dy = math.abs(y)
    local dz = math.abs(z)
    return math.sqrt(dx*dx + dy*dy + dz*dz)
end

--PROGRESSION
function check_level_up()
    local needed = LEVEL_UP_BASE + player.level * LEVEL_UP_FACTOR
    if player.fighter.xp >= needed then
        player.level = player.level + 1
        player.fighter.xp = player.fighter.xp - needed
        console_print("Your battle skills grow stronger! You reached level " .. player.level .. "!", color_yellow)
        local pwrbonus = math.random(0, 1)
        local defbonus = math.random(0, 1)
        local hpbonus = math.random(1, 2)
        player.fighter.power = player.fighter.power + pwrbonus
        player.fighter.defense = player.fighter.defense + defbonus
        player.fighter.max_hp = player.fighter.max_hp + hpbonus
        player.fighter.hp = player.fighter.max_hp
        console_print("You gain " .. pwrbonus .. " Power, " .. defbonus .. " Defense, and " .. hpbonus .. " Hitpoints!", color_yellow)
    end
end

function from_dungeon_level(table)
    for k, arr in pairs(table) do
        if dungeon_level >= arr[1] then
            return arr[2]
        end
    end
    return 0
end