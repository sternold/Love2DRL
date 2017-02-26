local screen = require('screens/screen')
local mainscreen = {}

function mainscreen.new()
    local self = screen.new()

    function self:draw()
    
    end

    function self:keypressed(key)

    end
    return self
end

return mainscreen