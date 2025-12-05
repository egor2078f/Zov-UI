local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local Library = {
    Open = true,
    Accent = Color3.fromRGB(0, 122, 204),
    Pages = {},
    Flags = {}
}

local Theme = {
    Main = Color3.fromRGB(25, 25, 25),
    Sidebar = Color3.fromRGB(30, 30, 30),
    Section = Color3.fromRGB(35, 35, 35),
    Text = Color3.fromRGB(240, 240, 240),
    TextDim = Color3.fromRGB(160, 160, 160),
    Stroke = Color3.fromRGB(50, 50, 50),
    Item = Color3.fromRGB(40, 40, 40),
    Hover = Color3.fromRGB(50, 50, 50)
}

local function CreateTween(obj, props, time)
    local info = TweenInfo.new(time or 0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    TweenService:Create(obj, info, props):Play()
end

local function MakeDraggable(topbar, object)
    local Dragging, DragInput, DragStart, StartPos

    topbar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            Dragging = true
            DragStart = input.Position
            StartPos = object.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then Dragging = false end
            end)
        end
    end)

    topbar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            DragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == DragInput and Dragging then
            local Delta = input.Position - DragStart
            object.Position = UDim2.new(StartPos.X.Scale, StartPos.X.Offset + Delta.X, StartPos.Y.Scale, StartPos.Y.Offset + Delta.Y)
        end
    end)
end

