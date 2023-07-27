HOSTNAME = "craftyturtle"
MODEM = "top"

PROTOCOL = "mf-craftyturtle"

rednet.open(MODEM)
rednet.host(PROTOCOL, HOSTNAME)

while 1 do
  local originID, message = rednet.receive(PROTOCOL)

  load(message)()
  rednet.send(originID, "ready", PROTOCOL)
end