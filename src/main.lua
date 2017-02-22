--modules
class = require("libraries/middleclass")
bitser = require("libraries/bitser")
require("libraries/util")
require("libraries/extendedgraphics")
require("resources/colors")
require("resources/invocations")
require("classes/Tile")
require("classes/Rect")
require("classes/GameObject")
require("constants")
require("game")

--function containers
graphics = love.graphics
config = {}

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
    bitser.registerClass(Tile)
    bitser.registerClass(Rect)
    bitser.registerClass(GameObject)
    bitser.registerClass(Fighter)
    bitser.registerClass(BasicMonster)
    bitser.registerClass(ConfusedMonster)
    bitser.registerClass(Item)
    bitser.registerClass(Equipment)
    bitser.registerClass(Invocation)
    game_reg()
    inv_reg()
    obj_reg()
    local item_factory = require("resources/items")
    item_reg()

    --config
    love.filesystem.createDirectory(love.filesystem.getSaveDirectory())
    config = load_config()
    
    --options
    love.window.setMode(SCREEN_WIDTH*SCALE, SCREEN_HEIGHT*SCALE)
    love.keyboard.setKeyRepeat(true)
    graphics.setFont(graphics.newFont("resources/font/main.ttf", SCALE))

    --initialize
    game.state.base = STATE.pre_game
    game.state.pre_game = PRE_GAME_STATE.main
    graphics.draw_screen()
end

function love.update(dt)
    if game.state.base == STATE.pre_game then
        if game.state.pre_game == PRE_GAME_STATE.main then

        elseif game.state.pre_game == PRE_GAME_STATE.config then

        elseif game.state.pre_game == PRE_GAME_STATE.new_game then
            game.new_game()
        elseif game.state.pre_game == PRE_GAME_STATE.load_game then
            game.load_game()
        elseif game.state.pre_game == PRE_GAME_STATE.exit then

        end
    elseif game.state.base == STATE.playing then
        if game.state.playing == PLAYING_STATE.active then
            game.state.playing = PLAYING_STATE.waiting
            for key,value in pairs(game.map.objects) do 
                if value.ai then
                    for k, v in pairs(value.fighter.invocations) do
                        v:invoke()
                    end
                    value.ai:take_turn()
                end 
            end
            for k, v in pairs(game.player.character.fighter.invocations) do
                v:invoke()
            end
            graphics.draw_screen()
        elseif game.state.playing == PLAYING_STATE.waiting then

        elseif game.state.playing == PLAYING_STATE.casting then

        elseif game.state.playing == PLAYING_STATE.dead then
            game.state.base = STATE.cutscene
            game.state.cutscene = CUTSCENE_STATE.dead
            graphics.draw_screen()
        end
    elseif game.state.base == STATE.menu then
        if game.state.menu == MENU_STATE.inventory then

        elseif game.state.menu == MENU_STATE.dropping then

        elseif game.state.menu == MENU_STATE.level_up then

        end
    elseif game.state.base == STATE.paused then
    elseif game.state.base == STATE.cutscene then
        if game.state.cutscene == CUTSCENE_STATE.begin then

        elseif game.state.cutscene == CUTSCENE_STATE.won then

        elseif game.state.cutscene == CUTSCENE_STATE.dead then

        end
    end
end

function love.draw()
    if game.state.base == STATE.pre_game then
        if game.state.pre_game == PRE_GAME_STATE.main then
            main_menu()
        elseif game.state.pre_game == PRE_GAME_STATE.config then
            config_menu()
        elseif game.state.pre_game == PRE_GAME_STATE.new_game then

        elseif game.state.pre_game == PRE_GAME_STATE.load_game then

        elseif game.state.pre_game == PRE_GAME_STATE.exit then

        end
    elseif game.state.base == STATE.playing then
        world_draw()
        UI_draw()
        if draw_visible_list then list_visible_objects() end
        if draw_tutorial then list_tutorial() end
        
        if game.state.playing == PLAYING_STATE.active then

        elseif game.state.playing == PLAYING_STATE.waiting then

        elseif game.state.playing == PLAYING_STATE.casting then
            aim_draw()
        elseif game.state.playing == PLAYING_STATE.dead then

        end
    elseif game.state.base == STATE.menu then
        world_draw()
        UI_draw()
        if game.state.menu == MENU_STATE.inventory then
            inventory_menu(game.player.character.name .. "'s Inventory")
        elseif game.state.menu == MENU_STATE.dropping then
            inventory_menu("Drop item: ")
        elseif game.state.menu == MENU_STATE.level_up then
            level_up_menu()
        end
    elseif game.state.base == STATE.paused then
        game_over("Press ESC again to save and exit...")
    elseif game.state.base == STATE.cutscene then
        if game.state.cutscene == CUTSCENE_STATE.begin then
            --TODO
        elseif game.state.cutscene == CUTSCENE_STATE.won then
            game_over("A WINNER IS YOU.\npress any key to continue...")
        elseif game.state.cutscene == CUTSCENE_STATE.dead then
            world_draw()
            game_over("Death is inevitable.\npress R to restart...")
        end
    end
