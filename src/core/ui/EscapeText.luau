return function(rawText: string)
	local escapedText = rawText

	escapedText = string.gsub(escapedText, "&", "&amp;")
	escapedText = string.gsub(escapedText, "<", "&lt;")
	escapedText = string.gsub(escapedText, ">", "&gt;")
	escapedText = string.gsub(escapedText, '"', "&quot;")
	escapedText = string.gsub(escapedText, "'", "&apos;")

	return escapedText
end
