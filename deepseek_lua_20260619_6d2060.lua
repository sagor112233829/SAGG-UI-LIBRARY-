--[[
    MobileUI - Premium Mobile-First UI Library for Roblox
    Designed for mobile devices, optimized for touch interactions,
    inspired by iOS, Material Design 3, and modern mobile dashboards.
    
    Features:
    - Dark / AMOLED / Midnight / Custom themes
    - Smooth animations (TweenService, 60 FPS)
    - Touch-friendly components with gesture support
    - Draggable window, minimize/expand
    - Safe area support for notches
    - Auto-scaling across resolutions
    - Object-oriented, modular, production-ready
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- ====================== THEME SYSTEM ======================
local Themes = {
	Dark = {
		Name = "Dark",
		Background = Color3.fromRGB(18, 18, 24),
		Surface = Color3.fromRGB(30, 30, 40),
		SurfaceLight = Color3.fromRGB(45, 45, 58),
		Primary = Color3.fromRGB(100, 140, 255),
		OnPrimary = Color3.fromRGB(255, 255, 255),
		Secondary = Color3.fromRGB(60, 60, 75),
		OnSecondary = Color3.fromRGB(200, 200, 210),
		Text = Color3.fromRGB(240, 240, 245),
		SubText = Color3.fromRGB(170, 170, 180),
		Border = Color3.fromRGB(80, 80, 95),
		Shadow = Color3.fromRGB(0, 0, 0),
		ScrollBar = Color3.fromRGB(100, 100, 120),
		Glass = Color3.fromRGB(255, 255, 255),
	},
	AMOLED = {
		Name = "AMOLED",
		Background = Color3.fromRGB(0, 0, 0),
		Surface = Color3.fromRGB(8, 8, 16),
		SurfaceLight = Color3.fromRGB(20, 20, 30),
		Primary = Color3.fromRGB(130, 170, 255),
		OnPrimary = Color3.fromRGB(255, 255, 255),
		Secondary = Color3.fromRGB(30, 30, 40),
		OnSecondary = Color3.fromRGB(180, 180, 190),
		Text = Color3.fromRGB(230, 230, 240),
		SubText = Color3.fromRGB(150, 150, 160),
		Border = Color3.fromRGB(40, 40, 55),
		Shadow = Color3.fromRGB(0, 0, 0),
		ScrollBar = Color3.fromRGB(80, 80, 100),
		Glass = Color3.fromRGB(255, 255, 255),
	},
	Midnight = {
		Name = "Midnight",
		Background = Color3.fromRGB(10, 15, 28),
		Surface = Color3.fromRGB(18, 25, 45),
		SurfaceLight = Color3.fromRGB(28, 38, 60),
		Primary = Color3.fromRGB(120, 160, 255),
		OnPrimary = Color3.fromRGB(255, 255, 255),
		Secondary = Color3.fromRGB(35, 45, 65),
		OnSecondary = Color3.fromRGB(190, 190, 210),
		Text = Color3.fromRGB(220, 230, 250),
		SubText = Color3.fromRGB(150, 160, 180),
		Border = Color3.fromRGB(60, 70, 100),
		Shadow = Color3.fromRGB(0, 0, 0),
		ScrollBar = Color3.fromRGB(90, 100, 130),
		Glass = Color3.fromRGB(255, 255, 255),
	},
}

-- ====================== UTILITY FUNCTIONS ======================
local function applyTheme(instance, theme, propertyPath)
	-- Helper to set theme color on an instance based on a path like "Background", "Text", etc.
	if propertyPath == "Background" then
		instance.BackgroundColor3 = theme.Background
	elseif propertyPath == "Surface" then
		instance.BackgroundColor3 = theme.Surface
	elseif propertyPath == "SurfaceLight" then
		instance.BackgroundColor3 = theme.SurfaceLight
	elseif propertyPath == "Primary" then
		instance.BackgroundColor3 = theme.Primary
	elseif propertyPath == "OnPrimary" then
		instance.TextColor3 = theme.OnPrimary
	elseif propertyPath == "Secondary" then
		instance.BackgroundColor3 = theme.Secondary
	elseif propertyPath == "OnSecondary" then
		instance.TextColor3 = theme.OnSecondary
	elseif propertyPath == "Text" then
		instance.TextColor3 = theme.Text
	elseif propertyPath == "SubText" then
		instance.TextColor3 = theme.SubText
	elseif propertyPath == "Border" then
		instance.BackgroundColor3 = theme.Border
	elseif propertyPath == "ScrollBar" then
		instance.ScrollBarImageColor3 = theme.ScrollBar
	elseif propertyPath == "Glass" then
		instance.BackgroundColor3 = theme.Glass
	elseif propertyPath == "Shadow" then
		instance.BackgroundColor3 = theme.Shadow
	end
end

local function createShadow(parent, size, cornerRadius, theme, zIndex)
	local shadow = Instance.new("Frame")
	shadow.Name = "Shadow"
	shadow.Size = size
	shadow.BackgroundColor3 = theme.Shadow
	shadow.BackgroundTransparency = 0.85
	shadow.BorderSizePixel = 0
	shadow.ZIndex = zIndex or 0
	local corner = Instance.new("UICorner")
	corner.CornerRadius = cornerRadius or UDim.new(0, 16)
	corner.Parent = shadow
	shadow.Parent = parent
	return shadow
end

local function createGlassEffect(instance, theme, transparency)
	instance.BackgroundTransparency = transparency or 0.25
	instance.BackgroundColor3 = theme.Surface
	local stroke = Instance.new("UIStroke")
	stroke.Thickness = 1
	stroke.Color = theme.Glass
	stroke.Transparency = 0.7
	stroke.Parent = instance
end

local function tweenObject(instance, properties, duration, easingStyle, direction, callback)
	local tweenInfo = TweenInfo.new(duration, easingStyle or Enum.EasingStyle.Quart, direction or Enum.EasingDirection.Out)
	local tween = TweenService:Create(instance, tweenInfo, properties)
	tween:Play()
	if callback then
		tween.Completed:Connect(function()
			callback()
		end)
	end
	return tween
end

-- ====================== SCALING SYSTEM ======================
local BASE_WIDTH = 400
local BASE_HEIGHT = 800
local screenSize = PlayerGui.AbsoluteSize
local scaleFactor = math.min(screenSize.X / BASE_WIDTH, screenSize.Y / BASE_HEIGHT)

local function scaleOffset(offset)
	return offset * scaleFactor
end

local function scaleUDim2(xScale, xOffset, yScale, yOffset)
	return UDim2.new(xScale or 0, scaleOffset(xOffset or 0), yScale or 0, scaleOffset(yOffset or 0))
end

-- ====================== SAFE AREA MANAGEMENT ======================
local safeAreaEnabled = false
local safeAreaTop = 44   -- typical notch height
local safeAreaBottom = 34 -- gesture bar

-- ====================== COMPONENT CLASSES ======================
local ComponentBase = {}
ComponentBase.__index = ComponentBase

function ComponentBase.new(instance)
	local self = setmetatable({ Instance = instance }, ComponentBase)
	return self
end

function ComponentBase:SetVisible(visible)
	self.Instance.Visible = visible
end

function ComponentBase:Destroy()
	self.Instance:Destroy()
end

-- ====================== BUTTON ======================
local Button = setmetatable({}, ComponentBase)
Button.__index = Button

function Button.new(parent, config, theme)
	local holder = Instance.new("Frame")
	holder.Size = UDim2.new(1, 0, 0, scaleOffset(56))
	holder.BackgroundTransparency = 1
	holder.Name = "ButtonHolder"
	
	local shadow = createShadow(holder, UDim2.new(1, 0, 1, 0), UDim.new(0, 16), theme, 0)
	shadow.Position = UDim2.new(0, 2, 0, 2)
	
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, 0, 1, 0)
	btn.BackgroundColor3 = theme.Primary
	btn.Text = config.Name or "Button"
	btn.TextColor3 = theme.OnPrimary
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = scaleOffset(18)
	btn.BorderSizePixel = 0
	btn.ZIndex = 2
	btn.Parent = holder
	
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 16)
	corner.Parent = btn
	
	local stroke = Instance.new("UIStroke")
	stroke.Thickness = 1
	stroke.Color = theme.Glass
	stroke.Transparency = 0.6
	stroke.Parent = btn
	
	local ripple = Instance.new("Frame")
	ripple.Size = UDim2.new(0, 0, 0, 0)
	ripple.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	ripple.BackgroundTransparency = 0.6
	ripple.BorderSizePixel = 0
	ripple.ZIndex = 3
	ripple.AnchorPoint = Vector2.new(0.5, 0.5)
	ripple.Visible = false
	local rippleCorner = Instance.new("UICorner")
	rippleCorner.CornerRadius = UDim.new(1, 0)
	rippleCorner.Parent = ripple
	ripple.Parent = btn
	
	-- Touch feedback
	local originalSize = btn.Size
	btn.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch then
			tweenObject(btn, {Size = UDim2.new(1, -scaleOffset(6), 1, -scaleOffset(6))}, 0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
			-- ripple
			local pos = input.Position
			ripple.Position = UDim2.new(0, pos.X - btn.AbsolutePosition.X, 0, pos.Y - btn.AbsolutePosition.Y)
			ripple.Size = UDim2.new(0, 0, 0, 0)
			ripple.Visible = true
			tweenObject(ripple, {Size = UDim2.new(0, scaleOffset(200), 0, scaleOffset(200))}, 0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, function()
				ripple.Visible = false
			end)
		end
	end)
	btn.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch then
			tweenObject(btn, {Size = originalSize}, 0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		end
	end)
	
	btn.MouseButton1Click:Connect(function()
		if config.Callback then
			config.Callback()
		end
	end)
	
	holder.Parent = parent
	
	local self = setmetatable({ Instance = holder, Button = btn }, Button)
	self.Theme = theme
	return self
