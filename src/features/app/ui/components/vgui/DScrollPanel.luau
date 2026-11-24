local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local React = require(ReplicatedStorage.Packages.React)
local IsMouseEntered = require(ReplicatedStorage.Source.Core.UI.IsMouseEntered)
local IsVisible = require(ReplicatedStorage.Source.Core.UI.IsVisible)

local e = React.createElement

type DScrollPanelProps = {
	AnchorPoint: Vector2?,
	Position: UDim2?,
	Size: UDim2?,
	ZIndex: number?,
	children: React.ReactNode?,
}

local DEFAULTS = {
	AnchorPoint = Vector2.zero,
	Position = UDim2.fromOffset(0, 0),
	Size = UDim2.fromScale(1, 1),
	ZIndex = 1,
}

local COLORS = {
	SCROLL_UP = Color3.fromRGB(208, 208, 208),
	SCROLL_DOWN = Color3.fromRGB(208, 208, 208),
	SCROLL_UP_HOVERED = Color3.fromRGB(211, 237, 255),
	SCROLL_DOWN_HOVERED = Color3.fromRGB(211, 237, 255),
	SCROLL_UP_ICON = Color3.fromRGB(57, 57, 57),
	SCROLL_DOWN_ICON = Color3.fromRGB(57, 57, 57),
	SCROLL_UP_ICON_HOVERED = Color3.fromRGB(12, 63, 70),
	SCROLL_DOWN_ICON_HOVERED = Color3.fromRGB(12, 63, 70),
	SCROLL_UP_HOLDED = Color3.fromRGB(25, 208, 248),
	SCROLL_DOWN_HOLDED = Color3.fromRGB(25, 208, 248),
	SCROLL_UP_ICON_HOLDED = Color3.fromRGB(2, 120, 227),
	SCROLL_DOWN_ICON_HOLDED = Color3.fromRGB(2, 120, 227),
}

