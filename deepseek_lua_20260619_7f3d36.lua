--[[
    MobileUI – Modern, Minimalist, Mobile-Optimized Roblox Script Hub Library
    • Card-Based layout with soft borders (UIStroke 1px, 50% transparency)
    • Centralised THEME table for one-click palette changes
    • Camera.ViewportSize scaling (phones & tablets)
    • Smooth animations (Quint easing for toggles, scale/hover for buttons)
    • Compact, high-density components that feel like a premium iOS/Android dashboard
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Camera = Workspace.CurrentCamera

-- ====================== THEME SYSTEM ======================
-- Change any color here to instantly restyle the entire library
local THEME = {
    -- Dark (default)
    Dark = {
        Background = Color3.fromRGB(12, 12, 18),
        Surface = Color3.fromRGB(22, 22, 32),
        Primary = Color3.fromRGB(140, 110, 255),          -- soft lavender
        TextPrimary = Color3.fromRGB(240, 240, 245),
        TextSecondary = Color3.fromRGB(170, 170, 185),
        Border = Color3.fromRGB(255, 255, 255),           -- used as UIStroke color (white with transparency)
        ScrollBar = Color3.fromRGB(100, 100, 120),
    },
    -- Light (optional)
    Light = {
        Background = Color3.fromRGB(240, 240, 245),
        Surface = Color3.fromRGB(255, 255, 255),
        Primary = Color3.fromRGB(140, 110, 255),
        TextPrimary = Color3.fromRGB(30, 30, 35),
        TextSecondary = Color3.fromRGB(100, 100, 110),
        Border = Color3.fromRGB(0, 0, 0),
        ScrollBar = Color3.fromRGB(180, 180, 190),
    },
}

-- ====================== SCALING (ViewportSize) ======================
local BASE_WIDTH = 400
local BASE_HEIGHT = 800
local screenSize = Camera.ViewportSize
local scaleFactor = math.min(screenSize.X / BASE_WIDTH, screenSize.Y / BASE_HEIGHT)

local function scale(offset)
    return offset * scaleFactor
end

-- ====================== UTILITY ======================
local function tween(instance, props, duration, easing, dir, callback)
    local info = TweenInfo.new(duration, easing or Enum.EasingStyle.Quart, dir or Enum.EasingDirection.Out)
    local tw = TweenService:Create(instance, info, props)
    tw:Play()
    if callback then
        tw.Completed:Connect(function() callback() end)
    end
    return tw
end

-- Helper to apply card styling (surface bg, 12px corner, soft border)
local function applyCard(frame, theme)
    frame.BackgroundColor3 = theme.Surface
    if not frame:FindFirstChild("UICorner") then
        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(0, 12)
        c.Parent = frame
    end
    local stroke = frame:FindFirstChild("UIStroke")
    if not stroke then
        stroke = Instance.new("UIStroke")
        stroke.Thickness = 1
        stroke.Transparency = 0.5
        stroke.Color = theme.Border
        stroke.Parent = frame
    else
        stroke.Color = theme.Border
    end
end

-- ====================== COMPONENT BASE ======================
local ComponentBase = {}
ComponentBase.__index = ComponentBase

function ComponentBase.new(instance)
    return setmetatable({ Instance = instance }, ComponentBase)
end

-- ====================== BUTTON ======================
local Button = setmetatable({}, ComponentBase)
Button.__index = Button

function Button.new(parent, config, theme)
    local holder = Instance.new("Frame")
    holder.Size = UDim2.new(1, 0, 0, scale(44))
    holder.BackgroundTransparency = 1
    holder.Name = "ButtonHolder"

    local card = Instance.new("TextButton")
    card.Size = UDim2.new(1, 0, 1, 0)
    card.Text = config.Name or "Button"
    card.TextColor3 = theme.TextPrimary
    card.Font = Enum.Font.GothamBold
    card.TextSize = scale(15)
    card.BackgroundColor3 = theme.Primary
    card.BorderSizePixel = 0
    card.ZIndex = 2
    applyCard(card, theme)
    card.Parent = holder

    -- hover / press effect (scale + brighten)
    local originalColor = card.BackgroundColor3
    local originalSize = card.Size
    card.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            tween(card, {BackgroundColor3 = originalColor:Lerp(Color3.new(1,1,1), 0.15)}, 0.1)
            tween(card, {Size = UDim2.new(1, -scale(4), 1, -scale(4))}, 0.1, Enum.EasingStyle.Quad)
        end
    end)
    card.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            tween(card, {BackgroundColor3 = originalColor}, 0.1)
            tween(card, {Size = originalSize}, 0.1, Enum.EasingStyle.Quad)
        end
    end)

    card.MouseButton1Click:Connect(function()
        if config.Callback then config.Callback() end
    end)

    holder.Parent = parent
    return setmetatable({ Instance = holder, Button = card, Theme = theme }, Button)
end

-- ====================== TOGGLE (Quint easing) ======================
local Toggle = setmetatable({}, ComponentBase)
Toggle.__index = Toggle

