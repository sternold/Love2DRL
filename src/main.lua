--modules
class = require("libraries/middleclass")
bitser = require("libraries/bitser")
console = require("libraries/loveconsole")
screenmanager = require("libraries/screenmanager")
require("libraries/util")
require("libraries/colors")
require("game/dungeon/classes/Tile")
require("game/dungeon/classes/Rect")
require("game/dungeon/classes/Map")
require("game/classes/GameObject")
require("game/classes/Item")
require("game/classes/AI")
require("game/classes/Fighter")
require("game/classes/Equipment")
require("game/classes/Invocation")
require("game/classes/Player")
require("constants")

game = require("game/game")

function register()
    bitser.registerClass(Map)
    bitser.registerClass(Player)
    bitser.registerClass(Tile)
    bitser.registerClass(Rect)
    bitser.registerClass(GameObject)
    bitser.registerClass(Fighter)
    bitser.registerClass(BasicMonster)
    bitser.registerClass(ConfusedMonster)
    bitser.registerClass(Item)
    bitser.registerClass(Equipment)
    bitser.registerClass(Invocation)
    inv_reg()
    fit_reg()
    item_reg()
end

--engine
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
    --binser
    register()

    --config
    love.filesystem.createDirectory(love.filesystem.getSaveDirectory())
    config = load_config()
    
    --window
    console.init(80, 50, 16)
    love.keyboard.setKeyRepeat(true)

    --initialize screen manager
    local screens = {
        main = require("screens/mainscreen"),
        game = require("screens/gamescreen"),
        mainmenu = require("screens/menus/mainmenu"),
        config = require("screens/menus/config"),
        inventory = require("screens/menus/inventory"),
        levelup = require("screens/menus/levelup"),
        pause = require("screens/menus/pausemenu"),
        classselect = require("screens/menus/classselect"),
        tutorial = require("screens/overlays/tutorial"),
        gameover = require("screens/overlays/gameover"),
        casting = require("screens/overlays/casting")
        
    }
    screenmanager.init(screens, "main")
    screenmanager.registerCallbacks()
    screenmanager.push("mainmenu")
end

function love.update(dt)
    screenmanager.update(dt)
end

function love.draw()
    screenmanager.draw()
end

--config init
function save_config()
    bitser.dumpLoveFile(CONFIG_FILE, config)
end

function load_config()
    if not love.filesystem.isFile(CONFIG_FILE) then
        local config_default = {fullscreen=false, tutorial=true}
        bitser.dumpLoveFile(CONFIG_FILE, config_default)
        print("Default config loaded.")
    end
    return bitser.loadLoveFile(CONFIG_FILE)
end