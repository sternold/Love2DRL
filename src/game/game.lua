--function containers
game = {}
game.map = {}
game.player = {}
game.console = {}
game.state = {}

--variables
aimable_spell = nil
direction = DIRECTIONS.none

--bitser
function game_reg()
    bitser.register("gam_ba", game.new_game)
    bitser.register("gam_bbl", game.next_level)
    bitser.register("gam_bcen", game.save_game)
    bitser.register("gam_bd", game.load_game)
    bitser.register("gam_be", game.console.print)
    bitser.register("gam_bff", game.map.make_map)
    bitser.register("gam_bg", game.map.create_room)
    bitser.register("gam_bhstr", game.map.create_h_tunnel)
    bitser.register("gam_bimsk", game.map.create_v_tunnel)
    bitser.register("gam_bjg", game.map.place_objects)
    bitser.register("gam_bkg", game.map.is_blocked)
    bitser.register("gam_blg", game.map.from_dungeon_level)
    bitser.register("gam_bmg", game.map.find_gameobject)
    bitser.register("gam_bng", game.map.closest_monster)
    bitser.register("gam_bog", game.map.find_target)
    bitser.register("gam_bpg", game.map.gameobjects_in_range)
    bitser.register("gam_bqg", game.player.move_or_attack)
    bitser.register("gam_brg", game.player.visible_range)
    bitser.register("gam_bsg", game.player.check_level_up)
    bitser.register("gam_upd", game.update)
end

--init
function game.new_game(class)
    local class_factory = require("resources/script/classes")
    console.setFullscreen(config.fullscreen)
     
    game.player.inventory = {}
    game.console.log = {}
    game.map.level = 1
    game.map.make_map()

    --Welcome message
    game.console.print("Welcome stranger, be prepared to perish in the tombs of LOVE!", colors.red)

    --player initialization
    game.player.character = class_factory[class](player_start_x, player_start_y)
    game.player.level = 1
    game.player.visible_range(PLAYER_VISIBILITY_RANGE)

    draw_tutorial = config.tutorial
    console.draw()
end

function game.next_level()
    game.console.print("You take a moment to rest...", colors.red)
    game.map.level = game.map.level + 1
    game.map.make_map()
    game.player.character.x = player_start_x
    game.player.character.y = player_start_y
    game.player.character.fighter:heal(math.round(game.player.character.fighter:max_hp() / 2))
    game.player.visible_range(PLAYER_VISIBILITY_RANGE)
    console.draw()
end

function game.update()
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
end

--deprecated
function game.save_game()
    bitser.dumpLoveFile(SAVE_FILE, game)
end

--deprecated
function game.load_game()
    if love.filesystem.isFile(SAVE_FILE) then
        console.setFullscreen(config.fullscreen)
        game = bitser.loadLoveFile(SAVE_FILE)
        game.player.visible_range(PLAYER_VISIBILITY_RANGE)
        console.draw()
    else
        print("no save data could be found.")      
        console.draw()
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
    if game.map.level == END_FLOOR then
        game.map.stairs = GameObject(1, 1, "<", "stairs", colors.white)
    else
        game.map.stairs = GameObject(x, y, "<", "stairs", colors.white)
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
    local monster_factory = require("resources/script/monsters")
    local item_factory = require("resources/script/items")
    
    local max_monsters = game.map.from_dungeon_level({{1, 2}, {4, 3}, {6, 5}})
    local max_items = game.map.from_dungeon_level({{1, 1}, {4, 2}})
    
    local num_monsters = love.math.random(0, max_monsters)
    for i=0, num_monsters do
        --choose random spot for this monster
        local x = love.math.random(room.x1+1, room.x2-1)
        local y = love.math.random(room.y1+1, room.y2-1)
        
         if not game.map.is_blocked(x, y) then   
            local choice = random_choice(monster_factory.chances()) 
            local monster_func = monster_factory[choice]
            local monster = monster_func(x, y)
            game.map.monster_count = game.map.monster_count + 1
            table.insert(game.map.objects, monster)
        end 
    end

    local num_items = love.math.random(0, max_items)
    for i=0, num_items do
        local x = love.math.random(room.x1+1, room.x2-1)
        local y = love.math.random(room.y1+1, room.y2-1)
 
        if not game.map.is_blocked(x, y) then
            local item = nil
            local choice = random_choice(item_factory.chances()) 
            local item_func = item_factory[choice]
            local item = item_func(x, y)
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
    for k, v in pairs(game.map.objects) do
        if v.x == x and v.y == y then
            return v
        end
    end
    return nil
end

function game.map.closest_monster(max_range)
    local closest_enemy = nil
    local closest_dist = max_range + 1
 
    for key, value in pairs(game.map.objects) do
        if value.fighter and value ~= game.player.character then
            dist = game.player.character:distance_to(value)
            if dist < closest_dist then
                closest_enemy = value
                closest_dist = dist
            end
        end
    end
    if closest_enemy == nil then
        return closest_enemy
    elseif game.map.tilemap[closest_enemy.x][closest_enemy.y].visibility == special_colors.fov_visible then
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
    if direction.dx == 1 then
        xlimit = MAP_WIDTH
    end
    if direction.dy == -1 then
        ylimit = MAP_HEIGHT
    end

    local x = game.player.character.x
    local y = game.player.character.y

    while x ~= xlimit and y ~= ylimit do
        if game.map.tilemap[x][y].blocked then
                break
            end
            for k, v in pairs(game.map.objects) do
                if v.x == x and v.y == y and v.ai ~= nil then
                    return v
                end
            end
            x = x + direction.dx
            y = y + direction.dy
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
        print(target.fighter.hp .. "/" .. target.fighter:max_hp())
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
        console.draw()
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