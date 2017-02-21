--function containers
game = {}
game.map = {}
game.player = {}
game.console = {}
game.state = {}

--variables
local aimable_spell = nil
local direction = DIRECTIONS.none

--init
function game.new_game()
    graphics.set_fullscreen(config.fullscreen)
    
    game.state.base = STATE.playing
    game.state.playing = PLAYING_STATE.waiting   
    game.player.inventory = {}
    game.console.log = {}
    game.map.level = 1
    game.map.make_map()

    --player initialization
    local fighter_component = Fighter(100, 0, 2, 0, player_death)
    game.player.character = GameObject(player_start_x, player_start_y, "@", "player", colors.yellow, true, fighter_component, nil)
    game.player.level = 1
    game.player.visible_range(PLAYER_VISIBILITY_RANGE)

    --Welcome message
    game.console.print("Welcome stranger, be prepared to perish in the tombs of LOVE!", colors.red)

    --starting gear
    --dagger
    local equipment_component = Equipment('right hand', 1, 0, 0)
    local item = GameObject(0, 0, '-', 'dagger', colors.grey_2, false, nil, nil, nil, equipment_component)
    table.insert(game.player.inventory, item)
    item.equipment:equip()
    --cloak
    local equipment_component = Equipment('back', 0, 1, 0)
    local item = GameObject(0, 0, '\\', 'Cloak of Protection', colors.light_purple, false, nil, nil, nil, equipment_component)
    table.insert(game.player.inventory, item)
    item.equipment:equip()

    draw_tutorial = config.tutorial
    graphics.draw_screen()
end

function game.next_level()
    console_print("You take a moment to rest...", colors.red)
    dungeon_level = dungeon_level + 1
    make_map()
    player.x = player_start_x
    player.y = player_start_y
    visible_range(PLAYER_VISIBILITY_RANGE)
    drawablemap = map_to_image(objectmap)
    graphics.draw_screen()
end

--deprecated
function game.save_game()
    if game_state == "dead" or player == nil then
        return
    end
    local savedata = {}
    table.insert(savedata, 1, objectmap)
    table.insert(savedata, 3, gameobjects)
    table.insert(savedata, 4, player)
    table.insert(savedata, 5, inventory)
    table.insert(savedata, 6, console_log)
    table.insert(savedata, 7, game_state)
    persistence.store(love.filesystem.getSaveDirectory() .. "/" .. SAVE_FILE, savedata)
end

--deprecated
function game.load_game()
    if love.filesystem.isFile(SAVE_FILE) then
        set_fullscreen(config.fullscreen)
        local savedata = persistence.load(love.filesystem.getSaveDirectory() .. "/" .. SAVE_FILE)
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
            local lequipment = nil
            if v.fighter ~= nil then
                lfighter = Fighter(v.fighter.base_max_hp, v.fighter.base_defense, v.fighter.base_power, v.fighter.xp, monster_death)
                lfighter.hp = v.fighter.hp
            end
            if v.ai ~= nil then
                lai = BasicMonster()
            end
            if v.item ~= nil then
                litem = Item(v.item.use_function)
            end
            if v.equipment ~= nil then
                lequipment = Equipment(v.equipment.slot)
                lequipment.is_equipped = v.equipment.is_equipped
                lequipment.max_hp_bonus = v.equipment.max_hp_bonus
                lequipment.power_bonus = v.equipment.power_bonus
                lequipment.defense_bonus = v.equipment.defense_bonus
            end
            local lgameobject = GameObject(v.x, v.y, v.char, v.name, v.color, v.blocks, lfighter, lai, litem, lequipment)
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
        local fighter = Fighter(lfighter.base_max_hp, lfighter.base_defense, lfighter.base_power, lfighter.xp, player_death)
        fighter.hp = lfighter.hp
        player = GameObject(lplayer.x, lplayer.y, lplayer.char, "player", colors.player, true, fighter, nil, nil)
        player.level = lplayer.level
        
        --load inventory
        inventory = {}
        local linventory = savedata[5]
        for k,v in pairs(linventory) do
            local litem_component = nil
            local lequipment = nil
            if v.item ~= nil then
                litem_component = Item(v.item.use_function)
            end
            if v.equipment ~= nil then
                lequipment = Equipment(v.equipment.slot)
                lequipment.is_equipped = v.equipment.is_equipped
                lequipment.max_hp_bonus = v.equipment.max_hp_bonus
                lequipment.power_bonus = v.equipment.power_bonus
                lequipment.defense_bonus = v.equipment.defense_bonus
            end
            local litem = GameObject(v.x, v.y, v.char, v.name, v.color, false, nil, nil, litem_component, lequipment)
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
        graphics.draw_screen()
    else
        print("no save data could be found.")
        no_save_data = true       
        graphics.draw_screen()
    end
