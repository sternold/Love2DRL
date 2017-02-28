local screen = require('screens/screen')
local casting = {}

function casting.new()
    local self = screen.new()

    function self:draw()
        console.drawText("*", data.player.character.x + direction.dx, data.player.character.y + direction.dy, colors.yellow)
    end

    function self:keypressed(key)
        if key == "c" then
            aimable_spell.func(aimable_spell.item)
            screenmanager.pop()
        else
            if key == "left" or key == "kp4" then
                direction = DIRECTIONS.left
            elseif key == "right" or key == "kp6" then
                direction = DIRECTIONS.right
            elseif key == "up" or key == "kp8" then
                direction = DIRECTIONS.up
            elseif key == "down" or key == "kp2" then
                direction = DIRECTIONS.down
            end
        end
    end

    return self
end

return casting