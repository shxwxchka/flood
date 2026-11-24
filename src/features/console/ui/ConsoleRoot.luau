local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TextService = game:GetService("TextService")
local UserInputService = game:GetService("UserInputService")

local React = require(ReplicatedStorage.Packages.React)
local DScrollPanel = require(ReplicatedStorage.Source.Features.App.UI.Components.Vgui.DScrollPanel)
local OutputService = require(ReplicatedStorage.Source.Features.Output.OutputService)

local e = React.createElement

type DScrollPanel = typeof(DScrollPanel)

local COLORS = {
	SUBMIT = Color3.fromRGB(228, 228, 228),
	SUBMIT_HOVERED = Color3.fromRGB(241, 241, 241),
	SUBMIT_TEXT = Color3.fromRGB(81, 81, 81),
	SUBMIT_TEXT_HOVERED = Color3.fromRGB(32, 115, 180),
	SUBMIT_HOLD = Color3.fromRGB(83, 180, 245),
	SUBMIT_TEXT_HOLD = Color3.fromRGB(255, 255, 255),
	MESSAGE_OUTPUT = Color3.fromRGB(255, 255, 255),
	MESSAGE_WARN = Color3.fromRGB(255, 222, 102),
	MESSAGE_ERROR = Color3.fromRGB(255, 90, 90),
}

local FONTS = {
	InconsolataLight = Font.new(
		"rbxasset://fonts/families/RobotoMono.json",
		Enum.FontWeight.Light,
		Enum.FontStyle.Normal
	),
	InconsolataSemiBold = Font.new(
		"rbxasset://fonts/families/RobotoMono.json",
		Enum.FontWeight.Bold,
		Enum.FontStyle.Normal
	),
}

local STARTER_ANCHOR_POINT = Vector2.new(1, 0)
local STARTER_POSITION = UDim2.new(1, -16, 0, 16)
local STARTER_SIZE = UDim2.fromOffset(712, 523)
local MIN_WIDTH = 300
local MIN_HEIGHT = 200

