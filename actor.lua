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
  self.topic = ""

  self.childs = {}

  self.lastCId = -1

  self.buffer = {}
  self.bufferCId = 0
  self.bufferConfs = {}

  self.auxBuffer = {}
  self.auxBufferCId = 0
  self.auxBufferConfs = {}

  return self
end

function Actor.get_childs(self) then
  return self.childs
end 

function Actor.get_id(self)
  return self.id
end

local function mqcb(self)
  return function (msg)
    sender, dest, m, timestamp = string.match(msg, "(.+);(.+);(.+)") 

    -- Checa se eh o destinatario da mensagem
    if dest == self.id then
      _, count = string.gsub(m, "(%w+)")

      if count == 2 then
        -- Se for uma confirmacao, adiciona ao contador da mensagem referente
        cmd, cId = string.match(m, "(%w+) (%w+)")

        if cId == bufferCId then
          -- insere o remetente na tabela de confirmados
          table.insert(bufferConfs, sender)

          if #bufferConfs == #childs then
            for i, bmsg in ipairs(buffer) do
              mqtt_client:publish(self.topic, string.format("event %s", bmsg))
            end

            self.buffer = {}
            self.bufferCId = 0
            self.bufferConfs = {}
          end

        elseif cId == auxBufferCId then
          -- insere o remetente na tabela de confirmados
          table.insert(auxBufferConfs, sender)

          -- checa para ver se as confirmacoes estão feitas
          if #auxBufConfs == #childs then
            for i, bmsg in ipairs(auxBuffer) do
                mqtt_client:publish(self.topic, string.format("event %s", bmsg))
            end

            self.auxBuffer = {}
            self.auxBufferCId = 0
            self.auxBufferConfs = {}
          end
        else
          print("erro no cid")
        end

      elseif count == 3 then
        -- Se nao, envia confirmacoes as folhas e adiciona nova mensagem no buffer

      else
        print("erro no count")
      end
    end
  end
end

function Actor.connect(self, host, port, topic)
  self.mqtt_client = mqtt.client.create(host, port, mqcb(self))
  self.mqtt_client:connect(self.id)
  self.mqtt_client:subscribe({topic})
  self.topic = topic
end

function Actor.addChild(self, child)
  table.insert(childs, child)
end

function Actor.update(self, dt)
  if mqtt_client ~= nil then
    self.mqtt_client:handler()
  end
end

function Actor.getxy(self)
  return {self.x,self.y}
end

function Actor.keypressed(self, mx, my, key)
  if (math.sqrt((mx - self.x)^2 + (my - self.y)^2) < self.r) then
    print("sensor clicado")
    
    if key == "LC" then
    end
  
    return true
  end

  return false
end

function Actor.draw(self)
  local l = self.r * math.sqrt(3)
  local h = self.r * 1.5

  love.graphics.setColor(self.color[1], self.color[2], self.color[3])
  love.graphics.polygon("fill", self.x - l / 2, self.y + h / 3,
    self.x + l / 2, self.y + h / 3,
    self.x , self.y - 2 * h / 3)
end