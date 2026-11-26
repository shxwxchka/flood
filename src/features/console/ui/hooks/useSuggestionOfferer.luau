local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local React = require(ReplicatedStorage.Packages.React)
local RegistryServiceClient = require(ReplicatedStorage.Source.Features.Registry.RegistryServiceClient)

return function(
	inputBoxRef: React.Ref<TextBox>,
	inputBoxText: string,
	suggests: { string },
	setSuggests: ({ string }) -> (),
	selectedSuggest: string?,
	setSelectedSuggest: (string?) -> (),
	suggestContainerRef: React.Ref<Frame>
)
	React.useEffect(function()
		if not RunService:IsRunning() then
			return function() end
		end

		setSelectedSuggest(nil)

		if inputBoxText == "" then
			suggestContainerRef.current.Visible = false
		else
			local commandNames = {}

			for _, command in RegistryServiceClient.commands do
				table.insert(commandNames, command.name)
			end

			for _, serverCommandName in RegistryServiceClient.serverCommandNames() do
				table.insert(commandNames, serverCommandName)
			end

			local commandNamesToSuggest = {} :: { string }

			for _, commandName in commandNames do
				if commandName ~= inputBoxText and string.find(commandName, inputBoxText) then
					table.insert(commandNamesToSuggest, commandName)
				end
			end

			setSuggests(commandNamesToSuggest)

			suggestContainerRef.current.Visible = #commandNamesToSuggest > 0
		end

		return function() end
	end, { inputBoxText })

	React.useEffect(function()
		if not RunService:IsRunning() then
			return function() end
		end

		local inputBegan = UserInputService.InputBegan:Connect(function(input)
			if UserInputService:GetFocusedTextBox() ~= inputBoxRef.current then
				return
			end

			if input.KeyCode == Enum.KeyCode.Up then
				local currentIndex = table.find(suggests, selectedSuggest, 1) or 0
				local nextSuggest = suggests[currentIndex - 1] or suggests[#suggests]

				setSelectedSuggest(nextSuggest)
			elseif input.KeyCode == Enum.KeyCode.Down then
				local currentIndex = table.find(suggests, selectedSuggest, 1) or 0
				local prevSuggest = suggests[currentIndex + 1] or suggests[1]

				setSelectedSuggest(prevSuggest)
			end
		end)

		return function()
			inputBegan:Disconnect()
		end
	end, {
		suggests,
		selectedSuggest,
	})
end
