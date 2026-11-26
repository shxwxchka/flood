local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)

local e = React.createElement

type SuggestProps = {
	suggest: string,
	selectedSuggest: string?,
	selectTrigger: () -> (),
}

local COLORS = {
	SUGGEST = Color3.fromRGB(234, 234, 234),
	SUGGEST_TEXT = Color3.fromRGB(79, 79, 79),
	SUGGEST_SELECTED = Color3.fromRGB(133, 184, 241),
	SUGGEST_TEXT_SELECTED = Color3.fromRGB(255, 255, 255),
}

local FONTS = {
	RobotoMonoLight = Font.new(
		"rbxasset://fonts/families/RobotoMono.json",
		Enum.FontWeight.Light,
		Enum.FontStyle.Normal
	),
}

return function(props: SuggestProps)
	return e("Frame", {
		Size = UDim2.fromOffset(14, 14),
		BackgroundColor3 = props.selectedSuggest == props.suggest and COLORS.SUGGEST_SELECTED or COLORS.SUGGEST,
		BackgroundTransparency = 0,
		BorderSizePixel = 0,
		AutomaticSize = Enum.AutomaticSize.X,
	}, {
		TextLabel = e("TextLabel", {
			Size = UDim2.fromOffset(0, 14),
			BackgroundTransparency = 1,
			Text = props.suggest,
			TextColor3 = Color3.fromRGB(79, 79, 79),
			TextSize = 13,
			FontFace = FONTS.RobotoMonoLight,
			AutomaticSize = Enum.AutomaticSize.X,
		}, {
			Padding = e("UIPadding", {
				PaddingLeft = UDim.new(0, 4),
				PaddingRight = UDim.new(0, 8),
			}),
		}),
		Button = e("TextButton", {
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			TextTransparency = 1,
			[React.Event.MouseEnter] = function()
				props.selectTrigger()
			end,
			[React.Event.MouseButton1Up] = function() end,
		}),
	})
end
