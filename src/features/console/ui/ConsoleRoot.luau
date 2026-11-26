local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local React = require(ReplicatedStorage.Packages.React)
local Sift = require(ReplicatedStorage.Packages.Sift)
local DScrollPanel = require(ReplicatedStorage.Source.Features.App.UI.Components.Vgui.DScrollPanel)
local Suggest = require(ReplicatedStorage.Source.Features.Console.UI.Components.Suggest)
local useAutoOutputBoxResizer = require(ReplicatedStorage.Source.Features.Console.UI.Hooks.useAutoOutputBoxResizer)
local useMove = require(ReplicatedStorage.Source.Features.Console.UI.Hooks.useMove)
local useOutput = require(ReplicatedStorage.Source.Features.Console.UI.Hooks.useOutput)
local useResize = require(ReplicatedStorage.Source.Features.Console.UI.Hooks.useResize)
local useSuggestionOfferer = require(ReplicatedStorage.Source.Features.Console.UI.Hooks.useSuggestionOfferer)
local RegistryServiceClient = require(ReplicatedStorage.Source.Features.Registry.RegistryServiceClient)

local e = React.createElement

type DScrollPanel = typeof(DScrollPanel)

local COLORS = {
	SUBMIT = Color3.fromRGB(228, 228, 228),
	SUBMIT_TEXT = Color3.fromRGB(81, 81, 81),
	SUBMIT_HOVERED = Color3.fromRGB(241, 241, 241),
	SUBMIT_TEXT_HOVERED = Color3.fromRGB(32, 115, 180),
	SUBMIT_HOLD = Color3.fromRGB(83, 180, 245),
	SUBMIT_TEXT_HOLD = Color3.fromRGB(255, 255, 255),
}

local FONTS = {
	RobotoMonoLight = Font.new(
		"rbxasset://fonts/families/RobotoMono.json",
		Enum.FontWeight.Light,
		Enum.FontStyle.Normal
	),
	RobotoMonoSemiBold = Font.new(
		"rbxasset://fonts/families/RobotoMono.json",
		Enum.FontWeight.Bold,
		Enum.FontStyle.Normal
	),
}

local STARTER_ANCHOR_POINT = Vector2.new(1, 0)
local STARTER_POSITION = UDim2.new(1, -16, 0, 16)
local STARTER_WIDTH = 712
local STARTER_HEIGHT = 523
local MIN_WIDTH = 300
local MIN_HEIGHT = 200

