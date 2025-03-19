
local vec2 = math.vec2

local Viewport = require("src.scene.viewport")

local Body = require("src.body.body")
local Point = require("src.body.shape.point")
local Line = require("src.body.shape.line")
local Circle = require("src.body.shape.circle")

local tick = {length = 0.016, currentTime = 0, extraTime = 0, frame = 0, lastUpdate = 0, extraUpdate = 0, active = true}

local VP = {
	main = Viewport(32, 32, 1280, 720),
	ctrl = Viewport(32, 720 + 64, 1280, 256),
	dbg1 = Viewport(1280 + 64, 32, 480, 480),
	dbg2 = Viewport(1280 + 64, 80 + 480, 480, 480)
}

local mouse = vec2(0, 0)
local grabber = Point(0, 0)

local player = Circle(0, -256, 96)
local line = Line(0, 0, 512)

local img = {}

function load()
	img = {
		whale = love.graphics.newImage("img/whale.png"),
		arrow = love.graphics.newImage("img/arrow.png"),
		luv = love.graphics.newImage("img/luv.png")
	}
	
	VP.main.gui, VP.ctrl.ui = Body(), Body()
	
	VP.dbg1.zoom, VP.dbg2.zoom = 1, 1
	
	VP.main.query = {idx = -1, offset = {}, button = 0}
	VP.ctrl.query = {idx = -1, offset = {}, button = 0}
	VP.dbg1.query = {idx = -1, zoom = {}}
	VP.dbg2.query = {idx = -1, zoom = {}}
	
	for i = 0, 11 do -- origin, velocity, scale, angle, torque, tick
		VP.ctrl.ui:addShape(Circle(128 + 256 * (i % 2), 128 + 256 * math.floor(i / 2), 96))
		VP.ctrl.ui.shape[i + 1].mode = "line"
	end

	VP.ctrl.ui.shape[11]:setOrigin(128 + 512 + 256, 128)
  VP.ctrl.ui.shape[11].radius = 64
  VP.ctrl.ui.shape[11].mode = "fill"
  VP.ctrl.ui.shape[12]:setOrigin(128 + 1024, 128)
  VP.ctrl.ui.shape[12].radius = 64
  
  VP.main.gui:addShape(Circle(0, 0, 64, -math.pi / 2))
  VP.main.gui:addShape(Circle(160, 0, 64, math.pi / 2))
  VP.main.gui:addShape(Circle(VP.main.w - 192, 0, 64))
  
  for i = 1, 3 do
  	vec2.translate(VP.main.gui.shape[i].origin, vec2(VP.main.x + 96, VP.main.y + VP.main.h - 96))
  end
  
  player.velocity.y = -500
  
  player.vDamp = 0.996
  player.tDamp = 0.996
  
  line.vDamp = 0.95
  line.tDamp = 0.95
end

function love.touchpressed(id, x, y, dx, dy, pressure)
	local idx = tonumber(string.sub(tostring(id), 13)) or 0
	
	grabber.origin.x, grabber.origin.y = x, y
	
	for i = 1, #VP.main.gui.shape do
		if grabber:checkCollision(VP.main.gui.shape[i]).collide then
			VP.main.query.button = i
			player.velocity.y = i == 3 and -400 or player.velocity.y
			break
		end
	end
	
  grabber.origin.x, grabber.origin.y = VP.main:toWorld(x, y)
  mouse.x, mouse.y = VP.main:toCanvas(x, y)
  
  if not grabber:checkCollision(player).collide and mouse.x < VP.main.w and mouse.y < VP.main.h then
  	VP.main.query.offset = {move = true, x = {VP.main.ox, mouse.x + (VP.main.x + VP.main.ox)}, y = {VP.main.oy, mouse.y + (VP.main.y + VP.main.oy)}}
  end
  
  grabber.origin.x, grabber.origin.y = VP.ctrl:toWorld(x, y)
  mouse.x, mouse.y = VP.ctrl:toCanvas(x, y)
  
  for i = 1, 10 do
	  if grabber:checkCollision(VP.ctrl.ui.shape[i]).collide then VP.ctrl.query.button = i end
  end

  if VP.ctrl.query.button == 0 then
  	if grabber:checkCollision(VP.ctrl.ui.shape[11]).collide then
	    tick.active = not tick.active
	    VP.ctrl.ui:getShape(11).mode = tick.active and "fill" or "line"
  	elseif grabber:checkCollision(VP.ctrl.ui.shape[12]).collide then
   		VP.ctrl.ui.shape[12].mode = VP.ctrl.ui.shape[12].mode == "line" and "fill" or "line"
	  elseif x < VP.ctrl.x + VP.ctrl.w and y > VP.ctrl.y then
	 		VP.ctrl.query.offset = {move = true, VP.ctrl.oy, y}
	  end
	 elseif VP.ctrl.query.button == 9 then
	 	VP.ctrl.ui.shape[9].origin.x = 128 + 512
	 elseif VP.ctrl.query.button == 10 then
	 	VP.ctrl.ui.shape[10].origin.x = 128 + 512
	 end
  
  mouse.x, mouse.y = x, y
