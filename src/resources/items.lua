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

--usables
function eat(self)
    game.player.character.fighter:heal(table.maxn(self.var.ingredients) * 2)
    for k,v in pairs(game.player.character.fighter.invocations) do
        if v.invoke_function == invoke_vampirism and table.has_value(self.ingredients, "garlic") then
            v.var.weakness = true
        end
    end
    game.console.print("You eat a some " .. self.owner.name .. "!", colors.green)
end

function cast_heal()
    if game.player.character.fighter.hp == game.player.character.fighter.max_hp.get() then
        game.console.print("You're already at full health.", colors.light_blue)
        return "cancelled"
    end
    game.console.print("You're starting to feel better!", colors.light_green)
    game.player.character.fighter:heal(20)
end

function cast_regen()
    console_print("The " .. game.player.character.name .. " slowly grows healthier!", colors.light_green)
    add_invocation(game.player.character.fighter, REGEN_DURATION, invoke_regen)
end

function cast_lightning()
    local monster = closest_monster(SPELL_RANGE)
    if monster == nil then
        console_print("No enemy in range.")
        return "cancelled"
    end

    console_print("A lightning bolt strikes the " .. monster.name .. ", dealing " .. LIGHTNING_DAMAGE .. " damage!", color_yellow)
    monster.fighter:take_damage(LIGHTNING_DAMAGE)
end

function cast_fireball()
    game_state = "aiming"
    if direction == DIRECTIONS["none"] then
        aimable_spell = cast_fireball
    else
        target = find_target(direction)
        if target == "wrong_direction" then
            console_print("Wrong key.")
        elseif target ~= nil then
            console_print("The " .. target.name .. " takes " .. FIREBALL_DAMAGE .. " fire damage!", color_red)
            target.fighter:take_damage(FIREBALL_DAMAGE)
            game_state = "playing"
            direction = DIRECTIONS["none"]
            aimable_spell = nil
            draw_screen()
        else
            console_print("The fireball splashes against the wall.")
            game_state = "playing"
            direction = DIRECTIONS["none"]
            aimable_spell = nil
            draw_screen()
        end
    end
end

function cast_confusion()
    local monster = closest_monster(SPELL_RANGE)
    if monster == nil then
        console_print("No enemy in range.")
        return "cancelled"
    end

    console_print("The " .. monster.name .. " seems dazed and confused!", color_orange)
    add_invocation(monster, CONFUSION_DURATION, invoke_confusion)
end

function cast_strength()
    console_print("The " .. player.name .. " grows stronger!", color_player)
    add_invocation(player, STRENGTH_DURATION, invoke_strength)
end

function cast_lightning_storm()
    local gobjects = gameobjects_in_range(player.x, player.y, LIGHTNING_STORM_RANGE)
    if table.maxn(gobjects) == 0 then
        console_print(table.maxn(gobjects))
        console_print("No enemy in range.")
        return "cancelled"
    end
    local monsters = {}
    for k, v in pairs(gobjects)do
        if v.ai ~= nil then
            table.insert(monsters, v)
        end
    end

    console_print("A lightning storm strikes " .. table.maxn(monsters) .. " targets, dealing " .. LIGHTNING_DAMAGE .. " damage to each!", color_yellow)
    for k, v in pairs(monsters) do
        v.fighter:take_damage(LIGHTNING_DAMAGE)
    end
end

--on equip
function equip_stone_mask()
    if player.fighter.hp ~= player.fighter.max_hp then
        for k,v in pairs(player.invocations) do
            if v.invoke_function == invoke_vampirism then
                return
            end
        end
        console_print("A dark energy surrounds you. Prongs dig in your face. You feel lifeless, and yet, powerfull...")
        add_invocation(player, 999999, invoke_vampirism)
    end
end

--equipment on usage
function use_silver_dagger(target)
    for k,v in pairs(target.invocations) do
        if v.invoke_function == invoke_vampirism then
            v.weakness = true
        end
    end
end


return {chances=item_chances, factory=nil}