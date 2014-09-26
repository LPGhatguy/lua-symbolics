# lua-symbolics
Provides a structure to represent mathematical expressions symbolically. It is a **work in progress.**

This work is licensed under the zlib/libpng license; more details are in license.txt.

## Usage
The library's basic usage is straightforward:
```lua
--Load base library
local symbolics = require("symbolics")

--Fractions!
local fraction = require("symbolics.types.fraction")

--Build tree representing the logarithm with base 1/2 of X:
local log2 = {"logarithm", fraction.new(1, 2), "x"}

--Turn that into a Lua function!
local log2f = symbolics:functify(log2, {"x"})

--Print the string representation of our expression
print(symbolics:stringify(log2))

--Approximate the value at x=8
print(symbolics:approx(log2, {x=8}))

--Approximate the value using our functional form
print(log2f(8))
```