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

  self.children = {}

  self.lastCId = 0

  self.buffer = {}
  self.bufferCId = -1
  self.bufferConfs = {}

  self.auxBuffer = {}
  self.auxBufferCId = -1
  self.auxBufferConfs = {}

  return self
end

function Actor.get_children(self)
  return self.children
end 

function Actor.get_id(self)
  return self.id
end

function Actor.get_xy(self)
  return {self.x,self.y}
end

local function table_contains (table, item)
  for i, elem in ipairs(table) do
    if elem == item then
      return true
    end
  end
  
  return false
end

local function find_leaves (children)
  local nextChildren = {}
  local newChild = false

  for i, c in ipairs(children) do
    childChildren = c:get_children()

    if #childChildren == 0 then
      table.insert(nextChildren, c)
    else
      for j, nc in ipairs(c:get_children()) do
        newChild = true
        table.insert(nextChildren, nc)
      end
    end
  end

  if not newChild then
    return children
  else
    return find_leaves(nextChildren)
  end
end

-- código adaptado do stackoverflow, postado pelo usuário quino0627
local function sort_buffer(buffer, le, ri)
  if ri - le < 1 then
    return buffer
  end

  local left = le
  local right = ri
  local pivot = math.floor((le + ri) / 2)

  buffer[pivot], buffer[right] = buffer[right], buffer[pivot]

  local rTimestamp, _ = string.match(buffer[right], "(.+);(.+)")
  local rTimestamp = tonumber(rTimestamp)

  for i = le, ri do
    local iTimestamp, _ = string.match(buffer[i], "(.+);(.+)")
    local iTimestamp = tonumber(iTimestamp)

    if iTimestamp < rTimestamp then
      buffer[left], buffer[i] = buffer[i], buffer[left]

      left = left + 1
    end
  end

  buffer[left], buffer[right] = buffer[right], buffer[left]

  sort_buffer(buffer, 1, left - 1)
  sort_buffer(buffer, left + 1, ri)

  return buffer
end

local function mqcb(self)
  return function (t, msg)
    local sender, dest, m, timestamp = string.match(msg, "(.+);(.+);(.+);(.+)") 

    -- Checa se eh o destinatario da mensagem
    if dest == self.id then
      local _, count = string.gsub(m, "(%w+)", "")

      if count == 2 then
        -- Se for uma confirmacao, adiciona ao contador da mensagem referente
        local cmd, cId = string.match(m, "(%w+) (%w+)")

        local cId = tonumber(cId)

        if cId == self.bufferCId then
          -- insere o remetente na tabela de confirmados
          table.insert(self.bufferConfs, sender)

          if #self.bufferConfs == #self.children then
            for i, bmsg in ipairs(self.buffer) do
              local mTimeStamp, mCmd = string.match(bmsg, "(.+);(.+)")
              self.mqtt_client:publish(self.topic, string.format("event %s", mCmd))
            end

            self.buffer = self.auxBuffer
            self.bufferCId = self.auxBufferCId
            self.bufferConfs = self.auxBufferConfs

            self.auxBuffer = {}
            self.auxBufferCId = -1
            self.auxBufferConfs = {}
          end

        elseif cId == self.auxBufferCId then
          -- insere o remetente na tabela de confirmados
          table.insert(self.auxBufferConfs, sender)
        else
          print("erro no cid", cId)
        end

      elseif count == 4 then
        -- Se nao, envia confirmacoes as folhas e adiciona nova mensagem no buffer
        local mId, cmd, x, y = string.match(m, "(%w+) (%w+) (%w+) (%w+)")

        local cId = self.lastCId -- garantir que o id vai ser manter ao longo da funcao

        if table_contains(self.bufferConfs, sender) then
          -- coloca no buffer auxiliar
          table.insert(self.auxBuffer, string.format("%s;%s %s %s", timestamp, cmd, x, y))
          
          if #self.auxBuffer == 1 then
            cId = cId + 1
            self.auxBufferCId = cId
            self.lastCId = self.auxBufferCId

        
            local leaves = find_leaves(self.children)

            for i, leaf in ipairs(leaves) do
              self.mqtt_client:publish(self.topic, 
                string.format("%s;%s;confirm %d;%d", self.id, leaf:get_id(), cId, os.time()))
            end
          else
            self.auxBuffer = sort_buffer(self.auxBuffer, 1, #self.auxBuffer)
          end
        else
          -- coloca no buffer normal
          table.insert(self.buffer, string.format("%s;%s %s %s", timestamp, cmd, x, y))
        
          if #self.buffer == 1 then
            cId = cId + 1
            self.bufferCId = cId
            self.lastCId = self.bufferCId

            local leaves = find_leaves(self.children)

            for i, leaf in ipairs(leaves) do
              self.mqtt_client:publish(self.topic, 
                string.format("%s;%s;confirm %d;%d", self.id, leaf:get_id(), cId, os.time()))
            end
          else
            self.buffer = sort_buffer(self.buffer, 1, #self.buffer)
          end
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
  table.insert(self.children, child)
end

function Actor.update(self, dt)
  if self.mqtt_client ~= nil then
    self.mqtt_client:handler()
  end
end

function Actor.keypressed(self, mx, my, key)
  if (math.sqrt((mx - self.x)^2 + (my - self.y)^2) < self.r) then
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

  love.graphics.setColor(1.0, 1.0, 1.0)
end