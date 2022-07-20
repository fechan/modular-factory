GenericChest = {}

function GenericChest:new (o, peripheral)
o = o or {}
setmetatable(o, self)
self.__index = self

self.peripheral = peripheral
return o
end

return {GenericChest = GenericChest}