setfenv(1, KrimzinCore)

Table = {}

function Table.compare(a, b)
	for k, v in pairs(a) do
		if b[k] ~= v then
			return false
		end
	end

	for k, v in pairs(b) do
		if a[k] ~= v then
			return false
		end
	end

	return true
end

function Table.compare_unsorted_arrays(a, b)
	if #a ~= #b then
		return false
	end

	local a_map = {}

	for i = 1, #a do
		local v = a[i]
		a_map[v] = (a_map[v] or 0) + 1
	end

	local b_map = {}

	for i = 1, #b do
		local v = b[i]
		b_map[v] = (b_map[v] or 0) + 1
	end

	for v, n in pairs(a_map) do
		if n ~= b_map[v] then
			return false
		end
	end

	return true
end
