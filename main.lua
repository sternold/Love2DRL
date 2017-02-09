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

--colors
color_player = {200, 50, 50, 255}
color_dark_wall = {0, 0, 200, 255}
color_dark_ground = {100, 100, 250, 255}

--variables
player_start_x = 0
player_start_y = 0
worldactive = false

--TILE
Tile = class("Tile")
function Tile:initialize (blocked, block_sight)
    self.blocked = blocked
    self.block_sight = block_sight or blocked
end

--GAMEOBJECT
GameObject = class('GameObject')
function GameObject:initialize(x, y, char, color)
    self.x = x
    self.y = y
    self.char = char
    self.color = color
    self.colortext = G.newText(G.getFont(), {color, char})
end

function GameObject:move(dx, dy)
    if not objectmap[self.x + dx][self.y + dy].blocked then
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
    cx = (self.x1 + self.x2) / 2
    cy = (self.y1 + self.y2) / 2
    return {center_x = cx, center_y = cy}
end

function Rect:intersect(other)
    return (self.x1 <= other.x2 and self.x2 >= other.x1 and
                self.y1 <= other.y2 and self.y2 >= other.y1)
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
    objectmap = make_map()
    player = GameObject(player_start_x, player_start_y, "@", color_player)

    --make map into a single image
    drawablemap = map_to_image(objectmap)
end

function love.update(dt)
    if worldactive then

    worldactive = false
    end
end


function love.draw()
    --draw map
    G.draw(drawablemap, 1, 1)     

    --draw player
    player:draw(G, SCALE)
end

function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    elseif key == "a" or key == "left" then
        player:move(-1, 0)
    elseif key == "d" or key == "right" then
        player:move(1, 0)
    elseif key == "w" or key == "up" then
        player:move(0, -1)
    elseif key == "s" or key == "down" then
        player:move(0, 1)
    end
    
    if love.graphics and love.graphics.isActive() then
		love.graphics.clear(love.graphics.getBackgroundColor())
		love.graphics.origin()
		if love.draw then love.draw() end
		love.graphics.present()
	end
    
    worldactive = true
end

function make_map ()
    map = {}
    for i=1, MAP_WIDTH do
        map[i] = {} 
        for j=1, MAP_HEIGHT do
            tile = Tile(true)
            map[i][j] = tile
        end
    end

    --random dungeon generation
    rooms = {}
    for r=0, MAX_ROOMS do
        --random width and height
        w = love.math.random(ROOM_MIN_SIZE, ROOM_MAX_SIZE)
        h = love.math.random(ROOM_MIN_SIZE, ROOM_MAX_SIZE)
        --random position without going out of the boundaries of the map
        x = love.math.random(0, MAP_WIDTH - w - 1)
        y = love.math.random(0, MAP_HEIGHT - h - 1)

        new_room = Rect(x, y, w, h)
        failed = false
        for x=1, table.maxn(rooms) do
            if new_room:intersect(rooms[x]) then
                failed = true
                break
            end
        end
        if(not failed) then
            create_room(map, new_room)
            new_room_center = new_room:center()
            new_x = new_room_center.center_x
            new_y = new_room_center.center_y

            if table.maxn(rooms) == 0 then
                player_start_x = new_x
                player_start_y = new_y
            else    
                prev_room_center = rooms[num_rooms-1]:center()
                prev_x = prev_room_center.center_x
                prev_y = prev_room_center.center_y

                if love.math.random(0, 1) == 1 then
                    create_h_tunnel(map, prev_x, new_x, prev_y)
                    create_v_tunnel(map, prev_y, new_y, new_x)
                else
                    create_v_tunnel(map, prev_y, new_y, prev_x)
                    create_h_tunnel(map, prev_x, new_x, new_y)
                end
            table.insert(rooms, new_room)      
            end
        end
    end

    return map
end

function create_room(map, room)
    for x=room.x1+1, room.x2 do
        for y=room.y1+1, room.y2 do
            map[x][y].blocked = false
            map[x][y].block_sight = false
        end
    end
end

function create_h_tunnel(map, x1, x2, y)
    for x=math.min(x1, x2), math.max(x1, x2)+1 do
        map[x][y].blocked = false
        map[x][y].block_sight = false
    end
end

function create_v_tunnel(map, y1, y2, x)
    for y=math.min(y1, y2), math.max(y1, y2)+1 do
        map[x][y].blocked = false
        map[x][y].block_sight = false
    end
end

function map_to_image(map)
    tile = map[1][1]
    char = tile_to_colortext(tile)
    text = G.newText(G.getFont(), char)
    for i=1, table.maxn(map) do
        for j=2, table.maxn(map[i]) do
            tile = map[i][j]
            colortext = tile_to_colortext(tile)           
            text:add(colortext, i*SCALE, j*SCALE)
        end
    end
    return text
end

function tile_to_colortext(tile)
    wall = tile.block_sight
    colortext = {{255, 255, 255, 255}, "?"}
    if wall then
        char = {color_dark_wall, "#"}
    else
        char = {color_dark_ground, "."}
    end 
    return char
end

