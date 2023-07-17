local Inventory = require("inventory")

local Chest = {
  type = "chest",
  defaultPeripheralType = "minecraft:chest",
  inventory = nil
}
Chest.__index = Chest

function Chest:new (periph)
  local slots = {}
  local inputNames = {}
  for i=1,periph.size() do
    slots[i] = {periph, i}
    table.insert(inputNames, i)
  end

  local o = {
    peripheral = periph,
    inventory = Inventory.Inventory:new(inputNames, slots)
  }
  setmetatable(o, self)

  return o
end

return { Chest = Chest }