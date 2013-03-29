-- Broadcasts messages and lets things subscribe to messages.
--
-- A *message* is a string, with an optional set of arguments:
--     Messenger.send("player_jump", player_loc)
--
-- A *subscriber* is a function that wants to be notified about
-- that kind of message:
--     Messenger.subscribe("player_jump", handle_jump)

module(..., package.seeall)
local utils = require(_PACKAGE .. 'utils')
local List = require(_PACKAGE .. 'List')

local Messenger = utils.public_class('Messenger')

-- ## Subscription table
-- This maps from message name to [List](List.html) of subscribers.
-- The message names
-- are always strings, the subscribers are either functions
-- or tables containing {function_name, object} (if they used `method_subscribe`)
--
-- This may be swapped out and replaced when scenes are changed,
-- see [Scene](Scene.html).
Messenger.static.subscriptions = {}

----------------------------------------

-- ## Send
-- Send a message to all subscribers (if any)
--
-- - **message** is a string for the message type
-- - Other args are passed to all the subscribers

function Messenger.static.send(message, ...)
    local sub_list = Messenger.subscriptions[message]
    if sub_list then
        for _, subscriber in sub_list:each() do
            if type(subscriber) == 'table' then
                local fn_name, obj = unpack(subscriber)
                local fn = obj[fn_name]
                fn(obj, ...)
            elseif type(subscriber) == 'function' then
                subscriber(...)
            end
        end
    end
end

-- ## Subscribe
-- Add a function to the subscriber list for a message type
--
-- - **message** is a string for the message type
-- - **fn** is the function to handle it

function Messenger.static.subscribe(message, fn)
    if not Messenger.subscriptions[message] then
        Messenger.subscriptions[message] = List()
    end

    local subs = Messenger.subscriptions[message]
    subs:push(fn)
end

-- ## Method Subscribe
-- Add an object method to the subscriber list for a message type
--
-- - **message** is a string for the message type
-- - **obj** is the object to invoke a method on
-- - **method_name** is the name of the method to invoke.
--
-- method_name is optional, defaults to message.

function Messenger.static.method_subscribe(message, obj, method_name)
    if not Messenger.subscriptions[message] then
        Messenger.subscriptions[message] = List()
    end

    local subs = Messenger.subscriptions[message]
    local sub = {method_name or message, obj}
    subs:push(sub)
end

----------------------------------------

-- ## Test
-- A unit test

function Messenger.static.test()
    local a = false
    local a2 = false
    local b = false

    Messenger.subscribe('a', function(x) assert(x==1) ; a = true end)
    Messenger.subscribe('a', function(x) assert(x==1) ; a2 = true end)
    Messenger.subscribe('b', function() b = true end)

    Messenger.send('a', 1)
    assert(a and a2 and not b)

    local obj = { flag = false, flag2 = false }

    Messenger.method_subscribe('c', obj)

    obj.c = function(self, val)
                assert(val == 2)
                self.flag = true
            end

    Messenger.send('c', 2)
    assert(obj.flag)

    obj.set_flag2 = function(self) self.flag2 = true end
    Messenger.method_subscribe('d', obj, 'set_flag2')
    Messenger.send('d')
    assert(obj.flag2)
end

return Messenger