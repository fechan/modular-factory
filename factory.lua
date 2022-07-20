local furnaceDriver = require("furnaceDriver")
local genericChestDriver = require("genericChestDriver")

local myFurnace = nil
for _, furnace in pairs({peripheral.find("minecraft:furnace")}) do
  myFurnace = furnaceDriver.Furnace:new(nil, furnace)
  break
end

local myStorage = nil
for _, storage in pairs({peripheral.find("integrateddynamics:multipart_ticking")}) do
  myStorage = genericChestDriver.GenericChest:new(nil, storage)
  break
end

myFurnace:refuel("minecraft:charcoal", myStorage)
myFurnace:smelt("minecraft:cobblestone", myStorage)
myFurnace:waitForResult()
myFurnace:getResult(myStorage)