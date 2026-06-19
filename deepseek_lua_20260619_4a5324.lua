--[[
    MobileUI – Refined Premium Mobile-First UI Library for Roblox
    • OLED black background, electric purple accent  
    • Sharp 4–6 px corners, compact sizing  
    • Pure white typography, subtle glass borders  
    • All scaling still based on workspace.CurrentCamera.ViewportSize  
    • Touch-friendly, 60 FPS, mobile-native experience
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Camera = Workspace.CurrentCamera

-- ====================== THEME SYSTEM (REDESIGNED) ======================
local Themes = {
	Dark = {
		Name = "Dark",
		Background = Color3.fromRGB(10, 10, 15),        -- OLED black
		Surface = Color3.fromRGB(20, 20, 30),
		SurfaceLight = Color3.fromRGB(35, 35, 50),
		Primary = Color3.fromRGB(187, 0, 255),           -- Electric purple
		OnPrimary = Color3.fromRGB(255, 255, 255),
		Secondary = Color3.fromRGB(40, 40, 55),
		OnSecondary = Color3.fromRGB(200, 200, 210),
		Text = Color3.fromRGB(255, 255, 255),            -- pure white
		SubText = Color3.fromRGB(160, 160, 170),
		Border = Color3.fromRGB(60, 60, 75),
		Shadow = Color3.fromRGB(0, 0, 0),
		ScrollBar = Color3.fromRGB(100, 100, 120),
		Glass = Color3.fromRGB(255, 255, 255),
	},
	AMOLED = {
		Name = "AMOLED",
		Background = Color3.fromRGB(0, 0, 0),            -- true AMOLED black
		Surface = Color3.fromRGB(8, 8, 16),
		SurfaceLight = Color3.fromRGB(18, 18, 28),
		Primary = Color3.fromRGB(0, 255, 200),           -- Neon cyan accent
		OnPrimary = Color3.fromRGB(0, 0, 0),             -- black text on bright accent
		Secondary = Color3.fromRGB(30, 30, 40),
		OnSecondary = Color3.fromRGB(180, 180, 190),
		Text = Color3.fromRGB(240, 240, 245),
		SubText = Color3.fromRGB(150, 150, 160),
		Border = Color3.fromRGB(40, 40, 55),
		Shadow = Color3.fromRGB(0, 0, 0),
		ScrollBar = Color3.fromRGB(80, 80, 100),
		Glass = Color3.fromRGB(255, 255, 255),
	},
	Midnight = {
		Name = "Midnight",
		Background = Color3.fromRGB(5, 5, 15),
		Surface = Color3.fromRGB(12, 12, 28),
		SurfaceLight = Color3.fromRGB(24, 24, 42),
		Primary = Color3.fromRGB(120, 80, 255),
		OnPrimary = Color3.fromRGB(255, 255, 255),
		Secondary = Color3.fromRGB(30, 30, 50),
		OnSecondary = Color3.fromRGB(190, 190, 210),
		Text = Color3.fromRGB(230, 230, 250),
		SubText = Color3.fromRGB(140, 140, 160),
		Border = Color3.fromRGB(50, 50, 80),
		Shadow = Color3.fromRGB(0, 0, 0),
		ScrollBar = Color3.fromRGB(90, 90, 110),
		Glass = Color3.fromRGB(255, 255, 255),
	},
}

-- ====================== UTILITY ======================
local function createShadow(parent, size, cornerRadius, theme, zIndex)
	local shadow = Instance.new("Frame")
	shadow.Name = "Shadow"
	shadow.Size = size
	shadow.BackgroundColor3 = theme.Shadow
	shadow.BackgroundTransparency = 0.9
	shadow.BorderSizePixel = 0
	shadow.ZIndex = zIndex or 0
	local corner = Instance.new("UICorner")
	corner.CornerRadius = cornerRadius or UDim.new(0, 6)
	corner.Parent = shadow
	shadow.Parent = parent
	return shadow
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

-- ====================== SCALING (Camera.ViewportSize – KEPT INTACT) ======================
local BASE_WIDTH = 400
local BASE_HEIGHT = 800
local screenSize = Camera.ViewportSize
local scaleFactor = math.min(screenSize.X / BASE_WIDTH, screenSize.Y / BASE_HEIGHT)

local function scaleOffset(offset)
	return offset * scaleFactor
end

-- ====================== COMPONENT BASE ======================
local ComponentBase = {}
ComponentBase.__index = ComponentBase

function ComponentBase.new(instance)
	return setmetatable({ Instance = instance }, ComponentBase)
end

-- ====================== BUTTON (compact, sharp) ======================
local Button = setmetatable({}, ComponentBase)
Button.__index = Button

function Button.new(parent, config, theme)
	local holder = Instance.new("Frame")
	holder.Size = UDim2.new(1, 0, 0, scaleOffset(44))           -- reduced from 56
	holder.BackgroundTransparency = 1
	holder.Name = "ButtonHolder"

	local shadow = createShadow(holder, UDim2.new(1, 0, 1, 0), UDim.new(0, 6), theme, 0)
	shadow.Position = UDim2.new(0, 1, 0, 2)

	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, 0, 1, 0)
	btn.BackgroundColor3 = theme.Primary
	btn.Text = config.Name or "Button"
	btn.TextColor3 = theme.OnPrimary
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = scaleOffset(15)                              -- smaller, crisp
	btn.BorderSizePixel = 0
	btn.ZIndex = 2
	btn.Parent = holder

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 6)
	corner.Parent = btn

	-- razor-thin border (stroke)
	local stroke = Instance.new("UIStroke")
	stroke.Thickness = 1
	stroke.Color = theme.Glass
	stroke.Transparency = 0.85
	stroke.Parent = btn

	-- ripple effect (same logic)
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

	local originalSize = btn.Size
	btn.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch then
			tweenObject(btn, {Size = UDim2.new(1, -scaleOffset(4), 1, -scaleOffset(4))}, 0.1, Enum.EasingStyle.Quad)
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
			tweenObject(btn, {Size = originalSize}, 0.1, Enum.EasingStyle.Quad)
		end
	end)

	btn.MouseButton1Click:Connect(function()
		if config.Callback then config.Callback() end
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
	holder.Size = UDim2.new(1, 0, 0, scaleOffset(48))           -- slimmed
	holder.BackgroundTransparency = 1
	holder.Name = "ToggleHolder"

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(0.6, 0, 1, 0)
	label.Position = UDim2.new(0, scaleOffset(4), 0, 0)
	label.BackgroundTransparency = 1
	label.Text = config.Name or "Toggle"
	label.TextColor3 = theme.Text
	label.Font = Enum.Font.GothamMedium
	label.TextSize = scaleOffset(15)
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = holder

	local switchHolder = Instance.new("Frame")
	switchHolder.Size = UDim2.new(0, scaleOffset(52), 0, scaleOffset(30))
	switchHolder.Position = UDim2.new(1, -scaleOffset(56), 0.5, -scaleOffset(15))
	switchHolder.BackgroundColor3 = theme.Secondary
	switchHolder.BorderSizePixel = 0
	local switchCorner = Instance.new("UICorner")
	switchCorner.CornerRadius = UDim.new(0, 15)  -- pill shape
	switchCorner.Parent = switchHolder
	switchHolder.Parent = holder

	local knob = Instance.new("Frame")
	knob.Size = UDim2.new(0, scaleOffset(24), 0, scaleOffset(24))
	knob.Position = UDim2.new(0, scaleOffset(3), 0.5, -scaleOffset(12))
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
			tweenObject(knob, {Position = UDim2.new(1, -scaleOffset(27), 0.5, -scaleOffset(12))}, 0.2)
		else
			switchHolder.BackgroundColor3 = theme.Secondary
			tweenObject(knob, {Position = UDim2.new(0, scaleOffset(3), 0.5, -scaleOffset(12))}, 0.2)
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
		if config.Callback then config.Callback(state) end
	end)

	holder.Parent = parent
	local self = setmetatable({ Instance = holder, State = state }, Toggle)
	self.Theme = theme
	self.GetState = function() return state end
	self.SetState = function(s)
		state = s
		updateVisual()
	end
	return self
