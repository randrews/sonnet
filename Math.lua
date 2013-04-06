-- **Math** is a module of math helper functions
-- useful in game development

module(..., package.seeall)
local utils = require(_PACKAGE .. 'utils')
local List = require(_PACKAGE .. 'List')
local Point = require(_PACKAGE .. 'Point')

-- # Random numbers
--
-- A set of functions to handle random and quasi-random sequences

-- ## halton
--
-- Returns the first `num` values in the scrambled
-- Halton sequence for the given base.
--
-- The Halton sequence is a quasi-random sequence
-- used to generate evenly-distributed random values.
--
-- - `base` is a prime number (probably 2 or 3)
-- - `num` is the number of values to return.
--
-- Returns a List of `num` values between 0 and 1.

function halton(base, num)
    local values = List()

    --- The permutation is a table of 9 digits in random order
    local digits = List{1, 2, 3, 4, 5, 6, 7, 8, 9}
    local permutation = {}
    repeat
        local _, i = digits:random()
        table.insert(permutation, digits:remove_at(i))
    until digits:empty()

    for n = 1, num do
        --- First generate the number...
        local result = 0
        local f = 1 / base
        local i = n

        while i > 0 do
            result = result + f * (i % base);
            i = math.floor(i / base)
            f = f / base;
        end

        --- Then scramble it...
        local r = 0
        for n = 0, 15 do
            local d = math.floor(result * (10^n) % 10)
            if d > 0 then
                r = r + permutation[d] / (10^n)
            end
        end

        --- Then add it to the list
        values:push(r)
    end

    return values
end

-- ## qrandom points
--
-- Generate a list of quasi-random Points
-- using a scrambled Halton sequence
--
-- - `num` is the number of Points to generate
-- - `width` is the width of the range to place them in
-- - `height` is the height of the range to place them in
--
-- Returns a List of `num` Points

function qrandom_points(num, width, height)
    local points = List()
    local x = halton(2, num)
    local y = halton(3, num)

    for n = 1, num do
        local sx = round(x:at(n) * (width+0.5))
        local sy = round(y:at(n) * (height+0.5))
        points:push(Point(sx, sy))
    end

    return points
end

-- ## random points
--
-- Generate a list of random Points
-- using math.random.
--
-- - `num` is the number of Points to generate
-- - `width` is the width of the range to place them in
-- - `height` is the height of the range to place them in
--
-- Returns a List of `num` Points

function random_points(num, width, height)
    local points = List()

    for n = 1, num do
        local x = math.random(width)
        local y = math.random(height)
        points:push(Point(x, y))
    end

    return points
end

-- ## round
--
-- If the fractional part of `n` is 0.5 or above, returns `ceil(n)`;
-- otherwise, `floor(n)`

function round(n)
    local fpart = ((n * 10) % 10) / 10
    if fpart >= 0.5 then return math.ceil(n)
    else return math.floor(n) end
end

-- # Collisions
--
-- This is a set of functions to determine if two shapes intersect

-- ## collision point rect
--
-- Returns whether a point lies within a rectangle
--
-- - `pt` is the point
-- - `topleft` is a Point representing the top-left corner of the rect
-- - `size` is a Point representing the dimensions of the rect.
--
-- Returns true or false.

function collision_point_rect(pt, topleft, size)
    return pt.x >= topleft.x and
        pt.x <= topleft.x+size.x and
        pt.y >= topleft.y and
        pt.y <= topleft.y+size.y
end
