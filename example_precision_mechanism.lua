local Factory = require("factory")

local SequencedAssembly = require("drivers.create.sequencedassembly")
local Chest = require("drivers.chest")

local myStorage = Chest:new(peripheral.wrap("minecraft:chest_0"))
local myFactory = Factory:new(myStorage)

local mySequencedAssembler = SequencedAssembly:new(
  peripheral.wrap("create:deployer_0"),
  peripheral.wrap("create:depot_0"),
  peripheral.wrap("minecraft:chest_2")
)
myFactory:addMachine(mySequencedAssembler)

local mySequencedAssembler2 = SequencedAssembly:new(
  peripheral.wrap("create:deployer_1"),
  peripheral.wrap("create:depot_1"),
  peripheral.wrap("minecraft:chest_3")
)
myFactory:addMachine(mySequencedAssembler2)

myFactory:scheduleJob({
  {
    "sequencedassembly",
    {
      depot = {"create:golden_sheet", 1},
      [1] = {"create:cogwheel", 5},
      [2] = {"create:large_cogwheel", 5},
      [3] = {"minecraft:iron_nugget", 5},
    }
  },
  {
    "sequencedassembly",
    {
      depot = {"create:golden_sheet", 1},
      [1] = {"create:cogwheel", 5},
      [2] = {"create:large_cogwheel", 5},
      [3] = {"minecraft:iron_nugget", 5},
    }
  }
})