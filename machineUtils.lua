local function findFirst(driver, type)
    type = (type or driver.typeName)
    local first = peripheral.find(type)
    return driver:new(nil, first)
end

return { findFirst = findFirst() }