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
  self.parent = nil
  self.nChilds = 0
  self.childs = nil
  self.state = true --false quando detectou um objeto e ele n saiu do range do sensor 
  print(id)

  return self
end

function Sensor.get_id(self)
  return self.id
end

function mqcb(self)
  return function (msg)
    sender, dest, m, timestamp = string.match(msg, "")
  end
end

function Sensor.connect(self, host, port, topic)
  self.mqtt_client = mqtt.client.create(host, port, mqcb(self))
  self.mqtt_client:connect(self.id)
  self.mqtt_client:subscribe({topic})
  print("connected")
end

function Sensor.addChild(self)
  self.nChilds = self.nChilds + 1
end

function Sensor.keypressed(self, mx, my, key)
  if (math.sqrt((mx - self.x)^2 + (my - self.y)^2) < self.r) then
    print("sensor clicado")
    
    if key == "LC" then
      if self.state then
        self.mqtt_client:publish("inf1350-obc-topic", string.format("%s;%s;mid detect %f %f;%f",self.id,self.parent,mx,my,os.time()))
        self.state = false
        self.color = {1.0,3.0,3.0}
      else
        self.mqtt_client:publish("inf1350-obc-topic", string.format("%s;%s;mid loss %f %f;%f",self.id,self.parent,mx,my,os.time()))
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

function Sensor.getxy(self)
  return {self.x,self.y}
end

function Sensor.draw(self)
  local l = self.r * math.sqrt(3)
  local h = self.r * 1.5

  love.graphics.setColor(self.color[1], self.color[2], self.color[3])
  love.graphics.circle ("fill", self.x, self.y, self.r, 64)
end