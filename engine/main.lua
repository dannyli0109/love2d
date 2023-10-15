local program = require "program"
local love = require "love"

love.load = function()
    program.init()
end

love.draw = function()
    program.draw()
    program.drawGUI()
end

love.update = function(dt)
    program.update(dt)
end
