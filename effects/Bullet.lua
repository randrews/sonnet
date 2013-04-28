module(..., package.seeall)
local _SONNET = (...):match("(%w+)[.]")
local utils = require(_SONNET .. '.utils')
local Point = require(_SONNET .. '.Point')
local Effect = require(_SONNET .. '.Effect')

local Bullet = utils.submodule_class('effects', 'Bullet', Effect)

function Bullet:initialize(from, to, color)
    Effect.initialize(self)

    self.start = from
    self.dir = math.atan2(to.y-from.y, to.x-from.x)
    self.dist = 0
    self.max_dist = to:dist(from)
    self.color = color or {255, 255, 255}    
end

function Bullet:active()
    return self.dist < self.max_dist
end

function Bullet:update(dt)
    self.dist = self.dist + 1000 * dt    
end

function Bullet:draw()
    local loc = self.start + Point(self.dist * math.cos(self.dir),
                                   self.dist * math.sin(self.dir))
    love.graphics.setColor(self.color)
    love.graphics.circle('fill', loc.x, loc.y, 3, 8)
end

function Bullet.static.demoScene()
    local Scene = require(_SONNET .. '.Scene')
    local Demo = Scene:subclass('Demo')
    local cx, cy = love.graphics.getMode()
    cx = cx/2 ; cy = cy / 2
    function Demo:mousepressed(x, y)
        Bullet(Point(x, y), Point(cx, cy))
    end
    return Demo()
end

return Bullet