return function()
	local inputBoxText, setInputBoxText = React.useState("")
	local outputBoxText, setOutputBoxText = React.useState("")
	local shown, setShown = React.useState(true)

	local dScrollPanelRef = React.useRef(nil :: DScrollPanel)
	local containerRef = React.useRef(nil :: Frame?)
	local outputBoxRef = React.useRef(nil :: TextBox?)
	local outputBoxPaddingRef = React.useRef(nil :: UIPadding?)
	local inputBoxRef = React.useRef(nil :: TextBox?)
	local submitRef = React.useRef(nil :: Frame?)
	local submitTextRef = React.useRef(nil :: TextLabel?)
	local resizeRef = React.useRef(nil :: Frame?)
	local resizeDragDetectorRef = React.useRef(nil :: UIDragDetector?)

	local function updateOutputBoxSize()
		local paddingTop = outputBoxPaddingRef.current.PaddingTop.Offset
		local paddingBottom = outputBoxPaddingRef.current.PaddingBottom.Offset
		local paddingLeft = outputBoxPaddingRef.current.PaddingLeft.Offset
		local paddingRight = outputBoxPaddingRef.current.PaddingRight.Offset

		local width = math.max(1, outputBoxRef.current.AbsoluteSize.X - paddingLeft - paddingRight)

		local textBoundsParams = Instance.new("GetTextBoundsParams")
		textBoundsParams.Text = string.gsub(outputBoxRef.current.Text, "<[^>]->", "")
		textBoundsParams.Font = outputBoxRef.current.FontFace
		textBoundsParams.Size = outputBoxRef.current.TextSize
		textBoundsParams.Width = width

		local textBounds = TextService:GetTextBoundsAsync(textBoundsParams)
		local height = math.ceil(textBounds.Y) + paddingTop + paddingBottom

		outputBoxRef.current.Size = UDim2.new(1, 0, 0, height)
	end

	local function submit()
		setInputBoxText("")
		task.wait()
		inputBoxRef.current:CaptureFocus()

		task.defer(function()
			local absoluteCanvasSizeY = dScrollPanelRef.current.AbsoluteCanvasSize.Y
			local absoluteWindowSizeY = dScrollPanelRef.current.AbsoluteWindowSize.Y
			local canvasPositionX = dScrollPanelRef.current.CanvasPosition.X
			local canvasPositionY = math.max(0, absoluteCanvasSizeY - absoluteWindowSizeY)

			dScrollPanelRef.current.CanvasPosition = Vector2.new(canvasPositionX, canvasPositionY)
		end)
	end

	React.useEffect(function()
		updateOutputBoxSize()

		local textChanged = outputBoxRef.current:GetPropertyChangedSignal("Text"):Connect(updateOutputBoxSize)
		local sizeChanged = outputBoxRef.current:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateOutputBoxSize)

		return function()
			textChanged:Disconnect()
			sizeChanged:Disconnect()
		end
	end, {})

	React.useEffect(function()
		local startPosition, startSize, startAnchorPosition

		local dragStart = resizeDragDetectorRef.current.DragStart:Connect(function(position: Vector2)
			local parent = containerRef.current.Parent :: GuiObject

			startPosition = position
			startSize = containerRef.current.AbsoluteSize

			local relativeTopLeft = containerRef.current.AbsolutePosition - parent.AbsolutePosition
			local anchorPoint = containerRef.current.AnchorPoint
			local apX, apY = anchorPoint.X, anchorPoint.Y

			startAnchorPosition = relativeTopLeft + Vector2.new(startSize.X * apX, startSize.Y * apY)
		end)

		local dragContinue = resizeDragDetectorRef.current.DragContinue:Connect(function(position: Vector2)
			local container = containerRef.current
			local delta = position - startPosition
			local newWidth = math.max(MIN_WIDTH, startSize.X + delta.X)
			local newHeight = math.max(MIN_HEIGHT, startSize.Y + delta.Y)

			local deltaWidth = newWidth - startSize.X
			local deltaHeight = newHeight - startSize.Y
			local anchorPoint = container.AnchorPoint

			container.Size = UDim2.fromOffset(newWidth, newHeight)
			container.Position = UDim2.fromOffset(
				startAnchorPosition.X + deltaWidth * anchorPoint.X,
				startAnchorPosition.Y + deltaHeight * anchorPoint.Y
			)
		end)

		return function()
			dragStart:Disconnect()
			dragContinue:Disconnect()
		end
	end, {})

	React.useEffect(function()
		if not RunService:IsRunning() then
			return
		end

		local messageOut = OutputService.messageOut:Connect(function(message, messageType)
			setOutputBoxText(function(prevMessages)
				local color = COLORS.MESSAGE_OUTPUT

				if messageType == "warn" then
					color = COLORS.MESSAGE_WARN
				elseif messageType == "error" then
					color = COLORS.MESSAGE_ERROR
				end

				local r, g, b = math.floor(color.R * 255), math.floor(color.G * 255), math.floor(color.B * 255)
				local coloredMessage = "<font color='rgb(" .. r .. "," .. g .. "," .. b .. ")'>" .. message .. "</font>"

				return if prevMessages == "" then coloredMessage else prevMessages .. "\n" .. coloredMessage
			end)
		end)

		return function()
			messageOut:Disconnect()
		end
	end, {})

	React.useEffect(function()
		local inputBegan = UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
			if gameProcessedEvent then
				return
			end

			if input.KeyCode == Enum.KeyCode.Backquote then
				setShown(not shown)
			end
		end)

		return function()
			inputBegan:Disconnect()
		end
	end, { shown })

	return e(React.Fragment, nil, {
		ConsoleContainer = e("Frame", {
			AnchorPoint = STARTER_ANCHOR_POINT,
			Position = STARTER_POSITION,
			Size = STARTER_SIZE,
			BackgroundTransparency = 1,
			Visible = shown,
			ref = containerRef,
		}, {
			Stroke = e("UIStroke", {
				Color = Color3.fromRGB(35, 35, 35),
				BorderStrokePosition = Enum.BorderStrokePosition.Outer,
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
				LineJoinMode = Enum.LineJoinMode.Miter,
			}),
			DragDetector = e("UIDragDetector"),
			Title = e("TextLabel", {
				Size = UDim2.new(1, 0, 0, 32),
				BackgroundTransparency = 1,
				Text = "Console",
				TextColor3 = Color3.fromRGB(235, 235, 235),
				TextSize = 13,
				FontFace = FONTS.InconsolataSemiBold,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextYAlignment = Enum.TextYAlignment.Top,
				ZIndex = 2,
			}, {
				Padding = e("UIPadding", {
					PaddingTop = UDim.new(0, 8),
					PaddingLeft = UDim.new(0, 16),
				}),
			}),
			Borders = e("Frame", {
				Size = UDim2.fromScale(1, 1),
				BackgroundTransparency = 1,
			}, {
				Top = e("Frame", {
					AnchorPoint = Vector2.new(0.5, 0),
					Position = UDim2.fromScale(0.5, 0),
					Size = UDim2.new(1, 0, 0, 31 + 2),
					BackgroundColor3 = Color3.fromRGB(107, 110, 114),
					BorderSizePixel = 0,
				}),
				Bottom = e("Frame", {
					AnchorPoint = Vector2.new(0.5, 1),
					Position = UDim2.fromScale(0.5, 1),
					Size = UDim2.new(1, 0, 0, 48),
					BackgroundColor3 = Color3.fromRGB(107, 110, 114),
					BorderSizePixel = 0,
				}),
				Left = e("Frame", {
					AnchorPoint = Vector2.new(0, 0.5),
					Position = UDim2.fromScale(0, 0.5),
					Size = UDim2.new(0, 16, 1, 0),
					BackgroundColor3 = Color3.fromRGB(107, 110, 114),
					BorderSizePixel = 0,
				}),
				Right = e("Frame", {
					AnchorPoint = Vector2.new(1, 0.5),
					Position = UDim2.fromScale(1, 0.5),
					Size = UDim2.new(0, 16, 1, 0),
					BackgroundColor3 = Color3.fromRGB(107, 110, 114),
					BorderSizePixel = 0,
				}),
			}),
			Output = e("Frame", {
				AnchorPoint = Vector2.new(0.5, 0),
				Position = UDim2.new(0.5, 0, 0, 31 + 2),
				Size = UDim2.new(1, -32, 1, -79 - 2),
				BackgroundColor3 = Color3.fromRGB(79, 80, 83),
				BackgroundTransparency = 0.05,
				BorderSizePixel = 0,
			}, {
				Stroke = e("UIStroke", {
					Color = Color3.fromRGB(80, 80, 80),
					BorderStrokePosition = Enum.BorderStrokePosition.Inner,
					ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
					LineJoinMode = Enum.LineJoinMode.Miter,
				}),
				DScrollPanel = e(DScrollPanel, {
					ref = dScrollPanelRef,
				}, {
					OutputBox = e("TextBox", {
						Size = UDim2.fromScale(1, 1),
						BackgroundTransparency = 1,
						Text = outputBoxText,
						TextColor3 = Color3.fromRGB(255, 255, 255),
						TextSize = 13,
						FontFace = FONTS.InconsolataLight,
						TextXAlignment = Enum.TextXAlignment.Left,
						TextYAlignment = Enum.TextYAlignment.Top,
						TextWrapped = true,
						RichText = true,
						MultiLine = true,
						ClearTextOnFocus = false,
						TextEditable = false,
						ref = outputBoxRef,
					}, {
						Padding = e("UIPadding", {
							PaddingTop = UDim.new(0, 1),
							PaddingBottom = UDim.new(0, 1),
							PaddingLeft = UDim.new(0, 3),
							PaddingRight = UDim.new(0, 3),
							ref = outputBoxPaddingRef,
						}),
					}),
				}),
			}),
			InputBox = e("TextBox", {
				AnchorPoint = Vector2.new(0, 1),
				Position = UDim2.new(0, 16, 1, -16),
				Size = UDim2.new(1, -104, 0, 24),
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BorderSizePixel = 0,
				Text = inputBoxText,
				TextColor3 = Color3.new(0, 0, 0),
				TextSize = 14,
				FontFace = FONTS.InconsolataLight,
				TextXAlignment = Enum.TextXAlignment.Left,
				ClearTextOnFocus = false,
				ClipsDescendants = true,
				ref = inputBoxRef,
				[React.Change.Text] = function(rbx: TextLabel)
					setInputBoxText(rbx.Text)
				end,
				[React.Event.FocusLost] = function(_, enterPressed: boolean)
					if enterPressed then
						submit()
					end
				end,
			}, {
				Padding = e("UIPadding", {
					PaddingLeft = UDim.new(0, 4),
				}),
				Stroke = e("UIStroke", {
					Color = Color3.fromRGB(80, 80, 80),
					BorderStrokePosition = Enum.BorderStrokePosition.Inner,
					ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
					LineJoinMode = Enum.LineJoinMode.Miter,
				}),
			}),
			Submit = e("Frame", {
				AnchorPoint = Vector2.new(1, 1),
				Position = UDim2.new(1, -16, 1, -16),
				Size = UDim2.fromOffset(64, 24),
				BackgroundColor3 = COLORS.SUBMIT,
				BorderSizePixel = 0,
				ZIndex = 2,
				ref = submitRef,
			}, {
				Text = e("TextLabel", {
					Size = UDim2.fromScale(1, 1),
					BackgroundTransparency = 1,
					Text = "Submit",
					TextColor3 = COLORS.SUBMIT_TEXT,
					TextSize = 14,
					FontFace = FONTS.InconsolataLight,
					TextXAlignment = Enum.TextXAlignment.Left,
					ref = submitTextRef,
				}, {
					Padding = e("UIPadding", {
						PaddingLeft = UDim.new(0, 6),
					}),
				}),
				Stroke = e("UIStroke", {
					Color = Color3.fromRGB(80, 80, 80),
					BorderStrokePosition = Enum.BorderStrokePosition.Inner,
					ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
					LineJoinMode = Enum.LineJoinMode.Miter,
				}),
				Button = e("TextButton", {
					Size = UDim2.fromScale(1, 1),
					BackgroundTransparency = 1,
					TextTransparency = 1,
					[React.Event.MouseEnter] = function()
						submitRef.current.BackgroundColor3 = COLORS.SUBMIT_HOVERED
						submitTextRef.current.TextColor3 = COLORS.SUBMIT_TEXT_HOVERED
					end,
					[React.Event.MouseLeave] = function()
						submitRef.current.BackgroundColor3 = COLORS.SUBMIT
						submitTextRef.current.TextColor3 = COLORS.SUBMIT_TEXT
					end,
					[React.Event.MouseButton1Down] = function()
						submitRef.current.BackgroundColor3 = COLORS.SUBMIT_HOLD
						submitTextRef.current.TextColor3 = COLORS.SUBMIT_TEXT_HOLD
					end,
					[React.Event.MouseButton1Up] = function()
						submitRef.current.BackgroundColor3 = COLORS.SUBMIT_HOVERED
						submitTextRef.current.TextColor3 = COLORS.SUBMIT_TEXT_HOVERED
						submit()
					end,
				}),
			}),
			Resize = e("Frame", {
				AnchorPoint = Vector2.new(1, 1),
				Position = UDim2.new(1, -4, 1, -4),
				Size = UDim2.fromOffset(12, 12),
				BackgroundTransparency = 1,
				ZIndex = 2,
				ref = resizeRef,
			}, {
				DragDetector = e("UIDragDetector", {
					DragStyle = Enum.UIDragDetectorDragStyle.Scriptable,
					ref = resizeDragDetectorRef,
				}),
				Icon = e("ImageLabel", {
					Size = UDim2.fromScale(1, 1),
					BackgroundTransparency = 1,
					Image = "rbxassetid://123720322872834",
					ImageColor3 = Color3.fromRGB(185, 185, 186),
				}),
			}),
			Close = e("Frame", {
				AnchorPoint = Vector2.new(1, 0),
				Position = UDim2.new(1, -8, 0, 8),
				Size = UDim2.fromOffset(15, 15),
				BackgroundTransparency = 1,
				ZIndex = 2,
			}, {
				Icon = e("ImageLabel", {
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.fromScale(0.5, 0.5),
					Size = UDim2.fromScale(1, 1),
					BackgroundTransparency = 1,
					Image = "rbxassetid://131347504015529",
					ImageColor3 = Color3.fromRGB(185, 185, 186),
					ResampleMode = Enum.ResamplerMode.Pixelated,
				}),
				Button = e("TextButton", {
					Size = UDim2.fromScale(1, 1),
					BackgroundTransparency = 1,
					TextTransparency = 1,
					[React.Event.MouseButton1Up] = function()
						setShown(false)
					end,
				}),
			}),
		}),
	})
end
