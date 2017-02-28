Player = class('Player')
function Player:initialize(charclass, character)
    self.charclass = charclass
    self.character = character
    self.level = 1
    self.sense_range = 10
    self.inventory = {}
    self.base_xp = 200
    self.rate_xp = 150
end

function Player:move_or_attack(dx, dy)
    local x = self.character.x + dx
    local y = self.character.y + dy

    local target = nil
    for key,value in pairs(data.map.objects) do 
        if value.fighter and value.x == x and value.y == y then
            target = value
            break
        end
    end

    if target then
        print(target.fighter.hp .. "/" .. target.fighter:max_hp())
        self.character.fighter:attack(target)
        
        --special functions
        for k,v in pairs(self.inventory) do
            if target.fighter and v.equipment and v.equipment.is_equipped then
                if v.equipment.usage_table and v.equipment.usage_table.type == "attack" then
                    local func = v.equipment.usage_table.usage_function
                    func(target)
                end
            end
        end

    else
        self.character:move(dx, dy)
        self:visible_range()
    end
end

function Player:visible_range()
    data.map.tiles[self.character.x][self.character.y].visibility = special_colors.fov_visible

    for x, arr in pairs(data.map.tiles) do
        for y, til in pairs(arr) do
            if til.visibility == special_colors.fov_visible then
                til.visibility = special_colors.fov_visited
            end
        end
    end

    for k,v in pairs(DIRECTIONS) do
        fov_cast_light(1, 1, 0, 0, v.dx, v.dy, 0, self.sense_range)
        fov_cast_light(1, 1, 0, v.dx, 0, 0, v.dy, self.sense_range)
    end
end

function Player:check_level_up(type)
    local needed = self.base_xp + self.level * self.rate_xp
    if self.character.fighter.xp >= needed then
        self.level = self.level + 1
        self.character.fighter.xp = self.character.fighter.xp - needed
        game.print("Your battle skills grow stronger! You reached level " .. self.level .. "!", colors.yellow)
        screenmanager.push("levelup")
        console.draw()
    end
end