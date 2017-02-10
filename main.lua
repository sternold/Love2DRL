--modules
local class = require "lib//middleclass"
local G = love.graphics

--constants
ALPHABET = {"a", "b", "c", "d", "e", "f","g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"}
SCALE = 16
SCREEN_WIDTH = 80
SCREEN_HEIGHT = 50
MAP_WIDTH = 78
MAP_HEIGHT = 43
ROOM_MAX_SIZE = 10
ROOM_MIN_SIZE = 6
MAX_ROOMS = 30
MAX_ROOM_MONSTERS = 2
BAR_WIDTH = 20
BAR_Y = 0
MAX_ROOM_ITEMS = 2
INVENTORY_WIDTH = 60
HEAL_AMOUNT = 4
LIGHTNING_RANGE = 5
LIGHTNING_DAMAGE = 20
CONFUSION_DURATION = 10
FIREBALL_DAMAGE = 30

--colors
color_background = {255, 255, 255, 255}
color_text = {255, 255, 255, 255}
color_player = {200, 50, 50, 255}
color_dark_wall = {0, 0, 200, 255}
color_dark_ground = {100, 100, 250, 255}
color_green = {0, 250, 0, 255}
color_dark_green = {0, 150, 0, 255}
color_dark_red = {150, 0, 0, 255}
color_red = {250, 0, 0, 255}
color_grey = {200, 200, 200, 255}
color_violet = {200, 0, 150, 255}
color_menu = {200, 200, 200, 200}
color_light_yellow = {200, 200, 0, 255}
color_dark_yellow = {125, 125, 0, 245}

--variables
gameobjects = {}
player_start_x = 0
player_start_y = 0
worldactive = false
objectmap = {}
game_state = "playing"
player_action = ""
menu_active = false
monster_count = 0
aimable_spell = nil
direction = "none"

inventory = {}

--TILE
Tile = class("Tile")
function Tile:initialize (blocked)
    self.blocked = blocked
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
    G.draw(self.colortext, self.x*SCALE, self.y*SCALE)
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
function Fighter:initialize(hp, defense, power, death_function)
    self.max_hp = hp
    self.hp = hp
    self.defense = defense
    self.power = power
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
    console_print("Death is inevitable.")

    target.char = '%'
    target.color = color_dark_red
    target.colortext = G.newText(G.getFont(),{target.color, target.char})
    draw_screen()
end

function monster_death(target)
    console_print(target.name .. ' is dead!')
    target.char = '%'
    target.color = color_dark_red
    target.colortext = G.newText(G.getFont(),{target.color, target.char})
    target.blocks = false
    target.fighter = nil
    target.ai = nil
    target.name = 'remains of ' .. monster.name
    monster_count = monster_count - 1
end

--BASICMONSTER
BasicMonster = class('BasicMonster')
function BasicMonster:initialize()
end

function BasicMonster:take_turn()
    monster = self.owner
 
    if monster:distance_to(player) >= 2 then
        monster:move_towards(player.x, player.y)
    elseif player.fighter.hp > 0 then
        monster.fighter:attack(player)
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
        console_print("You picked up a " .. self.owner.name .. "!")
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
    console_print("you dropped a " .. self.owner.name .. ".")
end

function cast_heal()
    if player.fighter.hp == player.fighter.max_hp then
        console_print("You're already at full health")
        return "cancelled"
    end
    console_print("You're starting to feel better!")
    player.fighter:heal(HEAL_AMOUNT)
end

