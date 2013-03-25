module(..., package.seeall)
local utils = require(_PACKAGE .. 'utils')
local List = require(_PACKAGE .. 'List')

local Effect = utils.public_class('Effect')
Effect.all = List()

-- Effects
--
-- Effects are a level of abstraction higher than clocks / tweens. They
-- allow you to define an animated visual effect and display it on the
-- screen.
--
-- The typical way to use this is to subclass it and override draw(),
-- and possibly update(). You also need to call the Effect constructor.
-- You should override active() to return false when the effect is
-- finished and can be removed.

function Effect:initialize()
    Effect.all:push(self)
end

-- Override me
function Effect:draw() end
function Effect:update(dt) end
function Effect:active() return true end

function Effect.static.update(dt)
    Effect.all:method_each('update', dt)
    Effect.all = Effect.all:method_select('active')
end

function Effect.static.draw()
    Effect.all:method_each('draw')
end

return Effect