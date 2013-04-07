module(..., package.seeall)
local utils = require(_PACKAGE .. 'utils')
local List = utils.public_class('List')

----------------------------------------

function List:initialize(items)
    if type(items) ~= 'table' then items = {items} end
    self.items = items
end

-- Add to end
function List:push(item)
   table.insert(self.items, item)
end

-- Remove from end
function List:pop()
   return table.remove(self.items)
end

-- Add to beginning
function List:unshift(item)
   table.insert(self.items, 1, item)
end

-- Remove from beginning
function List:shift()
   return table.remove(self.items, 1)
end

-- Remove first occurrence of item (using ==)
function List:remove(item)
    for n, c in ipairs(self.items) do
        if c == item then
            table.remove(self.items, n)
            return true
        end
    end
end

-- Remove item at index
function List:remove_at(index)
    return table.remove(self.items, index)
end

----------------------------------------

function List:push_all(items)
   if items.class == List then items = items.items end
   for _, v in ipairs(items) do table.insert(self.items, v) end
end

function List:unshift_all(items)
   if items.class == List then items = items.items end
   for _, v in ipairs(items) do table.insert(self.items, v, 1) end
end

----------------------------------------

function List:length()
   return #(self.items)
end

function List:at(i, v)
   if v then self.items[i] = v end
   return self.items[i]
end
List.__call = List.at

function List:clear()
   self.items = {}
end

function List:empty()
   return #(self.items) == 0
end

function List:random()
   if self:empty() then return nil, nil
   else
       local i = math.random(#self.items)
       return self.items[i], i
   end
end

----------------------------------------

function List:map(fn, ...)
   local result = List()

   for _, item in ipairs(self.items) do
      result:push( fn(item, ...) )
   end

   return result
end

function List:method_map(fn_name, ...)
   local result = List()

   for _, item in ipairs(self.items) do
      local fn = item[fn_name]
      result:push( fn(item, ...) )
   end

   return result
end

function List:each(fn, ...)
    if fn then
        for _, item in ipairs(self.items) do
            fn(item, ...)
        end
    else -- No argument, return an iterator
        local it = function(t, n)
                       if t[n+1] then return n+1, t[n+1] end
                   end

        return it, self.items, 0
    end
end

function List:method_each(fn_name, ...)
   for _, item in ipairs(self.items) do
      local fn = item[fn_name]
      fn(item, ...)
   end
end

function List:select(fn, ...)
   local result = List()

   for _, item in ipairs(self.items) do
      if fn(item, ...) then result:push( item ) end
   end

   return result
end

function List:method_select(fn_name, ...)
   local result = List()

   for _, item in ipairs(self.items) do
      local fn = item[fn_name]
      if fn(item, ...) then result:push( item ) end
   end

   return result
end

function List:method_filter(fn_name, ...)
    local idx = 1
    while idx <= #self.items do
        local item = self.items[idx]
        local fn = item[fn_name]
        if fn(item, ...) then --- keep it
            idx = idx + 1
        else
            table.remove(self.items, idx)
        end
    end
end

function List:filter(fn, ...)
    local idx = 1
    while idx <= #self.items do
        local item = self.items[idx]
        if fn(...) then --- keep it
            idx = idx + 1
        else
            table.remove(self.items, idx)
        end
    end
end

return List