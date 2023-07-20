local inventoryUtils = require("utils.inventory")

local Factory = {
  machines = {}
}

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

-- each job: machineType, machineInputs, machineOptions
function Factory:scheduleJob (job)
  local tasks = {}

  for _,order in ipairs(job) do
    for _,task in ipairs(self:createTasks(order)) do
      table.insert(tasks, task)
    end
  end

  parallel.waitForAll(table.unpack(tasks))
end

function Factory:createTasks (order)
  local machineType, machineInputs, machineOptions = table.unpack(order)
  -- determine how many tasks needed to process the input
  -- and the input data/stats for each tasks
  local totalTasks = math.huge
  local inputStats = {}
  -- for input,maxInputSize in pairs(self.machines[machineType][1].inventory.maxInputSizes) do
  for input,itemStack in pairs(machineInputs) do
    local itemName, totalInputSize = table.unpack(itemStack)
    local maxInputSize = self.machines[machineType][1].inventory.maxInputSizes[input]

    local maxStackSize = math.min(maxInputSize, self:maxItemStackSize(itemName))
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

  return tasks
end

function Factory:runTask (machineType, machineInputs, machineOptions)
  machineOptions = machineOptions or {}
  -- wait until there's a machine available and for the inputs to be in storage
  local machine = self:getReadyMachine(machineType)
  local itemsAreAvailable = self:itemsAreAvailable(machineInputs)
  while machine == nil or not itemsAreAvailable do
    -- need to release mutex on the machine if this task doesn't have the crafting incredients
    -- so that other tasks can use it if they're good to go
    if machine then
      machine.ready = true
    end

    coroutine.yield()

    machine = self:getReadyMachine(machineType)
    itemsAreAvailable = self:itemsAreAvailable(machineInputs)
  end
  -- run the machine's run function
  machine:run(machineInputs, self.storage, machineOptions)
end

-- we need to actually have an item in storage to see it's max stack size
function Factory:maxItemStackSize (itemName)
  for slot,item in pairs(self.storage.inventory:list()) do
    if item.name == itemName then
      return self.storage.inventory:getItemDetail(slot).maxCount
    end
  end
end

---Get the first ready machine of the given type
---On success, the machine ready state is set to false in order to reserve it for
---the task that requested it
---@param machineType string Type of machine to get
---@return table? machine Matching machine if any are ready, otherwise nil
function Factory:getReadyMachine (machineType)
  for i,machine in ipairs(self.machines[machineType]) do
    if machine.ready then
      machine.ready = false
      return machine
    end
  end
  return nil
end

function Factory:itemsAreAvailable (machineInputs)
  for slot,itemStack in pairs(machineInputs) do
    local itemName, requestedItems = table.unpack(itemStack)
    local availableItems = inventoryUtils.numItemsInInventory(self.storage, itemName)
    if availableItems < requestedItems then
      return false
    end
  end
  return true
end

return { Factory = Factory }