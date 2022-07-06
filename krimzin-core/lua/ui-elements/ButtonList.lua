setfenv(1, KrimzinCore)

ButtonList = class()
ButtonList.MOVE_DELAY = 0.4

-- PUBLIC:

function ButtonList:init(main_panel, buttons, index)
	assert(buttons[1], "Tried to initialize a ButtonList with no buttons")

	self._main_panel = main_panel
	self._buttons = buttons
	self._index = index
	self._move_up = false
	self._move_down = false
	self._move_time = 0
end

function ButtonList:delete()
	self._main_panel:parent():remove(self._main_panel)
end

function ButtonList:update(t, dt)
	local direction = 0

	if self._move_up then
		direction = direction - 1
	end

	if self._move_down then
		direction = direction + 1
	end

	if (direction ~= 0) and ((t - self._move_time) >= self.MOVE_DELAY) then
		self._move_time = t
		self:_move(direction)
	end
end

function ButtonList:main_panel()
	return self._main_panel
end

function ButtonList:mouse_moved(x, y)
	if self._main_panel:inside(x, y) then
		local button = self._buttons[self._index]

		if button:main_panel():inside(x, y) or self:_select_button_at(x, y) then
			return true, "link"
		end
	end

	return false, "arrow"
end

function ButtonList:mouse_pressed(mouse_button, x, y)
	local button = self._buttons[self._index]

	if button:main_panel():inside(x, y) and (mouse_button == Idstring("0")) then
		button:press()
	end
end

function ButtonList:set_move_up(state)
	self._move_up = state

	if state then
		self._move_time = 0
	end
end

function ButtonList:set_move_down(state)
	self._move_down = state

	if state then
		self._move_time = 0
	end
end

function ButtonList:press()
	self._buttons[self._index]:press()
end

-- PRIVATE:

function ButtonList:_move(direction)
	if self._buttons[2] then
		local index = (self._index + direction - 1) % #self._buttons + 1
		self:_select_button(index)
	end
end

function ButtonList:_select_button_at(x, y)
	for i, button in ipairs(self._buttons) do
		if button:main_panel():inside(x, y) then
			self:_select_button(i)
			return true
		end
	end

	return false
end

function ButtonList:_select_button(index)
	self._buttons[self._index]:deselect()
	self._buttons[index]:select()
	self._index = index
end
