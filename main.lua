--Parámbola

function love.load()
	math.vec2 = require("util.math.vec2")
	
	math.snappedf = function (f, dec)
		local mult = 10 ^ dec
		return f >= 0 and math.floor(f * mult + 0.5) / mult or math.ceil(f * mult - 0.5) / mult
	end
	
	require("demo.clash.lc")
	load()
end

function love.update(delta)
	update(delta)
end

function love.draw()
	draw()
end