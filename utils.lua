module(..., package.seeall)
local middleclass = require(_PACKAGE .. 'middleclass')

_SONNET = _PACKAGE:sub(1, -2)

function public_class(...)
    local klass = middleclass.class(...)
    _G[_SONNET][klass.name] = klass
    return klass
end