end

-- ====================== SLIDER ======================
local Slider = setmetatable({}, ComponentBase)
Slider.__index = Slider

function Slider.new(parent, config, theme)
	local holder = Instance.new("Frame")
	holder.Size = UDim2.new(1, 0, 0, scaleOffset(58))
	holder.BackgroundTransparency = 1
	holder.Name = "SliderHolder"

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(0.6, 0, 0, scaleOffset(20))
	label.Position = UDim2.new(0, scaleOffset(4), 0, scaleOffset(2))
	label.BackgroundTransparency = 1
	label.Text = config.Name or "Slider"
	label.TextColor3 = theme.Text
	label.Font = Enum.Font.GothamMedium
	label.TextSize = scaleOffset(15)
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = holder

	local valueLabel = Instance.new("TextLabel")
	valueLabel.Size = UDim2.new(0.4, 0, 0, scaleOffset(20))
	valueLabel.Position = UDim2.new(0.6, 0, 0, scaleOffset(2))
	valueLabel.BackgroundTransparency = 1
	valueLabel.TextColor3 = theme.SubText
	valueLabel.Font = Enum.Font.GothamMedium
	valueLabel.TextSize = scaleOffset(14)
	valueLabel.TextXAlignment = Enum.TextXAlignment.Right
	valueLabel.Text = tostring(config.Default or config.Min or 0)
	valueLabel.Parent = holder

	local track = Instance.new("Frame")
	track.Size = UDim2.new(1, -scaleOffset(8), 0, scaleOffset(6))
	track.Position = UDim2.new(0, scaleOffset(4), 0, scaleOffset(30))
	track.BackgroundColor3 = theme.Secondary
	track.BorderSizePixel = 0
	local trackCorner = Instance.new("UICorner")
	trackCorner.CornerRadius = UDim.new(0, 3)
	trackCorner.Parent = track
	track.Parent = holder

	local fill = Instance.new("Frame")
	fill.Size = UDim2.new(0, 0, 1, 0)
	fill.BackgroundColor3 = theme.Primary
	fill.BorderSizePixel = 0
	local fillCorner = Instance.new("UICorner")
	fillCorner.CornerRadius = UDim.new(0, 3)
	fillCorner.Parent = fill
	fill.Parent = track

	local knob = Instance.new("TextButton")
	knob.Size = UDim2.new(0, scaleOffset(24), 0, scaleOffset(24))
	knob.Position = UDim2.new(0, -scaleOffset(12), 0.5, -scaleOffset(12))
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
		knob.Position = UDim2.new(fraction, -scaleOffset(12), 0.5, -scaleOffset(12))
		valueLabel.Text = string.format("%.2f", value)
	end
	updateValue(value)

	knob.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch then dragging = true end
	end)
	knob.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch then dragging = false end
	end)
	UserInputService.TouchMoved:Connect(function(touch, processed)
		if dragging and not processed then
			local trackPos = track.AbsolutePosition
			local trackWidth = track.AbsoluteSize.X
			local relX = math.clamp(touch.Position.X - trackPos.X, 0, trackWidth)
			updateValue(min + (relX / trackWidth) * (max - min))
			if config.Callback then config.Callback(value) end
		end
	end)

	track.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch then
			local relX = math.clamp(input.Position.X - track.AbsolutePosition.X, 0, track.AbsoluteSize.X)
			updateValue(min + (relX / track.AbsoluteSize.X) * (max - min))
			if config.Callback then config.Callback(value) end
			dragging = true
		end
	end)
	track.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch then dragging = false end
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
	holder.Size = UDim2.new(1, 0, 0, scaleOffset(44))
	holder.BackgroundTransparency = 1
	holder.Name = "DropdownHolder"

	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, 0, 1, 0)
	btn.BackgroundColor3 = theme.SurfaceLight
	btn.Text = config.Default or "Select..."
	btn.TextColor3 = theme.Text
	btn.Font = Enum.Font.GothamMedium
	btn.TextSize = scaleOffset(15)
	btn.BorderSizePixel = 0
	btn.ZIndex = 2
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
	btn.Parent = holder

	local arrow = Instance.new("TextLabel")
	arrow.Size = UDim2.new(0, scaleOffset(24), 0, scaleOffset(24))
	arrow.Position = UDim2.new(1, -scaleOffset(28), 0.5, -scaleOffset(12))
	arrow.BackgroundTransparency = 1
	arrow.Text = "▼"
	arrow.TextColor3 = theme.SubText
	arrow.Font = Enum.Font.GothamBold
	arrow.TextSize = scaleOffset(12)
	arrow.ZIndex = 3
	arrow.Parent = btn

	local listFrame = Instance.new("Frame")
	listFrame.Size = UDim2.new(1, 0, 0, 0)
	listFrame.Position = UDim2.new(0, 0, 1, scaleOffset(4))
	listFrame.BackgroundColor3 = theme.SurfaceLight
	listFrame.BorderSizePixel = 0
	listFrame.Visible = false
	listFrame.ZIndex = 5
	Instance.new("UICorner", listFrame).CornerRadius = UDim.new(0, 6)
	local listLayout = Instance.new("UIListLayout")
	listLayout.Padding = UDim.new(0, scaleOffset(2))
	listLayout.Parent = listFrame
	listFrame.Parent = holder

	local options = config.Options or {}
	local selected = config.Default or (options[1] or "Select...")

	local function rebuildList()
		for _, child in ipairs(listFrame:GetChildren()) do
			if child:IsA("TextButton") then child:Destroy() end
		end
		local count = #options
		for i, opt in ipairs(options) do
			local optBtn = Instance.new("TextButton")
			optBtn.Size = UDim2.new(1, 0, 0, scaleOffset(40))
			optBtn.BackgroundColor3 = (opt == selected) and theme.Primary or theme.SurfaceLight
			optBtn.Text = tostring(opt)
			optBtn.TextColor3 = (opt == selected) and theme.OnPrimary or theme.Text
			optBtn.Font = Enum.Font.GothamMedium
			optBtn.TextSize = scaleOffset(14)
			optBtn.BorderSizePixel = 0
			optBtn.ZIndex = 5
			local c = Instance.new("UICorner")
			c.CornerRadius = UDim.new(0, 4)
			c.Parent = optBtn
			optBtn.Parent = listFrame
			optBtn.MouseButton1Click:Connect(function()
				selected = opt
				btn.Text = opt
				listFrame.Visible = false
				rebuildList()
				if config.Callback then config.Callback(selected) end
			end)
		end
		listFrame.Size = UDim2.new(1, 0, 0, scaleOffset(40 * count + 4))
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
	holder.Size = UDim2.new(1, 0, 0, scaleOffset(44))
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
	box.TextSize = scaleOffset(15)
	box.BorderSizePixel = 0
	box.ClearTextOnFocus = false
	box.ZIndex = 2
	Instance.new("UICorner", box).CornerRadius = UDim.new(0, 6)
	box.Parent = holder

	local clearBtn = Instance.new("TextButton")
	clearBtn.Size = UDim2.new(0, scaleOffset(24), 0, scaleOffset(24))
	clearBtn.Position = UDim2.new(1, -scaleOffset(28), 0.5, -scaleOffset(12))
	clearBtn.BackgroundTransparency = 1
	clearBtn.Text = "✕"
	clearBtn.TextColor3 = theme.SubText
	clearBtn.Font = Enum.Font.GothamBold
	clearBtn.TextSize = scaleOffset(14)
	clearBtn.ZIndex = 3
	clearBtn.Visible = (box.Text ~= "")
	clearBtn.Parent = box

	box:GetPropertyChangedSignal("Text"):Connect(function()
		clearBtn.Visible = (box.Text ~= "")
		if config.Callback then config.Callback(box.Text) end
	end)
	clearBtn.MouseButton1Click:Connect(function()
		box.Text = ""
		clearBtn.Visible = false
	end)

	holder.Parent = parent
	local self = setmetatable({ Instance = holder }, TextBox)
	self.Theme = theme
	self.GetText = function() return box.Text end
	self.SetText = function(text) box.Text = text end
	return self
