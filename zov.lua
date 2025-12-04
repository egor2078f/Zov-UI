local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

--// File System Setup (Smart Folders)
local RootFolder = "ZovUi"

if not isfolder(RootFolder) then
    makefolder(RootFolder)
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
    Hover = Color3.fromRGB(35, 35, 35),
    Success = Color3.fromRGB(60, 179, 113),
    Error = Color3.fromRGB(220, 53, 69)
}

--// Library Logic
local Library = {
    Flags = {},
    ConfigObjects = {},
    Open = true,
    AccentColor = Theme.Accent,
    Keybind = Enum.KeyCode.RightControl,
    ScriptName = "Default" -- Default script name, will be changed in CreateWindow
}

local CurrentKeybinds = {}

--// Notification System
local NotificationsGui = Instance.new("ScreenGui")
NotificationsGui.Name = "ZovNotifications"
NotificationsGui.Parent = CoreGui
NotificationsGui.ZIndexBehavior = Enum.ZIndexBehavior.Global

local NotifContainer = Instance.new("Frame")
NotifContainer.Name = "Container"
NotifContainer.Position = UDim2.new(1, -270, 0.5, 0) -- Right side
NotifContainer.Size = UDim2.new(0, 260, 0.5, 0)
NotifContainer.BackgroundTransparency = 1
NotifContainer.Parent = NotificationsGui

local NotifLayout = Instance.new("UIListLayout")
NotifLayout.SortOrder = Enum.SortOrder.LayoutOrder
NotifLayout.Padding = UDim.new(0, 5)
NotifLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
NotifLayout.Parent = NotifContainer

function Library:Notify(title, text, duration, type)
    local Frame = Instance.new("Frame")
    local Title = Instance.new("TextLabel")
    local Desc = Instance.new("TextLabel")
    local Bar = Instance.new("Frame")
    local Gradient = Instance.new("UIGradient")
    
    local color = Theme.Accent
    if type == "error" then color = Theme.Error end
    if type == "success" then color = Theme.Success end

    Frame.Name = "Notification"
    Frame.Parent = NotifContainer
    Frame.BackgroundColor3 = Theme.Section
    Frame.BorderColor3 = Theme.Border
    Frame.BorderSizePixel = 1
    Frame.Size = UDim2.new(1, 0, 0, 0) -- Start small for animation
    Frame.ClipsDescendants = true
    Frame.BackgroundTransparency = 0.1

    Title.Parent = Frame
    Title.BackgroundTransparency = 1
    Title.Position = UDim2.new(0, 10, 0, 5)
    Title.Size = UDim2.new(1, -20, 0, 20)
    Title.Font = Enum.Font.Code
    Title.Text = title
    Title.TextColor3 = color
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
    Bar.BackgroundColor3 = color
    Bar.BorderSizePixel = 0
    Bar.Position = UDim2.new(0, 0, 1, -2)
    Bar.Size = UDim2.new(1, 0, 0, 2)

    -- Animation In
    TweenService:Create(Frame, TweenInfo.new(0.3), {Size = UDim2.new(1, 0, 0, 70)}):Play()
    TweenService:Create(Bar, TweenInfo.new(duration or 3, Enum.EasingStyle.Linear), {Size = UDim2.new(0, 0, 0, 2)}):Play()

    task.delay(duration or 3, function()
        -- Animation Out
        local Out = TweenService:Create(Frame, TweenInfo.new(0.3), {Size = UDim2.new(1, 0, 0, 0)})
        Out:Play()
        Out.Completed:Connect(function() Frame:Destroy() end)
    end)
end

--// Configuration System
local function GetScriptFolder()
    return RootFolder .. "/" .. Library.ScriptName
end

local function GetConfigPath(name)
    return GetScriptFolder() .. "/" .. name .. ".json"
end

local function SaveConfiguration(name)
    if not isfolder(GetScriptFolder()) then
        makefolder(GetScriptFolder())
    end

    local Data = {}
    for flag, value in pairs(Library.Flags) do
        if typeof(value) == "Color3" then
            Data[flag] = {R = value.R, G = value.G, B = value.B, IsColor = true}
        elseif typeof(value) == "EnumItem" then
            Data[flag] = {Name = value.Name, IsKeybind = true}
        else
            Data[flag] = value
        end
    end
    
    local success, err = pcall(function()
        writefile(GetConfigPath(name), HttpService:JSONEncode(Data))
    end)
    
    if not success then
        Library:Notify("Config Error", "Failed to save: " .. tostring(err), 3, "error")
        return false
    end
    Library:Notify("Config", "Successfully saved: " .. name, 3, "success")
    return true
end

