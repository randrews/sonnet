local Tween = require('sonnet.Tween')
local Clock = require('sonnet.Clock')
local Effect = require('sonnet.Effect')
local Sparks = require('sonnet.effects.Sparks')

local Spray = sonnet.class('Spray', Sparks)

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