function Toggle.new(parent, config, theme)
    local holder = Instance.new("Frame")
    holder.Size = UDim2.new(1, 0, 0, scale(46))
    holder.BackgroundTransparency = 1
    holder.Name = "ToggleHolder"

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.6, 0, 1, 0)
    label.Position = UDim2.new(0, scale(8), 0, 0)
    label.BackgroundTransparency = 1
    label.Text = config.Name or "Toggle"
    label.TextColor3 = theme.TextPrimary
    label.Font = Enum.Font.GothamMedium
    label.TextSize = scale(15)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = holder

    local switchCard = Instance.new("Frame")
    switchCard.Size = UDim2.new(0, scale(52), 0, scale(30))
    switchCard.Position = UDim2.new(1, -scale(60), 0.5, -scale(15))
    switchCard.BackgroundColor3 = theme.Surface
    switchCard.BorderSizePixel = 0
    applyCard(switchCard, theme)   -- card styling gives rounded pill + border
    switchCard.Parent = holder

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, scale(24), 0, scale(24))
    knob.Position = UDim2.new(0, scale(3), 0.5, -scale(12))
    knob.BackgroundColor3 = theme.TextPrimary
    knob.BorderSizePixel = 0
    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(1, 0)
    knobCorner.Parent = knob
    knob.Parent = switchCard

    local state = config.Default or false
    local function updateVisual()
        if state then
            switchCard.BackgroundColor3 = theme.Primary
            tween(knob, {Position = UDim2.new(1, -scale(27), 0.5, -scale(12))}, 0.25, Enum.EasingStyle.Quint)
        else
            switchCard.BackgroundColor3 = theme.Surface
            tween(knob, {Position = UDim2.new(0, scale(3), 0.5, -scale(12))}, 0.25, Enum.EasingStyle.Quint)
        end
    end
    updateVisual()

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.Parent = switchCard
    btn.MouseButton1Click:Connect(function()
        state = not state
        updateVisual()
        if config.Callback then config.Callback(state) end
    end)

    holder.Parent = parent
    local self = setmetatable({ Instance = holder }, Toggle)
    self.Theme = theme
    self.GetState = function() return state end
    self.SetState = function(s) state = s; updateVisual() end
    return self
end

-- ====================== SLIDER (thin track, circular handle) ======================
local Slider = setmetatable({}, ComponentBase)
Slider.__index = Slider

function Slider.new(parent, config, theme)
    local holder = Instance.new("Frame")
    holder.Size = UDim2.new(1, 0, 0, scale(50))
    holder.BackgroundTransparency = 1
    holder.Name = "SliderHolder"

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.6, 0, 0, scale(20))
    label.Position = UDim2.new(0, scale(8), 0, scale(4))
    label.BackgroundTransparency = 1
    label.Text = config.Name or "Slider"
    label.TextColor3 = theme.TextPrimary
    label.Font = Enum.Font.GothamMedium
    label.TextSize = scale(14)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = holder

    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(0.4, 0, 0, scale(20))
    valueLabel.Position = UDim2.new(0.6, 0, 0, scale(4))
    valueLabel.BackgroundTransparency = 1
    valueLabel.TextColor3 = theme.TextSecondary
    valueLabel.Font = Enum.Font.GothamMedium
    valueLabel.TextSize = scale(13)
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.Text = tostring(config.Default or config.Min or 0)
    valueLabel.Parent = holder

    local track = Instance.new("Frame")
    track.Size = UDim2.new(1, -scale(16), 0, scale(4))
    track.Position = UDim2.new(0, scale(8), 0, scale(32))
    track.BackgroundColor3 = theme.TextSecondary
    track.BorderSizePixel = 0
    Instance.new("UICorner", track).CornerRadius = UDim.new(0, 2)
    track.Parent = holder

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(0, 0, 1, 0)
    fill.BackgroundColor3 = theme.Primary
    fill.BorderSizePixel = 0
    Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 2)
    fill.Parent = track

    local knob = Instance.new("TextButton")
    knob.Size = UDim2.new(0, scale(20), 0, scale(20))
    knob.Position = UDim2.new(0, -scale(10), 0.5, -scale(10))
    knob.BackgroundColor3 = theme.Primary
    knob.Text = ""
    knob.BorderSizePixel = 0
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)
    knob.Parent = track

    local min = config.Min or 0
    local max = config.Max or 100
    local value = config.Default or min
    local dragging = false

    local function updateValue(newValue)
        value = math.clamp(newValue, min, max)
        local fraction = (value - min) / (max - min)
        fill.Size = UDim2.new(fraction, 0, 1, 0)
        knob.Position = UDim2.new(fraction, -scale(10), 0.5, -scale(10))
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
    local self = setmetatable({ Instance = holder }, Slider)
    self.Theme = theme
    self.GetValue = function() return value end
    self.SetValue = function(v) updateValue(v); if config.Callback then config.Callback(value) end end
    return self
end

-- ====================== DROPDOWN (with clipping) ======================
local Dropdown = setmetatable({}, ComponentBase)
Dropdown.__index = Dropdown

