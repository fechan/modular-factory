local Inventory = require("inventory")
local inventoryUtils = require("utils.inventory")

local Chest = {
  type = "chest",
  defaultPeripheralType = "minecraft:chest",
  inventory = nil
}
Chest.__index = Chest

function Chest:new (periph)
  local slots, inputNames = inventoryUtils.generateChestVirtualSlots(periph)

  local o = {
    peripheral = periph,
    inventory = Inventory:new(inputNames, slots)
  }
  setmetatable(o, self)

  return o
end

return { Chest = Chest }