local screen = require('screens/screen')
local levelup = {}

function levelup.new()
    local self = screen.new()

    function self:draw()
        console.drawMenu("What have you trained?", {"My Power", "My Defense", "My Courage"}, 32)
    end

    function self:keypressed(key)
        if table.index_of(ALPHABET, key) == 1 then
            data.player.character.fighter.base_power = data.player.character.fighter.base_power + 1
            game.print("You gain 1 Power!", colors.yellow)
            data.player.character.fighter.hp = data.player.character.fighter:max_hp()   
            screenmanager.pop()  
            console.draw()
        elseif table.index_of(ALPHABET, key) == 2 then
            data.player.character.fighter.base_defense = data.player.character.fighter.base_defense + 1
            game.print("You gain 1 Defense!", colors.yellow)
            data.player.character.fighter.hp = data.player.character.fighter:max_hp()     
            screenmanager.pop()
            console.draw()
        elseif table.index_of(ALPHABET, key) == 3 then
            data.player.character.fighter.base_max_hp = data.player.character.fighter.base_max_hp + 5
            game.print("You gain 5 HP!", colors.yellow)
            data.player.character.fighter.hp = data.player.character.fighter:max_hp()     
            screenmanager.pop()
            console.draw()
        end
    end

    return self
end

return levelup