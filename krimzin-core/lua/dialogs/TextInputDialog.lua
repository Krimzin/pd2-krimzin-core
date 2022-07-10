local ModPath = ModPath
KrimzinCore.require(ModPath .. "lua/dialogs/Dialog.lua")
KrimzinCore.require(ModPath .. "lua/ui-elements/TextInput.lua")
KrimzinCore.require(ModPath .. "lua/ui-elements/TextButton.lua")
KrimzinCore.require(ModPath .. "lua/ui-elements/ButtonList.lua")

setfenv(1, KrimzinCore)

TextInputDialog = class(Dialog)

-- PUBLIC:

function TextInputDialog:init(manager, title_str, placeholder_str, on_confirm)
	Dialog.init(self, manager, {})

	self._ws = manager:_get_ws()
	local layer = tweak_data.gui.DIALOG_LAYER
	self._main_panel = self._ws:panel():panel({layer = layer})
	self._text_input = self:_new_text_input(self._main_panel, placeholder_str)
	self._button_list = self:_new_button_list(self._main_panel, self:_new_button_configs())
	self._controller = managers.controller:create_controller()
	self._mouse_params = self:_new_mouse_params()
	self._enabled = false
	self._on_confirm = on_confirm

	self:_place_panels(title_str)
	self:_set_alpha(0)

	self._controller:disable()
	self:_bind_events()
end

function TextInputDialog:delete()
	self:_disable_input()
	self._controller:destroy()
	self._main_panel:parent():remove(self._main_panel)
	Dialog.delete(self)
end

function TextInputDialog:update(t, dt)
	Dialog.update(self, t, dt)
	self._text_input:update(t, dt)
	self._button_list:update(t, dt)
end

function TextInputDialog:confirm()
	self._on_confirm(self._text_input:input_str())
	self:fade_out_close()
end

function TextInputDialog:fade_out_close()
	self:_disable_input()
	Dialog.fade_out_close(self)
end

-- PRIVATE:

function TextInputDialog:_new_title_text(parent_panel, title_str)
	local title_text = parent_panel:text({
		text = title_str,
		font = tweak_data.menu.pd2_large_font,
		font_size = 28,
		color = tweak_data.screen_colors.text,
		layer = 1
	})
	local _, _, text_w, text_h = title_text:text_rect()
	title_text:set_size(text_w, text_h)

	return title_text
end

function TextInputDialog:_new_text_input(parent_panel, placeholder_str)
	local font = tweak_data.menu.pd2_medium_font
	local font_size = tweak_data.menu.pd2_medium_font_size
	local color = tweak_data.screen_colors.text
	local main_panel = parent_panel:panel({
		w = parent_panel:w() - 20,
		h = 24,
		layer = 1
	})
	local placeholder_text = main_panel:text({
		text = placeholder_str,
		font = font,
		font_size = font_size,
		color = color:with_alpha(0.35)
	})
	local input_text = main_panel:text({
		text = "",
		font = font,
		font_size = font_size,
		color = color
	})
	local caret_rect = main_panel:rect({
		w = 2,
		color = color
	})
	local max_letters = 30

	caret_rect:animate(self._blink)

	return TextInput:new(main_panel, placeholder_text, input_text, caret_rect, max_letters)
end

function TextInputDialog._blink(panel)
	while true do
		panel:hide()
		wait(0.3)
		panel:show()
		wait(0.3)
	end
end

function TextInputDialog:_new_button_configs()
	return {
		{
			text_str = managers.localization:to_upper_text("KrimzinCore.confirm"),
			on_press = function () self:confirm() end
		},
		{
			text_str = managers.localization:to_upper_text("KrimzinCore.cancel"),
			on_press = function () self:fade_out_close() end,
			is_selected = true
		}
	}
end

function TextInputDialog:_new_button_list(parent_panel, button_configs)
	local w = 0
	local h = 0
	local main_panel = parent_panel:panel({layer = 1})
	local buttons = {}
	local index = 1

	for i, config in ipairs(button_configs) do
		local button = self:_new_button(main_panel, config.text_str, config.on_press)
		local button_panel = button:main_panel()
		w = math.max(w, button_panel:w())
		button_panel:set_top(h)
		h = button_panel:bottom()

		if config.is_selected then
			button:select()
			index = i
		end

		table.insert(buttons, button)
	end

	for _, button in ipairs(buttons) do
		button:main_panel():set_w(w)
	end

	main_panel:set_size(w, h)

	return ButtonList:new(main_panel, buttons, index)
