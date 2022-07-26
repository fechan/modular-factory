local machineUtils = require("utils.machine")

local factory = require("factory")

local furnace = require("drivers.furnace")
local chest = require("drivers.chest")

local myStorage = machineUtils.findFirst(chest.Chest)
local myFactory = factory.Factory:new(myStorage)

for i,furnacePeriph in ipairs({peripheral.find(furnace.Furnace.defaultPeripheralType)}) do
  local myFurnace = furnace.Furnace:new(furnacePeriph)
  myFactory:addMachine(myFurnace)
end

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