end

function love.touchmoved(id, x, y, dx, dy, pressure)
	local idx = tonumber(string.sub(tostring(id), 13)) or 0
	
	player.velocity.x = (VP.main.query.button == 1) and -400 or (VP.main.query.button == 2) and 400 or player.velocity.y
	
	mouse.x, mouse.y = VP.main:toCanvas(x, y)
	
	if VP.main.query.offset.move then
		VP.main.ox = math.floor(VP.main.query.offset.x[1] + ((mouse.x + VP.main.y + VP.main.ox) - VP.main.query.offset.x[2]) * 0.5)
		VP.main.oy = math.floor(VP.main.query.offset.y[1] + ((mouse.y + VP.main.y + VP.main.oy) - VP.main.query.offset.y[2]) * 0.5)
	end
  
  if VP.ctrl.query.button == 1 then
		player.origin.x, player.origin.y = VP.main:toWorld(x, y)
	elseif VP.ctrl.query.button == 2 then
		line.origin.x, line.origin.y = VP.main:toWorld(x, y)
	end
	
	local cso = function (shape) return VP.ctrl.ui.shape[shape].origin end
	
	mouse.x, mouse.y = VP.ctrl:toWorld(x, y)
	grabber.origin.x, grabber.origin.y = VP.main:toWorld(x, y)
  
  if VP.ctrl.query.button == 3 then
  	player.velocity.x, player.velocity.y = (grabber.origin.x - player.origin.x), (grabber.origin.y - player.origin.y)
  elseif VP.ctrl.query.button == 4 then
  	line.velocity.x, line.velocity.y = (grabber.origin.x - line.origin.x), (grabber.origin.y - line.origin.y)
  elseif VP.ctrl.query.button == 5 then
  	player.radius = math.abs(mouse.x - cso(5).x) * 0.5
  elseif VP.ctrl.query.button == 6 then
  	line.length = math.abs(mouse.x - cso(6).x) * 0.5
  elseif VP.ctrl.query.button == 7 then
    player.angle = math.rad(x - (VP.ctrl.x + VP.ctrl.ox + (128 + 1024 + 512))) * 0.5
  elseif VP.ctrl.query.button == 8 then
    line.angle = math.rad(x - (VP.ctrl.x + VP.ctrl.ox + (128 + 1024 + 512 + 256))) * 0.5
  elseif VP.ctrl.query.button == 9 then
  	player.torque = math.rad(mouse.x - (128 + 512))
  elseif VP.ctrl.query.button == 10 then
  	line.torque = math.rad(mouse.x - (128 + 512))
  elseif VP.ctrl.query.button == 0 and VP.ctrl.query.offset.move then
  	VP.ctrl.oy = VP.ctrl.query.offset[1] + (y - VP.ctrl.query.offset[2]) * 2
  	VP.ctrl.oy = VP.ctrl.oy > -256 * (#VP.ctrl.ui.shape / 2 - 1) + 256 and VP.ctrl.oy or -256 * (#VP.ctrl.ui.shape / 2 - 1) + 256
  	VP.ctrl.oy = VP.ctrl.oy < 0 and VP.ctrl.oy or 0
  	VP.ctrl.ui.shape[11].origin.y = -VP.ctrl.oy + 128
  	VP.ctrl.ui.shape[12].origin.y = -VP.ctrl.oy + 128
  end
  
  mouse.x, mouse.y = x, y
end

function love.touchreleased(id, x, y, dx, dy, pressure)
	local idx = tonumber(string.sub(tostring(id), 16)) or 0
	
	VP.main.query.button = 0
	VP.ctrl.query.button = 0
	
	VP.ctrl.ui.shape[9].origin.x = 128
	VP.ctrl.ui.shape[10].origin.x = 128 + 256
	
  VP.ctrl.query.offset = {move = false}
  VP.main.query.offset = {move = false}
  
  mouse.x, mouse.y = x, y
end

function update(delta)
	VP.dbg1.zoom = 1 + math.sin(tick.currentTime) * 0.5
	VP.dbg2.zoom = 1 + math.sin(tick.currentTime) * 0.5
  if tick.active then
    local next_time = tick.currentTime + delta
    
    if next_time > (tick.lastUpdate - tick.extraTime) + tick.length then
      local calc_count = math.ceil((next_time - tick.currentTime) / tick.length) + tick.extraUpdate
      
      for i = 1, calc_count do
        if tickUpdate(delta / calc_count) then
        	tick.frame = tick.frame + 1
        	tick.active = false
        	VP.ctrl.ui.shape[11].mode = "line"
        	VP.ctrl.ui.shape[12].mode = "line"
        	break
        end
        tick.frame = tick.frame + 1
      end
      
      tick.extraTime = math.mod(next_time, tick.length)
      tick.lastUpdate = next_time
    end

    tick.currentTime = next_time
  end
end

function tickUpdate(delta)
	local collision = player:checkCollision(line)
  if collision.collide then
  	if VP.ctrl.ui.shape[12].mode == "fill" then return true end
    player.velocity = collision.velocity
    player.torque = collision.torque
    player.time = 0
  end
  
  player.velocity.x = player.velocity.x - (player.velocity.x - player.velocity.x * 1)--player.vDamp)
  player.velocity.y = player.velocity.y + (((not collision.collide and 800 * delta or 0)))
  player.velocity.y = (player.velocity.y - (player.velocity.y - player.velocity.y * 1))--player.vDamp))
  
  player.origin.x = player.origin.x + player.velocity.x * delta
  player.origin.y = player.origin.y + player.velocity.y * delta
  
  player.torque = player.torque - (player.torque - player.torque * 1)--player.tDamp)
  player.angle = player.angle + player.torque * delta
  
  line.velocity.x = line.velocity.x - (line.velocity.x - line.velocity.x * line.vDamp)
  line.velocity.y = line.velocity.y - (line.velocity.y - line.velocity.y * line.vDamp)
  
  line.origin.x = line.origin.x + line.velocity.x * delta
  line.origin.y = line.origin.y + line.velocity.y * delta
  
  line.torque = line.torque - (line.torque - line.torque * line.tDamp)
  line.angle = line.angle + line.torque * delta
  
  player.time = player.time + delta
