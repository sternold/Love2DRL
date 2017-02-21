graphics = love.graphics

function graphics.progress_bar_draw(x, y, total_width, name, value, maximum, bar_color, back_color)
    --render a bar (HP, experience, etc). first calculate the width of the bar
    local bar_width = math.round(value / maximum * total_width)
 
    --render the background first
    graphics.rect_draw("fill", x, y, total_width, 1, back_color)
 
    --now render the bar on top
    graphics.rect_draw("fill", x, y, bar_width, 1, bar_color)

    local string = name .. ": " .. value .. "/" .. maximum
    graphics.text_draw(string, x, y, color_white, 0, 0)
end

function graphics.rect_draw(mode, x, y, w, h, color)
    graphics.setColor(color)
    graphics.rectangle(mode, x * SCALE, y * SCALE, w * SCALE, h * SCALE)
    graphics.setColor(colors.white)
end

function graphics.text_draw(text, x, y, color, xoff, yoff)
    graphics.draw(graphics.newText(graphics.getFont(), {color or colors.white, text}), x * SCALE + xoff, y * SCALE + yoff + 5)
end

function graphics.window(header, options, x, y, w, h)  
    graphics.rect_draw("fill", x, y, w, h, special_colors.menu_grey)
    graphics.rect_draw("line", x, y, w, h, colors.grey_2)
    graphics.text_draw(header, x+1, y, colors.white, 5, 0)
    for k,v in pairs(options) do
        graphics.text_draw(v.text, x+1, y + k + 1, v.color, 0, 0)
    end
end

function graphics.menu(header, options, width)
    if table.maxn(options) > 26 then
        error("Cannot have a menu with more than 26 options")
    end
    local toptions = {}
    for k,v in pairs(options) do
        table.insert(toptions, {text="(" .. ALPHABET[k] .. ") " .. v, color=color_white})
    end

    graphics.window(header, toptions, 2, 2, width, table.maxn(options) + 4)
end