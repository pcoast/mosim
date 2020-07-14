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

function Actor.get_childs(self)
  return self.childs
end 

function Actor.get_id(self)
  return self.id
end

local function table_contains (table, item)
  for i, elem in ipairs(table) do
    if i == item then
      return true
    end
  end
  
  return false
end
local function get_leaves (childs)
  nextChilds = {}

  for i, c in ipairs(childs) do
    for j, nc in ipairs(c:get_childs()) do
      table.insert(nextChilds, nc)
    end
  end

  if nextChilds == {} then
    return childs
  else
    return get_leaves(nextChilds)
  end
end

local function mqcb(self)
  return function (msg)
    sender, dest, m, timestamp = string.match(msg, "(.+);(.+);(.+);(.+)") 

    -- Checa se eh o destinatario da mensagem
    if dest == self.id then
      _, count = string.gsub(m, "(%w+)")

      if count == 2 then
        -- Se for uma confirmacao, adiciona ao contador da mensagem referente
        cmd, cId = string.match(m, "(%w+) (%w+)")

        if cId == self.bufferCId then
          -- insere o remetente na tabela de confirmados
          table.insert(self.bufferConfs, sender)

          if #self.bufferConfs == #self.childs then
            for i, bmsg in ipairs(buffer) do
              mqtt_client:publish(self.topic, string.format("event %s", bmsg))
            end

            self.buffer = {}
            self.bufferCId = 0
            self.bufferConfs = {}
          end

        elseif cId == self.auxBufferCId then
          -- insere o remetente na tabela de confirmados
          table.insert(self.auxBufferConfs, sender)

          -- checa para ver se as confirmacoes estão feitas
          if #self.auxBufConfs == #self.childs then
            for i, bmsg in ipairs(self.auxBuffer) do
                mqtt_client:publish(self.topic, string.format("event %s", bmsg))
            end

            self.auxBuffer = {}
            self.auxBufferCId = 0
            self.auxBufferConfs = {}
          end
        else
          print("erro no cid")
        end

      elseif count == 4 then
        -- Se nao, envia confirmacoes as folhas e adiciona nova mensagem no buffer
        mId, cmd, x, y = string.match(m, "(%w+) (%w+) (%w+) (%w+)")

        self.lastCId = self.lastCId + 1

        local cId = self.lastCId -- garantir que o id vai ser manter ao longo da funcao

        if (table_contains(self.bufferConfs, sender)) then
          -- coloca no buffer auxiliar
          table.insert(self.auxBuffer, string.format("(%w+) (%w+) (%w+)", cmd, x, y))
        else
          -- coloca no buffer normal
          table.insert(self.buffer, string.format("(%w+) (%w+) (%w+)", cmd, x, y))
        end
        
        leaves = get_leves(self.childs)

        for i, leaf in ipairs(leaves) do
          self.mqtt_client:publish(self.topic, string.format("confirm %d", cId))
        end

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