end

--console
function game.console.print(string, color)
    print(string)
    table.insert(game.console.log, {string, color})
end

--map
function game.map.make_map()
    game.map.objects = {}
    game.map.tilemap = {}
    
    for x=1, MAP_WIDTH, 1 do
        table.insert(game.map.tilemap, x, {}) 
        for y=1, MAP_HEIGHT, 1 do
            table.insert(game.map.tilemap[x], y, Tile(true)) 
        end
    end

    --random dungeon generation
    local rooms = {}
    local x = 0
    local y = 0
    game.map.monster_count = 0
    for r=0, MAX_ROOMS do
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
        if not failed then
            game.map.create_room(new_room)
            game.map.place_objects(new_room)
            new_x, new_y = new_room:center()

            if table.maxn(rooms) == 0 then
                player_start_x = new_x
                player_start_y = new_y
            else    
                prev_x, prev_y = rooms[table.maxn(rooms)]:center()
                if love.math.random(0, 1) == 1 then
                    game.map.create_h_tunnel(prev_x, new_x, prev_y)
                    game.map.create_v_tunnel(prev_y, new_y, new_x)
                else
                    game.map.create_v_tunnel(prev_y, new_y, prev_x)
                    game.map.create_h_tunnel(prev_x, new_x, new_y)
                end                   
            end
            table.insert(rooms, new_room)
        end
    end
    while game.map.tilemap[x][y].blocked do
        local dx = love.math.random(-1, 1)
        local dy = love.math.random(-1, 1)
        if game.map.tilemap[x + dx] == nil or game.map.tilemap[x + dx][y + dy] == nil then
            x = love.math.random(2, MAP_WIDTH - 1)
            y = love.math.random(2, MAP_HEIGHT - 1)
        end
        x = x + dx
        y = y + dy
    end
    if dungeon_level == END_FLOOR then
        game.map.stairs = GameObject(1, 1, "<", "stairs", colors.white)
    end
    table.insert(game.map.objects, game.map.stairs)
end

function game.map.create_room(room)
    for x=room.x1+1, room.x2 do
        for y=room.y1+1, room.y2 do
            game.map.tilemap[x][y].blocked = false
            game.map.tilemap[x][y].block_sight = false
        end
    end
end

function game.map.create_h_tunnel(x1, x2, y)
    for x=math.min(x1, x2), math.max(x1, x2) do
        game.map.tilemap[x][y].blocked = false
        game.map.tilemap[x][y].block_sight = false
    end
end

function game.map.create_v_tunnel(y1, y2, x)
    for y=math.min(y1, y2), math.max(y1, y2) do
        game.map.tilemap[x][y].blocked = false
        game.map.tilemap[x][y].block_sight = false
    end
end

