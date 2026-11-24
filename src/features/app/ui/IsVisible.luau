return function(guiObject: GuiObject)
	local current = guiObject :: Instance?

	while current do
		if current:IsA("ScreenGui") then
			if not current.Enabled then
				return false
			end
		elseif current:IsA("GuiObject") then
			if not current.Visible then
				return false
			end
		end

		current = current.Parent
	end

	return true
end
