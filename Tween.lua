require('sonnet.table')
require('sonnet.middleclass')
local Promise = require('sonnet.Promise')

local Tween = class('Tween')

Tween.static.all = table()

function Tween.static.update(dt)
   Tween.all:method_each('update', dt)
   Tween.static.all = Tween.all:method_select('alive')
end

function Tween:initialize(from, to, duration)
    self.finished = false
    self.value = from
    self.from = from
    self.to = to
    self.diff = self.to - self.from
    self.time = 0
    self.duration = duration or 1
    Tween.all:push(self)
end

function Tween.static.loop(step_duration, ...)
    local steps = {...}
    assert(#steps >= 2, 'A tween needs at least two steps')

    local step1, step2 = table.remove(steps, 1), table.remove(steps, 1)
    table.insert(steps, step1) ; table.insert(steps, step2)
    local t = Tween(step1, step2, step_duration)

    t.steps = steps
    return t
end

function Tween:stop()
    self.stopped = true
end

function Tween:alive()
    return not self.finished and not self.stopped
end

function Tween:update(dt)
    if self.finished then return end

    self.time = self.time + dt
    self.value = self.from + self.diff * self.time / self.duration

    if self.time >= self.duration then
        self.value = self.to

        if self.steps then -- restart, go to the next step
            self.from = self.to
            self.to = table.remove(self.steps, 1)
            table.insert(self.steps, self.to)
            self.time = 0
            self.diff = self.to - self.from

        else -- No steps, just end
            self.finished = true
            if self._promise then self._promise:finish(self) end
        end
    end
end

function Tween:promise()
    if not self._promise then
        self._promise = Promise()
    end
    return self._promise
end

function Tween.static.test()
    local t = Tween(0, 10, 5)
    assert(Tween.all:length() == 1)

    assert(t.value == 0)
    assert(t:alive())

    Tween.update(1)
    assert(t.value == 2)
    assert(t:alive())

    Tween.update(6)
    assert(t.value == 10)
    assert(not t:alive())
    assert(Tween.all:length() == 0)

    Tween.update(1)
    assert(t.value == 10)
end

return Tween