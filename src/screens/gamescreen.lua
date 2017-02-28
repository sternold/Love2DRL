local screen = require('screens/screen')
local gamescreen = {}

function gamescreen.new()
    local self = screen.new()

    local viewinrange = false

    function self:draw()
        world_draw()
        UI_draw()

        if viewinrange then view_in_range_window() end
    end

    function self:keypressed(key)
        local update = true
        if key == "left" or key == "kp4" then data.player:move_or_attack(-1, 0)
        elseif key == "right" or key == "kp6" then data.player:move_or_attack(1, 0)       
        elseif key == "up" or key == "kp8" then data.player:move_or_attack(0, -1)      
        elseif key == "down" or key == "kp2" then data.player:move_or_attack(0, 1)
        elseif key == "i" then
                screenmanager.push("inventory", data.player.character.name .. "'s inventory", "use")
                update = false
        elseif key == "d" then 
                screenmanager.push("inventory", "dropping", "drop")
                update = false
        elseif key == "g" then
                for k, v in pairs(data.map.objects) do
                    if v.item and v.x == data.player.character.x and v.y == data.player.character.y then
                        v.item:pick_up()
                        break
                    end
                end
        elseif key == "," then
                if data.player.character.x == data.map.stairs.x and data.player.character.y == data.map.stairs.y then
                    game.next_level()
                end
                update = false
        elseif key == "l" then 
                viewinrange = not viewinrange
                update = false
        elseif key == "x" then 
                screenmanager.push("tutorial")
                update = false
        elseif key == "escape" then 
                screenmanager.push("pause")
                update = false
        else update = false
        end
        
        if update then
            game.update()
        end
    end

    function world_draw()
        data.map:draw()
        fog_of_war()
        for k,v in pairs(data.map.objects) do
            v:draw()
        end
        data.player.character:draw()
    end

    function fog_of_war()
        for x,arr in pairs(data.map.tiles) do
            for y, til in pairs(arr) do
                console.drawRect("fill", x, y, 1, 1, til.visibility)
            end
        end
    end

    function UI_draw()
        --level
        console.drawText("LvL " .. data.player.level, 1, console.height - 6, colors.white, 0, 0)
    
        --HP
        console.drawProgressBar(1, 1, 20, "HP", data.player.character.fighter.hp, data.player.character.fighter:max_hp(), colors.light_green, colors.red)

        --xp
        console.drawProgressBar(1,  console.height - 5, 12, "EXP", data.player.character.fighter.xp, (data.player.base_xp + data.player.level * data.player.rate_xp), colors.dark_yellow, colors.grey_5)

        --Attributes
        console.drawText("PWR:" .. data.player.character.fighter:power(), 1, console.height - 3, colors.white, 0, 0)
        console.drawText("DEF:" .. data.player.character.fighter:defense(), 1, console.height - 2, colors.white, 0, 0)
    
        --Dungeon level
        console.drawText("Floor " .. data.map.floor, console.width - 10, 1, colors.white, 0, 0)

        --console
        console_draw(15)
    end

    function console_draw(x)
        local count = table.maxn(data.console_log)
        local max = 1
        if count < 5 then
            max = count
        else
            max = 5
        end
        for i=1, max do
            console.drawText(data.console_log[count + 1 - i][1], x, console.height - i - 1, data.console_log[count + 1 - i][2] or nil)
        end
    end

    function view_in_range_window()
        local visobj = {}
            for k,v in pairs(data.map.objects) do
                if data.map.tiles[v.x][v.y].visibility == special_colors.fov_visible then
                    table.insert(visobj, {text = "[" .. v.char .. "] " .. v.name, color=v.color})
                end
            end
            console.drawWindow("you see:", visobj, console.width - 40, 5, 35, table.maxn(visobj) + 5)
    end

    return self
end

return gamescreen