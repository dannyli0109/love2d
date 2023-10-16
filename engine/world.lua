local love = require "love"
local config = require "config"

local imgui
local ffi
local float

if not config.build then
    imgui = require "cimgui" -- cimgui is the folder containing the Lua module (the "src" folder in the github repository)
    ffi = require("ffi")
    -- Define a C-style float
    float = ffi.new("float[3]")
    -- Initial values
    float[0] = 0.0
    float[1] = 0.0
    float[2] = 0.0

    for k, v in pairs(imgui) do
        print(k, v)
    end
end

local world = {
    entities = {},
    components = {}
}

function world:addEntity(entity)
    self.entities[entity.guid] = entity
end

function world:addComponent(entity, component)
    if (not self.components[entity.guid]) then
        self.components[entity.guid] = {}
    end
    self.components[entity.guid][component.type] = component.data
end

function world:getComponent(entity, type)
    return self.components[entity.guid][type]
end

function world:update(dt)
    for guid, components in pairs(self.components) do
        if components.rigidBody then
            local rigidBody = components.rigidBody
            rigidBody.velocity.x = rigidBody.velocity.x + rigidBody.acceleration.x * dt
            rigidBody.velocity.y = rigidBody.velocity.y + rigidBody.acceleration.y * dt
            rigidBody.acceleration.x = 0
            rigidBody.acceleration.y = 0
        end

        if components.transform and components.rigidBody then
            local transform = components.transform
            local rigidBody = components.rigidBody
            transform.position.x = transform.position.x + rigidBody.velocity.x * dt
            transform.position.y = transform.position.y + rigidBody.velocity.y * dt
            transform.rotation = (transform.rotation + rigidBody.angularVelocity * dt) % 360
        end

        if components.Clickable then
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

function world:draw()
    for guid, components in pairs(self.components) do
        love.graphics.push()
        if components.transform then
            local data = components.transform
            local centerX = data.position.x
            local centerY = data.position.y
            love.graphics.translate(centerX, centerY)
            love.graphics.rotate(math.rad(data.rotation))
            love.graphics.rectangle("line", -data.size.w / 2, -data.size.h / 2, data.size.w, data.size.h)
        end

        if components.UIElement and components.transform then
            love.graphics.printf(components.UIElement.text, -components.transform.size.w / 2, -components.transform.size.h / 4, components.transform.size.w, "center")
        end
        
        if components.transform and components.sprite then
            local sprite = components.sprite
            local transform = components.transform
            love.graphics.draw(
                sprite.image, sprite.frames[sprite.currentFrame % #sprite.frames + 1], 
                -transform.size.w / 2 + (transform.size.w - sprite.frameWidth * sprite.renderScale) / 2,
                -transform.size.h / 2 + (transform.size.h - sprite.frameHeight * sprite.renderScale) / 2, 
                0, 
                sprite.renderScale,
                sprite.renderScale
            )
            sprite.currentTime = sprite.currentTime + love.timer.getDelta()
            if sprite.currentTime >= sprite.frameTime then
                sprite.currentTime = sprite.currentTime - sprite.frameTime
                sprite.currentFrame = (sprite.currentFrame + 1) % #sprite.frames
            end
        end
        love.graphics.pop()

        if components.Clickable then
            love.graphics.push()
            local data = components.Clickable
            local centerX = data.region.x
            local centerY = data.region.y
            love.graphics.translate(centerX, centerY)
            -- love.graphics.push();
            love.graphics.setColor(1, 0, 0, 1)
            love.graphics.rectangle("line", -data.region.width / 2, -data.region.height / 2, data.region.width, data.region.height)
            love.graphics.setColor(1, 1, 1, 1)
            -- love.graphics.pop();
            love.graphics.pop()
        end
    end
end

function drawField(label, field, properties)
    local functions = {
        "DragFloat", "DragFloat2", "DragFloat3", "DragFloat4"
    }
    local changed
    for i, property in ipairs(properties) do
        float[i - 1] = field[property];
    end
    changed = imgui[functions[#properties]](label, float)
    
    if changed then
        for i, property in ipairs(properties) do
            field[property] = float[i - 1];
        end
    end
end

function drawTransformGUI(transform, guid)
    local label = "Transform"
    if imgui.TreeNode_Str(label .. "##" .. guid) then
        drawField("position", transform.position, {"x", "y"})
        drawField("rotation", transform, {"rotation"})
        drawField("size", transform.size, {"w", "h"})
        imgui.TreePop()
    end
end

function drawRigidBodyGUI(rigidBody, guid)
    local label = "RigidBody"
    if imgui.TreeNode_Str(label .. "##" .. guid) then
        drawField("velocity", rigidBody.velocity, {"x", "y"})
        drawField("acceleration", rigidBody.acceleration, {"x", "y"})
        drawField("angularVelocity", rigidBody, {"angularVelocity"})
        imgui.TreePop()
    end
end

function drawSpriteGUI(sprite, guid)
    local label = "Sprite"
    if imgui.TreeNode_Str(label .. "##" .. guid) then
        drawField("frameTime", sprite, {"frameTime"})
        drawField("renderScale", sprite, {"renderScale"})
        imgui.TreePop()
    end
end

function drawClickableGUI(clickable, guid)
    local label = "Clickable"
    if imgui.TreeNode_Str(label .. "##" .. guid) then
        drawField("active", clickable, {"active"})
        drawField("region", clickable.region, {"x", "y", "width", "height"})
        imgui.TreePop()
    end
end

function world:drawGUI()
    imgui.Begin("Entities")
    for guid, entity in pairs(self.entities) do
        if imgui.TreeNode_Str(guid) then
            if self.components[guid].transform then
                drawTransformGUI(self.components[guid].transform, guid)
            end
            if self.components[guid].rigidBody then
                drawRigidBodyGUI(self.components[guid].rigidBody, guid)
            end
            if self.components[guid].sprite then
                drawSpriteGUI(self.components[guid].sprite, guid)
            end
            if self.components[guid].Clickable then
                drawClickableGUI(self.components[guid].Clickable, guid)
            end
            imgui.TreePop()
        end
    end

    local windowPosition = imgui.GetWindowPos()

    local windowSize = imgui.GetWindowSize()
    imgui.Text("Window Position: x=" .. windowPosition.x .. ", y=" .. windowPosition.y)
    imgui.Text("Window Size: width=" .. windowSize.x .. ", height=" .. windowSize.y)
    imgui.End()
end


return world