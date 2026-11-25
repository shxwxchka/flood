local ServerScriptService = game:GetService("ServerScriptService")

local OutputServiceServer = require(ServerScriptService.Features.Output.OutputServiceServer)
local RegistryServiceServer = require(ServerScriptService.Features.Registry.RegistryServiceServer)

return function()
	RegistryServiceServer:registerCommand({
		name = "kill",
		callback = function(callbackConfig)
			local runPlayer = callbackConfig.runPlayer

			if runPlayer then
				local runCharacter = runPlayer.Character

				if runCharacter then
					local runHumanoid = runCharacter:FindFirstChild("Humanoid") :: Humanoid?

					if runHumanoid and runHumanoid.Health > 0 then
						runHumanoid.Health = 0

						OutputServiceServer:messageOnClient(runPlayer, runPlayer.Name .. " killed")
					end
				end
			end
		end,
	})
end
