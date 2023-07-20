local inventory = require("inventory")
local inventoryUtils = require("utils.inventory")

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

---Initialize a new Sequenced Assembly machine from Create using a Deployer, a Depot, and a
---buffer chest that stores crafting ingredients that will be fed into the deployer.
---
---The chest can be anywhere on the network, but the Deployer must be above the Depot
---(just like if you were to use a Deployer-Depot combo manually)
---@param deployerPeriph  table   ComputerCraft wrapped peripheral of the deployer
---@param depotPeriph     table   ComputerCraft wrapper peripheral of the depot
---@param chestPeriph     table   ComputerCraft wrapper peripheral of the chest
---@param slots           table?  Table mapping virtual slot names to the corresponding {peripheral, realSlot} pair. Leave nil for default mapping.
---@return table o SequencedAssembly machine
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
    maxInputSizes[chestSlot] = 64
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

---Perform sequenced assembly using items in storage
---
---The number of repetitions of the sequence required is inferred from the size of the first item stack.
---The number of inputs declared must be enough for the entire sequence.
---@param inputs          table   An array of items to be inserted into the Deployer in order, plus a "depot" key for the item to put in the Depot.
---@param storage         table   Machine used as storage
---@return boolean false if there's a problem, true otherwise
function SequencedAssembly:run (inputs, storage, options)
  self.ready = false
  self:clearInto(storage)

  local depotItemName, depotItemCount = table.unpack(inputs.depot)
  self:emplaceDepot(depotItemName, storage)

  -- prep deployer items in buffer chest
  local highestSlot = 1
  local repetitions = inputs[1][2] -- infer the number of repetitions from the size of the first item stack bound for the deployer
  for destinationSlot,item in ipairs(inputs) do -- this only enumerates items bound for the buffer chest!!!
    local itemName, itemCount = table.unpack(item)
    inventoryUtils.transfer(storage, self, itemName, itemCount, destinationSlot)
    highestSlot = destinationSlot
  end

  -- start assembly
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