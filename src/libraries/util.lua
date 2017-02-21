--MATH
function math.round(number)
    local toround = number - math.floor(number)
    if toround >= .5 then
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
function table.index_of(t, object)
    for key, value in pairs(t) do
        if value == object then
            return key
        end
    end
    return nil
end

function table.has_key(t, key)
    for k, v in pairs(t) do
        if key == k then
            return true
        end
    end
    return false
end

function table.has_value(t, value)
    for k, v in pairs(t) do
        if value == v then
            return true
        end
    end
    return false
end

function table.count(t)
    i = 0
    for k, v in pairs(t) do
        i = i + 1
    end
    return i
end

function table.random(t)
    local table_count = table.count(t)
    local choice = love.math.random(1, table_count)
    local i = 1
    for k,v in pairs(t) do
        if i == choice then
            return v 
        end
        i = i + 1
    end
end