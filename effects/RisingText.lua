local Tween = require('sonnet.Tween')
local Effect = require('sonnet.Effect')

local RisingText = sonnet.class('RisingText', Effect)

function RisingText:initialize(x, y, text, color)
    Effect.initialize(self)
    self.x = x
    self.y = Tween(y, y - 40, 1)
    self.a = Tween(255, 0, 1)
    self.text = text
    self.color = color or {255, 255, 255}
end

function RisingText:active()
    return self.y:alive()
end

function RisingText:draw()
    local r, g, b, a = love.graphics.getColor()

    love.graphics.setColor(self.color[1], self.color[2], self.color[3], self.a.value)
    love.graphics.printf(self.text,
                         self.x-500, self.y.value,
                         1000, 'center')
    love.graphics.setColor(r, g, b, a)
end

function RisingText.static.demoScene()
    local Scene = require(_SONNET .. 'Scene')
    local Demo = Scene:subclass('Demo')

    function Demo:initialize() self.n = 1 end
    function Demo:mousepressed(x, y)
        RisingText(x, y, self.n)
        self.n = self.n + 1
    end

    return Demo()
end

return RisingText