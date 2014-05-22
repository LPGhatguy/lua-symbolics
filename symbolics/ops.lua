local path = (...):match("^(.-)%..-$") .. "."
local fraction = require(path .. "types.fraction")
local ops = {}

ops.addition = {
	binary = true,
	commutative = true,
	associative = true,

	inverse = "subtraction",

	approx = function(a, b)
		return a + b
	end,

	format = function(a, b)
		return ("%s+%s"):format(a, b)
	end
}

ops.addition.eval = ops.addition.approx

ops.subtraction = {
	binary = true,
	commutative = false,
	associative = false,

	inverse = "addition",

	approx = function(a, b)
		return a - b
	end,

	format = function(a, b)
		return ("(%s)-(%s)"):format(a, b)
	end
}

ops.subtraction.eval = ops.subtraction.approx

ops.multiplication = {
	binary = true,
	commutative = true,
	associative = true,

	inverse = "division",

	approx = function(a, b)
		return a * b
	end,

	format = function(a, b)
		return ("(%s)*(%s)"):format(a, b)
	end
}

ops.multiplication.eval = ops.multiplication.approx

ops.division = {
	binary = true,
	commutative = false,
	associative = false,

	inverse = "multiplication",

	eval = function(a, b)
		return fraction.reduce(fraction.new(a, b))
	end,

	approx = function(a, b)
		return a / b
	end,

	format = function(a, b)
		return ("(%s)/(%s)"):format(a, b)
	end
}

ops.exponent = {
	binary = true,
	commutative = false,
	associative = false,

	inverse = "logarithm",

	--todo: eval

	approx = function(base, exp)
		return base ^ exp
	end,

	format = function(a, b)
		return ("(%s)^(%s)"):format(a, b)
	end
}

ops.logarithm = {
	binary = true,
	commutative = false,
	associative = false,

	inverse = "exponent",

	--todo: eval

	approx = function(base, body)
		return math.log(body) / math.log(base)
	end,

	format = function(a, b)
		return ("log%s(%s)"):format(a, b)
	end,

	functformat = function(a, b)
		return ("(math.log(%s) / math.log(%s))"):format(b, a)
	end
}

return ops