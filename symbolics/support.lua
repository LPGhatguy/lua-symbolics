--[[
Extension Support Module
Lets extension numeric datatypes integrate more effectively
]]

local tonumber__ = tonumber
local extension

extension = {
	import = function(self)
		_G.tonumber = self.tonumber
	end,

	tonumber = function(object)
		if (type(object) == "table") then
			local meta = getmetatable(object)
			if (meta and meta.__tonumber) then
				return meta.__tonumber(object)
			end
		end

		return tonumber__(object)
	end,

	gcd = function(a, b)
		local remainder

		while (b ~= 0) do
			remainder = a % b
			a = b
			b = remainder
		end

		return a
	end
}

return extension