
local vec2 = math.vec2
local Shape = require("src.body.shape.shape")
local Line = Shape:extend()

function Line:new(x, y, l, a)
  Line.super.new(self, x, y)
  self.velocity = vec2(0, 0)
	self.vDamp = 0
  
  self.angle = a or 0
  self.torque = 0
  self.tDamp = 0
  
  self.length = l
  self.mass = 1
  
  self.time = 0
end

function Line:draw()
	love.graphics.push()
	love.graphics.translate(self.origin.x, self.origin.y)
	love.graphics.rotate(self.angle)
  love.graphics.line(-self.length * 0.5, 0, self.length * 0.5, 0)
  love.graphics.line(0, -4, 0, -12)
  love.graphics.pop()
end

function Line:checkCollision(shape)
  return shape:lineCollide(self)
end

function Line:pointCollide(point)
  return self.x == point.x and self.y == point.y
end

function Line:lineCollide(line)
	return false
end

function Line:circleCollide(circle)
  local a, b, c = {o = vec2(self:getCenter(true))}, {o = vec2(circle:getCenter(true))}, {collide = false, velocity = vec2(circle.velocity.x, circle.velocity.y), torque = circle.torque}
	
	a.b, b.a = b.o - a.o, a.o - b.o
	
	b.v = vec2(circle.velocity.x, -circle.velocity.y)
	vec2.rotate(b.v, self.angle)
	
	vec2.rotate(a.b, self.angle)
	
	c.collide = a.b.y < circle.radius --and a.b.y > 0
	if c.collide and b.v.y < 0 then
		b.v.y = -b.v.y
		local v = vec2(b.v.x, b.v.y - (a.b.y - circle.radius))
		c.torque = c.velocity.x * 0.01
		vec2.rotate(v, -self.angle)
		c.velocity.x, c.velocity.y = v.x * 1, -v.y*0-- * 0.95 -- surface drag
		
	end
	return c
end

function Line:debugCollision(shape)
	shape:debugLineCollide(self)
end

function Line:debugCircleCollide(circle)
	local a, b, c = {}, {}, {}
	
	c.st = false
	
	a.o, b.o = vec2(self:getCenter(true)), vec2(circle:getCenter(true))
	
	a.b, b.a = b.o - a.o, a.o - b.o
	
	b.v = vec2(circle.velocity.x, -circle.velocity.y)
	vec2.rotate(b.v, self.angle)
	
	vec2.rotate(a.b, self.angle)
	
	c.st = a.b.y < circle.radius and a.b.y > 0
	if c.st and b.v.y < 0 then
		b.v.y = -b.v.y
		local v = vec2(b.v.x, b.v.y + -(a.b.y - circle.radius))
		vec2.rotate(v, -self.angle)
		--circle.vx, circle.vy = v.x, -v.y * 0.996
	end
	
	love.graphics.circle(c.st and "fill" or "line", 0, 0, 8)
	love.graphics.line(-self.length * 0.5, 0, self.length * 0.5, 0)
	love.graphics.line(a.b.x, -a.b.y, a.b.x + b.v.x, -(a.b.y + b.v.y))
	love.graphics.circle("line", a.b.x, -a.b.y, circle.radius)
end

return Line