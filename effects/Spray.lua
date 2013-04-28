module(..., package.seeall)
local _SONNET = (...):match("(%w+)[.]")
local utils = require(_SONNET .. '.utils')
local Tween = require(_SONNET .. '.Tween')
local Clock = require(_SONNET .. '.Clock')
local Effect = require(_SONNET .. '.Effect')
local Sparks = require(_SONNET .. '.effects.Sparks')

local Spray = utils.submodule_class('effects', 'Spray', Sparks)

function Spray:initialize(x, y, dir, range, color)
    color = color or {255, 255, 255}
    range = range or 100
    Sparks.initialize(self, x, y, color, color)

    self.particles:setGravity(0)
    self.particles:setParticleLife(range/1000, range/1000)
    self.particles:setSpeed(1000)
    self.particles:setSpread(math.pi / 32)
    self.particles:setDirection(dir)

    Clock.oneoff(0.5,
                 function() self.particles:setEmissionRate(0) end)
end

function Spray.static.demoScene()
    local Scene = require(_SONNET .. '.Scene')
    local Demo = Scene:subclass('Demo')
    function Demo:mousepressed(x, y)
        Spray(x, y,
              math.random(360) / 180 * math.pi,
              500)
    end
    return Demo()
end

return Spray