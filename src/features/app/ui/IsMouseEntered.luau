local GuiService = game:GetService("GuiService")
local UserInputService = game:GetService("UserInputService")

return function(guiObject: GuiObject): boolean
	local mouseLocation = UserInputService:GetMouseLocation() - GuiService:GetGuiInset()
	local position = guiObject.AbsolutePosition
	local size = guiObject.AbsoluteSize

	local insideX = mouseLocation.X >= position.X and mouseLocation.X <= position.X + size.X
	local insideY = mouseLocation.Y >= position.Y and mouseLocation.Y <= position.Y + size.Y

	return insideX and insideY
end
