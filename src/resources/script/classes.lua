local class_factory = {
    Warrior = function(x, y)
        local fighter_component = Fighter(100, 0, 2, 0, player_death)
        local character = GameObject(x, y, "@", "Warrior", colors.dark_yellow, true, fighter_component, nil)
        local player = Player("Warrior", character)
        --dagger
        local equipment_component = Equipment(SLOTS.right_hand, 1, 0, 0)
        local item = GameObject(0, 0, '-', 'dagger', colors.grey_2, false, nil, nil, nil, equipment_component)
        table.insert(player.inventory, item)
        --cloak
        local equipment_component = Equipment(SLOTS.back, 0, 1, 0)
        local item = GameObject(0, 0, '\\', 'Cloak of Protection', colors.light_purple, false, nil, nil, nil, equipment_component)
        table.insert(player.inventory, item)      
        return player
    end,

    Lovemancer = function(x, y)
        local fighter_component = Fighter(60, 0, 1, 0, player_death)
        local character = GameObject(x, y, "@", "Lovemancer", colors.dark_purple, true, fighter_component, nil)
        local player = Player("Lovemancer", character)
        
        --staff
        local item_component = Item(staff_love_dart)
        item_component.var.charges = 50
        item_component.var.damage = love.math.random(15, 30)
        local item = GameObject(0, 0, 'i', 'Staff of Love Darts', colors.light_purple, false, nil, nil, item_component)
        table.insert(player.inventory, item)
        
        return player
    end,

    Paladin = function(x, y)
        local fighter_component = Fighter(90, 0, 2, 0, player_death)
        local character = GameObject(x, y, "@", "Paladin", colors.light_yellow, true, fighter_component, nil)
        local player = Player("Paladin", character)
        player.base_xp = 400
        
        --staff
        local equipment_component = Equipment(SLOTS.right_hand, 4, 0, 10, nil, {type="attack", usage_function=use_holy_weapon})
        local item = GameObject(0, 0, 'T', 'Sword of Alexander', colors.light_yellow, false, nil, nil, nil, equipment_component)
        table.insert(player.inventory, item)
        
        return player
    end
}

return class_factory