end

-- ====================== LABEL ======================
local Label = setmetatable({}, ComponentBase)
Label.__index = Label

function Label.new(parent, config, theme)
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 0, scaleOffset(24))
	label.BackgroundTransparency = 1
	label.Text = config.Text or "Label"
	label.TextColor3 = theme.Text
	label.Font = Enum.Font.GothamBold
	label.TextSize = scaleOffset(16)
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = parent
	return setmetatable({ Instance = label }, Label)
end

-- ====================== PARAGRAPH ======================
local Paragraph = setmetatable({}, ComponentBase)
Paragraph.__index = Paragraph

function Paragraph.new(parent, config, theme)
	local para = Instance.new("TextLabel")
	para.Size = UDim2.new(1, 0, 0, scaleOffset(18))
	para.BackgroundTransparency = 1
	para.Text = config.Text or ""
	para.TextColor3 = theme.SubText
	para.Font = Enum.Font.Gotham
	para.TextSize = scaleOffset(14)
	para.TextWrapped = true
	para.TextXAlignment = Enum.TextXAlignment.Left
	para.RichText = true
	para.Parent = parent
	para:GetPropertyChangedSignal("Text"):Connect(function()
		para.Size = UDim2.new(1, 0, 0, para.TextBounds.Y + scaleOffset(4))
	end)
	return setmetatable({ Instance = para }, Paragraph)
end

