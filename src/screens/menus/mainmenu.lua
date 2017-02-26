local screen = require('screens/screen')
local mainmenu = {}

function mainmenu.new()
    local self = screen.new()

    function self:draw()
        console.drawMenu("TOMB OF KING LOVE by Sternold", {"New Game", "Continue", "Configuration", "Quit"}, 32)
    end

    function self:keypressed(key)
        local choice = table.index_of(ALPHABET, key)
        if choice == 1 then
            game.new_game(get_class_name(2))
            screenmanager.switch("game")
        elseif choice == 2 then
            game.load_game()
            screenmanager.switch("game")
        elseif choice == 3 then
            screenmanager.pop()
            screenmanager.push("config")
        elseif choice == 4 then
            love.event.quit()
        end
    end
    return self
end

return mainmenu