local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Charm = require(ReplicatedStorage.Packages.Charm)
local RegistryServiceUtils = require(script.Parent.RegistryServiceUtils)
local RegistryTypes = require(script.Parent.RegistryTypes)
local RegistryTypesClient = require(script.Parent.RegistryTypesClient)
local Networker = require(ReplicatedStorage.Packages.Networker)
local OutputServiceClient = require(ReplicatedStorage.Source.Features.Output.OutputServiceClient)

local builtInCommands = ReplicatedStorage.Source.Features.Registry.Modules.BuiltInCommands

type Command = RegistryTypesClient.Command
type CommandCallback = RegistryTypesClient.CommandCallback

type RegisterCommandConfig = {
	name: string,
	callback: CommandCallback,
}

type RunCommandConfig = {
	name: string,
	args: { string }?,
	argsString: string?,
}

type AskRunCommandOnServerConfig = RegistryTypes.AskRunCommandOnServerConfig

local RegistryServiceClient = {}

function RegistryServiceClient.init(self: RegistryServiceClient)
	self.networker = Networker.client.new("RegistryService", self)
	self.commands = {}
	self.serverCommandNames = Charm.atom(self:getServerCommandNames())

	for _, commandModule in builtInCommands:GetChildren() :: { ModuleScript } do
		local CommandModule = require(commandModule) :: () -> ()

		CommandModule()
	end
end

function RegistryServiceClient.registerCommand(self: RegistryServiceClient, registerConfig: RegisterCommandConfig)
	table.insert(self.commands, {
		name = registerConfig.name,
		callback = function(name: string, args: { string }?, argsString: string?)
			registerConfig.callback(name, args, argsString)
		end,
	})
end

function RegistryServiceClient.runCommand(self: RegistryServiceClient, runConfig: RunCommandConfig)
	local targetCommand: Command?
	local hasServerSide = table.find(self.serverCommandNames(), runConfig.name) and true or false

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
		})
	elseif not hasServerSide then
		OutputServiceClient:message(string.format(RegistryServiceUtils.UNKNOWN_COMMAND_MESSAGE, runConfig.name))
	end

	if hasServerSide then
		self:askRunCommandOnServer({
			name = runConfig.name,
			args = runConfig.args,
			argsString = runConfig.argsString,
		})
	end
end

function RegistryServiceClient.runCommandByInputBoxText(self: RegistryServiceClient, inputText: string)
	OutputServiceClient:message("] " .. inputText)

	local formattedText = string.gsub(string.match(inputText, "^%s*(.-)%s*$") or "", "%s+", " ")

	if formattedText == "" then
		return
	end

	local inputTextSplit = string.split(formattedText, " ")
	local name = inputTextSplit[1]
	local args = table.clone(inputTextSplit)

	table.remove(args, 1)

	for i = #args, 1, -1 do
		if args[i] == "" then
			table.remove(args, i)
		end
	end

	local argsString = ""

	for i, arg in args do
		argsString = i == 1 and arg or argsString .. " " .. arg
	end

	self:runCommand({
		name = name,
		args = args,
		argsString = argsString,
	})
end

function RegistryServiceClient.askRunCommandOnServer(
	self: RegistryServiceClient,
	askRunConfig: AskRunCommandOnServerConfig
)
	self.networker:fire("askRunCommandOnServer", askRunConfig)
end

function RegistryServiceClient.updateServerCommandNames(self: RegistryServiceClient, serverCommandNames: { string })
	self.serverCommandNames(serverCommandNames)
end

function RegistryServiceClient.getServerCommandNames(self: RegistryServiceClient)
	return self.networker:fetch("getServerCommandNames") :: { string }
end

type RegistryServiceClient = typeof(RegistryServiceClient) & {
	networker: Networker.Client,
	commands: { Command },
	serverCommandNames: Charm.Atom<{ string }>,
}

return RegistryServiceClient :: RegistryServiceClient
