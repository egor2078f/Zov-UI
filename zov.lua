--[[ 
    RAVION HUB UI LIBRARY - V2.0 (Mobile Support + New Elements)
    Style: Strict, Compact, Modular
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local Theme = {
	Background = Color3.fromRGB(20, 20, 20),
	Sidebar = Color3.fromRGB(25, 25, 25),
	Section = Color3.fromRGB(28, 28, 28),
	Text = Color3.fromRGB(240, 240, 240),
	TextDark = Color3.fromRGB(150, 150, 150),
	Accent = Color3.fromRGB(0, 122, 204), -- VS Code Blue
	Border = Color3.fromRGB(45, 45, 45),
	Hover = Color3.fromRGB(35, 35, 35)
}

local Library = {}
local CurrentKeybinds = {}

-- Улучшенная функция Draggable для PC и Mobile
local function MakeDraggable(topbarobject, object)
	local Dragging = nil
	local DragInput = nil
	local DragStart = nil
	local StartPosition = nil

	local function Update(input)
		local Delta = input.Position - DragStart
		local pos = UDim2.new(StartPosition.X.Scale, StartPosition.X.Offset + Delta.X, StartPosition.Y.Scale, StartPosition.Y.Offset + Delta.Y)
		object.Position = pos
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

function Library:CreateWindow(hubName, toggleKey)
	local KEY = toggleKey or Enum.KeyCode.RightControl

	if LocalPlayer.PlayerGui:FindFirstChild("RavionUI") then
		LocalPlayer.PlayerGui.RavionUI:Destroy()
	end

	local ScreenGui = Instance.new("ScreenGui")
	ScreenGui.Name = "RavionUI"
	ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
	ScreenGui.ResetOnSpawn = false
	ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global -- Важно для Dropdown

	-- === Кнопка открытия для телефонов ===
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
	OpenBtn.Visible = false -- Скрыта по умолчанию, покажем если это телефон или по желанию

	-- Простая проверка на мобильное устройство (можно улучшить)
	if UserInputService.TouchEnabled and not UserInputService.MouseEnabled then
		OpenBtn.Visible = true
	end
	
	MakeDraggable(OpenBtn, OpenBtn) -- Чтобы кнопку можно было двигать

	local MainFrame = Instance.new("Frame")
	MainFrame.Name = "MainFrame"
	MainFrame.Size = UDim2.new(0, 480, 0, 350) -- Чуть шире для телефонов
	MainFrame.AnchorPoint = Vector2.new(0.5, 0.5) -- Центрирование
	MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
	MainFrame.BackgroundColor3 = Theme.Background
	MainFrame.BorderColor3 = Theme.Border
	MainFrame.BorderSizePixel = 1
	MainFrame.Parent = ScreenGui

	-- Header
	local Header = Instance.new("Frame")
	Header.Name = "Header"
	Header.Size = UDim2.new(1, 0, 0, 30) -- Чуть выше, чтобы пальцем было удобно попасть
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
	Title.TextSize = 16
	Title.Font = Enum.Font.Code
	Title.TextXAlignment = Enum.TextXAlignment.Left
	Title.Parent = Header

	-- Close Button (X)
	local CloseBtn = Instance.new("TextButton")
	CloseBtn.Size = UDim2.new(0, 30, 1, 0)
	CloseBtn.Position = UDim2.new(1, -30, 0, 0)
	CloseBtn.BackgroundTransparency = 1
	CloseBtn.Text = "X"
	CloseBtn.TextColor3 = Theme.TextDark
	CloseBtn.Font = Enum.Font.GothamBold
	CloseBtn.TextSize = 14
	CloseBtn.Parent = Header
	
	CloseBtn.MouseButton1Click:Connect(function()
		MainFrame.Visible = false
		OpenBtn.Visible = true
	end)

	OpenBtn.MouseButton1Click:Connect(function()
		MainFrame.Visible = not MainFrame.Visible
	end)

	-- Sidebar
	local Sidebar = Instance.new("ScrollingFrame")
	Sidebar.Size = UDim2.new(0, 120, 1, -31)
	Sidebar.Position = UDim2.new(0, 0, 0, 31)
	Sidebar.BackgroundColor3 = Theme.Sidebar
	Sidebar.BorderColor3 = Theme.Border
	Sidebar.BorderSizePixel = 1
	Sidebar.ScrollBarThickness = 2
	Sidebar.ScrollBarImageColor3 = Theme.Accent
	Sidebar.Parent = MainFrame

	local SidebarLayout = Instance.new("UIListLayout")
	SidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
	SidebarLayout.Parent = Sidebar

	-- Content Area
	local ContentArea = Instance.new("Frame")
	ContentArea.Size = UDim2.new(1, -122, 1, -31)
	ContentArea.Position = UDim2.new(0, 122, 0, 31)
	ContentArea.BackgroundTransparency = 1
	ContentArea.ClipsDescendants = true
	ContentArea.Parent = MainFrame

	-- Toggle Menu Key (PC)
	UserInputService.InputBegan:Connect(function(input, gp)
		if gp then return end
		if input.KeyCode == KEY then
			MainFrame.Visible = not MainFrame.Visible
		end
	end)

	-- Keybind Listener
	UserInputService.InputBegan:Connect(function(input, gp)
		if gp or MainFrame.Visible then return end
		for key, callback in pairs(CurrentKeybinds) do
			if input.KeyCode == key then
				callback()
			end
		end
	end)

	local Window = {}
	local FirstTab = true

	function Window:AddTab(name)
		local TabBtn = Instance.new("TextButton")
		TabBtn.Size = UDim2.new(1, 0, 0, 32) -- Кнопки выше для удобства нажатия
		TabBtn.BackgroundColor3 = Theme.Sidebar
		TabBtn.Text = name
		TabBtn.TextColor3 = Theme.TextDark
		TabBtn.Font = Enum.Font.Gotham
		TabBtn.TextSize = 12
		TabBtn.BorderSizePixel = 0
		TabBtn.Parent = Sidebar

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
			SectionPad.PaddingTop = UDim.new(0, 26) -- Место под заголовок
			SectionPad.PaddingBottom = UDim.new(0, 6)
			SectionPad.PaddingLeft = UDim.new(0, 6)
			SectionPad.PaddingRight = UDim.new(0, 6)
			SectionPad.Parent = SectionContainer

			SectionLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
				SectionContainer.Size = UDim2.new(1, -4, 0, SectionLayout.AbsoluteContentSize.Y + 34)
			end)

			local Section = {}

			-- ELEMENT: LABEL
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
			end

			-- ELEMENT: BUTTON
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

			-- ELEMENT: TOGGLE
			function Section:AddToggle(toggleText, default, callback)
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

				ToggleFrame.MouseButton1Click:Connect(function()
					toggled = not toggled
					Indicator.Visible = toggled
					callback(toggled)
				end)
			end

			-- ELEMENT: SLIDER (Touch Friendly)
			function Section:AddSlider(text, minVal, maxVal, initialVal, step, callback)
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
				BarFrame.Size = UDim2.new(1, 0, 0, 10) -- Толще для пальцев
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

				local dragging = false
				local function updateValue(input)
					local barWidth = BarFrame.AbsoluteSize.X
					local pos = math.clamp(input.Position.X - BarFrame.AbsolutePosition.X, 0, barWidth)
					local newRatio = pos / barWidth
					local rawValue = minVal + newRatio * (maxVal - minVal)
					
					currentValue = math.floor(rawValue / step) * step
					currentValue = math.clamp(currentValue, minVal, maxVal)

					local currentRatio = (currentValue - minVal) / (maxVal - minVal)
					Fill.Size = UDim2.new(currentRatio, 0, 1, 0)
					Label.Text = text .. ": " .. tostring(currentValue)
					callback(currentValue)
				end

				BarFrame.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then 
						dragging = true; updateValue(input) 
					end
				end)
				
				UserInputService.InputChanged:Connect(function(input)
					if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
						updateValue(input)
					end
				end)
				
				UserInputService.InputEnded:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then 
						dragging = false 
					end
				end)
				
				callback(currentValue)
			end
			
			-- ELEMENT: TEXTBOX (NEW)
			function Section:AddTextbox(placeholder, callback)
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
				
				TextBox.FocusLost:Connect(function(enterPressed)
					callback(TextBox.Text)
				end)
			end
			
			-- ELEMENT: DROPDOWN
			function Section:AddDropdown(text, options, initialIndex, callback)
				local selectedIndex = initialIndex or 1
				local isExpanded = false

				local DropdownFrame = Instance.new("Frame")
				DropdownFrame.Size = UDim2.new(1, 0, 0, 26)
				DropdownFrame.BackgroundTransparency = 1
				DropdownFrame.ZIndex = 2
				DropdownFrame.Parent = SectionContainer

				local Label = Instance.new("TextLabel")
				Label.Size = UDim2.new(0.5, 0, 1, 0)
				Label.BackgroundTransparency = 1
				Label.Text = text
				Label.TextColor3 = Theme.Text
				Label.Font = Enum.Font.Gotham
				Label.TextSize = 12
				Label.TextXAlignment = Enum.TextXAlignment.Left
				Label.Parent = DropdownFrame

				local SelectButton = Instance.new("TextButton")
				SelectButton.Size = UDim2.new(0.5, 0, 1, 0)
				SelectButton.Position = UDim2.new(0.5, 0, 0, 0)
				SelectButton.BackgroundColor3 = Theme.Background
				SelectButton.BorderColor3 = Theme.Border
				SelectButton.BorderSizePixel = 1
				SelectButton.Text = options[selectedIndex] or "..."
				SelectButton.TextColor3 = Theme.Accent
				SelectButton.Font = Enum.Font.Gotham
				SelectButton.TextSize = 12
				SelectButton.Parent = DropdownFrame

				local DropdownList = Instance.new("Frame")
				DropdownList.Size = UDim2.new(0.5, 0, 0, #options * 24)
				DropdownList.Position = UDim2.new(0.5, 0, 1, 2)
				DropdownList.BackgroundColor3 = Theme.Section
				DropdownList.BorderColor3 = Theme.Border
				DropdownList.BorderSizePixel = 1
				DropdownList.Visible = false
				DropdownList.ZIndex = 50 
				DropdownList.Parent = DropdownFrame

				local ListLayout = Instance.new("UIListLayout")
				ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
				ListLayout.Parent = DropdownList

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
						selectedIndex = i
						SelectButton.Text = options[selectedIndex]
						DropdownList.Visible = false
						isExpanded = false
						DropdownFrame.Size = UDim2.new(1, 0, 0, 26)
						callback(option, selectedIndex)
					end)
				end

				SelectButton.MouseButton1Click:Connect(function()
					isExpanded = not isExpanded
					DropdownList.Visible = isExpanded
					if isExpanded then
						DropdownFrame.Size = UDim2.new(1, 0, 0, 26 + (#options * 24) + 4)
					else
						DropdownFrame.Size = UDim2.new(1, 0, 0, 26)
					end
				end)
			end

			-- ELEMENT: KEYBIND
			function Section:AddKeybind(text, initialKey, callback)
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
				
				local isSetting = false

				KeybindBtn.MouseButton1Click:Connect(function()
					if isSetting then return end
					isSetting = true
					KeybindBtn.Text = "..."
					
					local con
					con = UserInputService.InputBegan:Connect(function(input, gp)
						if gp or input.UserInputType == Enum.UserInputType.MouseButton1 then return end
						CurrentKeybinds[currentKey] = nil
						currentKey = input.KeyCode
						CurrentKeybinds[currentKey] = callback
						KeybindBtn.Text = text .. ": [" .. currentKey.Name .. "]"
						isSetting = false
						con:Disconnect()
					end)
				end)
				CurrentKeybinds[currentKey] = callback
			end

			return Section
		end
		return Tab
	end
	return Window
end

return Library
