--a small library to give some console-like functionality to the love2d window
--requires colors, util
love.graphics.console = {}
function love.graphics.console.init(width, height, scale, font)
    love.graphics.console.scale = scale or 16
    love.graphics.console.width = width or 80
    love.graphics.console.height = height or 60
    love.graphics.console.setFont(font or "main")
    love.graphics.console.resize()
end
function love.graphics.console.setScale(scale)
    love.graphics.console.scale = scale
    love.graphics.console.resize()
end
function love.graphics.console.setWidth(width)
    love.graphics.console.width = width
    love.graphics.console.resize()
end
function love.graphics.console.setHeight(height)
    love.graphics.console.height = height
    love.graphics.console.resize()
end
function love.graphics.console.setFont(font)
    love.graphics.console.font = font
    love.graphics.setFont(love.graphics.newFont("resources/font/" .. font .. ".ttf", love.graphics.console.scale))
end
function love.graphics.console.setFullscreen(mode)
    love.window.setFullscreen(mode)
    love.graphics.console.scale = math.round(love.graphics.getHeight() / love.graphics.console.height)
    love.graphics.console.setFont(love.graphics.console.font)
end
function love.graphics.console.resize()
    love.window.setMode(love.graphics.console.width * love.graphics.console.scale, love.graphics.console.height * love.graphics.console.scale)
end
function love.graphics.console.point(x, y)
    return x * love.graphics.console.scale, y * love.graphics.console.scale
end
function  love.graphics.console.drawRect(mode, x, y, w, h, color)
     love.graphics.setColor(color)
     love.graphics.rectangle(mode, x * love.graphics.console.scale, y * love.graphics.console.scale, w * love.graphics.console.scale, h * love.graphics.console.scale)
     love.graphics.setColor(colors.white)
end
function  love.graphics.console.drawProgressBar(x, y, total_width, name, value, maximum, bar_color, back_color)
    --first calculate the width of the bar
    local bar_width = math.round(value / maximum * total_width)
 
    --render the background first
    love.graphics.console.drawRect("fill", x, y, total_width, 1, back_color)
 
    --now render the bar on top
    love.graphics.console.drawRect("fill", x, y, bar_width, 1, bar_color)

    --renders text on top of the progressbar
    local string = name .. ": " .. value .. "/" .. maximum
    love.graphics.console.drawText(string, x, y, color_white, 0, 0)
end
function  love.graphics.console.drawText(text, x, y, color, xoff, yoff)    
     love.graphics.print({color or colors.white, text}, 
                        x * love.graphics.console.scale + (xoff or 0), 
                        y * love.graphics.console.scale + (yoff or 0) + 5)
end
function  love.graphics.console.drawWindow(header, options, x, y, w, h)  
     love.graphics.console.drawRect("fill", x, y, w, h, special_colors.menu_grey)
     love.graphics.console.drawRect("line", x, y, w, h, colors.grey_2)
     love.graphics.console.drawText(header, love.graphics.console.centerText(x, w, header), y, colors.white, 5, 0)
    for k,v in pairs(options) do
         love.graphics.console.drawText(v.text, x+1, y + k + 1, v.color, 0, 0)
    end
end
function  love.graphics.console.drawMenu(header, options, width)
    if table.maxn(options) > 26 then
        error("Cannot have a menu with more than 26 options")
    end
    local toptions = {}
    for k,v in pairs(options) do
        table.insert(toptions, {text="(" .. ALPHABET[k] .. ") " .. v, color=colors.white})
    end

     love.graphics.console.drawWindow(header, toptions, 2, 2, width, table.maxn(options) + 4)
end
function  love.graphics.console.centerText(x, w, text)
    return x + math.round((w / 2) - ( love.graphics.getFont():getWidth(text) / 2 / love.graphics.console.scale))
end
function love.graphics.console.draw()
    if love.graphics and love.graphics.isActive() then
        love.graphics.clear(love.graphics.getBackgroundColor())
        love.graphics.origin()
        if love.draw then love.draw() end
        love.graphics.present()
    end
end
return love.graphics.console