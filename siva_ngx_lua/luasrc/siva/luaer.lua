-- Copyright (c) 2014 Siva

--- Luaer is a set of utility functions for dealing with 
-- iterators, arrays, tables, and functions.

local Luaer = { funcs = {} }
Luaer.__index = Luaer

function Luaer.__call(_, value)
	return Luaer:new(value)
end

function Luaer:new(value, chained)
	return setmetatable({ _val = value, chained = chained or false }, self)
end

function Luaer.iter(list_or_iter)
	if type(list_or_iter) == "function" then return list_or_iter end
	
	return coroutine.wrap(function() 
		for i=1,#list_or_iter do
			coroutine.yield(list_or_iter[i])
		end
	end)
end

function Luaer.range(start_i, end_i, step)
	if end_i == nil then
		end_i = start_i
		start_i = 1
	end
	step = step or 1
	local range_iter = coroutine.wrap(function() 
		for i=start_i, end_i, step do
			coroutine.yield(i)
		end
	end)
	return Luaer:new(range_iter)
end

--- Identity function. This function looks useless, but is used throughout Luaer as a default.
-- @name _.identity
-- @param value any object
-- @return value
-- @usage _.identity("foo")
-- => "foo"
function Luaer.identity(value)
	return value
end

-- chaining

function Luaer:chain()
	self.chained = true
	return self
end

function Luaer:value()
	return self._val
end

-- iter

function Luaer.funcs.each(list, func)
	for i in Luaer.iter(list) do
		func(i)
	end
	return list
end