function Dropdown.new(parent, config, theme)
    local holder = Instance.new("Frame")
    holder.Size = UDim2.new(1, 0, 0, scale(44))
    holder.BackgroundTransparency = 1
    holder.Name = "DropdownHolder"
    holder.ClipsDescendants = false   -- the clipping will be on the list frame

    local card = Instance.new("TextButton")
    card.Size = UDim2.new(1, 0, 1, 0)
    card.Text = config.Default or "Select..."
    card.TextColor3 = theme.TextPrimary
    card.Font = Enum.Font.GothamMedium
    card.TextSize = scale(14)
    card.BackgroundColor3 = theme.Surface
    card.BorderSizePixel = 0
    card.ZIndex = 2
    applyCard(card, theme)
    card.Parent = holder

    local arrow = Instance.new("TextLabel")
    arrow.Size = UDim2.new(0, scale(24), 0, scale(24))
    arrow.Position = UDim2.new(1, -scale(28), 0.5, -scale(12))
    arrow.BackgroundTransparency = 1
    arrow.Text = "▼"
    arrow.TextColor3 = theme.TextSecondary
    arrow.Font = Enum.Font.GothamBold
    arrow.TextSize = scale(12)
    arrow.ZIndex = 3
    arrow.Parent = card

    -- List container with clipping
    local listClip = Instance.new("Frame")
    listClip.Size = UDim2.new(1, 0, 0, 0)
    listClip.Position = UDim2.new(0, 0, 1, scale(4))
    listClip.BackgroundTransparency = 1
    listClip.ClipsDescendants = true
    listClip.ZIndex = 5
    listClip.Parent = holder

    local listFrame = Instance.new("ScrollingFrame")
    listFrame.Size = UDim2.new(1, 0, 1, 0)
    listFrame.BackgroundColor3 = theme.Surface
    listFrame.BorderSizePixel = 0
    listFrame.ScrollBarThickness = scale(3)
    listFrame.ScrollBarImageColor3 = theme.ScrollBar
    listFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    listFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    listFrame.ScrollingDirection = Enum.ScrollingDirection.Y
    listFrame.ZIndex = 5
    applyCard(listFrame, theme)   -- card styling
    listFrame.Parent = listClip

    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, scale(2))
    listLayout.Parent = listFrame

    local options = config.Options or {}
    local selected = config.Default or (options[1] or "Select...")

    local function rebuildList()
        for _, child in ipairs(listFrame:GetChildren()) do
            if child:IsA("TextButton") then child:Destroy() end
        end
        for i, opt in ipairs(options) do
            local optBtn = Instance.new("TextButton")
            optBtn.Size = UDim2.new(1, 0, 0, scale(36))
            optBtn.BackgroundColor3 = (opt == selected) and theme.Primary or theme.Surface
            optBtn.Text = tostring(opt)
            optBtn.TextColor3 = (opt == selected) and Color3.new(1,1,1) or theme.TextPrimary
            optBtn.Font = Enum.Font.Gotham
            optBtn.TextSize = scale(13)
            optBtn.BorderSizePixel = 0
            optBtn.ZIndex = 6
            local c = Instance.new("UICorner")
            c.CornerRadius = UDim.new(0, 8)
            c.Parent = optBtn
            optBtn.Parent = listFrame
            optBtn.MouseButton1Click:Connect(function()
                selected = opt
                card.Text = opt
                listClip.Visible = false
                rebuildList()
                if config.Callback then config.Callback(selected) end
            end)
        end
        -- Limit visible height to 120px, scrolling inside
        listClip.Size = UDim2.new(1, 0, 0, math.min(scale(120), #options * scale(38) + scale(4)))
    end
    rebuildList()
    listClip.Visible = false

    card.MouseButton1Click:Connect(function()
        listClip.Visible = not listClip.Visible
    end)

    holder.Parent = parent
    local self = setmetatable({ Instance = holder }, Dropdown)
    self.Theme = theme
    self.GetValue = function() return selected end
    self.SetOptions = function(newOptions)
        options = newOptions
        selected = options[1] or "Select..."
        card.Text = selected
        rebuildList()
    end
    return self
end

-- ====================== TEXTBOX (card input) ======================
local TextBox = setmetatable({}, ComponentBase)
TextBox.__index = TextBox

function TextBox.new(parent, config, theme)
    local holder = Instance.new("Frame")
    holder.Size = UDim2.new(1, 0, 0, scale(44))
    holder.BackgroundTransparency = 1
    holder.Name = "TextBoxHolder"

    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, 0, 1, 0)
    card.BackgroundColor3 = theme.Surface
    card.BorderSizePixel = 0
    card.ZIndex = 2
    applyCard(card, theme)
    card.Parent = holder

    local box = Instance.new("TextBox")
    box.Size = UDim2.new(1, -scale(30), 1, 0)
    box.Position = UDim2.new(0, scale(8), 0, 0)
    box.BackgroundTransparency = 1
    box.Text = config.Default or ""
    box.PlaceholderText = config.Placeholder or ""
    box.TextColor3 = theme.TextPrimary
    box.PlaceholderColor3 = theme.TextSecondary
    box.Font = Enum.Font.Gotham
    box.TextSize = scale(14)
    box.BorderSizePixel = 0
    box.ClearTextOnFocus = false
    box.ZIndex = 3
    box.Parent = card

    local clearBtn = Instance.new("TextButton")
    clearBtn.Size = UDim2.new(0, scale(20), 0, scale(20))
    clearBtn.Position = UDim2.new(1, -scale(24), 0.5, -scale(10))
    clearBtn.BackgroundTransparency = 1
    clearBtn.Text = "✕"
    clearBtn.TextColor3 = theme.TextSecondary
    clearBtn.Font = Enum.Font.GothamBold
    clearBtn.TextSize = scale(12)
    clearBtn.ZIndex = 4
    clearBtn.Visible = (box.Text ~= "")
    clearBtn.Parent = card

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
    label.Size = UDim2.new(1, 0, 0, scale(24))
    label.BackgroundTransparency = 1
    label.Text = config.Text or "Label"
    label.TextColor3 = theme.TextPrimary
    label.Font = Enum.Font.GothamBold
    label.TextSize = scale(15)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = parent
    return setmetatable({ Instance = label }, Label)
end

-- ====================== PARAGRAPH ======================
local Paragraph = setmetatable({}, ComponentBase)
Paragraph.__index = Paragraph

function Paragraph.new(parent, config, theme)
    local para = Instance.new("TextLabel")
    para.Size = UDim2.new(1, 0, 0, scale(18))
    para.BackgroundTransparency = 1
    para.Text = config.Text or ""
    para.TextColor3 = theme.TextSecondary
    para.Font = Enum.Font.Gotham
    para.TextSize = scale(13)
    para.TextWrapped = true
    para.TextXAlignment = Enum.TextXAlignment.Left
    para.RichText = true
    para.Parent = parent
    para:GetPropertyChangedSignal("Text"):Connect(function()
        para.Size = UDim2.new(1, 0, 0, para.TextBounds.Y + scale(4))
    end)
    return setmetatable({ Instance = para }, Paragraph)
end

-- ====================== KEYBIND (card button) ======================
local Keybind = setmetatable({}, ComponentBase)
Keybind.__index = Keybind

function Keybind.new(parent, config, theme)
    local holder = Instance.new("Frame")
    holder.Size = UDim2.new(1, 0, 0, scale(44))
    holder.BackgroundTransparency = 1
    holder.Name = "KeybindHolder"

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.5, 0, 1, 0)
    label.Position = UDim2.new(0, scale(8), 0, 0)
    label.BackgroundTransparency = 1
    label.Text = config.Name or "Keybind"
    label.TextColor3 = theme.TextPrimary
    label.Font = Enum.Font.GothamMedium
    label.TextSize = scale(14)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = holder

    local cardBtn = Instance.new("TextButton")
    cardBtn.Size = UDim2.new(0, scale(80), 1, 0)
    cardBtn.Position = UDim2.new(1, -scale(88), 0, 0)
    cardBtn.Text = config.Default or "None"
    cardBtn.TextColor3 = theme.TextPrimary
    cardBtn.Font = Enum.Font.GothamMedium
    cardBtn.TextSize = scale(13)
    cardBtn.BackgroundColor3 = theme.Surface
    cardBtn.BorderSizePixel = 0
    cardBtn.ZIndex = 2
    applyCard(cardBtn, theme)
    cardBtn.Parent = holder

    local binding = config.Default
    local listening = false

    cardBtn.MouseButton1Click:Connect(function()
        listening = true
        cardBtn.Text = "Press..."
        cardBtn.BackgroundColor3 = theme.Primary
    end)
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if listening and not gameProcessed then
            if input.KeyCode ~= Enum.KeyCode.Unknown then
                binding = input.KeyCode
                cardBtn.Text = binding.Name
                listening = false
                cardBtn.BackgroundColor3 = theme.Surface
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
    holder.Size = UDim2.new(1, 0, 0, scale(44))
    holder.BackgroundTransparency = 1
    holder.Name = "ColorPickerHolder"

    local preview = Instance.new("Frame")
    preview.Size = UDim2.new(0, scale(32), 0, scale(32))
    preview.Position = UDim2.new(0, scale(6), 0.5, -scale(16))
    preview.BackgroundColor3 = config.Default or theme.Primary
    preview.BorderSizePixel = 0
    Instance.new("UICorner", preview).CornerRadius = UDim.new(0, 8)
    preview.Parent = holder

    local cardBtn = Instance.new("TextButton")
    cardBtn.Size = UDim2.new(1, -scale(44), 1, 0)
    cardBtn.Position = UDim2.new(0, scale(44), 0, 0)
    cardBtn.Text = "Pick Color"
    cardBtn.TextColor3 = theme.TextPrimary
    cardBtn.Font = Enum.Font.GothamMedium
    cardBtn.TextSize = scale(14)
    cardBtn.BackgroundColor3 = theme.Surface
    cardBtn.BorderSizePixel = 0
    cardBtn.ZIndex = 2
    applyCard(cardBtn, theme)
    cardBtn.Parent = holder

    local currentColor = config.Default or theme.Primary

    -- Popup (card)
    local popup = Instance.new("Frame")
    popup.Size = UDim2.new(0, scale(280), 0, scale(290))
    popup.Position = UDim2.new(0.5, -scale(140), 0.5, -scale(145))
    popup.BackgroundColor3 = theme.Surface
    popup.BorderSizePixel = 0
    popup.Visible = false
    popup.ZIndex = 100
    applyCard(popup, theme)
    popup.Parent = holder

    -- SV area
    local svImage = Instance.new("ImageLabel")
    svImage.Size = UDim2.new(1, -scale(16), 0, scale(180))
    svImage.Position = UDim2.new(0, scale(8), 0, scale(8))
    svImage.BackgroundColor3 = Color3.new(1,1,1)
    svImage.BorderSizePixel = 0
    Instance.new("UICorner", svImage).CornerRadius = UDim.new(0, 8)
    local hGrad = Instance.new("UIGradient")
    hGrad.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Color3.new(1,1,1)), ColorSequenceKeypoint.new(1, currentColor)}
    hGrad.Parent = svImage
    local vGrad = Instance.new("UIGradient")
    vGrad.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Color3.new(0,0,0,0)), ColorSequenceKeypoint.new(1, Color3.new(0,0,0))}
    vGrad.Rotation = 90
    vGrad.Parent = svImage
    svImage.Parent = popup

    local svKnob = Instance.new("Frame")
    svKnob.Size = UDim2.new(0, scale(12), 0, scale(12))
    svKnob.BackgroundColor3 = Color3.new(1,1,1)
    svKnob.BorderSizePixel = 0
    svKnob.AnchorPoint = Vector2.new(0.5,0.5)
    Instance.new("UICorner", svKnob).CornerRadius = UDim.new(1,0)
    svKnob.Parent = svImage

    -- Hue bar
    local hueBar = Instance.new("Frame")
    hueBar.Size = UDim2.new(1, -scale(16), 0, scale(18))
    hueBar.Position = UDim2.new(0, scale(8), 0, scale(196))
    hueBar.BorderSizePixel = 0
    Instance.new("UICorner", hueBar).CornerRadius = UDim.new(0, 8)
    local hueGrad = Instance.new("UIGradient")
    hueGrad.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255,0,0)),
        ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255,255,0)),
        ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0,255,0)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0,255,255)),
        ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0,0,255)),
        ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255,0,255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255,0,0)),
    }
    hueGrad.Parent = hueBar
    hueBar.Parent = popup

    local hueKnob = Instance.new("Frame")
    hueKnob.Size = UDim2.new(0, scale(14), 0, scale(24))
    hueKnob.Position = UDim2.new(0.5, -scale(7), 0, -scale(3))
    hueKnob.BackgroundColor3 = Color3.new(1,1,1)
    hueKnob.BorderSizePixel = 0
    Instance.new("UICorner", hueKnob).CornerRadius = UDim.new(0, 6)
    hueKnob.Parent = hueBar

    local confirmBtn = Instance.new("TextButton")
    confirmBtn.Size = UDim2.new(1, -scale(16), 0, scale(36))
    confirmBtn.Position = UDim2.new(0, scale(8), 1, -scale(44))
    confirmBtn.BackgroundColor3 = theme.Primary
    confirmBtn.Text = "Confirm"
    confirmBtn.TextColor3 = Color3.new(1,1,1)
    confirmBtn.Font = Enum.Font.GothamBold
    confirmBtn.TextSize = scale(13)
    confirmBtn.BorderSizePixel = 0
    Instance.new("UICorner", confirmBtn).CornerRadius = UDim.new(0, 8)
    confirmBtn.Parent = popup

    -- Color helpers
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
        return Color3.fromRGB(r*255, g*255, b*255)
    end

    local function updateFromSVH(sat, val, hue)
        currentColor = HSVtoRGB(hue, sat, 1 - val)
        preview.BackgroundColor3 = currentColor
        hGrad.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.new(1,1,1)),
            ColorSequenceKeypoint.new(1, HSVtoRGB(hue, 1, 1))
        }
    end

    local draggingSV, draggingH = false, false
    local function updatePick()
        local sx = svKnob.Position.X.Scale
        local sy = svKnob.Position.Y.Scale
        local hx = hueKnob.Position.X.Scale
        updateFromSVH(sx, sy, hx)
    end

    svImage.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then draggingSV = true end
    end)
    svImage.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then draggingSV = false end
    end)
    UserInputService.TouchMoved:Connect(function(touch, processed)
        if draggingSV and not processed then
            local pos = svImage.AbsolutePosition
            local size = svImage.AbsoluteSize
            local rx = math.clamp((touch.Position.X - pos.X) / size.X, 0, 1)
            local ry = math.clamp((touch.Position.Y - pos.Y) / size.Y, 0, 1)
            svKnob.Position = UDim2.new(rx, -scale(6), ry, -scale(6))
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
            hueKnob.Position = UDim2.new(rx, -scale(7), 0, -scale(3))
            updatePick()
        end
    end)

    cardBtn.MouseButton1Click:Connect(function()
        popup.Visible = not popup.Visible
    end)
    confirmBtn.MouseButton1Click:Connect(function()
        popup.Visible = false
        if config.Callback then config.Callback(currentColor) end
    end)

    holder.Parent = parent
    local self = setmetatable({ Instance = holder }, ColorPicker)
    self.Theme = theme
    self.GetColor = function() return currentColor end
    self.SetColor = function(c) currentColor = c; preview.BackgroundColor3 = c end
    return self
