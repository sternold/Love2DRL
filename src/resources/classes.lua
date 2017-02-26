
function get_class_name(index)
    count = 1
    for k, v in pairs(class_factory) do
        if count == index then
            return k
        end
        count = count + 1
    end
end

class_factory = {
    warrior = function(x, y)
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
        
        local fighter_component = Fighter(100, 0, 2, 0, player_death)
        return GameObject(x, y, "@", "player", colors.yellow, true, fighter_component, nil)
    end,

    lovemancer = function(x, y)
        --staff
        local item_component = Item(staff_love_dart)
        item_component.var.charges = 50
        item_component.var.damage = love.math.random(15, 30)
        local item = GameObject(0, 0, 'i', 'Staff of Love Darts', colors.light_purple, false, nil, nil, item_component)
        table.insert(game.player.inventory, item)
        
        local fighter_component = Fighter(60, 0, 1, 0, player_death)
        return GameObject(x, y, "@", "player", colors.yellow, true, fighter_component, nil)
    end
}

return class_factory