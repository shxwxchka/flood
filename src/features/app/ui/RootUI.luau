local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)
local Sift = require(ReplicatedStorage.Packages.Sift)

local e = React.createElement

local capturedRoots = {}

for _, root in ReplicatedStorage.Source.Features:GetDescendants() do
	if root:IsA("ModuleScript") and root.Name:match("Root") and root ~= script then
		capturedRoots[root.Name] = require(root)
	end
end

return function()
	return e(
		React.Fragment,
		nil,
		Sift.Dictionary.map(capturedRoots, function(root: ModuleScript, name: string)
			return e(root, { Name = name })
		end)
	)
end
