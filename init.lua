module(..., package.seeall)

require('sonnet.middleclass')
require('sonnet.table')

utils = require('sonnet.utils')
Math = require('sonnet.Math')
Raycast = require('sonnet.Raycast')
Set = require('sonnet.Set')
Point = require('sonnet.Point')
Map = require('sonnet.Map')
SparseMap = require('sonnet.SparseMap')
Clock = require('sonnet.Clock')
Tween = require('sonnet.Tween')
Promise = require('sonnet.Promise')
Messenger = require('sonnet.Messenger')
Scene = require('sonnet.Scene')
Effect = require('sonnet.Effect')

effects = {}

effects.RisingText = require('sonnet.effects.RisingText')
effects.Sparks = require('sonnet.effects.Sparks')
effects.Spray = require('sonnet.effects.Spray')
effects.Bullet = require('sonnet.effects.Bullet')

function sonnet.test()
    Point.test()
    Map.test()
    Promise.test()
    Scene.test()
    SparseMap.test()
    Tween.test()
end