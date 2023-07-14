local inventoryUtils = require("utils.inventory")
local machineUtils = require("utils.machine")

local Furnace = {
  type = "furnace",
  defaultPeripheralType = "minecraft:furnace",
  ready = true,
  slots = {
    top = 1,
    fuel = 2,
    result = 3
  },
  maxInputSizes = {
    top = 64,
    fuel = 64
  }
}

function Furnace:new (periph, slots)
  local o = {
    peripheral = periph,
    slots = slots
  }
  setmetatable(o, self)
  self.__index = self

  return o
end

---Smelt an item using items in storage
---@param inputs.top table Array containing {string name of item to smelt, number of item}
---@param inputs.fuel  table Array containing {string name of fuel item, number of item}
---@param storage table Machine used as storage
---@param timeout number Time in milliseconds to wait before timing out
---@return boolean false if timed out
function Furnace:run (inputs, storage, timeout)
  self.ready = false
  self:clearInto(storage)
  self:emplaceTop(inputs.top[1], storage, inputs.top[2])
  self:refuel(inputs.fuel[1], storage, inputs.fuel[2])
  local status = machineUtils.waitUntilDone(self, timeout)
  self:clearInto(storage)
  self.ready = true
  return status
end

function Furnace:emplaceTop (itemName, from, limit)
  return inventoryUtils.transfer(from, self, itemName, limit, self.slots.top)
end

function Furnace:refuel (itemName, from, limit)
  return inventoryUtils.transfer(from, self, itemName, limit, self.slots.fuel)
end

function Furnace:getResult (to)
  return inventoryUtils.transferFromSlot(self, to, self.slots.result)
end

function Furnace:clearInto (to)
  return inventoryUtils.transfer(self, to)
end

function Furnace:isDone ()
  return self.peripheral.getItemDetail(self.slots.top) == nil
end

return { Furnace = Furnace }