-- ====================== KEYBIND ======================
local Keybind = setmetatable({}, ComponentBase)
Keybind.__index = Keybind

function Keybind.new(parent, config, theme)
	local holder = Instance.new("Frame")
	holder.Size = UDim2.new(1, 0, 0, scaleOffset(44))
	holder.BackgroundTransparency = 1
	holder.Name = "KeybindHolder"

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(0.5, 0, 1, 0)
	label.Position = UDim2.new(0, scaleOffset(4), 0, 0)
	label.BackgroundTransparency = 1
	label.Text = config.Name or "Keybind"
	label.TextColor3 = theme.Text
	label.Font = Enum.Font.GothamMedium
	label.TextSize = scaleOffset(15)
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = holder

	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0, scaleOffset(90), 1, 0)
	btn.Position = UDim2.new(1, -scaleOffset(94), 0, 0)
	btn.BackgroundColor3 = theme.SurfaceLight
	btn.Text = config.Default or "None"
	btn.TextColor3 = theme.Text
	btn.Font = Enum.Font.GothamMedium
	btn.TextSize = scaleOffset(14)
	btn.BorderSizePixel = 0
	btn.ZIndex = 2
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
	btn.Parent = holder

	local binding = config.Default
	local listening = false

	btn.MouseButton1Click:Connect(function()
		listening = true
		btn.Text = "Press..."
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
				if config.Callback then config.Callback(binding) end
			end
		end
	end)

	holder.Parent = parent
	local self = setmetatable({ Instance = holder }, Keybind)
	self.Theme = theme
	self.GetKeybind = function() return binding end
	return self
end

-- ====================== COLOR PICKER (compact, modern) ======================
local ColorPicker = setmetatable({}, ComponentBase)
ColorPicker.__index = ColorPicker

