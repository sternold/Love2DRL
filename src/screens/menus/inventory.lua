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
    if table.maxn(game.player.inventory) == 0 then
        table.insert(options, "Inventory is empty.")
    else
        for key, value in pairs(game.player.inventory) do
            local text = value.name
            if value.equipment ~= nil and value.equipment.is_equipped then
                text = text .. " (on " .. value.equipment.slot .. ")"
            end
            table.insert(options, text)
        end
    end
    console.drawMenu(header, options, INVENTORY_WIDTH)
    end

    function self:keypressed(key)
        screenmanager.pop()
        if game.player.inventory[table.index_of(ALPHABET, key)] then
            if mode == "use" then
                game.player.inventory[table.index_of(ALPHABET, key)].item:use();
            elseif mode == "drop" then
                game.player.inventory[table.index_of(ALPHABET, key)].item:drop();
            end
        end
    end

    return self
end

return inventory