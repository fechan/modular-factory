-- optional: itemName (any), limit (inf), toSlot (any)
local function transfer (from, to, itemName, limit, toSlot)
  local toName = peripheral.getName(to.peripheral)
  local remaining = limit or math.huge
  local totalTransferred = 0
  for fromSlot,item in pairs(from.peripheral.list()) do
    if (item.name == (itemName or item.name)) and (remaining > 0) then
      local transferred
      if remaining == math.huge then
        transferred = from.peripheral.pushItems(toName, fromSlot, nil, toSlot)
      else
        transferred = from.peripheral.pushItems(toName, fromSlot, remaining, toSlot)
      end
      totalTransferred = totalTransferred + transferred
      remaining = remaining - transferred
    end
  end
  return totalTransferred
end

-- optional: limit (inf)
local function transferFromSlot (from, to, fromSlot, limit)
  local toName = peripheral.getName(to.peripheral)
  return from.peripheral.pushItems(toName, fromSlot, limit)
end

return {
  transfer = transfer,
  transferFromSlot = transferFromSlot
}