local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Signal = require(ReplicatedStorage.Packages.Signal)

local OutputService = {}

function OutputService.init(self: OutputService)
	self.messageOut = Signal.new()
end

function OutputService.message(self: OutputService, message: string, messageType: string)
	local filteredMessageType = messageType == "warn" and "warn" or messageType == "error" and "error" or "output"

	self.messageOut:Fire(message, filteredMessageType)
end

type OutputService = typeof(OutputService) & {
	messageOut: Signal.Signal<string, string>,
}

return OutputService :: OutputService