end

-- ====================== SEARCH BAR ======================
local SearchBar = setmetatable({}, ComponentBase)
SearchBar.__index = SearchBar

function SearchBar.new(parent, config, theme)
    local holder = Instance.new("Frame")
    holder.Size = UDim2.new(1, 0, 0, scale(44))
    holder.BackgroundTransparency = 1
    holder.Name = "SearchBarHolder"

    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, 0, 1, 0)
    card.BackgroundColor3 = theme.Surface
    card.BorderSizePixel = 0
    card.ZIndex = 2
    applyCard(card, theme)
    card.Parent = holder

    local icon = Instance.new("TextLabel")
    icon.Size = UDim2.new(0, scale(20), 0, scale(20))
    icon.Position = UDim2.new(0, scale(8), 0.5, -scale(10))
    icon.BackgroundTransparency = 1
    icon.Text = "🔍"
    icon.TextColor3 = theme.TextSecondary
    icon.Font = Enum.Font.GothamBold
    icon.TextSize = scale(12)
    icon.Parent = card

    local box = Instance.new("TextBox")
    box.Size = UDim2.new(1, -scale(48), 1, 0)
    box.Position = UDim2.new(0, scale(32), 0, 0)
    box.BackgroundTransparency = 1
    box.Text = config.Default or ""
    box.PlaceholderText = config.Placeholder or "Search..."
    box.TextColor3 = theme.TextPrimary
    box.PlaceholderColor3 = theme.TextSecondary
    box.Font = Enum.Font.Gotham
    box.TextSize = scale(14)
    box.BorderSizePixel = 0
    box.ClearTextOnFocus = false
    box.ZIndex = 3
    box.Parent = card

    local clearBtn = Instance.new("TextButton")
    clearBtn.Size = UDim2.new(0, scale(18), 0, scale(18))
    clearBtn.Position = UDim2.new(1, -scale(24), 0.5, -scale(9))
    clearBtn.BackgroundTransparency = 1
    clearBtn.Text = "✕"
    clearBtn.TextColor3 = theme.TextSecondary
    clearBtn.Font = Enum.Font.GothamBold
    clearBtn.TextSize = scale(11)
    clearBtn.ZIndex = 4
    clearBtn.Visible = (box.Text ~= "")
    clearBtn.Parent = card

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

