require ("sensor")
require ("actor")
local mqtt = require("mqtt_library")
local TAM = 400
local s,a = 1,1
local startedge = {}

local actors = {}
local sensores = {}
  
local function mqttcb (msg)
  print(msg)
end

function love.load ()
  love.window.setMode(TAM,TAM)
  love.graphics.setBackgroundColor(0,0,0)
  --[[
  for i = 1, 2 do
    sensores[i] = Sensor.new(string.format("inf1350-obc-sensor-", i),i*TAM/3,TAM/2,TAM/8)
    sensores[i]:connect("broker.hivemq.com", 1883, "inf1350-obc-topic")
  end]]
end

function love.mousepressed (mx, my)
  for i = 1, #sensores do
      sensores[i]:keypressed(mx, my, "LC")
  end
end

function love.update(dt)
  for i = 1, #sensores do
    --print(i)
    sensores[i]:update(dt)
  end
  for i = 1, #actors do
    --print(i)
    actors[i]:update(dt)
  end
end

function love.draw ()
  for i = 1, #sensores do
    sensores[i]:draw()
  end
  for i = 1, #actors do
    actors[i]:draw()
  end
end

function love.keypressed(key, scancode, isrepeat)
  local x,y = love.mouse.getPosition()
  
  if key == "s" then
    print(s)
    local new = Sensor.new(string.format("inf1350-obc-sensor-%d", s),x,y,TAM/16)
    new:connect("broker.hivemq.com", 1883, "inf1350-obc-topic")
    table.insert(sensores,new)
    s = s + 1
  end
  
  if key == "a" then
    print(a)
    local new = Actor.new(string.format("inf1350-obc-actor-%d", a),x,y,TAM/16)
    new:connect("broker.hivemq.com", 1883, "inf1350-obc-topic")
    table.insert(actors,new)
    a = a + 1
  end
  
  if key == "c" then
    for i,elem in ipairs(sensores) do
      if elem:keypressed(x,y,"c") then
        startedge = elem:getxy()
      end
    end
    for i,elem in ipairs(actors) do
      if elem:keypressed(x,y,"c") then
        startedge = elem:getxy()
      end
    end
    
  end
end

function love.keyreleased(key, scancode)
  local x,y = love.mouse.getPosition()
  
  if key == "c" then
    for i,elem in ipairs(sensores) do
      if elem:keypressed(x,y,"c") then
        love.graphics.line(startedge[1],startedge[2],x,y)
      end
    end
    for i,elem in ipairs(actors) do
      if elem:keypressed(x,y,"c") then
        love.graphics.line(startedge[1],startedge[2],x,y)
      end
    end
    startedge = {}
  end
end
        

function love.quit()
  os.exit()
end
