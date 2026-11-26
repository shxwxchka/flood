local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Charm = require(ReplicatedStorage.Packages.Charm)
local OutputServiceServer = require(ServerScriptService.Features.Output.OutputServiceServer)
local RegistryTypesServer = require(script.Parent.RegistryTypesServer)
local Networker = require(ReplicatedStorage.Packages.Networker)
local RegistryServiceUtils = require(ReplicatedStorage.Source.Features.Registry.RegistryServiceUtils)
local RegistryTypes = require(ReplicatedStorage.Source.Features.Registry.RegistryTypes)

local builtInCommands = ServerScriptService.Features.Registry.Modules.BuiltInCommands

type Command = RegistryTypesServer.Command
type CommandCallback = RegistryTypesServer.CommandCallback
type CommandCallbackConfig = RegistryTypesServer.CommandCallbackConfig

type RegisterCommandConfig = {
	name: string,
	callback: CommandCallback,
}

type RunCommandConfig = {
	name: string,
	args: { string }?,
	argsString: string?,
	runPlayer: Player?,
}

type AskRunCommandOnServerConfig = RegistryTypes.AskRunCommandOnServerConfig

local RegistryServiceServer = {}

function RegistryServiceServer.init(self: RegistryServiceServer)
	self.networker = Networker.server.new("RegistryService", self, {
		self.getServerCommandNames,
		self.askRunCommandOnServer,
	})

	self.commands = {}
	self.commandNames = Charm.atom({})

	Charm.subscribe(self.commandNames, function()
		self:updateServerCommandNames()
	end)

	for _, commandModule in builtInCommands:GetChildren() :: { ModuleScript } do
		local CommandModule = require(commandModule) :: () -> ()

		CommandModule()
	end
end

function RegistryServiceServer.registerCommand(self: RegistryServiceServer, registerConfig: RegisterCommandConfig)
	table.insert(self.commands, {
		name = registerConfig.name,
		callback = function(callbackConfig: CommandCallbackConfig)
			registerConfig.callback(callbackConfig)
		end,
	})

	local newCommandNames = table.clone(self.commandNames())

	table.insert(newCommandNames, registerConfig.name)

	self.commandNames(newCommandNames)
end

function RegistryServiceServer.runCommand(self: RegistryServiceServer, runConfig: RunCommandConfig)
	local targetCommand: Command?

	for _, command in self.commands do
		if command.name == runConfig.name then
			targetCommand = command
			break
		end
	end

	if targetCommand then
		targetCommand.callback({
			name = runConfig.name,
			args = runConfig.args,
			argsString = runConfig.argsString,
			runPlayer = runConfig.runPlayer,
		})
	else
		OutputServiceServer:messageOnClient(
			runConfig.runPlayer,
			string.format(RegistryServiceUtils.UNKNOWN_COMMAND_MESSAGE, runConfig.name)
		)
	end
end

function RegistryServiceServer.askRunCommandOnServer(
	self: RegistryServiceServer,
	player: Player,
	askRunConfig: AskRunCommandOnServerConfig
)
	if typeof(askRunConfig) ~= "table" then
		return
	end

	if typeof(askRunConfig.name) ~= "string" then
		return
	end

	if askRunConfig.args ~= nil and typeof(askRunConfig.args) ~= "table" then
		return
	end

	askRunConfig.argsString = nil

	if askRunConfig.args then
		for i, word in askRunConfig.args do
			if typeof(word) == "string" then
				askRunConfig.argsString = i == 1 and word or askRunConfig.argsString .. " " .. word
			end
		end
	end

	if askRunConfig.args then
		for i, arg in askRunConfig.args do
			if typeof(arg) ~= "string" then
				table.remove(askRunConfig.args, i)
			end
		end
	end

	self:runCommand({
		name = askRunConfig.name,
		args = askRunConfig.args,
		argsString = askRunConfig.argsString,
		runPlayer = player,
	})
end

function RegistryServiceServer.updateServerCommandNames(self: RegistryServiceServer)
	self.networker:fireAll("updateServerCommandNames", self.commandNames())
end

function RegistryServiceServer.getServerCommandNames(self: RegistryServiceServer)
	return self.commandNames()
end

type RegistryServiceServer = typeof(RegistryServiceServer) & {
	networker: Networker.Server,
	commands: { Command },
	commandNames: Charm.Atom<{ string }>,
}

return RegistryServiceServer :: RegistryServiceServer
