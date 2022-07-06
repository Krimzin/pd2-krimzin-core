setfenv(1, KrimzinCore)

local loaded = {[MOD_PATH .. "lua/core/Functions.lua"] = true}

function require(path)
	local value = loaded[path]

	if value == nil then
		value = blt.vm.dofile(path)

		if value == nil then
			value = true
		end

		loaded[path] = value
	end

	return value
end

function use_env(name, parent)
	parent = parent or getfenv(2)
	local env = parent[name]

	if not env then
		env = setmetatable({}, {__index = parent})
		parent[name] = env
	end

	setfenv(2, env)
end
