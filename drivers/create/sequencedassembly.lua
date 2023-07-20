local inventory = require("inventory")
local inventoryUtils = require("utils.inventory")
local machineUtils = require("utils.machine")

local SequencedAssembly = {
  type = "sequencedassembly",
  defaultPeripheralType = {"create:deployer", "create:depot", "minecraft:chest"},
  ready = true,
  realSlotNums = {
    deployer = 1,
    depot = 1,
  },
  inputNames = {"depot"},
  maxInputSizes = {
    depot = 1,
  },
  inventory = nil,
}
SequencedAssembly.__index = SequencedAssembly

function SequencedAssembly:new (deployerPeriph, depotPeriph, chestPeriph, slots)
  local defaultSlots = {
    deployer = {deployerPeriph, self.realSlotNums.deployer},
    depot = {depotPeriph, self.realSlotNums.depot},
  }
  local chestSlots, _ = inventoryUtils.generateChestVirtualSlots(chestPeriph)
  local inputNames = {self.inputNames[1]}
  local maxInputSizes = {depot = self.maxInputSizes["depot"]}
  for chestSlot,mapping in pairs(chestSlots) do
    defaultSlots[chestSlot] = mapping
    maxInputSizes[chestSlot] = 1
    table.insert(inputNames, chestSlot)
  end
  self.inputNames = inputNames
  self.maxInputSizes = maxInputSizes

  local o = {
    inventory = inventory.Inventory:new(inputNames, slots or defaultSlots, maxInputSizes)
  }
  setmetatable(o, self)

  return o
end

---Perform sequenced assmebly using items in storage
---@param inputs.deployer table   An array of items, ordered by when they should be deployed  TODO: fix me
---@param inputs.depot    table   Initial item to put in the depot
---@param storage         table   Machine used as storage
---@param options.repeat  number  Number of times to perform the sequence
---@return boolean false if there's a problem, true otherwise
function SequencedAssembly:run (inputs, storage, options)
  self.ready = false
  self:clearInto(storage)

  local depotItemName, depotItemCount = table.unpack(inputs.depot)
  self:emplaceDepot(depotItemName, storage)
  -- prep items in buffer chest
  local highestSlot = 1
  local repetitions = options["repeat"] or 1
  for i=1,repetitions do
    for destinationSlot,item in ipairs(inputs) do -- this only enumerates items bound for the buffer chest!!!
      local itemName, itemCount = table.unpack(item)
      inventoryUtils.transfer(storage, self, itemName, 1, destinationSlot)
      highestSlot = destinationSlot

      print("Moving item", itemName, "from storage to SA slot", destinationSlot)
    end
  end

  -- start assembly
  print("Now assembling with", highestSlot, "items to deploy")
  for i=1,repetitions do
    for fromBufferSlot=1,highestSlot do
      self:emplaceDeployer(fromBufferSlot)
      self:waitForDepotChange()
    end
  end

  self:clearInto(storage)
  self.ready = true
  return true
end

function SequencedAssembly:clearInto (to)
  return inventoryUtils.transfer(self, to)
end

function SequencedAssembly:emplaceDepot (itemName, from)
  return inventoryUtils.transfer(from, self, itemName, 1, "depot")
end

function SequencedAssembly:emplaceDeployer (fromBufferSlot)
  print("Putting item from SA slot", fromBufferSlot, "into deployer")
  return self.inventory:pushItems(self, fromBufferSlot, 1, "deployer")
end

function SequencedAssembly:waitForDepotChange ()
  local itemInit = self.inventory:getItemDetail("depot")
  local nameInit, countInit, nbtInit = itemInit.name, itemInit.count, itemInit.nbt

  local changed = false
  while not changed do
    local item = self.inventory:getItemDetail("depot")
    local name, count, nbt = item.name, item.count, item.nbt
    changed = name ~= nameInit or count ~= countInit or nbt ~= nbtInit
    os.sleep(0.05)
  end
end

return { SequencedAssembly = SequencedAssembly }