function cast_lightning()
    local monster = closest_monster(LIGHTNING_RANGE)
    if monster == nil then
        console_print("No enemy in range.")
        return "cancelled"
    end

    console_print("A lightning bolt strikes the " .. monster.name .. ", dealing " .. LIGHTNING_DAMAGE .. " damage!")
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
            console_print("The " .. target.name .. "takes 30 fire damage!")
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
    local monster = closest_monster(LIGHTNING_RANGE)
    if monster == nil then
        console_print("No enemy in range.")
        return "cancelled"
    end

    console_print("The " .. monster.name .. " seems dazed and confused!")
    add_invocation(monster, CONFUSION_DURATION, invoke_confusion)
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
        console_print("The confusion has ended.")
        invocation.owner.ai = invocation.old_ai
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
    console_print("The " .. self.owner.name .. " stumbles around!")
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
    love.window.setTitle("Roguelike")
    love.window.setMode(SCREEN_WIDTH*SCALE, SCREEN_HEIGHT*SCALE)
    love.keyboard.setKeyRepeat(true)
    G.setFont(G.newFont("PS2P-R.ttf", SCALE))

    --initialize
    console_log = {}
    make_map()
    
    local fighter_component = Fighter(30, 2, 5, player_death)
    player = GameObject(player_start_x, player_start_y, "@", "player", color_player, true, fighter_component, nil)
    table.insert(gameobjects, player)

    --make map into a single image
    drawablemap = map_to_image(objectmap)

    console_print("Welcome stranger, be prepared to perish in the tombs of LOVE!")
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
        draw_screen()
        worldactive = false
    elseif game_state == "casting" then
        if aimable_spell ~= nil then
            aimable_spell()
        end
    end

    if monster_count == 0 then
        rect_draw("fill", 0, 0, SCREEN_WIDTH, SCREEN_HEIGHT, {0,0,0,200})
        console_print("A WINNER IS YOU!")
        G.draw(G.newText(G.getFont(), {color_text, "A WINNER IS YOU!"}), ((round(SCREEN_WIDTH / 2)) - 10) * SCALE, (round(SCREEN_HEIGHT / 2)) * SCALE)
    end 

    if player_action == "exit" then
        love.event.quit()
    end
end

function love.draw()
    --draw map
    G.draw(drawablemap, 1, 1)

    --draw player
    for key,value in pairs(gameobjects) do 
        if value ~= player then
            value:draw()
        end
    end
    player:draw()

    console_draw()
    stats_draw()

    if game_state == "menu" then
        inventory_menu(player.name .. "'s Inventory")
    elseif game_state == "aiming" then
        if direction == "up" then
            text_draw(color_dark_yellow, "*", player.x, player.y - 1)
        elseif direction == "down" then
            text_draw(color_dark_yellow, "*", player.x, player.y + 1)
        elseif direction == "left" then
            text_draw(color_dark_yellow, "*", player.x - 1, player.y)
        elseif direction == "right" then
            text_draw(color_dark_yellow, "*", player.x + 1, player.y)
        end
    end
end

function love.keypressed(key)
    if game_state == "playing" then
        worldactive = true
        if key == "left" then
            player_move_or_attack(-1, 0)
            player_action = "left"
        elseif key == "right" then
            player_move_or_attack(1, 0)
            player_action = "right"
        elseif key == "up" then
            player_move_or_attack(0, -1)
            player_action = "up"
        elseif key == "down" then
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
        else 
            game_state = "playing"
            draw_screen()
        end
    elseif game_state == "aiming" then
        if key == "c" then
            game_state = "casting"
        else
            direction = key
        end
        draw_screen()
    end
    if key == "escape" then
        player_action = "exit"
    elseif key == "i" then
        if game_state == "playing" then
            game_state = "menu"
            player_action = "inventory"
        end
        draw_screen()
    elseif key == "d" then
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

--MISC
function round(number)
    local toround = number - math.floor(number)
    if toround >= .5 then
        return math.ceil(number)
    else
        return math.floor(number)
    end
end

function console_print(string)
    print(string)
    table.insert(console_log, string)
end

function menu(header, options, width)
    if table.maxn(options) > 26 then
        error("Cannot have a menu with more than 26 options")
    end
    local x = 2
    local y = 2
    local height = table.maxn(options) + 2
    rect_draw("fill", x, y, width, height, color_menu)
    rect_draw("line", x, y, width, height, color_text)

    G.draw(G.newText(G.getFont(), {color_text, header}), x * SCALE + 4, y * SCALE + 4)

    for i=1, table.maxn(options) do
        text = "(" .. ALPHABET[i] .. ") " .. options[i]
        G.draw(G.newText(G.getFont(), {color_text, text}), x * SCALE + 4, (y + i) * SCALE + 4)
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

function index_of(table, object)
    for key, value in pairs(table) do
        if value == object then
            return key
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
    return closest_enemy
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

--DRAWING
function console_draw()
    local count = table.maxn(console_log)
    local max = 1
    if count < 5 then
        max = count
    else
        max = 5
    end
    for i=1, max do
        G.draw(G.newText(G.getFont(), {color_text, console_log[count + 1 - i]}), SCALE, SCREEN_HEIGHT * SCALE - 1 - SCALE * i)
    end
end

function stats_draw()
    --HP
    bar_draw(1, BAR_Y, BAR_WIDTH, "HP", player.fighter.hp, player.fighter.max_hp, color_red, color_grey)
    
end