end

function love.keypressed(key)
    if game.state.base == STATE.pre_game then
        local choice = table.index_of(ALPHABET, key)
        if game.state.pre_game == PRE_GAME_STATE.main then 
            if choice == 1 then
                game.state.pre_game = PRE_GAME_STATE.new_game
            elseif choice == 2 then
                game.state.pre_game = PRE_GAME_STATE.load_game
            elseif choice == 3 then
                game.state.pre_game = PRE_GAME_STATE.config
                graphics.draw_screen()
            elseif choice == 4 then
                game.state.pre_game = PRE_GAME_STATE.exit
            end
        elseif game.state.pre_game == PRE_GAME_STATE.config then
            local keys = {}
            for k,v in pairs(config) do
                table.insert(keys, k)
            end 
            if choice == table.maxn(keys) + 1 then
                    save_config()
                    game.state.pre_game = PRE_GAME_STATE.main
                    graphics.draw_screen()
                else
                    config[keys[choice]] = not config[keys[choice]]
                end
                graphics.draw_screen()
        elseif game.state.pre_game == PRE_GAME_STATE.new_game then
        elseif game.state.pre_game == PRE_GAME_STATE.load_game then
        elseif game.state.pre_game == PRE_GAME_STATE.exit then
        end
    elseif game.state.base == STATE.playing then
        if game.state.playing == PLAYING_STATE.active then
        
        elseif game.state.playing == PLAYING_STATE.waiting then
            game.state.playing = PLAYING_STATE.active
            if key == "left" or key == "kp4" then game.player.move_or_attack(-1, 0)
            elseif key == "right" or key == "kp6" then game.player.move_or_attack(1, 0)       
            elseif key == "up" or key == "kp8" then game.player.move_or_attack(0, -1)      
            elseif key == "down" or key == "kp2" then game.player.move_or_attack(0, 1)
            elseif key == "i" then
                game.state.base = STATE.menu
                game.state.menu = MENU_STATE.inventory
            elseif key == "d" then
                game.state.base = STATE.menu
                game.state.menu = MENU_STATE.dropping
            elseif key == "g" then
                for k, v in pairs(game.map.objects) do
                    if v.item and v.x == game.player.character.x and v.y == game.player.character.y then
                        v.item:pick_up()
                        break
                    end
                end
            elseif key == "," then
                if game.player.character.x == game.map.stairs.x and game.player.character.y == game.map.stairs.y then
                    game.next_level()
                end
            elseif key == "l" then
                game.state.playing = PLAYING_STATE.waiting
                draw_visible_list = not draw_visible_list
                graphics.draw_screen()
            elseif key == "x" then
                game.state.playing = PLAYING_STATE.waiting
                draw_tutorial = not draw_tutorial
                graphics.draw_screen()
            elseif key == "escape" then
                game.state.base = STATE.paused
            else
                game.state.playing = PLAYING_STATE.waiting
            end
            graphics.draw_screen()
        elseif game.state.playing == PLAYING_STATE.casting then
            if key == "c" then
                game.state.playing = PLAYING_STATE.active
                if aimable_spell then
                    aimable_spell()
                end
            else
                if key == "left" or key == "kp4" then
                    direction = DIRECTIONS.left
                elseif key == "right" or key == "kp6" then
                    direction = DIRECTIONS.right
                elseif key == "up" or key == "kp8" then
                    direction = DIRECTIONS.up
                elseif key == "down" or key == "kp2" then
                    direction = DIRECTIONS.down
                end
            end
            graphics.draw_screen()
        elseif game.state.playing == PLAYING_STATE.dead then

        end
    elseif game.state.base == STATE.menu then
        if game.state.menu == MENU_STATE.inventory then
            game.state.base = STATE.playing
            game.state.playing = PLAYING_STATE.waiting
            if game.player.inventory[table.index_of(ALPHABET, key)] then
                game.player.inventory[table.index_of(ALPHABET, key)].item:use();
            end
        elseif game.state.menu == MENU_STATE.dropping then
            game.state.base = STATE.playing
            game.state.playing = PLAYING_STATE.waiting
            if game.player.inventory[table.index_of(ALPHABET, key)] then
                game.player.inventory[table.index_of(ALPHABET, key)].item:drop();
            end
        elseif game.state.menu == MENU_STATE.level_up then
            game.state.base = STATE.playing
            game.state.playing = PLAYING_STATE.waiting
            if table.index_of(ALPHABET, key) == 1 then
                game.player.character.fighter.base_power = game.player.character.fighter.base_power + 1
                game.console.print("You gain 1 Power!", color_yellow)
                game.player.character.fighter.hp = game.player.character.fighter:max_hp()     
                graphics.draw_screen() 
            elseif table.index_of(ALPHABET, key) == 2 then
                game.player.character.fighter.base_defense = game.player.character.fighter.base_defense + 1
                game.console.print("You gain 1 Defense!", color_yellow)
                game.player.character.fighter.hp = game.player.character.fighter:max_hp()     
                graphics.draw_screen() 
            elseif table.index_of(ALPHABET, key) == 3 then
                game.player.character.fighter.base_max_hp = game.player.character.fighter.base_max_hp + 5
                game.console.print("You gain 5 HP!", color_yellow)
                game.player.character.fighter.hp = game.player.character.fighter:max_hp()     
                graphics.draw_screen() 
            else
                game.state.base = STATE.menu
            end
        end
        graphics.draw_screen()
    elseif game.state.base == STATE.paused then
        game.state.base = STATE.playing
        if key == "escape" then
            game.save_game()
            love.event.quit() 
        end
    elseif game.state.base == STATE.cutscene then
        if game.state.cutscene == CUTSCENE_STATE.begin then

        elseif game.state.cutscene == CUTSCENE_STATE.won then
            game.state.base = STATE.pre_game
        elseif game.state.cutscene == CUTSCENE_STATE.dead then
            if key == "r" then
                game.new_game()
            end
        end
    end
