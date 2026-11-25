return function(text: string, color: Color3)
	local r, g, b = color.R * 255, color.G * 255, color.B * 255

	return `<font color="rgb({r}, {g}, {b})">{text}</font>`
end
