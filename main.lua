require ("sensor")
require ("actor")
local mqtt = require("mqtt_library")
local TAM = 400

local sensores = {}
  
local function mqttcb (msg)
  print(msg)
end

function love.load ()
  love.window.setMode(TAM,TAM)
  love.graphics.setBackgroundColor(0,0,0)

  for i = 1, 2 do
    sensores[i] = Sensor.new(string.format("inf1350-obc-sensor-", i),i*TAM/3,TAM/2,TAM/8)
    sensores[i]:connect("broker.hivemq.com", 1883, "inf1350-obc-topic")
  end
end

function love.mousepressed (mx, my)
  for i = 1, 2 do
      sensores[i]:mousepressed(mx, my)
  end
end

function love.update(dt)
  for i = 1, 2 do
    sensores[i]:update(dt)
  end
end

function love.draw ()
  for i = 1, 2 do
    sensores[i]:draw()
  end
end

function love.quit()
  os.exit()
end