end

function graphics.draw_screen()
    --draw screen when moving
    if love.graphics and love.graphics.isActive() then
        love.graphics.clear(love.graphics.getBackgroundColor())
        love.graphics.origin()
        if love.draw then love.draw() end
        love.graphics.present()
    end
end

function graphics.set_fullscreen(toggle)
    if toggle then
        love.window.setFullscreen(true)
        SCALE = math.round(love.graphics.getHeight() / SCREEN_HEIGHT)
    end
end

--init
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

--drawing
function world_draw()
    map_draw()
    for k,v in pairs(game.map.objects) do
        v:draw()
    end
    game.player.character:draw()
end

function map_draw()
    for x, arr in pairs(game.map.tilemap) do
        for y, til in pairs(arr) do
            if til.blocked then
                graphics.rect_draw("fill", x, y, 1, 1, WALL_COLOR)
            else
                graphics.rect_draw("fill", x, y, 1, 1, FLOOR_COLOR)
            end
        end
    end
    fog_of_war()
end

function fog_of_war()
    for x,arr in pairs(game.map.tilemap) do
        for y, til in pairs(arr) do
            graphics.rect_draw("fill", x, y, 1, 1, til.visibility)
        end
    end
end

function UI_draw()
    --level
    graphics.text_draw("LvL " .. game.player.level, 1, SCREEN_HEIGHT - 6, colors.white, 0, 0)
    
    --HP
    graphics.progress_bar_draw(1, STAT_DRAW_Y, 20, "HP", game.player.character.fighter.hp, game.player.character.fighter:max_hp(), colors.light_green, colors.red)

    --xp
    graphics.progress_bar_draw(1,  SCREEN_HEIGHT - 5, 12, "EXP", game.player.character.fighter.xp, (LEVEL_UP_BASE + game.player.level * LEVEL_UP_FACTOR), colors.dark_yellow, colors.grey_5)

    --Attributes
    graphics.text_draw("PWR:" .. game.player.character.fighter:power(), 1, SCREEN_HEIGHT - 3, colors.white, 0, 0)
    graphics.text_draw("DEF:" .. game.player.character.fighter:defense(), 1, SCREEN_HEIGHT - 2, colors.white, 0, 0)
    
    --Dungeon level
    graphics.text_draw("Floor " .. game.map.level, SCREEN_WIDTH - 10, STAT_DRAW_Y, colors.white, 0, 0)

    --console
    console_draw(15)
