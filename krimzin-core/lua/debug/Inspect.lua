setfenv(1, KrimzinCore)

Inspect = {}

local function get_member_names(class)
	local pub_var = {}
	local pub_fun = {}
	local pri_var = {}
	local pri_fun = {}
	local has = {}

	while class do
		for k, v in pairs(class) do
			if not has[k] then
				if k:sub(1, 1) == "_" then
					if type(v) == "function" then
						pri_fun[#pri_fun + 1] = k
					else
						pri_var[#pri_var + 1] = k
					end
				else
					if type(v) == "function" then
						pub_fun[#pub_fun + 1] = k
					else
						pub_var[#pub_var + 1] = k
					end
				end

				has[k] = true
			end
		end

		class = getmetatable(class) or nil
	end

	return pub_var, pub_fun, pri_var, pri_fun
end

local function add_member_names(names, output)
	table.sort(names)

	for i = 1, #names do
		output[#output + 1] = "\n\t\t"
		output[#output + 1] = names[i]
	end
end

function Inspect.format_member_names(class)
	local pub_var, pub_fun, pri_var, pri_fun = get_member_names(class)
	local output = {}

	if pub_var[1] or pub_fun[1] then
		output[#output + 1] = "\nPUBLIC:"

		if pub_var[1] then
			output[#output + 1] = "\n\tVARIABLES:"
			add_member_names(pub_var, output)
		end

		if pub_fun[1] then
			output[#output + 1] = "\n\tFUNCTIONS:"
			add_member_names(pub_fun, output)
		end
	end

	if pri_var[1] or pri_fun[1] then
		output[#output + 1] = "\nPRIVATE:"

		if pri_var[1] then
			output[#output + 1] = "\n\tVARIABLES:"
			add_member_names(pri_var, output)
		end

		if pri_fun[1] then
			output[#output + 1] = "\n\tFUNCTIONS:"
			add_member_names(pri_fun, output)
		end
	end

	return table.concat(output)
end
