local function findFirst(driver, type)
    local machine = nil
    -- this for loop is inelegant but I couldn't get it to work otherwise??
    for _, periph in pairs({peripheral.find(type)}) do
        machine = driver:new(nil, periph)
        break
    end
    return machine
end

return { findFirst = findFirst }