local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local IsMobile = UserInputService.TouchEnabled

-- Тема
local Theme = {
    Background = Color3.fromRGB(15, 15, 18),
    TopBar = Color3.fromRGB(20, 20, 25),
    Sidebar = Color3.fromRGB(18, 18, 22),
    Section = Color3.fromRGB(22, 22, 28),
    Element = Color3.fromRGB(28, 28, 35),
    ElementHover = Color3.fromRGB(35, 35, 45),
    Text = Color3.fromRGB(255, 255, 255),
    TextDark = Color3.fromRGB(150, 150, 160),
    Accent = Color3.fromRGB(90, 120, 255),
    AccentHover = Color3.fromRGB(110, 140, 255),
    Border = Color3.fromRGB(40, 40, 50),
    Toggle = Color3.fromRGB(45, 45, 55),
    ToggleOn = Color3.fromRGB(90, 120, 255),
    SliderBg = Color3.fromRGB(35, 35, 45),
    Success = Color3.fromRGB(80, 200, 120),
    Warning = Color3.fromRGB(255, 180, 50),
    Error = Color3.fromRGB(255, 80, 80)
}

local Library = {
    Flags = {},
    Open = true,
    Keybind = Enum.KeyCode.RightControl,
    ToggleCallbacks = {},
    Connections = {}
}

-- Утилиты
local function Create(class, props)
    local inst = Instance.new(class)
    for k, v in pairs(props or {}) do
        if k ~= "Parent" then
            inst[k] = v
        end
    end
    if props and props.Parent then
        inst.Parent = props.Parent
    end
    return inst
end

local function Tween(obj, time, props)
    local tween = TweenService:Create(obj, TweenInfo.new(time, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), props)
    tween:Play()
    return tween
end

local function AddCorner(parent, radius)
    return Create("UICorner", {CornerRadius = UDim.new(0, radius or 6), Parent = parent})
end

local function AddStroke(parent, color, thickness)
    return Create("UIStroke", {Color = color or Theme.Border, Thickness = thickness or 1, Parent = parent})
end

-- Dragging
local function MakeDraggable(handle, frame)
    local dragging, dragInput, dragStart, startPos
    
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input == dragInput then
            local delta = input.Position - dragStart
            Tween(frame, 0.1, {Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)})
        end
    end)
end

-- Notifications
local NotifGui = Create("ScreenGui", {
    Name = "RavionNotifications",
    ZIndexBehavior = Enum.ZIndexBehavior.Global,
    ResetOnSpawn = false
})
pcall(function() NotifGui.Parent = CoreGui end)
if not NotifGui.Parent then NotifGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

local NotifHolder = Create("Frame", {
    Size = UDim2.new(0, 300, 1, -40),
    Position = UDim2.new(1, -310, 0, 20),
    BackgroundTransparency = 1,
    Parent = NotifGui
})

Create("UIListLayout", {
    Padding = UDim.new(0, 8),
    VerticalAlignment = Enum.VerticalAlignment.Bottom,
    SortOrder = Enum.SortOrder.LayoutOrder,
    Parent = NotifHolder
})

function Library:Notify(title, text, duration, nType)
    duration = duration or 3
    nType = nType or "Info"
    
    local colors = {
        Info = Theme.Accent,
        Success = Theme.Success,
        Warning = Theme.Warning,
        Error = Theme.Error
    }
    
    local Notif = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 70),
        BackgroundColor3 = Theme.Section,
        Parent = NotifHolder
    })
    AddCorner(Notif, 8)
    AddStroke(Notif, Theme.Border)
    
    local Accent = Create("Frame", {
        Size = UDim2.new(0, 4, 1, -10),
        Position = UDim2.new(0, 5, 0, 5),
        BackgroundColor3 = colors[nType] or Theme.Accent,
        Parent = Notif
    })
    AddCorner(Accent, 2)
    
    Create("TextLabel", {
        Size = UDim2.new(1, -50, 0, 22),
        Position = UDim2.new(0, 18, 0, 8),
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = Theme.Text,
        TextSize = 14,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = Notif
    })
    
    Create("TextLabel", {
        Size = UDim2.new(1, -25, 0, 32),
        Position = UDim2.new(0, 18, 0, 30),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = Theme.TextDark,
        TextSize = 12,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        TextWrapped = true,
        Parent = Notif
    })
    
    local Progress = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 3),
        Position = UDim2.new(0, 0, 1, -3),
        BackgroundColor3 = colors[nType] or Theme.Accent,
        Parent = Notif
    })
    
    Notif.Position = UDim2.new(1, 20, 0, 0)
    Tween(Notif, 0.3, {Position = UDim2.new(0, 0, 0, 0)})
    Tween(Progress, duration, {Size = UDim2.new(0, 0, 0, 3)})
    
    task.delay(duration, function()
        Tween(Notif, 0.3, {Position = UDim2.new(1, 20, 0, 0)})
        task.wait(0.3)
        Notif:Destroy()
    end)
