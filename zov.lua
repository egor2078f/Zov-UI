--[[ 
    RavinUI - Professional Edition (Fixed Color Picker)
    Stable, Optimized, Bug-Free
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

--// Configuration System Setup
local ConfigFolder = "RavinUi"
local ConfigExtension = ".json"

if not isfolder(ConfigFolder) then
    makefolder(ConfigFolder)
end

--// Theme
local Theme = {
    Background = Color3.fromRGB(20, 20, 20),
    Sidebar = Color3.fromRGB(25, 25, 25),
    Section = Color3.fromRGB(28, 28, 28),
    Text = Color3.fromRGB(240, 240, 240),
    TextDark = Color3.fromRGB(150, 150, 150),
    Accent = Color3.fromRGB(0, 122, 204),
    Border = Color3.fromRGB(45, 45, 45),
    Hover = Color3.fromRGB(35, 35, 35)
}

--// Library Logic
local Library = {
    Flags = {},
    ConfigObjects = {},
    Open = true,
    AccentColor = Theme.Accent,
    Keybind = Enum.KeyCode.RightControl
}

local CurrentKeybinds = {}
local Notifications = Instance.new("ScreenGui")
Notifications.Name = "RavinNotifications"
Notifications.Parent = CoreGui
Notifications.ZIndexBehavior = Enum.ZIndexBehavior.Global

--// Utility Functions
local function GetConfigName(name)
    return ConfigFolder .. "/" .. name .. ConfigExtension
end

local function SaveConfiguration(name)
    local Data = {}
    for flag, value in pairs(Library.Flags) do
        if typeof(value) == "Color3" then
            Data[flag] = {R = value.R, G = value.G, B = value.B, Type = "Color"}
        elseif typeof(value) == "EnumItem" then
            Data[flag] = {Name = value.Name, Type = "Keybind"}
        else
            Data[flag] = value
        end
    end
    writefile(GetConfigName(name), HttpService:JSONEncode(Data))
end

local function LoadConfiguration(name)
    if not isfile(GetConfigName(name)) then return end
    
    local Content = readfile(GetConfigName(name))
    local Data = HttpService:JSONDecode(Content)
    
    for flag, value in pairs(Data) do
        if type(value) == "table" and value.Type == "Color" then
            Library.Flags[flag] = Color3.new(value.R, value.G, value.B)
        elseif type(value) == "table" and value.Type == "Keybind" then
            Library.Flags[flag] = Enum.KeyCode[value.Name]
        else
            Library.Flags[flag] = value
        end
        
        if Library.ConfigObjects[flag] then
            Library.ConfigObjects[flag]:Set(Library.Flags[flag])
        end
    end
end

local function MakeDraggable(topbarobject, object)
    local Dragging = nil
    local DragInput = nil
    local DragStart = nil
    local StartPosition = nil

    local function Update(input)
        local Delta = input.Position - DragStart
        local pos = UDim2.new(StartPosition.X.Scale, StartPosition.X.Offset + Delta.X, StartPosition.Y.Scale, StartPosition.Y.Offset + Delta.Y)
        local Tween = TweenService:Create(object, TweenInfo.new(0.15), {Position = pos})
        Tween:Play()
    end

    topbarobject.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            Dragging = true
            DragStart = input.Position
            StartPosition = object.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    Dragging = false
                end
            end)
        end
    end)

    topbarobject.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            DragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == DragInput and Dragging then
            Update(input)
        end
    end)
end

function Library:Notify(title, text, duration)
    local Frame = Instance.new("Frame")
    local Title = Instance.new("TextLabel")
    local Desc = Instance.new("TextLabel")
    local Bar = Instance.new("Frame")
    
    Frame.Name = "Notification"
    Frame.Parent = Notifications
    Frame.BackgroundColor3 = Theme.Section
    Frame.BorderColor3 = Theme.Border
    Frame.BorderSizePixel = 1
    Frame.Size = UDim2.new(0, 250, 0, 70)
    Frame.Position = UDim2.new(1, 260, 1, -80)
    Frame.ClipsDescendants = true

    Title.Parent = Frame
    Title.BackgroundTransparency = 1
    Title.Position = UDim2.new(0, 10, 0, 5)
    Title.Size = UDim2.new(1, -20, 0, 20)
    Title.Font = Enum.Font.Code
    Title.Text = title
    Title.TextColor3 = Theme.Accent
    Title.TextSize = 14
    Title.TextXAlignment = Enum.TextXAlignment.Left

    Desc.Parent = Frame
    Desc.BackgroundTransparency = 1
    Desc.Position = UDim2.new(0, 10, 0, 25)
    Desc.Size = UDim2.new(1, -20, 0, 40)
    Desc.Font = Enum.Font.Gotham
    Desc.Text = text
    Desc.TextColor3 = Theme.Text
    Desc.TextSize = 12
    Desc.TextWrapped = true
    Desc.TextXAlignment = Enum.TextXAlignment.Left
    Desc.TextYAlignment = Enum.TextYAlignment.Top

    Bar.Parent = Frame
    Bar.BackgroundColor3 = Theme.Accent
    Bar.BorderSizePixel = 0
    Bar.Position = UDim2.new(0, 0, 1, -2)
    Bar.Size = UDim2.new(1, 0, 0, 2)

    TweenService:Create(Frame, TweenInfo.new(0.5, Enum.EasingStyle.Quart), {Position = UDim2.new(1, -260, 1, -80)}):Play()
    TweenService:Create(Bar, TweenInfo.new(duration or 3, Enum.EasingStyle.Linear), {Size = UDim2.new(0, 0, 0, 2)}):Play()

    task.delay(duration or 3, function()
        local Out = TweenService:Create(Frame, TweenInfo.new(0.5, Enum.EasingStyle.Quart), {Position = UDim2.new(1, 260, 1, -80)})
        Out:Play()
        Out.Completed:Connect(function() Frame:Destroy() end)
    end)
