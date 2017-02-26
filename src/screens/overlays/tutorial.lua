local screen = require('screens/screen')
local tutorial = {}

function tutorial.new()
    local self = screen.new()

    function self:draw()
        local tutorial = {}
        table.insert(tutorial, 1, {text="Press the ARROW keys to move.", color=color_white})
        table.insert(tutorial, 3, {text="Press G to pick up items.", color=color_white})
        table.insert(tutorial, 5, {text="Press I to open your inventory.", color=color_white})
        table.insert(tutorial, 7, {text="Press D to drop an item.", color=color_white})
        table.insert(tutorial, 9, {text="Press the corresponding letter to select an option inside a menu.", color=color_white})
        table.insert(tutorial, 11, {text="While casting aimable spells, press the arrow keys to aim, and C to cast.", color=color_white})
        table.insert(tutorial, 13, {text="Press Comma (,) to move down stairs.", color=color_white})
        table.insert(tutorial, 15, {text="Press L to look around.", color=color_white})
        table.insert(tutorial, 17, {text="Press R to restart when you've died.", color=color_white})
        table.insert(tutorial, 19, {text="Press ESC to save and exit.", color=color_white})
        table.insert(tutorial, 21, {text="Reach floor 10 and defeat all the monsters there to win!", color=color_white})
        table.insert(tutorial, 35, {text="Press the X to close or open this tutorial.", color=color_white})
        console.drawWindow("TUTORIAL", tutorial, 3, 3, console.width - 6, console.height - 10)
    end

    function self:keypressed(key)
        if key == "x" then
            screenmanager.pop()
            console.draw()
        end
    end

    return self
end

return tutorial