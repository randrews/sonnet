Sonnet
======

A library of utility classes for Love2d

Purpose
-------

I found myself reusing the same sorts of classes in different games over and over again, to handle points on a grid, or animation, or callbacks with timers. So, I stopped just copying these files into each new game, and made them into a library.

Installation
------------

1. First, clone this repository into some directory in your game, like "sonnet".
2. Then, if you want to pull in all the classes, put <code>require('sonnet')</code> at the top of main.lua (or wherever). If you cloned it into a directory other than "sonnet" then use that name instead.
3. If you just want to use some classes, then require them individually: <code>require('sonnet.Tween')</code> for example.

Classes
-------

I don't have full documentation finished yet, but this is a list of available classes and what they do:

- **Point** represents a point on a 2d plane
- **List** and **Set** are ordered and unordered data structures respectively
- **Map** handles a square grid of tiles
- **SparseMap** is like Map but more efficient for a grid in which most of the cells are empty
- **Clock** will call a function repeatedly on a timer
- **Promise** will allow you to perform an action when an asynchronous operation finishes
- **Tween** smoothly changes a value between two limits

More to come!

Author
------

I'm [Ross Andrews](mailto:ross.andrews@gmail.com), and I write Lua as a hobby. My blog is [Play With Lua!](http://playwithlua.com)
