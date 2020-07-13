local mqtt = require("mqtt_library")
Actor = {}
Actor.__index = Actor

function Actor.new(id, x, y, r)
  local self = setmetatable({}, Actor)

  self.color = { 1.0, 1.0, 1.0}
  self.x = x
  self.y = y
  self.r = r
  
  self.id = id
  self.mqtt_client = nil
  self.nChilds = 0
  self.leaves = {}

  return self
end

function Actor.get_id(self)
  return self.id
end

local function mqcb(self)
  return function (msg)
    -- Checa se eh o destinatario da mensagem
      -- Se for uma confirmacao, adiciona ao contador da mensagem referente
      -- Se nao, envia confirmacoes as folhas e adiciona nova mensagem no buffer
  end
end

function Actor.connect(self, host, port,topic)
  self.mqtt_client = mqtt.client.create(host, port, mqcb(self))
  self.mqtt_client:connect(self.id)
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

  love.graphics.setColor(self.color[1], self.color[2], self.color[3])
  love.graphics.polygon("fill", self.x - l / 2, self.y + h / 3,
    self.x + l / 2, self.y + h / 3,
    self.x , self.y - 2 * h / 3)
end