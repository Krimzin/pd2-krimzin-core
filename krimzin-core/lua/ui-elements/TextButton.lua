setfenv(1, KrimzinCore)

TextButton = class()

function TextButton:init(main_panel, text, select_rect, colors, on_press)
	self._main_panel = main_panel
	self._text = text
	self._select_rect = select_rect
	self._colors = colors
	self._on_press = on_press
end

function TextButton:delete()
	self._main_panel:parent():remove(self._main_panel)
end

function TextButton:main_panel()
	return self._main_panel
end

function TextButton:select()
	self._text:set_color(self._colors.select)
	self._select_rect:show()
	managers.menu:post_event("highlight")
end

function TextButton:deselect()
	self._text:set_color(self._colors.deselect)
	self._select_rect:hide()
end

function TextButton:press()
	self._on_press()
end
