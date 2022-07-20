local inventoryUtils = require("inventoryUtils")

CreatePresserDepot = {}

function CreatePresserDepot:new (o, peripheral)
  o = o or {}
  setmetatable(o, self)
  self.__index = self

  self.peripheral = peripheral
  return o
end

function CreatePresserDepot:press (itemName, from, limit)
  return inventoryUtils.transfer(from, self, itemName, limit)
end

function CreatePresserDepot:clear (to)
  return inventoryUtils.transfer(self, to)
end

function CreatePresserDepot:waitForResult (itemName, amount, timeout)
  amount = amount or 1
  local timer = timeout or math.huge
  local done = false
  while not done do

    local resultItemCount = 0
    for slot,item in pairs(self.peripheral.list()) do
      if (item.name == (itemName or item.name)) then
        resultItemCount = resultItemCount + item.count
      end
    end
    done = resultItemCount >= amount
    
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