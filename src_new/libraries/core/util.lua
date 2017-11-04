--A small library for some extra utilities.
--@Author Tobi van Bronswijk


--MATH
function math.round(number)
    if number - math.floor(number) >= .5 then
        return math.ceil(number)
    else
        return math.floor(number)
    end
end

function math.circle_radius(x, y, z)
    local dx = math.abs(x)
    local dy = math.abs(y)
    local dz = math.abs(z)
    return math.sqrt(dx*dx + dy*dy + dz*dz)
end

--TABLE
function table.index_of(table, object)
    for key, value in pairs(table) do
        if value == object then
            return key
        end
    end
    return nil
end

function table.get_key(table, index)
    count = 1
    for key, value in pairs(table) do
        if count == index then
            return key
        end
        count = count + 1
    end
    return nil
end

function table.has_key(table, key)
    for k, v in pairs(table) do
        if key == k then
            return true
        end
    end
    return false
end

function table.has_value(table, value)
    for key, value in pairs(table) do
        if value == value then
            return true
        end
    end
    return false
end

function table.count(table)
    i = 0
    for key, value in pairs(table) do
        i = i + 1
    end
    return i
end

function table.random(table)
    local table_count = table.count(table)
    local choice = love.math.random(1, table_count)
    local i = 1
    for key, value in pairs(table) do
        if i == choice then
            return value 
        end
        i = i + 1
    end
end