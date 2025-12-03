--[[ 
    RAVION HUB MOBILE V2 - SOURCE
    Upload this to GitHub
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local Theme = {
	Background = Color3.fromRGB(25, 25, 25),
	Header = Color3.fromRGB(30, 30, 30),
	Sidebar = Color3.fromRGB(32, 32, 32),
	Section = Color3.fromRGB(35, 35, 35),
	Text = Color3.fromRGB(255, 255, 255),
	TextDark = Color3.fromRGB(170, 170, 170),
	Accent = Color3.fromRGB(0, 140, 255), -- Яркий синий
	Border = Color3.fromRGB(50, 50, 50),
	Hover = Color3.fromRGB(45, 45, 45)
}

local Library = {}
local CurrentKeybinds = {}

-- === MOBILE DRAGGABLE FUNCTION === --
local function MakeDraggable(gui)
	local dragging
	local dragInput
	local dragStart
	local startPos

	local function update(input)
		local delta = input.Position - dragStart
		gui.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end

	gui.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = gui.Position

			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	gui.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			update(input)
		end
	end)
end

function Library:CreateWindow(hubName, toggleKey)
	local KEY = toggleKey or Enum.KeyCode.RightControl
	
	-- Защита от CoreGui (чтобы не видели в PlayerGui)
	local ParentTarget = game:GetService("CoreGui") -- Используем CoreGui для скрытности, если эксплойт позволяет
	pcall(function() 
	    if not ParentTarget:FindFirstChild("RobloxGui") then
	        ParentTarget = LocalPlayer.PlayerGui 
	    end
	end)

	if ParentTarget:FindFirstChild("RavionMobileUI") then
		ParentTarget.RavionMobileUI:Destroy()
	end

	local ScreenGui = Instance.new("ScreenGui")
	ScreenGui.Name = "RavionMobileUI"
	ScreenGui.Parent = ParentTarget
	ScreenGui.ResetOnSpawn = false
	
	-- NOTIFICATION CONTAINER
	local NotifyList = Instance.new("Frame")
	NotifyList.Name = "NotifyList"
	NotifyList.Size = UDim2.new(0, 200, 1, -20)
	NotifyList.Position = UDim2.new(1, -210, 0, 10)
	NotifyList.BackgroundTransparency = 1
	NotifyList.Parent = ScreenGui
	
	local NotifyLayout = Instance.new("UIListLayout")
	NotifyLayout.SortOrder = Enum.SortOrder.LayoutOrder
	NotifyLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
	NotifyLayout.Padding = UDim.new(0, 5)
	NotifyLayout.Parent = NotifyList

	-- MAIN FRAME
	local MainFrame = Instance.new("Frame")
	MainFrame.Name = "MainFrame"
	MainFrame.Size = UDim2.new(0, 480, 0, 320) -- Чуть шире для телефонов
	MainFrame.Position = UDim2.new(0.5, -240, 0.5, -160)
	MainFrame.BackgroundColor3 = Theme.Background
	MainFrame.BorderColor3 = Theme.Border
	MainFrame.BorderSizePixel = 1
	MainFrame.ClipsDescendants = true
	MainFrame.Parent = ScreenGui
	
	-- ROUNDED CORNERS
	local UICorner = Instance.new("UICorner")
	UICorner.CornerRadius = UDim.new(0, 6)
	UICorner.Parent = MainFrame

	-- HEADER
	local Header = Instance.new("Frame")
	Header.Size = UDim2.new(1, 0, 0, 35)
	Header.BackgroundColor3 = Theme.Header
	Header.BorderSizePixel = 0
	Header.Parent = MainFrame
	
	local HeaderCorner = Instance.new("UICorner")
	HeaderCorner.CornerRadius = UDim.new(0, 6)
	HeaderCorner.Parent = Header
	
	-- Fix bottom corners of header needing to be flat
	local HeaderCover = Instance.new("Frame")
	HeaderCover.Size = UDim2.new(1, 0, 0, 10)
	HeaderCover.Position = UDim2.new(0,0,1,-10)
	HeaderCover.BackgroundColor3 = Theme.Header
	HeaderCover.BorderSizePixel = 0
	HeaderCover.Parent = Header

	local Title = Instance.new("TextLabel")
	Title.Size = UDim2.new(1, -20, 1, 0)
	Title.Position = UDim2.new(0, 15, 0, 0)
	Title.BackgroundTransparency = 1
	Title.Text = hubName
	Title.TextColor3 = Theme.Accent
	Title.Font = Enum.Font.GothamBold
	Title.TextSize = 16
	Title.TextXAlignment = Enum.TextXAlignment.Left
	Title.Parent = Header
	
	MakeDraggable(MainFrame) -- Делаем все окно перетаскиваемым

	-- MOBILE TOGGLE BUTTON (Кружок на экране)
	local ToggleBtn = Instance.new("ImageButton")
	ToggleBtn.Name = "MobileToggle"
	ToggleBtn.Size = UDim2.new(0, 50, 0, 50)
	ToggleBtn.Position = UDim2.new(0, 50, 0, 50) -- Слева сверху по дефолту
	ToggleBtn.BackgroundColor3 = Theme.Sidebar
	ToggleBtn.BorderColor3 = Theme.Accent
	ToggleBtn.BorderSizePixel = 2
	ToggleBtn.Parent = ScreenGui
	
	local ToggleCorner = Instance.new("UICorner")
	ToggleCorner.CornerRadius = UDim.new(1, 0) -- Круг
	ToggleCorner.Parent = ToggleBtn
	
	local ToggleIcon = Instance.new("ImageLabel")
	ToggleIcon.Size = UDim2.new(0, 30, 0, 30)
	ToggleIcon.Position = UDim2.new(0.5, -15, 0.5, -15)
	ToggleIcon.BackgroundTransparency = 1
	ToggleIcon.Image = "rbxassetid://3926305904" -- Иконка логотипа
	ToggleIcon.ImageColor3 = Theme.Accent
	ToggleIcon.Parent = ToggleBtn
	
	MakeDraggable(ToggleBtn) -- Кнопку тоже можно таскать!
	
	ToggleBtn.MouseButton1Click:Connect(function()
		MainFrame.Visible = not MainFrame.Visible
	end)

	-- SIDEBAR
	local Sidebar = Instance.new("ScrollingFrame")
	Sidebar.Size = UDim2.new(0, 120, 1, -35)
	Sidebar.Position = UDim2.new(0, 0, 0, 35)
	Sidebar.BackgroundColor3 = Theme.Sidebar
	Sidebar.BorderSizePixel = 0
	Sidebar.ScrollBarThickness = 0
	Sidebar.Parent = MainFrame
	
	local SidePad = Instance.new("UIPadding")
	SidePad.PaddingTop = UDim.new(0, 10)
	SidePad.Parent = Sidebar

	local SidebarLayout = Instance.new("UIListLayout")
	SidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
	SidebarLayout.Padding = UDim.new(0, 5)
	SidebarLayout.Parent = Sidebar

	-- CONTENT
	local ContentArea = Instance.new("Frame")
	ContentArea.Size = UDim2.new(1, -120, 1, -35)
	ContentArea.Position = UDim2.new(0, 120, 0, 35)
	ContentArea.BackgroundTransparency = 1
	ContentArea.Parent = MainFrame

	-- PC Toggle Key
	UserInputService.InputBegan:Connect(function(input, gp)
		if gp then return end
		if input.KeyCode == KEY then
			MainFrame.Visible = not MainFrame.Visible
		end
	end)

	-- NOTIFICATION FUNCTION
	function Library:Notify(title, text, duration)
		local NotifFrame = Instance.new("Frame")
		NotifFrame.Size = UDim2.new(1, 0, 0, 60)
		NotifFrame.BackgroundColor3 = Theme.Section
		NotifFrame.BorderColor3 = Theme.Accent
		NotifFrame.BorderSizePixel = 1
		NotifFrame.Parent = NotifyList
		
		local NTitle = Instance.new("TextLabel")
		NTitle.Size = UDim2.new(1, -10, 0, 20)
		NTitle.Position = UDim2.new(0, 5, 0, 5)
		NTitle.BackgroundTransparency = 1
		NTitle.Text = title
		NTitle.TextColor3 = Theme.Accent
		NTitle.Font = Enum.Font.GothamBold
		NTitle.TextSize = 14
		NTitle.TextXAlignment = Enum.TextXAlignment.Left
		NTitle.Parent = NotifFrame
		
		local NText = Instance.new("TextLabel")
		NText.Size = UDim2.new(1, -10, 0, 30)
		NText.Position = UDim2.new(0, 5, 0, 25)
		NText.BackgroundTransparency = 1
		NText.Text = text
		NText.TextColor3 = Theme.Text
		NText.Font = Enum.Font.Gotham
		NText.TextSize = 12
		NText.TextXAlignment = Enum.TextXAlignment.Left
		NText.TextWrapped = true
		NText.Parent = NotifFrame
		
		task.delay(duration or 3, function()
			TweenService:Create(NotifFrame, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
			TweenService:Create(NTitle, TweenInfo.new(0.5), {TextTransparency = 1}):Play()
			TweenService:Create(NText, TweenInfo.new(0.5), {TextTransparency = 1}):Play()
			wait(0.5)
			NotifFrame:Destroy()
		end)
	end

	local Window = {}
	local FirstTab = true

	function Window:AddTab(name)
		local TabBtn = Instance.new("TextButton")
		TabBtn.Size = UDim2.new(1, 0, 0, 30)
		TabBtn.BackgroundTransparency = 1
		TabBtn.Text = name
		TabBtn.TextColor3 = Theme.TextDark
		TabBtn.Font = Enum.Font.GothamBold
		TabBtn.TextSize = 13
		TabBtn.Parent = Sidebar

		local Page = Instance.new("ScrollingFrame")
		Page.Size = UDim2.new(1, -10, 1, -10)
		Page.Position = UDim2.new(0, 5, 0, 5)
		Page.BackgroundTransparency = 1
		Page.ScrollBarThickness = 2
		Page.ScrollBarImageColor3 = Theme.Accent
		Page.Visible = false
		Page.Parent = ContentArea

		local PageLayout = Instance.new("UIListLayout")
		PageLayout.SortOrder = Enum.SortOrder.LayoutOrder
		PageLayout.Padding = UDim.new(0, 5)
		PageLayout.Parent = Page

		if FirstTab then
			Page.Visible = true
			TabBtn.TextColor3 = Theme.Text
			FirstTab = false
		end

		TabBtn.MouseButton1Click:Connect(function()
			for _, child in pairs(ContentArea:GetChildren()) do child.Visible = false end
			for _, child in pairs(Sidebar:GetChildren()) do
				if child:IsA("TextButton") then child.TextColor3 = Theme.TextDark end
			end
			Page.Visible = true
			TabBtn.TextColor3 = Theme.Text
		end)

		local Tab = {}

		function Tab:AddSection(sectionName)
			local SectionContainer = Instance.new("Frame")
			SectionContainer.BackgroundColor3 = Theme.Section
			SectionContainer.BorderSizePixel = 0
			SectionContainer.Parent = Page
			
			local SectionCorner = Instance.new("UICorner")
			SectionCorner.CornerRadius = UDim.new(0, 4)
			SectionCorner.Parent = SectionContainer

			local SectionTitle = Instance.new("TextLabel")
			SectionTitle.Size = UDim2.new(1, -10, 0, 25)
			SectionTitle.Position = UDim2.new(0, 5, 0, 0)
			SectionTitle.BackgroundTransparency = 1
			SectionTitle.Text = sectionName
			SectionTitle.TextColor3 = Theme.Accent
			SectionTitle.Font = Enum.Font.GothamBold
			SectionTitle.TextSize = 12
			SectionTitle.TextXAlignment = Enum.TextXAlignment.Left
			SectionTitle.Parent = SectionContainer

			local SectionLayout = Instance.new("UIListLayout")
			SectionLayout.SortOrder = Enum.SortOrder.LayoutOrder
			SectionLayout.Padding = UDim.new(0, 5)
			SectionLayout.Parent = SectionContainer

			local SectionPad = Instance.new("UIPadding")
			SectionPad.PaddingTop = UDim.new(0, 30)
			SectionPad.PaddingBottom = UDim.new(0, 10)
			SectionPad.PaddingLeft = UDim.new(0, 10)
			SectionPad.PaddingRight = UDim.new(0, 10)
			SectionPad.Parent = SectionContainer
			
			-- Auto-Size Logic
			local function UpdateSize()
				SectionContainer.Size = UDim2.new(1, 0, 0, SectionLayout.AbsoluteContentSize.Y + 40)
				Page.CanvasSize = UDim2.new(0, 0, 0, PageLayout.AbsoluteContentSize.Y + 20)
			end
			SectionLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(UpdateSize)
			
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
				UpdateSize()
			end

			-- ELEMENT: BUTTON
			function Section:AddButton(btnText, callback)
				local Button = Instance.new("TextButton")
				Button.Size = UDim2.new(1, 0, 0, 30)
				Button.BackgroundColor3 = Theme.Background
				Button.Text = btnText
				Button.TextColor3 = Theme.Text
				Button.Font = Enum.Font.Gotham
				Button.TextSize = 12
				Button.AutoButtonColor = false
				Button.Parent = SectionContainer
				
				local BtnCorner = Instance.new("UICorner")
				BtnCorner.CornerRadius = UDim.new(0, 4)
				BtnCorner.Parent = Button

				Button.MouseButton1Click:Connect(function()
					callback()
					TweenService:Create(Button, TweenInfo.new(0.1), {BackgroundColor3 = Theme.Accent}):Play()
					wait(0.1)
					TweenService:Create(Button, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Background}):Play()
				end)
				UpdateSize()
			end

			-- ELEMENT: TOGGLE
			function Section:AddToggle(toggleText, default, callback)
				local toggled = default or false
				local ToggleBtn = Instance.new("TextButton")
				ToggleBtn.Size = UDim2.new(1, 0, 0, 30)
				ToggleBtn.BackgroundTransparency = 1
				ToggleBtn.Text = ""
				ToggleBtn.Parent = SectionContainer

				local Label = Instance.new("TextLabel")
				Label.Size = UDim2.new(1, -40, 1, 0)
				Label.BackgroundTransparency = 1
				Label.Text = toggleText
				Label.TextColor3 = Theme.Text
				Label.Font = Enum.Font.Gotham
				Label.TextSize = 12
				Label.TextXAlignment = Enum.TextXAlignment.Left
				Label.Parent = ToggleBtn

				local OuterBox = Instance.new("Frame")
				OuterBox.Size = UDim2.new(0, 40, 0, 20)
				OuterBox.Position = UDim2.new(1, -40, 0.5, -10)
				OuterBox.BackgroundColor3 = Theme.Background
				OuterBox.Parent = ToggleBtn
				
				local BoxCorner = Instance.new("UICorner")
				BoxCorner.CornerRadius = UDim.new(1,0)
				BoxCorner.Parent = OuterBox

				local Circle = Instance.new("Frame")
				Circle.Size = UDim2.new(0, 16, 0, 16)
				Circle.Position = UDim2.new(0, 2, 0.5, -8)
				Circle.BackgroundColor3 = Theme.TextDark
				Circle.Parent = OuterBox
				
				local CircleCorner = Instance.new("UICorner")
				CircleCorner.CornerRadius = UDim.new(1,0)
				CircleCorner.Parent = Circle

				local function UpdateState()
					if toggled then
						TweenService:Create(OuterBox, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Accent}):Play()
						TweenService:Create(Circle, TweenInfo.new(0.2), {Position = UDim2.new(1, -18, 0.5, -8), BackgroundColor3 = Theme.Text}):Play()
					else
						TweenService:Create(OuterBox, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Background}):Play()
						TweenService:Create(Circle, TweenInfo.new(0.2), {Position = UDim2.new(0, 2, 0.5, -8), BackgroundColor3 = Theme.TextDark}):Play()
					end
				end
				UpdateState()

				ToggleBtn.MouseButton1Click:Connect(function()
					toggled = not toggled
					UpdateState()
					callback(toggled)
				end)
				UpdateSize()
			end

			-- ELEMENT: SLIDER
			function Section:AddSlider(text, minVal, maxVal, initialVal, step, callback)
				local currentValue = initialVal or minVal
				local SliderFrame = Instance.new("Frame")
				SliderFrame.Size = UDim2.new(1, 0, 0, 45)
				SliderFrame.BackgroundTransparency = 1
				SliderFrame.Parent = SectionContainer

				local Label = Instance.new("TextLabel")
				Label.Size = UDim2.new(1, 0, 0, 20)
				Label.BackgroundTransparency = 1
				Label.Text = text .. ": " .. currentValue
				Label.TextColor3 = Theme.Text
				Label.Font = Enum.Font.Gotham
				Label.TextSize = 12
				Label.TextXAlignment = Enum.TextXAlignment.Left
				Label.Parent = SliderFrame

				local Bar = Instance.new("Frame")
				Bar.Size = UDim2.new(1, 0, 0, 6)
				Bar.Position = UDim2.new(0, 0, 0, 25)
				Bar.BackgroundColor3 = Theme.Background
				Bar.Parent = SliderFrame
				
				local BarCorner = Instance.new("UICorner")
				BarCorner.CornerRadius = UDim.new(1,0)
				BarCorner.Parent = Bar

				local Fill = Instance.new("Frame")
				Fill.Size = UDim2.new((currentValue - minVal) / (maxVal - minVal), 0, 1, 0)
				Fill.BackgroundColor3 = Theme.Accent
				Fill.Parent = Bar
				
				local FillCorner = Instance.new("UICorner")
				FillCorner.CornerRadius = UDim.new(1,0)
				FillCorner.Parent = Fill

				local dragging = false
				local function update(input)
					local sizeX = math.clamp((input.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
					local val = minVal + (maxVal - minVal) * sizeX
					val = math.floor(val / step) * step
					val = math.clamp(val, minVal, maxVal)
					
					currentValue = val
					Fill.Size = UDim2.new(sizeX, 0, 1, 0)
					Label.Text = text .. ": " .. val
					callback(val)
				end

				Bar.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
						dragging = true; update(input)
					end
				end)
				
				UserInputService.InputEnded:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
						dragging = false
					end
				end)
				
				UserInputService.InputChanged:Connect(function(input)
					if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
						update(input)
					end
				end)
				UpdateSize()
			end
			
			-- ELEMENT: TEXTBOX
			function Section:AddTextbox(placeholder, callback)
				local BoxFrame = Instance.new("Frame")
				BoxFrame.Size = UDim2.new(1, 0, 0, 30)
				BoxFrame.BackgroundColor3 = Theme.Background
				BoxFrame.Parent = SectionContainer
				
				local BoxCorner = Instance.new("UICorner")
				BoxCorner.CornerRadius = UDim.new(0, 4)
				BoxCorner.Parent = BoxFrame
				
				local Input = Instance.new("TextBox")
				Input.Size = UDim2.new(1, -10, 1, 0)
				Input.Position = UDim2.new(0, 5, 0, 0)
				Input.BackgroundTransparency = 1
				Input.Text = ""
				Input.PlaceholderText = placeholder
				Input.PlaceholderColor3 = Theme.TextDark
				Input.TextColor3 = Theme.Text
				Input.Font = Enum.Font.Gotham
				Input.TextSize = 12
				Input.TextXAlignment = Enum.TextXAlignment.Left
				Input.Parent = BoxFrame
				
				Input.FocusLost:Connect(function()
					callback(Input.Text)
				end)
				UpdateSize()
			end

			-- ELEMENT: DROPDOWN
			function Section:AddDropdown(text, options, callback)
				local isExpanded = false
				local selected = options[1]
				
				local DropFrame = Instance.new("Frame")
				DropFrame.Size = UDim2.new(1, 0, 0, 30)
				DropFrame.BackgroundTransparency = 1
				DropFrame.ClipsDescendants = true
				DropFrame.Parent = SectionContainer
				
				local MainBtn = Instance.new("TextButton")
				MainBtn.Size = UDim2.new(1, 0, 0, 30)
				MainBtn.BackgroundColor3 = Theme.Background
				MainBtn.Text = text .. ": " .. selected
				MainBtn.TextColor3 = Theme.Text
				MainBtn.Font = Enum.Font.Gotham
				MainBtn.TextSize = 12
				MainBtn.Parent = DropFrame
				
				local MainCorner = Instance.new("UICorner")
				MainCorner.CornerRadius = UDim.new(0, 4)
				MainCorner.Parent = MainBtn
				
				local ItemsList = Instance.new("Frame")
				ItemsList.Size = UDim2.new(1, 0, 0, 0)
				ItemsList.Position = UDim2.new(0, 0, 0, 35)
				ItemsList.BackgroundTransparency = 1
				ItemsList.Parent = DropFrame
				
				local ListLayout = Instance.new("UIListLayout")
				ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
				ListLayout.Padding = UDim.new(0, 2)
				ListLayout.Parent = ItemsList
				
				for _, opt in ipairs(options) do
					local OptBtn = Instance.new("TextButton")
					OptBtn.Size = UDim2.new(1, 0, 0, 25)
					OptBtn.BackgroundColor3 = Theme.Hover
					OptBtn.Text = opt
					OptBtn.TextColor3 = Theme.TextDark
					OptBtn.Font = Enum.Font.Gotham
					OptBtn.TextSize = 12
					OptBtn.Parent = ItemsList
					
					local OptCorner = Instance.new("UICorner")
					OptCorner.CornerRadius = UDim.new(0, 4)
					OptCorner.Parent = OptBtn
					
					OptBtn.MouseButton1Click:Connect(function()
						selected = opt
						MainBtn.Text = text .. ": " .. selected
						isExpanded = false
						DropFrame:TweenSize(UDim2.new(1, 0, 0, 30), "Out", "Quad", 0.2, true)
						task.wait(0.2)
						UpdateSize()
						callback(opt)
					end)
				end
				
				MainBtn.MouseButton1Click:Connect(function()
					isExpanded = not isExpanded
					if isExpanded then
						local height = 35 + (#options * 27)
						DropFrame:TweenSize(UDim2.new(1, 0, 0, height), "Out", "Quad", 0.2, true)
					else
						DropFrame:TweenSize(UDim2.new(1, 0, 0, 30), "Out", "Quad", 0.2, true)
					end
					task.wait(0.2)
					UpdateSize()
				end)
				
				UpdateSize()
			end

			return Section
		end
		return Tab
	end
	return Window
end

return Library
