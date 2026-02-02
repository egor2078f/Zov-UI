--[[
    RavionUI Premium Library v3.0
    Полная поддержка ПК и мобильных устройств
    Улучшенные элементы и анимации
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local GuiService = game:GetService("GuiService")
local TextService = game:GetService("TextService")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera

-- Определение платформы
local IsMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
local IsTablet = UserInputService.TouchEnabled and (Camera.ViewportSize.X > 600)
local IsPlatformPC = not UserInputService.TouchEnabled

-- Темы
local Themes = {
    Dark = {
        Background = Color3.fromRGB(18, 18, 22),
        Secondary = Color3.fromRGB(24, 24, 30),
        Tertiary = Color3.fromRGB(32, 32, 40),
        Sidebar = Color3.fromRGB(22, 22, 28),
        Section = Color3.fromRGB(28, 28, 35),
        Text = Color3.fromRGB(245, 245, 250),
        TextDark = Color3.fromRGB(140, 140, 155),
        TextMuted = Color3.fromRGB(100, 100, 115),
        Accent = Color3.fromRGB(88, 101, 242),
        AccentDark = Color3.fromRGB(71, 82, 196),
        AccentLight = Color3.fromRGB(114, 127, 255),
        Border = Color3.fromRGB(48, 48, 58),
        BorderLight = Color3.fromRGB(58, 58, 70),
        Hover = Color3.fromRGB(40, 40, 50),
        Success = Color3.fromRGB(67, 181, 129),
        Warning = Color3.fromRGB(250, 166, 26),
        Error = Color3.fromRGB(237, 66, 69),
        Info = Color3.fromRGB(59, 165, 222),
        Shadow = Color3.fromRGB(0, 0, 0),
        Divider = Color3.fromRGB(45, 45, 55),
        Input = Color3.fromRGB(20, 20, 26),
        ScrollBar = Color3.fromRGB(60, 60, 75)
    },
    Light = {
        Background = Color3.fromRGB(250, 250, 252),
        Secondary = Color3.fromRGB(245, 245, 248),
        Tertiary = Color3.fromRGB(238, 238, 242),
        Sidebar = Color3.fromRGB(248, 248, 252),
        Section = Color3.fromRGB(255, 255, 255),
        Text = Color3.fromRGB(25, 25, 35),
        TextDark = Color3.fromRGB(85, 85, 100),
        TextMuted = Color3.fromRGB(130, 130, 145),
        Accent = Color3.fromRGB(88, 101, 242),
        AccentDark = Color3.fromRGB(71, 82, 196),
        AccentLight = Color3.fromRGB(114, 127, 255),
        Border = Color3.fromRGB(218, 218, 228),
        BorderLight = Color3.fromRGB(228, 228, 238),
        Hover = Color3.fromRGB(235, 235, 240),
        Success = Color3.fromRGB(67, 181, 129),
        Warning = Color3.fromRGB(250, 166, 26),
        Error = Color3.fromRGB(237, 66, 69),
        Info = Color3.fromRGB(59, 165, 222),
        Shadow = Color3.fromRGB(0, 0, 0),
        Divider = Color3.fromRGB(228, 228, 238),
        Input = Color3.fromRGB(252, 252, 255),
        ScrollBar = Color3.fromRGB(180, 180, 195)
    },
    Midnight = {
        Background = Color3.fromRGB(10, 10, 15),
        Secondary = Color3.fromRGB(15, 15, 22),
        Tertiary = Color3.fromRGB(22, 22, 32),
        Sidebar = Color3.fromRGB(12, 12, 18),
        Section = Color3.fromRGB(18, 18, 26),
        Text = Color3.fromRGB(240, 240, 250),
        TextDark = Color3.fromRGB(120, 120, 140),
        TextMuted = Color3.fromRGB(80, 80, 100),
        Accent = Color3.fromRGB(147, 112, 219),
        AccentDark = Color3.fromRGB(123, 93, 183),
        AccentLight = Color3.fromRGB(170, 140, 240),
        Border = Color3.fromRGB(35, 35, 48),
        BorderLight = Color3.fromRGB(45, 45, 60),
        Hover = Color3.fromRGB(28, 28, 40),
        Success = Color3.fromRGB(80, 200, 120),
        Warning = Color3.fromRGB(255, 180, 50),
        Error = Color3.fromRGB(255, 85, 85),
        Info = Color3.fromRGB(100, 180, 255),
        Shadow = Color3.fromRGB(0, 0, 0),
        Divider = Color3.fromRGB(30, 30, 42),
        Input = Color3.fromRGB(12, 12, 18),
        ScrollBar = Color3.fromRGB(50, 50, 70)
    },
    Ocean = {
        Background = Color3.fromRGB(15, 22, 30),
        Secondary = Color3.fromRGB(20, 28, 38),
        Tertiary = Color3.fromRGB(28, 38, 50),
        Sidebar = Color3.fromRGB(18, 25, 35),
        Section = Color3.fromRGB(25, 35, 48),
        Text = Color3.fromRGB(235, 245, 255),
        TextDark = Color3.fromRGB(130, 150, 175),
        TextMuted = Color3.fromRGB(90, 110, 135),
        Accent = Color3.fromRGB(32, 178, 170),
        AccentDark = Color3.fromRGB(26, 142, 136),
        AccentLight = Color3.fromRGB(64, 200, 192),
        Border = Color3.fromRGB(40, 55, 72),
        BorderLight = Color3.fromRGB(50, 68, 88),
        Hover = Color3.fromRGB(35, 48, 65),
        Success = Color3.fromRGB(72, 199, 142),
        Warning = Color3.fromRGB(255, 193, 7),
        Error = Color3.fromRGB(244, 67, 54),
        Info = Color3.fromRGB(33, 150, 243),
        Shadow = Color3.fromRGB(0, 0, 0),
        Divider = Color3.fromRGB(38, 52, 68),
        Input = Color3.fromRGB(18, 26, 36),
        ScrollBar = Color3.fromRGB(55, 75, 100)
    }
}

local Library = {
    Flags = {},
    Open = true,
    Minimized = false,
    AccentColor = Themes.Dark.Accent,
    Theme = "Dark",
    CurrentTheme = Themes.Dark,
    Keybind = Enum.KeyCode.RightControl,
    SoundsEnabled = true,
    AnimationsEnabled = true,
    SaveConfig = true,
    ConfigFolder = "RavionUI",
    Windows = {},
    Connections = {},
    ToggleCallbacks = {}
}

local CurrentKeybinds = {}
local ActiveDropdowns = {}
local ActiveTooltip = nil

-- Утилиты
local Utils = {}

function Utils.Create(className, properties)
    local instance = Instance.new(className)
    for prop, value in pairs(properties or {}) do
        if prop ~= "Parent" then
            instance[prop] = value
        end
    end
    if properties and properties.Parent then
        instance.Parent = properties.Parent
    end
    return instance
end

function Utils.Tween(object, tweenInfo, properties)
    if not Library.AnimationsEnabled then
        for prop, val in pairs(properties) do
            object[prop] = val
        end
        return
    end
    local tween = TweenService:Create(object, tweenInfo, properties)
    tween:Play()
    return tween
end

function Utils.QuickTween(object, duration, properties)
    return Utils.Tween(object, TweenInfo.new(duration, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), properties)
end

function Utils.AddCorner(parent, radius)
    return Utils.Create("UICorner", {
        CornerRadius = UDim.new(0, radius or 6),
        Parent = parent
    })
end

function Utils.AddStroke(parent, color, thickness, transparency)
    return Utils.Create("UIStroke", {
        Color = color or Library.CurrentTheme.Border,
        Thickness = thickness or 1,
        Transparency = transparency or 0,
        Parent = parent
    })
end

function Utils.AddPadding(parent, padding)
    local p = padding or 8
    return Utils.Create("UIPadding", {
        PaddingTop = UDim.new(0, p),
        PaddingBottom = UDim.new(0, p),
        PaddingLeft = UDim.new(0, p),
        PaddingRight = UDim.new(0, p),
        Parent = parent
    })
end

function Utils.AddShadow(parent)
    local shadow = Utils.Create("ImageLabel", {
        Name = "Shadow",
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Position = UDim2.new(0.5, 0, 0.5, 4),
        Size = UDim2.new(1, 24, 1, 24),
        ZIndex = -1,
        Image = "rbxassetid://6014261993",
        ImageColor3 = Color3.fromRGB(0, 0, 0),
        ImageTransparency = 0.5,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(49, 49, 450, 450),
        Parent = parent
    })
    return shadow
end

function Utils.AddGradient(parent, colors, rotation)
    local colorSeq = {}
    for i, color in ipairs(colors) do
        table.insert(colorSeq, ColorSequenceKeypoint.new((i - 1) / (#colors - 1), color))
    end
    return Utils.Create("UIGradient", {
        Color = ColorSequence.new(colorSeq),
        Rotation = rotation or 0,
        Parent = parent
    })
end

function Utils.Ripple(button, color)
    local ripple = Utils.Create("Frame", {
        Name = "Ripple",
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = color or Library.CurrentTheme.Accent,
        BackgroundTransparency = 0.7,
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(0, 0, 0, 0),
        Parent = button
    })
    Utils.AddCorner(ripple, 100)
    
    local size = math.max(button.AbsoluteSize.X, button.AbsoluteSize.Y) * 2
    local tween = Utils.Tween(ripple, TweenInfo.new(0.5), {
        Size = UDim2.new(0, size, 0, size),
        BackgroundTransparency = 1
    })
    if tween then
        tween.Completed:Connect(function()
            ripple:Destroy()
        end)
    else
        ripple:Destroy()
    end
end

function Utils.PlaySound(soundId, volume)
    if not Library.SoundsEnabled then return end
    local sound = Instance.new("Sound")
    sound.SoundId = "rbxassetid://" .. soundId
    sound.Volume = volume or 0.5
    sound.Parent = CoreGui
    sound:Play()
    sound.Ended:Connect(function()
        sound:Destroy()
    end)
end

function Utils.GetTextSize(text, textSize, font, frameSize)
    return TextService:GetTextSize(text, textSize, font, frameSize or Vector2.new(math.huge, math.huge))
end

function Utils.DeepCopy(original)
    local copy = {}
    for k, v in pairs(original) do
        if type(v) == "table" then
            copy[k] = Utils.DeepCopy(v)
        else
            copy[k] = v
        end
    end
    return copy
end

-- Создание GUI для уведомлений
local NotificationContainer = Utils.Create("ScreenGui", {
    Name = "RavionNotifications",
    ZIndexBehavior = Enum.ZIndexBehavior.Global,
    ResetOnSpawn = false,
    IgnoreGuiInset = true
})

local function SafeParent(gui)
    local success = pcall(function()
        gui.Parent = CoreGui
    end)
    if not success then
        gui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end
end

SafeParent(NotificationContainer)

local NotificationHolder = Utils.Create("Frame", {
    Name = "Holder",
    AnchorPoint = Vector2.new(1, 1),
    BackgroundTransparency = 1,
    Position = UDim2.new(1, -20, 1, -20),
    Size = UDim2.new(0, 320, 1, -40),
    Parent = NotificationContainer
})

local NotificationLayout = Utils.Create("UIListLayout", {
    Padding = UDim.new(0, 10),
    HorizontalAlignment = Enum.HorizontalAlignment.Right,
    VerticalAlignment = Enum.VerticalAlignment.Bottom,
    SortOrder = Enum.SortOrder.LayoutOrder,
    Parent = NotificationHolder
})

-- Dragging system с поддержкой touch
local function MakeDraggable(dragHandle, target)
    local dragging = false
    local dragInput
    local dragStart
    local startPos
    
    local function Update(input)
        local delta = input.Position - dragStart
        local newPos = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
        Utils.QuickTween(target, 0.1, {Position = newPos})
    end
    
    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or
           input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = target.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    dragHandle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or
           input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    table.insert(Library.Connections, UserInputService.InputChanged:Connect(function(input)
        if dragging and input == dragInput then
            Update(input)
        end
    end))
end

-- Tooltip System
local TooltipFrame = Utils.Create("Frame", {
    Name = "Tooltip",
    BackgroundColor3 = Themes.Dark.Tertiary,
    Size = UDim2.new(0, 0, 0, 0),
    Visible = false,
    ZIndex = 1000,
    Parent = NotificationContainer
})
Utils.AddCorner(TooltipFrame, 4)
Utils.AddStroke(TooltipFrame, Themes.Dark.Border)

local TooltipText = Utils.Create("TextLabel", {
    BackgroundTransparency = 1,
    Size = UDim2.new(1, -16, 1, -8),
    Position = UDim2.new(0, 8, 0, 4),
    Font = Enum.Font.Gotham,
    TextColor3 = Themes.Dark.Text,
    TextSize = 12,
    TextWrapped = true,
    ZIndex = 1001,
    Parent = TooltipFrame
})

local function ShowTooltip(text, position)
    local textSize = Utils.GetTextSize(text, 12, Enum.Font.Gotham, Vector2.new(200, math.huge))
    TooltipFrame.Size = UDim2.new(0, textSize.X + 16, 0, textSize.Y + 8)
    TooltipFrame.Position = UDim2.new(0, position.X + 10, 0, position.Y + 10)
    TooltipText.Text = text
    TooltipFrame.Visible = true
end

local function HideTooltip()
    TooltipFrame.Visible = false
end

-- Notification System
function Library:Notify(config)
    if type(config) == "string" then
        config = {Title = "Notification", Text = config, Duration = 3}
    end
    
    local title = config.Title or "Notification"
    local text = config.Text or ""
    local duration = config.Duration or 3
    local notifType = config.Type or "Info"
    local callback = config.Callback
    
    local typeColors = {
        Info = Library.CurrentTheme.Info,
        Success = Library.CurrentTheme.Success,
        Warning = Library.CurrentTheme.Warning,
        Error = Library.CurrentTheme.Error
    }
    
    local typeIcons = {
        Info = "ℹ",
        Success = "✓",
        Warning = "⚠",
        Error = "✗"
    }
    
    local color = typeColors[notifType] or Library.CurrentTheme.Accent
    
    local Notification = Utils.Create("Frame", {
        Name = "Notification",
        BackgroundColor3 = Library.CurrentTheme.Section,
        Size = UDim2.new(1, 0, 0, 80),
        ClipsDescendants = true,
        Parent = NotificationHolder
    })
    Utils.AddCorner(Notification, 8)
    Utils.AddShadow(Notification)
    
    local AccentBar = Utils.Create("Frame", {
        BackgroundColor3 = color,
        Size = UDim2.new(0, 4, 1, 0),
        Parent = Notification
    })
    Utils.AddCorner(AccentBar, 2)
    
    local Icon = Utils.Create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 16, 0, 12),
        Size = UDim2.new(0, 24, 0, 24),
        Font = Enum.Font.GothamBold,
        Text = typeIcons[notifType] or "•",
        TextColor3 = color,
        TextSize = 18,
        Parent = Notification
    })
    
    local TitleLabel = Utils.Create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 48, 0, 10),
        Size = UDim2.new(1, -100, 0, 20),
        Font = Enum.Font.GothamBold,
        Text = title,
        TextColor3 = Library.CurrentTheme.Text,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = Notification
    })
    
    local DescLabel = Utils.Create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 48, 0, 32),
        Size = UDim2.new(1, -60, 0, 38),
        Font = Enum.Font.Gotham,
        Text = text,
        TextColor3 = Library.CurrentTheme.TextDark,
        TextSize = 12,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        Parent = Notification
    })
    
    local CloseBtn = Utils.Create("TextButton", {
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -32, 0, 8),
        Size = UDim2.new(0, 24, 0, 24),
        Font = Enum.Font.GothamBold,
        Text = "×",
        TextColor3 = Library.CurrentTheme.TextDark,
        TextSize = 18,
        Parent = Notification
    })
    
    local ProgressBar = Utils.Create("Frame", {
        BackgroundColor3 = color,
        Position = UDim2.new(0, 0, 1, -3),
        Size = UDim2.new(1, 0, 0, 3),
        Parent = Notification
    })
    
    -- Анимация входа
    Notification.Position = UDim2.new(1, 50, 0, 0)
    Utils.QuickTween(Notification, 0.3, {Position = UDim2.new(0, 0, 0, 0)})
    
    local function Close()
        Utils.QuickTween(Notification, 0.3, {Position = UDim2.new(1, 50, 0, 0)})
        task.delay(0.3, function()
            Notification:Destroy()
        end)
    end
    
    CloseBtn.MouseButton1Click:Connect(Close)
    
    if callback then
        local ActionBtn = Utils.Create("TextButton", {
            BackgroundColor3 = color,
            Position = UDim2.new(1, -80, 0, 45),
            Size = UDim2.new(0, 70, 0, 26),
            Font = Enum.Font.GothamBold,
            Text = "Action",
            TextColor3 = Color3.new(1, 1, 1),
            TextSize = 11,
            Parent = Notification
        })
        Utils.AddCorner(ActionBtn, 4)
        
        ActionBtn.MouseButton1Click:Connect(function()
            callback()
            Close()
        end)
    end
    
    -- Progress bar
    Utils.Tween(ProgressBar, TweenInfo.new(duration, Enum.EasingStyle.Linear), {Size = UDim2.new(0, 0, 0, 3)})
    
    task.delay(duration, Close)
    
    Utils.PlaySound(6518811702, 0.3)
    
    return Notification