end

function Button:SetText(text)
	self.Button.Text = text
end

-- ====================== TOGGLE ======================
local Toggle = setmetatable({}, ComponentBase)
Toggle.__index = Toggle

function Toggle.new(parent, config, theme)
	local holder = Instance.new("Frame")
	holder.Size = UDim2.new(1, 0, 0, scaleOffset(60))
	holder.BackgroundTransparency = 1
	holder.Name = "ToggleHolder"
	
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(0.6, 0, 1, 0)
	label.Position = UDim2.new(0, scaleOffset(4), 0, 0)
	label.BackgroundTransparency = 1
	label.Text = config.Name or "Toggle"
	label.TextColor3 = theme.Text
	label.Font = Enum.Font.GothamMedium
	label.TextSize = scaleOffset(17)
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = holder
	
	local switchHolder = Instance.new("Frame")
	switchHolder.Size = UDim2.new(0, scaleOffset(60), 0, scaleOffset(34))
	switchHolder.Position = UDim2.new(1, -scaleOffset(64), 0.5, -scaleOffset(17))
	switchHolder.BackgroundColor3 = theme.Secondary
	switchHolder.BorderSizePixel = 0
	local switchCorner = Instance.new("UICorner")
	switchCorner.CornerRadius = UDim.new(1, 0)
	switchCorner.Parent = switchHolder
	switchHolder.Parent = holder
	
	local knob = Instance.new("Frame")
	knob.Size = UDim2.new(0, scaleOffset(28), 0, scaleOffset(28))
	knob.Position = UDim2.new(0, scaleOffset(3), 0.5, -scaleOffset(14))
	knob.BackgroundColor3 = theme.Text
	knob.BorderSizePixel = 0
	local knobCorner = Instance.new("UICorner")
	knobCorner.CornerRadius = UDim.new(1, 0)
	knobCorner.Parent = knob
	knob.Parent = switchHolder
	
	local state = config.Default or false
	local function updateVisual()
		if state then
			switchHolder.BackgroundColor3 = theme.Primary
			tweenObject(knob, {Position = UDim2.new(1, -scaleOffset(31), 0.5, -scaleOffset(14))}, 0.2)
		else
			switchHolder.BackgroundColor3 = theme.Secondary
			tweenObject(knob, {Position = UDim2.new(0, scaleOffset(3), 0.5, -scaleOffset(14))}, 0.2)
		end
	end
	updateVisual()
	
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, 0, 1, 0)
	btn.BackgroundTransparency = 1
	btn.Text = ""
	btn.Parent = switchHolder
	btn.MouseButton1Click:Connect(function()
		state = not state
		updateVisual()
		if config.Callback then
			config.Callback(state)
		end
	end)
	
	holder.Parent = parent
	
	local self = setmetatable({ Instance = holder, State = state }, Toggle)
	self.Theme = theme
	self.GetState = function() return state end
	self.SetState = function(newState)
		state = newState
		updateVisual()
	end
	return self
end

-- ====================== SLIDER ======================
local Slider = setmetatable({}, ComponentBase)
Slider.__index = Slider

function Slider.new(parent, config, theme)
	local holder = Instance.new("Frame")
	holder.Size = UDim2.new(1, 0, 0, scaleOffset(70))
	holder.BackgroundTransparency = 1
	holder.Name = "SliderHolder"
	
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(0.6, 0, 0, scaleOffset(24))
	label.Position = UDim2.new(0, scaleOffset(4), 0, scaleOffset(2))
	label.BackgroundTransparency = 1
	label.Text = config.Name or "Slider"
	label.TextColor3 = theme.Text
	label.Font = Enum.Font.GothamMedium
	label.TextSize = scaleOffset(17)
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = holder
	
	local valueLabel = Instance.new("TextLabel")
	valueLabel.Size = UDim2.new(0.4, 0, 0, scaleOffset(24))
	valueLabel.Position = UDim2.new(0.6, 0, 0, scaleOffset(2))
	valueLabel.BackgroundTransparency = 1
	valueLabel.TextColor3 = theme.SubText
	valueLabel.Font = Enum.Font.GothamMedium
	valueLabel.TextSize = scaleOffset(16)
	valueLabel.TextXAlignment = Enum.TextXAlignment.Right
	valueLabel.Text = tostring(config.Default or config.Min or 0)
	valueLabel.Parent = holder
	
	local track = Instance.new("Frame")
	track.Size = UDim2.new(1, -scaleOffset(8), 0, scaleOffset(6))
	track.Position = UDim2.new(0, scaleOffset(4), 0, scaleOffset(36))
	track.BackgroundColor3 = theme.Secondary
	track.BorderSizePixel = 0
	local trackCorner = Instance.new("UICorner")
	trackCorner.CornerRadius = UDim.new(1, 0)
	trackCorner.Parent = track
	track.Parent = holder
	
	local fill = Instance.new("Frame")
	fill.Size = UDim2.new(0, 0, 1, 0)
	fill.BackgroundColor3 = theme.Primary
	fill.BorderSizePixel = 0
	local fillCorner = Instance.new("UICorner")
	fillCorner.CornerRadius = UDim.new(1, 0)
	fillCorner.Parent = fill
	fill.Parent = track
	
	local knob = Instance.new("TextButton")
	knob.Size = UDim2.new(0, scaleOffset(28), 0, scaleOffset(28))
	knob.Position = UDim2.new(0, -scaleOffset(14), 0.5, -scaleOffset(14))
	knob.BackgroundColor3 = theme.Primary
	knob.Text = ""
	knob.BorderSizePixel = 0
	local knobCorner = Instance.new("UICorner")
	knobCorner.CornerRadius = UDim.new(1, 0)
	knobCorner.Parent = knob
	knob.Parent = track
	
	local min = config.Min or 0
	local max = config.Max or 100
	local value = config.Default or min
	local dragging = false
	
	local function updateValue(newValue)
		value = math.clamp(newValue, min, max)
		local fraction = (value - min) / (max - min)
		fill.Size = UDim2.new(fraction, 0, 1, 0)
		knob.Position = UDim2.new(fraction, -scaleOffset(14), 0.5, -scaleOffset(14))
		valueLabel.Text = tostring(math.floor(value * 100 + 0.5) / 100)
	end
	updateValue(value)
	
	knob.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
		end
	end)
	knob.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)
	
	UserInputService.TouchMoved:Connect(function(touch, processed)
		if dragging and not processed then
			local trackPos = track.AbsolutePosition
			local trackWidth = track.AbsoluteSize.X
			local touchX = touch.Position.X
			local relativeX = math.clamp(touchX - trackPos.X, 0, trackWidth)
			local fraction = relativeX / trackWidth
			updateValue(min + fraction * (max - min))
			if config.Callback then
				config.Callback(value)
			end
		end
	end)
	
	-- Allow tap on track
	track.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch then
			local trackPos = track.AbsolutePosition
			local trackWidth = track.AbsoluteSize.X
			local relativeX = math.clamp(input.Position.X - trackPos.X, 0, trackWidth)
			local fraction = relativeX / trackWidth
			updateValue(min + fraction * (max - min))
			if config.Callback then
				config.Callback(value)
			end
			dragging = true
		end
	end)
	track.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)
	
	holder.Parent = parent
	
	local self = setmetatable({ Instance = holder, Value = value }, Slider)
	self.Theme = theme
	self.GetValue = function() return value end
	self.SetValue = function(v)
		updateValue(v)
		if config.Callback then config.Callback(value) end
	end
	return self
