local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local React = require(ReplicatedStorage.Packages.React)
local ColorizeText = require(ReplicatedStorage.Source.Core.UI.ColorizeText)
local EscapeText = require(ReplicatedStorage.Source.Core.UI.EscapeText)
local OutputServiceClient = require(ReplicatedStorage.Source.Features.Output.OutputServiceClient)

local COLORS = {
	MESSAGE_OUTPUT = Color3.fromRGB(255, 255, 255),
	MESSAGE_WARN = Color3.fromRGB(255, 222, 102),
	MESSAGE_ERROR = Color3.fromRGB(255, 90, 90),
}

return function(setOutputBoxText: (string) -> ())
	React.useEffect(function()
		if not RunService:IsRunning() then
			return function() end
		end

		local messageOut = OutputServiceClient.messageOut:Connect(function(message, messageType)
			setOutputBoxText(function(oldOutputBoxText)
				local color = COLORS.MESSAGE_OUTPUT

				if messageType == "warn" then
					color = COLORS.MESSAGE_WARN
				elseif messageType == "error" then
					color = COLORS.MESSAGE_ERROR
				end

				local formattedMessage = ColorizeText(EscapeText(message), color)

				return if oldOutputBoxText == "" then formattedMessage else oldOutputBoxText .. "\n" .. formattedMessage
			end)
		end)

		return function()
			messageOut:Disconnect()
		end
	end, {})
end
