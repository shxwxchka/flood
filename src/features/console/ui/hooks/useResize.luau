local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)

return function(
	containerRef: React.Ref<Frame>,
	resizeDragDetectorRef: React.Ref<DragDetector>,
	minWidth: number,
	minHeight: number
)
	React.useEffect(function()
		local startInputPosition: Vector2?
		local startPosition: UDim2?
		local startSize: Vector2?

		local dragStart = resizeDragDetectorRef.current.DragStart:Connect(function(position: Vector2)
			startInputPosition = position
			startSize = containerRef.current.AbsoluteSize
			startPosition = containerRef.current.Position
		end)

		local dragContinue = resizeDragDetectorRef.current.DragContinue:Connect(function(position: Vector2)
			local anchorPoint = containerRef.current.AnchorPoint
			local delta = position - startInputPosition
			local newWidth = math.max(minWidth, startSize.X + delta.X)
			local newHeight = math.max(minHeight, startSize.Y + delta.Y)
			local deltaWidth = newWidth - startSize.X
			local deltaHeight = newHeight - startSize.Y

			containerRef.current.Size = UDim2.fromOffset(newWidth, newHeight)
			containerRef.current.Position = UDim2.new(
				startPosition.X.Scale,
				startPosition.X.Offset + deltaWidth * anchorPoint.X,
				startPosition.Y.Scale,
				startPosition.Y.Offset + deltaHeight * anchorPoint.Y
			)
		end)

		return function()
			dragStart:Disconnect()
			dragContinue:Disconnect()
		end
	end, {})
end
