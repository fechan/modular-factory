local RemoteInventory = require("remote_inventory")
local inventoryUtils = require("utils.inventory")

PROTOCOL = "mf-craftyturtle"
SERVER_HOSTNAME = "mf-server"

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
  clientID = nil,
}
CraftyTurtle.__index = CraftyTurtle

function CraftyTurtle:new (turtlePeriph, hostname, slots)
  peripheral.find("modem", rednet.open)
  rednet.unhost(PROTOCOL)
  local clientID = rednet.lookup(PROTOCOL, hostname)
  assert(clientID ~= nil, "Failed to connect to remote inventory client with hostname", hostname)
  rednet.host(PROTOCOL, SERVER_HOSTNAME)

  local defaultSlots = {}
  for virtSlot,realSlot in pairs(self.realSlotNums) do
    defaultSlots[virtSlot] = {turtlePeriph, realSlot}
  end
  
  local o = {
    inventory = RemoteInventory:new(clientID, self.inputNames, slots or defaultSlots),
    clientID = clientID,
  }
  setmetatable(o, self)

  return o
end

function CraftyTurtle:run (inputs, storage, options)
  self.ready = false
  self:clearInto(storage)
  
  for slotName,itemStack in pairs(inputs) do
    local itemName, itemCount = table.unpack(itemStack)
    inventoryUtils.transfer(storage, self, itemName, itemCount, slotName)
  end

  rednet.send(self.clientID, "craft", PROTOCOL)
  local id, rpcResponse, protocol
  repeat
    id, rpcResponse, protocol = rednet.receive(PROTOCOL)
  until id == self.clientID
  local success, failReason = table.unpack(textutils.unserialize(rpcResponse))

  self:clearInto(storage)
  self.ready = true
  return success
end

function CraftyTurtle:clearInto (storage)
  inventoryUtils.transfer(self, storage)
end

return CraftyTurtle