local Inventory = require("inventory")
local inventoryUtils = require("utils.inventory")
local machineUtils = require("utils.machine")

local Furnace = {
  type = "furnace",
  ready = true,
  defaultPeripheralType = "minecraft:furnace",
  realSlotNums = {
    top = 1,
    fuel = 2,
    result = 3
  },
  inputNames = {"top", "fuel"},
  inventory = nil
}
Furnace.__index = Furnace

function Furnace:new (periph, slots)
  local defaultSlots = {
    top = {periph, self.realSlotNums.top},
    fuel = {periph, self.realSlotNums.fuel},
    result = {periph, self.realSlotNums.result}
  }

  local o = {
    inventory = Inventory.Inventory:new(self.inputNames, slots or defaultSlots)
  }
  setmetatable(o, self)

  return o
end

---Smelt an item using items in storage
---@param inputs.top table Array containing {string name of item to smelt, number of item}
---@param inputs.fuel  table Array containing {string name of fuel item, number of item}
---@param storage table Machine used as storage
---@param options.timeout number Time in milliseconds to wait before timing out
---@return boolean false if timed out, true otherwise
function Furnace:run (inputs, storage, options)
  self.ready = false
  self:clearInto(storage)
  self:emplaceTop(inputs.top[1], storage, inputs.top[2])
  self:refuel(inputs.fuel[1], storage, inputs.fuel[2])
  local status = machineUtils.waitUntilDone(self, options.timeout)
  self:clearInto(storage)
  self.ready = true
  return status
end

function Furnace:emplaceTop (itemName, from, limit)
  return inventoryUtils.transfer(from, self, itemName, limit, "top")
end

function Furnace:refuel (itemName, from, limit)
  return inventoryUtils.transfer(from, self, itemName, limit, "fuel")
end

function Furnace:getResult (to)
  return inventoryUtils.transferFromSlot(self, to, "result")
end

function Furnace:clearInto (to)
  return inventoryUtils.transfer(self, to)
end

function Furnace:isDone ()
  return self.inventory:getItemDetail("top") == nil
end

return { Furnace = Furnace }