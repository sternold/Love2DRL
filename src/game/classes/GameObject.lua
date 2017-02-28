
--class definitions
GameObject = class('GameObject')
function GameObject:initialize(x, y, char, name, color, blocks, fighter, ai, item, equipment)
    self.x = x
    self.y = y
    self.char = char
    self.name = name
    self.color = color
    self.blocks = blocks or false
    self.fighter = fighter or nil
    if self.fighter ~= nil then
        self.fighter.owner = self
    end
    self.ai = ai or nil
    if self.ai ~= nil then
        self.ai.owner = self
    end
    self.item = item or nil
    if self.item ~= nil then
        self.item.owner = self
    end
    self.equipment = equipment or nil
    if self.equipment ~= nil then
        self.equipment.owner = self
        --there must be an Item component for the Equipment component to work properly
        self.item = Item()
        self.item.owner = self
    end
end

function GameObject:move(dx, dy)
    if not data.map:is_blocked(self.x + dx, self.y + dy) then
        self.x = self.x + dx
        self.y = self.y + dy
    end
end

function GameObject:draw()
    if data.map.tiles[self.x][self.y].visibility == special_colors.fov_visible then
        console.drawText(self.char, self.x, self.y, self.color)
    end
end

function GameObject:move_towards(target_x, target_y)
    local dx = target_x - self.x
    local dy = target_y - self.y
    local distance = math.sqrt(math.pow(dx, 2) + math.pow(dy, 2))

    dx = math.round(dx / distance)
    dy = math.round(dy / distance)
    self:move(dx, dy) 
end

function GameObject:distance_to(other)
    local dx = other.x - self.x
    local dy = other.y - self.y
    return math.sqrt(math.pow(dx, 2) + math.pow(dy, 2))
end