local dungeon_generator = {}

function dungeon_generator.generate(floor)
    dungeon_level = floor
    local map_width = dungeon_generator.from_dungeon_level({{1, 50}})
    local map_height = dungeon_generator.from_dungeon_level({{1, 50}})
    local map = Map:new(map_width, map_height, floor)
    local starting_coords = dungeon_generator.create_rooms(map)   
    return map, starting_coords
end

function dungeon_generator.create_rooms(map)
    local rooms = {}
    local max_rooms = (map.width * map.height) / 100
    local room_min_size = dungeon_generator.from_dungeon_level({{1, 6}})
    local room_max_size = dungeon_generator.from_dungeon_level({{1, 10}})
    local w = 0
    local h = 0
    local x = 0
    local y = 0
    for r=0, max_rooms do
        --random width and height
        w = love.math.random(room_min_size, room_max_size)
        h = love.math.random(room_min_size, room_max_size)
        --random position without going out of the boundaries of the map
        x = love.math.random(1, map.width - w - 1)
        y = love.math.random(1, map.height - h - 1)

        local new_room = Rect(x, y, w, h)
        local failed = false
        for x=1, table.maxn(rooms) do
            if new_room:intersect(rooms[x]) then
                failed = true
                break
            end
        end
        if not failed then
            dungeon_generator.create_room(map, new_room)
            dungeon_generator.place_objects(map, new_room)
            new_x, new_y = new_room:center()

            if table.maxn(rooms) == 0 then
                player_start_x = new_x
                player_start_y = new_y
            else    
                prev_x, prev_y = rooms[table.maxn(rooms)]:center()
                if love.math.random(0, 1) == 1 then
                    dungeon_generator.create_h_tunnel(map, prev_x, new_x, prev_y)
                    dungeon_generator.create_v_tunnel(map, prev_y, new_y, new_x)
                else
                    dungeon_generator.create_v_tunnel(map, prev_y, new_y, prev_x)
                    dungeon_generator.create_h_tunnel(map, prev_x, new_x, new_y)
                end                   
            end
            table.insert(rooms, new_room)
        end
    end
    dungeon_generator.stairs(map, x, y)
    return {x=player_start_x, y=player_start_y}
end

function dungeon_generator.create_room(map, room)
    for x=room.x1+1, room.x2 do
        for y=room.y1+1, room.y2 do
            map.tiles[x][y].blocked = false
            map.tiles[x][y].block_sight = false
        end
    end
end

function dungeon_generator.create_h_tunnel(map, x1, x2, y)
    for x=math.min(x1, x2), math.max(x1, x2) do
        map.tiles[x][y].blocked = false
        map.tiles[x][y].block_sight = false
    end
end

function dungeon_generator.create_v_tunnel(map, y1, y2, x)
    for y=math.min(y1, y2), math.max(y1, y2) do
        map.tiles[x][y].blocked = false
        map.tiles[x][y].block_sight = false
    end
end

function dungeon_generator.place_objects(map, room)
    local monster_factory = require("resources/script/monsters")
    local item_factory = require("resources/script/items")
    
    local max_monsters = dungeon_generator.from_dungeon_level({{1, 2}, {4, 3}, {6, 5}})
    local max_items = dungeon_generator.from_dungeon_level({{1, 1}, {4, 2}})
    
    local num_monsters = love.math.random(0, max_monsters)
    for i=0, num_monsters do
        --choose random spot for this monster
        local x = love.math.random(room.x1+1, room.x2-1)
        local y = love.math.random(room.y1+1, room.y2-1)
        
         if not map:is_blocked(x, y) then   
            local choice = random_choice(monster_factory.chances(dungeon_generator)) 
            local monster_func = monster_factory[choice]
            local monster = monster_func(x, y)
            map.monster_count = map.monster_count + 1
            table.insert(map.objects, monster)
        end 
    end

    local num_items = love.math.random(0, max_items)
    for i=0, num_items do
        local x = love.math.random(room.x1+1, room.x2-1)
        local y = love.math.random(room.y1+1, room.y2-1)
 
        if not map:is_blocked(x, y) then
            local item = nil
            local choice = random_choice(item_factory.chances(dungeon_generator)) 
            local item_func = item_factory[choice]
            local item = item_func(x, y)
            table.insert(map.objects, item)
        end
    end
end

function dungeon_generator.stairs(map, x, y)
    local sx = x
    local sy = y
    while map.tiles[sx][sy].blocked do
        local dx = love.math.random(-1, 1)
        local dy = love.math.random(-1, 1)
        if map.tiles[sx + dx] == nil or map.tiles[sx + dx][sy + dy] == nil then
            sx = love.math.random(2, map.width - 1)
            sy = love.math.random(2, map.height - 1)
        end
        sx = sx + dx
        sy = sy + dy
    end
    if floor == END_FLOOR then
        map.stairs = GameObject(1, 1, "<", "stairs", colors.white)
    else
        map.stairs = GameObject(sx, sy, "<", "stairs", colors.white)
    end
    table.insert(map.objects, map.stairs)
end

function dungeon_generator.from_dungeon_level(table)
    result = 0
    for k, arr in pairs(table) do
        if dungeon_level >= arr[1] then
            result = arr[2]
        end
    end
    return result
end

return dungeon_generator