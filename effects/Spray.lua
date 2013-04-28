module(..., package.seeall)
local _SONNET = (...):match("(%w+)[.]")
local utils = require(_SONNET .. '.utils')
local Tween = require(_SONNET .. '.Tween')
local Clock = require(_SONNET .. '.Clock')
local Effect = require(_SONNET .. '.Effect')
local Sparks = require(_SONNET .. '.effects.Sparks')

local Spray = utils.submodule_class('effects', 'Spray', Sparks)

function Spray:initialize(x, y, dir, lifetime, speed, color)
    color = color or {255, 255, 255}
    lifetime = lifetime or 0.5
    speed = speed or 100
    self.dontstart = true

    Sparks.initialize(self, x, y, color, color)
    self.particles:setGravity(0)
    self.particles:setParticleLife(lifetime, lifetime)
    self.particles:setSpeed(speed)
    self.particles:setSpread(math.pi / 4)
    self.particles:setDirection(dir)

    self.particles:start()
end

function Spray.static.demoScene()
    local Scene = require(_SONNET .. '.Scene')
    local Demo = Scene:subclass('Demo')
    function Demo:mousepressed(x, y)
        Spray(x, y,
              math.random(360) / 180 * math.pi,
              0.25, 200)
    end
    return Demo()
end

return Spray