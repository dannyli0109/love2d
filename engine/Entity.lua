local util = require "util"
local world = require "world"

local Entity = {
    guid = nil,
}

function Entity:new()
    local newObj = {}
    setmetatable(newObj, self)
    self.guid = util.generate_uuid(8)
    self.__index = self
    return newObj
end

function Entity:addComponent(component)
    world:addComponent(self, component)
end

return Entity