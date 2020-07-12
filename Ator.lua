local mqtt = require("mqtt_library")
Ator = {}
Ator.__index = Sensor

function Ator.new(cor, x, y, r)
  local self = setmetatable({}, Sensor)
  self.cor = cor
  self.x = x
  self.y = y
  self.r = r
  self.mqtt_client = None
  return self
end

function Ator.update(self)
  self.mqtt_client:handler()
end

function Ator.draw(self)
  love.graphics.setColor(((self):get_cor())[1], ((self):get_cor())[2], ((self):get_cor())[3])
    love.graphics.circle ("fill", self:get_x(), self:get_y(), self:get_r(), 64)
end

function Ator.connect(self,broker,num,callback,corretor,topico)
  self.mqtt_client = mqtt.client.create(broker, num, callback)
  self.mqtt_client:connect(corretor)
  self.mqtt_client:subscribe({topico})
end

function Ator.set_cor(self,cor)
  self.cor = cor
end

function Ator.set_xyr(self,x,y,r)
  self.x = x
  self.y = y
  self.r = r
end

function Ator.get_cor(self)
  return self.cor
end

function Ator.get_x(self)
  return self.x
end

function Ator.get_y(self)
  return self.y
end

function Ator.get_r(self)
  return self.r
end

function Ator.get_client(self)
  return self.mqtt_client
end