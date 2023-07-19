local function findFirst (driver, type)
  type = (type or driver.defaultPeripheralType)
  local first = peripheral.find(type)
  return driver:new(first)
end

local function waitUntilDone (machine, timeoutMs)
  local timeoutMs = timeoutMs or math.huge
  local start = os.epoch("utc")
  while os.epoch("utc") - start < timeoutMs do
    if machine:isDone() then
      return true
    end
  end
  return false
end

return {
  findFirst = findFirst,
  waitUntilDone = waitUntilDone
}