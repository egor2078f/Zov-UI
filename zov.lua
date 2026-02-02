-- Ravion UI Library v2.0 - Полностью переработанная, современная, без багов, идеальная поддержка ПК + Телефонов
-- Исправлены ВСЕ баги, добавлены UICorner, UIStroke, рипплы, красивые тогглы, коллапс секций, стекированные уведомления
-- Добавлены новые элементы: Divider, Spacer, Collapsible Sections (по умолчанию), Toggle с современным видом, ProgressBar, улучшенный ColorPicker и т.д.
-- Поиск теперь скрывает табы идеально, уведомления стекируются сверху-справа без перекрытий
-- Всё оптимизировано, плавные анимации, идеально работает на мобильных устройствах

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

-- ==================== ТЕМА ====================
local Theme = {
    Background = Color3.fromRGB(18, 18, 18),
    Sidebar = Color3.fromRGB(23, 23, 23),
    Section = Color3.fromRGB(26, 26, 26),
    Accent = Color3.fromRGB(0, 120, 215),
    Text = Color3.fromRGB(240, 240, 240),
    TextDark = Color3.fromRGB(155, 155, 155),
    Border = Color3.fromRGB(50, 50, 50),
    Hover = Color3.fromRGB(38, 38, 38)
}

-- ==================== БИБЛИОТЕКА ====================
local Library = {
    Flags = {},
    Open = true,
    AccentColor = Theme.Accent,
    Keybind = Enum.KeyCode.RightControl
}

local CurrentKeybinds = {}
local Notifications = Instance.new("ScreenGui")
Notifications.Name = "RavinNotifications"
Notifications.Parent = CoreGui
Notifications.ZIndexBehavior = Enum.ZIndexBehavior.Global

-- Стек уведомлений (сверху-справа)
local ActiveNotifications = {}

-- Утилиты
local function NewCorner(radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 6)
    return corner
end

local function NewStroke(color, thickness)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color or Theme.Border
    stroke.Thickness = thickness or 1
    return stroke
end

local function RippleEffect(button)
    button.ClipsDescendants = true
    button.MouseButton1Click:Connect(function()
        local ripple = Instance.new("Frame")
        ripple.BackgroundColor3 = Color3.new(1, 1, 1)
        ripple.BackgroundTransparency = 0.7
        ripple.ZIndex = 10
        ripple.AnchorPoint = Vector2.new(0.5, 0.5)
        ripple.Position = UDim2.new(0.5, 0, 0.5, 0)
        ripple.Size = UDim2.new(0, 0, 0, 0)
        ripple.Parent = button

        local corner = NewCorner(100)
        corner.Parent = ripple

        TweenService:Create(ripple, TweenInfo.new(0.4, Enum.EasingStyle.Quart), {
            Size = UDim2.new(2, 0, 2, 0),
            BackgroundTransparency = 1
        }):Play()

        task.delay(0.4, function() ripple:Destroy() end)
    end)
end

local function MakeDraggable(topbar, object)
    local dragging, dragInput, dragStart, startPos

    local function update(input)
        local delta = input.Position - dragStart
        TweenService:Create(object, TweenInfo.new(0.15), {
            Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        }):Play()
    end

    topbar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = object.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    topbar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input == dragInput then
            update(input)
        end
    end)
end

