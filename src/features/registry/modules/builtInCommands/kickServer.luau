local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local ArgsToText = require(ReplicatedStorage.Source.Features.Registry.Modules.ArgsToText)
local OutputServiceServer = require(ServerScriptService.Features.Output.OutputServiceServer)
local RegistryServiceServer = require(ServerScriptService.Features.Registry.RegistryServiceServer)

local DEFAULT_MESSAGE = "Kicked from server"

return function()
	RegistryServiceServer:registerCommand({
		name = "kick",
		callback = function(callbackConfig)
			local args = callbackConfig.args
			local runPlayer = callbackConfig.runPlayer
			local playerName = args and args[1]
			local message = args and ArgsToText(args, 2)

			if args and playerName then
				local player = Players:FindFirstChild(playerName) :: Player?

				if player then
					player:Kick(message or DEFAULT_MESSAGE)

					if runPlayer then
						OutputServiceServer:messageOnClient(
							runPlayer,
							"Dropped " .. playerName .. " from server (" .. (message or DEFAULT_MESSAGE) .. ")"
						)
					end
				else
					OutputServiceServer:messageOnClient(runPlayer, 'Player "' .. playerName .. '" not found')
				end
			else
				OutputServiceServer:messageOnClient(runPlayer, "Usage: kick <name>")
			end
		end,
	})
end
