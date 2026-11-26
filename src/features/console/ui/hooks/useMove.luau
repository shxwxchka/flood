local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)

return function(containerRef: React.Ref<Frame>, moveDragDetectorRef: React.Ref<DragDetector>)
	React.useEffect(function()
		local startInputPosition: Vector2?
		local startPosition: UDim2?

		local dragStart = moveDragDetectorRef.current.DragStart:Connect(function(position: Vector2)
			startInputPosition = position
			startPosition = containerRef.current.Position
		end)

		local dragContinue = moveDragDetectorRef.current.DragContinue:Connect(function(position: Vector2)
			local delta = position - startInputPosition

			containerRef.current.Position = UDim2.new(
				startPosition.X.Scale,
				startPosition.X.Offset + delta.X,
				startPosition.Y.Scale,
				startPosition.Y.Offset + delta.Y
			)
		end)

		return function()
			dragStart:Disconnect()
			dragContinue:Disconnect()
		end
	end, {})
end
