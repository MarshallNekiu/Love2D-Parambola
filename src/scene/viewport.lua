local Object = require("util.classic")
local Viewport = Object:extend()

function Viewport:new(x, y, w, h, ox, oy)
  self.x, self.y = x, y
  self.w, self.h = w, h
  self.ox, self.oy = ox or 0, oy or 0
  
  self.canvas = love.graphics.newCanvas(w, h)
end

function Viewport:toCanvas(x, y)
	return x - self.x, y - self.y
end

function Viewport:toWorld(x, y)
	return (x - self.x) - self.ox, (y - self.y) - self.oy
end

function Viewport:drawBegin()
  love.graphics.setCanvas(self.canvas)
  love.graphics.clear()
  love.graphics.rectangle("line", 0, 0, self.w, self.h)
  love.graphics.push()
  love.graphics.translate(self.ox, self.oy)
end

function Viewport:drawEnd()
  love.graphics.setCanvas()
  love.graphics.pop()
  love.graphics.draw(self.canvas, self.x, self.y)
end

return Viewport