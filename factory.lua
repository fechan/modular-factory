local inventoryUtils = require("utils.inventory")

local Factory = {}

function Factory:new (storage, machines)
  local o = {
    storage = storage,
    machines = machines
  }
  setmetatable(o, self)
  self.__index = self
  return o
end

function Factory:addMachine (machine)
  if self.machines[machine.type] == nil then
    self.machines[machine.type] = {}
  end
  table.insert(self.machines[machine.type], machine)
end

function Factory:scheduleJob (machineType, machineInputs, machineOptions)
  -- determine how many tasks needed to process the input
  -- and the input data/stats for each tasks
  local totalTasks = math.huge
  local inputStats = {}
  for input, maxInputSize in pairs(self.machines[machineType][1].maxInputSizes) do
    local itemName = machineInputs[input][1]
    local maxStackSize = math.min(maxInputSize, self:maxItemStackSize(itemName))

    local totalInputSize = math.min(machineInputs[input][2], inventoryUtils.numItemsInInventory(self.storage, itemName))
    local numMaxStacks = math.floor(totalInputSize / maxStackSize) -- number of stacks with the max number of items possible

    local remainderStackSize = math.fmod(totalInputSize, maxStackSize)
    local hasRemainderStack = remainderStackSize > 0

    local numStacks = numMaxStacks
    if hasRemainderStack then
      numStacks = numStacks + 1
    end

    if numMaxStacks < totalTasks then
      totalTasks = numStacks
    end

    inputStats[input] = {
      itemName = itemName,
      maxStackSize = maxStackSize,
      numMaxStacks = numMaxStacks,
      remainderStackSize = remainderStackSize
    }
  end

  -- generate tasks and run them based on above data
  local tasks = {}
  for taskNumber=1,totalTasks do
    local taskInputs = {}

    for input,stats in pairs(inputStats) do
      local itemCount = stats.maxStackSize
      if stats.numMaxStacks < taskNumber then
        itemCount = stats.remainderStackSize
      end

      taskInputs[input] = {stats.itemName, itemCount}
    end

    table.insert(tasks, function () self:runTask(machineType, taskInputs, machineOptions) end)
  end
  parallel.waitForAll(table.unpack(tasks))
end

function Factory:runTask (machineType, machineInputs, machineOptions)
  machineOptions = machineOptions or {}
  -- wait until there's a machine available
  local machine = self:getReadyMachine(machineType)
  while machine == nil do
    machine = self:getReadyMachine(machineType)
    coroutine.yield()
  end
  -- run the machine's run function
  machine:run(machineInputs, self.storage, machineOptions.timeout)
end

-- we need to actually have an item in storage to see it's max stack size
function Factory:maxItemStackSize(itemName)
  for slot,item in pairs(self.storage.peripheral.list()) do
    if item.name == itemName then
      return self.storage.peripheral.getItemDetail(slot).maxCount
    end
  end
end

function Factory:getReadyMachine(machineType)
  for i,machine in ipairs(self.machines[machineType]) do
    if machine.ready then
      machine.ready = false
      return machine
    end
  end
  return nil
end

return { Factory = Factory }