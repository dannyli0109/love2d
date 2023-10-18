local love = require "love"
local SpriteRenderSystem = {}

function SpriteRenderSystem.update(components)
    local sprite = components.sprite
    local transform = components.transform
    if transform and sprite then
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
end

return SpriteRenderSystem