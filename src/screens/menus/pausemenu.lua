local screen = require('screens/screen')
local pause = {}

function pause.new()
    local self = screen.new()

    function self:draw()
        console.drawMenu("PAUSED", {"CONTINUE", "SAVE", "MAIN MENU", "EXIT"}, 32)
    end

    function self:keypressed(key)
        if table.index_of(ALPHABET, key) == 1 then
            screenmanager.pop() 
        elseif table.index_of(ALPHABET, key) == 2 then
            game.save_game()
        elseif table.index_of(ALPHABET, key) == 3 then
            screenmanager.switch("main")
            screenmanager.push("mainmenu")
        elseif table.index_of(ALPHABET, key) == 4 then
            love.event.quit()
        end
    end

    return self
end

return pause