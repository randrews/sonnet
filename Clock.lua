-- A **Clock** takes a callback function and a delay time
-- and calls the function at that interval.

module(..., package.seeall)
local utils = require(_PACKAGE .. 'utils')
local List = require(_PACKAGE .. 'List')

local Clock = utils.public_class('Clock')

-- The list of all Clocks. Used by `Clock.all`
-- to update all active Clocks every frame.
-- This may be swapped out by Scene; Clocks are
-- local to the Scene they were declared in.

Clock.all = List()

-- ## Initialize
--
-- Constructor
--
-- - `delay` is the amount of time between calls
-- (and the amount of time before the first one)
--
-- - `callback` is the function to call.
--
-- - All other arguments are passed to the callback.

function Clock:initialize(delay, callback, ...)
   assert(delay > 0, "Delay must be greater than 0 seconds")
   assert(callback, "Clocks must have a callback, otherwise what's the point?")

   self.delay = delay
   self.callback = callback
   self.elapsed = 0
   self.args = {...}

   Clock.all:push(self)
end

-- ## Oneoff
--
-- Create a Clock that is called once and stops. This
-- essentially just calls the callback after the specified
-- delay.
--
-- Arguments are the same as the normal constructor.
--
-- Returns a Clock.

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

-- ## Update
--
-- Inform this Clock that time has passed; this may cause
-- it to call the callback.
--
-- You shouldn't call this manually, call the static
-- `Clock.update()` instead.

function Clock:update(dt)
   self.elapsed = self.elapsed + dt
   if self.elapsed >= self.delay then
      self.callback(unpack(self.args))
      self.elapsed = 0
   end
end

-- ## Stop
--
-- Stop this clock from running.

function Clock:stop()
    if not Clock.all:remove(self) then
        error("Clock not active!")
    end
end

-- ## Update
--
-- Updates all Clocks. This is called automatically by Scene
-- so you should only need to use it if you're not using Scenes.
--
-- - `dt` is the time delta for this frame.

function Clock.static.update(dt)
    Clock.all:method_each('update', dt)
end

return Clock