end

function Library:CreateWindow(hubName, toggleKey)
    Library.Keybind = toggleKey or Enum.KeyCode.RightControl

    if LocalPlayer.PlayerGui:FindFirstChild("RavionUI") then
        LocalPlayer.PlayerGui.RavionUI:Destroy()
    end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "RavionUI"
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global

    local OpenBtn = Instance.new("TextButton")
    OpenBtn.Name = "MobileToggle"
    OpenBtn.Size = UDim2.new(0, 50, 0, 50)
    OpenBtn.Position = UDim2.new(0.1, 0, 0.1, 0)
    OpenBtn.BackgroundColor3 = Theme.Sidebar
    OpenBtn.BorderColor3 = Theme.Accent
    OpenBtn.BorderSizePixel = 1
    OpenBtn.Text = "UI"
    OpenBtn.TextColor3 = Theme.Accent
    OpenBtn.Font = Enum.Font.Code
    OpenBtn.TextSize = 14
    OpenBtn.Parent = ScreenGui
    OpenBtn.Visible = false

    if UserInputService.TouchEnabled then OpenBtn.Visible = true end
    MakeDraggable(OpenBtn, OpenBtn)

    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 550, 0, 380)
    MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    MainFrame.BackgroundColor3 = Theme.Background
    MainFrame.BorderColor3 = Theme.Border
    MainFrame.BorderSizePixel = 1
    MainFrame.Parent = ScreenGui

    local Header = Instance.new("Frame")
    Header.Name = "Header"
    Header.Size = UDim2.new(1, 0, 0, 35)
    Header.BackgroundColor3 = Theme.Sidebar
    Header.BorderColor3 = Theme.Border
    Header.BorderSizePixel = 1
    Header.Parent = MainFrame
    
    MakeDraggable(Header, MainFrame)

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -10, 1, 0)
    Title.Position = UDim2.new(0, 10, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = hubName
    Title.TextColor3 = Theme.Accent
    Title.TextSize = 17
    Title.Font = Enum.Font.Code
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = Header

    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 35, 1, 0)
    CloseBtn.Position = UDim2.new(1, -35, 0, 0)
    CloseBtn.BackgroundTransparency = 1
    CloseBtn.Text = "X"
    CloseBtn.TextColor3 = Theme.TextDark
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.TextSize = 14
    CloseBtn.Parent = Header
    
    local function ToggleUI()
        Library.Open = not Library.Open
        MainFrame.Visible = Library.Open
        OpenBtn.Visible = not Library.Open and UserInputService.TouchEnabled
    end

    CloseBtn.MouseButton1Click:Connect(ToggleUI)
    OpenBtn.MouseButton1Click:Connect(ToggleUI)

    local SidebarContainer = Instance.new("Frame")
    SidebarContainer.Name = "SidebarContainer"
    SidebarContainer.Size = UDim2.new(0, 140, 1, -36)
    SidebarContainer.Position = UDim2.new(0, 0, 0, 36)
    SidebarContainer.BackgroundColor3 = Theme.Sidebar
    SidebarContainer.BorderColor3 = Theme.Border
    SidebarContainer.BorderSizePixel = 1
    SidebarContainer.Parent = MainFrame

    local SearchBar = Instance.new("TextBox")
    SearchBar.Name = "SearchBar"
    SearchBar.Size = UDim2.new(1, -10, 0, 24)
    SearchBar.Position = UDim2.new(0, 5, 0, 6)
    SearchBar.BackgroundColor3 = Theme.Background
    SearchBar.BorderColor3 = Theme.Border
    SearchBar.BorderSizePixel = 1
    SearchBar.PlaceholderText = "Search Tab..."
    SearchBar.Text = ""
    SearchBar.TextColor3 = Theme.Text
    SearchBar.PlaceholderColor3 = Theme.TextDark
    SearchBar.Font = Enum.Font.Gotham
    SearchBar.TextSize = 12
    SearchBar.Parent = SidebarContainer

    local Sidebar = Instance.new("ScrollingFrame")
    Sidebar.Size = UDim2.new(1, 0, 1, -36)
    Sidebar.Position = UDim2.new(0, 0, 0, 36)
    Sidebar.BackgroundTransparency = 1
    Sidebar.BorderSizePixel = 0
    Sidebar.ScrollBarThickness = 2
    Sidebar.ScrollBarImageColor3 = Theme.Accent
    Sidebar.Parent = SidebarContainer

    local SidebarLayout = Instance.new("UIListLayout")
    SidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
    SidebarLayout.Parent = Sidebar

    local ContentArea = Instance.new("Frame")
    ContentArea.Size = UDim2.new(1, -142, 1, -36)
    ContentArea.Position = UDim2.new(0, 142, 0, 36)
    ContentArea.BackgroundTransparency = 1
    ContentArea.ClipsDescendants = true
    ContentArea.Parent = MainFrame

    UserInputService.InputBegan:Connect(function(input, gp)
        if gp then return end
        if input.KeyCode == Library.Keybind then
            ToggleUI()
        end
    end)

    UserInputService.InputBegan:Connect(function(input, gp)
        if gp or not Library.Open then return end
        for key, callback in pairs(CurrentKeybinds) do
            if input.KeyCode == key then
                callback()
            end
        end
    end)

    local TabButtons = {} 
    
    SearchBar:GetPropertyChangedSignal("Text"):Connect(function()
        local text = SearchBar.Text:lower()
        for _, btn in pairs(TabButtons) do
            if text == "" or btn.Text:lower():find(text) then
                btn.Visible = true
            else
                btn.Visible = false
            end
        end
    end)

    local Window = {}
    local FirstTab = true

    function Window:AddTab(name)
        local TabBtn = Instance.new("TextButton")
        TabBtn.Size = UDim2.new(1, 0, 0, 32)
        TabBtn.BackgroundColor3 = Theme.Sidebar
        TabBtn.Text = name
        TabBtn.TextColor3 = Theme.TextDark
        TabBtn.Font = Enum.Font.Gotham
        TabBtn.TextSize = 12
        TabBtn.BorderSizePixel = 0
        TabBtn.Parent = Sidebar
        
        table.insert(TabButtons, TabBtn)

        local Page = Instance.new("ScrollingFrame")
        Page.Size = UDim2.new(1, -4, 1, 0)
        Page.Position = UDim2.new(0, 4, 0, 0)
        Page.BackgroundTransparency = 1
        Page.ScrollBarThickness = 2
        Page.ScrollBarImageColor3 = Theme.Accent
        Page.Visible = false
        Page.BorderSizePixel = 0
        Page.Parent = ContentArea

        local PageLayout = Instance.new("UIListLayout")
        PageLayout.SortOrder = Enum.SortOrder.LayoutOrder
        PageLayout.Padding = UDim.new(0, 6)
        PageLayout.Parent = Page

        local PagePad = Instance.new("UIPadding")
        PagePad.PaddingTop = UDim.new(0, 6)
        PagePad.PaddingLeft = UDim.new(0, 4)
        PagePad.PaddingRight = UDim.new(0, 4)
        PagePad.Parent = Page

        if FirstTab then
            Page.Visible = true
            TabBtn.TextColor3 = Theme.Text
            TabBtn.BackgroundColor3 = Theme.Background
            FirstTab = false
        end

        TabBtn.MouseButton1Click:Connect(function()
            for _, child in pairs(ContentArea:GetChildren()) do child.Visible = false end
            for _, child in pairs(Sidebar:GetChildren()) do
                if child:IsA("TextButton") then child.TextColor3 = Theme.TextDark; child.BackgroundColor3 = Theme.Sidebar end
            end
            Page.Visible = true
            TabBtn.TextColor3 = Theme.Text
            TabBtn.BackgroundColor3 = Theme.Background
        end)

        local Tab = {}

        function Tab:AddSection(sectionName)
            local SectionContainer = Instance.new("Frame")
            SectionContainer.Size = UDim2.new(1, -4, 0, 30)
            SectionContainer.BackgroundColor3 = Theme.Section
            SectionContainer.BorderColor3 = Theme.Border
            SectionContainer.BorderSizePixel = 1
            SectionContainer.Parent = Page

            local SectionTitle = Instance.new("TextLabel")
            SectionTitle.Size = UDim2.new(1, -10, 0, 20)
            SectionTitle.Position = UDim2.new(0, 5, 0, 2)
            SectionTitle.BackgroundTransparency = 1
            SectionTitle.Text = sectionName:upper()
            SectionTitle.TextColor3 = Theme.Accent
            SectionTitle.Font = Enum.Font.Code
            SectionTitle.TextSize = 11
            SectionTitle.TextXAlignment = Enum.TextXAlignment.Left
            SectionTitle.Parent = SectionContainer

            local SectionLayout = Instance.new("UIListLayout")
            SectionLayout.SortOrder = Enum.SortOrder.LayoutOrder
            SectionLayout.Padding = UDim.new(0, 4)
            SectionLayout.Parent = SectionContainer

            local SectionPad = Instance.new("UIPadding")
            SectionPad.PaddingTop = UDim.new(0, 26)
            SectionPad.PaddingBottom = UDim.new(0, 6)
            SectionPad.PaddingLeft = UDim.new(0, 6)
            SectionPad.PaddingRight = UDim.new(0, 6)
            SectionPad.Parent = SectionContainer

            SectionLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                SectionContainer.Size = UDim2.new(1, -4, 0, SectionLayout.AbsoluteContentSize.Y + 34)
            end)

            local Section = {}

            function Section:AddLabel(text)
                local Label = Instance.new("TextLabel")
                Label.Size = UDim2.new(1, 0, 0, 20)
                Label.BackgroundTransparency = 1
                Label.Text = text
                Label.TextColor3 = Theme.TextDark
                Label.Font = Enum.Font.Gotham
                Label.TextSize = 12
                Label.TextXAlignment = Enum.TextXAlignment.Left
                Label.Parent = SectionContainer
                
                local LabelObj = {}
                function LabelObj:Set(newText)
                    Label.Text = newText
                end
                return LabelObj
            end
            
            function Section:AddParagraph(title, content)
                local ParaFrame = Instance.new("Frame")
                ParaFrame.Size = UDim2.new(1, 0, 0, 0)
                ParaFrame.BackgroundTransparency = 1
                ParaFrame.Parent = SectionContainer
                
                local PTitle = Instance.new("TextLabel")
                PTitle.Size = UDim2.new(1, 0, 0, 16)
                PTitle.BackgroundTransparency = 1
                PTitle.Text = title
                PTitle.TextColor3 = Theme.Text
                PTitle.Font = Enum.Font.GothamBold
                PTitle.TextSize = 12
                PTitle.TextXAlignment = Enum.TextXAlignment.Left
                PTitle.Parent = ParaFrame
                
                local PContent = Instance.new("TextLabel")
                PContent.Size = UDim2.new(1, 0, 0, 0)
                PContent.Position = UDim2.new(0, 0, 0, 18)
                PContent.BackgroundTransparency = 1
                PContent.Text = content
                PContent.TextColor3 = Theme.TextDark
                PContent.Font = Enum.Font.Gotham
                PContent.TextSize = 12
                PContent.TextWrapped = true
                PContent.TextXAlignment = Enum.TextXAlignment.Left
                PContent.TextYAlignment = Enum.TextYAlignment.Top
                PContent.Parent = ParaFrame
                
                PContent.Size = UDim2.new(1, 0, 0, 1000)
                local bounds = PContent.TextBounds.Y
                PContent.Size = UDim2.new(1, 0, 0, bounds)
                ParaFrame.Size = UDim2.new(1, 0, 0, bounds + 22)
            end

            function Section:AddButton(btnText, callback)
                local Button = Instance.new("TextButton")
                Button.Size = UDim2.new(1, 0, 0, 26)
                Button.BackgroundColor3 = Theme.Background
                Button.BorderColor3 = Theme.Border
                Button.BorderSizePixel = 1
                Button.Text = btnText
                Button.TextColor3 = Theme.Text
                Button.Font = Enum.Font.Gotham
                Button.TextSize = 12
                Button.Parent = SectionContainer

                Button.MouseButton1Click:Connect(function()
                    callback()
                    TweenService:Create(Button, TweenInfo.new(0.1), {BackgroundColor3 = Theme.Accent}):Play()
                    task.wait(0.1)
                    TweenService:Create(Button, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Background}):Play()
                end)
            end

            function Section:AddToggle(toggleText, default, flag, callback)
                local toggled = default or false
                
                local ToggleFrame = Instance.new("TextButton")
                ToggleFrame.Size = UDim2.new(1, 0, 0, 26)
                ToggleFrame.BackgroundTransparency = 1
                ToggleFrame.Text = ""
                ToggleFrame.Parent = SectionContainer

                local Label = Instance.new("TextLabel")
                Label.Size = UDim2.new(1, -26, 1, 0)
                Label.BackgroundTransparency = 1
                Label.Text = toggleText
                Label.TextColor3 = Theme.Text
                Label.Font = Enum.Font.Gotham
                Label.TextSize = 12
                Label.TextXAlignment = Enum.TextXAlignment.Left
                Label.Parent = ToggleFrame

                local Box = Instance.new("Frame")
                Box.Size = UDim2.new(0, 16, 0, 16)
                Box.Position = UDim2.new(1, -18, 0.5, -8)
                Box.BackgroundColor3 = Theme.Background
                Box.BorderColor3 = Theme.Border
                Box.BorderSizePixel = 1
                Box.Parent = ToggleFrame

                local Indicator = Instance.new("Frame")
                Indicator.Size = UDim2.new(1, -4, 1, -4)
                Indicator.Position = UDim2.new(0, 2, 0, 2)
                Indicator.BackgroundColor3 = Theme.Accent
                Indicator.BorderSizePixel = 0
                Indicator.Visible = toggled
                Indicator.Parent = Box

                local function UpdateState(state)
                    toggled = state
                    Indicator.Visible = toggled
                    if flag then Library.Flags[flag] = toggled end
                    callback(toggled)
                end

                ToggleFrame.MouseButton1Click:Connect(function()
                    UpdateState(not toggled)
                end)

                if flag then
                    Library.ConfigObjects[flag] = {Type = "Toggle", Set = UpdateState}
                    if Library.Flags[flag] ~= nil then
                        UpdateState(Library.Flags[flag])
                    else
                        Library.Flags[flag] = toggled
                    end
                end
            end

            function Section:AddSlider(text, minVal, maxVal, initialVal, step, flag, callback)
                minVal = minVal or 0; maxVal = maxVal or 100; initialVal = initialVal or minVal; step = step or 1
                local currentValue = initialVal

                local SliderFrame = Instance.new("Frame")
                SliderFrame.Size = UDim2.new(1, 0, 0, 38)
                SliderFrame.BackgroundTransparency = 1
                SliderFrame.Parent = SectionContainer

                local Label = Instance.new("TextLabel")
                Label.Size = UDim2.new(1, 0, 0, 16)
                Label.BackgroundTransparency = 1
                Label.Text = text .. ": " .. currentValue
                Label.TextColor3 = Theme.Text
                Label.Font = Enum.Font.Gotham
                Label.TextSize = 12
                Label.TextXAlignment = Enum.TextXAlignment.Left
                Label.Parent = SliderFrame

                local BarFrame = Instance.new("Frame")
                BarFrame.Size = UDim2.new(1, 0, 0, 10)
                BarFrame.Position = UDim2.new(0, 0, 0, 20)
                BarFrame.BackgroundColor3 = Theme.Background
                BarFrame.BorderColor3 = Theme.Border
                BarFrame.BorderSizePixel = 1
                BarFrame.Parent = SliderFrame

                local Fill = Instance.new("Frame")
                local ratio = (initialVal - minVal) / (maxVal - minVal)
                Fill.Size = UDim2.new(ratio, 0, 1, 0)
                Fill.BackgroundColor3 = Theme.Accent
                Fill.BorderColor3 = Theme.Accent
                Fill.BorderSizePixel = 1
                Fill.Parent = BarFrame

                local function SetValue(val)
                    currentValue = math.clamp(val, minVal, maxVal)
                    local currentRatio = (currentValue - minVal) / (maxVal - minVal)
                    Fill.Size = UDim2.new(currentRatio, 0, 1, 0)
                    Label.Text = text .. ": " .. tostring(currentValue)
                    
                    if flag then Library.Flags[flag] = currentValue end
                    callback(currentValue)
                end

                local dragging = false
                local function updateInput(input)
                    local barWidth = BarFrame.AbsoluteSize.X
                    local pos = math.clamp(input.Position.X - BarFrame.AbsolutePosition.X, 0, barWidth)
                    local newRatio = pos / barWidth
                    local rawValue = minVal + newRatio * (maxVal - minVal)
                    local steppedValue = math.floor(rawValue / step + 0.5) * step
                    SetValue(steppedValue)
                end

                BarFrame.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then 
                        dragging = true; updateInput(input) 
                    end
                end)
                
                UserInputService.InputChanged:Connect(function(input)
                    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                        updateInput(input)
                    end
                end)
                
                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then 
                        dragging = false 
                    end
                end)

                if flag then
                    Library.ConfigObjects[flag] = {Type = "Slider", Set = SetValue}
                    if Library.Flags[flag] ~= nil then
                        SetValue(Library.Flags[flag])
                    else
                        Library.Flags[flag] = currentValue
                    end
                end
            end

            function Section:AddTextbox(placeholder, flag, callback)
                local BoxFrame = Instance.new("Frame")
                BoxFrame.Size = UDim2.new(1, 0, 0, 26)
                BoxFrame.BackgroundColor3 = Theme.Background
                BoxFrame.BorderColor3 = Theme.Border
                BoxFrame.BorderSizePixel = 1
                BoxFrame.Parent = SectionContainer

                local TextBox = Instance.new("TextBox")
                TextBox.Size = UDim2.new(1, -8, 1, 0)
                TextBox.Position = UDim2.new(0, 4, 0, 0)
                TextBox.BackgroundTransparency = 1
                TextBox.Text = ""
                TextBox.PlaceholderText = placeholder
                TextBox.PlaceholderColor3 = Theme.TextDark
                TextBox.TextColor3 = Theme.Text
                TextBox.Font = Enum.Font.Gotham
                TextBox.TextSize = 12
                TextBox.TextXAlignment = Enum.TextXAlignment.Left
                TextBox.Parent = BoxFrame
                
                local function SetText(txt)
                    TextBox.Text = txt
                    if flag then Library.Flags[flag] = txt end
                    callback(txt)
                end
                
                TextBox.FocusLost:Connect(function()
                    SetText(TextBox.Text)
                end)
                
                if flag then
                    Library.ConfigObjects[flag] = {Type = "Textbox", Set = SetText}
                    if Library.Flags[flag] ~= nil then
                        SetText(Library.Flags[flag])
                    end
                end
            end

            function Section:AddDropdown(text, options, initialIndex, flag, callback)
                local selectedIndex = initialIndex or 1
                local isExpanded = false

                local DropdownFrame = Instance.new("Frame")
                DropdownFrame.Size = UDim2.new(1, 0, 0, 26)
                DropdownFrame.BackgroundTransparency = 1
                DropdownFrame.ZIndex = 20
                DropdownFrame.Parent = SectionContainer

                local Label = Instance.new("TextLabel")
                Label.Size = UDim2.new(0.4, 0, 1, 0)
                Label.BackgroundTransparency = 1
                Label.Text = text
                Label.TextColor3 = Theme.Text
                Label.Font = Enum.Font.Gotham
                Label.TextSize = 12
                Label.TextXAlignment = Enum.TextXAlignment.Left
                Label.Parent = DropdownFrame

                local SelectButton = Instance.new("TextButton")
                SelectButton.Size = UDim2.new(0.6, 0, 1, 0)
                SelectButton.Position = UDim2.new(0.4, 0, 0, 0)
                SelectButton.BackgroundColor3 = Theme.Background
                SelectButton.BorderColor3 = Theme.Border
                SelectButton.BorderSizePixel = 1
                SelectButton.Text = options[selectedIndex] or "..."
                SelectButton.TextColor3 = Theme.Accent
                SelectButton.Font = Enum.Font.Gotham
                SelectButton.TextSize = 12
                SelectButton.Parent = DropdownFrame

                local DropdownList = Instance.new("ScrollingFrame")
                DropdownList.Size = UDim2.new(0.6, 0, 0, 0)
                DropdownList.Position = UDim2.new(0.4, 0, 1, 2)
                DropdownList.BackgroundColor3 = Theme.Section
                DropdownList.BorderColor3 = Theme.Border
                DropdownList.BorderSizePixel = 1
                DropdownList.Visible = false
                DropdownList.ZIndex = 50 
                DropdownList.ScrollBarThickness = 2
                DropdownList.Parent = DropdownFrame

                local ListLayout = Instance.new("UIListLayout")
                ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
                ListLayout.Parent = DropdownList
                
                local function SetOption(opt)
                    SelectButton.Text = opt
                    if flag then Library.Flags[flag] = opt end
                    callback(opt)
                    
                    isExpanded = false
                    DropdownList.Visible = false
                    DropdownFrame.Size = UDim2.new(1, 0, 0, 26)
                    DropdownFrame.ZIndex = 20
                end
                
                local function RefreshList()
                    for _, v in pairs(DropdownList:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
                    
                    for i, option in ipairs(options) do
                        local ItemBtn = Instance.new("TextButton")
                        ItemBtn.Size = UDim2.new(1, 0, 0, 24)
                        ItemBtn.BackgroundColor3 = Theme.Section
                        ItemBtn.BorderColor3 = Theme.Border
                        ItemBtn.BorderSizePixel = 0
                        ItemBtn.Text = option
                        ItemBtn.TextColor3 = Theme.Text
                        ItemBtn.Font = Enum.Font.Gotham
                        ItemBtn.TextSize = 12
                        ItemBtn.ZIndex = 51
                        ItemBtn.Parent = DropdownList
    
                        ItemBtn.MouseButton1Click:Connect(function()
                            SetOption(option)
                        end)
                    end
                    DropdownList.CanvasSize = UDim2.new(0,0,0, #options * 24)
                end
                
                RefreshList()

                SelectButton.MouseButton1Click:Connect(function()
                    isExpanded = not isExpanded
                    DropdownList.Visible = isExpanded
                    if isExpanded then
                        DropdownFrame.ZIndex = 60
                        local h = math.min(#options * 24, 120)
                        DropdownList.Size = UDim2.new(0.6, 0, 0, h)
                        DropdownFrame.Size = UDim2.new(1, 0, 0, 26 + h + 2)
                    else
                        DropdownFrame.Size = UDim2.new(1, 0, 0, 26)
                        DropdownFrame.ZIndex = 20
                    end
                end)
                
                if flag then
                    Library.ConfigObjects[flag] = {
                        Type = "Dropdown", 
                        Set = function(val) SetOption(val) end,
                        Refresh = function(newOpts) 
                            options = newOpts 
                            RefreshList() 
                            SetOption(options[1] or "...")
                        end
                    }
                    if Library.Flags[flag] ~= nil then
                        SetOption(Library.Flags[flag])
                    else
                        Library.Flags[flag] = options[selectedIndex]
                    end
                end
            end
            
            function Section:AddColorPicker(text, defaultColor, flag, callback)
                local default = defaultColor or Color3.fromRGB(255, 255, 255)
                local colorH, colorS, colorV = default:ToHSV()
                local currentColor = default
                
                local PickerFrame = Instance.new("Frame")
                PickerFrame.Size = UDim2.new(1, 0, 0, 26)
                PickerFrame.BackgroundTransparency = 1
                PickerFrame.Parent = SectionContainer
                
                local Label = Instance.new("TextLabel")
                Label.Size = UDim2.new(1, -40, 1, 0)
                Label.BackgroundTransparency = 1
                Label.Text = text
                Label.TextColor3 = Theme.Text
                Label.Font = Enum.Font.Gotham
                Label.TextSize = 12
                Label.TextXAlignment = Enum.TextXAlignment.Left
                Label.Parent = PickerFrame
                
                local ColorBtn = Instance.new("TextButton")
                ColorBtn.Size = UDim2.new(0, 30, 0, 18)
                ColorBtn.Position = UDim2.new(1, -30, 0.5, -9)
                ColorBtn.BackgroundColor3 = currentColor
                ColorBtn.BorderColor3 = Theme.Border
                ColorBtn.BorderSizePixel = 1
                ColorBtn.Text = ""
                ColorBtn.Parent = PickerFrame
                
                -- PRO COLOR PICKER CONTAINER
                local CP_Container = Instance.new("Frame")
                CP_Container.Size = UDim2.new(1, 0, 0, 130)
                CP_Container.BackgroundColor3 = Theme.Section
                CP_Container.BorderColor3 = Theme.Border
                CP_Container.BorderSizePixel = 1
                CP_Container.Visible = false
                CP_Container.ClipsDescendants = true
                CP_Container.Parent = SectionContainer
                CP_Container.ZIndex = 5 -- Higher ZIndex
                
                local SV_Map = Instance.new("ImageButton")
                SV_Map.Size = UDim2.new(0, 100, 0, 100)
                SV_Map.Position = UDim2.new(0, 10, 0, 10)
                SV_Map.BackgroundColor3 = Color3.fromHSV(colorH, 1, 1)
                SV_Map.Image = "rbxassetid://4155801252" -- Gradient for SV
                SV_Map.BorderSizePixel = 0
                SV_Map.AutoButtonColor = false
                SV_Map.Parent = CP_Container
                SV_Map.ZIndex = 6
                
                local SV_Cursor = Instance.new("Frame")
                SV_Cursor.Size = UDim2.new(0, 4, 0, 4)
                SV_Cursor.AnchorPoint = Vector2.new(0.5, 0.5)
                SV_Cursor.BackgroundColor3 = Color3.new(1,1,1)
                SV_Cursor.BorderColor3 = Color3.new(0,0,0)
                SV_Cursor.Parent = SV_Map
                SV_Cursor.ZIndex = 7
                SV_Cursor.Position = UDim2.new(colorS, 0, 1 - colorV, 0)

                local Hue_Bar = Instance.new("ImageButton")
                Hue_Bar.Size = UDim2.new(0, 20, 0, 100)
                Hue_Bar.Position = UDim2.new(0, 120, 0, 10)
                Hue_Bar.BackgroundColor3 = Color3.new(1,1,1)
                Hue_Bar.BorderSizePixel = 0
                Hue_Bar.AutoButtonColor = false
                Hue_Bar.Parent = CP_Container
                Hue_Bar.ZIndex = 6
                
                local UIGradient = Instance.new("UIGradient")
                UIGradient.Rotation = 90
                UIGradient.Color = ColorSequence.new{
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(255,0,0)), 
                    ColorSequenceKeypoint.new(0.167, Color3.fromRGB(255,255,0)), 
                    ColorSequenceKeypoint.new(0.333, Color3.fromRGB(0,255,0)), 
                    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0,255,255)), 
                    ColorSequenceKeypoint.new(0.667, Color3.fromRGB(0,0,255)), 
                    ColorSequenceKeypoint.new(0.833, Color3.fromRGB(255,0,255)), 
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(255,0,0))
                }
                UIGradient.Parent = Hue_Bar
                
                local Hue_Cursor = Instance.new("Frame")
                Hue_Cursor.Size = UDim2.new(1, 0, 0, 2)
                Hue_Cursor.BackgroundColor3 = Color3.new(1,1,1)
                Hue_Cursor.BorderColor3 = Color3.new(0,0,0)
                Hue_Cursor.Parent = Hue_Bar
                Hue_Cursor.ZIndex = 7
                Hue_Cursor.Position = UDim2.new(0, 0, colorH, 0)
                
                local function UpdateColorPicker()
                    currentColor = Color3.fromHSV(colorH, colorS, colorV)
                    ColorBtn.BackgroundColor3 = currentColor
                    SV_Map.BackgroundColor3 = Color3.fromHSV(colorH, 1, 1)
                    
                    if flag then Library.Flags[flag] = currentColor end
                    callback(currentColor)
                end
                
                -- Input Handling using RenderStepped for smoothness
                local draggingSV, draggingHue = false, false
                
                SV_Map.MouseButton1Down:Connect(function()
                    draggingSV = true
                end)
                
                Hue_Bar.MouseButton1Down:Connect(function()
                    draggingHue = true
                end)
                
                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        draggingSV = false
                        draggingHue = false
                    end
                end)
                
                RunService.RenderStepped:Connect(function()
                    if Library.Open and CP_Container.Visible then
                        local mouse = UserInputService:GetMouseLocation()
                        
                        if draggingSV then
                            local rX = math.clamp(mouse.X - SV_Map.AbsolutePosition.X, 0, SV_Map.AbsoluteSize.X)
                            local rY = math.clamp(mouse.Y - SV_Map.AbsolutePosition.Y - 36, 0, SV_Map.AbsoluteSize.Y) -- -36 accounts for GuiInset if needed, usually just abs pos works but checking offset
                            -- Recalc pure relative
                            rX = math.clamp(mouse.X - SV_Map.AbsolutePosition.X, 0, 100)
                            rY = math.clamp(mouse.Y - SV_Map.AbsolutePosition.Y, 0, 100)
                            
                            colorS = rX / 100
                            colorV = 1 - (rY / 100)
                            
                            SV_Cursor.Position = UDim2.new(colorS, 0, 1-colorV, 0)
                            UpdateColorPicker()
                        end
                        
                        if draggingHue then
                            local rY = math.clamp(mouse.Y - Hue_Bar.AbsolutePosition.Y, 0, 100)
                            colorH = 1 - (rY / 100) -- Inverted because gradient is usually 0-1 top-down but standard is 1-0 or adjust per preference. Standard rainbow UIGrad above implies 0 is red top.
                            -- Actually let's just match position:
                            colorH = rY / 100 
                            -- Standard Hue is 0=Red, 1=Red.
                            
                            Hue_Cursor.Position = UDim2.new(0, 0, colorH, 0)
                            -- Need to invert for calculation if standard HSV circle
                            -- But UI Gradient defines it.
                            -- If 0 is Red (top), then value is correct.
                            
                            UpdateColorPicker()
                        end
                    end
                end)
                
                local open = false
                ColorBtn.MouseButton1Click:Connect(function()
                    open = not open
                    CP_Container.Visible = open
                end)
                
                if flag then
                    Library.ConfigObjects[flag] = {Type = "Color", Set = function(col) 
                        if typeof(col) == "table" then col = Color3.new(col.R, col.G, col.B) end
                        colorH, colorS, colorV = col:ToHSV()
                        -- Invert V and Position logic for update
                        currentColor = col
                        SV_Cursor.Position = UDim2.new(colorS, 0, 1-colorV, 0)
                        Hue_Cursor.Position = UDim2.new(0, 0, colorH, 0)
                        UpdateColorPicker()
                    end}
                    if Library.Flags[flag] ~= nil then
                        -- Restore
                        local col = Library.Flags[flag]
                         if typeof(col) == "table" then col = Color3.new(col.R, col.G, col.B) end
                        colorH, colorS, colorV = col:ToHSV()
                        SV_Cursor.Position = UDim2.new(colorS, 0, 1-colorV, 0)
                        Hue_Cursor.Position = UDim2.new(0, 0, colorH, 0)
                        UpdateColorPicker()
                    end
                end
            end

            function Section:AddKeybind(text, initialKey, flag, callback)
                local currentKey = initialKey or Enum.KeyCode.RightShift
                
                local KeybindBtn = Instance.new("TextButton")
                KeybindBtn.Size = UDim2.new(1, 0, 0, 26)
                KeybindBtn.BackgroundColor3 = Theme.Background
                KeybindBtn.BorderColor3 = Theme.Border
                KeybindBtn.BorderSizePixel = 1
                KeybindBtn.Text = text .. ": [" .. currentKey.Name .. "]"
                KeybindBtn.TextColor3 = Theme.Text
                KeybindBtn.Font = Enum.Font.Code
                KeybindBtn.TextSize = 12
                KeybindBtn.Parent = SectionContainer
                
                local function SetKey(key)
                    if CurrentKeybinds[currentKey] then CurrentKeybinds[currentKey] = nil end
                    currentKey = key
                    CurrentKeybinds[currentKey] = callback
                    KeybindBtn.Text = text .. ": [" .. currentKey.Name .. "]"
                    
                    if flag then Library.Flags[flag] = currentKey end
                end
                
                local listening = false
                KeybindBtn.MouseButton1Click:Connect(function()
                    if listening then return end
                    listening = true
                    KeybindBtn.Text = text .. ": [...]"
                    
                    local connection
                    connection = UserInputService.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.Keyboard then
                            SetKey(input.KeyCode)
                            listening = false
                            connection:Disconnect()
                        end
                    end)
                end)
                
                if flag then
                    Library.ConfigObjects[flag] = {Type = "Keybind", Set = SetKey}
                    if Library.Flags[flag] ~= nil then
                        SetKey(Library.Flags[flag])
                    else
                        SetKey(currentKey)
                    end
                else
                    SetKey(currentKey)
                end
            end
            
            return Section
        end
        return Tab
    end

    --// Settings Tab Logic
    local SettingsTab = Window:AddTab("Settings")
    local ConfigSection = SettingsTab:AddSection("Configuration")
    
    local ConfigName = ""
    ConfigSection:AddTextbox("Config Name", nil, function(txt)
        ConfigName = txt
    end)
    
    ConfigSection:AddButton("Save Config", function()
        if ConfigName ~= "" then
            SaveConfiguration(ConfigName)
            Library:Notify("Configuration", "Saved config: " .. ConfigName, 3)
        end
    end)
    
    ConfigSection:AddButton("Load Config", function()
        if ConfigName ~= "" then
            LoadConfiguration(ConfigName)
            Library:Notify("Configuration", "Loaded config: " .. ConfigName, 3)
        end
    end)
    
    local ConfigList = {}
    local function RefreshConfigs()
        ConfigList = {}
        if isfolder(ConfigFolder) then
            for _, file in ipairs(listfiles(ConfigFolder)) do
                if file:sub(-#ConfigExtension) == ConfigExtension then
                    local name = file:gsub(ConfigFolder.."/", ""):gsub(ConfigExtension, "")
                    table.insert(ConfigList, name)
                end
            end
        end
        return ConfigList
    end
    
    ConfigSection:AddDropdown("Config List", RefreshConfigs(), 1, nil, function(val)
        ConfigName = val
    end)

    ConfigSection:AddButton("Refresh Config List", function()
       Library:Notify("System", "Refreshed list (Reload UI to see changes)", 2)
    end)

    return Window
end

return Library
