local Object = require("util.classic")
local Body = Object:extend()

function Body:new()
  self.shape = {}
end

function Body:draw()
  for i, v in ipairs(self.shape) do
    v:draw()
  end
end

function Body:addShape(new_shape)
  table.insert(self.shape, new_shape)
end

function Body:getShape(idx)
  return self.shape[idx]
end

return Body