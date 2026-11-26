local ReplicatedStorage = game:GetService("ReplicatedStorage")

local OutputServiceClient = require(ReplicatedStorage.Source.Features.Output.OutputServiceClient)
local RegistryServiceClient = require(ReplicatedStorage.Source.Features.Registry.RegistryServiceClient)

return function()
	RegistryServiceClient:registerCommand({
		name = "echo",
		callback = function(callbackConfig)
			local text = ""

			for i, word in callbackConfig.args do
				text = i == 1 and word or text .. " " .. word
			end

			OutputServiceClient:message(text)
		end,
	})
end
