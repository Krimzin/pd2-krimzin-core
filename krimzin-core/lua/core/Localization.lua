setfenv(1, KrimzinCore)

function load_localization(manager, path)
	local files = file.GetFiles(path)
	local key = SystemInfo:language():key()
	local file_name = "english.txt"

	for i = 1, #files do
		local name = files[i]

		if Idstring(name:match("^(.*).txt$")):key() == key then
			file_name = name
			break
		end
	end

	path = path .. file_name

	if io.file_is_readable(path) then
		manager:load_localization_file(path)
	end
end
