return function(args: { string }, from: number?)
	local text = nil

	for i = from or 1, #args do
		if i == from then
			text = args[i]
		else
			text = (text or "") .. " " .. args[i]
		end
	end

	return text
end
