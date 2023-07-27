-- optional: itemName (any), limit (inf), toSlot (any)
local function transfer (from, to, itemName, limit, toSlot)
  local remaining = limit or math.huge
  local totalTransferred = 0
  for fromSlot,item in pairs(from.inventory:list()) do
    if (item.name == (itemName or item.name)) and (remaining > 0) then
      local transferred
      if remaining == math.huge then
        transferred = from.inventory:pushItems(to, fromSlot, nil, toSlot)
      else
        transferred = from.inventory:pushItems(to, fromSlot, remaining, toSlot)
      totalTransferred = totalTransferred + transferred
      remaining = remaining - transferred
    end
  end
  return totalTransferred
end

-- optional: limit (inf)
local function transferFromSlot (from, to, fromSlot, limit)
  return from.inventory:pushItems(to.inventory, fromSlot, limit)
end

local function numItemsInInventory (machine, itemName)
  local count = 0
  for slot,item in pairs(machine.inventory:list()) do
    if item.name == itemName then
      count = count + item.count
    end
  end
  return count
end

---Generate virtual slot mapping for a chest-like peripheral of any size,
---as well as an array of all the virtual slots
---@param periph table ComputerCraft wrapped peripheral of the chest
---@return table slots      Virtual slot mapping
---@return table inputNames Array of virtual slot names
local function generateChestVirtualSlots (periph)
  local slots = {}
  local inputNames = {}
  for i=1,periph.size() do
    slots[i] = {periph, i}
    table.insert(inputNames, i)
  end

  return slots, inputNames
end

return {
  transfer = transfer,
  transferFromSlot = transferFromSlot,
  numItemsInInventory = numItemsInInventory,
  generateChestVirtualSlots = generateChestVirtualSlots,
}