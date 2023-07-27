local Inventory = require("inventory")
local inventoryUtils = require("utils.inventory")

local CraftyTurtle = {
  type = "craftyturtle",
  ready = true,
  defaultPeripheralType = "computercraft:turtle_normal",
  realSlotNums = {
    [1] = 1, -- top row
    [2] = 2,
    [3] = 3,
    [4] = 5, -- middle row
    [5] = 6,
    [6] = 7,
    [7] = 9, -- bottom row
    [8] = 10,
    [9] = 11,
  },
  inputNames = {1, 2, 3, 4, 5, 6, 7, 8, 9},
  inventory = nil,
}
CraftyTurtle.__index = CraftyTurtle

function CraftyTurtle:new (periph, slots)
  local defaultSlots = {}
  for virtSlot,realSlot in pairs(realSlotNums) do
    defaultSlots[virtSlot] = {periph, realSlot}
  end
  
  local o = {
    inventory = Inventory:new(self.inputNames, slots or defaultSlots)
  }
  setmetatable(o, self)

  return o
end

function CraftyTurtle:run (inputs, storage, options)
  self.ready = false
  self:clearInto(storage)
  
  for slotName,itemStack in pairs(inputs) do
    local itemName, itemCount = table.unpack(itemStack)
    inventoryUtils.transfer(storage, self, itemName, itemCount)
  end
end

function CraftyTurtle:clearInto (storage)
end