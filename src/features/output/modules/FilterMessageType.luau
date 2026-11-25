return function(messageType: string)
	return messageType == "warn" and "warn" or messageType == "error" and "error" or "output"
end
