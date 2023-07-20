local machineUtils = require("utils.machine")

local factory = require("factory")

local furnace = require("drivers.furnace")
local chest = require("drivers.chest")

local myStorage = chest.Chest:new(peripheral.wrap("minecraft:chest_0"))
local myFactory = factory.Factory:new(myStorage)

for i,furnacePeriph in ipairs({peripheral.find(furnace.Furnace.defaultPeripheralType)}) do
  local myFurnace = furnace.Furnace:new(furnacePeriph)
  myFactory:addMachine(myFurnace)
end

myFactory:scheduleJob({
  {
    "furnace",
    {
      top = {"minecraft:cobblestone", 2},
      fuel = {"minecraft:charcoal", 2}
    },
  },
  {
    "furnace", {
      top = {"minecraft:stone", 2},
      fuel = {"minecraft:charcoal", 2}
    }
  }
})

-- myFurnace:smelt({
--     top = {"minecraft:cobblestone", 2},
--     fuel = {"minecraft:charcoal", 64}
--   },
--   myStorage)