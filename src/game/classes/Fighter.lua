function fit_reg()
    bitser.register("obj_pld", player_death)
    bitser.register("obj_mod", monster_death)
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
            game.print(self.owner.name .. ' attacks ' .. target.name .. ' for ' .. damage .. ' hit points.')
            target.fighter:take_damage(damage)
        else
            game.print(self.owner.name .. ' attacks ' .. target.name .. ' but it has no effect!')
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
    target.char = '%'
    target.color = colors.dark_red
    screenmanager.push("gameover", "Death is inevitable.")
end

function monster_death(target)
    game.print(target.name .. ' is dead!', colors.dark_red)
    data.player.character.fighter.xp = data.player.character.fighter.xp + target.fighter.xp
    target.char = '%'
    target.color = colors.dark_red
    target.blocks = false
    target.fighter = nil
    target.ai = nil
    target.name = 'remains of ' .. target.name
    data.map.monster_count = data.map.monster_count - 1
    data.player:check_level_up()
end