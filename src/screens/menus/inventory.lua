local screen = require('screens/screen')
local inventory = {}

function inventory.new()
    local self = screen.new()
    
    local header
    local mode

    function self:init(h, m)
        header = h
        mode = m
    end

    function self:draw()
    local options = {}
    if table.maxn(data.player.inventory) == 0 then
        table.insert(options, "Inventory is empty.")
    else
        for key, value in pairs(data.player.inventory) do
            local text = value.name
            if value.equipment ~= nil and value.equipment.is_equipped then
                text = text .. " (on " .. table.index_of(SLOTS, value.equipment.slot):gsub("_", " ") .. ")"
            end
            table.insert(options, text)
        end
    end
    console.drawMenu(header, options, 60)
    end

    function self:keypressed(key)
        screenmanager.pop()
        if data.player.inventory[table.index_of(ALPHABET, key)] then
            if mode == "use" then
                data.player.inventory[table.index_of(ALPHABET, key)].item:use();
            elseif mode == "drop" then
                data.player.inventory[table.index_of(ALPHABET, key)].item:drop();
            end
        end
        console.draw()
    end

    return self
end

return inventory