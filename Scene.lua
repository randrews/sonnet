module(..., package.seeall)
local utils = require(_PACKAGE .. 'utils')
local Clock = require(_PACKAGE .. 'Clock')
local Tween = require(_PACKAGE .. 'Tween')
local Effect = require(_PACKAGE .. 'Effect')
local List = require(_PACKAGE .. 'List')

local Scene = utils.public_class('Scene')
Scene.stack = {}

-- The Scene stack:
--
-- Scene manages a stack of scenes. Each scene is a set
-- of love event handlers (draw, update, etc) as well as
-- Tween / Clock / Messenger / Effect global lists. You
-- can push and pop on the Scene stack, which is the
-- standard method of changing scenes.
--
-- Scene lifecycle:
--
-- scene1 = MyScene()      [calls your constructor]
-- scene2 = MyOtherScene() [calls your constructor]
-- Scene.push(scene1)      [scene1:on_install]
-- Scene.push(scene2)      [scene1:on_pause, scene2:on_install]
-- Scene.pop()             [scene2:on_exit, scene1:on_resume, scene1:on_install]
-- Scene.pop()             [scene1:on_exit]
--
-- Event handler sequence:
--
-- constructor
-- on_install
-- on_pause   --
-- on_resume    >-- Possibly several times
-- on_install --
-- on_exit

function Scene.static.push(scene)
    local stk = Scene.stack
    if #stk > 0 then
        stk[#stk]:pause()
    end

    table.insert(stk, scene)
    scene:install()
end

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

-- Override me
function Scene:on_install() end
function Scene:on_pause() end
function Scene:on_resume() end
function Scene:on_exit() end
function Scene:update(dt) end
function Scene:draw() end
function Scene:keypressed(key, unicode) end
function Scene:mousepressed(x, y, button) end

function Scene:install()
    assert(love)

    self:on_install()
    love.update = function(dt) self:update_with_sonnet(dt) end
    love.draw = function() self:draw_with_sonnet() end
    love.keypressed = function(k, u) self:keypressed(k, u) end
    love.mousepressed = function(x, y, b) self:mousepressed(x, y, b) end
end

function Scene:update_with_sonnet(dt)
    Clock.update(dt)
    Tween.update(dt)
    Effect.update(dt)
    self:update(dt)
end

function Scene:draw_with_sonnet(dt)
    self:draw()
    Effect.draw()
end

function Scene:pause()
    self:on_pause()

    self.clocks = Clock.all
    self.tweens = Tween.all
    self.effects = Effect.all
    Clock.all = List()
    Tween.all = List()
    Effect.all = List()
end

function Scene:resume()
    if self.clocks and self.tweens then
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