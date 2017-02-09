--modules
local class = require "lib//middleclass"
local G = love.graphics

--constants
SCALE = 16
SCREEN_WIDTH = 80
SCREEN_HEIGHT = 50
MAP_WIDTH = 78
MAP_HEIGHT = 43

--colors
color_player = {200, 50, 50, 255}
color_dark_wall = {0, 0, 200, 255}
color_dark_ground = {100, 100, 250, 255}

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
end

function GameObject:move(dx, dy)
    if not map[self.x + dx][self.y + dy].blocked then
        self.x = self.x + dx
        self.y = self.y + dy
    end
end

function GameObject:draw()
    G.setColor(self.color)
    G.draw(G.newText(G.getFont(), self.char), self.x*SCALE, self.y*SCALE)
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
    map = make_map()
    player = GameObject:new(SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2, "@", color_player)

    --test
    map[30][22].blocked = true
    map[30][22].block_sight = true
    map[50][22].blocked = true
    map[50][22].block_sight = true
end

function love.update(dt)
    if worldactive then

    worldactive = false
    end
end


function love.draw()
    --draw map
    for i=1, table.maxn(map) do
        for j=1, table.maxn(map[i]) do
            tile = map[i][j]
            wall = tile.block_sight
            char = "?"
            if wall then
                G.setColor(color_dark_wall)
                char = "#"
            else
                G.setColor(color_dark_ground)
                char = "."
            end  
            G.draw(G.newText(G.getFont(), char), i*SCALE, j*SCALE)     
        end
    end

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
            tile = Tile:new(false)
            map[i][j] = tile
        end
    end
    return map
end

