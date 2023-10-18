local love = require "love"
local config = require "config"

local imgui
local ffi
local float

if not config.build then
    imgui = require "cimgui" -- cimgui is the folder containing the Lua module (the "src" folder in the github repository)
    ffi = require("ffi")
    -- Define a C-style float
    float = ffi.new("float[4]")
    -- Initial values
    float[0] = 0.0
    float[1] = 0.0
    float[2] = 0.0
    float[3] = 0.0

    for k, v in pairs(imgui) do
        print(k, v)
    end
end

local PhysicsSystem = require "system.physicsSystem"
local InputSystem = require "system.inputSystem"
local UIRenderSystem = require "system.uiRenderSystem"
local SpriteRenderSystem = require "system.spriteRenderSystem"

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
        PhysicsSystem.update(dt, components)
        InputSystem.update(dt, components)
    end
end

function world:draw()
    for guid, components in pairs(self.components) do
        local transfrom = components.transform
        local centerX = transfrom.position.x
        local centerY = transfrom.position.y
        love.graphics.push()
        love.graphics.translate(centerX, centerY)
        love.graphics.rotate(math.rad(transfrom.rotation))
        UIRenderSystem.update(components)
        SpriteRenderSystem.update(components)
        love.graphics.pop()
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
        drawField("position", transform.position, { "x", "y" })
        drawField("rotation", transform, { "rotation" })
        drawField("size", transform.size, { "w", "h" })
        imgui.TreePop()
    end
end

function drawRigidBodyGUI(rigidBody, guid)
    local label = "RigidBody"
    if imgui.TreeNode_Str(label .. "##" .. guid) then
        drawField("velocity", rigidBody.velocity, { "x", "y" })
        drawField("acceleration", rigidBody.acceleration, { "x", "y" })
        drawField("angularVelocity", rigidBody, { "angularVelocity" })
        imgui.TreePop()
    end
end

function drawSpriteGUI(sprite, guid)
    local label = "Sprite"
    if imgui.TreeNode_Str(label .. "##" .. guid) then
        drawField("frameTime", sprite, { "frameTime" })
        drawField("renderScale", sprite, { "renderScale" })
        imgui.TreePop()
    end
end

function drawClickableGUI(clickable, guid)
    local label = "Clickable"
    if imgui.TreeNode_Str(label .. "##" .. guid) then
        drawField("active", clickable, { "active" })
        drawField("region", clickable.region, { "x", "y", "width", "height" })
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
