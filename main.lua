require ("sensor")
require ("actor")
local mqtt = require("mqtt_library")
local TAM = 400
local s,a = 1,1

local startEdge = {}
local startNode = nil
  
local actors = {}
local sensores = {}
local lines = {}

function love.load ()
  love.window.setMode(TAM,TAM)
  love.graphics.setBackgroundColor(0,0,0)
end

function love.mousepressed (mx, my)
  for i = 1, #sensores do
      sensores[i]:keypressed(mx, my, "LC")
  end
end

function love.keypressed(key, scancode, isrepeat)
  local x,y = love.mouse.getPosition()
  
  if key == "s" then
    local new = Sensor.new(string.format("inf1350-obc-sensor-%d", s),x,y,TAM/16)
    new:connect("broker.hivemq.com", 1883, "inf1350-obc-topic")
    table.insert(sensores,new)
    s = s + 1
  end
  
  if key == "a" then
    local new = Actor.new(string.format("inf1350-obc-actor-%d", a),x,y,TAM/16)
    new:connect("broker.hivemq.com", 1883, "inf1350-obc-topic")
    table.insert(actors,new)
    a = a + 1
  end
  
  if key == "c" then
    for i,elem in ipairs(sensores) do
      if elem:keypressed(x,y,"c") then
        startNode = elem
        startEdge = elem:get_xy()
      end
    end
    -- for i,elem in ipairs(actors) do
    --   if elem:keypressed(x,y,"c") then
    --     startnode = elem
    --     startedge = elem:get_xy()
    --   end
    -- end
    
  end
end

function love.keyreleased(key, scancode)
  local x,y = love.mouse.getPosition()
  
  if key == "c" then
    for i,elem in ipairs(sensores) do
      if elem:keypressed(x,y,"c") and startEdge[1] ~= nil  then
        elem:addChild(startNode)
        startNode:set_parent(elem:get_id())
        love.graphics.setColor(255, 255, 255)
        table.insert(lines, { startEdge[1], startEdge[2], x, y })
      end
    end

    for i,elem in ipairs(actors) do
      if elem:keypressed(x,y,"c") and startEdge[1] ~= nil then
        elem:addChild(startNode)
        startNode:set_parent(elem:get_id())
        love.graphics.setColor(255, 255, 255)
        table.insert(lines, { startEdge[1], startEdge[2], x, y })
      end
    end

    startEdge = {}
    startNode = nil
  end
end

function love.update(dt)
  for i = 1, #sensores do
    sensores[i]:update(dt)
  end
  for i = 1, #actors do
    actors[i]:update(dt)
  end
end

function love.draw ()
  for i = 1, #lines do
    love.graphics.line(lines[i][1],lines[i][2],lines[i][3],lines[i][4])
  end
  for i = 1, #sensores do
    sensores[i]:draw()
  end
  for i = 1, #actors do
    actors[i]:draw()
  end
end
        
function love.quit()
  os.exit()
end
