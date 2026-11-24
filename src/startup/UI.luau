local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")

local React = require(ReplicatedStorage.Packages.React)
local ReactRoblox = require(ReplicatedStorage.Packages.ReactRoblox)
local RootUI = require(ReplicatedStorage.Source.Features.App.UI.RootUI)

local localPlayer = Players.LocalPlayer
local playerGui = localPlayer.PlayerGui

local UI = {}

function UI.mount(_self: UI)
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, false)

	local container = Instance.new("ScreenGui")
	container.Name = "UI"
	container.IgnoreGuiInset = true
	container.ResetOnSpawn = false
	container.ClipToDeviceSafeArea = false
	container.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	container.Parent = playerGui

	local root = ReactRoblox.createRoot(container)
	local app = React.createElement(RootUI)

	root:render(app)
end

type UI = typeof(UI)

return UI :: UI
