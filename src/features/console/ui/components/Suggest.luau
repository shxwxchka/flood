local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)

local e = React.createElement

type SuggestProps = {
	suggest: string,
	selectedSuggest: string?,
	mouseEnter: () -> (),
	mouseButton1Up: () -> (),
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
	local suggestColor, setSuggestColor = React.useState(COLORS.SUGGEST)
	local suggestTextColor, setSuggestTextColor = React.useState(COLORS.SUGGEST_TEXT)

	local function selected()
		setSuggestColor(COLORS.SUGGEST_SELECTED)
		setSuggestTextColor(COLORS.SUGGEST_TEXT_SELECTED)
	end

	local function deselected()
		setSuggestColor(COLORS.SUGGEST)
		setSuggestTextColor(COLORS.SUGGEST_TEXT)
	end

	React.useEffect(function()
		if props.suggest == props.selectedSuggest then
			selected()
		else
			deselected()
		end
	end, { props.selectedSuggest })

	return e("Frame", {
		Size = UDim2.fromOffset(14, 14),
		BackgroundColor3 = suggestColor,
		BackgroundTransparency = 0,
		BorderSizePixel = 0,
		AutomaticSize = Enum.AutomaticSize.X,
	}, {
		TextLabel = e("TextLabel", {
			Size = UDim2.fromOffset(0, 14),
			BackgroundTransparency = 1,
			Text = props.suggest,
			TextColor3 = suggestTextColor,
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
				selected()
				props.mouseEnter()
			end,
			[React.Event.MouseLeave] = function()
				deselected()
			end,
			[React.Event.MouseButton1Up] = function()
				props.mouseButton1Up()
			end,
		}),
	})
end
