function item_reg()
    bitser.register("it_eat", eat)
    bitser.register("it_heal", cast_heal)
    bitser.register("it_regen", cast_regen)
    bitser.register("it_lit", cast_lightning)
    bitser.register("it_fir", use_silver_dagger)
    bitser.register("it_conf", cast_fireball)
    bitser.register("it_str", cast_confusion)
    bitser.register("it_litstr", cast_strength)
    bitser.register("it_stnmsk", cast_lightning_storm)
    bitser.register("it_sldg", equip_stone_mask)
    bitser.register("it_stfmm", staff_love_dart)
end

item_factory = {
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
                local item = GameObject(x, y, '#', "Scroll of Giant's Strength", colors.player, false, nil, nil, item_component)   
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
                local equipment_component = Equipment('right hand', 2, 0, 0, nil, {type="attack", usage_function=use_silver_dagger})
                local item = GameObject(x, y, '-', 'silver dagger', colors.grey_5, false, nil, nil, nil, equipment_component)
                return item
            end
}

function item_factory.chances()
    item_chances = {
        pot_heal = 15,
        fd_bread = 10,
        fd_apple = 5,
        fd_garlic_bread = game.map.from_dungeon_level({{2, 10}}),
        fd_stew = game.map.from_dungeon_level({{3, 15}}),
        pot_regen = game.map.from_dungeon_level({{4, 5}}),
        scr_lightning = game.map.from_dungeon_level({{5, 10}}),
        scr_fireball =  game.map.from_dungeon_level({{2, 10}}),
        scr_confuse =   game.map.from_dungeon_level({{3, 5}}),
        scr_strength =   game.map.from_dungeon_level({{4, 5}}),
        scr_lightning_storm =   game.map.from_dungeon_level({{7, 5}}),
        wpn_s_sword =   game.map.from_dungeon_level({{1, 5}, {5, 0}}),
        wpn_l_sword =   game.map.from_dungeon_level({{4, 5}}),
        wpn_g_sword =   game.map.from_dungeon_level({{7, 5}}),
        wpn_rapier =   game.map.from_dungeon_level({{3, 1}}),
        arm_shield =   game.map.from_dungeon_level({{1, 5}}),
        arm_l_armor =   game.map.from_dungeon_level({{1, 7}, {5,0}}),
        arm_c_armor =   game.map.from_dungeon_level({{4, 7}}),
        arm_p_armor =   game.map.from_dungeon_level({{7, 7}}),
        acc_scarf =   game.map.from_dungeon_level({{2, 3}}),
        art_stone_mask = game.map.from_dungeon_level({{8, 1}}),
        wpn_silver_dagger = game.map.from_dungeon_level({{6, 2}})
    }
    return item_chances
end
--usables
function eat(self)
    game.player.character.fighter:heal(table.maxn(self.var.ingredients) * 5)
    for k,v in pairs(game.player.character.fighter.invocations) do
        if v.invoke_function == invoke_vampirism and table.has_value(self.ingredients, "garlic") then
            v.var.weakness = true
        end
    end
    game.console.print("You eat a some " .. self.owner.name .. "!", colors.green)
end

function cast_heal(self)
    if game.player.character.fighter.hp == game.player.character.fighter:max_hp() then
        game.console.print("You're already at full health.", colors.light_blue)
        return "cancelled"
    end
    game.console.print("You're starting to feel better!", colors.light_green)
    game.player.character.fighter:heal(self.var.amount)
end

function cast_regen(self)
    game.console.print("The " .. game.player.character.name .. " slowly grows healthier!", colors.light_green)
    add_invocation(game.player.character.fighter, self.var.duration, invoke_regen)
end

function cast_lightning(self)
    local monster = game.map.closest_monster(self.var.range)
    if monster == nil then
        game.console.print("No enemy in range.")
        return "cancelled"
    end

    game.console.print("A lightning bolt strikes the " .. monster.name .. ", dealing " .. self.var.damage .. " damage!", colors.yellow)
    monster.fighter:take_damage(self.var.damage)
end

function cast_fireball(self)
    game.state.playing = PLAYING_STATE.casting
    if direction == DIRECTIONS.none then
        aimable_spell = {func=cast_fireball, item=self}
        return
    else
        target = game.map.find_target(direction)
        if target == "wrong_direction" then
            game.console.print("Wrong key.")
        elseif target then
            game.console.print("The " .. target.name .. " takes " .. self.var.damage .. " fire damage!", colors.red)
            target.fighter:take_damage(self.var.damage)
        else
            game.console.print("The fireball splashes against the wall.")
        end
        game.state.playing = PLAYING_STATE.waiting
        direction = DIRECTIONS.none
        aimable_spell = nil
        console.draw()
    end
end

function cast_confusion(self)
    local monster = game.map.closest_monster(self.var.range)
    if monster == nil then
        game.console.print("No enemy in range.")
        return "cancelled"
    end

    game.console.print("The " .. monster.name .. " seems dazed and confused!", color_orange)
    add_invocation(monster, self.var.duration, invoke_confusion)
end

function cast_strength(self)
    game.console.print("The " .. game.player.character.name .. " grows stronger!", colors.dark_purple)
    add_invocation(game.player.character, self.var.duration, invoke_strength)
end

function cast_lightning_storm(self)
    local gobjects = game.map.gameobjects_in_range(game.player.character.x, game.player.character.y, self.var.range)
    if table.maxn(gobjects) == 0 then
        game.console.print(table.maxn(gobjects))
        game.console.print("No enemy in range.")
        return "cancelled"
    end
    local monsters = {}
    for k, v in pairs(gobjects) do
        if v.ai ~= nil then
            table.insert(monsters, v)
        end
    end

    game.console.print("A lightning storm strikes " .. table.maxn(monsters) .. " targets, dealing " .. self.var.damage .. " damage to each!", colors.yellow)
    for k, v in pairs(monsters) do
        v.fighter:take_damage(self.var.damage)
    end
end

function staff_love_dart(self)
    game.state.playing = PLAYING_STATE.casting
    if direction == DIRECTIONS.none then
        aimable_spell = {func=staff_love_dart, item=self}
        if self.var.charges > 0 then
            return 'cancelled'
        else
            return
        end
    else
        target = game.map.find_target(direction)
        if target == "wrong_direction" then
            game.console.print("Wrong key.")
        elseif target then
            local dam = self.var.damage
            game.console.print("The " .. target.name .. " takes " .. dam .. " love damage! " .. self.var.charges - 1 .. " charges left.", colors.light_purple)
            target.fighter:take_damage(dam)
        else
            game.console.print("The dart splashes against the wall.")
        end
        self.var.charges = self.var.charges - 1
        self.var.damage = love.math.random(15, 30)
        game.state.playing = PLAYING_STATE.waiting
        direction = DIRECTIONS.none
        aimable_spell = nil
        console.draw()
    end
end

--on equip
function equip_stone_mask()
    if game.player.character.fighter.hp ~= game.player.character.fighter:max_hp() then
        for k,v in pairs(game.player.character.fighter.invocations) do
            if v.invoke_function == invoke_vampirism then
                return
            end
        end
        game.console.print("A dark energy surrounds you. Prongs dig in your face. You feel lifeless, and yet, powerful...")
        add_invocation(game.player.character, 999999, invoke_vampirism)
    end
end

--equipment on usage
function use_silver_dagger(target)
    for k,v in pairs(target.fighter.invocations) do
        if v.invoke_function == invoke_vampirism then
            v.weakness = true
        end
    end
end


return item_factory