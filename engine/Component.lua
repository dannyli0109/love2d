local Component = {
    type = nil,
    data = nil
}

function Component:new(type, data)
    local newObj = {}
    setmetatable(newObj, self)
    self.type = type
    self.data = data
    self.__index = self
    return newObj
end

return Component