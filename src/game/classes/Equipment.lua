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
    if old_equipment then
        old_equipment:dequip()
    end
    self.is_equipped = true
    game.console.print("Equipped " .. self.owner.name .. " on " .. self.slot .. ".", color_blue)
    if self.equip_function then
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