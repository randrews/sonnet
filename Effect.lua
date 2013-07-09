require('sonnet.table')
require('sonnet.middleclass')
local Promise = require('sonnet.Promise')

local Effect = class('Effect')
Effect.all = table()

--- Effects
---
--- Effects are a level of abstraction higher than clocks / tweens. They
--- allow you to define an animated visual effect and display it on the
--- screen.
---
--- The typical way to use this is to subclass it and override draw(),
--- and possibly update(). You also need to call the Effect constructor.
--- You should override active() to return false when the effect is
--- finished and can be removed.

function Effect:initialize()
    Effect.all:push(self)
end

--- Override me
function Effect:draw() end
function Effect:update(dt) end
function Effect:active() return true end

function Effect.static.update(dt)
    Effect.all:method_each('update', dt)

    local active_effects = table()
    for _, e in Effect.all:each() do
        if e:active() then
            active_effects:push(e)
        else
            if e._promise then e._promise:finish() end
        end
    end

    Effect.all = active_effects
end

function Effect.static.draw()
    Effect.all:method_each('draw')
end

function Effect:promise()
    if not self._promise then
        self._promise = Promise()
    end

    return self._promise
end

return Effect