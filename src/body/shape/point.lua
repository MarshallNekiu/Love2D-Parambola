
local Shape = require("src.body.shape.shape")
local Point = Shape:extend()

function Point:new(x, y)
  Point.super.new(self, x, y)
end

function Point:draw()
  love.graphics.points(self.x, self.y)
end

function Point:checkCollision(shape)
  return shape:pointCollide(self)
end

function Point:pointCollide(point)
  return self.x == point.x and self.y == point.y
end

function Point:circleCollide(circle)
  return math.sqrt((self.x - circle.x)^2 + (self.y - circle.y)^2) < circle.r
end

return Point