local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Networker = require(ReplicatedStorage.Packages.Networker)
local Signal = require(ReplicatedStorage.Packages.Signal)
local FilterMessageType = require(ReplicatedStorage.Source.Features.Output.Modules.FilterMessageType)

local OutputServiceServer = {}

function OutputServiceServer.init(self: OutputServiceServer)
	self.networker = Networker.server.new("OutputService", self, {})
	self.messageOut = Signal.new()
end

function OutputServiceServer.message(self: OutputServiceServer, message: string, messageType: string)
	local filteredMessageType = FilterMessageType(messageType)

	print(message)

	self.messageOut:Fire(message, filteredMessageType)
end

function OutputServiceServer.messageOnClient(
	self: OutputServiceServer,
	player: Player,
	message: string,
	messageType: string
)
	self.networker:fire(player, "message", message, messageType)
end

type OutputServiceServer = typeof(OutputServiceServer) & {
	networker: Networker.Server,
	messageOut: Signal.Signal<string, string>,
}

return OutputServiceServer :: OutputServiceServer
