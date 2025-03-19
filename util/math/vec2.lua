
local vec2 = {}

local newVectorMt = {
    __tostring = function(v) return "(" .. v.x .. ", " .. v.y ..")" end,
    __add = function(a, b) return vec2(a.x + b.x, a.y + b.y) end,
    __sub = function(a, b) return vec2(a.x - b.x, a.y - b.y) end,
    __mul = function(a, b) return vec2(a.x * b.x, a.y * b.y) end,
    __div = function(a, b) return vec2(a.x / b.x, a.y / b.y) end,
    __unm = function(v) return vec2(-v.x, -v.y) end,
    __eq = function(a, b) return a.x == b.x and a.y == b.y end,
    __concat = function(a, b) return tostring(a) .. tostring(b) end
}
local mt = {
    __call = function(_, x, y)
        local v = y and {x = x, y = y} or {x = x.x, y = x.y}
        setmetatable(v, newVectorMt)
        return v
    end
}
setmetatable(vec2, mt)

function vec2.fromAngle(angle, len) -- 0 -> (1, 0)
    len = len or 1
    return vec2(math.cos(angle) * len, math.sin(angle) * len)
end

function vec2.unpack(v)
	return v.x, v.y
end

function vec2.angle(v)
    return math.atan2(v.y, v.x)
end

function vec2.mirror(v, x, y, angle)
	vec2.rotate(v, -angle)
	v.x, v.y = v.x * x, v.y * y
	return vec2.rotate(v, angle)
end

function vec2.lengthSquared(v)
    return v.x^2 + v.y^2
end

function vec2.length(v)
    return vec2.lengthSquared(v)^0.5
end

function vec2.swap(v)
  v.x, v.y = v.y, v.x
  return v
end

function vec2.abs(v)
    v.x, v.y = math.abs(v.x), math.abs(v.y)
    return v
end

function vec2.sign(v)
  v.x, v.y = v.x >= 0 and 1 or -1, v.y >= 0 and 1 or -1
  return v
end

function vec2.normalize(v)
    local m = (v.x^2 + v.y^2)^0.5 --magnitude
    v.x, v.y = (v.x / m ~= v.x / m) and 0 or (v.x / m), (v.y / m ~= v.y / m) and 0 or (v.y / m)
    return v
end

function vec2.snappedf(v, dec)
    local mult = 10^dec
    v.x = v.x >= 0 and math.floor(v.x * mult + 0.5) / mult or math.ceil(v.x * mult - 0.5) / mult
    v.y = v.y >= 0 and math.floor(v.y * mult + 0.5) / mult or math.ceil(v.y * mult - 0.5) / mult
    return v
end

function vec2.rotate(v, phi)
    v.x, v.y = math.cos(phi) * v.x - math.sin(phi) * v.y, math.sin(phi) * v.x + math.cos(phi) * v.y
    return v
end

function vec2.translate(v, o)
	v.x, v.y = v.x + o.x, v.y + o.y
	end

function vec2.distanceSquaredTo(a, b)
    return (b.x - a.x)^2 + (b.y - a.y)^2
end

function vec2.distanceTo(a, b)
    return vec2.distanceSquaredTo(a, b)^0.5
end

function vec2.directionTo(a, b)
	return vec2.normalize(b - a)
end

function vec2.dot(a, b)
    return a.x * b.x + a.y * b.y
end

function vec2.perpDot(a, b)
    return a.x * b.x - a.y * b.y
end

function vec2.cross(a, b)
    return a.x * b.y - a.y * b.x
end

function vec2.lerp(a, b, w)
    local i = 1 - w
    a.x = a.x * i + b.x * w
    a.y = a.y * i + b.y * w
end

function vec2.clamp(v, a, b)
	v.x = v.x >= a.x and v.x <= b.x and v.x or b.x or a.x
	v.y = v.y >= a.y and v.y <= b.y and v.y or b.y or a.y
end

return vec2