function Library:CreateWindow(name, toggleKey)
    if LocalPlayer.PlayerGui:FindFirstChild("ZovUI") then LocalPlayer.PlayerGui.ZovUI:Destroy() end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "ZovUI"
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    ScreenGui.ResetOnSpawn = false

    local MobileBtn = Instance.new("TextButton")
    MobileBtn.Size = UDim2.new(0, 50, 0, 50)
    MobileBtn.Position = UDim2.new(0.05, 0, 0.1, 0)
    MobileBtn.BackgroundColor3 = Theme.Sidebar
    MobileBtn.BorderSizePixel = 0
    MobileBtn.Text = "O"
    MobileBtn.TextColor3 = Library.Accent
    MobileBtn.Font = Enum.Font.GothamBold
    MobileBtn.TextSize = 20
    MobileBtn.Parent = ScreenGui
    MobileBtn.Visible = UserInputService.TouchEnabled
    
    local UICornerBtn = Instance.new("UICorner")
    UICornerBtn.CornerRadius = UDim.new(0, 12)
    UICornerBtn.Parent = MobileBtn
    
    MakeDraggable(MobileBtn, MobileBtn)

    local Main = Instance.new("Frame")
    Main.Size = UDim2.new(0, 600, 0, 400)
    Main.Position = UDim2.new(0.5, 0, 0.5, 0)
    Main.AnchorPoint = Vector2.new(0.5, 0.5)
    Main.BackgroundColor3 = Theme.Main
    Main.BorderSizePixel = 0
    Main.ClipsDescendants = true
    Main.Parent = ScreenGui

    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 6)
    MainCorner.Parent = Main

    local Sidebar = Instance.new("Frame")
    Sidebar.Size = UDim2.new(0, 160, 1, 0)
    Sidebar.BackgroundColor3 = Theme.Sidebar
    Sidebar.BorderSizePixel = 0
    Sidebar.Parent = Main

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -20, 0, 50)
    Title.Position = UDim2.new(0, 15, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = name
    Title.TextColor3 = Library.Accent
    Title.Font = Enum.Font.GothamBlack
    Title.TextSize = 18
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = Sidebar

    local TabContainer = Instance.new("ScrollingFrame")
    TabContainer.Size = UDim2.new(1, 0, 1, -60)
    TabContainer.Position = UDim2.new(0, 0, 0, 60)
    TabContainer.BackgroundTransparency = 1
    TabContainer.ScrollBarThickness = 0
    TabContainer.Parent = Sidebar

    local TabLayout = Instance.new("UIListLayout")
    TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabLayout.Padding = UDim.new(0, 5)
    TabLayout.Parent = TabContainer

    local Content = Instance.new("Frame")
    Content.Size = UDim2.new(1, -160, 1, 0)
    Content.Position = UDim2.new(0, 160, 0, 0)
    Content.BackgroundTransparency = 1
    Content.Parent = Main

    local function ToggleUI()
        Library.Open = not Library.Open
        MobileBtn.Visible = not Library.Open and UserInputService.TouchEnabled
        if Library.Open then
            Main.Visible = true
            CreateTween(Main, {Size = UDim2.new(0, 600, 0, 400), BackgroundTransparency = 0}, 0.3)
        else
            CreateTween(Main, {Size = UDim2.new(0, 600, 0, 0), BackgroundTransparency = 1}, 0.3)
            task.delay(0.3, function() if not Library.Open then Main.Visible = false end end)
        end
    end

    UserInputService.InputBegan:Connect(function(input, gp)
        if gp then return end
        if input.KeyCode == (toggleKey or Enum.KeyCode.RightControl) then ToggleUI() end
    end)
    MobileBtn.MouseButton1Click:Connect(ToggleUI)
    MakeDraggable(Sidebar, Main)

    local Window = {}
    local FirstTab = true

    function Window:AddTab(name, order)
        local TabBtn = Instance.new("TextButton")
        TabBtn.Size = UDim2.new(1, -20, 0, 32)
        TabBtn.BackgroundTransparency = 1
        TabBtn.Text = name
        TabBtn.TextColor3 = Theme.TextDim
        TabBtn.Font = Enum.Font.GothamMedium
        TabBtn.TextSize = 13
        TabBtn.TextXAlignment = Enum.TextXAlignment.Left
        TabBtn.LayoutOrder = order or 1
        TabBtn.Parent = TabContainer

        local TabPad = Instance.new("UIPadding")
        TabPad.PaddingLeft = UDim.new(0, 15)
        TabPad.Parent = TabBtn

        local Indicator = Instance.new("Frame")
        Indicator.Size = UDim2.new(0, 3, 0, 16)
        Indicator.Position = UDim2.new(0, -15, 0.5, -8)
        Indicator.BackgroundColor3 = Library.Accent
        Indicator.BorderSizePixel = 0
        Indicator.Visible = false
        Indicator.Parent = TabBtn
        
        local IndCorner = Instance.new("UICorner")
        IndCorner.CornerRadius = UDim.new(0, 4)
        IndCorner.Parent = Indicator

        local Page = Instance.new("ScrollingFrame")
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.BackgroundTransparency = 1
        Page.ScrollBarThickness = 2
        Page.ScrollBarImageColor3 = Library.Accent
        Page.Visible = false
        Page.Parent = Content

        local PageLayout = Instance.new("UIListLayout")
        PageLayout.SortOrder = Enum.SortOrder.LayoutOrder
        PageLayout.Padding = UDim.new(0, 8)
        PageLayout.Parent = Page

        local PagePad = Instance.new("UIPadding")
        PagePad.PaddingTop = UDim.new(0, 10)
        PagePad.PaddingLeft = UDim.new(0, 10)
        PagePad.PaddingRight = UDim.new(0, 10)
        PagePad.PaddingBottom = UDim.new(0, 10)
        PagePad.Parent = Page

        if FirstTab then
            Page.Visible = true
            TabBtn.TextColor3 = Theme.Text
            Indicator.Visible = true
            FirstTab = false
        end

        TabBtn.MouseButton1Click:Connect(function()
            for _, v in pairs(Content:GetChildren()) do v.Visible = false end
            for _, v in pairs(TabContainer:GetChildren()) do
                if v:IsA("TextButton") then
                    CreateTween(v, {TextColor3 = Theme.TextDim}, 0.2)
                    v.Frame.Visible = false
                end
            end
            Page.Visible = true
            CreateTween(TabBtn, {TextColor3 = Theme.Text}, 0.2)
            Indicator.Visible = true
        end)

        local Tab = {}

        function Tab:AddSection(text)
            local SectionFrame = Instance.new("Frame")
            SectionFrame.Size = UDim2.new(1, 0, 0, 30)
            SectionFrame.BackgroundTransparency = 1
            SectionFrame.Parent = Page

            local SectionText = Instance.new("TextLabel")
            SectionText.Size = UDim2.new(1, 0, 1, 0)
            SectionText.BackgroundTransparency = 1
            SectionText.Text = text
            SectionText.TextColor3 = Library.Accent
            SectionText.Font = Enum.Font.GothamBold
            SectionText.TextSize = 12
            SectionText.TextXAlignment = Enum.TextXAlignment.Left
            SectionText.Parent = SectionFrame
            return SectionFrame
        end

        function Tab:AddProfile(username)
            local ProfileFrame = Instance.new("Frame")
            ProfileFrame.Size = UDim2.new(1, 0, 0, 50)
            ProfileFrame.BackgroundColor3 = Theme.Section
            ProfileFrame.Parent = Page
            
            local PCorner = Instance.new("UICorner")
            PCorner.CornerRadius = UDim.new(0, 6)
            PCorner.Parent = ProfileFrame
            
            local Avatar = Instance.new("ImageLabel")
            Avatar.Size = UDim2.new(0, 34, 0, 34)
            Avatar.Position = UDim2.new(0, 8, 0, 8)
            Avatar.BackgroundColor3 = Theme.Item
            Avatar.Image = Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
            Avatar.Parent = ProfileFrame
            
            local ACorner = Instance.new("UICorner")
            ACorner.CornerRadius = UDim.new(1, 0)
            ACorner.Parent = Avatar
            
            local NameLbl = Instance.new("TextLabel")
            NameLbl.Size = UDim2.new(1, -60, 0, 20)
            NameLbl.Position = UDim2.new(0, 50, 0, 8)
            NameLbl.BackgroundTransparency = 1
            NameLbl.Text = username or LocalPlayer.DisplayName
            NameLbl.TextColor3 = Theme.Text
            NameLbl.Font = Enum.Font.GothamBold
            NameLbl.TextSize = 14
            NameLbl.TextXAlignment = Enum.TextXAlignment.Left
            NameLbl.Parent = ProfileFrame
            
            local RankLbl = Instance.new("TextLabel")
            RankLbl.Size = UDim2.new(1, -60, 0, 16)
            RankLbl.Position = UDim2.new(0, 50, 0, 28)
            RankLbl.BackgroundTransparency = 1
            RankLbl.Text = "Zov User"
            RankLbl.TextColor3 = Theme.TextDim
            RankLbl.Font = Enum.Font.Gotham
            RankLbl.TextSize = 11
            RankLbl.TextXAlignment = Enum.TextXAlignment.Left
            RankLbl.Parent = ProfileFrame
        end

        function Tab:AddLabel(text)
            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(1, 0, 0, 26)
            Label.BackgroundTransparency = 1
            Label.Text = text
            Label.TextColor3 = Theme.Text
            Label.Font = Enum.Font.Gotham
            Label.TextSize = 13
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = Page
            return Label
        end

        function Tab:AddButton(text, callback)
            local Button = Instance.new("TextButton")
            Button.Size = UDim2.new(1, 0, 0, 34)
            Button.BackgroundColor3 = Theme.Item
            Button.Text = text
            Button.TextColor3 = Theme.Text
            Button.Font = Enum.Font.Gotham
            Button.TextSize = 13
            Button.Parent = Page
            
            local BCorner = Instance.new("UICorner")
            BCorner.CornerRadius = UDim.new(0, 4)
            BCorner.Parent = Button
            
            Button.MouseEnter:Connect(function() CreateTween(Button, {BackgroundColor3 = Theme.Hover}) end)
            Button.MouseLeave:Connect(function() CreateTween(Button, {BackgroundColor3 = Theme.Item}) end)
            Button.MouseButton1Click:Connect(function()
                CreateTween(Button, {TextSize = 11}, 0.1)
                task.wait(0.1)
                CreateTween(Button, {TextSize = 13}, 0.1)
                pcall(callback)
            end)
        end

        function Tab:AddToggle(text, default, callback)
            local Toggled = default or false
            local ToggleFrame = Instance.new("TextButton")
            ToggleFrame.Size = UDim2.new(1, 0, 0, 34)
            ToggleFrame.BackgroundColor3 = Theme.Item
            ToggleFrame.Text = ""
            ToggleFrame.Parent = Page
            
            local TCorner = Instance.new("UICorner")
            TCorner.CornerRadius = UDim.new(0, 4)
            TCorner.Parent = ToggleFrame
            
            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(1, -50, 1, 0)
            Label.Position = UDim2.new(0, 10, 0, 0)
            Label.BackgroundTransparency = 1
            Label.Text = text
            Label.TextColor3 = Theme.Text
            Label.Font = Enum.Font.Gotham
            Label.TextSize = 13
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = ToggleFrame
            
            local Switch = Instance.new("Frame")
            Switch.Size = UDim2.new(0, 40, 0, 20)
            Switch.Position = UDim2.new(1, -50, 0.5, -10)
            Switch.BackgroundColor3 = Toggled and Library.Accent or Theme.Stroke
            Switch.Parent = ToggleFrame
            
            local SCorner = Instance.new("UICorner")
            SCorner.CornerRadius = UDim.new(1, 0)
            SCorner.Parent = Switch
            
            local Circle = Instance.new("Frame")
            Circle.Size = UDim2.new(0, 16, 0, 16)
            Circle.Position = Toggled and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
            Circle.BackgroundColor3 = Theme.Text
            Circle.Parent = Switch
            
            local CCorner = Instance.new("UICorner")
            CCorner.CornerRadius = UDim.new(1, 0)
            CCorner.Parent = Circle
            
            ToggleFrame.MouseButton1Click:Connect(function()
                Toggled = not Toggled
                CreateTween(Switch, {BackgroundColor3 = Toggled and Library.Accent or Theme.Stroke})
                CreateTween(Circle, {Position = Toggled and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)})
                pcall(callback, Toggled)
            end)
        end

        function Tab:AddSlider(text, min, max, default, callback)
            local Value = default or min
            local SliderFrame = Instance.new("Frame")
            SliderFrame.Size = UDim2.new(1, 0, 0, 45)
            SliderFrame.BackgroundColor3 = Theme.Item
            SliderFrame.Parent = Page
            
            local SCorner = Instance.new("UICorner")
            SCorner.CornerRadius = UDim.new(0, 4)
            SCorner.Parent = SliderFrame
            
            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(1, -10, 0, 20)
            Label.Position = UDim2.new(0, 10, 0, 5)
            Label.BackgroundTransparency = 1
            Label.Text = text
            Label.TextColor3 = Theme.Text
            Label.Font = Enum.Font.Gotham
            Label.TextSize = 13
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = SliderFrame
            
            local ValueLabel = Instance.new("TextLabel")
            ValueLabel.Size = UDim2.new(0, 50, 0, 20)
            ValueLabel.Position = UDim2.new(1, -60, 0, 5)
            ValueLabel.BackgroundTransparency = 1
            ValueLabel.Text = tostring(Value)
            ValueLabel.TextColor3 = Theme.TextDim
            ValueLabel.Font = Enum.Font.Gotham
            ValueLabel.TextSize = 12
            ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
            ValueLabel.Parent = SliderFrame
            
            local BarBG = Instance.new("Frame")
            BarBG.Size = UDim2.new(1, -20, 0, 4)
            BarBG.Position = UDim2.new(0, 10, 0, 30)
            BarBG.BackgroundColor3 = Theme.Stroke
            BarBG.BorderSizePixel = 0
            BarBG.Parent = SliderFrame
            
            local BarCorner = Instance.new("UICorner")
            BarCorner.CornerRadius = UDim.new(1, 0)
            BarCorner.Parent = BarBG
            
            local Fill = Instance.new("Frame")
            Fill.Size = UDim2.new((Value - min) / (max - min), 0, 1, 0)
            Fill.BackgroundColor3 = Library.Accent
            Fill.BorderSizePixel = 0
            Fill.Parent = BarBG
            
            local FillCorner = Instance.new("UICorner")
            FillCorner.CornerRadius = UDim.new(1, 0)
            FillCorner.Parent = Fill
            
            local function Update(input)
                local SizeX = math.clamp((input.Position.X - BarBG.AbsolutePosition.X) / BarBG.AbsoluteSize.X, 0, 1)
                local NewValue = math.floor(min + ((max - min) * SizeX))
                CreateTween(Fill, {Size = UDim2.new(SizeX, 0, 1, 0)}, 0.1)
                ValueLabel.Text = tostring(NewValue)
                pcall(callback, NewValue)
            end
            
            SliderFrame.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    local dragging = true
                    Update(input)
                    input.Changed:Connect(function()
                        if input.UserInputState == Enum.UserInputState.End then dragging = false end
                    end)
                    UserInputService.InputChanged:Connect(function(moveInput)
                        if dragging and (moveInput.UserInputType == Enum.UserInputType.MouseMovement or moveInput.UserInputType == Enum.UserInputType.Touch) then
                            Update(moveInput)
                        end
                    end)
                end
            end)
        end

        function Tab:AddDropdown(text, options, callback)
            local Dropped = false
            local Selected = options[1] or "None"
            
            local DropFrame = Instance.new("Frame")
            DropFrame.Size = UDim2.new(1, 0, 0, 34)
            DropFrame.BackgroundColor3 = Theme.Item
            DropFrame.ClipsDescendants = true
            DropFrame.Parent = Page
            
            local DCorner = Instance.new("UICorner")
            DCorner.CornerRadius = UDim.new(0, 4)
            DCorner.Parent = DropFrame
            
            local HeaderBtn = Instance.new("TextButton")
            HeaderBtn.Size = UDim2.new(1, 0, 0, 34)
            HeaderBtn.BackgroundTransparency = 1
            HeaderBtn.Text = ""
            HeaderBtn.Parent = DropFrame
            
            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(1, -30, 1, 0)
            Label.Position = UDim2.new(0, 10, 0, 0)
            Label.BackgroundTransparency = 1
            Label.Text = text .. ": " .. Selected
            Label.TextColor3 = Theme.Text
            Label.Font = Enum.Font.Gotham
            Label.TextSize = 13
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = DropFrame
            
            local Icon = Instance.new("TextLabel")
            Icon.Size = UDim2.new(0, 30, 0, 34)
            Icon.Position = UDim2.new(1, -30, 0, 0)
            Icon.BackgroundTransparency = 1
            Icon.Text = "+"
            Icon.TextColor3 = Theme.TextDim
            Icon.Font = Enum.Font.GothamMedium
            Icon.TextSize = 16
            Icon.Parent = DropFrame
            
            local List = Instance.new("Frame")
            List.Size = UDim2.new(1, 0, 0, 0)
            List.Position = UDim2.new(0, 0, 0, 34)
            List.BackgroundTransparency = 1
            List.Parent = DropFrame
            
            local ListLayout = Instance.new("UIListLayout")
            ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
            ListLayout.Parent = List
            
            local function Refresh()
                for _, v in pairs(List:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
                for _, opt in ipairs(options) do
                    local OptBtn = Instance.new("TextButton")
                    OptBtn.Size = UDim2.new(1, 0, 0, 30)
                    OptBtn.BackgroundColor3 = Theme.Section
                    OptBtn.BorderSizePixel = 0
                    OptBtn.Text = "  " .. opt
                    OptBtn.TextColor3 = Theme.TextDim
                    OptBtn.Font = Enum.Font.Gotham
                    OptBtn.TextSize = 12
                    OptBtn.TextXAlignment = Enum.TextXAlignment.Left
                    OptBtn.Parent = List
                    
                    OptBtn.MouseButton1Click:Connect(function()
                        Selected = opt
                        Label.Text = text .. ": " .. Selected
                        Dropped = false
                        Icon.Text = "+"
                        Icon.TextColor3 = Theme.TextDim
                        CreateTween(DropFrame, {Size = UDim2.new(1, 0, 0, 34)})
                        pcall(callback, opt)
                    end)
                end
            end
            
            Refresh()
            
            HeaderBtn.MouseButton1Click:Connect(function()
                Dropped = not Dropped
                Icon.Text = Dropped and "-" or "+"
                Icon.TextColor3 = Dropped and Library.Accent or Theme.TextDim
                local contentSize = #options * 30
                CreateTween(DropFrame, {Size = UDim2.new(1, 0, 0, Dropped and (34 + contentSize) or 34)})
            end)
        end

        function Tab:AddChipSet(text, options, callback)
            local ChipFrame = Instance.new("Frame")
            ChipFrame.Size = UDim2.new(1, 0, 0, 60)
            ChipFrame.BackgroundColor3 = Theme.Item
            ChipFrame.Parent = Page
            
            local CCorner = Instance.new("UICorner")
            CCorner.CornerRadius = UDim.new(0, 4)
            CCorner.Parent = ChipFrame
            
            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(1, -10, 0, 20)
            Label.Position = UDim2.new(0, 10, 0, 4)
            Label.BackgroundTransparency = 1
            Label.Text = text
            Label.TextColor3 = Theme.Text
            Label.Font = Enum.Font.Gotham
            Label.TextSize = 12
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = ChipFrame
            
            local Scroll = Instance.new("ScrollingFrame")
            Scroll.Size = UDim2.new(1, -10, 0, 30)
            Scroll.Position = UDim2.new(0, 5, 0, 26)
            Scroll.BackgroundTransparency = 1
            Scroll.ScrollBarThickness = 0
            Scroll.CanvasSize = UDim2.new(0, #options * 75, 0, 0)
            Scroll.Parent = ChipFrame
            
            local Layout = Instance.new("UIListLayout")
            Layout.FillDirection = Enum.FillDirection.Horizontal
            Layout.SortOrder = Enum.SortOrder.LayoutOrder
            Layout.Padding = UDim.new(0, 5)
            Layout.Parent = Scroll
            
            for _, opt in ipairs(options) do
                local Chip = Instance.new("TextButton")
                Chip.Size = UDim2.new(0, 70, 1, 0)
                Chip.BackgroundColor3 = Theme.Section
                Chip.Text = opt
                Chip.TextColor3 = Theme.TextDim
                Chip.Font = Enum.Font.Gotham
                Chip.TextSize = 11
                Chip.Parent = Scroll
                
                local ChCorner = Instance.new("UICorner")
                ChCorner.CornerRadius = UDim.new(0, 12)
                ChCorner.Parent = Chip
                
                Chip.MouseButton1Click:Connect(function()
                   for _, c in pairs(Scroll:GetChildren()) do
                       if c:IsA("TextButton") then
                           CreateTween(c, {BackgroundColor3 = Theme.Section, TextColor3 = Theme.TextDim})
                       end
                   end
                   CreateTween(Chip, {BackgroundColor3 = Library.Accent, TextColor3 = Theme.Text})
                   pcall(callback, opt)
                end)
            end
        end

        function Tab:AddKeybind(text, default, callback)
            local Key = default or Enum.KeyCode.RightShift
            local BindFrame = Instance.new("Frame")
            BindFrame.Size = UDim2.new(1, 0, 0, 34)
            BindFrame.BackgroundColor3 = Theme.Item
            BindFrame.Parent = Page
            
            local BCorner = Instance.new("UICorner")
            BCorner.CornerRadius = UDim.new(0, 4)
            BCorner.Parent = BindFrame
            
            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(1, -10, 1, 0)
            Label.Position = UDim2.new(0, 10, 0, 0)
            Label.BackgroundTransparency = 1
            Label.Text = text
            Label.TextColor3 = Theme.Text
            Label.Font = Enum.Font.Gotham
            Label.TextSize = 13
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = BindFrame
            
            local BindBtn = Instance.new("TextButton")
            BindBtn.Size = UDim2.new(0, 80, 0, 24)
            BindBtn.Position = UDim2.new(1, -90, 0.5, -12)
            BindBtn.BackgroundColor3 = Theme.Section
            BindBtn.Text = Key.Name
            BindBtn.TextColor3 = Theme.TextDim
            BindBtn.Font = Enum.Font.Gotham
            BindBtn.TextSize = 11
            BindBtn.Parent = BindFrame
            
            local BtnCorner = Instance.new("UICorner")
            BtnCorner.CornerRadius = UDim.new(0, 4)
            BtnCorner.Parent = BindBtn
            
            local Listening = false
            
            BindBtn.MouseButton1Click:Connect(function()
                Listening = true
                BindBtn.Text = "..."
                BindBtn.TextColor3 = Library.Accent
                
                local conn
                conn = UserInputService.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.Keyboard then
                        Key = input.KeyCode
                        BindBtn.Text = Key.Name
                        BindBtn.TextColor3 = Theme.TextDim
                        Listening = false
                        conn:Disconnect()
                    end
                end)
            end)
            
            UserInputService.InputBegan:Connect(function(input, gp)
                if not gp and not Listening and input.KeyCode == Key then
                    pcall(callback)
                end
            end)
        end

        return Tab
    end
    return Window
end

return Library
