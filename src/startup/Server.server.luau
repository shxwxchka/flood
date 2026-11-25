local ServerScriptService = game:GetService("ServerScriptService")

local OutputServiceServer = require(ServerScriptService.Features.Output.OutputServiceServer)
local RegistryServiceServer = require(ServerScriptService.Features.Registry.RegistryServiceServer)

OutputServiceServer:init()
RegistryServiceServer:init()
