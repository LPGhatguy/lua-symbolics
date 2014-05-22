--[[
Symbolic Math Library Core
Targetting Lua 5.1 and LuaJIT 2
Any Lua 5.2 or 5.3 support is accidental.

TODO:
- Smarter parens
- Better error reporting
- "Pretty printing" with love
- Class for constants
]]

local path = (...) .. "."
local support = require(path .. "support")
local ops = require(path .. "ops")
local constants = require(path .. "constants")
local symbolics

local tonumber = support.tonumber

symbolics = {
	ops = ops,
	constants = constants,

	eval = function(self, expression, values)
		if (type(expression) == "table") then
			if (expression.__number) then
				if (expression.eval) then
					return expression:eval()
				else
					return expression
				end
			else

				local sort = expression[1]

				if (self.ops[sort]) then
					local op = self.ops[sort]
					local args = {}
					local has_problem = false
					local problems = ""

					local method = op.eval

					if (not method) then
						if (op.approx) then
							method = op.approx
							has_problems = true
							problems = problems .. "Approximation used, results may not be exact.\n"
						else
							print("Unable to find eval or approx member of operator '" .. sort .. "'")
							return
						end
					end

					for index = 2, #expression do
						local value = self:eval(expression[index], values)

						table.insert(args, value)
					end

					return method(unpack(args))
				else
					print("Invalid operator '" .. tostring(sort) .. "'")
					return
				end
			end
		elseif (values and values[expression]) then
			return values[expression]
		elseif (self.constants[expression]) then
			return self.constants[expression].value
		elseif (tonumber(expression)) then
			return tonumber(expression)
		else
			print("Unresolved variable '" .. tostring(expression) .. "'")
		end
	end,

	approx = function(self, expression, values)
		if (type(expression) == "table") then
			if (expression.__number) then
				if (expression.approx) then
					return expression:approx()
				else
					print("No approximation function for pseudonumber!")
				end
			else

				local sort = expression[1]

				if (self.ops[sort]) then
					local op = self.ops[sort]
					local args = {}

					for index = 2, #expression do
						local value = self:approx(expression[index], values)

						if (type(value) == "number") then
							table.insert(args, value)
						else
							print("Unresolved symbol in operator!")
							print(value)
							return
						end
					end

					return op.approx(unpack(args))
				else
					print("Invalid operator '" .. tostring(sort) .. "'")
					return
				end
			end
		elseif (values and values[expression]) then
			return values[expression]
		elseif (self.constants[expression]) then
			return self.constants[expression].value
		elseif (tonumber(expression)) then
			return tonumber(expression)
		else
			print("Unresolved variable '" .. tostring(expression) .. "'!")
		end
	end,

	stringify = function(self, expression, out)
		if (type(expression) == "table") then
			if (expression.__number) then
				if (expression.tostring) then
					return expression:tostring()
				else
					print("No tostring operator for pseudonumber!")
					return
				end
			else
				out = out or ""
				local sort = expression[1]

				if (self.ops[sort]) then
					local op = self.ops[sort]

					local list = {}

					for index = 2, #expression do
						table.insert(list, self:stringify(expression[index]))
					end

					return op.format(unpack(list))
				else
					print("Found invalid operation '" .. tostring(sort) .. "'")
				end
			end
		elseif (self.constants[expression]) then
			return self.constants[expression].symbol
		else
			return tostring(expression)
		end
	end,

	functstring = function(self, expression, out)
		if (type(expression) == "table") then
			if (expression.__number) then
				local formatter = expression.tofunctstring or expression.tostring

				if (formatter) then
					return formatter(expression)
				else
					print("Could not find formatter for pseudonumber!")
				end
			else
				out = out or ""

				local sort = expression[1]

				if (self.ops[sort]) then
					local op = self.ops[sort]
					local formatter = op.functformat or op.format

					local list = {}

					for index = 2, #expression do
						table.insert(list, self:functstring(expression[index]))
					end

					return formatter(unpack(list))
				else
					print("Found invalid operation '" .. tostring(sort) .. "'")
				end
			end
		elseif (self.constants[expression]) then
			return self.constants[expression].symbol
		else
			return tostring(expression)
		end
	end,

	functify = function(self, expression, variables)
		local source = ([[
			return function(%s)
				return %s
			end
		]]):format(
			table.concat(variables, ","),
			self:functstring(expression)
		)

		return loadstring(source)()
	end
}

return symbolics