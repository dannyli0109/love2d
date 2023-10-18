local InputSystem = {}
local config = require "config"
local love = require "love"

function InputSystem.update(dt, components)
    if components.Clickable then
        if (components.Visibility ~= nil and components.Visibility.visible == true) or (components.Visibility == nil) then
            local clickable = components.Clickable
            local mouseX, mouseY = love.mouse.getPosition()
            mouseX = mouseX - config.sceneOffset.x
            mouseY = mouseY - config.sceneOffset.y

            if clickable and clickable.active then
                local inside = mouseX > clickable.region.x - clickable.region.width / 2 and
                    mouseX < clickable.region.x + clickable.region.width / 2 and
                    mouseY > clickable.region.y - clickable.region.height / 2 and
                    mouseY < clickable.region.y + clickable.region.height / 2

                if inside then
                    -- When the mouse is pressed
                    if love.mouse.isDown(1) and inside and not clickable.mousePressedInside then
                        clickable.mousePressedInside = true
                    end

                    -- When the mouse is released
                    if clickable.mousePressedInside and not love.mouse.isDown(1) and inside then
                        clickable.callback()
                        clickable.mousePressedInside = false -- Reset the state
                    end

                    -- If the mouse is released outside of the clickable region
                    if clickable.mousePressedInside and not love.mouse.isDown(1) and not inside then
                        clickable.mousePressedInside = false -- Reset the state but don't call the callback
                    end
                else
                    clickable.mousePressedInside = false -- Reset the state but don't call the callback
                end
            end
        end
    end
end

return InputSystem
