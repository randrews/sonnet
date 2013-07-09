--- **Scenes** are an abstraction of the Love callbacks: they
--- encapsulate drawing, update, and input functions into
--- one object. You can define multiple scenes and install
--- them one at a time, through the scene stack.

require('sonnet.table')
require('sonnet.middleclass')
local Clock = require('sonnet.Clock')
local Tween = require('sonnet.Tween')
local Effect = require('sonnet.Effect')

local Scene = class('Scene')

--- ## The Scene stack:
---
--- Scene manages a stack of scenes. Each scene is a set
--- of love event handlers (draw, update, etc) as well as
--- Tween / Clock / Messenger / Effect global lists. You
--- can push and pop on the Scene stack, which is the
--- standard method of changing scenes.
---
--- ### Scene lifecycle:
---
---     scene1 = MyScene()  -- calls your constructor
---     scene2 = MyOtherScene()  -- calls your constructor
---     Scene.push(scene1)  -- scene1:on_install
---     Scene.push(scene2)  -- scene1:on_pause, scene2:on_install
---     Scene.pop() -- scene2:on_exit, scene1:on_resume, scene1:on_install
---     Scene.pop()  -- scene1:on_exit
---
--- ### Event handler sequence:
---
--- - constructor
--- - on_install
--- - on_pause
--- - on_resume
--- - on_install
--- - on_exit
---
--- (pause, resume, and install may be called several times, the rest only once)
Scene.stack = {}

--- ## Scene.push
--- Push a scene on to the stack, pausing any scene that's already there.
---
--- - `scene` - The scene to push

function Scene.static.push(scene)
    local stk = Scene.stack
    if #stk > 0 then
        stk[#stk]:pause()
    end

    table.insert(stk, scene)
    scene:install()
end

--- ## Scene.pop
--- Pops the current scene off the stack, which calls its `on_exit` handler
--- and resumes the scene below it (if any).

function Scene.static.pop()
    local stk = Scene.stack
    if #stk == 0 then error("Scene stack underflow") end
    local curr = stk[#stk]
    curr:on_exit()
    table.remove(stk)

    if #stk > 0 then
        stk[#stk]:resume()
        stk[#stk]:install()
    end
end

--- ## Event handler methods
--- Scenes should override these
function Scene:on_install() end
function Scene:on_pause() end
function Scene:on_resume() end
function Scene:on_exit() end
function Scene:update(dt) end
function Scene:draw() end
function Scene:keypressed(key, unicode) end
function Scene:keyreleased(key) end
function Scene:mousepressed(x, y, button) end

--- ## Scene:install
--- Installs this scene as the current scene (the one that
--- is being drawn and updated, taking input, etc). You
--- should probably not call this; use `Scene.push()` instead.

function Scene:install()
    assert(love)

    self:on_install()
    love.update = function(dt) self:update_with_sonnet(dt) end
    love.draw = function() self:draw_with_sonnet() end
    love.keypressed = function(k, u) self:keypressed(k, u) end
    love.keyreleased = function(k) self:keyreleased(k) end
    love.mousepressed = function(x, y, b) self:mousepressed(x, y, b) end
end

----------------------------------------

--- ## Internal stuff

--- ## `update_with_sonnet`
--- Scenes automatically call all Sonnet things (Clock, Tween, etc)
--- with their updates.

function Scene:update_with_sonnet(dt)
    Clock.update(dt)
    Tween.update(dt)
    Effect.update(dt)
    self:update(dt)
end

--- ## `draw_with_sonnet`
--- Scenes automatically draw Sonnet effects, you don't have to call Effect.draw by hand.

function Scene:draw_with_sonnet(dt)
    self:draw()
    Effect.draw()
end

--- ## `pause`
--- When paused, scenes keep a copy of all global Sonnet
--- stuff (Effect, Tween, etc), so the next scene has a clean slate

function Scene:pause()
    self:on_pause()

    self.clocks = Clock.all
    self.tweens = Tween.all
    self.effects = Effect.all
    Clock.all = table()
    Tween.all = table()
    Effect.all = table()
end

--- ## `resume`
--- When resumed, scenes re-install all the global Sonnet
--- stuff (Effect, Tween, etc) that they saved

function Scene:resume()
    if self.clocks and self.tweens and self.effects then
        Clock.all = self.clocks
        self.clocks = nil

        Tween.all = self.tweens
        self.tweens = nil

        Effect.all = self.effects
        self.effects = nil

        self:on_resume()
    else
        error("Scene wasn't paused")
    end
end

----------------------------------------

--- ## `test`
--- A unit test

function Scene.static.test()
    love = {}
    local messages = {}

    local Demo = Scene:subclass('Demo')

    function Demo:initialize(name)
        self.name = name
    end

    function Demo:on_install() table.insert(messages, self.name .. " installed") end
    function Demo:on_pause() table.insert(messages, self.name .. " paused") end
    function Demo:on_resume() table.insert(messages, self.name .. " resumed") end
    function Demo:on_exit() table.insert(messages, self.name .. " exited") end

    d1 = Demo('d1')
    d2 = Demo('d2')
    d3 = Demo('d3')

    Scene.push(d1)
    Scene.push(d2)
    assert(Scene.stack[1] == d1 and Scene.stack[2] == d2)
    Scene.pop()
    Scene.push(d3)
    assert(Scene.stack[1] == d1 and Scene.stack[2] == d3)
    Scene.pop()
    assert(Scene.stack[1] == d1 and Scene.stack[2] == nil)
    Scene.pop()
    assert(#Scene.stack == 0)

    assert(messages[1] == "d1 installed")
    assert(messages[2] == "d1 paused")
    assert(messages[3] == "d2 installed")
    assert(messages[4] == "d2 exited")
    assert(messages[5] == "d1 resumed")
    assert(messages[6] == "d1 installed")
    assert(messages[7] == "d1 paused")
    assert(messages[8] == "d3 installed")
    assert(messages[9] == "d3 exited")
    assert(messages[10] == "d1 resumed")
    assert(messages[11] == "d1 installed")
    assert(messages[12] == "d1 exited")
end

return Scene