return function()
	local inputBoxText, setInputBoxText = React.useState("")
	local outputBoxText, setOutputBoxText = React.useState("")
	local suggests, setSuggests = React.useState({} :: { string })
	local selectedSuggest, setSelectedSuggest = React.useState(nil :: string?)
	local shown, setShown = React.useState(true)

	local moveDragDetectorRef = React.useRef(nil :: UIDragDetector)
	local containerRef = React.useRef(nil :: Frame)
	local dScrollPanelRef = React.useRef(nil :: DScrollPanel)
	local outputBoxRef = React.useRef(nil :: TextBox)
	local outputBoxPaddingRef = React.useRef(nil :: UIPadding)
	local inputBoxRef = React.useRef(nil :: TextBox)
	local submitRef = React.useRef(nil :: Frame)
	local submitTextRef = React.useRef(nil :: TextLabel)
	local suggestContainerRef = React.useRef(nil :: Frame)
	local resizeRef = React.useRef(nil :: Frame)
	local resizeDragDetectorRef = React.useRef(nil :: UIDragDetector)

	local function submit()
		if not RunService:IsRunning() then
			return
		end

		if selectedSuggest then
			setInputBoxText(selectedSuggest .. " ")
			setSelectedSuggest(nil)
		else
			RegistryServiceClient:runCommandByInputBoxText(inputBoxText)
			setInputBoxText("")
		end

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

	if shown then
		useMove(containerRef, moveDragDetectorRef)
		useResize(containerRef, resizeDragDetectorRef, MIN_WIDTH, MIN_HEIGHT)
		useAutoOutputBoxResizer(outputBoxRef, outputBoxPaddingRef)
		useOutput(setOutputBoxText)
		useSuggestionOfferer(
			inputBoxText,
			suggests,
			setSuggests,
			selectedSuggest,
			setSelectedSuggest,
			suggestContainerRef
		)
	end

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
			Size = UDim2.fromOffset(STARTER_WIDTH, STARTER_HEIGHT),
			BackgroundTransparency = 1,
			Visible = shown,
			ref = containerRef,
		}, {
			StrokeContainer = e("Frame", {
				Size = UDim2.fromScale(1, 1),
				BackgroundTransparency = 1,
				ZIndex = 3,
			}, {
				Stroke = e("UIStroke", {
					Color = Color3.fromRGB(35, 35, 35),
					BorderStrokePosition = Enum.BorderStrokePosition.Inner,
					ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
					LineJoinMode = Enum.LineJoinMode.Miter,
				}),
			}),
			Move = e("Frame", {
				Size = UDim2.new(1, 0, 0, 33),
				BackgroundTransparency = 1,
				ZIndex = 3,
			}, {
				DragDetector = e("UIDragDetector", {
					DragStyle = Enum.UIDragDetectorDragStyle.Scriptable,
					ref = moveDragDetectorRef,
				}),
			}),
			Title = e("TextLabel", {
				Size = UDim2.new(1, 0, 0, 32),
				BackgroundTransparency = 1,
				Text = "Console",
				TextColor3 = Color3.fromRGB(235, 235, 235),
				TextSize = 13,
				FontFace = FONTS.RobotoMonoSemiBold,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextYAlignment = Enum.TextYAlignment.Top,
				ZIndex = 3,
			}, {
				Padding = e("UIPadding", {
					PaddingTop = UDim.new(0, 8),
					PaddingLeft = UDim.new(0, 16),
				}),
			}),
			Borders = e("Frame", {
				Size = UDim2.fromScale(1, 1),
				BackgroundTransparency = 1,
				ZIndex = 1,
			}, {
				Top = e("Frame", {
					AnchorPoint = Vector2.new(0.5, 0),
					Position = UDim2.fromScale(0.5, 0),
					Size = UDim2.new(1, 0, 0, 33),
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
				Position = UDim2.new(0.5, 0, 0, 33),
				Size = UDim2.new(1, -32, 1, -81),
				BackgroundColor3 = Color3.fromRGB(79, 80, 83),
				BackgroundTransparency = 0.05,
				BorderSizePixel = 0,
				ZIndex = 1,
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
						FontFace = FONTS.RobotoMonoLight,
						TextXAlignment = Enum.TextXAlignment.Left,
						TextYAlignment = Enum.TextYAlignment.Top,
						TextWrapped = true,
						RichText = true,
						ClearTextOnFocus = false,
						MultiLine = true,
						TextEditable = false,
						Interactable = false,
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
				TextSize = 16,
				FontFace = FONTS.RobotoMonoLight,
				TextXAlignment = Enum.TextXAlignment.Left,
				ClearTextOnFocus = false,
				ClipsDescendants = true,
				ZIndex = 2,
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
					FontFace = FONTS.RobotoMonoLight,
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
			SuggestContainer = e(
				"Frame",
				{
					AnchorPoint = Vector2.new(0, 0),
					Position = UDim2.new(0, 16, 1, -16),
					Size = UDim2.fromOffset(16, 16),
					BackgroundColor3 = Color3.fromRGB(234, 234, 234),
					BackgroundTransparency = 0,
					BorderSizePixel = 0,
					AutomaticSize = Enum.AutomaticSize.XY,
					ZIndex = 5,
					Visible = false,
					ref = suggestContainerRef,
				},
				{
					Stroke = e("UIStroke", {
						Color = Color3.fromRGB(80, 80, 80),
						BorderStrokePosition = Enum.BorderStrokePosition.Inner,
						ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
						LineJoinMode = Enum.LineJoinMode.Miter,
					}),
					Padding = e("UIPadding", {
						PaddingTop = UDim.new(0, 1),
						PaddingBottom = UDim.new(0, 1),
						PaddingLeft = UDim.new(0, 1),
						PaddingRight = UDim.new(0, 1),
					}),
					ListLayout = e("UIListLayout"),
				},
				Sift.Array.map(suggests, function(suggest: string)
					return e(Suggest, {
						suggest = suggest,
						selectedSuggest = selectedSuggest,
						mouseEnter = function()
							setSelectedSuggest(suggest)
						end,
						mouseButton1Up = function()
							setInputBoxText(suggest)
							setSelectedSuggest(nil)
						end,
					})
				end)
			),
			Resize = e("Frame", {
				AnchorPoint = Vector2.new(1, 1),
				Position = UDim2.new(1, -4, 1, -4),
				Size = UDim2.fromOffset(12, 12),
				BackgroundTransparency = 1,
				ZIndex = 3,
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
				ZIndex = 4,
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