end

-- Config System
function Library:SaveConfig(name)
    if not Library.SaveConfig then return end
    
    local config = {}
    for flag, value in pairs(Library.Flags) do
        if typeof(value) == "Color3" then
            config[flag] = {Type = "Color3", R = value.R, G = value.G, B = value.B}
        elseif typeof(value) == "EnumItem" then
            config[flag] = {Type = "Enum", Name = value.Name, EnumType = tostring(value.EnumType)}
        else
            config[flag] = value
        end
    end
    
    local success, result = pcall(function()
        if not isfolder(Library.ConfigFolder) then
            makefolder(Library.ConfigFolder)
        end
        writefile(Library.ConfigFolder .. "/" .. name .. ".json", HttpService:JSONEncode(config))
    end)
    
    if success then
        Library:Notify({Title = "Config", Text = "Configuration saved: " .. name, Type = "Success", Duration = 2})
    end
    
    return success
end

function Library:LoadConfig(name)
    local success, result = pcall(function()
        local data = readfile(Library.ConfigFolder .. "/" .. name .. ".json")
        return HttpService:JSONDecode(data)
    end)
    
    if success and result then
        for flag, value in pairs(result) do
            if type(value) == "table" then
                if value.Type == "Color3" then
                    Library.Flags[flag] = Color3.new(value.R, value.G, value.B)
                elseif value.Type == "Enum" then
                    Library.Flags[flag] = Enum[value.EnumType:gsub("Enum.", "")][value.Name]
                end
            else
                Library.Flags[flag] = value
            end
        end
        
        -- Обновляем все элементы
        for _, callback in pairs(Library.ToggleCallbacks) do
            pcall(callback)
        end
        
        Library:Notify({Title = "Config", Text = "Configuration loaded: " .. name, Type = "Success", Duration = 2})
    end
    
    return success
end

function Library:GetConfigs()
    local configs = {}
    local success = pcall(function()
        if isfolder(Library.ConfigFolder) then
            for _, file in pairs(listfiles(Library.ConfigFolder)) do
                if file:match("%.json$") then
                    table.insert(configs, file:match("([^/\\]+)%.json$"))
                end
            end
        end
    end)
    return configs
end

-- Set Theme
function Library:SetTheme(themeName)
    if Themes[themeName] then
        Library.Theme = themeName
        Library.CurrentTheme = Themes[themeName]
        Library.AccentColor = Library.CurrentTheme.Accent
        
        -- Обновляем все элементы (если окно существует)
        for _, callback in pairs(Library.ToggleCallbacks) do
            pcall(callback)
        end
    end
end

function Library:SetAccentColor(color)
    Library.AccentColor = color
    Library.CurrentTheme.Accent = color
end

