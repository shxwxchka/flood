local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextService = game:GetService("TextService")

local React = require(ReplicatedStorage.Packages.React)

local function resizeOutputBox(outputBoxRef: React.Ref<TextBox>, outputBoxPaddingRef: React.Ref<UIPadding>)
	local paddingTop = outputBoxPaddingRef.current.PaddingTop.Offset
	local paddingBottom = outputBoxPaddingRef.current.PaddingBottom.Offset
	local paddingLeft = outputBoxPaddingRef.current.PaddingLeft.Offset
	local paddingRight = outputBoxPaddingRef.current.PaddingRight.Offset

	local width = math.max(1, outputBoxRef.current.AbsoluteSize.X - paddingLeft - paddingRight)

	local textBoundsParams = Instance.new("GetTextBoundsParams")
	textBoundsParams.Text = string.gsub(outputBoxRef.current.Text, "<[^>]->", "")
	textBoundsParams.Font = outputBoxRef.current.FontFace
	textBoundsParams.Size = outputBoxRef.current.TextSize
	textBoundsParams.Width = width

	local textBounds = TextService:GetTextBoundsAsync(textBoundsParams)
	local height = math.ceil(textBounds.Y) + paddingTop + paddingBottom

	outputBoxRef.current.Size = UDim2.new(1, 0, 0, height)
end

return function(outputBoxRef: React.Ref<TextBox>, outputBoxPaddingRef: React.Ref<UIPadding>)
	React.useEffect(function()
		local function update()
			resizeOutputBox(outputBoxRef, outputBoxPaddingRef)
		end

		update()

		local textChanged = outputBoxRef.current:GetPropertyChangedSignal("Text"):Connect(update)
		local sizeChanged = outputBoxRef.current:GetPropertyChangedSignal("AbsoluteSize"):Connect(update)

		return function()
			textChanged:Disconnect()
			sizeChanged:Disconnect()
		end
	end, {})
end