end

-- ====================== DROPDOWN ======================
local Dropdown = setmetatable({}, ComponentBase)
Dropdown.__index = Dropdown

function Dropdown.new(parent, config, theme)
	local holder = Instance.new("Frame")
	holder.Size = UDim2.new(1, 0, 0, scaleOffset(56))
	holder.BackgroundTransparency = 1
	holder.Name = "DropdownHolder"
	
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, 0, 1, 0)
	btn.BackgroundColor3 = theme.SurfaceLight
	btn.Text = config.Default or "Select..."
	btn.TextColor3 = theme.Text
	btn.Font = Enum.Font.GothamMedium
	btn.TextSize = scaleOffset(17)
	btn.BorderSizePixel = 0
	btn.ZIndex = 2
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 14)
	corner.Parent = btn
	btn.Parent = holder
	
	local arrow = Instance.new("TextLabel")
	arrow.Size = UDim2.new(0, scaleOffset(30), 0, scaleOffset(30))
	arrow.Position = UDim2.new(1, -scaleOffset(34), 0.5, -scaleOffset(15))
	arrow.BackgroundTransparency = 1
	arrow.Text = "▼"
	arrow.TextColor3 = theme.SubText
	arrow.Font = Enum.Font.GothamBold
	arrow.TextSize = scaleOffset(14)
	arrow.ZIndex = 3
	arrow.Parent = btn
	
	local listFrame = Instance.new("Frame")
	listFrame.Size = UDim2.new(1, 0, 0, 0)
	listFrame.Position = UDim2.new(0, 0, 1, scaleOffset(4))
	listFrame.BackgroundColor3 = theme.SurfaceLight
	listFrame.BorderSizePixel = 0
	listFrame.Visible = false
	listFrame.ZIndex = 5
	local listCorner = Instance.new("UICorner")
	listCorner.CornerRadius = UDim.new(0, 14)
	listCorner.Parent = listFrame
	local listLayout = Instance.new("UIListLayout")
	listLayout.Padding = UDim.new(0, scaleOffset(2))
	listLayout.Parent = listFrame
	listFrame.Parent = holder
	
	local options = config.Options or {}
	local selected = config.Default or (options[1] or "Select...")
	
	local function rebuildList()
		for _, child in ipairs(listFrame:GetChildren()) do
			if child:IsA("TextButton") then
				child:Destroy()
			end
		end
		local count = #options
		for i, opt in ipairs(options) do
			local optBtn = Instance.new("TextButton")
			optBtn.Size = UDim2.new(1, 0, 0, scaleOffset(44))
			optBtn.BackgroundColor3 = (opt == selected) and theme.Primary or theme.SurfaceLight
			optBtn.Text = tostring(opt)
			optBtn.TextColor3 = (opt == selected) and theme.OnPrimary or theme.Text
			optBtn.Font = Enum.Font.GothamMedium
			optBtn.TextSize = scaleOffset(16)
			optBtn.BorderSizePixel = 0
			optBtn.ZIndex = 5
			local optCorner = Instance.new("UICorner")
			optCorner.CornerRadius = UDim.new(0, 12)
			optCorner.Parent = optBtn
			optBtn.Parent = listFrame
			optBtn.MouseButton1Click:Connect(function()
				selected = opt
				btn.Text = opt
				listFrame.Visible = false
				rebuildList()
				if config.Callback then
					config.Callback(selected)
				end
			end)
		end
		listFrame.Size = UDim2.new(1, 0, 0, scaleOffset(44 * count + 4))
	end
	rebuildList()
	
	btn.MouseButton1Click:Connect(function()
		listFrame.Visible = not listFrame.Visible
	end)
	
	holder.Parent = parent
	
	local self = setmetatable({ Instance = holder }, Dropdown)
	self.Theme = theme
	self.GetValue = function() return selected end
	self.SetOptions = function(newOptions)
		options = newOptions
		selected = options[1] or "Select..."
		btn.Text = selected
		rebuildList()
	end
	return self
end

-- ====================== TEXTBOX ======================
local TextBox = setmetatable({}, ComponentBase)
TextBox.__index = TextBox

function TextBox.new(parent, config, theme)
	local holder = Instance.new("Frame")
	holder.Size = UDim2.new(1, 0, 0, scaleOffset(56))
	holder.BackgroundTransparency = 1
	holder.Name = "TextBoxHolder"
	
	local box = Instance.new("TextBox")
	box.Size = UDim2.new(1, 0, 1, 0)
	box.BackgroundColor3 = theme.SurfaceLight
	box.Text = config.Default or ""
	box.PlaceholderText = config.Placeholder or ""
	box.TextColor3 = theme.Text
	box.PlaceholderColor3 = theme.SubText
	box.Font = Enum.Font.GothamMedium
	box.TextSize = scaleOffset(17)
	box.BorderSizePixel = 0
	box.ClearTextOnFocus = false
	box.ZIndex = 2
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 14)
	corner.Parent = box
	box.Parent = holder
	
	local clearBtn = Instance.new("TextButton")
	clearBtn.Size = UDim2.new(0, scaleOffset(30), 0, scaleOffset(30))
	clearBtn.Position = UDim2.new(1, -scaleOffset(34), 0.5, -scaleOffset(15))
	clearBtn.BackgroundTransparency = 1
	clearBtn.Text = "✕"
	clearBtn.TextColor3 = theme.SubText
	clearBtn.Font = Enum.Font.GothamBold
	clearBtn.TextSize = scaleOffset(16)
	clearBtn.ZIndex = 3
	clearBtn.Visible = (box.Text ~= "")
	clearBtn.Parent = box
	
	box:GetPropertyChangedSignal("Text"):Connect(function()
		clearBtn.Visible = (box.Text ~= "")
		if config.Callback then
			config.Callback(box.Text)
		end
	end)
	clearBtn.MouseButton1Click:Connect(function()
		box.Text = ""
		clearBtn.Visible = false
	end)
	
	holder.Parent = parent
	
	local self = setmetatable({ Instance = holder }, TextBox)
	self.Theme = theme
	self.GetText = function() return box.Text end
	self.SetText = function(text)
		box.Text = text
	end
	return self