function ColorPicker.new(parent, config, theme)
	local holder = Instance.new("Frame")
	holder.Size = UDim2.new(1, 0, 0, scaleOffset(44))
	holder.BackgroundTransparency = 1
	holder.Name = "ColorPickerHolder"

	local preview = Instance.new("Frame")
	preview.Size = UDim2.new(0, scaleOffset(36), 0, scaleOffset(36))
	preview.Position = UDim2.new(0, scaleOffset(4), 0.5, -scaleOffset(18))
	preview.BackgroundColor3 = config.Default or theme.Primary
	preview.BorderSizePixel = 0
	Instance.new("UICorner", preview).CornerRadius = UDim.new(0, 6)
	preview.Parent = holder

	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, -scaleOffset(48), 1, 0)
	btn.Position = UDim2.new(0, scaleOffset(48), 0, 0)
	btn.BackgroundColor3 = theme.SurfaceLight
	btn.Text = "Pick Color"
	btn.TextColor3 = theme.Text
	btn.Font = Enum.Font.GothamMedium
	btn.TextSize = scaleOffset(15)
	btn.BorderSizePixel = 0
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
	btn.Parent = holder

	local currentColor = config.Default or theme.Primary

	-- popup (scaled)
	local pickerPopup = Instance.new("Frame")
	pickerPopup.Size = UDim2.new(0, scaleOffset(280), 0, scaleOffset(300))
	pickerPopup.Position = UDim2.new(0.5, -scaleOffset(140), 0.5, -scaleOffset(150))
	pickerPopup.BackgroundColor3 = theme.Surface
	pickerPopup.BorderSizePixel = 0
	pickerPopup.Visible = false
	pickerPopup.ZIndex = 100
	Instance.new("UICorner", pickerPopup).CornerRadius = UDim.new(0, 8)
	pickerPopup.Parent = holder

	-- Saturation/Value area
	local satValImage = Instance.new("ImageLabel")
	satValImage.Size = UDim2.new(1, -scaleOffset(16), 0, scaleOffset(180))
	satValImage.Position = UDim2.new(0, scaleOffset(8), 0, scaleOffset(8))
	satValImage.BackgroundColor3 = Color3.new(1,1,1)
	satValImage.BorderSizePixel = 0
	Instance.new("UICorner", satValImage).CornerRadius = UDim.new(0, 6)
	-- Horizontal gradient: white to pure hue
	local hGradient = Instance.new("UIGradient")
	hGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.new(1,1,1)),
		ColorSequenceKeypoint.new(1, currentColor)
	})
	hGradient.Rotation = 0
	hGradient.Parent = satValImage
	-- Vertical gradient: transparent to black
	local vGradient = Instance.new("UIGradient")
	vGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.new(0,0,0,0)),
		ColorSequenceKeypoint.new(1, Color3.new(0,0,0))
	})
	vGradient.Rotation = 90
	vGradient.Parent = satValImage
	satValImage.Parent = pickerPopup

	-- SV indicator
	local svIndicator = Instance.new("Frame")
	svIndicator.Size = UDim2.new(0, scaleOffset(14), 0, scaleOffset(14))
	svIndicator.BackgroundColor3 = Color3.new(1,1,1)
	svIndicator.BorderSizePixel = 0
	svIndicator.AnchorPoint = Vector2.new(0.5, 0.5)
	Instance.new("UICorner", svIndicator).CornerRadius = UDim.new(1, 0)
	svIndicator.Parent = satValImage

	-- Hue bar
	local hueBar = Instance.new("Frame")
	hueBar.Size = UDim2.new(1, -scaleOffset(16), 0, scaleOffset(18))
	hueBar.Position = UDim2.new(0, scaleOffset(8), 0, scaleOffset(196))
	hueBar.BorderSizePixel = 0
	Instance.new("UICorner", hueBar).CornerRadius = UDim.new(0, 6)
	local hueGradient = Instance.new("UIGradient")
	hueGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255,0,0)),
		ColorSequenceKeypoint.new(0.2, Color3.fromRGB(255,255,0)),
		ColorSequenceKeypoint.new(0.4, Color3.fromRGB(0,255,0)),
		ColorSequenceKeypoint.new(0.6, Color3.fromRGB(0,255,255)),
		ColorSequenceKeypoint.new(0.8, Color3.fromRGB(0,0,255)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(255,0,255)),
	})
	hueGradient.Parent = hueBar
	hueBar.Parent = pickerPopup

	local hueKnob = Instance.new("Frame")
	hueKnob.Size = UDim2.new(0, scaleOffset(14), 0, scaleOffset(26))
	hueKnob.Position = UDim2.new(0.5, -scaleOffset(7), 0, -scaleOffset(4))
	hueKnob.BackgroundColor3 = Color3.new(1,1,1)
	hueKnob.BorderSizePixel = 0
	Instance.new("UICorner", hueKnob).CornerRadius = UDim.new(0, 6)
	hueKnob.Parent = hueBar

	local confirmBtn = Instance.new("TextButton")
	confirmBtn.Size = UDim2.new(1, -scaleOffset(16), 0, scaleOffset(36))
	confirmBtn.Position = UDim2.new(0, scaleOffset(8), 1, -scaleOffset(44))
	confirmBtn.BackgroundColor3 = theme.Primary
	confirmBtn.Text = "Confirm"
	confirmBtn.TextColor3 = theme.OnPrimary
	confirmBtn.Font = Enum.Font.GothamBold
	confirmBtn.TextSize = scaleOffset(14)
	confirmBtn.BorderSizePixel = 0
	Instance.new("UICorner", confirmBtn).CornerRadius = UDim.new(0, 6)
	confirmBtn.Parent = pickerPopup

	-- Color math
	local function HSVtoRGB(h, s, v)
		local r, g, b
		local i = math.floor(h * 6)
		local f = h * 6 - i
		local p = v * (1 - s)
		local q = v * (1 - f * s)
		local t = v * (1 - (1 - f) * s)
		i = i % 6
		if i == 0 then r,g,b = v,t,p
		elseif i == 1 then r,g,b = q,v,p
		elseif i == 2 then r,g,b = p,v,t
		elseif i == 3 then r,g,b = p,q,v
		elseif i == 4 then r,g,b = t,p,v
		else r,g,b = v,p,q
		end
		return Color3.fromRGB(r*255, g*255, b*255)
	end

	local function updateFromSVH(s, v, h)
		currentColor = HSVtoRGB(h, s, 1 - v)
		preview.BackgroundColor3 = currentColor
		hGradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.new(1,1,1)),
			ColorSequenceKeypoint.new(1, HSVtoRGB(h, 1, 1))
		})
	end

	local draggingSV, draggingH = false, false
	local function updatePick()
		local sx = svIndicator.Position.X.Scale
		local sy = svIndicator.Position.Y.Scale
		local hx = hueKnob.Position.X.Scale
		updateFromSVH(sx, sy, hx)
	end

	satValImage.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch then draggingSV = true end
	end)
	satValImage.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch then draggingSV = false end
	end)
	UserInputService.TouchMoved:Connect(function(touch, processed)
		if draggingSV and not processed then
			local pos = satValImage.AbsolutePosition
			local size = satValImage.AbsoluteSize
			local rx = math.clamp((touch.Position.X - pos.X) / size.X, 0, 1)
			local ry = math.clamp((touch.Position.Y - pos.Y) / size.Y, 0, 1)
			svIndicator.Position = UDim2.new(rx, -scaleOffset(7), ry, -scaleOffset(7))
			updatePick()
		end
	end)

	hueBar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch then draggingH = true end
	end)
	hueBar.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch then draggingH = false end
	end)
	UserInputService.TouchMoved:Connect(function(touch, processed)
		if draggingH and not processed then
			local pos = hueBar.AbsolutePosition
			local size = hueBar.AbsoluteSize
			local rx = math.clamp((touch.Position.X - pos.X) / size.X, 0, 1)
			hueKnob.Position = UDim2.new(rx, -scaleOffset(7), 0, -scaleOffset(4))
			updatePick()
		end
	end)

	btn.MouseButton1Click:Connect(function()
		pickerPopup.Visible = not pickerPopup.Visible
	end)
	confirmBtn.MouseButton1Click:Connect(function()
		pickerPopup.Visible = false
		if config.Callback then config.Callback(currentColor) end
	end)

	holder.Parent = parent
	local self = setmetatable({ Instance = holder }, ColorPicker)
	self.Theme = theme
	self.GetColor = function() return currentColor end
	self.SetColor = function(c)
		currentColor = c
		preview.BackgroundColor3 = c
	end
	return self
end

-- ====================== NOTIFICATIONS ======================
local NotificationManager = {}
function NotificationManager:Show(config, theme)
	local notif = Instance.new("Frame")
	notif.Size = UDim2.new(1, -scaleOffset(16), 0, scaleOffset(60))
	notif.Position = UDim2.new(0.5, 0, 1, scaleOffset(-10))
	notif.AnchorPoint = Vector2.new(0.5, 1)
	notif.BackgroundColor3 = theme.Surface
	notif.BorderSizePixel = 0
	notif.ZIndex = 200
	Instance.new("UICorner", notif).CornerRadius = UDim.new(0, 6)
	notif.Parent = PlayerGui

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, -scaleOffset(32), 0, scaleOffset(20))
	title.Position = UDim2.new(0, scaleOffset(12), 0, scaleOffset(8))
	title.BackgroundTransparency = 1
	title.Text = config.Title or "Notification"
	title.TextColor3 = theme.Text
	title.Font = Enum.Font.GothamBold
	title.TextSize = scaleOffset(14)
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Parent = notif

	local msg = Instance.new("TextLabel")
	msg.Size = UDim2.new(1, -scaleOffset(32), 0, scaleOffset(18))
	msg.Position = UDim2.new(0, scaleOffset(12), 0, scaleOffset(30))
	msg.BackgroundTransparency = 1
	msg.Text = config.Text or ""
	msg.TextColor3 = theme.SubText
	msg.Font = Enum.Font.Gotham
	msg.TextSize = scaleOffset(12)
	msg.TextXAlignment = Enum.TextXAlignment.Left
	msg.Parent = notif

	local closeBtn = Instance.new("TextButton")
	closeBtn.Size = UDim2.new(0, scaleOffset(24), 0, scaleOffset(24))
	closeBtn.Position = UDim2.new(1, -scaleOffset(30), 0, scaleOffset(6))
	closeBtn.BackgroundTransparency = 1
	closeBtn.Text = "✕"
	closeBtn.TextColor3 = theme.SubText
	closeBtn.Font = Enum.Font.GothamBold
	closeBtn.TextSize = scaleOffset(16)
	closeBtn.Parent = notif

	tweenObject(notif, {Position = UDim2.new(0.5, 0, 1, scaleOffset(-70))}, 0.3, Enum.EasingStyle.Back)

	local self = { Instance = notif }
	local autoDismiss
	if config.Duration and config.Duration > 0 then
		autoDismiss = task.delay(config.Duration, function() self:Dismiss() end)
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
	return self
