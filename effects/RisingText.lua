module(..., package.seeall)
local _SONNET = (...):match("(%w+[.])")
local utils = require(_SONNET .. 'utils')
local Tween = require(_SONNET .. 'Tween')
local Effect = require(_SONNET .. 'Effect')

local RisingText = utils.public_class('RisingText', Effect)

function RisingText:initialize(x, y, text)
    Effect.initialize(self)
    self.x = x
    self.y = Tween(y, y - 40, 1)
    self.a = Tween(255, 0, 1)
    self.text = text
end

function RisingText:active()
    return self.y:alive()
end

function RisingText:draw()
    local r, g, b, a = love.graphics.getColor()

    love.graphics.setColor(r, g, b, self.a.value)
    love.graphics.printf(self.text,
                         self.x, self.y.value,
                         0, 'center')
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