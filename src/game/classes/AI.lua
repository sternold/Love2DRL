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


ConfusedMonster = class('ConfusedMonster')
function ConfusedMonster:initialize()
end

function ConfusedMonster:take_turn()
    game.console.print("The " .. self.owner.name .. " stumbles around!", color_orange)
    self.owner:move(love.math.random(-1, 1), love.math.random(-1, 1))
end