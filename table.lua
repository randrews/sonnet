-- Example:
-- t = table(1, 2, 3)
--     --> {1, 2, 3}
-- t:insert(4)
--     --> {1, 2, 3, 4}
-- t:map(function(n) return n*n)
--     --> {1, 4, 9, 16}

setmetatable(table,
             {__call = function(_, ...)
                           return setmetatable({...}, table.mt)
                       end })

table.mt = {
    __index = table,
    __tostring = function(self)
                     return "{" .. self:map(tostring):concat(", ") .. "}"
                 end
}

-------------------------

--- Add to end
table.push = table.insert

--- Remove from end
table.pop = table.remove

--- Add to beginning
function table:unshift(item)
    self:insert(1, item)
end

--- Remove from beginning
function table:shift()
    return self:remove(1)
end

--- Remove first occurrence of item (using ==)
function table:remove_item(item)
    for n, c in ipairs(self) do
        if c == item then
            self:remove(n)
            return true
        end
    end
end

--- Remove item at index
table.remove_at = table.remove

----------------------------------------

function table:push_all(items)
    for _, v in ipairs(items) do self:insert(v) end
end

function table:unshift_all(items)
    for _, v in ipairs(items) do self:insert(v, 1) end
end

----------------------------------------

function table:length()
    return #(self)
end

function table:clear()
    while #self > 0 do self:pop() end
end

function table:empty()
    return #(self) == 0
end

function table:random()
    if self:empty() then return nil, nil
    else
        local i = math.random(#self)
        return self[i], i
    end
end

----------------------------------------

function table:map(fn, ...)
    local t = table()
    for _, e in ipairs(self) do
        t:insert( fn(e, ...) )
    end
    return t
end

function table:method_map(fn_name, ...)
    local result = table()

    for _, item in ipairs(self) do
        local fn = item[fn_name]
        local r = fn(item, ...)
        if r~=nil then result:push(r) end
    end

    return result
end

function table:each(fn, ...)
    if fn then
        for _, item in ipairs(self) do
            fn(item, ...)
        end
    else -- No argument, return an iterator
        local it = function(t, n)
                       if t[n+1]~=nil then return n+1, t[n+1] end
                   end

        return it, self, 0
    end
end

function table:method_each(fn_name, ...)
    for _, item in ipairs(self) do
        local fn = item[fn_name]
        fn(item, ...)
    end
end

function table:select(fn, ...)
    local result = table()

    for _, item in ipairs(self) do
        if fn(item, ...) then result:push( item ) end
    end

    return result
end

function table:method_select(fn_name, ...)
    local result = table()

    for _, item in ipairs(self) do
        local fn = item[fn_name]
        if fn(item, ...) then result:push( item ) end
    end

    return result
end

function table:method_filter(fn_name, ...)
    local idx = 1
    while idx <= #self do
        local item = self[idx]
        local fn = item[fn_name]
        if fn(item, ...) then -- keep it
            idx = idx + 1
        else
            self:remove(idx)
        end
    end
end

function table:filter(fn, ...)
    local idx = 1
    while idx <= #self do
        local item = self[idx]
        if fn(...) then -- keep it
            idx = idx + 1
        else
            self:remove(idx)
        end
    end
end
