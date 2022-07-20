local function findFirst(driver, type)
    local first = peripheral.find(type)
    return driver:new(nil, first)
end

return { findFirst = findFirst }