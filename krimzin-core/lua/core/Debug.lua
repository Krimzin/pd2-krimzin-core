setfenv(1, KrimzinCore)

Debug = {}

local function value_output(value, output) 
	if type(value) == "string" then
		output[#output + 1] = '"'
		output[#output + 1] = value
		output[#output + 1] = '"'
	else
		output[#output + 1] = tostring(value)
	end
end

local function table_output(tbl, output, has, tabs)
	has[tbl] = true
	output[#output + 1] = tostring(tbl)

	if next(tbl) then
		output[#output + 1] = " {\n"
		local next_tabs = tabs .. "\t"

		for k, v in pairs(tbl) do
			output[#output + 1] = next_tabs
			value_output(k, output)
			output[#output + 1] = " = "

			if (type(v) == "table") and not has[v] then
				table_output(v, output, has, next_tabs)
			else
				value_output(v, output)
			end

			output[#output + 1] = "\n"
		end

		output[#output + 1] = tabs
		output[#output + 1] = "}"
	else
		output[#output + 1] = " {}"
	end
end

function Debug.to_string(value)
	local output = {}

	if type(value) == "table" then
		local has = {}
		local tabs = ""
		table_output(value, output, has, tabs)
	else
		value_output(value, output)
	end

	return table.concat(output)
end

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
		output[#output + 1] = "\t\t" .. names[i]
	end
end

function Debug.format_member_names(class)
	local pub_var, pub_fun, pri_var, pri_fun = get_member_names(class)
	local output = {}

	if pub_var[1] or pub_fun[1] then
		output[#output + 1] = "PUBLIC:"

		if pub_var[1] then
			output[#output + 1] = "\tVARIABLES:"
			add_member_names(pub_var, output)
		end

		if pub_fun[1] then
			output[#output + 1] = "\tFUNCTIONS:"
			add_member_names(pub_fun, output)
		end
	end

	if pri_var[1] or pri_fun[1] then
		output[#output + 1] = "PRIVATE:"

		if pri_var[1] then
			output[#output + 1] = "\tVARIABLES:"
			add_member_names(pri_var, output)
		end

		if pri_fun[1] then
			output[#output + 1] = "\tFUNCTIONS:"
			add_member_names(pri_fun, output)
		end
	end

	return table.concat(output, "\n")
end
