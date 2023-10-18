local love = require "love"

local UIRenderSystem = {}

function rederButton(transfrom, uiElement) 
    if uiElement and transfrom then
        love.graphics.rectangle("line", -transfrom.size.w / 2, -transfrom.size.h / 2, transfrom.size.w, transfrom.size.h)
        love.graphics.printf(uiElement.text, -transfrom.size.w / 2,
            -transfrom.size.h / 4, transfrom.size.w, "center")
    end
end

function UIRenderSystem.update(components)
    local transform = components.transform
    local uiElement = components.UIElement
    local visible =  (components.Visibility ~= nil and components.Visibility.visible == true) or (components.Visibility == nil);

    if transform and uiElement and visible then
        if uiElement.type == "button" then
            rederButton(transform, uiElement)
        end
        -- You can add other UI element types like "label", "slider", etc.
    end
end

return UIRenderSystem