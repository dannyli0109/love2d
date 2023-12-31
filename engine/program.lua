local love = require "love"
local config = require "config"
local imguiRenderer
local canvas
local canvasWidth = 1200
local canvasHeight = 700
local imgui
local LogManager;

if (not config.build) then
    imguiRenderer = require "imguiRenderer"
    imgui = require "cimgui" -- cimgui is the folder containing the Lua module (the "src" folder in the github repository)
    LogManager = require "logManager"
    -- for k, v in pairs(imgui) do
    --     print(k, v)
    -- end
end

local Entity = require "Entity"
local Component = require "Component"
local world = require "world"
local UIFactory = require "uiFactory"

local program = {
}

function program.init()
    math.randomseed(os.time())
    canvas = love.graphics.newCanvas(canvasWidth, canvasHeight)
    if (not config.build) then
        imguiRenderer.init()
    end

    local images = {
        "assets/atk_64x64.png",
        "assets/idle_48x48.png",
    }

    local frameSize = {
        {
            w = 64,
            h = 64
        },
        {
            w = 48,
            h = 48
        }
    }

    for i = 1, 2 do
        local entity = Entity:new()
        local frameWidth = frameSize[i].w
        local frameHeight = frameSize[i].h
        entity:addComponent(Component:new("transform", {
            position = {
                x = i * 100 - frameWidth / 2, y = canvasHeight / 2
            },
            rotation = 0,
            size = {
                w = 100, h = 100
            }
        }))
        entity:addComponent(Component:new("rigidBody", {
            velocity = {
                x = 0, y = 0
            },
            acceleration = {
                x = 0, y = 0
            },
            angularVelocity = 0,
        }))
        local frames = {}

        local image = love.graphics.newImage(images[i])
        for y = 0, image:getHeight() - frameHeight, frameHeight do
            for x = 0, image:getWidth() - frameWidth, frameWidth do
                local quad = love.graphics.newQuad(x, y, frameWidth, frameHeight, image:getDimensions())
                table.insert(frames, quad)
            end
        end

        entity:addComponent(Component:new("sprite", {
            frames = frames,
            image = image,
            currentFrame = 0,
            frameTime = 0.1,
            currentTime = 0,
            frameWidth = frameWidth,
            frameHeight = frameHeight,
            renderScale = 1,
        }))

        entity:addComponent(Component:new("Visibility", {
            visible = true
        }))
        world:addEntity(entity)
    end

    local soundButton = UIFactory.createButton({
        position = {
            x = 100, y = 200
        },
        size = {
            w = 100, h = 30
        },
        text = "Sound",
        callback = function()
            print("clicked soundButton")
            -- Start the game or whatever action you want
        end,
        visible = false
    })
    world:addEntity(soundButton)


    local optionButton = UIFactory.createButton({
        position = {
            x = 100, y = 100
        },
        size = {
            w = 100, h = 30
        },
        text = "Options",
        callback = function()
            print("clicked optionButton")
            -- Start the game or whatever action you want
        end,
        submenu = {},
        visible = true
    })
    world:addEntity(optionButton)
end

function program.update(dt)
    world:update(dt)
    if (not config.build) then
        imguiRenderer.update(dt)
        world:drawGUI()
        imgui.Begin("ImGui Window")
        -- print(imgui.GetContentRegionAvail())
        local cursorScreenPos = imgui.GetCursorScreenPos()
        config.sceneOffset.x = cursorScreenPos.x
        config.sceneOffset.y = cursorScreenPos.y

        local windowSize = imgui.GetContentRegionAvail()
        if canvasWidth ~= windowSize.x or canvasHeight ~= windowSize.y then
            canvasWidth = windowSize.x
            canvasHeight = windowSize.y
        end
        if (canvasWidth == 0) then
            canvasWidth = 1
        end

        if (canvasHeight == 0) then
            canvasHeight = 1
        end
        canvas = love.graphics.newCanvas(canvasWidth, canvasHeight)
        imgui.Image(canvas, { canvasWidth, canvasHeight })
        -- print()
        imgui.End()

        LogManager:draw()
    end
end

function program.draw()
    love.graphics.setCanvas(canvas)
    love.graphics.clear()
    world:draw()
    love.graphics.setCanvas()
    if (config.build) then
        love.graphics.draw(canvas)
    end
end

function program.drawGUI()
    if (not config.build) then
        imguiRenderer.draw()
    end
end

return program