local function LoadConfiguration(name)
    local configPath = GetConfigPath(name)
    
    if not isfile(configPath) then 
        Library:Notify("Config Error", "File not found: " .. name, 3, "error")
        return false
    end
    
    local success, result = pcall(function()
        return HttpService:JSONDecode(readfile(configPath))
    end)
    
    if not success then
        Library:Notify("Config Error", "Corrupted file", 3, "error")
        return false
    end
    
    local Data = result
    
    for flag, value in pairs(Data) do
        local finalValue = value
        
        -- Deserialize special types
        if type(value) == "table" then
            if value.IsColor then
                finalValue = Color3.new(value.R, value.G, value.B)
            elseif value.IsKeybind then
                finalValue = Enum.KeyCode[value.Name] or Enum.KeyCode.RightControl
            end
        end
        
        Library.Flags[flag] = finalValue
        
        -- Update UI Object
        if Library.ConfigObjects[flag] and Library.ConfigObjects[flag].Set then
            task.spawn(function()
                pcall(function()
                    Library.ConfigObjects[flag]:Set(finalValue)
                end)
            end)
        end
    end
    
    Library:Notify("Config", "Loaded: " .. name, 3, "success")
    return true
end

--// Draggable Logic
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

--// Main Window Creation
function Library:CreateWindow(hubName, toggleKey)
    Library.ScriptName = hubName or "ZovScript" -- Sets the subfolder name
    
    -- Create Folder if it doesn't exist for this script
    if not isfolder(GetScriptFolder()) then
        makefolder(GetScriptFolder())
    end

    Library.Keybind = toggleKey or Enum.KeyCode.RightControl

    if LocalPlayer.PlayerGui:FindFirstChild("ZovUI_Main") then
        LocalPlayer.PlayerGui.ZovUI_Main:Destroy()
    end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "ZovUI_Main"
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
    MainFrame.Size = UDim2.new(0, 600, 0, 400) -- Slightly larger
    MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    MainFrame.BackgroundColor3 = Theme.Background
    MainFrame.BorderColor3 = Theme.Border
    MainFrame.BorderSizePixel = 1
    MainFrame.Parent = ScreenGui

    -- Shadow
    local Shadow = Instance.new("ImageLabel")
    Shadow.Name = "Shadow"
    Shadow.AnchorPoint = Vector2.new(0.5, 0.5)
    Shadow.Position = UDim2.new(0.5, 0, 0.5, 0)
    Shadow.Size = UDim2.new(1, 40, 1, 40)
    Shadow.BackgroundTransparency = 1
    Shadow.Image = "rbxassetid://6015897843"
    Shadow.ImageColor3 = Color3.new(0, 0, 0)
    Shadow.ImageTransparency = 0.5
    Shadow.ZIndex = -1
    Shadow.SliceCenter = Rect.new(49, 49, 450, 450)
    Shadow.ScaleType = Enum.ScaleType.Slice
    Shadow.SliceScale = 1
    Shadow.Parent = MainFrame

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
    SidebarContainer.Size = UDim2.new(0, 150, 1, -36)
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
    SearchBar.PlaceholderText = "Search Features..."
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
    ContentArea.Size = UDim2.new(1, -152, 1, -36)
    ContentArea.Position = UDim2.new(0, 152, 0, 36)
    ContentArea.BackgroundTransparency = 1
    ContentArea.ClipsDescendants = true
    ContentArea.Parent = MainFrame

    -- Global Keybind Handler
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
    local TabData = {}
    
    --// Smart Search Logic
    local function SmartSearch(query)
        query = query:lower()
        if query == "" then
            for _, btn in pairs(TabButtons) do btn.Visible = true end
            return
        end
        
        local results = {}
        for tabName, data in pairs(TabData) do
            local score = 0
            if tabName:lower():find(query, 1, true) then score = score + 100 end
            for _, funcName in ipairs(data.functions) do
                if funcName:lower():find(query, 1, true) then score = score + 50 end
            end
            if score > 0 then results[tabName] = score end
        end
        
        for _, btn in pairs(TabButtons) do
            if results[btn.Text] then
                btn.Visible = true
            else
                btn.Visible = false
            end
        end
    end
    
    SearchBar:GetPropertyChangedSignal("Text"):Connect(function() SmartSearch(SearchBar.Text) end)

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
        TabData[name] = {functions = {}}

        local Page = Instance.new("ScrollingFrame")
        Page.Size = UDim2.new(1, -4, 1, 0)
        Page.Position = UDim2.new(0, 4, 0, 0)
        Page.BackgroundTransparency = 1
        Page.ScrollBarThickness = 3
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
        PagePad.PaddingBottom = UDim.new(0, 6)
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
                if child:IsA("TextButton") then 
                    child.TextColor3 = Theme.TextDark
                    child.BackgroundColor3 = Theme.Sidebar 
                end
            end
            Page.Visible = true
            TabBtn.TextColor3 = Theme.Text
            TabBtn.BackgroundColor3 = Theme.Background
        end)

        local Tab = {}

        function Tab:AddSection(sectionName)
            local SectionContainer = Instance.new("Frame")
            SectionContainer.BackgroundColor3 = Theme.Section
            SectionContainer.BorderColor3 = Theme.Border
            SectionContainer.BorderSizePixel = 1
            SectionContainer.ClipsDescendants = true
            SectionContainer.Parent = Page

            local SectionHeader = Instance.new("TextButton")
            SectionHeader.Size = UDim2.new(1, 0, 0, 30)
            SectionHeader.BackgroundTransparency = 1
            SectionHeader.Text = ""
            SectionHeader.Parent = SectionContainer

            local SectionTitle = Instance.new("TextLabel")
            SectionTitle.Size = UDim2.new(1, -30, 1, 0)
            SectionTitle.Position = UDim2.new(0, 10, 0, 0)
            SectionTitle.BackgroundTransparency = 1
            SectionTitle.Text = sectionName:upper()
            SectionTitle.TextColor3 = Theme.Accent
            SectionTitle.Font = Enum.Font.Code
            SectionTitle.TextSize = 11
            SectionTitle.TextXAlignment = Enum.TextXAlignment.Left
            SectionTitle.Parent = SectionHeader

            local Arrow = Instance.new("TextLabel")
            Arrow.Size = UDim2.new(0, 30, 1, 0)
            Arrow.Position = UDim2.new(1, -30, 0, 0)
            Arrow.BackgroundTransparency = 1
            Arrow.Text = "-"
            Arrow.TextColor3 = Theme.TextDark
            Arrow.Font = Enum.Font.GothamBold
            Arrow.TextSize = 14
            Arrow.Parent = SectionHeader

            local Container = Instance.new("Frame")
            Container.Size = UDim2.new(1, 0, 0, 0)
            Container.Position = UDim2.new(0, 0, 0, 30)
            Container.BackgroundTransparency = 1
            Container.Parent = SectionContainer

            local SectionLayout = Instance.new("UIListLayout")
            SectionLayout.SortOrder = Enum.SortOrder.LayoutOrder
            SectionLayout.Padding = UDim.new(0, 4)
            SectionLayout.Parent = Container

            local SectionPad = Instance.new("UIPadding")
            SectionPad.PaddingTop = UDim.new(0, 5)
            SectionPad.PaddingBottom = UDim.new(0, 5)
            SectionPad.PaddingLeft = UDim.new(0, 6)
            SectionPad.PaddingRight = UDim.new(0, 6)
            SectionPad.Parent = Container

            local collapsed = false
            local function Resize()
                if collapsed then
                    TweenService:Create(SectionContainer, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {Size = UDim2.new(1, 0, 0, 30)}):Play()
                    Arrow.Text = "+"
                else
                    local h = SectionLayout.AbsoluteContentSize.Y + 40
                    TweenService:Create(SectionContainer, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {Size = UDim2.new(1, 0, 0, h)}):Play()
                    Arrow.Text = "-"
                end
            end

            SectionHeader.MouseButton1Click:Connect(function()
                collapsed = not collapsed
                Resize()
            end)

            SectionLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                if not collapsed then Resize() end
            end)

            -- Initialize Size
            SectionContainer.Size = UDim2.new(1, 0, 0, 40) -- Temp
            task.delay(0.1, Resize)

            local Section = {}

            --// ELEMENT: Label
            function Section:AddLabel(text)
                table.insert(TabData[name].functions, "Label: " .. text)
                
                local Label = Instance.new("TextLabel")
                Label.Size = UDim2.new(1, 0, 0, 20)
                Label.BackgroundTransparency = 1
                Label.Text = text
                Label.TextColor3 = Theme.TextDark
                Label.Font = Enum.Font.Gotham
                Label.TextSize = 12
                Label.TextXAlignment = Enum.TextXAlignment.Left
                Label.Parent = Container
                
                local LabelObj = {}
                function LabelObj:Set(newText) Label.Text = newText end
                return LabelObj
            end
            
            --// ELEMENT: Divider
            function Section:AddDivider()
                local Div = Instance.new("Frame")
                Div.Size = UDim2.new(1, 0, 0, 1)
                Div.BackgroundColor3 = Theme.Border
                Div.BorderSizePixel = 0
                Div.Parent = Container
            end

            --// ELEMENT: Image
            function Section:AddImage(imageId, height)
                local ImgFrame = Instance.new("Frame")
                ImgFrame.Size = UDim2.new(1, 0, 0, height or 100)
                ImgFrame.BackgroundTransparency = 1
                ImgFrame.Parent = Container

                local Img = Instance.new("ImageLabel")
                Img.Size = UDim2.new(1, 0, 1, 0)
                Img.BackgroundTransparency = 1
                Img.ScaleType = Enum.ScaleType.Fit
                Img.Image = "rbxassetid://" .. tostring(imageId):gsub("rbxassetid://", "")
                Img.Parent = ImgFrame
            end

            --// ELEMENT: Paragraph
            function Section:AddParagraph(title, content)
                table.insert(TabData[name].functions, "Paragraph: " .. title)
                
                local ParaFrame = Instance.new("Frame")
                ParaFrame.Size = UDim2.new(1, 0, 0, 0)
                ParaFrame.BackgroundTransparency = 1
                ParaFrame.Parent = Container
                
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

            --// ELEMENT: Button
            function Section:AddButton(btnText, callback)
                table.insert(TabData[name].functions, "Button: " .. btnText)
                
                local Button = Instance.new("TextButton")
                Button.Size = UDim2.new(1, 0, 0, 26)
                Button.BackgroundColor3 = Theme.Background
                Button.BorderColor3 = Theme.Border
                Button.BorderSizePixel = 1
                Button.Text = btnText
                Button.TextColor3 = Theme.Text
                Button.Font = Enum.Font.Gotham
                Button.TextSize = 12
                Button.Parent = Container

                Button.MouseButton1Click:Connect(function()
                    pcall(callback)
                    TweenService:Create(Button, TweenInfo.new(0.1), {BackgroundColor3 = Theme.Accent}):Play()
                    task.wait(0.1)
                    TweenService:Create(Button, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Background}):Play()
                end)
            end

            --// ELEMENT: Toggle
            function Section:AddToggle(toggleText, default, flag, callback)
                table.insert(TabData[name].functions, "Toggle: " .. toggleText)
                local toggled = default or false
                
                local ToggleFrame = Instance.new("TextButton")
                ToggleFrame.Size = UDim2.new(1, 0, 0, 26)
                ToggleFrame.BackgroundTransparency = 1
                ToggleFrame.Text = ""
                ToggleFrame.Parent = Container

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
                    pcall(callback, toggled)
                end

                ToggleFrame.MouseButton1Click:Connect(function() UpdateState(not toggled) end)

                if flag then
                    Library.ConfigObjects[flag] = {Type = "Toggle", Set = UpdateState}
                    if Library.Flags[flag] ~= nil then UpdateState(Library.Flags[flag]) else Library.Flags[flag] = toggled end
                end
                
                return {Set = UpdateState}
            end

            --// ELEMENT: Slider
            function Section:AddSlider(text, minVal, maxVal, initialVal, step, flag, callback)
                table.insert(TabData[name].functions, "Slider: " .. text)
                
                minVal = minVal or 0
                maxVal = maxVal or 100
                initialVal = initialVal or minVal
                step = step or 1
                local currentValue = initialVal

                local SliderFrame = Instance.new("Frame")
                SliderFrame.Size = UDim2.new(1, 0, 0, 38)
                SliderFrame.BackgroundTransparency = 1
                SliderFrame.Parent = Container

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
                    -- Rounding to step
                    currentValue = math.floor(currentValue / step + 0.5) * step
                    -- Keep decimals clean
                    currentValue = tonumber(string.format("%."..(tostring(step):match("%.(%d+)") and #tostring(step):match("%.(%d+)") or 0).."f", currentValue))

                    local currentRatio = (currentValue - minVal) / (maxVal - minVal)
                    Fill.Size = UDim2.new(currentRatio, 0, 1, 0)
                    Label.Text = text .. ": " .. tostring(currentValue)
                    
                    if flag then Library.Flags[flag] = currentValue end
                    pcall(callback, currentValue)
                end

                local dragging = false
                local function updateInput(input)
                    local barWidth = BarFrame.AbsoluteSize.X
                    local pos = math.clamp(input.Position.X - BarFrame.AbsolutePosition.X, 0, barWidth)
                    local newRatio = pos / barWidth
                    local rawValue = minVal + newRatio * (maxVal - minVal)
                    SetValue(rawValue)
                end

                BarFrame.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then 
                        dragging = true
                        updateInput(input) 
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
                    if Library.Flags[flag] ~= nil then SetValue(Library.Flags[flag]) else Library.Flags[flag] = currentValue end
                end
                
                return {Set = SetValue}
            end

            --// ELEMENT: Textbox
            function Section:AddTextbox(placeholder, flag, callback)
                table.insert(TabData[name].functions, "Textbox: " .. placeholder)
                
                local BoxFrame = Instance.new("Frame")
                BoxFrame.Size = UDim2.new(1, 0, 0, 26)
                BoxFrame.BackgroundColor3 = Theme.Background
                BoxFrame.BorderColor3 = Theme.Border
                BoxFrame.BorderSizePixel = 1
                BoxFrame.Parent = Container

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
                    pcall(callback, txt)
                end
                
                TextBox.FocusLost:Connect(function() SetText(TextBox.Text) end)
                
                if flag then
                    Library.ConfigObjects[flag] = {Type = "Textbox", Set = SetText}
                    if Library.Flags[flag] ~= nil then SetText(Library.Flags[flag]) end
                end
                
                return {Set = SetText}
            end

            --// ELEMENT: Dropdown (Single)
            function Section:AddDropdown(text, options, initialIndex, flag, callback)
                table.insert(TabData[name].functions, "Dropdown: " .. text)
                
                local selectedOption = options[initialIndex or 1] or "..."
                local isExpanded = false

                local DropdownFrame = Instance.new("Frame")
                DropdownFrame.Size = UDim2.new(1, 0, 0, 26)
                DropdownFrame.BackgroundTransparency = 1
                DropdownFrame.ZIndex = 20
                DropdownFrame.Parent = Container

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
                SelectButton.Text = selectedOption
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
                    selectedOption = opt
                    SelectButton.Text = opt
                    if flag then Library.Flags[flag] = opt end
                    pcall(callback, opt)
                    
                    isExpanded = false
                    DropdownList.Visible = false
                    DropdownFrame.Size = UDim2.new(1, 0, 0, 26)
                    DropdownFrame.ZIndex = 20
                end
                
                local function RefreshList()
                    for _, v in pairs(DropdownList:GetChildren()) do 
                        if v:IsA("TextButton") then v:Destroy() end 
                    end
                    
                    for _, option in ipairs(options) do
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
    
                        ItemBtn.MouseButton1Click:Connect(function() SetOption(option) end)
                    end
                    DropdownList.CanvasSize = UDim2.new(0, 0, 0, #options * 24)
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
                        Set = SetOption,
                        Refresh = function(newOpts) options = newOpts RefreshList() SetOption(options[1] or "...") end
                    }
                    if Library.Flags[flag] ~= nil then SetOption(Library.Flags[flag]) else Library.Flags[flag] = selectedOption end
                end
                
                return {Set = SetOption, Refresh = function(n) options = n RefreshList() end}
            end

            --// ELEMENT: Multi Dropdown (New)
            function Section:AddMultiDropdown(text, options, flag, callback)
                table.insert(TabData[name].functions, "MultiDropdown: " .. text)
                
                local selected = {} 
                local isExpanded = false

                local DropdownFrame = Instance.new("Frame")
                DropdownFrame.Size = UDim2.new(1, 0, 0, 26)
                DropdownFrame.BackgroundTransparency = 1
                DropdownFrame.ZIndex = 20
                DropdownFrame.Parent = Container

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
                SelectButton.Text = "..."
                SelectButton.TextColor3 = Theme.Text
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
                
                local function UpdateText()
                    local count = 0
                    local txt = ""
                    for k, v in pairs(selected) do
                        if v then 
                            count = count + 1 
                            if count == 1 then txt = k else txt = txt .. ", " .. k end
                        end
                    end
                    if count == 0 then txt = "None" end
                    SelectButton.Text = txt
                    
                    if flag then Library.Flags[flag] = selected end
                    pcall(callback, selected)
                end
                
                local function RefreshList()
                    for _, v in pairs(DropdownList:GetChildren()) do 
                        if v:IsA("TextButton") then v:Destroy() end 
                    end
                    
                    for _, option in ipairs(options) do
                        local ItemBtn = Instance.new("TextButton")
                        ItemBtn.Size = UDim2.new(1, 0, 0, 24)
                        ItemBtn.BackgroundColor3 = Theme.Section
                        ItemBtn.BorderColor3 = Theme.Border
                        ItemBtn.BorderSizePixel = 0
                        ItemBtn.Text = option
                        ItemBtn.TextColor3 = Theme.TextDark
                        ItemBtn.Font = Enum.Font.Gotham
                        ItemBtn.TextSize = 12
                        ItemBtn.ZIndex = 51
                        ItemBtn.Parent = DropdownList
    
                        ItemBtn.MouseButton1Click:Connect(function()
                            if selected[option] then
                                selected[option] = nil
                                ItemBtn.TextColor3 = Theme.TextDark
                            else
                                selected[option] = true
                                ItemBtn.TextColor3 = Theme.Accent
                            end
                            UpdateText()
                        end)
                    end
                    DropdownList.CanvasSize = UDim2.new(0, 0, 0, #options * 24)
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
                        
                        -- Update visuals on open
                        for _, v in pairs(DropdownList:GetChildren()) do
                            if v:IsA("TextButton") then
                                if selected[v.Text] then v.TextColor3 = Theme.Accent else v.TextColor3 = Theme.TextDark end
                            end
                        end
                    else
                        DropdownFrame.Size = UDim2.new(1, 0, 0, 26)
                        DropdownFrame.ZIndex = 20
                    end
                end)
                
                if flag then
                    Library.ConfigObjects[flag] = {
                        Type = "MultiDropdown", 
                        Set = function(val) selected = val or {} UpdateText() end,
                    }
                    if Library.Flags[flag] ~= nil then selected = Library.Flags[flag] UpdateText() end
                end
                
                return {Set = function(val) selected = val UpdateText() end}
            end
            
            --// ELEMENT: Color Picker
            function Section:AddColorPicker(text, defaultColor, flag, callback)
                table.insert(TabData[name].functions, "ColorPicker: " .. text)
                
                local default = defaultColor or Color3.fromRGB(255, 255, 255)
                local colorH, colorS, colorV = default:ToHSV()
                local currentColor = default
                
                local PickerFrame = Instance.new("Frame")
                PickerFrame.Size = UDim2.new(1, 0, 0, 26)
                PickerFrame.BackgroundTransparency = 1
                PickerFrame.Parent = Container
                
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
                
                local CP_Container = Instance.new("Frame")
                CP_Container.Size = UDim2.new(1, 0, 0, 130)
                CP_Container.BackgroundColor3 = Theme.Section
                CP_Container.BorderColor3 = Theme.Border
                CP_Container.BorderSizePixel = 1
                CP_Container.Visible = false
                CP_Container.ClipsDescendants = true
                CP_Container.Parent = Container
                CP_Container.ZIndex = 5 
                
                local SV_Map = Instance.new("ImageButton")
                SV_Map.Size = UDim2.new(0, 100, 0, 100)
                SV_Map.Position = UDim2.new(0, 10, 0, 10)
                SV_Map.BackgroundColor3 = Color3.fromHSV(colorH, 1, 1)
                SV_Map.Image = "rbxassetid://4155801252"
                SV_Map.BorderSizePixel = 0
                SV_Map.AutoButtonColor = false
                SV_Map.Parent = CP_Container
                SV_Map.ZIndex = 6
                
                local SV_Cursor = Instance.new("Frame")
                SV_Cursor.Size = UDim2.new(0, 4, 0, 4)
                SV_Cursor.AnchorPoint = Vector2.new(0.5, 0.5)
                SV_Cursor.BackgroundColor3 = Color3.new(1, 1, 1)
                SV_Cursor.BorderColor3 = Color3.new(0, 0, 0)
                SV_Cursor.Parent = SV_Map
                SV_Cursor.ZIndex = 7
                SV_Cursor.Position = UDim2.new(colorS, 0, 1 - colorV, 0)

                local Hue_Bar = Instance.new("ImageButton")
                Hue_Bar.Size = UDim2.new(0, 20, 0, 100)
                Hue_Bar.Position = UDim2.new(0, 120, 0, 10)
                Hue_Bar.BackgroundColor3 = Color3.new(1, 1, 1)
                Hue_Bar.BorderSizePixel = 0
                Hue_Bar.AutoButtonColor = false
                Hue_Bar.Parent = CP_Container
                Hue_Bar.ZIndex = 6
                
                local UIGradient = Instance.new("UIGradient")
                UIGradient.Rotation = 90
                UIGradient.Color = ColorSequence.new{
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)), 
                    ColorSequenceKeypoint.new(0.167, Color3.fromRGB(255, 255, 0)), 
                    ColorSequenceKeypoint.new(0.333, Color3.fromRGB(0, 255, 0)), 
                    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)), 
                    ColorSequenceKeypoint.new(0.667, Color3.fromRGB(0, 0, 255)), 
                    ColorSequenceKeypoint.new(0.833, Color3.fromRGB(255, 0, 255)), 
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
                }
                UIGradient.Parent = Hue_Bar
                
                local Hue_Cursor = Instance.new("Frame")
                Hue_Cursor.Size = UDim2.new(1, 0, 0, 2)
                Hue_Cursor.BackgroundColor3 = Color3.new(1, 1, 1)
                Hue_Cursor.BorderColor3 = Color3.new(0, 0, 0)
                Hue_Cursor.Parent = Hue_Bar
                Hue_Cursor.ZIndex = 7
                Hue_Cursor.Position = UDim2.new(0, 0, colorH, 0)
                
                local function UpdateColorPicker()
                    currentColor = Color3.fromHSV(colorH, colorS, colorV)
                    ColorBtn.BackgroundColor3 = currentColor
                    SV_Map.BackgroundColor3 = Color3.fromHSV(colorH, 1, 1)
                    
                    if flag then Library.Flags[flag] = currentColor end
                    pcall(callback, currentColor)
                end
                
                local draggingSV, draggingHue = false, false
                
                local function UpdateSV(input)
                    local rX = math.clamp(input.Position.X - SV_Map.AbsolutePosition.X, 0, SV_Map.AbsoluteSize.X)
                    local rY = math.clamp(input.Position.Y - SV_Map.AbsolutePosition.Y, 0, SV_Map.AbsoluteSize.Y)
                    
                    colorS = rX / SV_Map.AbsoluteSize.X
                    colorV = 1 - (rY / SV_Map.AbsoluteSize.Y)
                    
                    SV_Cursor.Position = UDim2.new(colorS, 0, 1 - colorV, 0)
                    UpdateColorPicker()
                end
                
                local function UpdateHue(input)
                    local rY = math.clamp(input.Position.Y - Hue_Bar.AbsolutePosition.Y, 0, Hue_Bar.AbsoluteSize.Y)
                    colorH = rY / Hue_Bar.AbsoluteSize.Y
                    
                    Hue_Cursor.Position = UDim2.new(0, 0, colorH, 0)
                    UpdateColorPicker()
                end

                SV_Map.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        draggingSV = true
                        UpdateSV(input)
                    end
                end)
                
                Hue_Bar.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        draggingHue = true
                        UpdateHue(input)
                    end
                end)
                
                UserInputService.InputChanged:Connect(function(input)
                    if draggingSV and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                        UpdateSV(input)
                    elseif draggingHue and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                        UpdateHue(input)
                    end
                end)
                
                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        draggingSV = false
                        draggingHue = false
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
                        currentColor = col
                        SV_Cursor.Position = UDim2.new(colorS, 0, 1 - colorV, 0)
                        Hue_Cursor.Position = UDim2.new(0, 0, colorH, 0)
                        UpdateColorPicker()
                    end}
                    if Library.Flags[flag] ~= nil then
                        local col = Library.Flags[flag]
                        if typeof(col) == "table" then col = Color3.new(col.R, col.G, col.B) end
                        colorH, colorS, colorV = col:ToHSV()
                        SV_Cursor.Position = UDim2.new(colorS, 0, 1 - colorV, 0)
                        Hue_Cursor.Position = UDim2.new(0, 0, colorH, 0)
                        UpdateColorPicker()
                    end
                end
                
                return {Set = function(col)
                    if typeof(col) == "table" then col = Color3.new(col.R, col.G, col.B) end
                    colorH, colorS, colorV = col:ToHSV()
                    currentColor = col
                    SV_Cursor.Position = UDim2.new(colorS, 0, 1 - colorV, 0)
                    Hue_Cursor.Position = UDim2.new(0, 0, colorH, 0)
                    UpdateColorPicker()
                end}
            end

            --// ELEMENT: Keybind
            function Section:AddKeybind(text, initialKey, flag, callback)
                table.insert(TabData[name].functions, "Keybind: " .. text)
                
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
                KeybindBtn.Parent = Container
                
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
                    if Library.Flags[flag] ~= nil then SetKey(Library.Flags[flag]) else SetKey(currentKey) end
                else
                    SetKey(currentKey)
                end
                
                return {Set = SetKey}
            end
            
            --// ELEMENT: Progress Bar
            function Section:AddProgressBar(text, maxValue, flag, colorFlag)
                table.insert(TabData[name].functions, "ProgressBar: " .. text)
                
                maxValue = maxValue or 100
                local currentValue = 0
                local barColor = Theme.Accent
                
                local ProgressFrame = Instance.new("Frame")
                ProgressFrame.Size = UDim2.new(1, 0, 0, 38)
                ProgressFrame.BackgroundTransparency = 1
                ProgressFrame.Parent = Container

                local Label = Instance.new("TextLabel")
                Label.Size = UDim2.new(1, 0, 0, 16)
                Label.BackgroundTransparency = 1
                Label.Text = text .. ": 0/" .. maxValue
                Label.TextColor3 = Theme.Text
                Label.Font = Enum.Font.Gotham
                Label.TextSize = 12
                Label.TextXAlignment = Enum.TextXAlignment.Left
                Label.Parent = ProgressFrame

                local BarFrame = Instance.new("Frame")
                BarFrame.Size = UDim2.new(1, 0, 0, 10)
                BarFrame.Position = UDim2.new(0, 0, 0, 20)
                BarFrame.BackgroundColor3 = Theme.Background
                BarFrame.BorderColor3 = Theme.Border
                BarFrame.BorderSizePixel = 1
                BarFrame.Parent = ProgressFrame

                local Fill = Instance.new("Frame")
                Fill.Size = UDim2.new(0, 0, 1, 0)
                Fill.BackgroundColor3 = barColor
                Fill.BorderSizePixel = 0
                Fill.Parent = BarFrame
                
                local PercentLabel = Instance.new("TextLabel")
                PercentLabel.Size = UDim2.new(1, 0, 1, 0)
                PercentLabel.BackgroundTransparency = 1
                PercentLabel.Text = "0%"
                PercentLabel.TextColor3 = Theme.Text
                PercentLabel.Font = Enum.Font.GothamBold
                PercentLabel.TextSize = 10
                PercentLabel.ZIndex = 2
                PercentLabel.Parent = BarFrame

                local function SetValue(val)
                    currentValue = math.clamp(val, 0, maxValue)
                    local ratio = currentValue / maxValue
                    local percent = math.floor(ratio * 100)
                    
                    TweenService:Create(Fill, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {Size = UDim2.new(ratio, 0, 1, 0)}):Play()
                    
                    Label.Text = text .. ": " .. currentValue .. "/" .. maxValue
                    PercentLabel.Text = percent .. "%"
                    
                    if flag then Library.Flags[flag] = currentValue end
                end
                
                local function SetColor(col)
                    barColor = col
                    Fill.BackgroundColor3 = col
                    if colorFlag then Library.Flags[colorFlag] = col end
                end

                if flag then
                    Library.ConfigObjects[flag] = {Type = "ProgressBar", Set = SetValue}
                    if Library.Flags[flag] ~= nil then SetValue(Library.Flags[flag]) end
                end
                
                if colorFlag then
                    Library.ConfigObjects[colorFlag] = {Type = "Color", Set = SetColor}
                    if Library.Flags[colorFlag] ~= nil then SetColor(Library.Flags[colorFlag]) end
                end
                
                return {Set = SetValue, SetColor = SetColor, Increment = function(amt) SetValue(currentValue + (amt or 1)) end}
            end
            
            return Section
        end
        return Tab
    end

    --// Built-in Settings Tab
    local SettingsTab = Window:AddTab("Config")
    local ConfigSection = SettingsTab:AddSection("Manager")
    
    local ConfigName = ""
    local ConfigDropdown = nil
    
    ConfigSection:AddTextbox("Create/Load Name", nil, function(txt)
        ConfigName = txt
    end)
    
    local function RefreshConfigs()
        local ConfigList = {}
        local path = GetScriptFolder()
        if isfolder(path) then
            local files = listfiles(path)
            for _, file in ipairs(files) do
                if file:sub(-5) == ".json" then
                    local name = file:gsub(path .. "/", ""):gsub(".json", "")
                    table.insert(ConfigList, name)
                end
            end
        end
        if #ConfigList == 0 then table.insert(ConfigList, "No Configs") end
        return ConfigList
    end

    ConfigDropdown = ConfigSection:AddDropdown("Available Configs", RefreshConfigs(), 1, nil, function(val)
        if val ~= "No Configs" then ConfigName = val end
    end)

    ConfigSection:AddButton("Refresh List", function()
        if ConfigDropdown then ConfigDropdown:Refresh(RefreshConfigs()) end
        Library:Notify("System", "Refreshed", 2)
    end)
    
    ConfigSection:AddDivider()

    ConfigSection:AddButton("Save Config", function()
        if ConfigName ~= "" then
            SaveConfiguration(ConfigName)
            ConfigDropdown:Refresh(RefreshConfigs())
        else
            Library:Notify("Error", "Enter a name", 3, "error")
        end
    end)
    
    ConfigSection:AddButton("Load Config", function()
        if ConfigName ~= "" then LoadConfiguration(ConfigName) else Library:Notify("Error", "Enter a name", 3, "error") end
    end)

    ConfigSection:AddButton("Delete Config", function()
        if ConfigName ~= "" and ConfigName ~= "No Configs" then
            local path = GetConfigPath(ConfigName)
            if isfile(path) then
                delfile(path)
                Library:Notify("Config", "Deleted: " .. ConfigName, 3, "success")
                ConfigDropdown:Refresh(RefreshConfigs())
            end
        end
    end)
    
    local InfoSection = SettingsTab:AddSection("Info")
    InfoSection:AddLabel("User: " .. LocalPlayer.DisplayName)
    InfoSection:AddLabel("Script: " .. Library.ScriptName)
    InfoSection:AddImage("rbxassetid://16016599484", 100) -- Example Logo
    InfoSection:AddButton("Unload UI", function() ScreenGui:Destroy() end)

    return Window
end

return Library
