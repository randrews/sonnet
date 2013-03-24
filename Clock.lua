module(..., package.seeall)
local utils = require(_PACKAGE .. 'utils')
local List = require(_PACKAGE .. 'List')

local Clock = utils.public_class('Clock')

Clock.all = List()

function Clock:initialize(delay, callback, ...)
   assert(delay > 0, "Delay must be greater than 0 seconds")
   assert(callback, "Clocks must have a callback, otherwise what's the point?")

   self.delay = delay
   self.callback = callback
   self.elapsed = 0
   self.args = {...}

   Clock.all:push(self)
end

function Clock.static.oneoff(delay, callback, ...)
   assert(delay > 0, "Delay must be greater than 0 seconds")
   assert(callback, "Clocks must have a callback, otherwise what's the point?")

   local a = {...}
   local c
   c = Clock(delay, function()
                       callback(unpack(a))
                       c:stop()
                    end)

   return c
end

function Clock:update(dt)
   self.elapsed = self.elapsed + dt
   if self.elapsed >= self.delay then
      self.callback(unpack(self.args))
      self.elapsed = 0
   end
end

function Clock:stop()
    if not Clock.all:remove(n) then
        error("Clock not active!")
    end
end

function Clock.static.update(dt)
    Clock.all:method_each('update', dt)
end

return Clock