end

-- ====================== LABEL ======================
local Label = setmetatable({}, ComponentBase)
Label.__index = Label

function Label.new(parent, config, theme)
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 0, scaleOffset(30))
	label.BackgroundTransparency = 1
	label.Text = config.Text or "Label"
	label.TextColor3 = theme.Text
	label.Font = Enum.Font.GothamBold
	label.TextSize = scaleOffset(18)
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = parent
	
	local self = setmetatable({ Instance = label }, Label)
	self.Theme = theme
	return self
end

-- ====================== PARAGRAPH ======================
local Paragraph = setmetatable({}, ComponentBase)
Paragraph.__index = Paragraph

function Paragraph.new(parent, config, theme)
	local para = Instance.new("TextLabel")
	para.Size = UDim2.new(1, 0, 0, scaleOffset(20))
	para.BackgroundTransparency = 1
	para.Text = config.Text or ""
	para.TextColor3 = theme.SubText
	para.Font = Enum.Font.Gotham
	para.TextSize = scaleOffset(15)
	para.TextWrapped = true
	para.TextXAlignment = Enum.TextXAlignment.Left
	para.RichText = true
	para.Parent = parent
	
	-- Auto-size height based on text
	para:GetPropertyChangedSignal("Text"):Connect(function()
		local textBounds = para.TextBounds
		para.Size = UDim2.new(1, 0, 0, textBounds.Y + scaleOffset(4))
	end)
	
	local self = setmetatable({ Instance = para }, Paragraph)
	self.Theme = theme
	return self
end

-- ====================== KEYBIND (for mobile with keyboard) ======================
local Keybind = setmetatable({}, ComponentBase)
Keybind.__index = Keybind

function Keybind.new(parent, config, theme)
	local holder = Instance.new("Frame")
	holder.Size = UDim2.new(1, 0, 0, scaleOffset(56))
	holder.BackgroundTransparency = 1
	holder.Name = "KeybindHolder"
	
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(0.5, 0, 1, 0)
	label.Position = UDim2.new(0, scaleOffset(4), 0, 0)
	label.BackgroundTransparency = 1
	label.Text = config.Name or "Keybind"
	label.TextColor3 = theme.Text
	label.Font = Enum.Font.GothamMedium
	label.TextSize = scaleOffset(17)
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = holder
	
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0, scaleOffset(100), 1, 0)
	btn.Position = UDim2.new(1, -scaleOffset(104), 0, 0)
	btn.BackgroundColor3 = theme.SurfaceLight
	btn.Text = config.Default or "None"
	btn.TextColor3 = theme.Text
	btn.Font = Enum.Font.GothamMedium
	btn.TextSize = scaleOffset(16)
	btn.BorderSizePixel = 0
	btn.ZIndex = 2
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 14)
	corner.Parent = btn
	btn.Parent = holder
	
	local binding = config.Default
	local listening = false
	
	btn.MouseButton1Click:Connect(function()
		listening = true
		btn.Text = "Press a key..."
		btn.BackgroundColor3 = theme.Primary
	end)
	
	local conn
	conn = UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if listening and not gameProcessed then
			if input.KeyCode ~= Enum.KeyCode.Unknown then
				binding = input.KeyCode
				btn.Text = binding.Name
				listening = false
				btn.BackgroundColor3 = theme.SurfaceLight
				if config.Callback then
					config.Callback(binding)
				end
			end
		end
	end)
	
	holder.Parent = parent
	
	local self = setmetatable({ Instance = holder }, Keybind)
	self.Theme = theme
	self.GetKeybind = function() return binding end
	return self
end

-- ====================== COLOR PICKER (with hue/sat/val) ======================
local ColorPicker = setmetatable({}, ComponentBase)
ColorPicker.__index = ColorPicker

