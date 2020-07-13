local mqtt = require("mqtt_library")
Actor = {}
Actor.__index = Actor

function Actor.new(cor, x, y, r)
  local self = setmetatable({}, Actor)

  self.cor = cor
  self.x = x
  self.y = y
  self.r = r

  self.mqtt_client = nil
  self.nChilds = 0
  self.leaves = {}

  return self
end

function Actor.set_cor(self,cor)
  self.cor = cor
end

function Actor.set_xyr(self,x,y,r)
  self.x = x
  self.y = y
  self.r = r
end

function Actor.get_cor(self)
  return self.cor
end

function Actor.get_x(self)
  return self.x
end

function Actor.get_y(self)
  return self.y
end

function Actor.get_r(self)
  return self.r
end

function Actor.get_client(self)
  return self.mqtt_client
end

local function mqcb(self)
  return function (msg)
    -- Checa se eh o destinatario da mensagem
      -- Se for uma confirmacao, adiciona ao contador da mensagem referente
      -- Se nao, envia confirmacoes as folhas e adiciona nova mensagem no buffer
  end
end

function Actor.connect(self, host, port, id, topic)
  self.mqtt_client = mqtt.client.create(broker, port, mqcb(self))
  self.mqtt_client:connect(id)
  self.mqtt_client:subscribe({topic})
end

function Actor.addChild(self)
  self.nChilds = self.nChilds + 1
end

function Actor.update(self, dt)
  self.mqtt_client:handler()
end

function Actor.draw(self)
  local l = self.r * math.sqrt(3)
  local h = self.r * 1.5

  love.graphics.setColor(self.cor[1], self.cor[2], self.cor[3])
  love.graphics.polygon("fill", self.x - l / 2, self.y + h / 3,
    self.x + l / 2, self.y + h / 3,
    self.x , self.y - 2 * h / 3)
end