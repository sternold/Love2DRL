local screen = require('screens/screen')
local levelup = {}

function levelup.new()
    local self = screen.new()

    function self:draw()
        console.drawMenu("What have you trained?", {"My Power", "My Defense", "My Courage"}, 32)
    end

    function self:keypressed(key)
        if table.index_of(ALPHABET, key) == 1 then
            game.player.character.fighter.base_power = game.player.character.fighter.base_power + 1
            game.console.print("You gain 1 Power!", color_yellow)
            game.player.character.fighter.hp = game.player.character.fighter:max_hp()   
            screenmanager.pop()  
            console.draw()
        elseif table.index_of(ALPHABET, key) == 2 then
            game.player.character.fighter.base_defense = game.player.character.fighter.base_defense + 1
            game.console.print("You gain 1 Defense!", color_yellow)
            game.player.character.fighter.hp = game.player.character.fighter:max_hp()     
            screenmanager.pop()
            console.draw()
        elseif table.index_of(ALPHABET, key) == 3 then
            game.player.character.fighter.base_max_hp = game.player.character.fighter.base_max_hp + 5
            game.console.print("You gain 5 HP!", color_yellow)
            game.player.character.fighter.hp = game.player.character.fighter:max_hp()     
            screenmanager.pop()
            console.draw()
        end
    end

    return self
end

return levelup