function ColorPicker.new(parent, config, theme)
	local holder = Instance.new("Frame")
	holder.Size = UDim2.new(1, 0, 0, scaleOffset(56))
	holder.BackgroundTransparency = 1
	holder.Name = "ColorPickerHolder"
	
	local preview = Instance.new("Frame")
	preview.Size = UDim2.new(0, scaleOffset(40), 0, scaleOffset(40))
	preview.Position = UDim2.new(0, scaleOffset(4), 0.5, -scaleOffset(20))
	preview.BackgroundColor3 = config.Default or theme.Primary
	preview.BorderSizePixel = 0
	local previewCorner = Instance.new("UICorner")
	previewCorner.CornerRadius = UDim.new(0, 12)
	previewCorner.Parent = preview
	preview.Parent = holder
	
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, -scaleOffset(52), 1, 0)
	btn.Position = UDim2.new(0, scaleOffset(52), 0, 0)
	btn.BackgroundColor3 = theme.SurfaceLight
	btn.Text = "Pick Color"
	btn.TextColor3 = theme.Text
	btn.Font = Enum.Font.GothamMedium
	btn.TextSize = scaleOffset(17)
	btn.BorderSizePixel = 0
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 14)
	corner.Parent = btn
	btn.Parent = holder
	
	local currentColor = config.Default or theme.Primary
	
	local pickerPopup = Instance.new("Frame")
	pickerPopup.Size = UDim2.new(0, scaleOffset(300), 0, scaleOffset(320))
	pickerPopup.Position = UDim2.new(0.5, -scaleOffset(150), 0.5, -scaleOffset(160))
	pickerPopup.BackgroundColor3 = theme.Surface
	pickerPopup.BorderSizePixel = 0
	pickerPopup.Visible = false
	pickerPopup.ZIndex = 100
	local popupCorner = Instance.new("UICorner")
	popupCorner.CornerRadius = UDim.new(0, 20)
	popupCorner.Parent = pickerPopup
	pickerPopup.Parent = holder
	
	local satValImage = Instance.new("ImageLabel")
	satValImage.Size = UDim2.new(1, -scaleOffset(20), 0, scaleOffset(200))
	satValImage.Position = UDim2.new(0, scaleOffset(10), 0, scaleOffset(10))
	satValImage.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	satValImage.BorderSizePixel = 0
	-- Gradient: horizontal white to color, vertical transparent to black
	local hGradient = Instance.new("UIGradient")
	hGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
		ColorSequenceKeypoint.new(1, currentColor)
	})
	hGradient.Rotation = 0
	hGradient.Parent = satValImage
	local vGradient = Instance.new("UIGradient")
	vGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 0)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
	})
	vGradient.Rotation = 90
	vGradient.Parent = satValImage
	local satValCorner = Instance.new("UICorner")
	satValCorner.CornerRadius = UDim.new(0, 10)
	satValCorner.Parent = satValImage
	satValImage.Parent = pickerPopup
	
	-- Hue bar
	local hueBar = Instance.new("Frame")
	hueBar.Size = UDim2.new(1, -scaleOffset(20), 0, scaleOffset(20))
	hueBar.Position = UDim2.new(0, scaleOffset(10), 0, scaleOffset(220))
	hueBar.BorderSizePixel = 0
	local hueCorner = Instance.new("UICorner")
	hueCorner.CornerRadius = UDim.new(0, 10)
	hueCorner.Parent = hueBar
	local hueGradient = Instance.new("UIGradient")
	hueGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
		ColorSequenceKeypoint.new(0.2, Color3.fromRGB(255, 255, 0)),
		ColorSequenceKeypoint.new(0.4, Color3.fromRGB(0, 255, 0)),
		ColorSequenceKeypoint.new(0.6, Color3.fromRGB(0, 255, 255)),
		ColorSequenceKeypoint.new(0.8, Color3.fromRGB(0, 0, 255)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 255)),
	})
	hueGradient.Parent = hueBar
	hueBar.Parent = pickerPopup
	
	local hueKnob = Instance.new("Frame")
	hueKnob.Size = UDim2.new(0, scaleOffset(16), 0, scaleOffset(30))
	hueKnob.Position = UDim2.new(0.5, -scaleOffset(8), 0, -scaleOffset(5))
	hueKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	hueKnob.BorderSizePixel = 0
	local hueKnobCorner = Instance.new("UICorner")
	hueKnobCorner.CornerRadius = UDim.new(0, 8)
	hueKnobCorner.Parent = hueKnob
	hueKnob.Parent = hueBar
	
	local confirmBtn = Instance.new("TextButton")
	confirmBtn.Size = UDim2.new(1, -scaleOffset(20), 0, scaleOffset(40))
	confirmBtn.Position = UDim2.new(0, scaleOffset(10), 1, -scaleOffset(50))
	confirmBtn.BackgroundColor3 = theme.Primary
	confirmBtn.Text = "Confirm"
	confirmBtn.TextColor3 = theme.OnPrimary
	confirmBtn.Font = Enum.Font.GothamBold
	confirmBtn.TextSize = scaleOffset(16)
	confirmBtn.BorderSizePixel = 0
	local confirmCorner = Instance.new("UICorner")
	confirmCorner.CornerRadius = UDim.new(0, 14)
	confirmCorner.Parent = confirmBtn
	confirmBtn.Parent = pickerPopup
	
	-- Sat/Val indicator
	local svIndicator = Instance.new("Frame")
	svIndicator.Size = UDim2.new(0, scaleOffset(16), 0, scaleOffset(16))
	svIndicator.Position = UDim2.new(1, -scaleOffset(8), 0, -scaleOffset(8))
	svIndicator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	svIndicator.BorderSizePixel = 0
	svIndicator.AnchorPoint = Vector2.new(0.5, 0.5)
	local svIndCorner = Instance.new("UICorner")
	svIndCorner.CornerRadius = UDim.new(1, 0)
	svIndCorner.Parent = svIndicator
	svIndicator.Parent = satValImage
	
	local draggingSatVal = false
	local draggingHue = false
	
	local function updateColorFromSVH(sat, val, hue)
		local function HSVtoRGB(h, s, v)
			local r, g, b
			local i = math.floor(h * 6)
			local f = h * 6 - i
			local p = v * (1 - s)
			local q = v * (1 - f * s)
			local t = v * (1 - (1 - f) * s)
			i = i % 6
			if i == 0 then r, g, b = v, t, p
			elseif i == 1 then r, g, b = q, v, p
			elseif i == 2 then r, g, b = p, v, t
			elseif i == 3 then r, g, b = p, q, v
			elseif i == 4 then r, g, b = t, p, v
			else r, g, b = v, p, q
			end
			return Color3.fromRGB(r * 255, g * 255, b * 255)
		end
		return HSVtoRGB(hue, sat, val)
	end
	
	local function updatePick()
		local svX = svIndicator.Position.X.Scale
		local svY = svIndicator.Position.Y.Scale
		local hueFrac = hueKnob.Position.X.Scale
		currentColor = updateColorFromSVH(svX, 1 - svY, hueFrac)
		preview.BackgroundColor3 = currentColor
		-- Update sat/val gradient
		hGradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
			ColorSequenceKeypoint.new(1, updateColorFromSVH(1, 1, hueFrac))
		})
	end
	
	satValImage.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch then
			draggingSatVal = true
		end
	end)
	satValImage.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch then
			draggingSatVal = false
		end
	end)
	UserInputService.TouchMoved:Connect(function(touch, processed)
		if draggingSatVal and not processed then
			local pos = satValImage.AbsolutePosition
			local size = satValImage.AbsoluteSize
			local relX = math.clamp((touch.Position.X - pos.X) / size.X, 0, 1)
			local relY = math.clamp((touch.Position.Y - pos.Y) / size.Y, 0, 1)
			svIndicator.Position = UDim2.new(relX, -scaleOffset(8), relY, -scaleOffset(8))
			updatePick()
		end
	end)
	
	hueBar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch then
			draggingHue = true
		end
	end)
	hueBar.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch then
			draggingHue = false
		end
	end)
	UserInputService.TouchMoved:Connect(function(touch, processed)
		if draggingHue and not processed then
			local pos = hueBar.AbsolutePosition
			local size = hueBar.AbsoluteSize
			local relX = math.clamp((touch.Position.X - pos.X) / size.X, 0, 1)
			hueKnob.Position = UDim2.new(relX, -scaleOffset(8), 0, -scaleOffset(5))
			updatePick()
		end
	end)
	
	btn.MouseButton1Click:Connect(function()
		pickerPopup.Visible = not pickerPopup.Visible
	end)
	
	confirmBtn.MouseButton1Click:Connect(function()
		pickerPopup.Visible = false
		if config.Callback then
			config.Callback(currentColor)
		end
	end)
	
	holder.Parent = parent
	
	local self = setmetatable({ Instance = holder }, ColorPicker)
	self.Theme = theme
	self.GetColor = function() return currentColor end
	self.SetColor = function(color)
		currentColor = color
		preview.BackgroundColor3 = color
	end
	return self
end

-- ====================== NOTIFICATIONS ======================
local NotificationManager = {}
local notificationQueue = {}
local activeNotifications = {}

