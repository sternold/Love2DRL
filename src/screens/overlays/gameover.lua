local screen = require('screens/screen')
local gameover = {}

function gameover.new()
    local self = screen.new()

    local text = ""

    function self:init(t)
        text = t
        game.console.print(text, colors.yellow)
    end

    function self:draw()
        console.drawRect("fill", 0, 0, console.width, console.height, {0,0,0,100})
        console.drawText(text, console.centerText(0, console.width, text), (math.round(console.height / 2)), colors.white)
    end

    function self:keypressed(key)
        if key == "r" then
            game.new_game(get_class_name(1))
            screenmanager.pop()
        end
        console.draw()
    end

    return self
end

return gameover