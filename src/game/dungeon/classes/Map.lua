Map = class('Map')
function Map:initialize(w, h, floor)
    self.width = w
    self.height = h
    self.floor = floor
    self.tiles = {}
    for x=1, w, 1 do
        table.insert(self.tiles, x, {}) 
        for y=1, h, 1 do
            table.insert(self.tiles[x], y, Tile(true)) 
        end
    end
    self.objects = {}
    self.monster_count = 0
    self.stairs = nil
    self.floor_color = colors.grey_6
    self.wall_color = colors.dark_orange
end

function Map:draw(cx, cy, cw, ch)
    for x=cx+1, cx+cw do
        if self.tiles[x] then
            for y=cy+1, cy+ch do
                if self.tiles[x][y] and self.tiles[x][y].blocked then
                    console.drawRect("fill", x-cx, y-cy, 1, 1, self.wall_color)
                else
                    console.drawRect("fill", x-cx, y-cy, 1, 1, self.floor_color)
                end
            end
        end
    end
end

function Map:draw_fog(cx, cy, cw, ch)
    for x=cx+1, cx+cw do
        if self.tiles[x] then
            for y=cy+1, cy+ch do
                if self.tiles[x][y] then
                    console.drawRect("fill", x-cx, y-cy, 1, 1, self.tiles[x][y].visibility)
                end
            end
        end
    end
end

function Map:is_blocked(x, y)
    if self.tiles[x][y].blocked then
        return true
    end
    for key,value in pairs(self.objects) do 
        if value.blocks and value.x == x and value.y == y then
            return true
        end
    end
 
    return false
end

function Map:has_gameobject(x, y)
    for k, v in pairs(self.objects) do
        if v.x == x and v.y == y then
            return v
        end
    end
    return nil
end

function Map:closest_enemy(src, max_range)
    local closest_enemy = nil
    local closest_dist = max_range + 1
 
    for key, value in pairs(self.objects) do
        if value.fighter and value ~= src then
            dist = src:distance_to(value)
            if dist < closest_dist then
                closest_enemy = value
                closest_dist = dist
            end
        end
    end
    if closest_enemy == nil or self.tiles[closest_enemy.x][closest_enemy.y].visibility == special_colors.fov_visible then
        return closest_enemy
    else
        return nil
    end
end

function Map:target_direction(src, dir)
    if dir == DIRECTIONS.none then
        return 'wrong_direction'
    end

    local xlimit = 0
    local ylimit = 0
    if dir.dx == 1 then
        xlimit = self.width
    end
    if dir.dy == -1 then
        ylimit = self.height
    end

    local x = src.x
    local y = src.y

    while x ~= xlimit and y ~= ylimit do
        if self.tiles[x][y].blocked then
            break
        end
        for k, v in pairs(self.objects) do
            if v.x == x and v.y == y and v.ai ~= nil then
                return v
            end
        end
        x = x + dir.dx
        y = y + dir.dy
    end
end

function Map:gameobjects_in_range(src, range)
    local targets = {}
    for x = src.x - range, src.x + range do
        for y = src.y - range, src.y + range do
            gob = self:has_gameobject(x, y)
            if gob ~= nil then
                table.insert(targets, gob)
            end
        end
    end 
    return targets
end
