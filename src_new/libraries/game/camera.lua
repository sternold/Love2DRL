local cam = {}

function cam.init(w, h)
    local camera = {}
    camera.width = w
    camera.height = h
    camera.x = 0
    camera.y = 0
    return camera
end

function cam.move(camera, map, dx, dy)
    local x = dx - math.round(camera.width / 2)
	local y = dy - math.round(camera.height / 2)
 
	if x < 0 then x = 0 end
	if y < 0 then y = 0 end
	if x > map.width - camera.width - 1 then x = map.width - camera.width - 1 end
	if y > map.height - camera.height - 1 then y = map.height - camera.height - 1 end
 
	camera.x = x
    camera.y = y
end

function cam.coordinates(camera, x, y)
    local dx = x - camera.x
    local dy = y - camera.y
 
	if dx < 0 or dy < 0 or dx > camera.width or dy > camera.height then
		return nil, nil
    end
	return dx, dy
end


return cam