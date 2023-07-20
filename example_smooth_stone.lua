local Factory = require("factory")

local Furnace = require("drivers.furnace")
local Chest = require("drivers.chest")

local myStorage = Chest:new(peripheral.wrap("minecraft:chest_0"))
local myFactory = Factory:new(myStorage)

for i,furnacePeriph in ipairs({peripheral.find(Furnace.defaultPeripheralType)}) do
  local myFurnace = Furnace:new(furnacePeriph)
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