end

-- Main Window
function Library:CreateWindow(hubName, toggleKey)
    Library.Keybind = toggleKey or Enum.KeyCode.RightControl
    
    -- Cleanup old
    local old = LocalPlayer.PlayerGui:FindFirstChild("RavionUI")
    if old then old:Destroy() end
    local oldCore = CoreGui:FindFirstChild("RavionUI")
    if oldCore then oldCore:Destroy() end
    
    local ScreenGui = Create("ScreenGui", {
        Name = "RavionUI",
        ZIndexBehavior = Enum.ZIndexBehavior.Global,
        ResetOnSpawn = false
    })
    pcall(function() ScreenGui.Parent = CoreGui end)
    if not ScreenGui.Parent then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end
    
    -- Mobile Button
    local MobileBtn = Create("TextButton", {
        Size = UDim2.new(0, 50, 0, 50),
        Position = UDim2.new(0, 20, 0.5, -25),
        BackgroundColor3 = Theme.Section,
        Text = "≡",
        TextColor3 = Theme.Accent,
        TextSize = 24,
        Font = Enum.Font.GothamBold,
        Visible = IsMobile and false,
        Parent = ScreenGui
    })
    AddCorner(MobileBtn, 25)
    AddStroke(MobileBtn, Theme.Accent, 2)
    MakeDraggable(MobileBtn, MobileBtn)
    
    -- Main Frame
    local Main = Create("Frame", {
        Size = UDim2.new(0, 600, 0, 400),
        Position = UDim2.new(0.5, -300, 0.5, -200),
        BackgroundColor3 = Theme.Background,
        Parent = ScreenGui
    })
    AddCorner(Main, 10)
    AddStroke(Main, Theme.Border)
    
    -- TopBar
    local TopBar = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundColor3 = Theme.TopBar,
        Parent = Main
    })
    AddCorner(TopBar, 10)
    
    Create("Frame", {
        Size = UDim2.new(1, 0, 0, 10),
        Position = UDim2.new(0, 0, 1, -10),
        BackgroundColor3 = Theme.TopBar,
        BorderSizePixel = 0,
        Parent = TopBar
    })
    
    MakeDraggable(TopBar, Main)
    
    -- Logo
    local Logo = Create("Frame", {
        Size = UDim2.new(0, 28, 0, 28),
        Position = UDim2.new(0, 8, 0.5, -14),
        BackgroundColor3 = Theme.Accent,
        Parent = TopBar
    })
    AddCorner(Logo, 6)
    
    Create("TextLabel", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = string.sub(hubName, 1, 1):upper(),
        TextColor3 = Color3.new(1, 1, 1),
        TextSize = 14,
        Font = Enum.Font.GothamBlack,
        Parent = Logo
    })
    
    -- Title
    Create("TextLabel", {
        Size = UDim2.new(0, 200, 1, 0),
        Position = UDim2.new(0, 45, 0, 0),
        BackgroundTransparency = 1,
        Text = hubName,
        TextColor3 = Theme.Text,
        TextSize = 16,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = TopBar
    })
    
    -- Close/Minimize
    local CloseBtn = Create("TextButton", {
        Size = UDim2.new(0, 30, 0, 30),
        Position = UDim2.new(1, -38, 0.5, -15),
        BackgroundColor3 = Theme.Error,
        Text = "×",
        TextColor3 = Color3.new(1, 1, 1),
        TextSize = 18,
        Font = Enum.Font.GothamBold,
        Parent = TopBar
    })
    AddCorner(CloseBtn, 6)
    
    local MinBtn = Create("TextButton", {
        Size = UDim2.new(0, 30, 0, 30),
        Position = UDim2.new(1, -75, 0.5, -15),
        BackgroundColor3 = Theme.Element,
        Text = "−",
        TextColor3 = Theme.TextDark,
        TextSize = 18,
        Font = Enum.Font.GothamBold,
        Parent = TopBar
    })
    AddCorner(MinBtn, 6)
    
    -- Sidebar
    local Sidebar = Create("Frame", {
        Size = UDim2.new(0, 140, 1, -45),
        Position = UDim2.new(0, 5, 0, 45),
        BackgroundColor3 = Theme.Sidebar,
        Parent = Main
    })
    AddCorner(Sidebar, 8)
    
    local TabHolder = Create("ScrollingFrame", {
        Size = UDim2.new(1, -10, 1, -10),
        Position = UDim2.new(0, 5, 0, 5),
        BackgroundTransparency = 1,
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = Theme.Accent,
        BorderSizePixel = 0,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        Parent = Sidebar
    })
    
    local TabLayout = Create("UIListLayout", {
        Padding = UDim.new(0, 4),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = TabHolder
    })
    
    TabLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        TabHolder.CanvasSize = UDim2.new(0, 0, 0, TabLayout.AbsoluteContentSize.Y + 10)
    end)
    
    -- Content Area
    local ContentArea = Create("Frame", {
        Size = UDim2.new(1, -155, 1, -50),
        Position = UDim2.new(0, 150, 0, 45),
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        Parent = Main
    })
    
    -- Toggle Functions
    local function ToggleUI(state)
        Library.Open = state ~= nil and state or not Library.Open
        Main.Visible = Library.Open
        if IsMobile then MobileBtn.Visible = not Library.Open end
    end
    
    CloseBtn.MouseButton1Click:Connect(function() ToggleUI(false) end)
    MobileBtn.MouseButton1Click:Connect(function() ToggleUI(true) end)
    
    MinBtn.MouseButton1Click:Connect(function()
        if Main.Size.Y.Offset > 50 then
            Tween(Main, 0.2, {Size = UDim2.new(0, 600, 0, 40)})
            MinBtn.Text = "+"
        else
            Tween(Main, 0.2, {Size = UDim2.new(0, 600, 0, 400)})
            MinBtn.Text = "−"
        end
    end)
    
    -- Keyboard
    UserInputService.InputBegan:Connect(function(input, gp)
        if gp then return end
        if input.KeyCode == Library.Keybind then
            ToggleUI()
        end
    end)
    
    if IsMobile then MobileBtn.Visible = true end
    
    -- Tab System
    local Tabs = {}
    local CurrentTab = nil
    local Window = {}
    
    function Window:AddTab(name, icon)
        icon = icon or ""
        
        local TabBtn = Create("TextButton", {
            Size = UDim2.new(1, 0, 0, 35),
            BackgroundColor3 = Theme.Sidebar,
            BackgroundTransparency = 1,
            Text = "",
            Parent = TabHolder
        })
        AddCorner(TabBtn, 6)
        
        if icon ~= "" then
            Create("TextLabel", {
                Size = UDim2.new(0, 25, 1, 0),
                Position = UDim2.new(0, 5, 0, 0),
                BackgroundTransparency = 1,
                Text = icon,
                TextColor3 = Theme.TextDark,
                TextSize = 14,
                Font = Enum.Font.Gotham,
                Parent = TabBtn
            })
        end
        
        local TabLabel = Create("TextLabel", {
            Size = UDim2.new(1, icon ~= "" and -35 or -15, 1, 0),
            Position = UDim2.new(0, icon ~= "" and 30 or 10, 0, 0),
            BackgroundTransparency = 1,
            Text = name,
            TextColor3 = Theme.TextDark,
            TextSize = 13,
            Font = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = TabBtn
        })
        
        local TabPage = Create("ScrollingFrame", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = Theme.Accent,
            BorderSizePixel = 0,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            Visible = false,
            Parent = ContentArea
        })
        
        local PageLayout = Create("UIListLayout", {
            Padding = UDim.new(0, 8),
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = TabPage
        })
        
        Create("UIPadding", {
            PaddingTop = UDim.new(0, 5),
            PaddingLeft = UDim.new(0, 5),
            PaddingRight = UDim.new(0, 5),
            Parent = TabPage
        })
        
        PageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            TabPage.CanvasSize = UDim2.new(0, 0, 0, PageLayout.AbsoluteContentSize.Y + 20)
        end)
        
        Tabs[name] = {Button = TabBtn, Page = TabPage, Label = TabLabel}
        
        if CurrentTab == nil then
            CurrentTab = name
            TabPage.Visible = true
            TabBtn.BackgroundTransparency = 0
            TabBtn.BackgroundColor3 = Theme.Accent
            TabLabel.TextColor3 = Color3.new(1, 1, 1)
        end
        
        TabBtn.MouseButton1Click:Connect(function()
            if CurrentTab == name then return end
            
            -- Deselect old
            if CurrentTab and Tabs[CurrentTab] then
                Tabs[CurrentTab].Page.Visible = false
                Tween(Tabs[CurrentTab].Button, 0.2, {BackgroundTransparency = 1})
                Tween(Tabs[CurrentTab].Label, 0.2, {TextColor3 = Theme.TextDark})
            end
            
            -- Select new
            CurrentTab = name
            TabPage.Visible = true
            Tween(TabBtn, 0.2, {BackgroundTransparency = 0, BackgroundColor3 = Theme.Accent})
            Tween(TabLabel, 0.2, {TextColor3 = Color3.new(1, 1, 1)})
        end)
        
        TabBtn.MouseEnter:Connect(function()
            if CurrentTab ~= name then
                Tween(TabBtn, 0.15, {BackgroundTransparency = 0.5, BackgroundColor3 = Theme.Element})
            end
        end)
        
        TabBtn.MouseLeave:Connect(function()
            if CurrentTab ~= name then
                Tween(TabBtn, 0.15, {BackgroundTransparency = 1})
            end
        end)
        
        local Tab = {}
        
        function Tab:AddSection(sectionName)
            local Section = Create("Frame", {
                Size = UDim2.new(1, -5, 0, 35),
                BackgroundColor3 = Theme.Section,
                Parent = TabPage
            })
            AddCorner(Section, 8)
            AddStroke(Section, Theme.Border)
            
            -- Section Header
            local Header = Create("Frame", {
                Size = UDim2.new(1, 0, 0, 30),
                BackgroundTransparency = 1,
                Parent = Section
            })
            
            Create("Frame", {
                Size = UDim2.new(0, 3, 0, 14),
                Position = UDim2.new(0, 10, 0.5, -7),
                BackgroundColor3 = Theme.Accent,
                Parent = Header
            }):FindFirstChildOfClass("UICorner") or AddCorner(Header:FindFirstChild("Frame"), 2)
            
            Create("TextLabel", {
                Size = UDim2.new(1, -25, 1, 0),
                Position = UDim2.new(0, 20, 0, 0),
                BackgroundTransparency = 1,
                Text = sectionName:upper(),
                TextColor3 = Theme.Text,
                TextSize = 11,
                Font = Enum.Font.GothamBold,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = Header
            })
            
            local Content = Create("Frame", {
                Size = UDim2.new(1, -16, 0, 0),
                Position = UDim2.new(0, 8, 0, 32),
                BackgroundTransparency = 1,
                Parent = Section
            })
            
            local ContentLayout = Create("UIListLayout", {
                Padding = UDim.new(0, 6),
                SortOrder = Enum.SortOrder.LayoutOrder,
                Parent = Content
            })
            
            ContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                Content.Size = UDim2.new(1, -16, 0, ContentLayout.AbsoluteContentSize.Y)
                Section.Size = UDim2.new(1, -5, 0, ContentLayout.AbsoluteContentSize.Y + 42)
            end)
            
            local SectionObj = {}
            
            -- LABEL
            function SectionObj:AddLabel(text)
                local Label = Create("TextLabel", {
                    Size = UDim2.new(1, 0, 0, 20),
                    BackgroundTransparency = 1,
                    Text = text,
                    TextColor3 = Theme.TextDark,
                    TextSize = 12,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = Content
                })
                
                return {
                    Set = function(_, newText) Label.Text = newText end
                }
            end
            
            -- BUTTON
            function SectionObj:AddButton(text, callback)
                callback = callback or function() end
                
                local Btn = Create("TextButton", {
                    Size = UDim2.new(1, 0, 0, 32),
                    BackgroundColor3 = Theme.Element,
                    Text = "",
                    Parent = Content
                })
                AddCorner(Btn, 6)
                
                Create("TextLabel", {
                    Size = UDim2.new(1, -20, 1, 0),
                    Position = UDim2.new(0, 10, 0, 0),
                    BackgroundTransparency = 1,
                    Text = text,
                    TextColor3 = Theme.Text,
                    TextSize = 12,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = Btn
                })
                
                Create("TextLabel", {
                    Size = UDim2.new(0, 20, 1, 0),
                    Position = UDim2.new(1, -25, 0, 0),
                    BackgroundTransparency = 1,
                    Text = "→",
                    TextColor3 = Theme.TextDark,
                    TextSize = 14,
                    Font = Enum.Font.GothamBold,
                    Parent = Btn
                })
                
                Btn.MouseEnter:Connect(function()
                    Tween(Btn, 0.15, {BackgroundColor3 = Theme.ElementHover})
                end)
                
                Btn.MouseLeave:Connect(function()
                    Tween(Btn, 0.15, {BackgroundColor3 = Theme.Element})
                end)
                
                Btn.MouseButton1Click:Connect(function()
                    Tween(Btn, 0.1, {BackgroundColor3 = Theme.Accent})
                    task.wait(0.1)
                    Tween(Btn, 0.1, {BackgroundColor3 = Theme.Element})
                    pcall(callback)
                end)
                
                return {
                    SetText = function(_, newText)
                        Btn:FindFirstChildOfClass("TextLabel").Text = newText
                    end
                }
            end
            
            -- TOGGLE
            function SectionObj:AddToggle(text, default, flag, callback)
                default = default or false
                callback = callback or function() end
                local toggled = default
                
                local Toggle = Create("TextButton", {
                    Size = UDim2.new(1, 0, 0, 32),
                    BackgroundTransparency = 1,
                    Text = "",
                    Parent = Content
                })
                
                Create("TextLabel", {
                    Size = UDim2.new(1, -55, 1, 0),
                    BackgroundTransparency = 1,
                    Text = text,
                    TextColor3 = Theme.Text,
                    TextSize = 12,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = Toggle
                })
                
                local ToggleBg = Create("Frame", {
                    Size = UDim2.new(0, 44, 0, 22),
                    Position = UDim2.new(1, -46, 0.5, -11),
                    BackgroundColor3 = Theme.Toggle,
                    Parent = Toggle
                })
                AddCorner(ToggleBg, 11)
                
                local ToggleCircle = Create("Frame", {
                    Size = UDim2.new(0, 18, 0, 18),
                    Position = UDim2.new(0, 2, 0.5, -9),
                    BackgroundColor3 = Theme.TextDark,
                    Parent = ToggleBg
                })
                AddCorner(ToggleCircle, 9)
                
                local function Update(state)
                    toggled = state
                    if flag then Library.Flags[flag] = toggled end
                    
                    if toggled then
                        Tween(ToggleBg, 0.2, {BackgroundColor3 = Theme.ToggleOn})
                        Tween(ToggleCircle, 0.2, {Position = UDim2.new(1, -20, 0.5, -9), BackgroundColor3 = Color3.new(1, 1, 1)})
                    else
                        Tween(ToggleBg, 0.2, {BackgroundColor3 = Theme.Toggle})
                        Tween(ToggleCircle, 0.2, {Position = UDim2.new(0, 2, 0.5, -9), BackgroundColor3 = Theme.TextDark})
                    end
                    
                    pcall(callback, toggled)
                end
                
                Toggle.MouseButton1Click:Connect(function()
                    Update(not toggled)
                end)
                
                if flag then Library.Flags[flag] = toggled end
                if default then Update(true) end
                
                return {
                    Set = function(_, state) Update(state) end,
                    Get = function() return toggled end
                }
            end
            
            -- SLIDER
            function SectionObj:AddSlider(text, min, max, default, flag, callback)
                min = min or 0
                max = max or 100
                default = default or min
                callback = callback or function() end
                local value = default
                
                local SliderFrame = Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 42),
                    BackgroundTransparency = 1,
                    Parent = Content
                })
                
                Create("TextLabel", {
                    Size = UDim2.new(0.6, 0, 0, 18),
                    BackgroundTransparency = 1,
                    Text = text,
                    TextColor3 = Theme.Text,
                    TextSize = 12,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = SliderFrame
                })
                
                local ValueLabel = Create("TextLabel", {
                    Size = UDim2.new(0.4, 0, 0, 18),
                    Position = UDim2.new(0.6, 0, 0, 0),
                    BackgroundTransparency = 1,
                    Text = tostring(value),
                    TextColor3 = Theme.Accent,
                    TextSize = 12,
                    Font = Enum.Font.GothamBold,
                    TextXAlignment = Enum.TextXAlignment.Right,
                    Parent = SliderFrame
                })
                
                local SliderBg = Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 12),
                    Position = UDim2.new(0, 0, 0, 24),
                    BackgroundColor3 = Theme.SliderBg,
                    Parent = SliderFrame
                })
                AddCorner(SliderBg, 6)
                
                local SliderFill = Create("Frame", {
                    Size = UDim2.new((default - min) / (max - min), 0, 1, 0),
                    BackgroundColor3 = Theme.Accent,
                    Parent = SliderBg
                })
                AddCorner(SliderFill, 6)
                
                local SliderBtn = Create("TextButton", {
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundTransparency = 1,
                    Text = "",
                    Parent = SliderBg
                })
                
                local function SetValue(val)
                    value = math.clamp(math.floor(val + 0.5), min, max)
                    local ratio = (value - min) / (max - min)
                    Tween(SliderFill, 0.1, {Size = UDim2.new(ratio, 0, 1, 0)})
                    ValueLabel.Text = tostring(value)
                    if flag then Library.Flags[flag] = value end
                    pcall(callback, value)
                end
                
                local dragging = false
                
                local function Update(input)
                    local pos = math.clamp((input.Position.X - SliderBg.AbsolutePosition.X) / SliderBg.AbsoluteSize.X, 0, 1)
                    SetValue(min + pos * (max - min))
                end
                
                SliderBtn.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        dragging = true
                        Update(input)
                    end
                end)
                
                UserInputService.InputChanged:Connect(function(input)
                    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                        Update(input)
                    end
                end)
                
                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        dragging = false
                    end
                end)
                
                if flag then Library.Flags[flag] = value end
                
                return {
                    Set = function(_, val) SetValue(val) end,
                    Get = function() return value end
                }
            end
            
            -- TEXTBOX
            function SectionObj:AddTextbox(placeholder, flag, callback)
                callback = callback or function() end
                
                local BoxFrame = Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 32),
                    BackgroundColor3 = Theme.Element,
                    Parent = Content
                })
                AddCorner(BoxFrame, 6)
                
                local Box = Create("TextBox", {
                    Size = UDim2.new(1, -16, 1, 0),
                    Position = UDim2.new(0, 8, 0, 0),
                    BackgroundTransparency = 1,
                    PlaceholderText = placeholder or "Enter text...",
                    PlaceholderColor3 = Theme.TextDark,
                    Text = "",
                    TextColor3 = Theme.Text,
                    TextSize = 12,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ClearTextOnFocus = false,
                    Parent = BoxFrame
                })
                
                Box.FocusLost:Connect(function()
                    if flag then Library.Flags[flag] = Box.Text end
                    pcall(callback, Box.Text)
                end)
                
                return {
                    Set = function(_, text) Box.Text = text end,
                    Get = function() return Box.Text end
                }
            end
            
            -- DROPDOWN
            function SectionObj:AddDropdown(text, options, default, flag, callback)
                options = options or {}
                callback = callback or function() end
                local selected = default or options[1] or ""
                local open = false
                
                local DropFrame = Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 50),
                    BackgroundTransparency = 1,
                    ClipsDescendants = false,
                    ZIndex = 10,
                    Parent = Content
                })
                
                Create("TextLabel", {
                    Size = UDim2.new(1, 0, 0, 18),
                    BackgroundTransparency = 1,
                    Text = text,
                    TextColor3 = Theme.Text,
                    TextSize = 12,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = DropFrame
                })
                
                local DropBtn = Create("TextButton", {
                    Size = UDim2.new(1, 0, 0, 30),
                    Position = UDim2.new(0, 0, 0, 20),
                    BackgroundColor3 = Theme.Element,
                    Text = "",
                    Parent = DropFrame
                })
                AddCorner(DropBtn, 6)
                
                local SelectedLabel = Create("TextLabel", {
                    Size = UDim2.new(1, -30, 1, 0),
                    Position = UDim2.new(0, 10, 0, 0),
                    BackgroundTransparency = 1,
                    Text = selected,
                    TextColor3 = Theme.Accent,
                    TextSize = 12,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = DropBtn
                })
                
                local Arrow = Create("TextLabel", {
                    Size = UDim2.new(0, 20, 1, 0),
                    Position = UDim2.new(1, -25, 0, 0),
                    BackgroundTransparency = 1,
                    Text = "▼",
                    TextColor3 = Theme.TextDark,
                    TextSize = 10,
                    Font = Enum.Font.GothamBold,
                    Parent = DropBtn
                })
                
                local DropList = Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 0),
                    Position = UDim2.new(0, 0, 0, 52),
                    BackgroundColor3 = Theme.Section,
                    ClipsDescendants = true,
                    Visible = false,
                    ZIndex = 50,
                    Parent = DropFrame
                })
                AddCorner(DropList, 6)
                AddStroke(DropList, Theme.Border)
                
                local ListScroll = Create("ScrollingFrame", {
                    Size = UDim2.new(1, -6, 1, -6),
                    Position = UDim2.new(0, 3, 0, 3),
                    BackgroundTransparency = 1,
                    ScrollBarThickness = 2,
                    ScrollBarImageColor3 = Theme.Accent,
                    BorderSizePixel = 0,
                    ZIndex = 51,
                    Parent = DropList
                })
                
                local ListLayout = Create("UIListLayout", {
                    Padding = UDim.new(0, 2),
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Parent = ListScroll
                })
                
                local function RefreshOptions()
                    for _, v in pairs(ListScroll:GetChildren()) do
                        if v:IsA("TextButton") then v:Destroy() end
                    end
                    
                    for _, opt in ipairs(options) do
                        local OptBtn = Create("TextButton", {
                            Size = UDim2.new(1, 0, 0, 26),
                            BackgroundColor3 = Theme.Element,
                            BackgroundTransparency = 1,
                            Text = opt,
                            TextColor3 = opt == selected and Theme.Accent or Theme.TextDark,
                            TextSize = 12,
                            Font = Enum.Font.Gotham,
                            ZIndex = 52,
                            Parent = ListScroll
                        })
                        AddCorner(OptBtn, 4)
                        
                        OptBtn.MouseEnter:Connect(function()
                            Tween(OptBtn, 0.1, {BackgroundTransparency = 0})
                        end)
                        
                        OptBtn.MouseLeave:Connect(function()
                            Tween(OptBtn, 0.1, {BackgroundTransparency = 1})
                        end)
                        
                        OptBtn.MouseButton1Click:Connect(function()
                            selected = opt
                            SelectedLabel.Text = opt
                            if flag then Library.Flags[flag] = selected end
                            pcall(callback, selected)
                            
                            -- Close
                            open = false
                            Tween(DropList, 0.2, {Size = UDim2.new(1, 0, 0, 0)})
                            Tween(Arrow, 0.2, {Rotation = 0})
                            task.delay(0.2, function() DropList.Visible = false end)
                            DropFrame.Size = UDim2.new(1, 0, 0, 50)
                            
                            RefreshOptions()
                        end)
                    end
                    
                    ListScroll.CanvasSize = UDim2.new(0, 0, 0, #options * 28)
                end
                
                RefreshOptions()
                
                DropBtn.MouseButton1Click:Connect(function()
                    open = not open
                    
                    if open then
                        DropList.Visible = true
                        local h = math.min(#options * 28 + 6, 130)
                        Tween(DropList, 0.2, {Size = UDim2.new(1, 0, 0, h)})
                        Tween(Arrow, 0.2, {Rotation = 180})
                        DropFrame.Size = UDim2.new(1, 0, 0, 54 + h)
                    else
                        Tween(DropList, 0.2, {Size = UDim2.new(1, 0, 0, 0)})
                        Tween(Arrow, 0.2, {Rotation = 0})
                        task.delay(0.2, function() DropList.Visible = false end)
                        DropFrame.Size = UDim2.new(1, 0, 0, 50)
                    end
                end)
                
                DropBtn.MouseEnter:Connect(function()
                    Tween(DropBtn, 0.15, {BackgroundColor3 = Theme.ElementHover})
                end)
                
                DropBtn.MouseLeave:Connect(function()
                    Tween(DropBtn, 0.15, {BackgroundColor3 = Theme.Element})
                end)
                
                if flag then Library.Flags[flag] = selected end
                
                return {
                    Set = function(_, val)
                        selected = val
                        SelectedLabel.Text = val
                        if flag then Library.Flags[flag] = selected end
                        RefreshOptions()
                    end,
                    Get = function() return selected end,
                    Refresh = function(_, newOpts)
                        options = newOpts
                        RefreshOptions()
                    end
                }
            end
            
            -- KEYBIND
            function SectionObj:AddKeybind(text, default, flag, callback)
                default = default or Enum.KeyCode.None
                callback = callback or function() end
                local key = default
                local listening = false
                
                local KeyFrame = Create("TextButton", {
                    Size = UDim2.new(1, 0, 0, 32),
                    BackgroundColor3 = Theme.Element,
                    Text = "",
                    Parent = Content
                })
                AddCorner(KeyFrame, 6)
                
                Create("TextLabel", {
                    Size = UDim2.new(1, -70, 1, 0),
                    Position = UDim2.new(0, 10, 0, 0),
                    BackgroundTransparency = 1,
                    Text = text,
                    TextColor3 = Theme.Text,
                    TextSize = 12,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = KeyFrame
                })
                
                local KeyLabel = Create("TextLabel", {
                    Size = UDim2.new(0, 55, 0, 22),
                    Position = UDim2.new(1, -60, 0.5, -11),
                    BackgroundColor3 = Theme.SliderBg,
                    Text = key.Name == "None" and "..." or key.Name,
                    TextColor3 = Theme.Accent,
                    TextSize = 11,
                    Font = Enum.Font.GothamBold,
                    Parent = KeyFrame
                })
                AddCorner(KeyLabel, 4)
                
                KeyFrame.MouseButton1Click:Connect(function()
                    if listening then return end
                    listening = true
                    KeyLabel.Text = "..."
                    Tween(KeyLabel, 0.15, {BackgroundColor3 = Theme.Accent})
                    KeyLabel.TextColor3 = Color3.new(1, 1, 1)
                    
                    local conn
                    conn = UserInputService.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.Keyboard then
                            key = input.KeyCode
                            KeyLabel.Text = key.Name
                            if flag then Library.Flags[flag] = key end
                            listening = false
                            Tween(KeyLabel, 0.15, {BackgroundColor3 = Theme.SliderBg})
                            KeyLabel.TextColor3 = Theme.Accent
                            conn:Disconnect()
                        end
                    end)
                end)
                
                KeyFrame.MouseEnter:Connect(function()
                    Tween(KeyFrame, 0.15, {BackgroundColor3 = Theme.ElementHover})
                end)
                
                KeyFrame.MouseLeave:Connect(function()
                    Tween(KeyFrame, 0.15, {BackgroundColor3 = Theme.Element})
                end)
                
                -- Keybind listener
                UserInputService.InputBegan:Connect(function(input, gp)
                    if gp or listening then return end
                    if input.KeyCode == key then
                        pcall(callback)
                    end
                end)
                
                if flag then Library.Flags[flag] = key end
                
                return {
                    Set = function(_, newKey)
                        key = newKey
                        KeyLabel.Text = key.Name
                        if flag then Library.Flags[flag] = key end
                    end,
                    Get = function() return key end
                }
            end
            
            -- COLOR PICKER
            function SectionObj:AddColorPicker(text, default, flag, callback)
                default = default or Color3.fromRGB(255, 255, 255)
                callback = callback or function() end
                local h, s, v = default:ToHSV()
                local color = default
                local open = false
                
                local ColorFrame = Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 32),
                    BackgroundTransparency = 1,
                    ClipsDescendants = false,
                    Parent = Content
                })
                
                Create("TextLabel", {
                    Size = UDim2.new(1, -45, 1, 0),
                    BackgroundTransparency = 1,
                    Text = text,
                    TextColor3 = Theme.Text,
                    TextSize = 12,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = ColorFrame
                })
                
                local ColorBtn = Create("TextButton", {
                    Size = UDim2.new(0, 35, 0, 22),
                    Position = UDim2.new(1, -37, 0.5, -11),
                    BackgroundColor3 = color,
                    Text = "",
                    Parent = ColorFrame
                })
                AddCorner(ColorBtn, 4)
                AddStroke(ColorBtn, Theme.Border)
                
                local Picker = Create("Frame", {
                    Size = UDim2.new(1, 0, 0, 0),
                    Position = UDim2.new(0, 0, 1, 4),
                    BackgroundColor3 = Theme.Section,
                    ClipsDescendants = true,
                    Visible = false,
                    ZIndex = 30,
                    Parent = ColorFrame
                })
                AddCorner(Picker, 8)
                AddStroke(Picker, Theme.Border)
                
                local SVMap = Create("ImageButton", {
                    Size = UDim2.new(0, 120, 0, 90),
                    Position = UDim2.new(0, 10, 0, 10),
                    BackgroundColor3 = Color3.fromHSV(h, 1, 1),
                    Image = "rbxassetid://4155801252",
                    AutoButtonColor = false,
                    ZIndex = 31,
                    Parent = Picker
                })
                AddCorner(SVMap, 4)
                
                local SVCursor = Create("Frame", {
                    Size = UDim2.new(0, 8, 0, 8),
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    Position = UDim2.new(s, 0, 1 - v, 0),
                    BackgroundColor3 = Color3.new(1, 1, 1),
                    ZIndex = 32,
                    Parent = SVMap
                })
                AddCorner(SVCursor, 4)
                AddStroke(SVCursor, Color3.new(0, 0, 0), 1)
                
                local HueBar = Create("ImageButton", {
                    Size = UDim2.new(0, 18, 0, 90),
                    Position = UDim2.new(0, 140, 0, 10),
                    BackgroundColor3 = Color3.new(1, 1, 1),
                    AutoButtonColor = false,
                    ZIndex = 31,
                    Parent = Picker
                })
                AddCorner(HueBar, 4)
                
                Create("UIGradient", {
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
                    Parent = HueBar
                })
                
                local HueCursor = Create("Frame", {
                    Size = UDim2.new(1, 4, 0, 4),
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    Position = UDim2.new(0.5, 0, h, 0),
                    BackgroundColor3 = Color3.new(1, 1, 1),
                    ZIndex = 32,
                    Parent = HueBar
                })
                AddCorner(HueCursor, 2)
                AddStroke(HueCursor, Color3.new(0, 0, 0), 1)
                
                local function UpdateColor()
                    color = Color3.fromHSV(h, s, v)
                    ColorBtn.BackgroundColor3 = color
                    SVMap.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
                    if flag then Library.Flags[flag] = color end
                    pcall(callback, color)
                end
                
                local draggingSV, draggingHue = false, false
                
                SVMap.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        draggingSV = true
                    end
                end)
                
                HueBar.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        draggingHue = true
                    end
                end)
                
                UserInputService.InputChanged:Connect(function(input)
                    if draggingSV and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                        local rx = math.clamp((input.Position.X - SVMap.AbsolutePosition.X) / SVMap.AbsoluteSize.X, 0, 1)
                        local ry = math.clamp((input.Position.Y - SVMap.AbsolutePosition.Y) / SVMap.AbsoluteSize.Y, 0, 1)
                        s, v = rx, 1 - ry
                        SVCursor.Position = UDim2.new(s, 0, 1 - v, 0)
                        UpdateColor()
                    elseif draggingHue and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                        local ry = math.clamp((input.Position.Y - HueBar.AbsolutePosition.Y) / HueBar.AbsoluteSize.Y, 0, 1)
                        h = ry
                        HueCursor.Position = UDim2.new(0.5, 0, h, 0)
                        UpdateColor()
                    end
                end)
                
                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        draggingSV, draggingHue = false, false
                    end
                end)
                
                ColorBtn.MouseButton1Click:Connect(function()
                    open = not open
                    if open then
                        Picker.Visible = true
                        Tween(Picker, 0.2, {Size = UDim2.new(1, 0, 0, 110)})
                        ColorFrame.Size = UDim2.new(1, 0, 0, 146)
                    else
                        Tween(Picker, 0.2, {Size = UDim2.new(1, 0, 0, 0)})
                        task.delay(0.2, function() Picker.Visible = false end)
                        ColorFrame.Size = UDim2.new(1, 0, 0, 32)
                    end
                end)
                
                if flag then Library.Flags[flag] = color end
                
                return {
                    Set = function(_, col)
                        h, s, v = col:ToHSV()
                        SVCursor.Position = UDim2.new(s, 0, 1 - v, 0)
                        HueCursor.Position = UDim2.new(0.5, 0, h, 0)
                        UpdateColor()
                    end,
                    Get = function() return color end
                }
            end
            
            return SectionObj
        end
        
        return Tab
    end
    
    -- Settings Tab
    local Settings = Window:AddTab("Settings", "⚙")
    local UISection = Settings:AddSection("UI Settings")
    
    UISection:AddButton("Reset Position", function()
        Main.Position = UDim2.new(0.5, -300, 0.5, -200)
        Library:Notify("UI", "Position reset", 2, "Success")
    end)
    
    UISection:AddButton("Destroy UI", function()
        ScreenGui:Destroy()
    end)
    
    UISection:AddKeybind("Toggle Key", Library.Keybind, nil, function()
        ToggleUI()
    end)
    
    return Window
end

return Library
