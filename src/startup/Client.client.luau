local ReplicatedStorage = game:GetService("ReplicatedStorage")

local OutputService = require(ReplicatedStorage.Source.Features.Output.OutputService)
local UI = require(script.Parent.UI)

OutputService:init()
UI:mount()
