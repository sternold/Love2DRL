local screen = require('screens/screen')
local scrconfig = {}

function scrconfig.new()
    local self = screen.new()

    function self:draw()
        local options = {}
        for k,v in pairs(config) do
            local boolstring = nil
            if v then
                boolstring = "on"
            else
                boolstring = "off"
            end
            table.insert(options, k .. " = " .. boolstring)
        end
        table.insert(options, "Back")
        console.drawMenu("Configuration", options, 32)
    end

    function self:keypressed(key)
        local choice = table.index_of(ALPHABET, key)
        local keys = {}
        for k,v in pairs(config) do
            table.insert(keys, k)
        end 
        if choice == table.maxn(keys) + 1 then
            save_config()
            screenmanager.pop()
            screenmanager.push("mainmenu")
        else
            config[keys[choice]] = not config[keys[choice]]
        end
        console.draw()
    end

    return self
end

return scrconfig