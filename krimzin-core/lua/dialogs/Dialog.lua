core:import("SystemMenuManager")
local BaseDialog = SystemMenuManager.BaseDialog

setfenv(1, KrimzinCore)

Dialog = class(BaseDialog)
Dialog.FADE_DURATION = 0.2

-- PUBLIC:

function Dialog:init(manager, data)
	BaseDialog.init(self, manager, data)

	self._fullscreen_ws = managers.gui_data:create_fullscreen_workspace()
	local fullscreen_panel = self._fullscreen_ws:panel()
	local layer = tweak_data.gui.DIALOG_LAYER - 1
	self._background_blur = self:_new_background_blur(fullscreen_panel, layer)
	self._background_rect = self:_new_background_rect(fullscreen_panel, layer)
	self._fade_time = 0
	self._fade_method = nil
end

function Dialog:delete()
	managers.gui_data:destroy_workspace(self._fullscreen_ws)
	BaseDialog.close(self)
end

function Dialog:update(t, dt)
	if self._fade_method then
		self:_fade_method(t)
	end
end

function Dialog:show()
	self._manager:event_dialog_shown(self)
	return true
end

function Dialog:close()
	self:delete()
end

function Dialog:force_close()
	self:delete()
end

function Dialog:fade_in()
	self._fade_time = TimerManager:main():time()
	self._fade_method = self._fade_in
end

function Dialog:fade_out_close()
	self._fade_time = TimerManager:main():time()
	self._fade_method = self._fade_out
	managers.menu:post_event("prompt_exit")
end

-- PRIVATE:

function Dialog:_new_background_blur(parent_panel, layer)
	return parent_panel:bitmap({
		texture = "guis/textures/test_blur_df",
		render_template = "VertexColorTexturedBlur3D",
		color = Color.white,
		alpha = 0,
		w = parent_panel:w(),
		h = parent_panel:h(),
		layer = layer
	})
end

function Dialog:_new_background_rect(parent_panel, layer)
	return parent_panel:rect({
		color = Color.black,
		alpha = 0,
		layer = layer
	})
end

function Dialog:_fade_in(t)
	local alpha = math.min((t - self._fade_time) / self.FADE_DURATION, 1)
	self:_set_alpha(alpha)

	if alpha == 1 then
		self._fade_time = 0
		self._fade_method = nil
		self:_on_ready()
	end
end

function Dialog:_fade_out(t)
	local alpha = 1 - math.min((t - self._fade_time) / self.FADE_DURATION, 1)
	self:_set_alpha(alpha)

	if alpha == 0 then
		self._fade_time = 0
		self._fade_method = nil
		self:delete()
	end
end

function Dialog:_set_alpha(alpha)
	self._background_blur:set_alpha(alpha * 0.9)
	self._background_rect:set_alpha(alpha * 0.3)
end

function Dialog:_on_ready()
	-- Override in subclass.
end