end

function draw()
	love.graphics.print(vec2.dot(vec2.fromAngle(line.angle + math.pi / 2), vec2.normalize(vec2(player:getCenter()) - vec2(line:getCenter()))), 640, 640)
	
	--VP.main.gui:draw()
	for i = 1, 3 do
		local s = VP.main.gui.shape[i]
		love.graphics.draw(img.arrow, s.origin.x, s.origin.y, s.angle, 0.5, 0.5, 96, 96)
	end
	
	--VP.main.ox, VP.main.oy = -player.origin.x + VP.main.w * 0.5, -player.origin.y + VP.main.h * 0.5
	
  VP.main:drawBegin()
  
  for i = 1,1 do
	  local l = vec2(player.origin * vec2(1, 1))
	  local a = vec2.fromAngle(line.angle, 512)
		vec2.mirror(l, -1, 1, line.angle)
		love.graphics.setColor(1, 1, 1, 0.8)
		love.graphics.line(player.origin.x, player.origin.y, l.x, l.y)
		--love.graphics.line(32, -128, l.x, -l.y)
		love.graphics.line(a.x, a.y, -a.x, -a.y)
		love.graphics.setColor(1, 1, 1, 1)
	end
  
  local wmouse = vec2(VP.main:toWorld(mouse.x, mouse.y))
  
  love.graphics.draw(img.whale, player.origin.x, player.origin.y, player.angle, player.radius / (174 * 0.5), (player.radius / (174 * 0.5)), 174 * 0.5, 174 * 0.5)
  
  love.graphics.print(string.format("(%d, %d)", -VP.main.ox, VP.main.oy), -VP.main.ox + VP.main.w * 0.5, -VP.main.oy + 16)
  love.graphics.line(-VP.main.ox, 0, -VP.main.ox + VP.main.w, 0)
  love.graphics.line(0, -VP.main.oy, 0, -VP.main.oy + VP.main.h)
  love.graphics.circle("line", wmouse.x, wmouse.y, 128)
	
  --player:draw()
  
  love.graphics.line(player.origin.x, player.origin.y, wmouse.x, wmouse.y)
  love.graphics.setColor(1, 1, 0, 0.85)
  love.graphics.line(player.origin.x, player.origin.y, player.origin.x + player.velocity.x, player.origin.y + player.velocity.y)
  love.graphics.setColor(1, 1, 1, 1)
  
  line:draw()
	
  VP.main:drawEnd()
  
  VP.ctrl:drawBegin()
  
  local cmouse = vec2(VP.ctrl:toWorld(mouse.x, mouse.y))
  local cso = function (shape) return VP.ctrl.ui.shape[shape].origin end
  
  love.graphics.circle("line", cmouse.x, cmouse.y, 96)
	
	love.graphics.setColor(1, 1, 0, 1)
	love.graphics.line(cso(3).x, cso(3).y, cso(3).x + (player.velocity.x * 0.35) / math.pi, cso(3).y + (player.velocity.y * 0.35) / math.pi)
	love.graphics.line(cso(4).x, cso(4).y, cso(4).x + (line.velocity.x * 0.35) / math.pi, cso(4).y + (line.velocity.y * 0.35) / math.pi)
	love.graphics.setColor(1, 1, 1, 1)
  
  love.graphics.circle("line", cso(5).x, cso(5).y, (player.radius * 0.35) / math.pi)
	love.graphics.circle("line", cso(6).x, cso(5).y, (line.length * 0.35) / math.pi)
  
  love.graphics.arc("line", cso(7).x, cso(7).y, 64, -math.pi / 2, math.mod(player.angle, math.pi * 2) - math.pi / 2)
	love.graphics.arc("line", cso(8).x, cso(8).y, 64, -math.pi / 2, math.mod(line.angle, math.pi * 2) - math.pi / 2)
	
	love.graphics.arc("line", cso(9).x, cso(9).y, 16 + (math.abs(player.torque) * 12) / math.pi, -math.pi / 2, math.mod(player.torque, math.pi * 2) - math.pi / 2)
	love.graphics.arc("line", cso(10).x, cso(10).y,  16 + (math.abs(line.torque) * 12) / math.pi, -math.pi / 2, math.mod(line.torque, math.pi * 2) - math.pi / 2)
  
  local color = {{0, 0, 1}, {1, 0, 0}, {1, 1, 1}}
  local color_idx = {1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 3, 3}
  for i, v in ipairs(VP.ctrl.ui.shape) do
  	love.graphics.setColor(color[color_idx[i]][1], color[color_idx[i]][2], color[color_idx[i]][3], 1)
  	local s = VP.ctrl.ui.shape[i]
  	love.graphics.circle(s.mode, s.origin.x, s.origin.y, s.radius)
  end
  love.graphics.setColor(1, 1, 1, 1)
  
  love.graphics.push()
  love.graphics.translate(128 + 512, 96)
  love.graphics.scale(3, 3)
  for i = 0, 4 do
	  love.graphics.print(i, 0, (256 / 3) * i)
	end
  love.graphics.pop()
  
  VP.ctrl:drawEnd()
  
  VP.dbg1:drawBegin()
  
  love.graphics.circle("line", mouse.x - VP.dbg1.x, mouse.y - VP.dbg1.y, 48)
  
  love.graphics.setColor(1, 1, 1, 0.6)
  love.graphics.line(240, 0, 240, 480)
  love.graphics.line(0, 240, 480, 240)
  love.graphics.setColor(1, 1, 1, 1)
  
  love.graphics.translate(240, 240)
  
  love.graphics.scale(VP.dbg1.zoom, VP.dbg1.zoom)
  
  player:debugCollision(line)
  
  VP.dbg1:drawEnd()
  
  VP.dbg2:drawBegin()
  
  love.graphics.circle("line", mouse.x - VP.dbg2.x, mouse.y - VP.dbg2.y, 64)
  
  love.graphics.setColor(1, 1, 1, 0.6)
  love.graphics.line(240, 0, 240, 480)
  love.graphics.line(0, 240, 480, 240)
  love.graphics.setColor(1, 1, 1, 1)
  
  love.graphics.translate(240, 240)
  
  love.graphics.scale(VP.dbg2.zoom, VP.dbg2.zoom)
  
  line:debugCollision(player)
  
  VP.dbg2:drawEnd()
  
  love.graphics.print(tick.frame .. "\n" .. tick.currentTime .. "\n" .. love.timer.getFPS(), 48, 96)
end