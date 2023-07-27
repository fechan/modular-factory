HOSTNAME = "craftyturtle"
SERVER_HOSTNAME = "mf-server"

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
    itemList[virtSlot] = turtle.getItemDetail(realSlot, false)
  end
  return itemList
end

local function craft ()
  local success, failReason = turtle.craft()
  return success, failReason
end

local function listen ()
  peripheral.find("modem", rednet.open)
  rednet.host(PROTOCOL, HOSTNAME)

  local serverID
  repeat
    serverID = rednet.lookup(PROTOCOL, SERVER_HOSTNAME)
  until serverID ~= nil
  print("Server found", serverID)

  while 1 do
    local originID, rpcRequest = rednet.receive(PROTOCOL)
    
    if originID == serverID then
      print("[RECV]", rpcRequest)

      local rpcResponse
      if rpcRequest == "list" then
        rpcResponse = textutils.serialize(table.pack(list()))
      elseif rpcRequest == "craft" then
        rpcResponse = textutils.serialize(table.pack(craft()))
      end

      rednet.send(originID, rpcResponse, PROTOCOL)
      print("[SEND]", rpcResponse)
    end  
  end
end

listen()