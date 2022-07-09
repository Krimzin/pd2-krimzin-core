setfenv(1, KrimzinCore)

TextInput = class()

-- PUBLIC:

function TextInput:init(main_panel, placeholder_text, input_text, caret_rect, max_letters)
	self._main_panel = main_panel
	self._placeholder_text = placeholder_text
	self._input_text = input_text
	self._caret_rect = caret_rect
	self._max_letters = max_letters
	self._action_map = self:_new_action_map()
	self._thread = nil
end

function TextInput:delete()
	self._main_panel:parent():remove(self._main_panel)
end

function TextInput:update(t, dt)
	if self._thread then
		coroutine.resume(self._thread, dt)
	end
end

function TextInput:main_panel()
	return self._main_panel
end

function TextInput:input_str()
	return self._input_text:text()
end

function TextInput:text_entered(str)
	if #self._input_text:text() < self._max_letters then
		self._input_text:replace_text(str)
		self:_on_text_changed()
	end
end

function TextInput:key_pressed(key)
	self:_run_action(key:key())
	self._thread = coroutine.create(function () self:_repeat_action(key:key()) end)
end

function TextInput:key_released(key)
	self._thread = nil
end

-- PRIVATE:

function TextInput:_new_action_map()
	return {[Idstring("backspace"):key()] = function () self:_backspace() end}
end

function TextInput:_run_action(key)
	local action = self._action_map[key]

	if action then
		action()
	end
end

function TextInput:_repeat_action(key)
	wait(0.6)

	while true do
		self:_run_action(key)
		wait(0.03)
	end
end

function TextInput:_backspace()
	local s, e = self._input_text:selection()

	if (s > 0) and (s == e) then
		self._input_text:set_selection(s - 1, e)
	end

	self._input_text:replace_text("")
	self:_on_text_changed()
end

function TextInput:_on_text_changed()
	self:_update_caret()
	self._placeholder_text:set_visible(#self._input_text:text() == 0)
end

function TextInput:_update_caret()
	local s, e = self._input_text:selection()
	local x, y = 0, 0

	if (s == 0) and (e == 0) then
		x, y = self._input_text:world_position()
	else
		x, y = self._input_text:selection_rect()
	end

	self._caret_rect:set_world_position(x, y)
end
