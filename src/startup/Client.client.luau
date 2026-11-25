local ReplicatedStorage = game:GetService("ReplicatedStorage")

local OutputServiceClient = require(ReplicatedStorage.Source.Features.Output.OutputServiceClient)
local RegistryServiceClient = require(ReplicatedStorage.Source.Features.Registry.RegistryServiceClient)
local UI = require(script.Parent.UI)

OutputServiceClient:init()
RegistryServiceClient:init()

UI:mount()