return React.forwardRef(function(props: DScrollPanelProps, ref: React.Ref<ScrollingFrame>)
	local scrollUpRef = React.useRef(nil :: Frame?)
	local scrollDownRef = React.useRef(nil :: Frame?)
	local scrollUpIconRef = React.useRef(nil :: ImageLabel?)
	local scrollDownIconRef = React.useRef(nil :: ImageLabel?)
	local scrollDraggerContainerRef = React.useRef(nil :: Frame?)
	local scrollDraggerRef = React.useRef(nil :: Frame?)
	local scrollDraggerButtonRef = React.useRef(nil :: TextButton?)
	local hitboxRef = React.useRef(nil :: Frame?)

	local dragMouseY, setDragMouseY = React.useState(0)
	local dragCanvasY, setDragCanvasY = React.useState(0)
	local scrollDraggerHolded, setScrollDraggerHolded = React.useState(false)

	local function canvasPositionChanged()
		local canvasY = ref.current.AbsoluteCanvasSize.Y
		local windowY = ref.current.AbsoluteWindowSize.Y
		local maxScrollY = canvasY - windowY

		if maxScrollY <= 0 then
			scrollDraggerRef.current.Position = UDim2.fromScale(0, 0)
		else
			local alpha = math.clamp(ref.current.CanvasPosition.Y / maxScrollY, 0, 1)
			local scaleY = scrollDraggerRef.current.Size.Y.Scale
			local positionY = alpha * (1 - scaleY)

			scrollDraggerRef.current.Position = UDim2.fromScale(0, positionY)
		end
	end

	local function canvasSizeChanged()
		local canvasY = ref.current.AbsoluteCanvasSize.Y
		local windowY = ref.current.AbsoluteWindowSize.Y
		local scaleY = math.clamp(windowY / canvasY, 0, 1)

		if canvasY <= 0 or windowY <= 0 or canvasY <= windowY then
			scrollDraggerRef.current.Size = UDim2.fromScale(1, 1)
		else
			scrollDraggerRef.current.Size = UDim2.fromScale(1, scaleY)
		end

		scrollDraggerRef.current.Visible = scaleY ~= 1

		canvasPositionChanged()
	end

	React.useEffect(function()
		canvasSizeChanged()
		canvasPositionChanged()
	end, {})

	React.useEffect(function()
		local mouseButton1Down = scrollDraggerButtonRef.current.MouseButton1Down:Connect(function()
			local mouseLocation = UserInputService:GetMouseLocation()

			setDragMouseY(mouseLocation.Y)
			setDragCanvasY(ref.current.CanvasPosition.Y)
			setScrollDraggerHolded(true)
		end)

		return function()
			mouseButton1Down:Disconnect()
		end
	end, {})

	React.useEffect(function()
		if not scrollDraggerHolded then
			return
		end

		local function stopDragging()
			setScrollDraggerHolded(false)
		end

		local inputEnded = UserInputService.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				stopDragging()
			end
		end)

		local inputChanged = UserInputService.InputChanged:Connect(function(input)
			if input.UserInputType ~= Enum.UserInputType.MouseMovement then
				return
			end

			local canvasY = ref.current.AbsoluteCanvasSize.Y
			local windowY = ref.current.AbsoluteWindowSize.Y
			local maxScrollY = canvasY - windowY

			if maxScrollY <= 0 then
				return
			end

			local trackHeight = scrollDraggerContainerRef.current.AbsoluteSize.Y
			local draggerHeight = scrollDraggerRef.current.AbsoluteSize.Y
			local movableHeight = trackHeight - draggerHeight

			if movableHeight <= 0 then
				return
			end

			local mouseLocation = UserInputService:GetMouseLocation()
			local currentMouseY = mouseLocation.Y
			local deltaMouseY = currentMouseY - dragMouseY

			local deltaCanvasY = (deltaMouseY / movableHeight) * maxScrollY
			local newCanvasY = math.clamp(dragCanvasY + deltaCanvasY, 0, maxScrollY)

			ref.current.CanvasPosition = Vector2.new(ref.current.CanvasPosition.X, newCanvasY)
		end)

		return function()
			inputEnded:Disconnect()
			inputChanged:Disconnect()
		end
	end, {
		scrollDraggerHolded,
		dragMouseY,
		dragCanvasY,
	})

	React.useEffect(function()
		local inputChanged = UserInputService.InputChanged:Connect(function(input)
			if
				input.UserInputType == Enum.UserInputType.MouseWheel
				and IsVisible(hitboxRef.current)
				and IsMouseEntered(hitboxRef.current)
				and ref.current
			then
				ref.current.CanvasPosition += Vector2.new(0, -input.Position.Z * 64)
			end
		end)

		return function()
			inputChanged:Disconnect()
		end
	end)

	return e("Frame", {
		AnchorPoint = props.AnchorPoint or DEFAULTS.AnchorPoint,
		Position = props.Position or DEFAULTS.Position,
		Size = props.Size or DEFAULTS.Size,
		BackgroundTransparency = 1,
		ZIndex = props.ZIndex or DEFAULTS.ZIndex,
	}, {
		Scroll = e("ScrollingFrame", {
			Size = UDim2.new(1, -15, 1, 0),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			CanvasSize = UDim2.fromOffset(0, 0),
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			ScrollBarThickness = 0,
			TopImage = "",
			MidImage = "",
			BottomImage = "",
			ScrollingEnabled = false,
			ref = ref,
			[React.Change.CanvasPosition] = canvasPositionChanged,
			[React.Change.CanvasSize] = canvasSizeChanged,
			[React.Change.AbsoluteCanvasSize] = canvasSizeChanged,
			[React.Change.AbsoluteWindowSize] = canvasSizeChanged,
		}, props.children),
		ScrollUp = e("Frame", {
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.fromScale(1, 0),
			Size = UDim2.fromOffset(15, 15),
			BackgroundColor3 = COLORS.SCROLL_UP,
			BorderSizePixel = 0,
			ZIndex = 3,
			ref = scrollUpRef,
		}, {
			Stroke = e("UIStroke", {
				Color = Color3.fromRGB(35, 35, 35),
				BorderStrokePosition = Enum.BorderStrokePosition.Inner,
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
				LineJoinMode = Enum.LineJoinMode.Miter,
			}),
			Icon = e("ImageLabel", {
				Size = UDim2.fromScale(1, 1),
				BackgroundTransparency = 1,
				Image = "rbxassetid://94786583281859",
				ImageColor3 = COLORS.SCROLL_UP_ICON,
				ref = scrollUpIconRef,
			}),
			Button = e("TextButton", {
				Size = UDim2.fromScale(1, 1),
				BackgroundTransparency = 1,
				TextTransparency = 1,
				[React.Event.MouseEnter] = function()
					scrollUpRef.current.BackgroundColor3 = COLORS.SCROLL_UP_HOVERED
					scrollUpIconRef.current.ImageColor3 = COLORS.SCROLL_UP_ICON_HOVERED
				end,
				[React.Event.MouseLeave] = function()
					scrollUpRef.current.BackgroundColor3 = COLORS.SCROLL_UP
					scrollUpIconRef.current.ImageColor3 = COLORS.SCROLL_UP_ICON
				end,
				[React.Event.MouseButton1Down] = function()
					scrollUpRef.current.BackgroundColor3 = COLORS.SCROLL_UP_HOLDED
					scrollUpIconRef.current.ImageColor3 = COLORS.SCROLL_UP_ICON_HOLDED
				end,
				[React.Event.MouseButton1Up] = function()
					scrollUpRef.current.BackgroundColor3 = COLORS.SCROLL_UP_HOVERED
					scrollUpIconRef.current.ImageColor3 = COLORS.SCROLL_UP_ICON_HOVERED

					if ref.current then
						ref.current.CanvasPosition -= Vector2.new(0, 16)
					end
				end,
			}),
		}),
		ScrollDown = e("Frame", {
			AnchorPoint = Vector2.new(1, 1),
			Position = UDim2.fromScale(1, 1),
			Size = UDim2.fromOffset(15, 15),
			BackgroundColor3 = COLORS.SCROLL_DOWN,
			BorderSizePixel = 0,
			ZIndex = 3,
			ref = scrollDownRef,
		}, {
			Stroke = e("UIStroke", {
				Color = Color3.fromRGB(35, 35, 35),
				BorderStrokePosition = Enum.BorderStrokePosition.Inner,
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
				LineJoinMode = Enum.LineJoinMode.Miter,
			}),
			Icon = e("ImageLabel", {
				Size = UDim2.fromScale(1, 1),
				BackgroundTransparency = 1,
				Image = "rbxassetid://138714238707786",
				ImageColor3 = COLORS.SCROLL_DOWN_ICON,
				ref = scrollDownIconRef,
			}),
			Button = e("TextButton", {
				Size = UDim2.fromScale(1, 1),
				BackgroundTransparency = 1,
				TextTransparency = 1,
				[React.Event.MouseEnter] = function()
					scrollDownRef.current.BackgroundColor3 = COLORS.SCROLL_DOWN_HOVERED
					scrollDownIconRef.current.ImageColor3 = COLORS.SCROLL_DOWN_ICON_HOVERED
				end,
				[React.Event.MouseLeave] = function()
					scrollDownRef.current.BackgroundColor3 = COLORS.SCROLL_DOWN
					scrollDownIconRef.current.ImageColor3 = COLORS.SCROLL_DOWN_ICON
				end,
				[React.Event.MouseButton1Down] = function()
					scrollDownRef.current.BackgroundColor3 = COLORS.SCROLL_DOWN_HOLDED
					scrollDownIconRef.current.ImageColor3 = COLORS.SCROLL_DOWN_ICON_HOLDED
				end,
				[React.Event.MouseButton1Up] = function()
					scrollDownRef.current.BackgroundColor3 = COLORS.SCROLL_DOWN_HOVERED
					scrollDownIconRef.current.ImageColor3 = COLORS.SCROLL_DOWN_ICON_HOVERED

					if ref.current then
						ref.current.CanvasPosition += Vector2.new(0, 16)
					end
				end,
			}),
		}),
		ScrollBar = e("Frame", {
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.fromScale(1, 0),
			Size = UDim2.new(0, 15, 1, 0),
			BackgroundColor3 = Color3.fromRGB(178, 178, 178),
			BackgroundTransparency = 0,
			BorderSizePixel = 0,
		}, {
			ScrollDraggerContainer = e("Frame", {
				AnchorPoint = Vector2.new(0, 0.5),
				Position = UDim2.fromScale(0, 0.5),
				Size = UDim2.new(1, 0, 1, -30),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				ref = scrollDraggerContainerRef,
			}, {
				ScrollDragger = e("Frame", {
					Size = UDim2.fromScale(1, 0),
					BackgroundColor3 = Color3.fromRGB(221, 221, 221),
					BorderSizePixel = 0,
					ref = scrollDraggerRef,
				}, {
					Stroke = e("UIStroke", {
						Color = Color3.fromRGB(79, 79, 79),
						BorderStrokePosition = Enum.BorderStrokePosition.Inner,
						ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
						LineJoinMode = Enum.LineJoinMode.Miter,
					}),
					Button = e("TextButton", {
						Size = UDim2.fromScale(1, 1),
						BackgroundTransparency = 1,
						TextTransparency = 1,
						ref = scrollDraggerButtonRef,
					}),
				}),
			}),
		}),
		Hitbox = e("Frame", {
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			ZIndex = 3,
			ref = hitboxRef,
		}),
	})
end)
