module(..., package.seeall)
local _SONNET = (...):match("(%w+)[.]")
local utils = require(_SONNET .. '.utils')
local Tween = require(_SONNET .. '.Tween')
local Effect = require(_SONNET .. '.Effect')

local Sparks = utils.submodule_class('effects', 'Sparks', Effect)

Sparks.image = nil

function Sparks:initialize(x, y, color1, color2)
    Effect.initialize(self)
    if not Sparks.image then
        Sparks.image = love.graphics.newImage(_SONNET .. '/images/particle.png')
    end

    self.particles = love.graphics.newParticleSystem(Sparks.image, 10)
    self.particles:setEmissionRate(100)

    self.color1 = color1 or {255, 255, 0}
    self.color2 = color2 or {255, 0, 0}

    self.particles:setColors(
        math.floor(color1[1]), math.floor(color1[2]), math.floor(color1[3]), 255, -- start
        math.floor(color2[1]), math.floor(color2[2]), math.floor(color2[3]), 0 -- end
    )

    self.particles:setGravity(600)
    self.particles:setParticleLife(0.5, 0.7)
    self.particles:setSpeed(200)
    self.particles:setSpread(math.pi * 2)

    if not self.dontstart then
        self.particles:start()
    end

    self.x = x
    self.y = y
end

function Sparks:active()
    if self.particles:count() == 0 then
        self.particles:stop()
        return false
    else
        return true
    end
end

function Sparks:update(dt)
    self.particles:update(dt)

    if self.particles:isFull() then
        self.particles:setEmissionRate(0)
    end
end

function Sparks:draw()
    love.graphics.draw(self.particles, self.x, self.y)
end

function Sparks.static.demoScene()
    local Scene = require(_SONNET .. '.Scene')
    local Demo = Scene:subclass('Demo')
    function Demo:mousepressed(x, y) Sparks(x, y) end
    return Demo()
end

return Sparks