function bar_draw(x, y, total_width, name, value, maximum, bar_color, back_color)
    --render a bar (HP, experience, etc). first calculate the width of the bar
    local bar_width = round(value / maximum * total_width)
 
    --render the background first
    rect_draw("fill", x, y, total_width, 1, back_color)
 
    --now render the bar on top
    rect_draw("fill", x, y, bar_width, 1, bar_color)

    local string = name .. ": " .. value .. "/" .. maximum
    G.draw(G.newText(G.getFont(), {color_text, string}), x * SCALE, y * SCALE + 4)
end

function rect_draw(mode, x, y, w, h, color)
    G.setColor(color)
    G.rectangle(mode, x * SCALE, y * SCALE, w * SCALE, h * SCALE)
    G.setColor(color_background)
end

function text_draw(color, text, x, y)
    G.draw(G.newText(G.getFont(), {color, text}), x * SCALE, y * SCALE)
end

--MAP
function make_map()
    for x=1, MAP_WIDTH, 1 do
        table.insert(objectmap, x, {}) 
        for y=1, MAP_HEIGHT, 1 do
            table.insert(objectmap[x], y, Tile(true)) 
        end
    end

    --random dungeon generation
    local rooms = {}
    for rums=0, MAX_ROOMS do
        --random width and height
        local w = love.math.random(ROOM_MIN_SIZE, ROOM_MAX_SIZE)
        local h = love.math.random(ROOM_MIN_SIZE, ROOM_MAX_SIZE)
        --random position without going out of the boundaries of the map
        local x = love.math.random(1, MAP_WIDTH - w - 1)
        local y = love.math.random(1, MAP_HEIGHT - h - 1)

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
end

function create_room(room)
    for x=room.x1+1, room.x2 do
        for y=room.y1+1, room.y2 do
            objectmap[x][y].blocked = false
        end
    end
end

function create_h_tunnel(x1, x2, y)
    for x=math.min(x1, x2), math.max(x1, x2) do
        objectmap[x][y].blocked = false
    end
end

function create_v_tunnel(y1, y2, x)
    for y=math.min(y1, y2), math.max(y1, y2) do
        objectmap[x][y].blocked = false
    end
end

function place_objects(room)
    local num_monsters = love.math.random(0, MAX_ROOM_MONSTERS)

    for i=0, num_monsters do
        --choose random spot for this monster
        local x = love.math.random(room.x1+1, room.x2-1)
        local y = love.math.random(room.y1+1, room.y2-1)
        
         if not is_blocked(x, y) then
            local monster = nil
            if love.math.random(0, 100) < 80 then  --80% chance of getting an orc
                --create an orc
                local fighter_component = Fighter(10, 0, 3, monster_death)
                local ai_component = BasicMonster()
                monster = GameObject(x, y, "o", "Orc", color_green, true, fighter_component, ai_component)
            else 
                --create a troll
                local fighter_component = Fighter(16, 1, 4, monster_death)
                local ai_component = BasicMonster()
                monster = GameObject(x, y, "T", "Troll", color_dark_green, true, fighter_component, ai_component)
            end
            monster_count = monster_count + 1
            table.insert(gameobjects, monster)
        end 
    end

    --choose random number of items
    local num_items = love.math.random(0, MAX_ROOM_ITEMS)
 
    for i=0, num_items do
        --choose random spot for this item
        local x = love.math.random(room.x1+1, room.x2-1)
        local y = love.math.random(room.y1+1, room.y2-1)
 
        --only place it if the tile is not blocked
        if not is_blocked(x, y) then
            local item = nil

            dice = love.math.random(0, 100)
            if dice < 40 then
                local item_component = Item(cast_heal)
                item = GameObject(x, y, '!', 'healing potion', color_violet, false, nil, nil, item_component)
            elseif dice > 40 and dice < 50 then
                local item_component = Item(cast_confusion)
                item = GameObject(x, y, '#', 'Scroll of Confusion', color_violet, false, nil, nil, item_component)   
            elseif dice > 50 and dice < 75 then
                local item_component = Item(cast_fireball)
                item = GameObject(x, y, '#', 'Scroll of Fireball', color_dark_red, false, nil, nil, item_component)   
            else
                local item_component = Item(cast_lightning)
                item = GameObject(x, y, '#', 'Scroll of Lighning Bolt', color_light_yellow, false, nil, nil, item_component)
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
        colortext = {color_dark_wall, "#"}
    else
        colortext = {color_dark_ground, "."}
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
        player.fighter:attack(target)
    else
        player:move(dx, dy)
    end
end