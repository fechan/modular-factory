local furnaceDriver = require("drivers.furnaceDriver")
local genericChestDriver = require("drivers.genericChestDriver")
local createPresserDepotDriver = require("drivers.create.createPresserDepotDriver")

local myFurnace = nil
for _, furnace in pairs({peripheral.find(furnaceDriver.typeName)}) do
  myFurnace = furnaceDriver.Furnace:new(nil, furnace)
  break
end

local myStorage = nil
for _, storage in pairs({peripheral.find("integrateddynamics:multipart_ticking")}) do
  myStorage = genericChestDriver.GenericChest:new(nil, storage)
  break
end

local myPresser = nil
for _, depot in pairs({peripheral.find(createPresserDepotDriver.typeName)}) do
  myPresser = createPresserDepotDriver.CreatePresserDepot:new(nil, depot)
  break
end

myPresser:clear(myStorage)
myPresser:press("minecraft:iron_ingot", myStorage, 2)
myPresser:waitForResult("create:iron_sheet", 2)

-- myFurnace:clear(myStorage)
-- myFurnace:refuel("minecraft:charcoal", myStorage)
-- myFurnace:smelt("minecraft:cobblestone", myStorage)
-- myFurnace:waitForResult()
-- myFurnace:getResult(myStorage)