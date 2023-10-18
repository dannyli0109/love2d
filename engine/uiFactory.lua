local Entity = require "Entity"
local Component = require "Component"

local UIFactory = {}


function UIFactory.createButton(params)
    local entity = Entity:new()

    local position = params.position or { x = 0, y = 0 }
    local size = params.size or { w = 100, h = 30 }
    local text = params.text or "Button"
    local callback = params.callback or function() end
    local visible = params.visible
    local submenu = params.submenu or {}

    entity:addComponent(Component:new("transform", {
        position = position,
        rotation = 0,
        size = size
    }))

    entity:addComponent(Component:new("UIElement", {
        type = "button",
        text = text,
        state = "normal",
        submenu = submenu
    }))

    entity:addComponent(Component:new("Clickable", {
        region = {
            x = position.x, y = position.y, width = size.w, height = size.h
        },
        callback = callback,
        active = true,
        mousePressedInside = false
    }))

    entity:addComponent(Component:new("Visibility", {
        visible = visible
    }))
    return entity
end

return UIFactory
