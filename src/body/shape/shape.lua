
local vec2 = math.vec2
local Object = require("util.classic")
local Shape = Object:extend()

function Shape:new(x, y) self.origin = vec2(x, y) end

function Shape:setOrigin(x, y) self.origin.x, self.origin.y = x, y end

function Shape:draw() end

function Shape:drawLocal() end

function Shape:getCenter(inv_y) return self.origin.x, inv_y and -self.origin.y or self.origin.y end

function Shape:checkCollision(shape) return false end

function Shape:pointCollide(point) return false end

function Shape:lineCollide(line) return false end

function Shape:circleCollide(circle) return false end

function Shape:debugCollision(shape) end

function Shape:debugPointCollide(point) end

function Shape:debugLineCollide(line) end

function Shape:debugCircleCollide(circle) end

return Shape