end

function TextInputDialog:_new_button(parent_panel, text_str, on_press)
	local main_panel = parent_panel:panel()
	local text = main_panel:text({
		text = text_str,
		font = tweak_data.menu.pd2_medium_font,
		font_size = tweak_data.menu.pd2_medium_font_size,
		color = tweak_data.screen_colors.button_stage_3,
		halign = "right"
	})
	local select_rect = main_panel:rect({
		color = tweak_data.screen_colors.button_stage_3,
		alpha = 0.3,
		halign = "grow",
		visible = false
	})
	local colors = {
		select = tweak_data.screen_colors.button_stage_2,
		deselect = tweak_data.screen_colors.button_stage_3
	}

	local _, _, text_w, text_h = text:text_rect()
	text:set_size(text_w, text_h)
	text:set_right(main_panel:w())
	
	local w = math.max(text_w + 40, 160)
	main_panel:set_size(w, text_h)
	select_rect:set_size(w, text_h)

	return TextButton:new(main_panel, text, select_rect, colors, on_press)
end

function TextInputDialog:_place_panels(title_str)
	local x = 10
	local y = 10
	local title_text = self:_new_title_text(self._main_panel, title_str)
	title_text:set_position(x, y)

	y = title_text:bottom() + 10
	local text_input_panel = self._text_input:main_panel()
	text_input_panel:set_position(x, y)

	local main_w = 540
	local button_list_panel = self._button_list:main_panel()
	x = main_w - button_list_panel:w() - 10
	y = text_input_panel:bottom() + 10
	button_list_panel:set_position(x, y)

	local main_h = button_list_panel:bottom() + 10
	self._main_panel:set_size(main_w, main_h)
	self._main_panel:set_world_center(self._ws:panel():world_center())
	self._main_panel:rect({color = tweak_data.screen_colors.dark_bg})
	BoxGuiObject:new(self._main_panel, {sides = {1, 1, 1, 1}})
end

function TextInputDialog:_new_mouse_params()
	return {
		id = managers.mouse_pointer:get_id(),
		mouse_move = function (panel, x, y) self:_mouse_moved(x, y) end,
		mouse_press = function (panel, button, x, y) self:_mouse_pressed(button, x, y) end
	}
end

function TextInputDialog:_mouse_moved(x, y)
	local in_use, cursor_type = self._button_list:mouse_moved(x, y)
	managers.mouse_pointer:set_pointer_image(in_use and cursor_type or "arrow")
end

function TextInputDialog:_mouse_pressed(button, x, y)
	self._button_list:mouse_pressed(button, x, y)
end

function TextInputDialog:_bind_events()
	self._main_panel:enter_text(function (panel, str) self._text_input:text_entered(str) end)
	self._main_panel:key_press(function (panel, key) self._text_input:key_pressed(key) end)
	self._main_panel:key_release(function (panel, key) self._text_input:key_released(key) end)

	self._controller:add_trigger("menu_up", function () self._button_list:set_move_up(true) end)
	self._controller:add_release_trigger("menu_up", function () self._button_list:set_move_up(false) end)
	self._controller:add_trigger("menu_down", function () self._button_list:set_move_down(true) end)
	self._controller:add_release_trigger("menu_down", function () self._button_list:set_move_down(false) end)
	self._controller:add_trigger("confirm", function () self._button_list:press() end)
	self._controller:add_trigger("toggle_menu", function () self:fade_out_close() end)
end

function TextInputDialog:_enable_input()
	if self._enabled then return end

	self._ws:connect_keyboard(Input:keyboard())
	managers.mouse_pointer:use_mouse(self._mouse_params)
	self._controller:enable()
	self._enabled = true
end

function TextInputDialog:_disable_input()
	if not self._enabled then return end

	self._ws:disconnect_keyboard()
	managers.mouse_pointer:remove_mouse(self._mouse_params.id)
	self._controller:disable()
	self._enabled = false
end

function TextInputDialog:_set_alpha(alpha)
	Dialog._set_alpha(self, alpha)
	self._main_panel:set_alpha(alpha)
end

function TextInputDialog:_on_ready()
	self:_enable_input()
end
