local love = require "love"
local config = require "config"

local imgui

if not config.build then
    imgui = require "cimgui" -- cimgui is the folder containing the Lua module (the "src" folder in the github repository)
end

local LogManager = {
    logs = {},
    limits = 100,
    dirty = false
}

function LogManager:draw()
    if not config.build then
        imgui.Begin("Log")
        for i = 1, #self.logs do
            imgui.Text(self.logs[i])
        end
        if self.dirty then
            imgui.SetScrollHereY(1.0)
            self.dirty = false
        end
        imgui.End()
    end
end

function LogManager:push(...)
    local args = { ... }
    local str = ""
    for i = 1, #args do
        str = str .. tostring(args[i]) .. " "
    end
    table.insert(self.logs, str)
    if #self.logs > self.limits then
        table.remove(self.logs, 1)
    end
    self.dirty = true
end

if not config.build then
    local original_print = _G.print

    _G.print = function(...)
        original_print(...)
        LogManager:push(...)
    end
end

return LogManager;
