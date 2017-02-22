function obj_reg()
    bitser.register("obj_pld", player_death)
    bitser.register("obj_mod", monster_death)
end

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
    if not game.map.is_blocked(self.x + dx, self.y + dy) then
        self.x = self.x + dx
        self.y = self.y + dy
    end
end

function GameObject:draw()
    if game.map.tilemap[self.x][self.y].visibility == special_colors.fov_visible then
        graphics.draw(graphics.newText(graphics.getFont(), {self.color, self.char}), self.x*SCALE, self.y*SCALE+5)
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

Fighter = class('Fighter')
function Fighter:initialize(hp, defense, power, xp, death_function)
    self.base_max_hp = hp
    self.base_defense = defense
    self.base_power = power
    self.hp = hp
    self.xp = xp
    self.death_function = death_function or nil
    self.invocations = {}
end

function Fighter:take_damage(damage)
    if damage > 0 then
        self.hp = self.hp - damage
        if self.hp <= 0 and self.death_function then
            self.death_function(self.owner)
        end
    end
end

function Fighter:attack(target)
    local damage = 0
    local chances = self:power() * 2
    for i = 0, chances do
        if love.math.random(1, 2 + target.fighter:defense()) == 1 then
            damage = damage + 1
        end
    end
        if damage > 0 then
            game.console.print(self.owner.name .. ' attacks ' .. target.name .. ' for ' .. damage .. ' hit points.')
            target.fighter:take_damage(damage)
        else
            game.console.print(self.owner.name .. ' attacks ' .. target.name .. ' but it has no effect!')
        end
end

function Fighter:heal(amount)
    self.hp = self.hp + amount
    if self.hp > self:max_hp() then
        self.hp = self:max_hp()
    end
end

function Fighter:max_hp()
    local bonus = 0
        for k,v in pairs(get_all_equipped(self.owner)) do
            bonus = bonus + v.equipment.max_hp_bonus
        end
    return self.base_max_hp + bonus
end

function Fighter:defense()
        local bonus = 0
        for k,v in pairs(get_all_equipped(self.owner)) do
            bonus = bonus + v.equipment.defense_bonus
        end
        return self.base_defense + bonus
end

function Fighter:power()
        local bonus = 0
        for k,v in pairs(get_all_equipped(self.owner)) do
            bonus = bonus + v.equipment.power_bonus
        end
        return self.base_power + bonus
end

function player_death(target)
    game.state.playing = PLAYING_STATE.dead
    target.char = '%'
    target.color = colors.dark_red
    graphics.draw_screen()
end

function monster_death(target)
    game.console.print(target.name .. ' is dead!', colors.dark_red)
    game.player.character.fighter.xp = game.player.character.fighter.xp + target.fighter.xp
    target.char = '%'
    target.color = colors.dark_red
    target.blocks = false
    target.fighter = nil
    target.ai = nil
    target.name = 'remains of ' .. target.name
    game.map.monster_count = game.map.monster_count - 1
    game.player.check_level_up()
end

BasicMonster = class('BasicMonster')
function BasicMonster:initialize()
end

function BasicMonster:take_turn()
    local monster = self.owner
    
    if game.map.tilemap[self.owner.x][self.owner.y].visibility == special_colors.fov_visible then
        if monster:distance_to(game.player.character) >= 2 then
            monster:move_towards(game.player.character.x, game.player.character.y)
        elseif game.player.character.fighter.hp > 0 then
            monster.fighter:attack(game.player.character)
        end
    end
end

Item = class('Item')
function Item:initialize(use_function)
    self.use_function = use_function
    self.var = {}
end

function Item:pick_up()
    if table.maxn(game.player.inventory) >= 26 then
        game.console.print("Your inventory is full.")
    else
        table.insert(game.player.inventory, self.owner)
        table.remove(game.map.objects, table.index_of(game.map.objects, self.owner))
        game.console.print("You picked up a " .. self.owner.name .. "!", self.owner.color)
    end

    --Equip the item if it's equippable and the slot is empty
    local equipment = self.owner.equipment
    if equipment and get_equipped_in_slot(equipment.slot) == nil then
        equipment:equip()
    end
end

function Item:use()
    if self.owner.equipment then
        self.owner.equipment:toggle_equip()
        return
    end

    if self.use_function then
        if self.use_function(self) ~= "cancelled" then
            table.remove(game.player.inventory, table.index_of(game.player.inventory, self.owner))
        end
    else
        game.console.print("The " .. self.owner.name .. " cannot be used.")
    end
end

function Item:drop()
    if self.owner.equipment then
        self.owner.equipment:dequip()
    end
    table.insert(game.map.objects, self.owner)
    table.remove(game.player.inventory, table.index_of(game.player.inventory, self.owner))
    self.owner.x = game.player.character.x
    self.owner.y = game.player.character.y
    game.console.print("you dropped a " .. self.owner.name .. ".", self.owner.color)
end

Equipment = class('Equipment')
function Equipment:initialize(slot, power_bonus, defense_bonus, max_hp_bonus, equip_function, usage_table)
    self.slot = slot
    self.is_equipped = false
    self.power_bonus = power_bonus
    self.defense_bonus = defense_bonus
    self.max_hp_bonus = max_hp_bonus
    self.equip_function = equip_function or nil
    self.usage_table = usage_table or nil
end

function Equipment:toggle_equip()
    if self.is_equipped then
        self:dequip()
    else
        self:equip()
    end
end

function Equipment:equip()
    local old_equipment = get_equipped_in_slot(self.slot)
    if old_equipment ~= nil then
        old_equipment:dequip()
    end
    self.is_equipped = true
    game.console.print("Equipped " .. self.owner.name .. " on " .. self.slot .. ".", color_blue)
    if self.equip_function ~= nil then
        self.equip_function()
    end
end

function Equipment:dequip()
    self.is_equipped = false
    game.console.print("Dequipped " .. self.owner.name .. " on " .. self.slot .. ".", color_yellow)
end

function get_equipped_in_slot(slot)
    for k, obj in pairs(game.player.inventory) do
        if obj.equipment ~= nil and obj.equipment.slot == slot and obj.equipment.is_equipped then
            return obj.equipment
        end
    end
    return nil
end

function get_all_equipped(obj)
    if obj == game.player.character then
        local equipped = {}
        for k,v in pairs(game.player.inventory) do
            if v.equipment ~= nil and v.equipment.is_equipped then
                table.insert(equipped, v)
            end
        end
        return equipped
    else
        return {} --TODO
    end
end

Invocation = class('Invocation')
function Invocation:initialize(duration, invoke_function)
    self.duration = duration
    self.timer = 0
    self.invoke_function = invoke_function
end

function Invocation:invoke()
    self.invoke_function(self, true)
    self.timer = self.timer + 1
    if(self.timer >= self.duration) then
        self.invoke_function(self, false)
    end
end

ConfusedMonster = class('ConfusedMonster')
function ConfusedMonster:initialize()
end

function ConfusedMonster:take_turn()
    game.console.print("The " .. self.owner.name .. " stumbles around!", color_orange)
    self.owner:move(love.math.random(-1, 1), love.math.random(-1, 1))
end