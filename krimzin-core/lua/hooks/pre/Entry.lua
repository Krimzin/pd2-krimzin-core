local ModPath = ModPath
KrimzinCore = setmetatable({}, {__index = _G})
KrimzinCore.MOD_PATH = ModPath

dofile(ModPath .. "lua/core/Functions.lua")
KrimzinCore.require(ModPath .. "lua/core/Localization.lua")
