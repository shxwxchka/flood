return function(guiObject: GuiObject)
	local currentGuiObject = guiObject :: Instance?

	while currentGuiObject do
		if currentGuiObject:IsA("ScreenGui") then
			if not currentGuiObject.Enabled then
				return false
			end
		elseif currentGuiObject:IsA("GuiObject") then
			if not currentGuiObject.Visible then
				return false
			end
		end

		currentGuiObject = currentGuiObject.Parent
	end

	return true
end
