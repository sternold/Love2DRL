local item_factory = {
            chances = function(generator)
                item_chances = {
                    pot_heal = 15,
                    fd_bread = 10,
                    fd_apple = 5,
                    fd_garlic_bread = generator.from_dungeon_level({{2, 10}}),
                    fd_stew = generator.from_dungeon_level({{3, 15}}),
                    pot_regen = generator.from_dungeon_level({{4, 5}}),
                    scr_lightning = generator.from_dungeon_level({{5, 10}}),
                    scr_fireball =  generator.from_dungeon_level({{2, 10}}),
                    scr_confuse =   generator.from_dungeon_level({{3, 5}}),
                    scr_strength =   generator.from_dungeon_level({{4, 5}}),
                    scr_lightning_storm =   generator.from_dungeon_level({{7, 5}}),
                    wpn_s_sword =   generator.from_dungeon_level({{1, 5}, {5, 0}}),
                    wpn_l_sword =   generator.from_dungeon_level({{4, 5}}),
                    wpn_g_sword =   generator.from_dungeon_level({{7, 5}}),
                    wpn_rapier =   generator.from_dungeon_level({{3, 1}}),
                    arm_shield =   generator.from_dungeon_level({{1, 5}}),
                    arm_l_armor =   generator.from_dungeon_level({{1, 7}, {5,0}}),
                    arm_c_armor =   generator.from_dungeon_level({{4, 7}}),
                    arm_p_armor =   generator.from_dungeon_level({{7, 7}}),
                    acc_scarf =   generator.from_dungeon_level({{2, 3}}),
                    art_stone_mask = generator.from_dungeon_level({{8, 1}}),
                    wpn_silver_dagger = generator.from_dungeon_level({{6, 2}})
                }
                return item_chances
            end,     
            pot_heal = function(x, y)
                local item_component = Item(cast_heal)
                item_component.var.amount = 20
                local item = GameObject(x, y, '!', 'healing potion', colors.light_pink, false, nil, nil, item_component)
                return item
            end,
            fd_bread = function(x, y)
                local item_component = Item(eat)
                item_component.var.ingredients = {"flour", "milk"}
                local item = GameObject(x, y, 'm', 'Bread', colors.dark_orange, false, nil, nil, item_component)
                return item
                end,
            fd_garlic_bread = function(x, y)
                local item_component = Item(eat)
                item_component.var.ingredients = {"flour", "milk", "garlic", "cheese"}
                local item = GameObject(x, y, 'm', 'Garlic Bread', colors.dark_yellow, false, nil, nil, item_component)
                return item
                end,
            fd_apple = function(x, y)
                local item_component = Item(eat)
                item_component.var.ingredients = {"apple"}
                local item = GameObject(x, y, 'a', 'Apple', colors.light_red, false, nil, nil, item_component)
                return item
                end,
            fd_stew = function(x, y)
                local item_component = Item(eat)
                item_component.var.ingredients = {"pork", "water", "milk", "onions", "garlic"}
                local item = GameObject(x, y, 'u', 'Stew', colors.dark_orange, false, nil, nil, item_component)
                return item
                end,
            pot_regen = function(x, y)
                local item_component = Item(cast_regen)
                item_component.var.duration = 10
                item_component.var.amount = 10
                local item = GameObject(x, y, '!', 'Potion of Regeneration', colors.dark_pink, false, nil, nil, item_component)
                return item
                end,
            scr_confuse = function(x, y)
                local item_component = Item(cast_confusion)
                item_component.var.duration = 30
                item_component.var.range = 5
                local item = GameObject(x, y, '#', 'Scroll of Confusion', colors.light_pink, false, nil, nil, item_component)   
                return item
                end,
            scr_fireball = function(x, y)
                local item_component = Item(cast_fireball)
                item_component.var.damage = 25
                local item = GameObject(x, y, '#', 'Scroll of Fireball', colors.dark_red, false, nil, nil, item_component)   
                return item
                end,
            scr_strength = function(x, y)
                local item_component = Item(cast_strength)
                item_component.var.duration = 10
                local item = GameObject(x, y, '#', "Scroll of Giant's Strength", colors.light_red, false, nil, nil, item_component)   
                return item
                end,
            scr_lightning = function(x, y)
                local item_component = Item(cast_lightning)
                item_component.var.damage = 50
                item_component.var.range = 5
                local item = GameObject(x, y, '#', 'Scroll of Lighning Bolt', colors.yellow, false, nil, nil, item_component)
                return item
                end,
            scr_lightning_storm = function(x, y)
                local item_component = Item(cast_lightning_storm)
                item_component.var.damage = 40
                item_component.var.range = 5
                local item = GameObject(x, y, '#', 'Scroll of Lightning Storm', colors.dark_yellow, false, nil, nil, item_component)
                return item
                end,
            wpn_s_sword = function(x, y)
                local equipment_component = Equipment('right hand', 2, 0, 0, nil, nil)
                local item = GameObject(x, y, 't', 'shortsword', colors.grey_2, false, nil, nil, nil, equipment_component)
                return item
                end,
            wpn_l_sword = function(x, y)
                local equipment_component = Equipment('right hand', 3, 0, 0, nil, nil)
                local item = GameObject(x, y, '|', 'longsword', colors.grey_2, false, nil, nil, nil, equipment_component)
                return item
                end,
            wpn_g_sword = function(x, y)
                local equipment_component = Equipment('right hand', 5, 0, 0, nil, nil)
                local item = GameObject(x, y, '|', 'greatsword', colors.grey_1, false, nil, nil, nil, equipment_component)
                return item
                end,
            wpn_rapier = function(x, y)
                local equipment_component = Equipment('left hand', 1, 0, 0, nil, nil)
                local item = GameObject(x, y, 't', 'rapier', colors.blue, false, nil, nil, nil, equipment_component)
                return item
                end,
            arm_shield = function(x, y)                
                local equipment_component = Equipment('left hand', 0, 1, 0, nil, nil)
                local item = GameObject(x, y, 'O', 'shield', colors.orange, false, nil, nil, nil, equipment_component)
                return item
                end,
            arm_l_armor = function(x, y)
                local equipment_component = Equipment('chest', 0, 1, 0, nil, nil)
                local item = GameObject(x, y, '%', 'leather armor', colors.dark_orange, false, nil, nil, nil, equipment_component)
                return item
                end,
            arm_c_armor = function(x, y)
                local equipment_component = Equipment('chest', 0, 2, 0, nil, nil)
                local item = GameObject(x, y, '%', 'chainmail armor', colors.grey_1, false, nil, nil, nil, equipment_component)
                return item
                end,
            arm_p_armor = function(x, y)
                local equipment_component = Equipment('chest', 0, 3, 0, nil, nil)
                local item = GameObject(x, y, '$', 'plate armor', colors.grey_1, false, nil, nil, nil, equipment_component)
                return item
                end,
            acc_scarf = function(x, y)
                local equipment_component = Equipment('neck', 0, 0, 5, nil, nil)
                local item = GameObject(x, y, 'S', 'Scarf of Courage', colors.red, false, nil, nil, nil, equipment_component)
                return item
                end,
            art_stone_mask = function(x, y)
                local equipment_component = Equipment('face', 0, 0, 0, equip_stone_mask, nil)
                local item = GameObject(x, y, '8', 'Stone Mask', colors.grey_1, false, nil, nil, nil, equipment_component)
                return item
                end,
            wpn_silver_dagger = function(x, y)
                local equipment_component = Equipment('right hand', 2, 0, 0, nil, {type="attack", usage_function=use_holy_weapon})
                local item = GameObject(x, y, '-', 'silver dagger', colors.grey_5, false, nil, nil, nil, equipment_component)
                return item
            end
}

return item_factory