
function inv_reg()
    bitser.register("inv_conf", invoke_confusion)
    bitser.register("inv_str", invoke_strength)
    bitser.register("inv_regen", invoke_regen)
    bitser.register("inv_vamp", invoke_vampirism)
end

function add_invocation(target, duration, invoke_function)
    local inv = Invocation(duration, invoke_function)
    if target.fighter then 
        inv.owner = target.fighter
        table.insert(target.fighter.invocations, inv)
    end
end

function invoke_confusion(invocation, state)
    if invocation.old_ai == nil and state then
        invocation.old_ai = invocation.owner.owner.ai
        new_ai = ConfusedMonster()
        new_ai.owner = invocation.owner.owner 
        invocation.owner.owner.ai = new_ai
    elseif not state then
        game.console.print("The confusion has ended.", color_green)
        invocation.owner.owner.ai = invocation.old_ai
        table.remove(invocation.owner.invocations, table.index_of(invocation))
    end
end

function invoke_strength(invocation, state)
    if not invocation.fired and state then
        invocation.old_pwr = invocation.owner.base_power
        new_pwr = invocation.owner.base_power + STRENGTH_BONUS
        invocation.owner.base_power = new_pwr
        invocation.fired = true
    elseif not state then
        game.console.print(invocation.owner.owner.name .. " no longer feels powerful.", color_player)
        invocation.owner.base_power = invocation.old_pwr
        table.remove(invocation.owner.invocations, table.index_of(invocation))
    end
end

function invoke_regen(invocation, state)
    if state then
        invocation.owner:heal(5)
        game.console.print(invocation.owner.owner.name .. " feels a little better!", color_player)
    elseif not state then
        table.remove(invocation.owner.invocations, table.index_of(invocation))
    end
end

function invoke_vampirism(invocation, state)
    if state then
        invocation.owner.base_defense = 30
        invocation.owner.base_power = 30
        invocation.owner.base_max_hp = 5
        invocation.owner.hp = 5
        invocation.owner.owner.colortext = graphics.newText(graphics.getFont(), {color_white, "w"})
        if invocation.weakness then
            invocation.owner.death_function(invocation.owner)
        end
    elseif not state then
        table.remove(invocation.owner.invocations, table.index_of(invocation))
    end
end