end

function console_draw(x)
    local count = table.maxn(game.console.log)
    local max = 1
    if count < 5 then
        max = count
    else
        max = 5
    end
    for i=1, max do
        graphics.text_draw(game.console.log[count + 1 - i][1], x, SCREEN_HEIGHT - i - 1, game.console.log[count + 1 - i][2] or nil, 0, 0)
    end
end

function aim_draw()
    graphics.text_draw("*", game.player.character.x + direction.dx, game.player.character.y + direction.dy, colors.yellow, 0, 0)
end

function list_visible_objects()
    local visobj = {}
    for k,v in pairs(game.map.objects) do
        if game.map.tilemap[v.x][v.y].visibility == special_colors.fov_visible then
            table.insert(visobj, {text = "[" .. v.char .. "] " .. v.name, color=v.color})
        end
    end
    graphics.window("you see:", visobj, SCREEN_WIDTH - 40, 5, 35, table.maxn(visobj) + 5)
end

function list_tutorial()
    local tutorial = {}
    table.insert(tutorial, 1, {text="Press the ARROW keys to move.", color=color_white})
    table.insert(tutorial, 3, {text="Press G to pick up items.", color=color_white})
    table.insert(tutorial, 5, {text="Press I to open your inventory.", color=color_white})
    table.insert(tutorial, 7, {text="Press D to drop an item.", color=color_white})
    table.insert(tutorial, 9, {text="Press the corresponding letter to select an option inside a menu.", color=color_white})
    table.insert(tutorial, 11, {text="While casting aimable spells, press the arrow keys to aim, and C to cast.", color=color_white})
    table.insert(tutorial, 13, {text="Press Comma (,) to move down stairs.", color=color_white})
    table.insert(tutorial, 15, {text="Press L to look around.", color=color_white})
    table.insert(tutorial, 17, {text="Press R to restart when you've died.", color=color_white})
    table.insert(tutorial, 19, {text="Press ESC to save and exit.", color=color_white})
    table.insert(tutorial, 21, {text="Reach floor 10 and defeat all the monsters there to win!", color=color_white})
    table.insert(tutorial, 35, {text="Press the X to close or open this tutorial.", color=color_white})
    graphics.window("TUTORIAL", tutorial, 3, 3, SCREEN_WIDTH - 6, SCREEN_HEIGHT - 10)
end

function inventory_menu(header)
    local options = {}
    if table.maxn(game.player.inventory) ==0 then
        table.insert(options, "Inventory is empty.")
    else
        for key, value in pairs(game.player.inventory) do
            local text = value.name
            if value.equipment ~= nil and value.equipment.is_equipped then
                text = text .. " (on " .. value.equipment.slot .. ")"
            end
            table.insert(options, text)
        end
    end
    graphics.menu(header, options, INVENTORY_WIDTH)
end

function main_menu()
    graphics.menu("TOMB OF KING LOVE by Sternold", {"New Game", "Continue", "Configuration", "Quit"}, 32)
end

function config_menu()
    local options = {}
    for k,v in pairs(config) do
        local boolstring = nil
        if v then
            boolstring = "on"
        else
            boolstring = "off"
        end
        table.insert(options, k .. " = " .. boolstring)
    end
        table.insert(options, "Back")
     graphics.menu("Configuration", options, 32)
end

function level_up_menu()
    graphics.menu("What have you trained?", {"My Power", "My Defense", "My Courage"}, 32)
end

function game_over(text)
        graphics.rect_draw("fill", 0, 0, SCREEN_WIDTH, SCREEN_HEIGHT, {0,0,0,100})
        game.console.print(text, colors.yellow)
        graphics.draw(graphics.newText(graphics.getFont(), {colors.white, text}), ((math.round(SCREEN_WIDTH / 2)) - 10) * SCALE, (math.round(SCREEN_HEIGHT / 2)) * SCALE)
end
