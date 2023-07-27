HOSTNAME = "craftyturtle"
SERVER_HOSTNAME = "server"
MODEM = "bottom"

PROTOCOL = "mf-craftyturtle"

REAL_SLOT_NUMS = {
  [1] = 1, -- top row
  [2] = 2,
  [3] = 3,
  [4] = 5, -- middle row
  [5] = 6,
  [6] = 7,
  [7] = 9, -- bottom row
  [8] = 10,
  [9] = 11,
}

local function list ()
  local itemList = {}
  for virtSlot,realSlot in pairs(REAL_SLOT_NUMS) do 
    itemList[virtSlot] = turtle.getItemDetail(realSlot)
  end
  return itemList
end

local function craft ()
  local success, failReason = turtle.craft()
  return success, failReason
end

local function listen ()
  rednet.open(MODEM)
  rednet.host(PROTOCOL, HOSTNAME)

  local serverID = rednet.lookup(PROTOCOL, SERVER_HOSTNAME)
  assert(serverID ~= nil, "Couldn't find factory server with hostname", SERVER_HOSTNAME)

  while 1 do
    local originID, rpcRequest = rednet.receive(PROTOCOL)
    
    if originID == serverID then
      local rpcResponse
      if rpcRequest == "list" then
        rpcResponse = textutils.serialize(table.pack(list()))
      elseif rpcRequest == "craft" then
        rpcResponse = textutils.serialize(table.pack(craft()))
      end

      rednet.send(originID, rpcResponse, PROTOCOL)
    end  
  end
end

listen()