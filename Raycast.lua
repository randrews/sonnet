--- **Raycast** is a module of functions to perform raycasting
--- against various primitives.

module(..., package.seeall)
require('sonnet.table')
local Point = require('sonnet.Point')

--- ## Common patterns
---
--- Most of these take a ray and some primitive. The ray is
--- always represented as two `Point`s: a starting point, and
--- a vector from the starting point.
---
--- They return either a Point or a numerically-indexed table
--- (not a `List`) of Points, depending on the number of
--- possible intersections; so, raycasting against a line segment
--- will return a `Point` or nil, against a polygon will return
--- an array of Points or an empty array, etc.

--- ## line
---
--- Intersection of a ray and a line segment
---
--- - `rpt`, `rvec` are the ray
---
--- - `line1`, `line2` are the endpoints of the
---   line segment.

function line(rpt, rvec, line1, line2)
    -- Find the slope and y-icpt of the ray and the line
    local rm, rb = slope_intercept(rpt, rvec)
    local lm, lb = slope_intercept(line1, line2-line1)

    local xmin = math.min(line1.x, line2.x)
    local xmax = math.max(line1.x, line2.x)
    local ymin = math.min(line1.y, line2.y)
    local ymax = math.max(line1.y, line2.y)

    if rm == lm then -- parallel lines
        return nil

    elseif line1.x == line2.x then -- vertical line special case
        local i = Point(line1.x, rm * line1.x + rb)

        -- Is the intersection actually on the segment?
        if i.y >= ymin and i.y <= ymax then
            -- Is the intersection actually being pointed at by the ray?
            local dx = i.x - rpt.x
            if dx < 0 and rvec.x < 0 or dx > 0 and rvec.x > 0 then
                return i
            end
        end

    elseif math.abs(rvec.x) < 0.0001 then -- vertical ray special case
        -- Sometimes atan2 gives us very small nonzero values, that we should really
        -- treat as zeros because they don't work with the general algorithm, so we round.
        -- The problem is that dx is effectively 0 so the "pointing at" check fails.
        local i = Point(rpt.x, lm * rpt.x + lb)

        -- Is the intersection actually on the segment?
        if i.x >= xmin and i.x <= xmax then
            -- Is the intersection actually being pointed at by the ray?
            local dy = i.y - rpt.y
            if dy < 0 and rvec.y < 0 or dy > 0 and rvec.y > 0 then
                return i
            end
        end

    else -- Normal intersecting lines
        -- okay, they intersect, but where?
        -- rm * x + rb == lm * x + lb
        -- x == (lb - rb) / (rm - lm)
        local ix = (lb - rb) / (rm - lm)

        -- Is the intersection actually on the segment?
        if ix >= xmin and ix <= xmax then

            -- Is the intersection actually being pointed at by the ray?
            local dx = ix - rpt.x
            if dx < 0 and rvec.x < 0 or dx > 0 and rvec.x > 0 then
                return Point(ix, rm*ix+rb)
            end
        end
    end
end

--- ## polygon
---
--- - `rpt`, `rvec` are a ray
---
--- - The other arguments are all points, the vertices
---   of the polygon (in order)

function polygon(rpt, rvec, ...)
    local corners = {...}
    local intersections = {}

    for i, p1 in ipairs(corners) do
        local p2 = corners[i+1] or corners[1]
        local isect = line(rpt, rvec, p1, p2)
        table.insert(intersections, isect)
    end
    return intersections
end

--- ## rectangle
---
--- - `rpt`, `rvec` are a ray
---
--- - `topleft` and `size` are the top left corner
---   and the size of a rectangle, as `Point`s.

function rectangle(rpt, rvec, topleft, size)
    return polygon(rpt, rvec,
                   topleft,
                   topleft+Point(size.x, 0),
                   topleft+size,
                   topleft+Point(0, size.y))
end

--- ## slope intercept
---
--- Takes a point and a vector from that point, and
--- returns the slope and y-intercept of the resulting
--- line.
function slope_intercept(pt, vec)
    local m = vec.y / vec.x
    local b = pt.y - pt.x * m
    return m, b
end
