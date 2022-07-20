local inventoryUtils = require("inventoryUtils")

DEPOT_INPUT_SLOT = 1

CreatePresserDepot = {}

function CreatePresserDepot:new (o, peripheral)
  o = o or {}
  setmetatable(o, self)
  self.__index = self

  self.peripheral = peripheral
  return o
end

function CreatePresserDepot:press (itemName, from, limit)
  return inventoryUtils.transfer(from, self, itemName, limit, DEPOT_INPUT_SLOT)
end

function CreatePresserDepot:clear (to)
  return inventoryUtils.transfer(self, to)
end

function Furnace:waitForResult (itemName, amount, timeout)
  amount = amount or 1
  local timer = timeout or math.huge
  local done = false
  while not done do

    for slot,item in pairs(self.peripheral.list()) do
      if (item.name == (itemName or item.name)) and (item.count >= amount) then
        done = true
        break
      end
    end
    
    os.sleep(1)
    timer = timer - 1
    if timer == 0 then
      return false
    end
  end
end

return {
  CreatePresserDepot = CreatePresserDepot,
  typeName = "create:depot"
}