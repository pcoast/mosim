Sensor = {}
Sensor.__index = Sensor

function Sensor.new(cor, x, y, r)
  local self = setmetatable({}, Sensor)
  self.cor = cor
  self.x = x
  self.y = y
  self.r = r
  return self
end

function Sensor.set_cor(self,cor)
  self.cor = cor
end

function Sensor.set_xyr(self,x,y,r)
  self.x = x
  self.y = y
  self.r = r
end

function Sensor.get_cor(self)
  return self.cor
end

function Sensor.get_x(self)
  return self.x
end

function Sensor.get_y(self)
  return self.y
end

function Sensor.get_r(self)
  return self.r
end
