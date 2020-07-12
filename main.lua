package.path = "home/miguel/inf1350/testee/"
local S = require ("sensor")
local mqtt = require("mqtt_library")
local TAM = 400
local cores = {}
cores[1] = {
  {1,0,0},
  {0.6, 0, 0}
}
cores[2] = {
  {0.5,1,0},
  {0.35,0.4,0.2}
}
local sensores = {}
  
local function mqttcb (msg)
  print(msg)
end

function love.load ()
  love.window.setMode(TAM,TAM)
  love.graphics.setBackgroundColor(0,0,0)

  for i = 1, 2 do
    sensores[i] = Sensor.new(cores[i][1],i*TAM/3,TAM/2,TAM/8)
    print((sensores[i]))
    print(sensores[i]:get_cor())
  end

  mqtt_client = mqtt.client.create("broker.hivemq.com", 1883, mqttcb)
  mqtt_client:connect("cliente love")
  mqtt_client:subscribe({"paralove"})
end

local function nosensor (sensor, mx, my)
  return math.sqrt((mx-sensor:get_x())^2 + (my-sensor:get_y())^2) < sensor:get_r()
end

local function mudaestado (i)
  if sensores[i]:get_cor() == cores[i][1] then
    sensores[i]:set_cor(cores[i][2])
  else
    sensores[i]:set_cor(cores[i][1])
  end
end

function love.mousepressed (mx, my)
  for i = 1, 2 do
    if nosensor (sensores[i], mx, my) then
      print ("no sensor ", i)
      if sensores[i]:get_cor() == cores[i][1] then
        mqtt_client:publish("paranode", "chegou")
      else
        mqtt_client:publish("paranode", "saiu")
      end
      mudaestado(i)
    end
  end
end

function love.update(dt)
  -- tem que chamar o handler aqui!
  mqtt_client:handler()
end

function love.draw ()
  
  for i = 1, 2 do
    love.graphics.setColor(((sensores[i]):get_cor())[1], ((sensores[i]):get_cor())[2], ((sensores[i]):get_cor())[3])
    love.graphics.circle ("fill", sensores[i]:get_x(), sensores[i]:get_y(), sensores[i]:get_r(), 64)
  end
end


function love.quit()
  os.exit()
end
