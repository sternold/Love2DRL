local screen = require('screens/screen')
local mainscreen = {}

function mainscreen.new()
    local self = screen.new()

    function self:init()
        console.setFullscreen(false)
    end

    function self:draw()
    
    end

    function self:keypressed(key)

    end
    return self
end

return mainscreen