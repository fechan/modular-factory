local factory = require("factory")
local machineUtils = require("utils.machine")

local sa = require("drivers.create.sequencedassembly")
local chest = require("drivers.chest")

local myStorage = chest.Chest:new(peripheral.wrap("minecraft:chest_0"))
local myFactory = factory.Factory:new(myStorage)

local mySequencedAssembler = sa.SequencedAssembly:new(
  peripheral.find("create:deployer"),
  peripheral.find("create:depot"),
  peripheral.wrap("minecraft:chest_1")
)
myFactory:addMachine(mySequencedAssembler)

myFactory:scheduleJob({
  {
    "sequencedassembly",
    {
      depot = {"create:golden_sheet", 1},
      [1] = {"create:cogwheel", 1},
      [2] = {"create:large_cogwheel", 1},
      [3] = {"minecraft:iron_nugget", 1},
    },
    {
      ["repeat"] = 5
    }
  }
})