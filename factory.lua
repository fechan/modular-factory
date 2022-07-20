local furnaced = require("drivers.furnaceDriver")
local genericchestd = require("drivers.genericChestDriver")
local presserd = require("drivers.create.createPresserDepotDriver")
local machineUtils = require("machineUtils")

local myFurnace = machineUtils.findFirst(furnaced.Furnace, furnaced.typeName)
local myStorage = machineUtils.findFirst(genericchestd.GenericChest, "integrateddynamics:multipart_ticking")
local myPresser = machineUtils.findFirst(presserd.CreatePresserDepot, presserd.typeName)

myPresser:clear(myStorage)
myPresser:press("minecraft:iron_ingot", myStorage, 2)
myPresser:waitForResult("create:iron_sheet", 2)

-- myFurnace:clear(myStorage)
-- myFurnace:refuel("minecraft:charcoal", myStorage)
-- myFurnace:smelt("minecraft:cobblestone", myStorage)
-- myFurnace:waitForResult()
-- myFurnace:getResult(myStorage)