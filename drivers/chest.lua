local Chest = {
  type = "chest",
  defaultPeripheralType = "minecraft:chest"
}

function Chest:new (periph)
  local o = { peripheral = periph }
  setmetatable(o, self)
  self.__index = self
  return o
end

return { Chest = Chest }