-- Main Window Creation
function Library:CreateWindow(config)
    config = config or {}
    local hubName = config.Title or config.Name or "Ravion UI"
    local subTitle = config.SubTitle or "v3.0"
    local toggleKey = config.ToggleKey or Enum.KeyCode.RightControl
    local size = config.Size or (IsMobile and UDim2.new(0, 380, 0, 340) or UDim2.new(0, 580, 0, 420))
    
    Library.Keybind = toggleKey
    
    -- Удаляем старый UI если есть
    local oldUI = LocalPlayer.PlayerGui:FindFirstChild("RavionUI")
    if oldUI then oldUI:Destroy() end
    
    local oldCore = CoreGui:FindFirstChild("RavionUI")
    if oldCore then oldCore:Destroy() end
    
    -- Создаем основной ScreenGui
    local ScreenGui = Utils.Create("ScreenGui", {
        Name = "RavionUI",
        ZIndexBehavior = Enum.ZIndexBehavior.Global,
        ResetOnSpawn = false,
        IgnoreGuiInset = true
    })
    SafeParent(ScreenGui)
    
    -- Mobile Toggle Button
    local MobileToggle = Utils.Create("TextButton", {
        Name = "MobileToggle",
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, 15, 0.5, 0),
        Size = UDim2.new(0, 50, 0, 50),
        BackgroundColor3 = Library.CurrentTheme.Section,
        Text = "",
        Visible = IsMobile and not Library.Open,
        ZIndex = 100,
        Parent = ScreenGui
    })
    Utils.AddCorner(MobileToggle, 25)
    Utils.AddShadow(MobileToggle)
    MakeDraggable(MobileToggle, MobileToggle)
    
    local MobileIcon = Utils.Create("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Font = Enum.Font.GothamBold,
        Text = "☰",
        TextColor3 = Library.CurrentTheme.Accent,
        TextSize = 22,
        Parent = MobileToggle
    })
    
    -- Main Container
    local MainContainer = Utils.Create("Frame", {
        Name = "MainContainer",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = size,
        BackgroundColor3 = Library.CurrentTheme.Background,
        ClipsDescendants = true,
        Parent = ScreenGui
    })
    Utils.AddCorner(MainContainer, 10)
    Utils.AddShadow(MainContainer)
    
    -- Header
    local Header = Utils.Create("Frame", {
        Name = "Header",
        Size = UDim2.new(1, 0, 0, 42),
        BackgroundColor3 = Library.CurrentTheme.Sidebar,
        Parent = MainContainer
    })
    Utils.AddCorner(Header, 10)
    
    -- Header bottom fix (для скругления только сверху)
    local HeaderFix = Utils.Create("Frame", {
        Size = UDim2.new(1, 0, 0, 15),
        Position = UDim2.new(0, 0, 1, -15),
        BackgroundColor3 = Library.CurrentTheme.Sidebar,
        BorderSizePixel = 0,
        Parent = Header
    })
    
    MakeDraggable(Header, MainContainer)
    
    -- Logo/Icon
    local LogoContainer = Utils.Create("Frame", {
        Size = UDim2.new(0, 32, 0, 32),
        Position = UDim2.new(0, 10, 0.5, -16),
        BackgroundColor3 = Library.CurrentTheme.Accent,
        Parent = Header
    })
    Utils.AddCorner(LogoContainer, 8)
    
    local LogoText = Utils.Create("TextLabel", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBlack,
        Text = hubName:sub(1, 1):upper(),
        TextColor3 = Color3.new(1, 1, 1),
        TextSize = 16,
        Parent = LogoContainer
    })
    
    -- Title
    local TitleContainer = Utils.Create("Frame", {
        Size = UDim2.new(0, 200, 1, 0),
        Position = UDim2.new(0, 52, 0, 0),
        BackgroundTransparency = 1,
        Parent = Header
    })
    
    local Title = Utils.Create("TextLabel", {
        Size = UDim2.new(1, 0, 0.55, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        Text = hubName,
        TextColor3 = Library.CurrentTheme.Text,
        TextSize = 15,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = TitleContainer
    })
    
    local SubTitle = Utils.Create("TextLabel", {
        Size = UDim2.new(1, 0, 0.45, 0),
        Position = UDim2.new(0, 0, 0.55, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        Text = subTitle,
        TextColor3 = Library.CurrentTheme.TextMuted,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = TitleContainer
    })
    
    -- Header Buttons
    local HeaderButtons = Utils.Create("Frame", {
        Size = UDim2.new(0, 100, 0, 30),
        Position = UDim2.new(1, -105, 0.5, -15),
        BackgroundTransparency = 1,
        Parent = Header
    })
    
    local MinimizeBtn = Utils.Create("TextButton", {
        Size = UDim2.new(0, 30, 0, 30),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = Library.CurrentTheme.Tertiary,
        Font = Enum.Font.GothamBold,
        Text = "−",
        TextColor3 = Library.CurrentTheme.TextDark,
        TextSize = 18,
        Parent = HeaderButtons
    })
    Utils.AddCorner(MinimizeBtn, 6)
    
    local MaximizeBtn = Utils.Create("TextButton", {
        Size = UDim2.new(0, 30, 0, 30),
        Position = UDim2.new(0, 35, 0, 0),
        BackgroundColor3 = Library.CurrentTheme.Tertiary,
        Font = Enum.Font.GothamBold,
        Text = "□",
        TextColor3 = Library.CurrentTheme.TextDark,
        TextSize = 14,
        Parent = HeaderButtons
    })
    Utils.AddCorner(MaximizeBtn, 6)
    
    local CloseBtn = Utils.Create("TextButton", {
        Size = UDim2.new(0, 30, 0, 30),
        Position = UDim2.new(0, 70, 0, 0),
        BackgroundColor3 = Library.CurrentTheme.Error,
        Font = Enum.Font.GothamBold,
        Text = "×",
        TextColor3 = Color3.new(1, 1, 1),
        TextSize = 18,
        Parent = HeaderButtons
    })
    Utils.AddCorner(CloseBtn, 6)
    
    -- Button hover effects
    for _, btn in pairs({MinimizeBtn, MaximizeBtn}) do
        btn.MouseEnter:Connect(function()
            Utils.QuickTween(btn, 0.15, {BackgroundColor3 = Library.CurrentTheme.Hover})
        end)
        btn.MouseLeave:Connect(function()
            Utils.QuickTween(btn, 0.15, {BackgroundColor3 = Library.CurrentTheme.Tertiary})
        end)
    end
    
    CloseBtn.MouseEnter:Connect(function()
        Utils.QuickTween(CloseBtn, 0.15, {BackgroundColor3 = Color3.fromRGB(255, 80, 80)})
    end)
    CloseBtn.MouseLeave:Connect(function()
        Utils.QuickTween(CloseBtn, 0.15, {BackgroundColor3 = Library.CurrentTheme.Error})
    end)
    
    -- Content Container
    local ContentContainer = Utils.Create("Frame", {
        Name = "ContentContainer",
        Size = UDim2.new(1, 0, 1, -42),
        Position = UDim2.new(0, 0, 0, 42),
        BackgroundTransparency = 1,
        Parent = MainContainer
    })
    
    -- Sidebar
    local Sidebar = Utils.Create("Frame", {
        Name = "Sidebar",
        Size = UDim2.new(0, 150, 1, 0),
        BackgroundColor3 = Library.CurrentTheme.Sidebar,
        Parent = ContentContainer
    })
    
    local SidebarSearch = Utils.Create("Frame", {
        Size = UDim2.new(1, -16, 0, 32),
        Position = UDim2.new(0, 8, 0, 8),
        BackgroundColor3 = Library.CurrentTheme.Input,
        Parent = Sidebar
    })
    Utils.AddCorner(SidebarSearch, 6)
    Utils.AddStroke(SidebarSearch, Library.CurrentTheme.Border)
    
    local SearchIcon = Utils.Create("TextLabel", {
        Size = UDim2.new(0, 28, 1, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        Text = "🔍",
        TextColor3 = Library.CurrentTheme.TextMuted,
        TextSize = 12,
        Parent = SidebarSearch
    })
    
    local SearchBox = Utils.Create("TextBox", {
        Size = UDim2.new(1, -35, 1, 0),
        Position = UDim2.new(0, 28, 0, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        PlaceholderText = "Search...",
        PlaceholderColor3 = Library.CurrentTheme.TextMuted,
        Text = "",
        TextColor3 = Library.CurrentTheme.Text,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        ClearTextOnFocus = false,
        Parent = SidebarSearch
    })
    
    -- Tab Container
    local TabContainer = Utils.Create("ScrollingFrame", {
        Name = "TabContainer",
        Size = UDim2.new(1, -8, 1, -50),
        Position = UDim2.new(0, 4, 0, 46),
        BackgroundTransparency = 1,
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = Library.CurrentTheme.ScrollBar,
        BorderSizePixel = 0,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        Parent = Sidebar
    })
    
    local TabLayout = Utils.Create("UIListLayout", {
        Padding = UDim.new(0, 4),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = TabContainer
    })
    
    TabLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        TabContainer.CanvasSize = UDim2.new(0, 0, 0, TabLayout.AbsoluteContentSize.Y + 10)
    end)
    
    -- Content Area
    local ContentArea = Utils.Create("Frame", {
        Name = "ContentArea",
        Size = UDim2.new(1, -154, 1, -4),
        Position = UDim2.new(0, 152, 0, 2),
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        Parent = ContentContainer
    })
    
    -- UI State Functions
    local function ToggleUI(state)
        Library.Open = state ~= nil and state or not Library.Open
        
        if Library.Open then
            MainContainer.Visible = true
            MainContainer.Size = UDim2.new(0, 0, 0, 0)
            Utils.QuickTween(MainContainer, 0.3, {Size = size})
            if IsMobile then MobileToggle.Visible = false end
        else
            local closeTween = Utils.QuickTween(MainContainer, 0.3, {Size = UDim2.new(0, 0, 0, 0)})
            task.delay(0.3, function()
                MainContainer.Visible = false
            end)
            if IsMobile then MobileToggle.Visible = true end
        end
        
        Utils.PlaySound(6518811702, 0.2)
    end
    
    local minimizedSize = UDim2.new(0, 250, 0, 42)
    local normalSize = size
    
    local function MinimizeUI()
        Library.Minimized = not Library.Minimized
        
        if Library.Minimized then
            Utils.QuickTween(MainContainer, 0.3, {Size = minimizedSize})
            ContentContainer.Visible = false
            MinimizeBtn.Text = "+"
        else
            Utils.QuickTween(MainContainer, 0.3, {Size = normalSize})
            ContentContainer.Visible = true
            MinimizeBtn.Text = "−"
        end
    end
    
    -- Button Connections
    CloseBtn.MouseButton1Click:Connect(function()
        Utils.Ripple(CloseBtn, Color3.new(1, 1, 1))
        ToggleUI(false)
    end)
    
    MinimizeBtn.MouseButton1Click:Connect(function()
        Utils.Ripple(MinimizeBtn, Library.CurrentTheme.Accent)
        MinimizeUI()
    end)
    
    MobileToggle.MouseButton1Click:Connect(function()
        Utils.Ripple(MobileToggle, Library.CurrentTheme.Accent)
        ToggleUI(true)
    end)
    
    -- Keyboard Toggle
    table.insert(Library.Connections, UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        
        if input.KeyCode == Library.Keybind then
            ToggleUI()
        end
        
        -- Keybind callbacks
        for key, callback in pairs(CurrentKeybinds) do
            if input.KeyCode == key then
                pcall(callback)
            end
        end
    end))
    
    -- Tab System
    local TabButtons = {}
    local TabPages = {}
    local TabData = {}
    local CurrentTab = nil
    
    local function SwitchTab(tabName)
        if CurrentTab == tabName then return end
        
        for name, btn in pairs(TabButtons) do
            if name == tabName then
                Utils.QuickTween(btn, 0.2, {BackgroundColor3 = Library.CurrentTheme.Accent})
                Utils.QuickTween(btn:FindFirstChild("Label"), 0.2, {TextColor3 = Color3.new(1, 1, 1)})
                TabPages[name].Visible = true
            else
                Utils.QuickTween(btn, 0.2, {BackgroundColor3 = Library.CurrentTheme.Sidebar})
                Utils.QuickTween(btn:FindFirstChild("Label"), 0.2, {TextColor3 = Library.CurrentTheme.TextDark})
                TabPages[name].Visible = false
            end
        end
        
        CurrentTab = tabName
        Utils.PlaySound(6518811702, 0.15)
    end
    
    -- Search functionality
    SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
        local query = SearchBox.Text:lower()
        
        for name, btn in pairs(TabButtons) do
            if query == "" then
                btn.Visible = true
            else
                local match = name:lower():find(query, 1, true)
                btn.Visible = match ~= nil
            end
        end
    end)
    
    local Window = {}
    
    function Window:AddTab(config)
        config = config or {}
        local name = config.Name or config.Title or "Tab"
        local icon = config.Icon or ""
        local order = config.Order or #TabButtons + 1
        
        local TabButton = Utils.Create("TextButton", {
            Name = name,
            Size = UDim2.new(1, -8, 0, 34),
            BackgroundColor3 = #TabButtons == 0 and Library.CurrentTheme.Accent or Library.CurrentTheme.Sidebar,
            Text = "",
            AutoButtonColor = false,
            LayoutOrder = order,
            Parent = TabContainer
        })
        Utils.AddCorner(TabButton, 6)
        
        local TabIcon = Utils.Create("TextLabel", {
            Size = UDim2.new(0, 28, 1, 0),
            BackgroundTransparency = 1,
            Font = Enum.Font.Gotham,
            Text = icon,
            TextColor3 = #TabButtons == 0 and Color3.new(1, 1, 1) or Library.CurrentTheme.TextDark,
            TextSize = 14,
            Parent = TabButton
        })
        
        local TabLabel = Utils.Create("TextLabel", {
            Name = "Label",
            Size = UDim2.new(1, -35, 1, 0),
            Position = UDim2.new(0, icon ~= "" and 28 or 10, 0, 0),
            BackgroundTransparency = 1,
            Font = Enum.Font.GothamMedium,
            Text = name,
            TextColor3 = #TabButtons == 0 and Color3.new(1, 1, 1) or Library.CurrentTheme.TextDark,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
            Parent = TabButton
        })
        
        local TabPage = Utils.Create("ScrollingFrame", {
            Name = name,
            Size = UDim2.new(1, -8, 1, -8),
            Position = UDim2.new(0, 4, 0, 4),
            BackgroundTransparency = 1,
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = Library.CurrentTheme.ScrollBar,
            BorderSizePixel = 0,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            Visible = #TabButtons == 0,
            Parent = ContentArea
        })
        
        local PageLayout = Utils.Create("UIListLayout", {
            Padding = UDim.new(0, 8),
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = TabPage
        })
        
        Utils.AddPadding(TabPage, 4)
        
        PageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            TabPage.CanvasSize = UDim2.new(0, 0, 0, PageLayout.AbsoluteContentSize.Y + 16)
        end)
        
        TabButtons[name] = TabButton
        TabPages[name] = TabPage
        TabData[name] = {functions = {}}
        
        if #TabButtons == 1 then
            CurrentTab = name
        end
        
        TabButton.MouseButton1Click:Connect(function()
            Utils.Ripple(TabButton, Color3.new(1, 1, 1))
            SwitchTab(name)
        end)
        
        TabButton.MouseEnter:Connect(function()
            if CurrentTab ~= name then
                Utils.QuickTween(TabButton, 0.15, {BackgroundColor3 = Library.CurrentTheme.Hover})
            end
        end)
        
        TabButton.MouseLeave:Connect(function()
            if CurrentTab ~= name then
                Utils.QuickTween(TabButton, 0.15, {BackgroundColor3 = Library.CurrentTheme.Sidebar})
            end
        end)
        
        local Tab = {}
        
        function Tab:AddSection(config)
            config = type(config) == "string" and {Name = config} or config
            local sectionName = config.Name or "Section"
            
            local Section = Utils.Create("Frame", {
                Name = sectionName,
                Size = UDim2.new(1, 0, 0, 40),
                BackgroundColor3 = Library.CurrentTheme.Section,
                ClipsDescendants = true,
                Parent = TabPage
            })
            Utils.AddCorner(Section, 8)
            Utils.AddStroke(Section, Library.CurrentTheme.Border)
            
            local SectionHeader = Utils.Create("Frame", {
                Size = UDim2.new(1, 0, 0, 32),
                BackgroundTransparency = 1,
                Parent = Section
            })
            
            local SectionIcon = Utils.Create("Frame", {
                Size = UDim2.new(0, 4, 0, 16),
                Position = UDim2.new(0, 12, 0.5, -8),
                BackgroundColor3 = Library.CurrentTheme.Accent,
                Parent = SectionHeader
            })
            Utils.AddCorner(SectionIcon, 2)
            
            local SectionTitle = Utils.Create("TextLabel", {
                Size = UDim2.new(1, -30, 1, 0),
                Position = UDim2.new(0, 24, 0, 0),
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamBold,
                Text = sectionName:upper(),
                TextColor3 = Library.CurrentTheme.Text,
                TextSize = 11,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = SectionHeader
            })
            
            local SectionContent = Utils.Create("Frame", {
                Name = "Content",
                Size = UDim2.new(1, -16, 0, 0),
                Position = UDim2.new(0, 8, 0, 36),
                BackgroundTransparency = 1,
                Parent = Section
            })
            
            local ContentLayout = Utils.Create("UIListLayout", {
                Padding = UDim.new(0, 6),
                SortOrder = Enum.SortOrder.LayoutOrder,
                Parent = SectionContent
            })
            
            ContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                SectionContent.Size = UDim2.new(1, -16, 0, ContentLayout.AbsoluteContentSize.Y)
                Section.Size = UDim2.new(1, 0, 0, ContentLayout.AbsoluteContentSize.Y + 44)
            end)
            
            local SectionObj = {}
            
            -- =============== LABEL ===============
            function SectionObj:AddLabel(config)
                config = type(config) == "string" and {Text = config} or config
                local text = config.Text or "Label"
                
                local Label = Utils.Create("TextLabel", {
                    Size = UDim2.new(1, 0, 0, 20),
                    BackgroundTransparency = 1,
                    Font = Enum.Font.Gotham,
                    Text = text,
                    TextColor3 = Library.CurrentTheme.TextDark,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = SectionContent
                })
                
                local LabelObj = {}
                function LabelObj:Set(newText)
                    Label.Text = newText
                end
                function LabelObj:Destroy()
                    Label:Destroy()
                end
                return LabelObj
            end
            
            -- =============== PARAGRAPH ===============
            function SectionObj:AddParagraph(config)
                config = type(config) == "string" and {Title = config} or config
                local title = config.Title or "Title"
                local content = config.Content or ""
                
                local ParaFrame = Utils.Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 0),
                    BackgroundTransparency = 1,
                    Parent = SectionContent
                })
                
                local ParaTitle = Utils.Create("TextLabel", {
                    Size = UDim2.new(1, 0, 0, 18),
                    BackgroundTransparency = 1,
                    Font = Enum.Font.GothamBold,
                    Text = title,
                    TextColor3 = Library.CurrentTheme.Text,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = ParaFrame
                })
                
                local ParaContent = Utils.Create("TextLabel", {
                    Size = UDim2.new(1, 0, 0, 0),
                    Position = UDim2.new(0, 0, 0, 20),
                    BackgroundTransparency = 1,
                    Font = Enum.Font.Gotham,
                    Text = content,
                    TextColor3 = Library.CurrentTheme.TextDark,
                    TextSize = 12,
                    TextWrapped = true,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextYAlignment = Enum.TextYAlignment.Top,
                    Parent = ParaFrame
                })
                
                local bounds = Utils.GetTextSize(content, 12, Enum.Font.Gotham, Vector2.new(SectionContent.AbsoluteSize.X - 20, math.huge))
                ParaContent.Size = UDim2.new(1, 0, 0, bounds.Y)
                ParaFrame.Size = UDim2.new(1, 0, 0, bounds.Y + 24)
                
                local ParaObj = {}
                function ParaObj:Set(newTitle, newContent)
                    ParaTitle.Text = newTitle or ParaTitle.Text
                    ParaContent.Text = newContent or ParaContent.Text
                    local newBounds = Utils.GetTextSize(ParaContent.Text, 12, Enum.Font.Gotham, Vector2.new(SectionContent.AbsoluteSize.X - 20, math.huge))
                    ParaContent.Size = UDim2.new(1, 0, 0, newBounds.Y)
                    ParaFrame.Size = UDim2.new(1, 0, 0, newBounds.Y + 24)
                end
                return ParaObj
            end
            
            -- =============== DIVIDER ===============
            function SectionObj:AddDivider()
                local Divider = Utils.Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 1),
                    BackgroundColor3 = Library.CurrentTheme.Divider,
                    BorderSizePixel = 0,
                    Parent = SectionContent
                })
                return Divider
            end
            
            -- =============== BUTTON ===============
            function SectionObj:AddButton(config)
                config = type(config) == "string" and {Name = config} or config
                local text = config.Name or config.Text or "Button"
                local callback = config.Callback or function() end
                local icon = config.Icon or ""
                local confirm = config.Confirm or false
                
                local Button = Utils.Create("TextButton", {
                    Size = UDim2.new(1, 0, 0, 32),
                    BackgroundColor3 = Library.CurrentTheme.Background,
                    Text = "",
                    AutoButtonColor = false,
                    Parent = SectionContent
                })
                Utils.AddCorner(Button, 6)
                Utils.AddStroke(Button, Library.CurrentTheme.Border)
                
                local ButtonIcon = Utils.Create("TextLabel", {
                    Size = UDim2.new(0, 28, 1, 0),
                    BackgroundTransparency = 1,
                    Font = Enum.Font.Gotham,
                    Text = icon,
                    TextColor3 = Library.CurrentTheme.TextDark,
                    TextSize = 14,
                    Visible = icon ~= "",
                    Parent = Button
                })
                
                local ButtonText = Utils.Create("TextLabel", {
                    Size = UDim2.new(1, icon ~= "" and -35 or -10, 1, 0),
                    Position = UDim2.new(0, icon ~= "" and 28 or 8, 0, 0),
                    BackgroundTransparency = 1,
                    Font = Enum.Font.GothamMedium,
                    Text = text,
                    TextColor3 = Library.CurrentTheme.Text,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = Button
                })
                
                local ButtonArrow = Utils.Create("TextLabel", {
                    Size = UDim2.new(0, 20, 1, 0),
                    Position = UDim2.new(1, -25, 0, 0),
                    BackgroundTransparency = 1,
                    Font = Enum.Font.GothamBold,
                    Text = "→",
                    TextColor3 = Library.CurrentTheme.TextMuted,
                    TextSize = 12,
                    Parent = Button
                })
                
                Button.MouseEnter:Connect(function()
                    Utils.QuickTween(Button, 0.15, {BackgroundColor3 = Library.CurrentTheme.Hover})
                    Utils.QuickTween(ButtonArrow, 0.15, {TextColor3 = Library.CurrentTheme.Accent})
                end)
                
                Button.MouseLeave:Connect(function()
                    Utils.QuickTween(Button, 0.15, {BackgroundColor3 = Library.CurrentTheme.Background})
                    Utils.QuickTween(ButtonArrow, 0.15, {TextColor3 = Library.CurrentTheme.TextMuted})
                end)
                
                local confirmState = false
                Button.MouseButton1Click:Connect(function()
                    Utils.Ripple(Button, Library.CurrentTheme.Accent)
                    Utils.PlaySound(6518811702, 0.2)
                    
                    if confirm and not confirmState then
                        confirmState = true
                        ButtonText.Text = "Click again to confirm"
                        ButtonText.TextColor3 = Library.CurrentTheme.Warning
                        task.delay(2, function()
                            if confirmState then
                                confirmState = false
                                ButtonText.Text = text
                                ButtonText.TextColor3 = Library.CurrentTheme.Text
                            end
                        end)
                        return
                    end
                    
                    confirmState = false
                    ButtonText.Text = text
                    ButtonText.TextColor3 = Library.CurrentTheme.Text
                    
                    pcall(callback)
                end)
                
                local ButtonObj = {}
                function ButtonObj:SetText(newText)
                    text = newText
                    ButtonText.Text = newText
                end
                function ButtonObj:SetCallback(newCallback)
                    callback = newCallback
                end
                return ButtonObj
            end
            
            -- =============== TOGGLE ===============
            function SectionObj:AddToggle(config)
                config = type(config) == "string" and {Name = config} or config
                local text = config.Name or config.Text or "Toggle"
                local default = config.Default or false
                local flag = config.Flag
                local callback = config.Callback or function() end
                
                local toggled = default
                
                local ToggleFrame = Utils.Create("TextButton", {
                    Size = UDim2.new(1, 0, 0, 32),
                    BackgroundTransparency = 1,
                    Text = "",
                    Parent = SectionContent
                })
                
                local ToggleLabel = Utils.Create("TextLabel", {
                    Size = UDim2.new(1, -50, 1, 0),
                    BackgroundTransparency = 1,
                    Font = Enum.Font.Gotham,
                    Text = text,
                    TextColor3 = Library.CurrentTheme.Text,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = ToggleFrame
                })
                
                local ToggleBackground = Utils.Create("Frame", {
                    Size = UDim2.new(0, 42, 0, 22),
                    Position = UDim2.new(1, -44, 0.5, -11),
                    BackgroundColor3 = Library.CurrentTheme.Tertiary,
                    Parent = ToggleFrame
                })
                Utils.AddCorner(ToggleBackground, 11)
                Utils.AddStroke(ToggleBackground, Library.CurrentTheme.Border)
                
                local ToggleCircle = Utils.Create("Frame", {
                    Size = UDim2.new(0, 16, 0, 16),
                    Position = UDim2.new(0, 3, 0.5, -8),
                    BackgroundColor3 = Library.CurrentTheme.TextDark,
                    Parent = ToggleBackground
                })
                Utils.AddCorner(ToggleCircle, 8)
                
                local function UpdateToggle(state, skipCallback)
                    toggled = state
                    if flag then Library.Flags[flag] = toggled end
                    
                    if toggled then
                        Utils.QuickTween(ToggleBackground, 0.2, {BackgroundColor3 = Library.CurrentTheme.Accent})
                        Utils.QuickTween(ToggleCircle, 0.2, {
                            Position = UDim2.new(1, -19, 0.5, -8),
                            BackgroundColor3 = Color3.new(1, 1, 1)
                        })
                    else
                        Utils.QuickTween(ToggleBackground, 0.2, {BackgroundColor3 = Library.CurrentTheme.Tertiary})
                        Utils.QuickTween(ToggleCircle, 0.2, {
                            Position = UDim2.new(0, 3, 0.5, -8),
                            BackgroundColor3 = Library.CurrentTheme.TextDark
                        })
                    end
                    
                    if not skipCallback then
                        pcall(callback, toggled)
                    end
                end
                
                ToggleFrame.MouseButton1Click:Connect(function()
                    UpdateToggle(not toggled)
                    Utils.PlaySound(6518811702, 0.15)
                end)
                
                if flag then
                    Library.Flags[flag] = toggled
                    Library.ToggleCallbacks[flag] = function()
                        UpdateToggle(Library.Flags[flag], true)
                    end
                end
                
                if default then UpdateToggle(true, true) end
                
                local ToggleObj = {}
                function ToggleObj:Set(state)
                    UpdateToggle(state)
                end
                function ToggleObj:Get()
                    return toggled
                end
                return ToggleObj
            end
            
            -- =============== SLIDER ===============
            function SectionObj:AddSlider(config)
                config = type(config) == "string" and {Name = config} or config
                local text = config.Name or config.Text or "Slider"
                local min = config.Min or 0
                local max = config.Max or 100
                local default = config.Default or min
                local increment = config.Increment or 1
                local suffix = config.Suffix or ""
                local flag = config.Flag
                local callback = config.Callback or function() end
                
                local currentValue = default
                
                local SliderFrame = Utils.Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 44),
                    BackgroundTransparency = 1,
                    Parent = SectionContent
                })
                
                local SliderLabel = Utils.Create("TextLabel", {
                    Size = UDim2.new(0.6, 0, 0, 18),
                    BackgroundTransparency = 1,
                    Font = Enum.Font.Gotham,
                    Text = text,
                    TextColor3 = Library.CurrentTheme.Text,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = SliderFrame
                })
                
                local SliderValue = Utils.Create("TextBox", {
                    Size = UDim2.new(0.4, 0, 0, 18),
                    Position = UDim2.new(0.6, 0, 0, 0),
                    BackgroundTransparency = 1,
                    Font = Enum.Font.GothamBold,
                    Text = tostring(currentValue) .. suffix,
                    TextColor3 = Library.CurrentTheme.Accent,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Right,
                    Parent = SliderFrame
                })
                
                local SliderBackground = Utils.Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 14),
                    Position = UDim2.new(0, 0, 0, 24),
                    BackgroundColor3 = Library.CurrentTheme.Background,
                    Parent = SliderFrame
                })
                Utils.AddCorner(SliderBackground, 7)
                Utils.AddStroke(SliderBackground, Library.CurrentTheme.Border)
                
                local SliderFill = Utils.Create("Frame", {
                    Size = UDim2.new((default - min) / (max - min), 0, 1, 0),
                    BackgroundColor3 = Library.CurrentTheme.Accent,
                    Parent = SliderBackground
                })
                Utils.AddCorner(SliderFill, 7)
                
                local SliderHandle = Utils.Create("Frame", {
                    Size = UDim2.new(0, 18, 0, 18),
                    Position = UDim2.new((default - min) / (max - min), -9, 0.5, -9),
                    BackgroundColor3 = Color3.new(1, 1, 1),
                    ZIndex = 2,
                    Parent = SliderBackground
                })
                Utils.AddCorner(SliderHandle, 9)
                Utils.AddStroke(SliderHandle, Library.CurrentTheme.Accent, 2)
                
                local function SetValue(val)
                    val = math.clamp(val, min, max)
                    val = math.floor(val / increment + 0.5) * increment
                    currentValue = val
                    
                    local ratio = (val - min) / (max - min)
                    Utils.QuickTween(SliderFill, 0.1, {Size = UDim2.new(ratio, 0, 1, 0)})
                    Utils.QuickTween(SliderHandle, 0.1, {Position = UDim2.new(ratio, -9, 0.5, -9)})
                    
                    SliderValue.Text = tostring(val) .. suffix
                    
                    if flag then Library.Flags[flag] = val end
                    pcall(callback, val)
                end
                
                local dragging = false
                
                local function UpdateSlider(input)
                    local barWidth = SliderBackground.AbsoluteSize.X
                    local pos = math.clamp(input.Position.X - SliderBackground.AbsolutePosition.X, 0, barWidth)
                    local ratio = pos / barWidth
                    local val = min + ratio * (max - min)
                    SetValue(val)
                end
                
                SliderBackground.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or
                       input.UserInputType == Enum.UserInputType.Touch then
                        dragging = true
                        UpdateSlider(input)
                    end
                end)
                
                table.insert(Library.Connections, UserInputService.InputChanged:Connect(function(input)
                    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or
                                     input.UserInputType == Enum.UserInputType.Touch) then
                        UpdateSlider(input)
                    end
                end))
                
                table.insert(Library.Connections, UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or
                       input.UserInputType == Enum.UserInputType.Touch then
                        dragging = false
                    end
                end))
                
                SliderValue.FocusLost:Connect(function()
                    local num = tonumber(SliderValue.Text:gsub(suffix, ""))
                    if num then
                        SetValue(num)
                    else
                        SliderValue.Text = tostring(currentValue) .. suffix
                    end
                end)
                
                if flag then
                    Library.Flags[flag] = currentValue
                    Library.ToggleCallbacks[flag] = function()
                        SetValue(Library.Flags[flag])
                    end
                end
                
                local SliderObj = {}
                function SliderObj:Set(val)
                    SetValue(val)
                end
                function SliderObj:Get()
                    return currentValue
                end
                return SliderObj
            end
            
            -- =============== DROPDOWN ===============
            function SectionObj:AddDropdown(config)
                config = type(config) == "string" and {Name = config} or config
                local text = config.Name or config.Text or "Dropdown"
                local options = config.Options or {"Option 1", "Option 2"}
                local default = config.Default or options[1]
                local multi = config.Multi or false
                local flag = config.Flag
                local callback = config.Callback or function() end
                
                local selected = multi and {} or default
                local isOpen = false
                
                if multi and type(default) == "table" then
                    for _, opt in pairs(default) do
                        selected[opt] = true
                    end
                end
                
                local DropdownFrame = Utils.Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 52),
                    BackgroundTransparency = 1,
                    ClipsDescendants = false,
                    ZIndex = 10,
                    Parent = SectionContent
                })
                
                local DropdownLabel = Utils.Create("TextLabel", {
                    Size = UDim2.new(1, 0, 0, 18),
                    BackgroundTransparency = 1,
                    Font = Enum.Font.Gotham,
                    Text = text,
                    TextColor3 = Library.CurrentTheme.Text,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = DropdownFrame
                })
                
                local DropdownButton = Utils.Create("TextButton", {
                    Size = UDim2.new(1, 0, 0, 32),
                    Position = UDim2.new(0, 0, 0, 20),
                    BackgroundColor3 = Library.CurrentTheme.Background,
                    Text = "",
                    AutoButtonColor = false,
                    Parent = DropdownFrame
                })
                Utils.AddCorner(DropdownButton, 6)
                Utils.AddStroke(DropdownButton, Library.CurrentTheme.Border)
                
                local function GetDisplayText()
                    if multi then
                        local items = {}
                        for opt, val in pairs(selected) do
                            if val then table.insert(items, opt) end
                        end
                        if #items == 0 then return "None selected" end
                        if #items > 2 then return #items .. " selected" end
                        return table.concat(items, ", ")
                    end
                    return selected or "Select..."
                end
                
                local DropdownText = Utils.Create("TextLabel", {
                    Size = UDim2.new(1, -35, 1, 0),
                    Position = UDim2.new(0, 10, 0, 0),
                    BackgroundTransparency = 1,
                    Font = Enum.Font.Gotham,
                    Text = GetDisplayText(),
                    TextColor3 = Library.CurrentTheme.Accent,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextTruncate = Enum.TextTruncate.AtEnd,
                    Parent = DropdownButton
                })
                
                local DropdownArrow = Utils.Create("TextLabel", {
                    Size = UDim2.new(0, 20, 1, 0),
                    Position = UDim2.new(1, -25, 0, 0),
                    BackgroundTransparency = 1,
                    Font = Enum.Font.GothamBold,
                    Text = "▼",
                    TextColor3 = Library.CurrentTheme.TextMuted,
                    TextSize = 10,
                    Parent = DropdownButton
                })
                
                local DropdownList = Utils.Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 0),
                    Position = UDim2.new(0, 0, 0, 54),
                    BackgroundColor3 = Library.CurrentTheme.Section,
                    ClipsDescendants = true,
                    Visible = false,
                    ZIndex = 100,
                    Parent = DropdownFrame
                })
                Utils.AddCorner(DropdownList, 6)
                Utils.AddStroke(DropdownList, Library.CurrentTheme.Border)
                Utils.AddShadow(DropdownList)
                
                local ListContainer = Utils.Create("ScrollingFrame", {
                    Size = UDim2.new(1, -8, 1, -8),
                    Position = UDim2.new(0, 4, 0, 4),
                    BackgroundTransparency = 1,
                    ScrollBarThickness = 2,
                    ScrollBarImageColor3 = Library.CurrentTheme.ScrollBar,
                    BorderSizePixel = 0,
                    ZIndex = 101,
                    Parent = DropdownList
                })
                
                local ListLayout = Utils.Create("UIListLayout", {
                    Padding = UDim.new(0, 2),
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Parent = ListContainer
                })
                
                local function RefreshOptions()
                    for _, child in pairs(ListContainer:GetChildren()) do
                        if child:IsA("TextButton") then child:Destroy() end
                    end
                    
                    for i, option in ipairs(options) do
                        local OptionButton = Utils.Create("TextButton", {
                            Size = UDim2.new(1, 0, 0, 28),
                            BackgroundColor3 = Library.CurrentTheme.Background,
                            BackgroundTransparency = 1,
                            Text = "",
                            AutoButtonColor = false,
                            ZIndex = 102,
                            LayoutOrder = i,
                            Parent = ListContainer
                        })
                        Utils.AddCorner(OptionButton, 4)
                        
                        local OptionCheck = Utils.Create("Frame", {
                            Size = UDim2.new(0, 4, 0, 16),
                            Position = UDim2.new(0, 6, 0.5, -8),
                            BackgroundColor3 = Library.CurrentTheme.Accent,
                            Visible = multi and selected[option] or (not multi and selected == option),
                            ZIndex = 103,
                            Parent = OptionButton
                        })
                        Utils.AddCorner(OptionCheck, 2)
                        
                        local OptionText = Utils.Create("TextLabel", {
                            Size = UDim2.new(1, -20, 1, 0),
                            Position = UDim2.new(0, 16, 0, 0),
                            BackgroundTransparency = 1,
                            Font = Enum.Font.Gotham,
                            Text = option,
                            TextColor3 = (multi and selected[option]) or (not multi and selected == option) 
                                          and Library.CurrentTheme.Text or Library.CurrentTheme.TextDark,
                            TextSize = 12,
                            TextXAlignment = Enum.TextXAlignment.Left,
                            ZIndex = 103,
                            Parent = OptionButton
                        })
                        
                        OptionButton.MouseEnter:Connect(function()
                            Utils.QuickTween(OptionButton, 0.1, {BackgroundTransparency = 0})
                        end)
                        
                        OptionButton.MouseLeave:Connect(function()
                            Utils.QuickTween(OptionButton, 0.1, {BackgroundTransparency = 1})
                        end)
                        
                        OptionButton.MouseButton1Click:Connect(function()
                            Utils.PlaySound(6518811702, 0.15)
                            
                            if multi then
                                selected[option] = not selected[option]
                                OptionCheck.Visible = selected[option]
                                OptionText.TextColor3 = selected[option] and Library.CurrentTheme.Text or Library.CurrentTheme.TextDark
                            else
                                selected = option
                                
                                -- Обновляем все опции
                                for _, child in pairs(ListContainer:GetChildren()) do
                                    if child:IsA("TextButton") then
                                        local check = child:FindFirstChild("Frame")
                                        local txt = child:FindFirstChild("TextLabel")
                                        if check and txt then
                                            check.Visible = txt.Text == option
                                            txt.TextColor3 = txt.Text == option and Library.CurrentTheme.Text or Library.CurrentTheme.TextDark
                                        end
                                    end
                                end
                                
                                -- Закрываем dropdown
                                isOpen = false
                                Utils.QuickTween(DropdownList, 0.2, {Size = UDim2.new(1, 0, 0, 0)})
                                task.delay(0.2, function()
                                    DropdownList.Visible = false
                                end)
                                Utils.QuickTween(DropdownArrow, 0.2, {Rotation = 0})
                                DropdownFrame.Size = UDim2.new(1, 0, 0, 52)
                            end
                            
                            DropdownText.Text = GetDisplayText()
                            
                            if flag then Library.Flags[flag] = selected end
                            pcall(callback, selected)
                        end)
                    end
                    
                    ListContainer.CanvasSize = UDim2.new(0, 0, 0, #options * 30)
                end
                
                RefreshOptions()
                
                DropdownButton.MouseButton1Click:Connect(function()
                    isOpen = not isOpen
                    Utils.PlaySound(6518811702, 0.15)
                    
                    if isOpen then
                        DropdownList.Visible = true
                        local height = math.min(#options * 30 + 8, 150)
                        Utils.QuickTween(DropdownList, 0.2, {Size = UDim2.new(1, 0, 0, height)})
                        Utils.QuickTween(DropdownArrow, 0.2, {Rotation = 180})
                        DropdownFrame.Size = UDim2.new(1, 0, 0, 56 + height)
                    else
                        Utils.QuickTween(DropdownList, 0.2, {Size = UDim2.new(1, 0, 0, 0)})
                        task.delay(0.2, function()
                            DropdownList.Visible = false
                        end)
                        Utils.QuickTween(DropdownArrow, 0.2, {Rotation = 0})
                        DropdownFrame.Size = UDim2.new(1, 0, 0, 52)
                    end
                end)
                
                DropdownButton.MouseEnter:Connect(function()
                    Utils.QuickTween(DropdownButton, 0.15, {BackgroundColor3 = Library.CurrentTheme.Hover})
                end)
                
                DropdownButton.MouseLeave:Connect(function()
                    Utils.QuickTween(DropdownButton, 0.15, {BackgroundColor3 = Library.CurrentTheme.Background})
                end)
                
                if flag then
                    Library.Flags[flag] = selected
                    Library.ToggleCallbacks[flag] = function()
                        -- Обновить отображение на основе флага
                    end
                end
                
                local DropdownObj = {}
                function DropdownObj:Set(val)
                    if multi then
                        selected = {}
                        if type(val) == "table" then
                            for _, opt in pairs(val) do
                                selected[opt] = true
                            end
                        end
                    else
                        selected = val
                    end
                    DropdownText.Text = GetDisplayText()
                    RefreshOptions()
                    if flag then Library.Flags[flag] = selected end
                    pcall(callback, selected)
                end
                function DropdownObj:Get()
                    return selected
                end
                function DropdownObj:Refresh(newOptions, newDefault)
                    options = newOptions
                    if newDefault then
                        selected = multi and {} or newDefault
                    end
                    RefreshOptions()
                    DropdownText.Text = GetDisplayText()
                end
                return DropdownObj
            end
            
            -- =============== INPUT (TEXTBOX) ===============
            function SectionObj:AddInput(config)
                config = type(config) == "string" and {Name = config} or config
                local text = config.Name or config.Text or "Input"
                local placeholder = config.Placeholder or "Enter text..."
                local default = config.Default or ""
                local numeric = config.Numeric or false
                local finished = config.Finished or false
                local flag = config.Flag
                local callback = config.Callback or function() end
                
                local InputFrame = Utils.Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 52),
                    BackgroundTransparency = 1,
                    Parent = SectionContent
                })
                
                local InputLabel = Utils.Create("TextLabel", {
                    Size = UDim2.new(1, 0, 0, 18),
                    BackgroundTransparency = 1,
                    Font = Enum.Font.Gotham,
                    Text = text,
                    TextColor3 = Library.CurrentTheme.Text,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = InputFrame
                })
                
                local InputBackground = Utils.Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 32),
                    Position = UDim2.new(0, 0, 0, 20),
                    BackgroundColor3 = Library.CurrentTheme.Input,
                    Parent = InputFrame
                })
                Utils.AddCorner(InputBackground, 6)
                Utils.AddStroke(InputBackground, Library.CurrentTheme.Border)
                
                local InputBox = Utils.Create("TextBox", {
                    Size = UDim2.new(1, -16, 1, 0),
                    Position = UDim2.new(0, 8, 0, 0),
                    BackgroundTransparency = 1,
                    Font = Enum.Font.Gotham,
                    PlaceholderText = placeholder,
                    PlaceholderColor3 = Library.CurrentTheme.TextMuted,
                    Text = default,
                    TextColor3 = Library.CurrentTheme.Text,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ClearTextOnFocus = false,
                    Parent = InputBackground
                })
                
                InputBox.Focused:Connect(function()
                    Utils.QuickTween(InputBackground:FindFirstChildOfClass("UIStroke"), 0.15, {Color = Library.CurrentTheme.Accent})
                end)
                
                InputBox.FocusLost:Connect(function(enterPressed)
                    Utils.QuickTween(InputBackground:FindFirstChildOfClass("UIStroke"), 0.15, {Color = Library.CurrentTheme.Border})
                    
                    if numeric then
                        local num = tonumber(InputBox.Text)
                        if not num then
                            InputBox.Text = default
                            return
                        end
                    end
                    
                    if finished then
                        if flag then Library.Flags[flag] = InputBox.Text end
                        pcall(callback, InputBox.Text)
                    end
                end)
                
                if not finished then
                    InputBox:GetPropertyChangedSignal("Text"):Connect(function()
                        if flag then Library.Flags[flag] = InputBox.Text end
                        pcall(callback, InputBox.Text)
                    end)
                end
                
                if flag then
                    Library.Flags[flag] = default
                    Library.ToggleCallbacks[flag] = function()
                        InputBox.Text = Library.Flags[flag]
                    end
                end
                
                local InputObj = {}
                function InputObj:Set(val)
                    InputBox.Text = tostring(val)
                    if flag then Library.Flags[flag] = val end
                end
                function InputObj:Get()
                    return InputBox.Text
                end
                return InputObj
            end
            
            -- =============== KEYBIND ===============
            function SectionObj:AddKeybind(config)
                config = type(config) == "string" and {Name = config} or config
                local text = config.Name or config.Text or "Keybind"
                local default = config.Default or Enum.KeyCode.None
                local mode = config.Mode or "Toggle"
                local flag = config.Flag
                local callback = config.Callback or function() end
                local changedCallback = config.ChangedCallback or function() end
                
                local currentKey = default
                local listening = false
                local held = false
                
                local KeybindFrame = Utils.Create("TextButton", {
                    Size = UDim2.new(1, 0, 0, 32),
                    BackgroundColor3 = Library.CurrentTheme.Background,
                    Text = "",
                    AutoButtonColor = false,
                    Parent = SectionContent
                })
                Utils.AddCorner(KeybindFrame, 6)
                Utils.AddStroke(KeybindFrame, Library.CurrentTheme.Border)
                
                local KeybindLabel = Utils.Create("TextLabel", {
                    Size = UDim2.new(1, -80, 1, 0),
                    Position = UDim2.new(0, 10, 0, 0),
                    BackgroundTransparency = 1,
                    Font = Enum.Font.Gotham,
                    Text = text,
                    TextColor3 = Library.CurrentTheme.Text,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = KeybindFrame
                })
                
                local KeybindValue = Utils.Create("TextLabel", {
                    Size = UDim2.new(0, 60, 0, 22),
                    Position = UDim2.new(1, -70, 0.5, -11),
                    BackgroundColor3 = Library.CurrentTheme.Tertiary,
                    Font = Enum.Font.GothamBold,
                    Text = currentKey.Name == "None" and "..." or currentKey.Name,
                    TextColor3 = Library.CurrentTheme.Accent,
                    TextSize = 11,
                    Parent = KeybindFrame
                })
                Utils.AddCorner(KeybindValue, 4)
                
                local function SetKey(key)
                    if CurrentKeybinds[currentKey] then
                        CurrentKeybinds[currentKey] = nil
                    end
                    
                    currentKey = key
                    CurrentKeybinds[key] = callback
                    
                    KeybindValue.Text = key.Name == "None" and "..." or key.Name
                    
                    if flag then Library.Flags[flag] = key end
                    pcall(changedCallback, key)
                end
                
                KeybindFrame.MouseButton1Click:Connect(function()
                    if listening then return end
                    listening = true
                    KeybindValue.Text = "..."
                    Utils.QuickTween(KeybindValue, 0.15, {BackgroundColor3 = Library.CurrentTheme.Accent})
                    Utils.QuickTween(KeybindValue, 0.15, {TextColor3 = Color3.new(1, 1, 1)})
                    
                    local conn
                    conn = UserInputService.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.Keyboard then
                            SetKey(input.KeyCode)
                            listening = false
                            Utils.QuickTween(KeybindValue, 0.15, {BackgroundColor3 = Library.CurrentTheme.Tertiary})
                            Utils.QuickTween(KeybindValue, 0.15, {TextColor3 = Library.CurrentTheme.Accent})
                            conn:Disconnect()
                        elseif input.UserInputType == Enum.UserInputType.MouseButton1 or
                               input.UserInputType == Enum.UserInputType.MouseButton2 then
                            listening = false
                            KeybindValue.Text = currentKey.Name == "None" and "..." or currentKey.Name
                            Utils.QuickTween(KeybindValue, 0.15, {BackgroundColor3 = Library.CurrentTheme.Tertiary})
                            Utils.QuickTween(KeybindValue, 0.15, {TextColor3 = Library.CurrentTheme.Accent})
                            conn:Disconnect()
                        end
                    end)
                end)
                
                KeybindFrame.MouseEnter:Connect(function()
                    Utils.QuickTween(KeybindFrame, 0.15, {BackgroundColor3 = Library.CurrentTheme.Hover})
                end)
                
                KeybindFrame.MouseLeave:Connect(function()
                    Utils.QuickTween(KeybindFrame, 0.15, {BackgroundColor3 = Library.CurrentTheme.Background})
                end)
                
                if flag then
                    Library.Flags[flag] = currentKey
                end
                SetKey(currentKey)
                
                local KeybindObj = {}
                function KeybindObj:Set(key)
                    SetKey(key)
                end
                function KeybindObj:Get()
                    return currentKey
                end
                return KeybindObj
            end
            
            -- =============== COLOR PICKER ===============
            function SectionObj:AddColorPicker(config)
                config = type(config) == "string" and {Name = config} or config
                local text = config.Name or config.Text or "Color Picker"
                local default = config.Default or Color3.fromRGB(255, 255, 255)
                local flag = config.Flag
                local callback = config.Callback or function() end
                
                local h, s, v = default:ToHSV()
                local currentColor = default
                local pickerOpen = false
                
                local ColorFrame = Utils.Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 32),
                    BackgroundTransparency = 1,
                    ClipsDescendants = false,
                    Parent = SectionContent
                })
                
                local ColorLabel = Utils.Create("TextLabel", {
                    Size = UDim2.new(1, -50, 1, 0),
                    BackgroundTransparency = 1,
                    Font = Enum.Font.Gotham,
                    Text = text,
                    TextColor3 = Library.CurrentTheme.Text,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = ColorFrame
                })
                
                local ColorButton = Utils.Create("TextButton", {
                    Size = UDim2.new(0, 36, 0, 22),
                    Position = UDim2.new(1, -38, 0.5, -11),
                    BackgroundColor3 = currentColor,
                    Text = "",
                    Parent = ColorFrame
                })
                Utils.AddCorner(ColorButton, 4)
                Utils.AddStroke(ColorButton, Library.CurrentTheme.Border)
                
                local PickerContainer = Utils.Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 0),
                    Position = UDim2.new(0, 0, 1, 4),
                    BackgroundColor3 = Library.CurrentTheme.Section,
                    ClipsDescendants = true,
                    Visible = false,
                    ZIndex = 50,
                    Parent = ColorFrame
                })
                Utils.AddCorner(PickerContainer, 8)
                Utils.AddStroke(PickerContainer, Library.CurrentTheme.Border)
                Utils.AddShadow(PickerContainer)
                
                -- Saturation/Value picker
                local SVPicker = Utils.Create("ImageButton", {
                    Size = UDim2.new(0, 140, 0, 100),
                    Position = UDim2.new(0, 10, 0, 10),
                    BackgroundColor3 = Color3.fromHSV(h, 1, 1),
                    Image = "rbxassetid://4155801252",
                    AutoButtonColor = false,
                    ZIndex = 51,
                    Parent = PickerContainer
                })
                Utils.AddCorner(SVPicker, 4)
                
                local SVCursor = Utils.Create("Frame", {
                    Size = UDim2.new(0, 10, 0, 10),
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    Position = UDim2.new(s, 0, 1 - v, 0),
                    BackgroundColor3 = Color3.new(1, 1, 1),
                    ZIndex = 52,
                    Parent = SVPicker
                })
                Utils.AddCorner(SVCursor, 5)
                Utils.AddStroke(SVCursor, Color3.new(0, 0, 0), 2)
                
                -- Hue slider
                local HuePicker = Utils.Create("ImageButton", {
                    Size = UDim2.new(0, 18, 0, 100),
                    Position = UDim2.new(0, 160, 0, 10),
                    BackgroundColor3 = Color3.new(1, 1, 1),
                    AutoButtonColor = false,
                    ZIndex = 51,
                    Parent = PickerContainer
                })
                Utils.AddCorner(HuePicker, 4)
                
                local HueGradient = Utils.Create("UIGradient", {
                    Rotation = 90,
                    Color = ColorSequence.new{
                        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
                        ColorSequenceKeypoint.new(0.167, Color3.fromRGB(255, 255, 0)),
                        ColorSequenceKeypoint.new(0.333, Color3.fromRGB(0, 255, 0)),
                        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
                        ColorSequenceKeypoint.new(0.667, Color3.fromRGB(0, 0, 255)),
                        ColorSequenceKeypoint.new(0.833, Color3.fromRGB(255, 0, 255)),
                        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
                    },
                    Parent = HuePicker
                })
                
                local HueCursor = Utils.Create("Frame", {
                    Size = UDim2.new(1, 4, 0, 4),
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    Position = UDim2.new(0.5, 0, h, 0),
                    BackgroundColor3 = Color3.new(1, 1, 1),
                    ZIndex = 52,
                    Parent = HuePicker
                })
                Utils.AddCorner(HueCursor, 2)
                Utils.AddStroke(HueCursor, Color3.new(0, 0, 0), 1)
                
                -- RGB Input
                local RGBContainer = Utils.Create("Frame", {
                    Size = UDim2.new(1, -20, 0, 24),
                    Position = UDim2.new(0, 10, 0, 116),
                    BackgroundTransparency = 1,
                    ZIndex = 51,
                    Parent = PickerContainer
                })
                
                local function CreateRGBInput(labelText, value, xPos)
                    local Input = Utils.Create("Frame", {
                        Size = UDim2.new(0.3, 0, 1, 0),
                        Position = UDim2.new(xPos, 0, 0, 0),
                        BackgroundColor3 = Library.CurrentTheme.Background,
                        ZIndex = 52,
                        Parent = RGBContainer
                    })
                    Utils.AddCorner(Input, 4)
                    
                    local Label = Utils.Create("TextLabel", {
                        Size = UDim2.new(0, 14, 1, 0),
                        BackgroundTransparency = 1,
                        Font = Enum.Font.GothamBold,
                        Text = labelText,
                        TextColor3 = Library.CurrentTheme.TextMuted,
                        TextSize = 10,
                        ZIndex = 53,
                        Parent = Input
                    })
                    
                    local Box = Utils.Create("TextBox", {
                        Size = UDim2.new(1, -18, 1, 0),
                        Position = UDim2.new(0, 16, 0, 0),
                        BackgroundTransparency = 1,
                        Font = Enum.Font.Gotham,
                        Text = tostring(value),
                        TextColor3 = Library.CurrentTheme.Text,
                        TextSize = 11,
                        ZIndex = 53,
                        Parent = Input
                    })
                    
                    return Box
                end
                
                local RInput = CreateRGBInput("R", math.floor(currentColor.R * 255), 0)
                local GInput = CreateRGBInput("G", math.floor(currentColor.G * 255), 0.35)
                local BInput = CreateRGBInput("B", math.floor(currentColor.B * 255), 0.7)
                
                local function UpdateColor()
                    currentColor = Color3.fromHSV(h, s, v)
                    ColorButton.BackgroundColor3 = currentColor
                    SVPicker.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
                    
                    RInput.Text = tostring(math.floor(currentColor.R * 255))
                    GInput.Text = tostring(math.floor(currentColor.G * 255))
                    BInput.Text = tostring(math.floor(currentColor.B * 255))
                    
                    if flag then Library.Flags[flag] = currentColor end
                    pcall(callback, currentColor)
                end
                
                local draggingSV, draggingHue = false, false
                
                SVPicker.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or
                       input.UserInputType == Enum.UserInputType.Touch then
                        draggingSV = true
                    end
                end)
                
                HuePicker.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or
                       input.UserInputType == Enum.UserInputType.Touch then
                        draggingHue = true
                    end
                end)
                
                table.insert(Library.Connections, UserInputService.InputChanged:Connect(function(input)
                    if draggingSV and (input.UserInputType == Enum.UserInputType.MouseMovement or
                                       input.UserInputType == Enum.UserInputType.Touch) then
                        local relX = math.clamp((input.Position.X - SVPicker.AbsolutePosition.X) / SVPicker.AbsoluteSize.X, 0, 1)
                        local relY = math.clamp((input.Position.Y - SVPicker.AbsolutePosition.Y) / SVPicker.AbsoluteSize.Y, 0, 1)
                        s = relX
                        v = 1 - relY
                        SVCursor.Position = UDim2.new(s, 0, 1 - v, 0)
                        UpdateColor()
                    elseif draggingHue and (input.UserInputType == Enum.UserInputType.MouseMovement or
                                            input.UserInputType == Enum.UserInputType.Touch) then
                        local relY = math.clamp((input.Position.Y - HuePicker.AbsolutePosition.Y) / HuePicker.AbsoluteSize.Y, 0, 1)
                        h = relY
                        HueCursor.Position = UDim2.new(0.5, 0, h, 0)
                        UpdateColor()
                    end
                end))
                
                table.insert(Library.Connections, UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or
                       input.UserInputType == Enum.UserInputType.Touch then
                        draggingSV = false
                        draggingHue = false
                    end
                end))
                
                -- RGB input handlers
                for _, input in pairs({RInput, GInput, BInput}) do
                    input.FocusLost:Connect(function()
                        local r = math.clamp(tonumber(RInput.Text) or 0, 0, 255) / 255
                        local g = math.clamp(tonumber(GInput.Text) or 0, 0, 255) / 255
                        local b = math.clamp(tonumber(BInput.Text) or 0, 0, 255) / 255
                        currentColor = Color3.new(r, g, b)
                        h, s, v = currentColor:ToHSV()
                        SVCursor.Position = UDim2.new(s, 0, 1 - v, 0)
                        HueCursor.Position = UDim2.new(0.5, 0, h, 0)
                        UpdateColor()
                    end)
                end
                
                ColorButton.MouseButton1Click:Connect(function()
                    pickerOpen = not pickerOpen
                    Utils.PlaySound(6518811702, 0.15)
                    
                    if pickerOpen then
                        PickerContainer.Visible = true
                        Utils.QuickTween(PickerContainer, 0.2, {Size = UDim2.new(1, 0, 0, 150)})
                        ColorFrame.Size = UDim2.new(1, 0, 0, 186)
                    else
                        Utils.QuickTween(PickerContainer, 0.2, {Size = UDim2.new(1, 0, 0, 0)})
                        task.delay(0.2, function()
                            PickerContainer.Visible = false
                        end)
                        ColorFrame.Size = UDim2.new(1, 0, 0, 32)
                    end
                end)
                
                if flag then
                    Library.Flags[flag] = currentColor
                    Library.ToggleCallbacks[flag] = function()
                        currentColor = Library.Flags[flag]
                        h, s, v = currentColor:ToHSV()
                        SVCursor.Position = UDim2.new(s, 0, 1 - v, 0)
                        HueCursor.Position = UDim2.new(0.5, 0, h, 0)
                        UpdateColor()
                    end
                end
                
                local ColorObj = {}
                function ColorObj:Set(color)
                    currentColor = color
                    h, s, v = color:ToHSV()
                    SVCursor.Position = UDim2.new(s, 0, 1 - v, 0)
                    HueCursor.Position = UDim2.new(0.5, 0, h, 0)
                    UpdateColor()
                end
                function ColorObj:Get()
                    return currentColor
                end
                return ColorObj
            end
            
            -- =============== PROGRESS BAR ===============
            function SectionObj:AddProgress(config)
                config = type(config) == "string" and {Name = config} or config
                local text = config.Name or config.Text or "Progress"
                local default = config.Default or 0
                local max = config.Max or 100
                local suffix = config.Suffix or "%"
                local color = config.Color or Library.CurrentTheme.Accent
                
                local current = default
                
                local ProgressFrame = Utils.Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 42),
                    BackgroundTransparency = 1,
                    Parent = SectionContent
                })
                
                local ProgressLabel = Utils.Create("TextLabel", {
                    Size = UDim2.new(0.7, 0, 0, 18),
                    BackgroundTransparency = 1,
                    Font = Enum.Font.Gotham,
                    Text = text,
                    TextColor3 = Library.CurrentTheme.Text,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = ProgressFrame
                })
                
                local ProgressValue = Utils.Create("TextLabel", {
                    Size = UDim2.new(0.3, 0, 0, 18),
                    Position = UDim2.new(0.7, 0, 0, 0),
                    BackgroundTransparency = 1,
                    Font = Enum.Font.GothamBold,
                    Text = tostring(current) .. suffix,
                    TextColor3 = color,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Right,
                    Parent = ProgressFrame
                })
                
                local ProgressBackground = Utils.Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 12),
                    Position = UDim2.new(0, 0, 0, 24),
                    BackgroundColor3 = Library.CurrentTheme.Background,
                    Parent = ProgressFrame
                })
                Utils.AddCorner(ProgressBackground, 6)
                Utils.AddStroke(ProgressBackground, Library.CurrentTheme.Border)
                
                local ProgressFill = Utils.Create("Frame", {
                    Size = UDim2.new(current / max, 0, 1, 0),
                    BackgroundColor3 = color,
                    Parent = ProgressBackground
                })
                Utils.AddCorner(ProgressFill, 6)
                
                local ProgressObj = {}
                function ProgressObj:Set(value)
                    current = math.clamp(value, 0, max)
                    local ratio = current / max
                    Utils.QuickTween(ProgressFill, 0.3, {Size = UDim2.new(ratio, 0, 1, 0)})
                    ProgressValue.Text = tostring(math.floor(current)) .. suffix
                end
                function ProgressObj:Increment(amount)
                    ProgressObj:Set(current + (amount or 1))
                end
                function ProgressObj:Get()
                    return current
                end
                function ProgressObj:SetColor(newColor)
                    color = newColor
                    ProgressFill.BackgroundColor3 = color
                    ProgressValue.TextColor3 = color
                end
                return ProgressObj
            end

            return SectionObj
        end
        
        return Tab
    end
    
    -- Settings Tab
    local SettingsTab = Window:AddTab({Name = "Settings", Icon = "⚙", Order = 999})
    local UISection = SettingsTab:AddSection({Name = "Interface"})
    
    UISection:AddDropdown({
        Name = "Theme",
        Options = {"Dark", "Light", "Midnight", "Ocean"},
        Default = Library.Theme,
        Callback = function(selected)
            Library:SetTheme(selected)
            Library:Notify({Title = "Theme", Text = "Theme changed to " .. selected, Type = "Success", Duration = 2})
        end
    })
    
    UISection:AddToggle({
        Name = "Animations",
        Default = Library.AnimationsEnabled,
        Callback = function(value)
            Library.AnimationsEnabled = value
        end
    })
    
    UISection:AddToggle({
        Name = "Sounds",
        Default = Library.SoundsEnabled,
        Callback = function(value)
            Library.SoundsEnabled = value
        end
    })
    
    UISection:AddButton({
        Name = "Reset Position",
        Callback = function()
            MainContainer.Position = UDim2.new(0.5, 0, 0.5, 0)
            Library:Notify({Title = "UI", Text = "Position reset to center", Type = "Info", Duration = 2})
        end
    })
    
    UISection:AddButton({
        Name = "Unload UI",
        Confirm = true,
        Callback = function()
            Library.Open = false
            for _, conn in pairs(Library.Connections) do
                conn:Disconnect()
            end
            ScreenGui:Destroy()
            NotificationContainer:Destroy()
        end
    })
    
    local ConfigSection = SettingsTab:AddSection({Name = "Configurations"})
    
    local configList = Library:GetConfigs()
    local ConfigDropdown = ConfigSection:AddDropdown({
        Name = "Config",
        Options = #configList > 0 and configList or {"No configs"},
        Default = configList[1] or "No configs"
    })
    
    local ConfigName = ConfigSection:AddInput({
        Name = "Config Name",
        Placeholder = "Enter config name...",
        Default = ""
    })
    
    ConfigSection:AddButton({
        Name = "Save Config",
        Callback = function()
            local name = ConfigName:Get()
            if name ~= "" then
                Library:SaveConfig(name)
                ConfigDropdown:Refresh(Library:GetConfigs())
            end
        end
    })
    
    ConfigSection:AddButton({
        Name = "Load Config",
        Callback = function()
            local selected = ConfigDropdown:Get()
            if selected and selected ~= "No configs" then
                Library:LoadConfig(selected)
            end
        end
    })
    
    table.insert(Library.Windows, Window)
    
    return Window
end

function Library:Destroy()
    for _, conn in pairs(Library.Connections) do
        pcall(function() conn:Disconnect() end)
    end
    for _, window in pairs(Library.Windows) do
        pcall(function() window:Destroy() end)
    end
    if NotificationContainer then
        NotificationContainer:Destroy()
    end
end

return Library
