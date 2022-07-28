local machineUtils = require("utils.machine")

local factory = require("factory")

local furnace = require("drivers.furnace")
local chest = require("drivers.chest")

local myFurnace, myFurnace2 = peripheral.find(furnace.Furnace.defaultPeripheralType)
local myStorage = machineUtils.findFirst(chest.Chest)
local myFactory = factory.Factory:new(myStorage)

local furnace1 = furnace.Furnace:new(myFurnace)
local furnace2 = furnace.Furnace:new(myFurnace2)

myFactory:addMachine(furnace1)
myFactory:addMachine(furnace2)

myFactory:scheduleJob(
  "furnace", {
    top = {"minecraft:cobblestone", 129},
    fuel = {"minecraft:charcoal", 1000}
  }
)

-- myFurnace:smelt({
--     top = {"minecraft:cobblestone", 2},
--     fuel = {"minecraft:charcoal", 64}
--   },
--   myStorage)