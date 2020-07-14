local mqtt = require("mqtt_library")
Sensor = {}
Sensor.__index = Sensor

function Sensor.new(id, x, y, r)
  local self = setmetatable({}, Sensor)

  self.color = { 1.0, 1.0, 1.0 }
  self.x = x
  self.y = y
  self.r = r
  self.id = id

  self.mqtt_client = nil
  self.topic = ""

  self.parent = nil
  self.children = {}
  self.confirms = {}
  self.state = true --false quando detectou um objeto e ele n saiu do range do sensor 

  return self
end

function Sensor.get_id(self)
  return self.id
end

function Sensor.get_xy(self)
  return {self.x,self.y}
end

function Sensor.get_children(self)
  return self.children
end

function Sensor.set_parent(self, parent)
  self.parent = parent
end

function mqcb(self)
  return function (topic, msg)
    sender, dest, m, timestamp = string.match(msg, "(.+);(.+);(.+);(.+)")

    -- Checa se eh o destinatario da mensagem
    if dest == self.id then
      _, count = string.gsub(m, "(%w+)", "")
      
      if count == 2 then
        local cmd, cId = string.match(m, "(%w+) (%w+)")
        local cId = tonumber(cId)


      end
      -- Repassa ela ao longo da rede
      self.mqtt_client:publish(self.topic, string.format("%s;%s;%s;%d",self.id,self.parent,m,timestamp))
    end
  end
end

function Sensor.connect(self, host, port, topic)
  self.mqtt_client = mqtt.client.create(host, port, mqcb(self))
  self.mqtt_client:connect(self.id)
  self.mqtt_client:subscribe({topic})
  self.topic = topic
end

function Sensor.addChild(self, child)
  table.insert(self.children, child)
end

function Sensor.keypressed(self, mx, my, key)
  if (math.sqrt((mx - self.x)^2 + (my - self.y)^2) < self.r) then
    if key == "LC" then
      if self.state then
        self.mqtt_client:publish(self.topic,
          string.format("%s;%s;mid detect %d %d;%d",self.id,self.parent,mx,my,os.time()))
        self.state = false
        self.color = {0.0,1.0,0.0}
      else
        self.mqtt_client:publish(self.topic,
          string.format("%s;%s;mid loss %d %d;%d",self.id,self.parent,mx,my,os.time()))
        self.state = true
        self.color = {1.0,1.0,1.0}
      end
    end
  
    return true
  end

  return false
end

function Sensor.update(self, dt)
  if self.mqtt_client ~= nil then
    self.mqtt_client:handler()
  end
end

function Sensor.draw(self)
  local l = self.r * math.sqrt(3)
  local h = self.r * 1.5

  love.graphics.setColor(self.color[1], self.color[2], self.color[3])
  love.graphics.circle ("fill", self.x, self.y, self.r, 64)

  love.graphics.setColor(1.0, 1.0, 1.0)
end