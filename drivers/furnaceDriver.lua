local inventoryUtils = require("inventoryUtils")

Furnace = {
  top_slot = 1,
  fuel_slot = 2,
  result_slot = 3
}

function Furnace:new (o, peripheral)
  o = o or {}
  setmetatable(o, self)
  self.__index = self

  self.peripheral = peripheral
  return o
end

function Furnace:refuel (itemName, from, limit)
  return inventoryUtils.transfer(from, self, itemName, limit, self.fuel_slot)
end

function Furnace:smelt (itemName, from, limit)
  return inventoryUtils.transfer(from, self, itemName, limit, self.top_slot)
end

function Furnace:getResult (to)
  return inventoryUtils.transferFromSlot(self, to, self.result_slot)
end

function Furnace:clear (to)
  return inventoryUtils.transfer(self, to)
end

-- optional: everything
function Furnace:waitForResult (itemName, amount, timeout)
  amount = amount or 1
  local timer = timeout or math.huge
  local done = false
  while not done do
    local result = self.peripheral.getItemDetail(self.result_slot)
    done = (result ~= nil) and (result.name == (itemName or result.name)) and (result.count >= amount)
    os.sleep(1)
    timer = timer - 1
    if timer == 0 then
      return false 
    end
  end
  return true
end

return {
  Furnace = Furnace,
  typeName = "minecraft:furnace"
}