function game.map.place_objects(room)
    local m = require("resources//monsters")
    local monster_chances = m.chances
    local monster_factory = m.factory
    local i = require("resources//items")
    local item_chances = i.chances
    local item_factory = i.factory
    
    
    --MONSTERS
    local max_monsters = game.map.from_dungeon_level({{1, 2}, {4, 3}, {6, 5}})
 
    --ITEMS
    local max_items = game.map.from_dungeon_level({{1, 1}, {4, 2}})
 

    local num_monsters = love.math.random(0, max_monsters)

    for i=0, num_monsters do
        --choose random spot for this monster
        local x = love.math.random(room.x1+1, room.x2-1)
        local y = love.math.random(room.y1+1, room.y2-1)
        
         if not game.map.is_blocked(x, y) then   
            local choice = random_choice(monster_chances) 
            local monster_func = monster_factory[choice]
            local monster = monster_func(x, y)
            game.map.monster_count = game.map.monster_count + 1
            table.insert(game.map.objects, monster)
        end 
    end

    --choose random number of items
    local num_items = love.math.random(0, max_items)
 
    for i=0, num_items do
        --choose random spot for this item
        local x = love.math.random(room.x1+1, room.x2-1)
        local y = love.math.random(room.y1+1, room.y2-1)
 
        --only place it if the tile is not blocked
        if not game.map.is_blocked(x, y) then
            local item = nil
            local choice = random_choice(item_chances) 
            if choice == "pot_heal" then
                local item_component = Item(cast_heal)
                item = GameObject(x, y, '!', 'healing potion', colors.light_pink, false, nil, nil, item_component)
            
            elseif choice == "fd_bread" then
                local item_component = Item(eat)
                item_component.var.ingredients = {"flour", "milk"}
                item = GameObject(x, y, 'm', 'Bread', colors.dark_orange, false, nil, nil, item_component)
            
            elseif choice == "fd_garlic_bread" then
                local item_component = Item(eat)
                item_component.var.ingredients = {"flour", "milk", "garlic", "cheese"}
                item = GameObject(x, y, 'm', 'Garlic Bread', colors.dark_yellow, false, nil, nil, item_component)
            
            elseif choice == "fd_apple" then
                local item_component = Item(eat)
                item_component.var.ingredients = {"apple"}
                item = GameObject(x, y, 'a', 'Apple', colors.light_red, false, nil, nil, item_component)
            
            elseif choice == "fd_stew" then
                local item_component = Item(eat)
                item_component.var.ingredients = {"pork", "water", "milk", "onions", "garlic"}
                item = GameObject(x, y, 'u', 'Stew', colors.dark_orange, false, nil, nil, item_component)

            elseif choice == "pot_regen" then
                local item_component = Item(cast_regen)
                item = GameObject(x, y, '!', 'Potion of Regeneration', colors.dark_pink, false, nil, nil, item_component)
            
            elseif choice == "scr_confuse" then
                local item_component = Item(cast_confusion)
                item = GameObject(x, y, '#', 'Scroll of Confusion', colors.light_pink, false, nil, nil, item_component)   
            
            elseif choice == "scr_fireball" then
                local item_component = Item(cast_fireball)
                item = GameObject(x, y, '#', 'Scroll of Fireball', colors.dark_red, false, nil, nil, item_component)   
            
            elseif choice == "scr_strength" then
                local item_component = Item(cast_strength)
                item = GameObject(x, y, '#', "Scroll of Giant's Strength", colors.player, false, nil, nil, item_component)   
            
            elseif choice == "scr_lightning" then
                local item_component = Item(cast_lightning)
                item = GameObject(x, y, '#', 'Scroll of Lighning Bolt', colors.yellow, false, nil, nil, item_component)
            
            elseif choice == "scr_lightning_storm" then
                local item_component = Item(cast_lightning_storm)
                item = GameObject(x, y, '#', 'Scroll of Lightning Storm', colors.dark_yellow, false, nil, nil, item_component)
            
            elseif choice == "wpn_s_sword" then
                local equipment_component = Equipment('right hand', 2, 0, 0, nil, nil)
                item = GameObject(x, y, 't', 'shortsword', colors.grey_2, false, nil, nil, nil, equipment_component)
            
            elseif choice == "wpn_l_sword" then
                local equipment_component = Equipment('right hand', 3, 0, 0, nil, nil)
                item = GameObject(x, y, '|', 'longsword', colors.grey_2, false, nil, nil, nil, equipment_component)
            
            elseif choice == "wpn_g_sword" then
                local equipment_component = Equipment('right hand', 5, 0, 0, nil, nil)
                item = GameObject(x, y, '|', 'greatsword', colors.grey_1, false, nil, nil, nil, equipment_component)
            
            elseif choice == "wpn_rapier" then
                local equipment_component = Equipment('left hand', 1, 0, 0, nil, nil)
                item = GameObject(x, y, 't', 'rapier', colors.blue, false, nil, nil, nil, equipment_component)
            
            elseif choice == "arm_shield" then
                local equipment_component = Equipment('left hand', 0, 1, 0, nil, nil)
                item = GameObject(x, y, 'O', 'shield', colors.orange, false, nil, nil, nil, equipment_component)
            
            elseif choice == "arm_l_armor" then
                local equipment_component = Equipment('chest', 0, 1, 0, nil, nil)
                item = GameObject(x, y, '%', 'leather armor', colors.dark_orange, false, nil, nil, nil, equipment_component)
            
            elseif choice == "arm_c_armor" then
                local equipment_component = Equipment('chest', 0, 2, 0, nil, nil)
                item = GameObject(x, y, '%', 'chainmail armor', colors.grey_1, false, nil, nil, nil, equipment_component)
            
            elseif choice == "arm_p_armor" then
                local equipment_component = Equipment('chest', 0, 3, 0, nil, nil)
                item = GameObject(x, y, '$', 'plate armor', colors.grey_1, false, nil, nil, nil, equipment_component)
            
            elseif choice == "acc_scarf" then
                local equipment_component = Equipment('neck', 0, 0, 5, nil, nil)
                item = GameObject(x, y, 'S', 'Scarf of Courage', colors.red, false, nil, nil, nil, equipment_component)

            elseif choice == "art_stone_mask" then
                local equipment_component = Equipment('face', 0, 0, 0, equip_stone_mask, nil)
                item = GameObject(x, y, '8', 'Stone Mask', colors.grey_1, false, nil, nil, nil, equipment_component)
            
            elseif choice == "wpn_silver_dagger" then
                local equipment_component = Equipment('right hand', 2, 0, 0, nil, {type="attack", usage_function=use_silver_dagger})
                item = GameObject(x, y, '-', 'silver dagger', colors.grey_5, false, nil, nil, nil, equipment_component)
            end
            table.insert(game.map.objects, item)
        end
    end
