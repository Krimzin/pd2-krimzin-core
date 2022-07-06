local localization_path = ModPath .. "localization/"
Hooks:Add("LocalizationManagerPostInit", "KrimzinCore.load_localization", function (self)
	KrimzinCore.load_localization(self, localization_path)
end)