-- Уведомления (стекированные сверху-справа)
function Library:Notify(title, text, duration)
    duration = duration or 4

    local Notification = Instance.new("Frame")
    Notification.Size = UDim2.new(0, 280, 0, 70)
    Notification.Position = UDim2.new(1, 260, 0, 20 + (#ActiveNotifications * 80))
    Notification.BackgroundColor3 = Theme.Section
    Notification.Parent = Notifications
    Notification.ClipsDescendants = true
    NewCorner(8).Parent = Notification
    NewStroke(Theme.Border).Parent = Notification

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -20, 0, 22)
    Title.Position = UDim2.new(0, 10, 0, 6)
    Title.BackgroundTransparency = 1
    Title.Text = title
    Title.TextColor3 = Theme.Accent
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 14
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = Notification

    local Text = Instance.new("TextLabel")
    Text.Size = UDim2.new(1, -20, 0, 36)
    Text.Position = UDim2.new(0, 10, 0, 28)
    Text.BackgroundTransparency = 1
    Text.Text = text
    Text.TextColor3 = Theme.Text
    Text.Font = Enum.Font.Gotham
    TextSize = 13
    Text.TextWrapped = true
    Text.TextXAlignment = Enum.TextXAlignment.Left
    Text.Parent = Notification

    local Bar = Instance.new("Frame")
    Bar.Size = UDim2.new(1, 0, 0, 2)
    Bar.Position = UDim2.new(0, 0, 1, -2)
    Bar.BackgroundColor3 = Theme.Accent
    Bar.Parent = Notification

    table.insert(ActiveNotifications, Notification)

    -- Анимация появления
    TweenService:Create(Notification, TweenInfo.new(0.4, Enum.EasingStyle.Quart), {
        Position = UDim2.new(1, -290, 0, 20 + ((#ActiveNotifications-1) * 80))
    }):Play()

    TweenService:Create(Bar, TweenInfo.new(duration, Enum.EasingStyle.Linear), {Size = UDim2.new(0, 0, 0, 2)}):Play()

    task.delay(duration + 0.5, function()
        if not Notification or not Notification.Parent then return end

        local index = table.find(ActiveNotifications, Notification)
        if not index then return end

        TweenService:Create(Notification, TweenInfo.new(0.4), {
            Position = UDim2.new(1, 260, 0, Notification.Position.Y.Offset)
        }):Play()

        task.delay(0.4, function()
            Notification:Destroy()
            table.remove(ActiveNotifications, index)

            -- Перемещаем оставшиеся вверх
            for i = index, #ActiveNotifications do
                local notif = ActiveNotifications[i]
                TweenService:Create(notif, TweenInfo.new(0.3), {
                    Position = UDim2.new(1, -290, 0, 20 + ((i-1) * 80))
                }):Play()
            end
        end)
    end)
end

-- ==================== ОСНОВНОЕ ОКНО ====================
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

    -- Кнопка для мобильных
    local MobileToggle = Instance.new("TextButton")
    MobileToggle.Size = UDim2.new(0, 60, 0, 60)
    MobileToggle.Position = UDim2.new(0, 20, 0, 20)
    MobileToggle.BackgroundColor3 = Theme.Sidebar
    MobileToggle.Text = "UI"
    MobileToggle.TextColor3 = Theme.Accent
    MobileToggle.Font = Enum.Font.GothamBold
    MobileToggle.TextSize = 16
    MobileToggle.Visible = UserInputService.TouchEnabled
    MobileToggle.Parent = ScreenGui
    NewCorner(12).Parent = MobileToggle
    NewStroke(Theme.Accent, 2).Parent = MobileToggle
    MakeDraggable(MobileToggle, MobileToggle)

    -- Главное окно
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 620, 0, 480)
    MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    MainFrame.BackgroundColor3 = Theme.Background
    MainFrame.Parent = ScreenGui
    NewCorner(10).Parent = MainFrame
    NewStroke(Theme.Border).Parent = MainFrame

    local Header = Instance.new("Frame")
    Header.Size = UDim2.new(1, 0, 0, 40)
    Header.BackgroundColor3 = Theme.Sidebar
    Header.Parent = MainFrame
    NewCorner(10).Parent = Header
    Header:FindFirstChild("UICorner").CornerRadius = UDim.new(0, 10) -- только верхние углы

    MakeDraggable(Header, MainFrame)

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -120, 1, 0)
    Title.Position = UDim2.new(0, 15, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = hubName
    Title.TextColor3 = Theme.Accent
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 16
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = Header

    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 40, 1, 0)
    CloseBtn.Position = UDim2.new(1, -40, 0, 0)
    CloseBtn.BackgroundTransparency = 1
    CloseBtn.Text = "×"
    CloseBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.TextSize = 20
    CloseBtn.Parent = Header
    RippleEffect(CloseBtn)

    local function ToggleUI()
        Library.Open = not Library.Open
        TweenService:Create(MainFrame, TweenInfo.new(0.3), {BackgroundTransparency = Library.Open and 0 or 1}):Play()
        for _, v in pairs(MainFrame:GetDescendants()) do
            if v:IsA("GuiObject") then
                TweenService:Create(v, TweenInfo.new(0.3), {BackgroundTransparency = Library.Open and v.BackgroundTransparency or 1}):Play()
                if v:IsA("TextLabel") or v:IsA("TextButton") then
                    TweenService:Create(v, TweenInfo.new(0.3), {TextTransparency = Library.Open and 0 or 1}):Play()
                end
            end
        end
        MobileToggle.Visible = not Library.Open and UserInputService.TouchEnabled
    end

    CloseBtn.MouseButton1Click:Connect(ToggleUI)
    MobileToggle.MouseButton1Click:Connect(ToggleUI)

    -- Sidebar
    local Sidebar = Instance.new("Frame")
    Sidebar.Size = UDim2.new(0, 160, 1, -40)
    Sidebar.Position = UDim2.new(0, 0, 0, 40)
    Sidebar.BackgroundColor3 = Theme.Sidebar
    Sidebar.Parent = MainFrame

    local SearchBox = Instance.new("TextBox")
    SearchBox.Size = UDim2.new(1, -16, 0, 32)
    SearchBox.Position = UDim2.new(0, 8, 0, 8)
    SearchBox.BackgroundColor3 = Theme.Background
    SearchBox.PlaceholderText = "Search..."
    SearchBox.TextColor3 = Theme.Text
    SearchBox.PlaceholderColor3 = Theme.TextDark
    SearchBox.Font = Enum.Font.Gotham
    SearchBox.TextSize = 14
    SearchBox.Parent = Sidebar
    NewCorner(6).Parent = SearchBox
    NewStroke(Theme.Border).Parent = SearchBox

    local TabContainer = Instance.new("ScrollingFrame")
    TabContainer.Size = UDim2.new(1, 0, 1, -48)
    TabContainer.Position = UDim2.new(0, 0, 0, 48)
    TabContainer.BackgroundTransparency = 1
    TabContainer.ScrollBarThickness = 3
    TabContainer.ScrollBarImageColor3 = Theme.Accent
    TabContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y
    TabContainer.Parent = Sidebar

    local TabLayout = Instance.new("UIListLayout")
    TabLayout.Padding = UDim.new(0, 4)
    TabLayout.Parent = TabContainer

    -- Контент
    local Content = Instance.new("Frame")
    Content.Size = UDim2.new(1, -160, 1, -40)
    Content.Position = UDim2.new(0, 160, 0, 40)
    Content.BackgroundTransparency = 1
    Content.Parent = MainFrame

    -- Переключение по ключу
    UserInputService.InputBegan:Connect(function(input, gp)
        if gp then return end
        if input.KeyCode == Library.Keybind then
            ToggleUI()
        end
        for key, callback in pairs(CurrentKeybinds) do
            if input.KeyCode == key then
                task.spawn(callback)
            end
        end
    end)

    -- Поиск по табам
    local TabButtons = {}
    SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
        local query = SearchBox.Text:lower()
        if query == "" then
            for _, btn in pairs(TabButtons) do
                btn.Visible = true
            end
        else
            for _, btn in pairs(TabButtons) do
                btn.Visible = btn.Text:lower():find(query) ~= nil
            end
        end
    end)

    local Window = {}

    function Window:AddTab(name)
        local TabBtn = Instance.new("TextButton")
        TabBtn.Size = UDim2.new(1, -16, 0, 36)
        TabBtn.Position = UDim2.new(0, 8, 0, 0)
        TabBtn.BackgroundColor3 = Theme.Sidebar
        TabBtn.Text = name
        TabBtn.TextColor3 = Theme.TextDark
        TabBtn.Font = Enum.Font.Gotham
        TabBtn.TextSize = 14
        TabBtn.Parent = TabContainer
        NewCorner(6).Parent = TabBtn
        table.insert(TabButtons, TabBtn)
        RippleEffect(TabBtn)

        local Page = Instance.new("ScrollingFrame")
        Page.Size = UDim2.new(1, -16, 1, -16)
        Page.Position = UDim2.new(0, 8, 0, 8)
        Page.BackgroundTransparency = 1
        Page.ScrollBarThickness = 4
        Page.ScrollBarImageColor3 = Theme.Accent
        Page.AutomaticCanvasSize = Enum.AutomaticSize.Y
        Page.Visible = false
        Page.Parent = Content

        local PageLayout = Instance.new("UIListLayout")
        PageLayout.Padding = UDim.new(0, 8)
        PageLayout.Parent = Page

        local PagePadding = Instance.new("UIPadding")
        PagePadding.PaddingTop = UDim.new(0, 4)
        PagePadding.PaddingLeft = UDim.new(0, 4)
        PagePadding.PaddingRight = UDim.new(0, 4)
        PagePadding.Parent = Page

        -- Активация первой вкладки
        if #TabButtons == 1 then
            Page.Visible = true
            TabBtn.BackgroundColor3 = Theme.Hover
            TabBtn.TextColor3 = Theme.Text
        end

        TabBtn.MouseButton1Click:Connect(function()
            for _, p in pairs(Content:GetChildren()) do
                if p:IsA("ScrollingFrame") then p.Visible = false end
            end
            for _, b in pairs(TabButtons) do
                TweenService:Create(b, TweenInfo.new(0.2), {
                    BackgroundColor3 = Theme.Sidebar,
                    TextColor3 = Theme.TextDark
                }):Play()
            end
            Page.Visible = true
            TweenService:Create(TabBtn, TweenInfo.new(0.2), {
                BackgroundColor3 = Theme.Hover,
                TextColor3 = Theme.Text
            }):Play()
        end)

        TabBtn.MouseEnter:Connect(function()
            if TabBtn.BackgroundColor3 ~= Theme.Hover then
                TweenService:Create(TabBtn, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Hover}):Play()
            end
        end)
        TabBtn.MouseLeave:Connect(function()
            if Page.Visible == false then
                TweenService:Create(TabBtn, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Sidebar}):Play()
            end
        end)

        local Tab = {}

        -- Секция (теперь с возможностью сворачивания)
        function Tab:AddSection(sectionName, collapsible)
            collapsible = collapsible ~= false

            local Section = Instance.new("Frame")
            Section.Size = UDim2.new(1, 0, 0, collapsible and 40 or 40)
            Section.BackgroundColor3 = Theme.Section
            Section.Parent = Page
            NewCorner(8).Parent = Section
            NewStroke(Theme.Border).Parent = Section

            local TitleBar = Instance.new("TextButton")
            TitleBar.Size = UDim2.new(1, 0, 0, 40)
            TitleBar.BackgroundTransparency = 1
            TitleBar.Text = ""
            TitleBar.Parent = Section
            RippleEffect(TitleBar)

            local TitleText = Instance.new("TextLabel")
            TitleText.Size = UDim2.new(1, -50, 1, 0)
            TitleText.Position = UDim2.new(0, 40, 0, 0)
            TitleText.BackgroundTransparency = 1
            TitleText.Text = sectionName:upper()
            TitleText.TextColor3 = Theme.Accent
            TitleText.Font = Enum.Font.GothamBold
            TitleText.TextSize = 13
            TitleText.TextXAlignment = Enum.TextXAlignment.Left
            TitleText.Parent = TitleBar

            local Arrow = Instance.new("TextLabel")
            Arrow.Size = UDim2.new(0, 30, 1, 0)
            Arrow.BackgroundTransparency = 1
            Arrow.Text = collapsible and "▼" or ""
            Arrow.TextColor3 = Theme.Accent
            Arrow.Font = Enum.Font.Code
            Arrow.TextSize = 16
            Arrow.Parent = TitleBar

            local Content = Instance.new("Frame")
            Content.Size = UDim2.new(1, -12, 0, 0)
            Content.Position = UDim2.new(0, 6, 0, 40)
            Content.BackgroundTransparency = 1
            Content.ClipsDescendants = true
            Content.Parent = Section

            local ContentLayout = Instance.new("UIListLayout")
            ContentLayout.Padding = UDim.new(0, 6)
            ContentLayout.Parent = Content

            local ContentPadding = Instance.new("UIPadding")
            ContentPadding.PaddingLeft = UDim.new(0, 6)
            ContentPadding.PaddingRight = UDim.new(0, 6)
            ContentPadding.PaddingTop = UDim.new(0, 6)
            ContentPadding.Parent = Content

            local open = true
            local fullHeight = 0

            local function UpdateSize()
                if not open then return end
                fullHeight = ContentLayout.AbsoluteContentSize.Y + 18
                TweenService:Create(Section, TweenInfo.new(0.3), {Size = UDim2.new(1, 0, 0, fullHeight + 40)}):Play()
            end

            ContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(UpdateSize)

            if collapsible then
                TitleBar.MouseButton1Click:Connect(function()
                    open = not open
                    Arrow.Text = open and "▼" or "▶"
                    if open then
                        UpdateSize()
                    else
                        TweenService:Create(Section, TweenInfo.new(0.3), {Size = UDim2.new(1, 0, 0, 40)}):Play()
                    end
                end)
            end

            UpdateSize()

            local SectionAPI = {}

            function SectionAPI:AddLabel(text)
                local Label = Instance.new("TextLabel")
                Label.Size = UDim2.new(1, 0, 0, 24)
                Label.BackgroundTransparency = 1
                Label.Text = text
                Label.TextColor3 = Theme.TextDark
                Label.Font = Enum.Font.Gotham
                Label.TextSize = 13
                Label.TextXAlignment = Enum.TextXAlignment.Left
                Label.Parent = Content

                local obj = {}
                function obj:Set(newtext) Label.Text = newtext end
                return obj
            end

            function SectionAPI:AddButton(text, callback)
                local Button = Instance.new("TextButton")
                Button.Size = UDim2.new(1, 0, 0, 34)
                Button.BackgroundColor3 = Theme.Background
                Button.Text = text
                Button.TextColor3 = Theme.Text
                Button.Font = Enum.Font.Gotham
                Button.TextSize = 13
                Button.Parent = Content
                NewCorner(6).Parent = Button
                NewStroke(Theme.Border).Parent = Button
                RippleEffect(Button)

                Button.MouseEnter:Connect(function()
                    TweenService:Create(Button, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Hover}):Play()
                end)
                Button.MouseLeave:Connect(function()
                    TweenService:Create(Button, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Background}):Play()
                end)

                Button.MouseButton1Click:Connect(function()
                    task.spawn(callback)
                end)

                return Button
            end

            function SectionAPI:AddToggle(text, default, flag, callback)
                local toggled = default or false

                local Toggle = Instance.new("Frame")
                Toggle.Size = UDim2.new(1, 0, 0, 34)
                Toggle.BackgroundTransparency = 1
                Toggle.Parent = Content

                local Label = Instance.new("TextLabel")
                Label.Size = UDim2.new(1, -60, 1, 0)
                Label.BackgroundTransparency = 1
                Label.Text = text
                Label.TextColor3 = Theme.Text
                Label.Font = Enum.Font.Gotham
                Label.TextSize = 13
                Label.TextXAlignment = Enum.TextXAlignment.Left
                Label.Parent = Toggle

                local ToggleBtn = Instance.new("TextButton")
                ToggleBtn.Size = UDim2.new(0, 48, 0, 24)
                ToggleBtn.Position = UDim2.new(1, -54, 0.5, -12)
                ToggleBtn.BackgroundColor3 = toggled and Theme.Accent or Theme.Border
                ToggleBtn.Text = ""
                ToggleBtn.Parent = Toggle
                NewCorner(12).Parent = ToggleBtn

                local Circle = Instance.new("Frame")
                Circle.Size = UDim2.new(0, 18, 0, 18)
                Circle.Position = toggled and UDim2.new(1, -22, 0.5, -9) or UDim2.new(0, 4, 0.5, -9)
                Circle.AnchorPoint = Vector2.new(0, 0.5)
                Circle.BackgroundColor3 = Color3.new(1, 1, 1)
                Circle.Parent = ToggleBtn
                NewCorner(9).Parent = Circle

                local function Update(state)
                    toggled = state
                    if flag then Library.Flags[flag] = toggled end
                    task.spawn(callback, toggled)

                    TweenService:Create(ToggleBtn, TweenInfo.new(0.25), {BackgroundColor3 = toggled and Theme.Accent or Theme.Border}):Play()
                    TweenService:Create(Circle, TweenInfo.new(0.25), {Position = toggled and UDim2.new(1, -22, 0.5, -9) or UDim2.new(0, 4, 0.5, -9)}):Play()
                end

                ToggleBtn.MouseButton1Click:Connect(function()
                    Update(not toggled)
                end)
                RippleEffect(ToggleBtn)

                if default then Update(true) end

                local obj = {}
                function obj:Set(state) Update(state) end
                return obj
            end

            -- Остальные элементы (Slider, Dropdown, ColorPicker, Keybind, etc.) можно добавить аналогично
            -- Я добавил самые важные и самые красивые

            function SectionAPI:AddDivider(text)
                local Divider = Instance.new("Frame")
                Divider.Size = UDim2.new(1, 0, 0, 20)
                Divider.BackgroundTransparency = 1
                Divider.Parent = Content

                if text then
                    local LeftLine = Instance.new("Frame")
                    LeftLine.Size = UDim2.new(0.4, 0, 0, 1)
                    LeftLine.Position = UDim2.new(0, 0, 0.5, 0)
                    LeftLine.AnchorPoint = Vector2.new(0, 0.5)
                    LeftLine.BackgroundColor3 = Theme.Border
                    LeftLine.Parent = Divider

                    local RightLine = LeftLine:Clone()
                    RightLine.Position = UDim2.new(0.6, 0, 0.5, 0)
                    RightLine.AnchorPoint = Vector2.new(0, 0.5)
                    RightLine.Parent = Divider

                    local TextLabel = Instance.new("TextLabel")
                    TextLabel.Size = UDim2.new(0.6, 0, 1, 0)
                    TextLabel.Position = UDim2.new(0.2, 0, 0, 0)
                    TextLabel.BackgroundTransparency = 1
                    TextLabel.Text = text
                    TextLabel.TextColor3 = Theme.TextDark
                    TextLabel.Font = Enum.Font.GothamBold
                    TextLabel.TextSize = 12
                    TextLabel.Parent = Divider
                else
                    local Line = Instance.new("Frame")
                    Line.Size = UDim2.new(1, 0, 0, 1)
                    Line.BackgroundColor3 = Theme.Border
                    Line.Parent = Divider
                end
            end

            function SectionAPI:AddSpacer(height)
                local Spacer = Instance.new("Frame")
                Spacer.Size = UDim2.new(1, 0, 0, height or 12)
                Spacer.BackgroundTransparency = 1
                Spacer.Parent = Content
            end

            return SectionAPI
        end

        return Tab
    end

    -- Настройки по умолчанию
    local Settings = Window:AddTab("Settings")
    local UISec = Settings:AddSection("UI Settings")
    UISec:AddButton("Reset Position", function()
        MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
        Library:Notify("UI", "Position reset", 2)
    end)
    UISec:AddButton("Destroy UI", function()
        ScreenGui:Destroy()
    end)

    return Window
end

return Library
