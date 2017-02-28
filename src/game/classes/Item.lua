Item = class('Item')
function Item:initialize(use_function)
    self.use_function = use_function
    self.var = {}
end

function Item:pick_up()
    if table.maxn(data.player.inventory) >= 26 then
        game.print("Your inventory is full.")
    else
        table.insert(data.player.inventory, self.owner)
        table.remove(data.map.objects, table.index_of(data.map.objects, self.owner))
        game.print("You picked up a " .. self.owner.name .. "!", self.owner.color)
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
            table.remove(data.player.inventory, table.index_of(data.player.inventory, self.owner))
        end
    else
        game.print("The " .. self.owner.name .. " cannot be used.")
    end
end

function Item:drop()
    if self.owner.equipment then
        self.owner.equipment:dequip()
    end
    table.insert(data.map.objects, self.owner)
    table.remove(data.player.inventory, table.index_of(data.player.inventory, self.owner))
    self.owner.x = data.player.character.x
    self.owner.y = data.player.character.y
    game.print("you dropped a " .. self.owner.name .. ".", self.owner.color)
end

--FUNCTIONS
function item_reg()
    bitser.register("it_eat", eat)
    bitser.register("it_heal", cast_heal)
    bitser.register("it_regen", cast_regen)
    bitser.register("it_lit", cast_lightning)
    bitser.register("it_conf", cast_fireball)
    bitser.register("it_str", cast_confusion)
    bitser.register("it_litstr", cast_strength)
    bitser.register("it_stnmsk", cast_lightning_storm)
    bitser.register("it_sldg", equip_stone_mask)
    bitser.register("it_stfmm", staff_love_dart)
    bitser.register("it_fir", use_holy_weapon)
end

--usables
function eat(self)
    data.player.character.fighter:heal(table.maxn(self.var.ingredients) * 5)
    for k,v in pairs(data.player.character.fighter.invocations) do
        if v.invoke_function == invoke_vampirism and table.has_value(self.ingredients, "garlic") then
            v.var.weakness = true
        end
    end
    game.print("You eat a some " .. self.owner.name .. "!", colors.green)
end

function cast_heal(self)
    if data.player.character.fighter.hp == data.player.character.fighter:max_hp() then
        game.print("You're already at full health.", colors.light_blue)
        return "cancelled"
    end
    game.print("You're starting to feel better!", colors.light_green)
    data.player.character.fighter:heal(self.var.amount)
end

function cast_regen(self)
    game.print("The " .. data.player.character.name .. " slowly grows healthier!", colors.light_green)
    add_invocation(data.player.character.fighter, self.var.duration, invoke_regen)
end

function cast_lightning(self)
    local monster = data.map:closest_enemy(data.player.character, self.var.range)
    if monster == nil then
        game.print("No enemy in range.")
        return "cancelled"
    end

    game.print("A lightning bolt strikes the " .. monster.name .. ", dealing " .. self.var.damage .. " damage!", colors.yellow)
    monster.fighter:take_damage(self.var.damage)
end

function cast_fireball(self)
    if direction == DIRECTIONS.none then
        aimable_spell = {func=cast_fireball, item=self}
        screenmanager.push("casting")
        return
    else
        target = data.map:target_direction(data.player.character, direction)
        if target == "wrong_direction" then
            game.print("Wrong key.")
        elseif target then
            game.print("The " .. target.name .. " takes " .. self.var.damage .. " fire damage!", colors.red)
            target.fighter:take_damage(self.var.damage)
        else
            game.print("The fireball splashes against the wall.")
        end
        direction = DIRECTIONS.none
        aimable_spell = nil
        console.draw()
    end
end

function cast_confusion(self)
    local monster = data.map:closest_enemy(data.player.character, self.var.range)
    if monster == nil then
        game.print("No enemy in range.")
        return "cancelled"
    end

    game.print("The " .. monster.name .. " seems dazed and confused!", color_orange)
    add_invocation(monster, self.var.duration, invoke_confusion)
end

function cast_strength(self)
    game.print("The " .. data.player.character.name .. " grows stronger!", colors.dark_purple)
    add_invocation(data.player.character, self.var.duration, invoke_strength)
end

function cast_lightning_storm(self)
    local gobjects = data.map:gameobjects_in_range(data.player.character, self.var.range)
    if table.maxn(gobjects) == 0 then
        game.print(table.maxn(gobjects))
        game.print("No enemy in range.")
        return "cancelled"
    end
    local monsters = {}
    for k, v in pairs(gobjects) do
        if v.ai ~= nil then
            table.insert(monsters, v)
        end
    end

    game.print("A lightning storm strikes " .. table.maxn(monsters) .. " targets, dealing " .. self.var.damage .. " damage to each!", colors.yellow)
    for k, v in pairs(monsters) do
        v.fighter:take_damage(self.var.damage)
    end
end

function staff_love_dart(self)
    if direction == DIRECTIONS.none then
        aimable_spell = {func=staff_love_dart, item=self}
        screenmanager.push("casting")
        if self.var.charges > 0 then
            return 'cancelled'
        else
            return
        end
    else
        target = data.map:target_direction(data.player.character, direction)
        if target == "wrong_direction" then
            game.print("Wrong key.")
        elseif target then
            local dam = self.var.damage
            game.print("The " .. target.name .. " takes " .. dam .. " love damage! " .. self.var.charges - 1 .. " charges left.", colors.light_purple)
            target.fighter:take_damage(dam)
        else
            game.print("The dart splashes against the wall.")
        end
        self.var.charges = self.var.charges - 1
        self.var.damage = love.math.random(15, 30)
        direction = DIRECTIONS.none
        aimable_spell = nil
        console.draw()
    end
end

--on equip
function equip_stone_mask()
    if data.player.character.fighter.hp ~= data.player.character.fighter:max_hp() then
        for k,v in pairs(data.player.character.fighter.invocations) do
            if v.invoke_function == invoke_vampirism then
                return
            end
        end
        game.print("A dark energy surrounds you. Prongs dig in your face. You feel lifeless, and yet, powerful...")
        add_invocation(data.player.character, 999999, invoke_vampirism)
    end
end

--equipment on usage
function use_holy_weapon(target)
    for k,v in pairs(target.fighter.invocations) do
        if v.invoke_function == invoke_vampirism then
            v.weakness = true
        end
    end
end