-- ====================== NOTIFICATIONS ======================
local NotificationManager = {}
function NotificationManager:Show(config, theme)
    local notif = Instance.new("Frame")
    notif.Size = UDim2.new(1, -scale(16), 0, scale(56))
    notif.Position = UDim2.new(0.5, 0, 1, scale(-10))
    notif.AnchorPoint = Vector2.new(0.5, 1)
    notif.BackgroundColor3 = theme.Surface
    notif.BorderSizePixel = 0
    notif.ZIndex = 200
    applyCard(notif, theme)
    notif.Parent = PlayerGui

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -scale(28), 0, scale(18))
    title.Position = UDim2.new(0, scale(10), 0, scale(8))
    title.BackgroundTransparency = 1
    title.Text = config.Title or "Notification"
    title.TextColor3 = theme.TextPrimary
    title.Font = Enum.Font.GothamBold
    title.TextSize = scale(13)
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = notif

    local msg = Instance.new("TextLabel")
    msg.Size = UDim2.new(1, -scale(28), 0, scale(16))
    msg.Position = UDim2.new(0, scale(10), 0, scale(28))
    msg.BackgroundTransparency = 1
    msg.Text = config.Text or ""
    msg.TextColor3 = theme.TextSecondary
    msg.Font = Enum.Font.Gotham
    msg.TextSize = scale(11)
    msg.TextXAlignment = Enum.TextXAlignment.Left
    msg.Parent = notif

    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, scale(22), 0, scale(22))
    closeBtn.Position = UDim2.new(1, -scale(26), 0, scale(4))
    closeBtn.BackgroundTransparency = 1
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = theme.TextSecondary
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = scale(14)
    closeBtn.Parent = notif

    tween(notif, {Position = UDim2.new(0.5, 0, 1, -scale(70))}, 0.3, Enum.EasingStyle.Back)

    local self = { Instance = notif }
    local timer
    if config.Duration and config.Duration > 0 then
        timer = task.delay(config.Duration, function() self:Dismiss() end)
    end
    closeBtn.MouseButton1Click:Connect(function()
        if timer then task.cancel(timer) end
        self:Dismiss()
    end)
    function self:Dismiss()
        tween(notif, {Position = UDim2.new(0.5, 0, 1, scale(80))}, 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In, function()
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
    container.Size = UDim2.new(0, scale(280), 0, scale(180))
    container.Position = UDim2.new(0.5, -scale(140), 0.5, -scale(90))
    container.BackgroundColor3 = theme.Surface
    container.BorderSizePixel = 0
    container.ZIndex = 151
    applyCard(container, theme)
    container.Parent = overlay

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -scale(16), 0, scale(24))
    titleLabel.Position = UDim2.new(0, scale(8), 0, scale(8))
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = config.Title or "Dialog"
    titleLabel.TextColor3 = theme.TextPrimary
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = scale(15)
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = container

    local msgLabel = Instance.new("TextLabel")
    msgLabel.Size = UDim2.new(1, -scale(16), 0, scale(70))
    msgLabel.Position = UDim2.new(0, scale(8), 0, scale(38))
    msgLabel.BackgroundTransparency = 1
    msgLabel.Text = config.Text or ""
    msgLabel.TextColor3 = theme.TextSecondary
    msgLabel.Font = Enum.Font.Gotham
    msgLabel.TextSize = scale(13)
    msgLabel.TextWrapped = true
    msgLabel.TextXAlignment = Enum.TextXAlignment.Left
    msgLabel.Parent = container

    local btnFrame = Instance.new("Frame")
    btnFrame.Size = UDim2.new(1, -scale(16), 0, scale(36))
    btnFrame.Position = UDim2.new(0, scale(8), 1, -scale(44))
    btnFrame.BackgroundTransparency = 1
    btnFrame.Parent = container

    local buttons = config.Buttons or {{Text = "OK", Callback = function() end}}
    for i, btnConfig in ipairs(buttons) do
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(1 / #buttons, -scale(6), 1, 0)
        b.Position = UDim2.new((i-1)/#buttons, scale(3), 0, 0)
        b.BackgroundColor3 = theme.Primary
        b.Text = btnConfig.Text or "Button"
        b.TextColor3 = Color3.new(1,1,1)
        b.Font = Enum.Font.GothamBold
        b.TextSize = scale(13)
        b.BorderSizePixel = 0
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
        b.Parent = btnFrame
        b.MouseButton1Click:Connect(function()
            if btnConfig.Callback then btnConfig.Callback() end
            overlay:Destroy()
        end)
    end

    tween(container, {Size = UDim2.new(0, scale(280), 0, scale(180))}, 0.2, Enum.EasingStyle.Back)
    return overlay
end

-- ====================== TAB SYSTEM ======================
local Tab = {}
Tab.__index = Tab

function Tab.new(name, icon, theme, parent)
    local page = Instance.new("ScrollingFrame")
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.ScrollBarThickness = scale(3)
    page.ScrollBarImageColor3 = theme.ScrollBar
    page.CanvasSize = UDim2.new(0, 0, 0, 0)
    page.BorderSizePixel = 0
    page.ScrollingDirection = Enum.ScrollingDirection.Y
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.Visible = false
    page.Parent = parent

    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, scale(8))
    listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Parent = page

    local self = setmetatable({
        Page = page,
        Name = name,
        Icon = icon,
        Theme = theme
    }, Tab)
    return self
end

function Tab:AddComponent(component)
    component.Instance.Parent = self.Page
    component.Instance.LayoutOrder = #self.Page:GetChildren()
    return component
end

-- Component creation shortcuts
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

-- ====================== WINDOW SYSTEM ======================
local Window = {}
Window.__index = Window

function Window.new(config)
    local self = setmetatable({}, Window)
    local themeName = config.Theme or "Dark"
    local theme = THEME[themeName] or THEME.Dark
    self.Theme = theme

    local gui = Instance.new("ScreenGui")
    gui.Name = "MobileUI_" .. (config.Title or "Hub")
    gui.Parent = PlayerGui
    gui.IgnoreGuiInset = true   -- utilise full screen area
    self.Gui = gui

    -- Viewport-based sizing
    local screenW = Camera.ViewportSize.X
    local screenH = Camera.ViewportSize.Y
    local windowW = math.min(screenW, scale(370))
    local windowH = math.min(screenH, scale(680))

    local mainContainer = Instance.new("Frame")
    mainContainer.Size = UDim2.new(0, windowW, 0, windowH)
    mainContainer.Position = UDim2.new(0.5, -windowW/2, 0.5, -windowH/2)
    mainContainer.BackgroundColor3 = theme.Background
    mainContainer.BorderSizePixel = 0
    mainContainer.ZIndex = 1
    applyCard(mainContainer, theme)   -- card border around whole window
    mainContainer.Parent = gui
    self.MainContainer = mainContainer

    -- Drag handle (thin bar)
    local dragHandle = Instance.new("TextButton")
    dragHandle.Size = UDim2.new(1, 0, 0, scale(36))
    dragHandle.BackgroundTransparency = 1
    dragHandle.Text = ""
    dragHandle.ZIndex = 10
    dragHandle.Parent = mainContainer

    local titleBar = Instance.new("TextLabel")
    titleBar.Size = UDim2.new(1, -scale(90), 1, 0)
    titleBar.Position = UDim2.new(0, scale(12), 0, 0)
    titleBar.BackgroundTransparency = 1
    titleBar.Text = config.Title or "Mobile Hub"
    titleBar.TextColor3 = theme.TextPrimary
    titleBar.Font = Enum.Font.GothamBold
    titleBar.TextSize = scale(16)
    titleBar.TextXAlignment = Enum.TextXAlignment.Left
    titleBar.ZIndex = 10
    titleBar.Parent = dragHandle

    -- Window controls
    local function makeWinBtn(text, posX)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, scale(26), 0, scale(26))
        btn.Position = UDim2.new(1, posX, 0.5, -scale(13))
        btn.BackgroundColor3 = theme.Surface
        btn.Text = text
        btn.TextColor3 = theme.TextPrimary
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = scale(16)
        btn.BorderSizePixel = 0
        btn.ZIndex = 10
        applyCard(btn, theme)
        btn.Parent = dragHandle
        return btn
    end
    local minimizeBtn = makeWinBtn("–", -scale(58))
    local expandBtn = makeWinBtn("⛶", -scale(30))

    local contentArea = Instance.new("Frame")
    contentArea.Size = UDim2.new(1, 0, 1, -scale(86))
    contentArea.Position = UDim2.new(0, 0, 0, scale(36))
    contentArea.BackgroundTransparency = 1
    contentArea.BorderSizePixel = 0
    contentArea.Parent = mainContainer
    self.ContentArea = contentArea

    -- Bottom navigation
    local bottomNav = Instance.new("Frame")
    bottomNav.Size = UDim2.new(1, -scale(12), 0, scale(44))
    bottomNav.Position = UDim2.new(0, scale(6), 1, -scale(50))
    bottomNav.BackgroundColor3 = theme.Surface
    bottomNav.BorderSizePixel = 0
    applyCard(bottomNav, theme)
    bottomNav.Parent = mainContainer
    self.BottomNav = bottomNav

    local tabList = Instance.new("UIListLayout")
    tabList.FillDirection = Enum.FillDirection.Horizontal
    tabList.HorizontalAlignment = Enum.HorizontalAlignment.Center
    tabList.VerticalAlignment = Enum.VerticalAlignment.Center
    tabList.Padding = UDim.new(0, scale(6))
    tabList.Parent = bottomNav

    self.Tabs = {}
    self.ActiveTab = nil

    -- Dragging (touch)
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
            local newX = dragOffset.X.Offset + delta.X
            local newY = dragOffset.Y.Offset + delta.Y
            newX = math.clamp(newX, 0, screenW - mainContainer.Size.X.Offset)
            newY = math.clamp(newY, 0, screenH - mainContainer.Size.Y.Offset)
            mainContainer.Position = UDim2.new(0, newX, 0, newY)
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
    minimizedBar.Size = UDim2.new(0, scale(180), 0, scale(36))
    minimizedBar.Position = UDim2.new(0.5, -scale(90), 1, scale(-6))
    minimizedBar.AnchorPoint = Vector2.new(0.5, 1)
    minimizedBar.BackgroundColor3 = theme.Surface
    minimizedBar.Text = config.Title or "Hub"
    minimizedBar.TextColor3 = theme.TextPrimary
    minimizedBar.Font = Enum.Font.GothamBold
    minimizedBar.TextSize = scale(14)
    minimizedBar.BorderSizePixel = 0
    minimizedBar.Visible = false
    minimizedBar.ZIndex = 50
    applyCard(minimizedBar, theme)
    minimizedBar.Parent = gui
    minimizedBar.MouseButton1Click:Connect(function()
        tween(mainContainer, {Size = originalSize, Position = originalPos}, 0.3, Enum.EasingStyle.Back)
        minimizedBar.Visible = false
        minimized = false
    end)
    minimizeBtn.MouseButton1Click:Connect(function()
        if minimized then return end
        minimized = true
        originalSize = mainContainer.Size
        originalPos = mainContainer.Position
        tween(mainContainer, {Size = UDim2.new(0, scale(180), 0, scale(36)), Position = UDim2.new(0.5, -scale(90), 1, scale(-6))}, 0.3, Enum.EasingStyle.Back, nil, function()
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
            tween(mainContainer, {Size = UDim2.new(0, screenW, 0, screenH), Position = UDim2.new(0, 0, 0, 0)}, 0.3)
        else
            tween(mainContainer, {Size = originalSize, Position = originalPos}, 0.3)
        end
    end)

    -- Auto-resize on viewport change
    Camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
        screenSize = Camera.ViewportSize
        scaleFactor = math.min(screenSize.X / BASE_WIDTH, screenSize.Y / BASE_HEIGHT)
        screenW = screenSize.X
        screenH = screenSize.Y
        if not expanded and not minimized then
            windowW = math.min(screenW, scale(370))
            windowH = math.min(screenH, scale(680))
            mainContainer.Size = UDim2.new(0, windowW, 0, windowH)
            mainContainer.Position = UDim2.new(0.5, -windowW/2, 0.5, -windowH/2)
        end
    end)

    function self:SetTheme(themeName)
        self.Theme = THEME[themeName] or THEME.Dark
        -- Update main window colors quickly (for a full re-theme, components must be recreated)
        mainContainer.BackgroundColor3 = self.Theme.Background
        bottomNav.BackgroundColor3 = self.Theme.Surface
        titleBar.TextColor3 = self.Theme.TextPrimary
    end

    return self
end

function Window:CreateTab(name, icon)
    local tab = Tab.new(name, icon or "•", self.Theme, self.ContentArea)

    local tabBtn = Instance.new("TextButton")
    tabBtn.Size = UDim2.new(0, scale(48), 0, scale(36))
    tabBtn.BackgroundColor3 = self.Theme.Surface
    tabBtn.Text = icon or name:sub(1,1)
    tabBtn.TextColor3 = self.Theme.TextSecondary
    tabBtn.Font = Enum.Font.GothamBold
    tabBtn.TextSize = scale(15)
    tabBtn.BorderSizePixel = 0
    applyCard(tabBtn, self.Theme)
    tabBtn.Parent = self.BottomNav

    local function selectTab()
        for _, t in ipairs(self.Tabs) do t.Page.Visible = false end
        for _, btn in ipairs(self.BottomNav:GetChildren()) do
            if btn:IsA("TextButton") then
                btn.BackgroundColor3 = self.Theme.Surface
                btn.TextColor3 = self.Theme.TextSecondary
            end
        end
        tab.Page.Visible = true
        tabBtn.BackgroundColor3 = self.Theme.Primary
        tabBtn.TextColor3 = Color3.new(1,1,1)
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