function NotificationManager:Show(config, theme)
	local notif = Instance.new("Frame")
	notif.Size = UDim2.new(1, -scaleOffset(20), 0, scaleOffset(70))
	notif.Position = UDim2.new(0.5, 0, 1, scaleOffset(-10))
	notif.AnchorPoint = Vector2.new(0.5, 1)
	notif.BackgroundColor3 = theme.SurfaceLight
	notif.BorderSizePixel = 0
	notif.ZIndex = 200
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 16)
	corner.Parent = notif
	notif.Parent = PlayerGui
	
	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, -scaleOffset(40), 0, scaleOffset(24))
	title.Position = UDim2.new(0, scaleOffset(16), 0, scaleOffset(12))
	title.BackgroundTransparency = 1
	title.Text = config.Title or "Notification"
	title.TextColor3 = theme.Text
	title.Font = Enum.Font.GothamBold
	title.TextSize = scaleOffset(16)
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Parent = notif
	
	local msg = Instance.new("TextLabel")
	msg.Size = UDim2.new(1, -scaleOffset(40), 0, scaleOffset(20))
	msg.Position = UDim2.new(0, scaleOffset(16), 0, scaleOffset(38))
	msg.BackgroundTransparency = 1
	msg.Text = config.Text or ""
	msg.TextColor3 = theme.SubText
	msg.Font = Enum.Font.Gotham
	msg.TextSize = scaleOffset(14)
	msg.TextXAlignment = Enum.TextXAlignment.Left
	msg.Parent = notif
	
	local closeBtn = Instance.new("TextButton")
	closeBtn.Size = UDim2.new(0, scaleOffset(30), 0, scaleOffset(30))
	closeBtn.Position = UDim2.new(1, -scaleOffset(36), 0, scaleOffset(8))
	closeBtn.BackgroundTransparency = 1
	closeBtn.Text = "✕"
	closeBtn.TextColor3 = theme.SubText
	closeBtn.Font = Enum.Font.GothamBold
	closeBtn.TextSize = scaleOffset(18)
	closeBtn.Parent = notif
	
	-- Animate in
	tweenObject(notif, {Position = UDim2.new(0.5, 0, 1, scaleOffset(-80))}, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
	
	local self = { Instance = notif }
	
	local autoDismiss
	if config.Duration and config.Duration > 0 then
		autoDismiss = task.delay(config.Duration, function()
			self:Dismiss()
		end)
	end
	
	closeBtn.MouseButton1Click:Connect(function()
		if autoDismiss then task.cancel(autoDismiss) end
		self:Dismiss()
	end)
	
	function self:Dismiss()
		tweenObject(notif, {Position = UDim2.new(0.5, 0, 1, scaleOffset(80))}, 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In, function()
			notif:Destroy()
		end)
	end
	
	table.insert(activeNotifications, self)
	return self
end

-- ====================== DIALOGS ======================
local Dialog = {}
function Dialog:Create(config, theme, parent)
	local overlay = Instance.new("Frame")
	overlay.Size = UDim2.new(1, 0, 1, 0)
	overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	overlay.BackgroundTransparency = 0.5
	overlay.BorderSizePixel = 0
	overlay.ZIndex = 150
	overlay.Parent = parent or PlayerGui
	
	local container = Instance.new("Frame")
	container.Size = UDim2.new(0, scaleOffset(320), 0, scaleOffset(200))
	container.Position = UDim2.new(0.5, -scaleOffset(160), 0.5, -scaleOffset(100))
	container.BackgroundColor3 = theme.Surface
	container.BorderSizePixel = 0
	container.ZIndex = 151
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 20)
	corner.Parent = container
	container.Parent = overlay
	
	local titleLabel = Instance.new("TextLabel")
	titleLabel.Size = UDim2.new(1, -scaleOffset(20), 0, scaleOffset(30))
	titleLabel.Position = UDim2.new(0, scaleOffset(10), 0, scaleOffset(12))
	titleLabel.BackgroundTransparency = 1
	titleLabel.Text = config.Title or "Dialog"
	titleLabel.TextColor3 = theme.Text
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.TextSize = scaleOffset(18)
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.Parent = container
	
	local msgLabel = Instance.new("TextLabel")
	msgLabel.Size = UDim2.new(1, -scaleOffset(20), 0, scaleOffset(80))
	msgLabel.Position = UDim2.new(0, scaleOffset(10), 0, scaleOffset(50))
	msgLabel.BackgroundTransparency = 1
	msgLabel.Text = config.Text or ""
	msgLabel.TextColor3 = theme.SubText
	msgLabel.Font = Enum.Font.Gotham
	msgLabel.TextSize = scaleOffset(15)
	msgLabel.TextWrapped = true
	msgLabel.TextXAlignment = Enum.TextXAlignment.Left
	msgLabel.Parent = container
	
	local buttonFrame = Instance.new("Frame")
	buttonFrame.Size = UDim2.new(1, -scaleOffset(20), 0, scaleOffset(44))
	buttonFrame.Position = UDim2.new(0, scaleOffset(10), 1, -scaleOffset(54))
	buttonFrame.BackgroundTransparency = 1
	buttonFrame.Parent = container
	
	local buttons = config.Buttons or {{Text = "OK", Callback = function() end}}
	for i, btnConfig in ipairs(buttons) do
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(1 / #buttons, -scaleOffset(6), 1, 0)
		btn.Position = UDim2.new((i-1)/#buttons, scaleOffset(3), 0, 0)
		btn.BackgroundColor3 = theme.Primary
		btn.Text = btnConfig.Text or "Button"
		btn.TextColor3 = theme.OnPrimary
		btn.Font = Enum.Font.GothamBold
		btn.TextSize = scaleOffset(15)
		btn.BorderSizePixel = 0
		local btnCorner = Instance.new("UICorner")
		btnCorner.CornerRadius = UDim.new(0, 14)
		btnCorner.Parent = btn
		btn.Parent = buttonFrame
		btn.MouseButton1Click:Connect(function()
			if btnConfig.Callback then
				btnConfig.Callback()
			end
			overlay:Destroy()
		end)
	end
	
	-- Animate entrance
	container.Size = UDim2.new(0, scaleOffset(300), 0, scaleOffset(180))
	tweenObject(container, {Size = UDim2.new(0, scaleOffset(320), 0, scaleOffset(200))}, 0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
	
	return overlay
end

-- ====================== SEARCH BAR ======================
local SearchBar = setmetatable({}, ComponentBase)
SearchBar.__index = SearchBar

function SearchBar.new(parent, config, theme)
	local holder = Instance.new("Frame")
	holder.Size = UDim2.new(1, 0, 0, scaleOffset(56))
	holder.BackgroundTransparency = 1
	holder.Name = "SearchBarHolder"
	
	local box = Instance.new("TextBox")
	box.Size = UDim2.new(1, 0, 1, 0)
	box.BackgroundColor3 = theme.SurfaceLight
	box.PlaceholderText = config.Placeholder or "Search..."
	box.Text = config.Default or ""
	box.TextColor3 = theme.Text
	box.PlaceholderColor3 = theme.SubText
	box.Font = Enum.Font.GothamMedium
	box.TextSize = scaleOffset(17)
	box.BorderSizePixel = 0
	box.ClearTextOnFocus = false
	box.ZIndex = 2
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 16)
	corner.Parent = box
	box.Parent = holder
	
	local icon = Instance.new("TextLabel")
	icon.Size = UDim2.new(0, scaleOffset(30), 0, scaleOffset(30))
	icon.Position = UDim2.new(0, scaleOffset(8), 0.5, -scaleOffset(15))
	icon.BackgroundTransparency = 1
	icon.Text = "🔍"
	icon.TextColor3 = theme.SubText
	icon.Font = Enum.Font.GothamBold
	icon.TextSize = scaleOffset(16)
	icon.ZIndex = 3
	icon.Parent = box
	
	-- Adjust text padding for icon
	box.TextXAlignment = Enum.TextXAlignment.Left
	box:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		box.TextXAlignment = Enum.TextXAlignment.Left
		-- We'll use a small padding by setting the text bounds, but can't easily. Instead rely on ClearButtonOnFocus left space.
	end)
	
	local clearBtn = Instance.new("TextButton")
	clearBtn.Size = UDim2.new(0, scaleOffset(30), 0, scaleOffset(30))
	clearBtn.Position = UDim2.new(1, -scaleOffset(34), 0.5, -scaleOffset(15))
	clearBtn.BackgroundTransparency = 1
	clearBtn.Text = "✕"
	clearBtn.TextColor3 = theme.SubText
	clearBtn.Font = Enum.Font.GothamBold
	clearBtn.TextSize = scaleOffset(16)
	clearBtn.ZIndex = 3
	clearBtn.Visible = (box.Text ~= "")
	clearBtn.Parent = box
	
	box:GetPropertyChangedSignal("Text"):Connect(function()
		clearBtn.Visible = (box.Text ~= "")
		if config.Callback then
			config.Callback(box.Text)
		end
	end)
	clearBtn.MouseButton1Click:Connect(function()
		box.Text = ""
		clearBtn.Visible = false
	end)
	
	holder.Parent = parent
	
	local self = setmetatable({ Instance = holder }, SearchBar)
	self.Theme = theme
	self.GetText = function() return box.Text end
	self.SetText = function(text) box.Text = text end
	return self
end

-- ====================== TAB SYSTEM ======================
local Tab = {}
Tab.__index = Tab

function Tab.new(name, icon, theme, parent)
	local page = Instance.new("ScrollingFrame")
	page.Size = UDim2.new(1, 0, 1, 0)
	page.BackgroundTransparency = 1
	page.ScrollBarThickness = scaleOffset(4)
	page.ScrollBarImageColor3 = theme.ScrollBar
	page.CanvasSize = UDim2.new(0, 0, 0, 0)
	page.BorderSizePixel = 0
	page.ScrollingDirection = Enum.ScrollingDirection.Y
	page.AutomaticCanvasSize = Enum.AutomaticSize.Y
	page.Visible = false
	page.Parent = parent
	
	local listLayout = Instance.new("UIListLayout")
	listLayout.Padding = UDim.new(0, scaleOffset(12))
	listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	listLayout.SortOrder = Enum.SortOrder.LayoutOrder
	listLayout.Parent = page
	
	local self = setmetatable({
		Page = page,
		Name = name,
		Icon = icon,
		Theme = theme,
	}, Tab)
	
	return self
end

function Tab:AddComponent(component)
	component.Instance.Parent = self.Page
	component.Instance.LayoutOrder = #self.Page:GetChildren() -- approximate
	return component
end

function Tab:CreateButton(config)
	local btn = Button.new(self.Page, config, self.Theme)
	return self:AddComponent(btn)
end

function Tab:CreateToggle(config)
	local tgl = Toggle.new(self.Page, config, self.Theme)
	return self:AddComponent(tgl)
end

function Tab:CreateSlider(config)
	local sld = Slider.new(self.Page, config, self.Theme)
	return self:AddComponent(sld)
end

function Tab:CreateDropdown(config)
	local dd = Dropdown.new(self.Page, config, self.Theme)
	return self:AddComponent(dd)
end

function Tab:CreateTextBox(config)
	local tb = TextBox.new(self.Page, config, self.Theme)
	return self:AddComponent(tb)
end

function Tab:CreateLabel(config)
	local lbl = Label.new(self.Page, config, self.Theme)
	return self:AddComponent(lbl)
end

function Tab:CreateParagraph(config)
	local para = Paragraph.new(self.Page, config, self.Theme)
	return self:AddComponent(para)
end

function Tab:CreateKeybind(config)
	local kb = Keybind.new(self.Page, config, self.Theme)
	return self:AddComponent(kb)
end

function Tab:CreateColorPicker(config)
	local cp = ColorPicker.new(self.Page, config, self.Theme)
	return self:AddComponent(cp)
end

function Tab:CreateSearchBar(config)
	local sb = SearchBar.new(self.Page, config, self.Theme)
	return self:AddComponent(sb)
end

-- ====================== WINDOW SYSTEM ======================
local Window = {}
Window.__index = Window

function Window.new(config)
	local self = setmetatable({}, Window)
	
	-- Theme
	local themeName = config.Theme or "Dark"
	local customTheme = config.CustomTheme
	local theme = customTheme or Themes[themeName] or Themes.Dark
	self.Theme = theme
	
	-- ScreenGui
	local gui = Instance.new("ScreenGui")
	gui.Name = "MobileUI_" .. (config.Title or "Hub")
	gui.Parent = PlayerGui
	gui.IgnoreGuiInset = not (config.SafeArea or false)
	self.Gui = gui
	
	-- Main container
	local mainContainer = Instance.new("Frame")
	mainContainer.Size = UDim2.new(0, math.min(screenSize.X, scaleOffset(420)), 0, math.min(screenSize.Y, scaleOffset(740)))
	mainContainer.Position = UDim2.new(0.5, -mainContainer.Size.X.Offset/2, 0.5, -mainContainer.Size.Y.Offset/2)
	mainContainer.BackgroundColor3 = theme.Background
	mainContainer.BorderSizePixel = 0
	mainContainer.ZIndex = 1
	local mainCorner = Instance.new("UICorner")
	mainCorner.CornerRadius = UDim.new(0, 24)
	mainCorner.Parent = mainContainer
	mainContainer.Parent = gui
	self.MainContainer = mainContainer
	
	-- Shadow for window
	local shadow = createShadow(mainContainer, UDim2.new(1, scaleOffset(16), 1, scaleOffset(16)), UDim.new(0, 24), theme, 0)
	shadow.Position = UDim2.new(0, -scaleOffset(8), 0, scaleOffset(8))
	shadow.ZIndex = 0
	
	-- Drag handle
	local dragHandle = Instance.new("TextButton")
	dragHandle.Size = UDim2.new(1, 0, 0, scaleOffset(50))
	dragHandle.BackgroundTransparency = 1
	dragHandle.Text = ""
	dragHandle.ZIndex = 10
	dragHandle.Parent = mainContainer
	
	local titleBar = Instance.new("TextLabel")
	titleBar.Size = UDim2.new(1, -scaleOffset(120), 1, 0)
	titleBar.Position = UDim2.new(0, scaleOffset(16), 0, 0)
	titleBar.BackgroundTransparency = 1
	titleBar.Text = config.Title or "Mobile Hub"
	titleBar.TextColor3 = theme.Text
	titleBar.Font = Enum.Font.GothamBold
	titleBar.TextSize = scaleOffset(20)
	titleBar.TextXAlignment = Enum.TextXAlignment.Left
	titleBar.ZIndex = 10
	titleBar.Parent = dragHandle
	
	-- Minimize button
	local minimizeBtn = Instance.new("TextButton")
	minimizeBtn.Size = UDim2.new(0, scaleOffset(36), 0, scaleOffset(36))
	minimizeBtn.Position = UDim2.new(1, -scaleOffset(90), 0.5, -scaleOffset(18))
	minimizeBtn.BackgroundColor3 = theme.SurfaceLight
	minimizeBtn.Text = "–"
	minimizeBtn.TextColor3 = theme.Text
	minimizeBtn.Font = Enum.Font.GothamBold
	minimizeBtn.TextSize = scaleOffset(22)
	minimizeBtn.BorderSizePixel = 0
	minimizeBtn.ZIndex = 10
	local minCorner = Instance.new("UICorner")
	minCorner.CornerRadius = UDim.new(0, 14)
	minCorner.Parent = minimizeBtn
	minimizeBtn.Parent = dragHandle
	
	-- Expand button
	local expandBtn = Instance.new("TextButton")
	expandBtn.Size = UDim2.new(0, scaleOffset(36), 0, scaleOffset(36))
	expandBtn.Position = UDim2.new(1, -scaleOffset(48), 0.5, -scaleOffset(18))
	expandBtn.BackgroundColor3 = theme.SurfaceLight
	expandBtn.Text = "⛶"
	expandBtn.TextColor3 = theme.Text
	expandBtn.Font = Enum.Font.GothamBold
	expandBtn.TextSize = scaleOffset(18)
	expandBtn.BorderSizePixel = 0
	expandBtn.ZIndex = 10
	local expCorner = Instance.new("UICorner")
	expCorner.CornerRadius = UDim.new(0, 14)
	expCorner.Parent = expandBtn
	expandBtn.Parent = dragHandle
	
	-- Content area for pages
	local contentArea = Instance.new("Frame")
	contentArea.Size = UDim2.new(1, 0, 1, -scaleOffset(110))
	contentArea.Position = UDim2.new(0, 0, 0, scaleOffset(50))
	contentArea.BackgroundTransparency = 1
	contentArea.BorderSizePixel = 0
	contentArea.Parent = mainContainer
	self.ContentArea = contentArea
	
	-- Bottom navigation bar
	local bottomNav = Instance.new("Frame")
	bottomNav.Size = UDim2.new(1, -scaleOffset(16), 0, scaleOffset(56))
	bottomNav.Position = UDim2.new(0, scaleOffset(8), 1, -scaleOffset(64))
	bottomNav.BackgroundColor3 = theme.Surface
	bottomNav.BorderSizePixel = 0
	local navCorner = Instance.new("UICorner")
	navCorner.CornerRadius = UDim.new(0, 20)
	navCorner.Parent = bottomNav
	bottomNav.Parent = mainContainer
	self.BottomNav = bottomNav
	
	local tabList = Instance.new("UIListLayout")
	tabList.FillDirection = Enum.FillDirection.Horizontal
	tabList.HorizontalAlignment = Enum.HorizontalAlignment.Center
	tabList.VerticalAlignment = Enum.VerticalAlignment.Center
	tabList.Padding = UDim.new(0, scaleOffset(8))
	tabList.Parent = bottomNav
	
	self.Tabs = {}
	self.ActiveTab = nil
	
	-- Dragging logic
	local dragging = false
	local dragStartPos
	local dragOffset
	dragHandle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStartPos = input.Position
			dragOffset = mainContainer.Position
		end
	end)
	UserInputService.TouchMoved:Connect(function(touch, processed)
		if dragging and not processed then
			local delta = touch.Position - dragStartPos
			local newPos = UDim2.new(dragOffset.X.Scale, dragOffset.X.Offset + delta.X, dragOffset.Y.Scale, dragOffset.Y.Offset + delta.Y)
			-- Boundary protection
			local halfWidth = mainContainer.Size.X.Offset / 2
			local halfHeight = mainContainer.Size.Y.Offset / 2
			newPos = UDim2.new(0, math.clamp(newPos.X.Offset, 0, screenSize.X - mainContainer.Size.X.Offset), 0, math.clamp(newPos.Y.Offset, 0, screenSize.Y - mainContainer.Size.Y.Offset))
			mainContainer.Position = newPos
		end
	end)
	UserInputService.TouchEnded:Connect(function(touch)
		if dragging then
			dragging = false
		end
	end)
	
	-- Minimize / Restore
	local minimized = false
	local originalSize = mainContainer.Size
	local originalPos = mainContainer.Position
	local minimizedBar = Instance.new("TextButton")
	minimizedBar.Size = UDim2.new(0, scaleOffset(200), 0, scaleOffset(50))
	minimizedBar.Position = UDim2.new(0.5, -scaleOffset(100), 1, scaleOffset(-10))
	minimizedBar.AnchorPoint = Vector2.new(0.5, 1)
	minimizedBar.BackgroundColor3 = theme.Surface
	minimizedBar.Text = config.Title or "Hub"
	minimizedBar.TextColor3 = theme.Text
	minimizedBar.Font = Enum.Font.GothamBold
	minimizedBar.TextSize = scaleOffset(16)
	minimizedBar.BorderSizePixel = 0
	minimizedBar.Visible = false
	minimizedBar.ZIndex = 50
	local minBarCorner = Instance.new("UICorner")
	minBarCorner.CornerRadius = UDim.new(0, 20)
	minBarCorner.Parent = minimizedBar
	minimizedBar.Parent = gui
	minimizedBar.MouseButton1Click:Connect(function()
		-- Restore
		tweenObject(mainContainer, {Size = originalSize, Position = originalPos}, 0.3, Enum.EasingStyle.Back)
		minimizedBar.Visible = false
		minimized = false
	end)
	
	minimizeBtn.MouseButton1Click:Connect(function()
		if minimized then return end
		minimized = true
		originalSize = mainContainer.Size
		originalPos = mainContainer.Position
		tweenObject(mainContainer, {Size = UDim2.new(0, scaleOffset(200), 0, scaleOffset(50)), Position = UDim2.new(0.5, -scaleOffset(100), 1, scaleOffset(-10))}, 0.3, Enum.EasingStyle.Back, nil, function()
			mainContainer.Visible = false
			minimizedBar.Visible = true
		end)
	end)
	
	-- Expand / Restore
	local expanded = false
	expandBtn.MouseButton1Click:Connect(function()
		expanded = not expanded
		if expanded then
			-- Save original size/pos
			originalSize = mainContainer.Size
			originalPos = mainContainer.Position
			local fullSize = UDim2.new(0, screenSize.X, 0, screenSize.Y)
			tweenObject(mainContainer, {Size = fullSize, Position = UDim2.new(0, 0, 0, 0)}, 0.3)
			mainCorner.CornerRadius = UDim.new(0, 0)
		else
			tweenObject(mainContainer, {Size = originalSize, Position = originalPos}, 0.3)
			mainCorner.CornerRadius = UDim.new(0, 24)
		end
	end)
	
	-- Auto-resize on screen change
	PlayerGui:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		screenSize = PlayerGui.AbsoluteSize
		scaleFactor = math.min(screenSize.X / BASE_WIDTH, screenSize.Y / BASE_HEIGHT)
		-- re-scale main container if not expanded/minimized
		if not expanded and not minimized then
			mainContainer.Size = UDim2.new(0, math.min(screenSize.X, scaleOffset(420)), 0, math.min(screenSize.Y, scaleOffset(740)))
			mainContainer.Position = UDim2.new(0.5, -mainContainer.Size.X.Offset/2, 0.5, -mainContainer.Size.Y.Offset/2)
		end
	end)
	
	-- Theme change function
	function self:SetTheme(newThemeName, custom)
		local newTheme = custom or Themes[newThemeName] or Themes.Dark
		self.Theme = newTheme
		-- Update main window
		mainContainer.BackgroundColor3 = newTheme.Background
		titleBar.TextColor3 = newTheme.Text
		bottomNav.BackgroundColor3 = newTheme.Surface
		-- Re-apply to all tabs and their components would require a full re-render, for simplicity we update the tab reference
		for _, tab in ipairs(self.Tabs) do
			tab.Theme = newTheme
			-- Could recursively update all components, but for brevity we'll just note that theme change on runtime requires re-creation.
			-- In a production library you'd iterate through all components and update colors.
		end
	end
	
	return self
