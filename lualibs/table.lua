-- preloaded code: table.lua

--- Returns true if `table` contains at least N copies of `item`
--- @param t table
--- @param item any
--- @param n integer?
--- @return boolean
function table.contains(t, item, n)
	n = n or 1
	if not t then
		error("Bad argument #1 of table.contains: table is nil")
	end
	if type(t) ~= 'table' then
		error("Bad argument #1 of table.contains: not a table")
	end
	if type(n) ~= 'number' then
		error("Bad argument #3 of table.contains: not a number")
	end

	local found = 0
	for _, v in pairs(t) do
		if v == item then
			found = found + 1
			if found >= n then
				return true
			end
		end
	end
	return false
end

--- Returns a table containing elements from `table` that match the criteria given by `func`
--- @param t table
--- @param func function(key: any, value: any, table: table): boolean
--- @return table
function table.filter(t, func)
	if not t then
		error("Bad argument #1 of table.filter: table is nil")
	end
	if type(t) ~= 'table' then
		error(
			"Bad argument #1 of table.filter: not a table")
	end
	if not func then
		error("Bad argument #2 of table.filter: function is nil")
	end
	if type(func) ~= 'function' then
		error(
			"Bad argument #2 of table.filter: not a function")
	end

	local ret = {}
	for k, v in pairs(t) do
		if func(v, k, t) then
			ret[k] = v
		end
	end
	return ret
end

--- Returns a shallow (non-recursive) copy of `table`
--- @param t table
--- @return table
function table.shallow_copy(t)
	local ret = {}
	for k, v in pairs(t) do
		ret[k] = v
	end
	return ret
end

--- Returns a deep (recursive) copy of `table`
--- @param t table
--- @return table
function table.deep_copy(t)
	-- TODO this is probably crap
	local ret = {}
	for k, v in pairs(t) do
		if type(k) == "table" then k = table.deep_copy(k) end
		if type(v) == "table" then v = table.deep_copy(v) end
		ret[k] = v
	end
	return ret
end
