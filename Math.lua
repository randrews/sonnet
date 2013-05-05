-- **Math** is a module of math helper functions
-- useful in game development

module(..., package.seeall)
local List = require('sonnet.List')
local Point = require('sonnet.Point')

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

-- ## collision circle rect
--
-- Returns whether a rectangle and a circle have collided, and if so how.
--
-- - `center` is a Point for the center of the circle
-- - `radius` is the radius of the circle.
-- - `topleft` is a Point for the top-left corner of a rectangle
-- - `size` is a Point representing the dimensions of the rect.
--
-- If no collision, then returns false.
--
-- If there is a collision, it returns true, and a unit-length Point representing
-- the direction the circle will have to move to move away from the collision.

function collision_circle_rect(center, radius, topleft, size)
    local rect_center = topleft + size/2
    local diag = math.sqrt(size.x*size.x + size.y*size.y) -- Length of the rect diagonal
    local dist = center:dist(rect_center) -- Distance the centers are apart

    -- First, check a circle circumscribing the rect.
    -- Obviously no collision, return false. This is to make the
    -- most common case (you're really far away) fast.
    if dist > diag/2 + radius then return false end

    -- Then, let's see if we hit one of the walls of the rect:

    -- We may hit a top / btm wall if we're too close:
    if center.x >= rect_center.x-size.x/2 and center.x <= rect_center.x+size.x/2 then
        if math.abs(center.y-rect_center.y) > radius + size.y/2 then return false
        else -- we hit it, move either up or down to resolve
            if center.y < rect_center.y then return true, Point(0, -1)
            else return true, Point(0, 1) end
        end
    end

    -- We may hit a left / rt wall if we're too close:
    if center.y >= rect_center.y-size.y/2 and center.y <= rect_center.y+size.x/2 then
        if math.abs(center.x-rect_center.x) > radius + size.x/2 then return false
        else -- we hit it, move either up or down to resolve
            if center.x < rect_center.x then return true, Point(-1, 0)
            else return true, Point(1, 0) end
        end
    end

    -- We're still here, so we are diagonal-wise to the rect.

    if center.x < rect_center.x and center.y < rect_center.y and
        center:dist(Point(rect_center.x-size.x/2, rect_center.y-size.y/2), diag/2+radius) then
        -- We hit the top left corner
        return true, (center-rect_center):normal()
    end

    if center.x > rect_center.x and center.y < rect_center.y and
        center:dist(Point(rect_center.x+size.x/2, rect_center.y-size.y/2), diag/2+radius) then
        -- We hit the top right corner
        return true, (center-rect_center):normal()
    end

    if center.x > rect_center.x and center.y > rect_center.y and
        center:dist(Point(rect_center.x+size.x/2, rect_center.y+size.y/2), diag/2+radius) then
        -- We hit the bottom right corner
        return true, (center-rect_center):normal()
    end

    if center.x < rect_center.x and center.y > rect_center.y and
        center:dist(Point(rect_center.x-size.x/2, rect_center.y+size.y/2), diag/2+radius) then
        -- We hit the bottom left corner
        return true, (center-rect_center):normal()
    end

    -- And we're close but not too close, so we are fine.
    return false
end
