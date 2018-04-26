local screen = require('screens/screen')
local classselect = {}

function classselect.new()
    local self = screen.new()
    local classes = require("resources/script/classes")

    function self:draw()
        options = {}
        for k in pairs(classes) do
            table.insert(options, k)
        end
        console.drawMenu("Choose a class...", options, 32)
    end

    function self:keypressed(key)
        local choice = table.index_of(ALPHABET, key)
        if not choice or choice > table.count(classes) then
            return
        end
        game.new_game(table.get_key(classes, choice))
        screenmanager.switch("game")
        if config.tutorial then
            screenmanager.push("tutorial")
        end
    end
    return self
end

return classselect