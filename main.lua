--modules
local class = require "lib//middleclass"
local G = love.graphics

--constants
SCALE = 16
SCREEN_WIDTH = 80
SCREEN_HEIGHT = 50
MAP_WIDTH = 78
MAP_HEIGHT = 43
ROOM_MAX_SIZE = 10
ROOM_MIN_SIZE = 6
MAX_ROOMS = 30
MAX_ROOM_MONSTERS = 3

--colors
color_player = {200, 50, 50, 255}
color_dark_wall = {0, 0, 200, 255}
color_dark_ground = {100, 100, 250, 255}
color_green = {0, 250, 0, 255}
color_dark_green = {0, 150, 0, 255}

--variables
gameobjects = {}
player_start_x = 0
player_start_y = 0
worldactive = false
objectmap = {}
drawablemap = nil
player = nil
game_state = "playing"
player_action = nil

--TILE
Tile = class("Tile")
function Tile:initialize (blocked)
    self.blocked = blocked
end

--GAMEOBJECT
GameObject = class('GameObject')
function GameObject:initialize(x, y, char, name, color, blocks)
    self.x = x
    self.y = y
    self.char = char
    self.name = name
    self.color = color
    self.blocks = blocks or false
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
    make_map()
    
    player = GameObject(player_start_x, player_start_y, "@", "player", color_player, true)
    table.insert(gameobjects, player)

    --make map into a single image
    drawablemap = map_to_image(objectmap)
end

function love.update(dt)
    if worldactive and game_state == "playing" and player_action ~= "didnt-take-turn" then
        for key,value in pairs(gameobjects) do 
            if value ~= player then
                print("the " .. value.name .. " growls!")
            end 
        end
        worldactive = false
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
        value:draw()
    end
end

function love.keypressed(key)
    if game_state == "playing" then
        worldactive = true

        if key == "escape" then
            player_action = "exit"
        elseif key == "a" or key == "left" then
            player_move_or_attack(-1, 0)
            player_action = "left"
        elseif key == "d" or key == "right" then
            player_move_or_attack(1, 0)
            player_action = "right"
        elseif key == "w" or key == "up" then
            player_move_or_attack(0, -1)
            player_action = "up"
        elseif key == "s" or key == "down" then
            player_move_or_attack(0, 1)
            player_action = "down"
        else
            worldactive = false
            player_action = "didnt-take-turn"
        end     
        
        --draw screen when moving
        if love.graphics and love.graphics.isActive() then
            love.graphics.clear(love.graphics.getBackgroundColor())
            love.graphics.origin()
            if love.draw then love.draw() end
            love.graphics.present()
        end
    end
end

function make_map ()
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
    for x=math.min(x1, x2), math.max(x1, x2)+1 do
        objectmap[x][y].blocked = false
    end
end

function create_v_tunnel(y1, y2, x)
    for y=math.min(y1, y2), math.max(y1, y2)+1 do
        objectmap[x][y].blocked = false
    end
end

function place_objects(room)
    local num_monsters = love.math.random(0, MAX_ROOM_MONSTERS)

    for i=0, num_monsters do
        --choose random spot for this monster
        local x = love.math.random(room.x1, room.x2)
        local y = love.math.random(room.y1, room.y2)
        
         if not is_blocked(x, y) then
            local monster = nil
            if love.math.random(0, 100) < 80 then  --80% chance of getting an orc
                --create an orc
                monster = GameObject(x, y, "o", "Orc", color_green, true)
            else 
                --create a troll
                monster = GameObject(x, y, "T", "Troll", color_dark_green, true)
            end
            table.insert(gameobjects, monster)
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
        if value.x == x and value.y == y then
            target = value
            break
        end
    end

    if target ~= nil then
        print("The " .. target.name .. " laughs at your puny efforts to attack him!")
    else
        player:move(dx, dy)
    end
end