end

-- ====================== DIALOGS ======================
local Dialog = {}
function Dialog:Create(config, theme, parent)
	local overlay = Instance.new("Frame")
	overlay.Size = UDim2.new(1, 0, 1, 0)
	overlay.BackgroundColor3 = Color3.fromRGB(0,0,0)
	overlay.BackgroundTransparency = 0.5
	overlay.BorderSizePixel = 0
	overlay.ZIndex = 150
	overlay.Parent = parent or PlayerGui

	local container = Instance.new("Frame")
	container.Size = UDim2.new(0, scaleOffset(290), 0, scaleOffset(180))
	container.Position = UDim2.new(0.5, -scaleOffset(145), 0.5, -scaleOffset(90))
	container.BackgroundColor3 = theme.Surface
	container.BorderSizePixel = 0
	container.ZIndex = 151
	Instance.new("UICorner", container).CornerRadius = UDim.new(0, 6)
	container.Parent = overlay

	local titleLabel = Instance.new("TextLabel")
	titleLabel.Size = UDim2.new(1, -scaleOffset(16), 0, scaleOffset(26))
	titleLabel.Position = UDim2.new(0, scaleOffset(8), 0, scaleOffset(8))
	titleLabel.BackgroundTransparency = 1
	titleLabel.Text = config.Title or "Dialog"
	titleLabel.TextColor3 = theme.Text
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.TextSize = scaleOffset(16)
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.Parent = container

	local msgLabel = Instance.new("TextLabel")
	msgLabel.Size = UDim2.new(1, -scaleOffset(16), 0, scaleOffset(70))
	msgLabel.Position = UDim2.new(0, scaleOffset(8), 0, scaleOffset(40))
	msgLabel.BackgroundTransparency = 1
	msgLabel.Text = config.Text or ""
	msgLabel.TextColor3 = theme.SubText
	msgLabel.Font = Enum.Font.Gotham
	msgLabel.TextSize = scaleOffset(14)
	msgLabel.TextWrapped = true
	msgLabel.TextXAlignment = Enum.TextXAlignment.Left
	msgLabel.Parent = container

	local buttonFrame = Instance.new("Frame")
	buttonFrame.Size = UDim2.new(1, -scaleOffset(16), 0, scaleOffset(38))
	buttonFrame.Position = UDim2.new(0, scaleOffset(8), 1, -scaleOffset(46))
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
		btn.TextSize = scaleOffset(14)
		btn.BorderSizePixel = 0
		Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
		btn.Parent = buttonFrame
		btn.MouseButton1Click:Connect(function()
			if btnConfig.Callback then btnConfig.Callback() end
			overlay:Destroy()
		end)
	end

	tweenObject(container, {Size = UDim2.new(0, scaleOffset(290), 0, scaleOffset(180))}, 0.2, Enum.EasingStyle.Back)

	return overlay
end

-- ====================== SEARCH BAR ======================
local SearchBar = setmetatable({}, ComponentBase)
SearchBar.__index = SearchBar