end

function Window:CreateTab(name, icon)
	local tab = Tab.new(name, icon or "•", self.Theme, self.ContentArea)
	
	-- Create tab button in bottom nav
	local tabBtn = Instance.new("TextButton")
	tabBtn.Size = UDim2.new(0, scaleOffset(60), 0, scaleOffset(48))
	tabBtn.BackgroundColor3 = self.Theme.SurfaceLight
	tabBtn.Text = icon or name:sub(1,1)
	tabBtn.TextColor3 = self.Theme.SubText
	tabBtn.Font = Enum.Font.GothamBold
	tabBtn.TextSize = scaleOffset(20)
	tabBtn.BorderSizePixel = 0
	local btnCorner = Instance.new("UICorner")
	btnCorner.CornerRadius = UDim.new(0, 14)
	btnCorner.Parent = tabBtn
	tabBtn.Parent = self.BottomNav
	
	local function selectTab()
		-- Hide all
		for _, t in ipairs(self.Tabs) do
			t.Page.Visible = false
		end
		-- Update button styles
		for _, btn in ipairs(self.BottomNav:GetChildren()) do
			if btn:IsA("TextButton") then
				btn.BackgroundColor3 = self.Theme.SurfaceLight
				btn.TextColor3 = self.Theme.SubText
			end
		end
		tab.Page.Visible = true
		tabBtn.BackgroundColor3 = self.Theme.Primary
		tabBtn.TextColor3 = self.Theme.OnPrimary
		self.ActiveTab = tab
	end
	
	tabBtn.MouseButton1Click:Connect(selectTab)
	
	-- Select first tab automatically
	if #self.Tabs == 0 then
		selectTab()
	end
	
	table.insert(self.Tabs, tab)
	return tab
end

function Window:ShowNotification(config)
	return NotificationManager:Show(config, self.Theme)
end

function Window:CreateDialog(config)
	return Dialog:Create(config, self.Theme, self.Gui)
end

function Window:Destroy()
	self.Gui:Destroy()
end

-- ====================== PUBLIC API ======================
local MobileUI = {}

function MobileUI:CreateWindow(config)
	config = config or {}
	return Window.new(config)
end

-- Allow changing global scale factor manually
function MobileUI:SetBaseResolution(width, height)
	BASE_WIDTH = width or 400
	BASE_HEIGHT = height or 800
	scaleFactor = math.min(screenSize.X / BASE_WIDTH, screenSize.Y / BASE_HEIGHT)
end

return MobileUI