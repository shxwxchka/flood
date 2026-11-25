local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Networker = require(ReplicatedStorage.Packages.Networker)
local Signal = require(ReplicatedStorage.Packages.Signal)
local FilterMessageType = require(ReplicatedStorage.Source.Features.Output.Modules.FilterMessageType)

local OutputServiceClient = {}

function OutputServiceClient.init(self: OutputServiceClient)
	self.networker = Networker.client.new("OutputService", self)
	self.messageOut = Signal.new()
end

function OutputServiceClient.message(self: OutputServiceClient, message: string, messageType: string)
	local filteredMessageType = FilterMessageType(messageType)

	print(message)

	self.messageOut:Fire(message, filteredMessageType)
end

type OutputServiceClient = typeof(OutputServiceClient) & {
	networker: Networker.Server,
	messageOut: Signal.Signal<string, string>,
}

return OutputServiceClient :: OutputServiceClient