end

function game.map.is_blocked(x, y)
    if game.map.tilemap[x][y].blocked then
        return true
    end
    for key,value in pairs(game.map.objects) do 
        if value.blocks and value.x == x and value.y == y then
            return true
        end
    end
 
    return false
end

function game.map.from_dungeon_level(table)
    for k, arr in pairs(table) do
        if game.map.level >= arr[1] then
            return arr[2]
        end
    end
    return 0
end

function game.map.find_gameobject(x, y)
    for k, v in pairs(gameobjects) do
        if v.x == x and v.y == y then
            return v
        end
    end
    return nil
end

function game.map.closest_monster(max_range)
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

function game.map.find_target(direction)
    if direction == DIRECTIONS["none"] then
        return 'wrong_direction'
    end

    local xlimit = 0
    local ylimit = 0
    if direction[1] == 1 then
        xlimit = MAP_WIDTH
    end
    if direction[2] == -1 then
        ylimit = MAP_HEIGHT
    end

    local x = player.x
    local y = player.y

    while x ~= xlimit and y ~= ylimit do
        if objectmap[x][y].blocked then
                break
            end
            for k, v in pairs(gameobjects) do
                if v.x == x and v.y == y and v.ai ~= nil then
                    return v
                end
            end
            x = x + direction[1]
            y = y + direction[2]
    end
end

function game.map.gameobjects_in_range(originx, originy, range)
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

--player
function game.player.move_or_attack(dx, dy)
    local x = game.player.character.x + dx
    local y = game.player.character.y + dy

    local target = nil
    for key,value in pairs(game.map.objects) do 
        if value.fighter and value.x == x and value.y == y then
            target = value
            break
        end
    end

    if target then
        print(target.fighter.hp .. "/" .. target.fighter.max_hp.get())
        game.player.character.fighter:attack(target)
        for k,v in pairs(game.player.inventory) do
            if v.equipment then
                if v.equipment.usage_table and v.equipment.usage_table.type == "attack" then
                    local func = v.equipment.usage_table.usage_function
                    func(target)
                end
            end
        end
    else
        game.player.character:move(dx, dy)
        game.player.visible_range(PLAYER_VISIBILITY_RANGE)
    end
end

function game.player.visible_range(range)
    game.map.tilemap[game.player.character.x][game.player.character.y].visibility = special_colors.fov_visible

    for x, arr in pairs(game.map.tilemap) do
        for y, til in pairs(arr) do
            if til.visibility == special_colors.fov_visible then
                til.visibility = special_colors.fov_visited
            end
        end
    end

    for k,v in pairs(DIRECTIONS) do
        fov_cast_light(1, 1, 0, 0, v.dx, v.dy, 0, range)
        fov_cast_light(1, 1, 0, v.dx, 0, 0, v.dy, range)
    end
end

function game.player.check_level_up(type)
    local needed = LEVEL_UP_BASE + game.player.level * LEVEL_UP_FACTOR
    if game.player.character.fighter.xp >= needed then
        game.player.level = game.player.level + 1
        game.player.character.fighter.xp = game.player.character.fighter.xp - needed
        game.console.print("Your battle skills grow stronger! You reached level " .. game.player.level .. "!", colors.yellow)
        game.state.base = STATE.menu
        game.state.menu = MENU_STATE.level_up
        graphics.draw_screen()
    end
end

--util
function fov_cast_light(row, cstart, cend, xx, xy, yx, yy, range)
    local startx = game.player.character.x
    local starty = game.player.character.y
    local radius = range
    local start = cstart
    
    local new_start = 0
    if start < cend then
        return
    end

    local width = table.maxn(game.map.tilemap)
    local height = table.maxn(game.map.tilemap[1])

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
                if math.circle_radius(deltax, deltay, 0) <= radius then
                    game.map.tilemap[currentx][currenty].visibility = special_colors.fov_visible
                end

                if blocked then
                    if game.map.tilemap[currentx][currenty].block_sight then
                        new_start = rightslope
                        --Continue
                    else 
                        blocked = false
                        start = new_start
                    end
                else
                    if game.map.tilemap[currentx][currenty].block_sight and distance < radius then
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

function random_choice(collection)
    local sum = 0
    for k,v in pairs(collection) do
        sum = sum + v
    end
    local dice = love.math.random(1, sum)
    sum = 0
    for k,v in pairs(collection) do
        sum = sum + v
        if dice <= sum then
            return k
        end
    end
end