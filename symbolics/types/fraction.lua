--[[
Fraction Extensions
Provides a fractional numeric datatype with exact evaluations
]]

local path = (...):match("^(.-)%..-%..-$") .. "."
local support = require(path .. "support")
local fraction
local fraction_meta

fraction = {
	__number = true,
	__fraction = true,

	new = function(a, b)
		return setmetatable({a, b}, fraction_meta)
	end,

	tostring = function(self)
		return ("%s/%s"):format(self[1], self[2])
	end,

	tofunctstring = function(self)
		return ("(%s)/(%s)"):format(self[1], self[2])
	end,

	approx = function(number)
		return number[1] / number[2]
	end,

	coerce = function(number)
		if (type(number) == "number") then
			if (number % 1 == 0) then
				return fraction:new(number, 1)
			else
				--uhh
				--TODO
				error("Cannot transform non-integer to fraction... yet!")
			end
		elseif (type(number) == "table") then
			if (number.__fraction) then
				return number
			else
				return fraction:new(number, 1)
			end
		end
	end,

	--simplify always returns a fraction
	simplify = function(number)
		local common = support.gcd(number[1], number[2])

		return fraction.new(number[1] / common, number[2] / common)
	end,

	--reduce can return another type
	reduce = function(number)
		if (number[1] / number[2] % 1 == 0) then
			return number[1] / number[2]
		else
			return fraction.simplify(number)
		end
	end,

	--ACTUAL OPERATORS
	minus = function(a)
		a = fraction.coerce(a)

		return fraction.new(-a[1], a[2])
	end,

	add = function(a, b)
		a = fraction.coerce(a)
		b = fraction.coerce(b)

		local n = a[1]*b[2] + a[2]*b[1]
		local d = a[2]*b[2]
		local g = support.gcd(n, d)

		return fraction.new(n / g, d / g)
	end,

	subtract = function(a, b)
		a = fraction.coerce(a)
		b = fraction.coerce(b)

		local n = a[1]*b[2] - a[2]*b[1]
		local d = a[2]*b[2]
		local g = support.gcd(n, d)

		return fraction.new(n / g, d / g)
	end,

	multiply = function(a, b)
		a = fraction.coerce(a)
		b = fraction.coerce(b)

		return fraction.reduce(fraction.new(a[1] * b[1], a[2] * b[2]))
	end,

	divide = function(a, b)
		a = fraction.coerce(a)
		b = fraction.coerce(b)

		return fraction.reduce(fraction.new(a[1] * b[2], a[2] * b[1]))
	end,

	power = function(a, b)
		a = fraction.coerce(a)
		b = fraction.coerce(b)

		--todo
		return 1
	end
}

fraction_meta = {
	__index = fraction,
	__tostring = fraction.tostring,

	__tonumber = fraction.approx,

	__unm = fraction.minus,
	__add = fraction.add,
	__sub = fraction.subtract,
	__mul = fraction.multiply,
	__div = fraction.divide,
	__pow = fraction.power
}

return fraction