function SearchBar.new(parent, config, theme)
	local holder = Instance.new("Frame")
	holder.Size = UDim2.new(1, 0, 0, scaleOffset(44))
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
	box.TextSize = scaleOffset(15)
	box.BorderSizePixel = 0
	box.ClearTextOnFocus = false
	box.ZIndex = 2
	Instance.new("UICorner", box).CornerRadius = UDim.new(0, 6)
	box.Parent = holder

	local icon = Instance.new("TextLabel")
	icon.Size = UDim2.new(0, scaleOffset(24), 0, scaleOffset(24))
	icon.Position = UDim2.new(0, scaleOffset(6), 0.5, -scaleOffset(12))
	icon.BackgroundTransparency = 1
	icon.Text = "🔍"
	icon.TextColor3 = theme.SubText
	icon.Font = Enum.Font.GothamBold
	icon.TextSize = scaleOffset(14)
	icon.ZIndex = 3
	icon.Parent = box

	local clearBtn = Instance.new("TextButton")
	clearBtn.Size = UDim2.new(0, scaleOffset(24), 0, scaleOffset(24))
	clearBtn.Position = UDim2.new(1, -scaleOffset(28), 0.5, -scaleOffset(12))
	clearBtn.BackgroundTransparency = 1
	clearBtn.Text = "✕"
	clearBtn.TextColor3 = theme.SubText
	clearBtn.Font = Enum.Font.GothamBold
	clearBtn.TextSize = scaleOffset(14)
	clearBtn.ZIndex = 3
	clearBtn.Visible = (box.Text ~= "")
	clearBtn.Parent = box

	box:GetPropertyChangedSignal("Text"):Connect(function()
		clearBtn.Visible = (box.Text ~= "")
		if config.Callback then config.Callback(box.Text) end
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
	listLayout.Padding = UDim.new(0, scaleOffset(10))
	listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	listLayout.SortOrder = Enum.SortOrder.LayoutOrder
	listLayout.Parent = page

	return setmetatable({
		Page = page,
		Name = name,
		Icon = icon,
		Theme = theme,
	}, Tab)
end

function Tab:AddComponent(component)
	component.Instance.Parent = self.Page
	component.Instance.LayoutOrder = #self.Page:GetChildren()
	return component
end

-- (component creators omitted for brevity – they're identical to previous, just calling the redesigned constructors)
function Tab:CreateButton(config) return self:AddComponent(Button.new(self.Page, config, self.Theme)) end
function Tab:CreateToggle(config) return self:AddComponent(Toggle.new(self.Page, config, self.Theme)) end
function Tab:CreateSlider(config) return self:AddComponent(Slider.new(self.Page, config, self.Theme)) end
function Tab:CreateDropdown(config) return self:AddComponent(Dropdown.new(self.Page, config, self.Theme)) end
function Tab:CreateTextBox(config) return self:AddComponent(TextBox.new(self.Page, config, self.Theme)) end
function Tab:CreateLabel(config) return self:AddComponent(Label.new(self.Page, config, self.Theme)) end
function Tab:CreateParagraph(config) return self:AddComponent(Paragraph.new(self.Page, config, self.Theme)) end
function Tab:CreateKeybind(config) return self:AddComponent(Keybind.new(self.Page, config, self.Theme)) end
function Tab:CreateColorPicker(config) return self:AddComponent(ColorPicker.new(self.Page, config, self.Theme)) end
function Tab:CreateSearchBar(config) return self:AddComponent(SearchBar.new(self.Page, config, self.Theme)) end

-- ====================== WINDOW SYSTEM (COMPACT, SHARP) ======================
local Window = {}
Window.__index = Window

function Window.new(config)
	local self = setmetatable({}, Window)
	local themeName = config.Theme or "Dark"
	local theme = Themes[themeName] or Themes.Dark
	self.Theme = theme

	local gui = Instance.new("ScreenGui")
	gui.Name = "MobileUI_" .. (config.Title or "Hub")
	gui.Parent = PlayerGui
	gui.IgnoreGuiInset = not (config.SafeArea or false)
	self.Gui = gui

	-- Use Camera.ViewportSize for dimensions (kept exactly as fixed)
	local screenW = Camera.ViewportSize.X
	local screenH = Camera.ViewportSize.Y
	local windowW = math.min(screenW, scaleOffset(360))
	local windowH = math.min(screenH, scaleOffset(640))

	local mainContainer = Instance.new("Frame")
	mainContainer.Size = UDim2.new(0, windowW, 0, windowH)
	mainContainer.Position = UDim2.new(0.5, -windowW/2, 0.5, -windowH/2)
	mainContainer.BackgroundColor3 = theme.Background
	mainContainer.BorderSizePixel = 0
	mainContainer.ZIndex = 1
	local mainCorner = Instance.new("UICorner")
	mainCorner.CornerRadius = UDim.new(0, 6)          -- sharp, not oval
	mainCorner.Parent = mainContainer
	mainContainer.Parent = gui
	self.MainContainer = mainContainer

	-- shadow (subtle)
	local shadow = createShadow(mainContainer, UDim2.new(1, scaleOffset(12), 1, scaleOffset(12)), UDim.new(0, 6), theme, 0)
	shadow.Position = UDim2.new(0, -scaleOffset(4), 0, scaleOffset(4))
	shadow.ZIndex = 0

	-- Drag handle (thin)
	local dragHandle = Instance.new("TextButton")
	dragHandle.Size = UDim2.new(1, 0, 0, scaleOffset(36))
	dragHandle.BackgroundTransparency = 1
	dragHandle.Text = ""
	dragHandle.ZIndex = 10
	dragHandle.Parent = mainContainer

	local titleBar = Instance.new("TextLabel")
	titleBar.Size = UDim2.new(1, -scaleOffset(100), 1, 0)
	titleBar.Position = UDim2.new(0, scaleOffset(12), 0, 0)
	titleBar.BackgroundTransparency = 1
	titleBar.Text = config.Title or "Mobile Hub"
	titleBar.TextColor3 = theme.Text
	titleBar.Font = Enum.Font.GothamBold
	titleBar.TextSize = scaleOffset(16)
	titleBar.TextXAlignment = Enum.TextXAlignment.Left
	titleBar.ZIndex = 10
	titleBar.Parent = dragHandle

	-- Minimize / Expand buttons (smaller)
	local function makeWinBtn(text, posX)
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(0, scaleOffset(28), 0, scaleOffset(28))
		btn.Position = UDim2.new(1, posX, 0.5, -scaleOffset(14))
		btn.BackgroundColor3 = theme.SurfaceLight
		btn.Text = text
		btn.TextColor3 = theme.Text
		btn.Font = Enum.Font.GothamBold
		btn.TextSize = scaleOffset(18)
		btn.BorderSizePixel = 0
		btn.ZIndex = 10
		Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
		btn.Parent = dragHandle
		return btn
	end
	local minimizeBtn = makeWinBtn("–", -scaleOffset(68))
	local expandBtn = makeWinBtn("⛶", -scaleOffset(36))

	-- Content area
	local contentArea = Instance.new("Frame")
	contentArea.Size = UDim2.new(1, 0, 1, -scaleOffset(92))
	contentArea.Position = UDim2.new(0, 0, 0, scaleOffset(36))
	contentArea.BackgroundTransparency = 1
	contentArea.BorderSizePixel = 0
	contentArea.Parent = mainContainer
	self.ContentArea = contentArea

	-- Bottom navigation bar
	local bottomNav = Instance.new("Frame")
	bottomNav.Size = UDim2.new(1, -scaleOffset(12), 0, scaleOffset(44))
	bottomNav.Position = UDim2.new(0, scaleOffset(6), 1, -scaleOffset(50))
	bottomNav.BackgroundColor3 = theme.Surface
	bottomNav.BorderSizePixel = 0
	Instance.new("UICorner", bottomNav).CornerRadius = UDim.new(0, 6)
	bottomNav.Parent = mainContainer
	self.BottomNav = bottomNav

	local tabList = Instance.new("UIListLayout")
	tabList.FillDirection = Enum.FillDirection.Horizontal
	tabList.HorizontalAlignment = Enum.HorizontalAlignment.Center
	tabList.VerticalAlignment = Enum.VerticalAlignment.Center
	tabList.Padding = UDim.new(0, scaleOffset(6))
	tabList.Parent = bottomNav

	self.Tabs = {}
	self.ActiveTab = nil

	-- Dragging logic (unchanged, uses Camera.ViewportSize for bounds)
	local dragging = false
	local dragStartPos, dragOffset
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
			newPos = UDim2.new(0, math.clamp(newPos.X.Offset, 0, screenW - mainContainer.Size.X.Offset), 0, math.clamp(newPos.Y.Offset, 0, screenH - mainContainer.Size.Y.Offset))
			mainContainer.Position = newPos
		end
	end)
	UserInputService.TouchEnded:Connect(function(touch)
		if dragging then dragging = false end
	end)

	-- Minimize / Restore
	local minimized = false
	local originalSize = mainContainer.Size
	local originalPos = mainContainer.Position
	local minimizedBar = Instance.new("TextButton")
	minimizedBar.Size = UDim2.new(0, scaleOffset(180), 0, scaleOffset(36))
	minimizedBar.Position = UDim2.new(0.5, -scaleOffset(90), 1, scaleOffset(-6))
	minimizedBar.AnchorPoint = Vector2.new(0.5, 1)
	minimizedBar.BackgroundColor3 = theme.Surface
	minimizedBar.Text = config.Title or "Hub"
	minimizedBar.TextColor3 = theme.Text
	minimizedBar.Font = Enum.Font.GothamBold
	minimizedBar.TextSize = scaleOffset(14)
	minimizedBar.BorderSizePixel = 0
	minimizedBar.Visible = false
	minimizedBar.ZIndex = 50
	Instance.new("UICorner", minimizedBar).CornerRadius = UDim.new(0, 6)
	minimizedBar.Parent = gui
	minimizedBar.MouseButton1Click:Connect(function()
		tweenObject(mainContainer, {Size = originalSize, Position = originalPos}, 0.3, Enum.EasingStyle.Back)
		minimizedBar.Visible = false
		minimized = false
	end)
	minimizeBtn.MouseButton1Click:Connect(function()
		if minimized then return end
		minimized = true
		originalSize = mainContainer.Size
		originalPos = mainContainer.Position
		tweenObject(mainContainer, {Size = UDim2.new(0, scaleOffset(180), 0, scaleOffset(36)), Position = UDim2.new(0.5, -scaleOffset(90), 1, scaleOffset(-6))}, 0.3, Enum.EasingStyle.Back, nil, function()
			mainContainer.Visible = false
			minimizedBar.Visible = true
		end)
	end)

	-- Expand / Restore
	local expanded = false
	expandBtn.MouseButton1Click:Connect(function()
		expanded = not expanded
		if expanded then
			originalSize = mainContainer.Size
			originalPos = mainContainer.Position
			tweenObject(mainContainer, {Size = UDim2.new(0, screenW, 0, screenH), Position = UDim2.new(0, 0, 0, 0)}, 0.3)
			mainCorner.CornerRadius = UDim.new(0, 0)
		else
			tweenObject(mainContainer, {Size = originalSize, Position = originalPos}, 0.3)
			mainCorner.CornerRadius = UDim.new(0, 6)
		end
	end)

	-- Auto-resize on viewport change
	Camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
		screenSize = Camera.ViewportSize
		scaleFactor = math.min(screenSize.X / BASE_WIDTH, screenSize.Y / BASE_HEIGHT)
		screenW = screenSize.X
		screenH = screenSize.Y
		if not expanded and not minimized then
			windowW = math.min(screenW, scaleOffset(360))
			windowH = math.min(screenH, scaleOffset(640))
			mainContainer.Size = UDim2.new(0, windowW, 0, windowH)
			mainContainer.Position = UDim2.new(0.5, -windowW/2, 0.5, -windowH/2)
		end
	end)

	function self:SetTheme(newName, custom)
		local newTheme = custom or Themes[newName] or Themes.Dark
		self.Theme = newTheme
		mainContainer.BackgroundColor3 = newTheme.Background
		titleBar.TextColor3 = newTheme.Text
		bottomNav.BackgroundColor3 = newTheme.Surface
	end

	return self
end

function Window:CreateTab(name, icon)
	local tab = Tab.new(name, icon or "•", self.Theme, self.ContentArea)

	local tabBtn = Instance.new("TextButton")
	tabBtn.Size = UDim2.new(0, scaleOffset(50), 0, scaleOffset(38))
	tabBtn.BackgroundColor3 = self.Theme.SurfaceLight
	tabBtn.Text = icon or name:sub(1,1)
	tabBtn.TextColor3 = self.Theme.SubText
	tabBtn.Font = Enum.Font.GothamBold
	tabBtn.TextSize = scaleOffset(16)
	tabBtn.BorderSizePixel = 0
	Instance.new("UICorner", tabBtn).CornerRadius = UDim.new(0, 6)
	tabBtn.Parent = self.BottomNav

	local function selectTab()
		for _, t in ipairs(self.Tabs) do t.Page.Visible = false end
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
	if #self.Tabs == 0 then selectTab() end
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
	return Window.new(config or {})
end
function MobileUI:SetBaseResolution(w, h)
	BASE_WIDTH = w or 400
	BASE_HEIGHT = h or 800
	scaleFactor = math.min(screenSize.X / BASE_WIDTH, screenSize.Y / BASE_HEIGHT)
end
return MobileUI