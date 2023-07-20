local factory = require("factory")

local SequencedAssembly = require("drivers.create.sequencedassembly")
local Chest = require("drivers.chest")

local myStorage = Chest:new(peripheral.wrap("minecraft:chest_0"))
local myFactory = Factory:new(myStorage)

local mySequencedAssembler = SequencedAssembly:new(
  peripheral.find("create:deployer"),
  peripheral.find("create:depot"),
  peripheral.wrap("minecraft:chest_2")
)
myFactory:addMachine(mySequencedAssembler)

myFactory:scheduleJob({
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