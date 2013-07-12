local Tween = require('sonnet.Tween')
local Effect = require('sonnet.Effect')

local Dim = sonnet.class('Dim', Effect)

function Dim:initialize(x, y, w, h)
    Effect.initialize(self)
    self.x = x or 0
    self.y = y or 0
    self.w = w
    self.h = h

    if not self.w or self.h then
        local ww, wh = love.graphics.getMode()
        self.w = self.w or ww
        self.h = self.h or wh
    end

    self.alpha = Tween(64, 0, 0.25)
end

function Dim:active()
    return self.alpha:alive()
end

function Dim:draw()
    local r, g, b, a = love.graphics.getColor()

    love.graphics.setColor(0, 0, 0, self.alpha.value)
    love.graphics.rectangle('fill', self.x, self.y, self.w, self.h)
    love.graphics.setColor(r, g, b, a)
end

function Dim.static.demoScene()
    local Scene = require(_SONNET .. 'Scene')
    local Demo = Scene:subclass('Demo')

    function Demo:initialize() love.graphics.setBackgroundColor(32, 140, 180) end
    function Demo:mousepressed(x, y)
        Dim(x-100, y-100, 200, 200)
    end

    return Demo()
end

return Dim