function Luaer.funcs.map(list, func)
	local mapped = {}
	for i in Luaer.iter(list) do
		mapped[#mapped+1] = func(i)
	end	
	return mapped
end

function Luaer.funcs.reduce(list, memo, func)	
	for i in Luaer.iter(list) do
		memo = func(memo, i)
	end	
	return memo
end

function Luaer.funcs.detect(list, func)
	for i in Luaer.iter(list) do
		if func(i) then return i end
	end	
	return nil	
end

function Luaer.funcs.select(list, func)
	local selected = {}
	for i in Luaer.iter(list) do
		if func(i) then selected[#selected+1] = i end
	end
	return selected
end

function Luaer.funcs.reject(list, func)
	local selected = {}
	for i in Luaer.iter(list) do
		if not func(i) then selected[#selected+1] = i end
	end
	return selected
end

function Luaer.funcs.all(list, func)
	func = func or Luaer.identity
	
	-- TODO what should happen with an empty list?
	for i in Luaer.iter(list) do
		if not func(i) then return false end
	end
	return true
end

function Luaer.funcs.any(list, func)
	func = func or Luaer.identity

	-- TODO what should happen with an empty list?	
	for i in Luaer.iter(list) do
		if func(i) then return true end
	end	
	return false
end

function Luaer.funcs.include(list, value)
	for i in Luaer.iter(list) do
		if i == value then return true end
	end	
	return false
end

function Luaer.funcs.invoke(list, function_name, ...)
	local args = {...}
	Luaer.funcs.each(list, function(i) i[function_name](i, unpack(args)) end)
	return list
end

function Luaer.funcs.pluck(list, propertyName)
	return Luaer.funcs.map(list, function(i) return i[propertyName] end)
end

function Luaer.funcs.min(list, func)
	func = func or Luaer.identity
	
	return Luaer.funcs.reduce(list, { item = nil, value = nil }, function(min, item) 
		if min.item == nil then
			min.item = item
			min.value = func(item)
		else
			local value = func(item)
			if value < min.value then
				min.item = item
				min.value = value
			end
		end
		return min
	end).item
end

function Luaer.funcs.max(list, func)
	func = func or Luaer.identity
	
	return Luaer.funcs.reduce(list, { item = nil, value = nil }, function(max, item) 
		if max.item == nil then
			max.item = item
			max.value = func(item)
		else
			local value = func(item)
			if value > max.value then
				max.item = item
				max.value = value
			end
		end
		return max
	end).item
end

function Luaer.funcs.to_array(list)
	local array = {}
	for i in Luaer.iter(list) do
		array[#array+1] = i
	end	
	return array
end

function Luaer.funcs.reverse(list)
	local reversed = {}
	for i in Luaer.iter(list) do
		table.insert(reversed, 1, i)
	end	
	return reversed
end

function Luaer.funcs.sort(iter, comparison_func)
	local array = iter
	if type(iter) == "function" then
		array = Luaer.funcs.to_array(iter)
	end
	table.sort(array, comparison_func)
	return array
end

-- arrays

function Luaer.funcs.first(array, n)
	if n == nil then
		return array[1]
	else
		local first = {}
		n = math.min(n,#array)
		for i=1,n do
			first[i] = array[i]			
		end
		return first
	end
end

function Luaer.funcs.rest(array, index)
	index = index or 2
	local rest = {}
	for i=index,#array do
		rest[#rest+1] = array[i]
	end
	return rest
end

function Luaer.funcs.slice(array, start_index, length)
	local sliced_array = {}
	
	start_index = math.max(start_index, 1)
	local end_index = math.min(start_index+length-1, #array)
	for i=start_index, end_index do
		sliced_array[#sliced_array+1] = array[i]
	end
	return sliced_array
end

function Luaer.funcs.flatten(array)
	local all = {}
	
	for ele in Luaer.iter(array) do
		if type(ele) == "table" then
			local flattened_element = Luaer.funcs.flatten(ele)
			Luaer.funcs.each(flattened_element, function(e) all[#all+1] = e end)
		else
			all[#all+1] = ele
		end
	end
	return all
end

function Luaer.funcs.push(array, item)
	table.insert(array, item)
	return array
end

function Luaer.funcs.pop(array)
	return table.remove(array)
end

function Luaer.funcs.shift(array)
	return table.remove(array, 1)
end

function Luaer.funcs.unshift(array, item)
	table.insert(array, 1, item)
	return array
end

function Luaer.funcs.join(array, separator)
	return table.concat(array, separator)
end

-- objects

function Luaer.funcs.keys(obj)
	local keys = {}
	for k,v in pairs(obj) do
		keys[#keys+1] = k
	end
	return keys
end

function Luaer.funcs.values(obj)
	local values = {}
	for k,v in pairs(obj) do
		values[#values+1] = v
	end
	return values
end

function Luaer.funcs.extend(destination, source)
	for k,v in pairs(source) do
		destination[k] = v
	end	
	return destination
end

function Luaer.funcs.is_empty(obj)
	return next(obj) == nil
end

-- Originally based on penlight's deepcompare() -- http://luaforge.net/projects/penlight/
function Luaer.funcs.is_equal(o1, o2, ignore_mt)
	local ty1 = type(o1)
	local ty2 = type(o2)
	if ty1 ~= ty2 then return false end
	
	-- non-table types can be directly compared
	if ty1 ~= 'table' then return o1 == o2 end
	
	-- as well as tables which have the metamethod __eq
	local mt = getmetatable(o1)
	if not ignore_mt and mt and mt.__eq then return o1 == o2 end
	
	local is_equal = Luaer.funcs.is_equal
	
	for k1,v1 in pairs(o1) do
		local v2 = o2[k1]
		if v2 == nil or not is_equal(v1,v2, ignore_mt) then return false end
	end
	for k2,v2 in pairs(o2) do
		local v1 = o1[k2]
		if v1 == nil then return false end
	end
	return true
end

-- functions

function Luaer.funcs.compose(...)
	local function call_funcs(funcs, ...)
		if #funcs > 1 then
			return funcs[1](call_funcs(_.rest(funcs), ...))
		else
			return funcs[1](...)
		end
	end
	
	local funcs = {...}
	return function(...)
		return call_funcs(funcs, ...)
	end
end

function Luaer.funcs.wrap(func, wrapper)
	return function(...)
		return wrapper(func, ...)
	end
end

function Luaer.funcs.curry(func, argument)
	return function(...)
		return func(argument, ...)
	end
end

function Luaer.functions() 
	return Luaer.keys(Luaer.funcs)
end

-- add aliases
Luaer.methods = Luaer.functions

Luaer.funcs.for_each = Luaer.funcs.each
Luaer.funcs.collect = Luaer.funcs.map
Luaer.funcs.inject = Luaer.funcs.reduce
Luaer.funcs.foldl = Luaer.funcs.reduce
Luaer.funcs.filter = Luaer.funcs.select
Luaer.funcs.every = Luaer.funcs.all
Luaer.funcs.some = Luaer.funcs.any
Luaer.funcs.head = Luaer.funcs.first
Luaer.funcs.tail = Luaer.funcs.rest

local function wrap_functions_for_oo_support()
	local function value_and_chained(value_or_self)
		local chained = false
		if getmetatable(value_or_self) == Luaer then 
			chained = value_or_self.chained
			value_or_self = value_or_self._val 
		end
		return value_or_self, chained
	end

	local function value_or_wrap(value, chained)
		if chained then value = Luaer:new(value, true) end
		return value
	end

	for fn, func in pairs(Luaer.funcs) do
		Luaer[fn] = function(obj_or_self, ...)
			local obj, chained = value_and_chained(obj_or_self)	
			return value_or_wrap(func(obj, ...), chained)		
		end	 
	end
end

wrap_functions_for_oo_support()

return Luaer:new()
