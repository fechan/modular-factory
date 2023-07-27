PROTOCOL = "mf-craftyturtle"

local RemoteInventory = {
  remote = true,
  slots = nil,
  maxInputSizes = nil,
  clientID = nil,
}

local function getMaxInputSizes (inputNames, slots)
  local maxInputSizes = {}
  for _,inputName in ipairs(inputNames) do
    maxInputSizes[inputName] = 64
  end
  return maxInputSizes
end

---This manages the inventory for machines that do not have their own peripheral-level
---inventory management methods (e.g. pushItems), but are able to use rednet to report
---their own inventory state.
---
---In other words, this is an Inventory class for CC Turtles.
---@param clientID      integer ID of client running craftyturtle.lua
---@param inputNames    table   Array of names of input slots (as opposed to result slots)
---@param slots         table   Table that maps virtual slot names to {peripheral, realSlotNum}
---@param maxInputSizes table?  Table that maps virtual slot names to their max supported item count
---@return table o New instance of Machine
function RemoteInventory:new (clientID, inputNames, slots, maxInputSizes)
  local o = {
    slots = slots,
    maxInputSizes = maxInputSizes or getMaxInputSizes(inputNames, slots),
    clientID = clientID,
  }

  setmetatable(o, self)
  self.__index = self

  return o
end

---List items in this machine's slots. Empty slots will not be included.
---Identical to [generic_peripheral/inventory.list()](https://tweaked.cc/generic_peripheral/inventory.html#v:list)
---except the keys are virtual slot names
---@return table list List of items in inventory
function RemoteInventory:list ()
  rednet.send(self.clientID, "list", PROTOCOL)
  local id, rpcResponse, protocol
  repeat
    id, rpcResponse, protocol = rednet.receive(PROTOCOL)
  until id == self.clientID

  local list = table.unpack(textutils.unserialize(rpcResponse))
  return list
end

---Push items to the given machine
---Identical to  [generic_peripheral/inventory.pushItems()](https://tweaked.cc/generic_peripheral/inventory.html#v:pushItems)
---except it operates on machines and takes virtual slot names
---@param toMachine table   Target machine
---@param fromSlot  string  Slot name of originating item stack
---@param limit     number? Optional upper bound for how many items to transfer
---@param toSlot    string? Optional destination slot name
---@return integer transferred Number of transferred items
function RemoteInventory:pushItems(toMachine, fromSlot, limit, toSlot)
  assert(toMachine.inventory.remote or false, "Cannot pushItems from a RemoteInventory to another RemoteInventory")

  return toMachine.inventory:pullItems({inventory = self}, fromSlot, limit, toSlot)
end

function RemoteInventory:pullItems(fromMachine, fromSlot, limit, toSlot)
  assert(toMachine.inventory.remote or false, "Cannot pullItems from a RemoteInventory to another RemoteInventory")

  return fromMachine.inventory:pushItems({inventory = self}, fromSlot, limit, toSlot)
end

return RemoteInventory