--function containers
local game = {}

--variables
data = {}

aimable_spell = nil
direction = DIRECTIONS.none

--init
function game.new_game(class)
    local class_factory = require("resources/script/classes")
    local dun_gen = require("game/dungeon/dungeongen")
    console.setFullscreen(config.fullscreen)
    data.console_log = {}
    
    --Welcome message
    game.print("Welcome stranger, be prepared to perish in the tombs of LOVE!", colors.red)

    local map, coords = dun_gen.generate(1) 
    data.map = map
    data.player = class_factory[class](coords.x, coords.y)
    data.player:visible_range()
    for k,v in pairs(data.player.inventory) do
        if v.equipment then
            v.equipment:equip()
        end
    end
    console.draw()
end

function game.save_game()
    bitser.dumpLoveFile(SAVE_FILE, data)
    game.print("Game Saved.")
end

function game.load_game()
    if love.filesystem.isFile(SAVE_FILE) then
        console.setFullscreen(config.fullscreen)
        data = bitser.loadLoveFile(SAVE_FILE)
        data.player:visible_range()
    else
        print("no save data could be found.")
    end
    console.draw()
end

function game.update()
    for key,value in pairs(data.map.objects) do 
        if value.ai then
            for k, v in pairs(value.fighter.invocations) do
                v:invoke()
            end
            value.ai:take_turn()
        end 
    end
    for k, v in pairs(data.player.character.fighter.invocations) do
        v:invoke()
    end
end

function game.next_level()
    local dun_gen = require("game/dungeon/dungeongen")
    game.print("You take a moment to rest...", colors.red)
    local map, coords = dun_gen.generate(data.map.floor + 1)
    data.map = map
    data.player.character.x = coords.x
    data.player.character.y = coords.y
    data.player.character.fighter:heal(math.round(data.player.character.fighter:max_hp() / 2))
    data.player:visible_range()
    console.draw()
end

--console
function game.print(string, color)
    print(string)
    table.insert(data.console_log, {string, color})
end

--util
function fov_cast_light(row, cstart, cend, xx, xy, yx, yy, range)
    local startx = data.player.character.x
    local starty = data.player.character.y
    local radius = range
    local start = cstart
    
    local new_start = 0
    if start < cend then
        return
    end

    local width = table.maxn(data.map.tiles)
    local height = table.maxn(data.map.tiles[1])

    local blocked = false
    for distance = row, radius do
        local deltay = distance * -1
        for deltax = distance * -1, 0 do
            local currentx = startx + deltax * xx + deltay * xy
            local currenty = starty + deltax * yx + deltay * yy
            local leftslope = (deltax - .5) / (deltay +.5)
            local rightslope = (deltax + .5) / (deltay - .5)

            if not (currentx >= 0 and currenty >= 0 and currentx < width and currenty < height) or start < rightslope then
                --Continue
            elseif cend > leftslope then
                break;
            else
                if math.circle_radius(deltax, deltay, 0) <= radius then
                    data.map.tiles[currentx][currenty].visibility = special_colors.fov_visible
                end

                if blocked then
                    if data.map.tiles[currentx][currenty].block_sight then
                        new_start = rightslope
                        --Continue
                    else 
                        blocked = false
                        start = new_start
                    end
                else
                    if data.map.tiles[currentx][currenty].block_sight and distance < radius then
                        blocked = true
                        fov_cast_light(distance + 1, start, leftslope, xx, xy, yx, yy, range)
                        new_start = rightslope
                    end
                end
            end
        end
        if blocked then
            break
        end
    end
end

function random_choice(collection)
    local sum = 0
    for k,v in pairs(collection) do
        sum = sum + v
    end
    local dice = love.math.random(1, sum)
    sum = 0
    for k,v in pairs(collection) do
        sum = sum + v
        if dice <= sum then
            return k
        end
    end
end

return game