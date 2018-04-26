local screen = require('screens/screen')
local casting = {}

function casting.new()
    local self = screen.new()

    function self:draw()
        local x, y = camera.coordinates(data.camera, data.player.character.x + direction.dx, data.player.character.y + direction.dy)
        console.drawText("*", x, y, colors.yellow)
    end

    function self:keypressed(key)
        if key == "c" then
            local level = data.player.level
            aimable_spell.func(aimable_spell.item)
            screenmanager.pop()
            if level ~= data.player.level then
                screenmanager.pop()
                screenmanager.push("levelup")
            end
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