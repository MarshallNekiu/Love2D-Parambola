
local vec2 = math.vec2
local Shape = require("src.body.shape.shape")
local Circle = Shape:extend()

function Circle:new(x, y, r, a)
  Circle.super.new(self, x, y)
  self.velocity = vec2(0, 0)
  self.vDamp = 0
  
  self.angle = a or 0
  self.torque = 0
  self.tDamp = 0
  
  self.radius = r
  self.mass = 1
  
  --self.vPotential = 0
  --self.vPotentialMax = -1
  
  --self.tPotential = 0
  --self.tPotentialMax = -1
  
  self.bounce = 1
  
  self.time = 0 -- reset on collision
end

function Circle:draw(fill)
  love.graphics.circle(fill and "fill" or "line", self.origin.x, self.origin.y, self.radius)
  love.graphics.push()
	love.graphics.translate(self.origin.x, self.origin.y)
	love.graphics.rotate(self.angle)
	love.graphics.line(0, 0, 0, -self.radius)
	love.graphics.pop()
end

function Circle:drawLocal(fill)
  love.graphics.circle(fill and "fill" or "line", 0, 0, self.radius)
end

function Circle:checkCollision(shape)
  return shape:circleCollide(self)
end

function Circle:pointCollide(point)
  return {collide = math.sqrt((self.origin.x - point.origin.x)^2 + (self.origin.y - point.origin.y)^2) < self.radius}
end

function Circle:lineCollide(line)
	return false
end

function Circle:circleCollide(circle)
  return math.sqrt((self.x - circle.x)^2 + (self.y - circle.y)^2) < self.r + circle.r
end

function Circle:debugCollision(shape)
  shape:debugCircleCollide(self)
end

function Circle:debugLineCollide(line)
	love.graphics.circle("line", 0, 0, self.radius)
	
	local a, b = {}, {}
	
	a.o, b.o = vec2(self.origin.x, self.origin.y), vec2(line.origin.x, line.origin.y)
	
	a.b, b.a = b.o - a.o, a.o - b.o
	
	vec2.rotate(a.b, -self.angle)
	
	b.l = vec2.rotate(vec2(line.length, 0), self.angle - line.angle) * vec2(0.5, 0.5)
	
	love.graphics.line(a.b.x - b.l.x, -(-a.b.y - b.l.y), a.b.x + b.l.x, -(-a.b.y + b.l.y))
	
	love.graphics.push()
	love.graphics.translate(a.b.x, a.b.y)
	love.graphics.rotate(-self.angle + line.angle)
	love.graphics.line(0, -4, 0, -12)
	love.graphics.pop()
end

function Circle:debugCircleCollide(circle)
  love.graphics.circle("line", 0, 0, self.r)
  love.graphics.circle("line", circle.x - self.x, circle.y - self.y, circle.r)
  love.graphics.line(0, 0, circle.x - self.x, circle.y - self.y)
end
  
return Circle