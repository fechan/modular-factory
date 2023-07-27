local Inventory = {
  slots = nil,
  maxInputSizes = nil
}

local function getMaxInputSizes (inputNames, slots)
  local maxInputSizes = {}
  for _,inputName in ipairs(inputNames) do
    local peripheral, realSlot = table.unpack(slots[inputName])
    maxInputSizes[inputName] = peripheral.getItemLimit(realSlot)
  end
  return maxInputSizes
end

---This manages peripheral-level inventory management methods
---for machines.
---@param inputNames    table   Array of names of input slots (as opposed to result slots)
---@param slots         table   Table that maps virtual slot names to {peripheral, realSlotNum}
---@param maxInputSizes table?  Table that maps virtual slot names to their max supported item count
---@return table o New instance of Machine
function Inventory:new (inputNames, slots, maxInputSizes)
  local o = {
    slots = slots,
    maxInputSizes = maxInputSizes or getMaxInputSizes(inputNames, slots)
  }

  setmetatable(o, self)
  self.__index = self

  return o
end

---List items in this machine's slots. Empty slots will not be included.
---Identical to [generic_peripheral/inventory.list()](https://tweaked.cc/generic_peripheral/inventory.html#v:list)
---except the keys are virtual slot names
---@return table list List of items in inventory
function Inventory:list ()
  local list = {}

  local periphListCache = {}
  for slotName,_ in pairs(self.slots) do
    -- turns out getItemDetail is really slow at scale
    -- so instead we look at each peripheral's list() and look up the item from there.
    -- The list() for each peripheral is cached in periphListCache
    -- so when there's another slot that references the same peripheral,
    -- we don't have to call list() on it again
    local periph, realSlot = table.unpack(self.slots[slotName])
    local periphList = periphListCache[peripheral.getName(periph)]
    if not periphList then
      periphList = periph.list()
      periphListCache[peripheral.getName(periph)] = periphList
    end

    local item = periphList[realSlot]

    if item then
      list[slotName] = item
    end
  end

  return list
end

---Get item details for the given slot
---Identical to [generic_peripheral/inventory.getItemDetail()](https://tweaked.cc/generic_peripheral/inventory.html#v:getItemDetail)
---except it takes a virtual slot name
---@param slot string Slot name
---@return table itemDetail Item details
function Inventory:getItemDetail (slot)
  local peripheral, realSlot = table.unpack(self.slots[slot])
  local item = peripheral.getItemDetail(realSlot)
  return item
end

---Push items to the given machine
---Identical to  [generic_peripheral/inventory.pushItems()](https://tweaked.cc/generic_peripheral/inventory.html#v:pushItems)
---except it operates on machines and takes virtual slot names
---@param toMachine table   Target machine
---@param fromSlot  string  Slot name of originating item stack
---@param limit     number? Optional upper bound for how many items to transfer
---@param toSlot    string? Optional destination slot name
---@return integer transferred Number of transferred items
function Inventory:pushItems(toMachine, fromSlot, limit, toSlot)
  local transferred = 0
  local fromPeriph, fromRealSlot = table.unpack(self.slots[fromSlot])
  local remaining = limit or fromPeriph.list()[fromRealSlot].count
  for toSlotName,toSlotInfo in pairs(toMachine.inventory.slots) do
    if toSlot == nil or toSlotName == toSlot then
      local toPeriph, toRealSlot = table.unpack(toSlotInfo)
      local toName = peripheral.getName(toPeriph)
      transferred = transferred + fromPeriph.pushItems(toName, fromRealSlot, remaining, toRealSlot)
      remaining = remaining - transferred
    end
  end
  return transferred
end

function Inventory:pullItems(fromMachine, fromSlot, limit, toSlot)
  local transferred = 0
  local fromPeriph, fromRealSlot = table.unpack(fromMachine.inventory.slots[fromSlot])
  local fromName = peripheral.getName(fromPeriph)
  local remaining = limit or fromPeriph.list()[fromRealSlot].count
  for toSlotName,toSlotInfo in pairs(self.slots) do
    if toSlot == nil or toSlotName == toSlot then
      local toPeriph, toRealSlot = table.unpack(toSlotInfo)
      transferred = transferred + toPeriph.pullItems(fromName, fromRealSlot, remaining, toRealSlot)
      remaining = remaining - transferred
    end
  end
  return transferred
end

return Inventory