local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local player = game:GetService("Players").LocalPlayer
local pgui = player:WaitForChild("PlayerGui")

-- 既存のUIを削除
if pgui:FindFirstChild("StyledExplorer") then pgui.StyledExplorer:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "StyledExplorer"
ScreenGui.ResetOnSpawn = false
ScreenGui.DisplayOrder = 1000
ScreenGui.Parent = pgui

-- メインフレーム
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 380, 0, 550) -- 少し横幅を広げました
MainFrame.Position = UDim2.new(0.02, 0, 0.15, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
MainFrame.BackgroundTransparency = 0.1
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = MainFrame

-- タイトルバー
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
Title.Text = "  MULTI-STORAGE EXPLORER"
Title.TextColor3 = Color3.fromRGB(0, 255, 200)
Title.TextSize = 14
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Active = true
Title.Parent = MainFrame
local TCorner = Instance.new("UICorner")
TCorner.Parent = Title

--- [[ ドラッグ移動の実装 ]] ---
local dragging, dragInput, dragStart, startPos
local function update(input)
	local delta = input.Position - dragStart
	MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end
Title.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = MainFrame.Position
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then dragging = false end
		end)
	end
end)
Title.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
end)
UIS.InputChanged:Connect(function(input)
	if input == dragInput and dragging then update(input) end
end)

-- スクロールエリア
local Scroll = Instance.new("ScrollingFrame")
Scroll.Size = UDim2.new(1, -10, 1, -45)
Scroll.Position = UDim2.new(0, 5, 0, 40)
Scroll.BackgroundTransparency = 1
Scroll.BorderSizePixel = 0
Scroll.ScrollBarThickness = 4
Scroll.ScrollBarImageColor3 = Color3.fromRGB(0, 255, 200)
Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
Scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
Scroll.Parent = MainFrame

local List = Instance.new("UIListLayout")
List.Parent = Scroll
List.SortOrder = Enum.SortOrder.LayoutOrder

-- アイテム作成関数
local function createItem(obj, level, parentFrame)
	local children = obj:GetChildren()
	
	local Container = Instance.new("Frame")
	Container.Size = UDim2.new(1, 0, 0, 28)
	Container.BackgroundTransparency = 1
	Container.Parent = parentFrame

	local Label = Instance.new("TextLabel")
	Label.Size = UDim2.new(1, -(level * 18 + 85), 1, 0) -- TPボタン用に隙間を確保
	Label.Position = UDim2.new(0, level * 18 + 35, 0, 0)
	Label.Text = obj.Name .. " <font color='#888'>[" .. obj.ClassName .. "]</font>"
	Label.RichText = true
	Label.TextColor3 = Color3.fromRGB(230, 230, 230)
	Label.TextSize = 13
	Label.Font = Enum.Font.Gotham
	Label.TextXAlignment = Enum.TextXAlignment.Left
	Label.BackgroundTransparency = 1
	Label.Parent = Container

	-- TPボタン (BasePartかModelの場合のみ表示)
	if obj:IsA("BasePart") or (obj:IsA("Model") and obj.PrimaryPart) then
		local TPBtn = Instance.new("TextButton")
		TPBtn.Size = UDim2.new(0, 35, 0, 20)
		TPBtn.Position = UDim2.new(1, -40, 0, 4)
		TPBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
		TPBtn.Text = "TP"
		TPBtn.TextColor3 = Color3.white
		TPBtn.TextSize = 10
		TPBtn.Parent = Container
		TPBtn.MouseButton1Click:Connect(function()
			if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
				local targetCFrame = obj:IsA("BasePart") and obj.CFrame or obj.PrimaryPart.CFrame
				player.Character.HumanoidRootPart.CFrame = targetCFrame * CFrame.new(0, 3, 0)
			end
		end)
	end

	-- 動体検知ロジック
	if obj:IsA("BasePart") then
		local lastPos = obj.Position
		RunService.Heartbeat:Connect(function()
			if (obj.Position - lastPos).Magnitude > 0.05 then
				Label.TextColor3 = Color3.fromRGB(255, 80, 80) -- 動いていたら赤
			else
				Label.TextColor3 = Color3.fromRGB(230, 230, 230) -- 止まったら白
			end
			lastPos = obj.Position
		end)
	end

	local ChildFrame = Instance.new("Frame")
	ChildFrame.Size = UDim2.new(1, 0, 0, 0)
	ChildFrame.AutomaticSize = Enum.AutomaticSize.Y
	ChildFrame.BackgroundTransparency = 1
	ChildFrame.Visible = false
	ChildFrame.Parent = parentFrame
	Instance.new("UIListLayout").Parent = ChildFrame

	if #children > 0 then
		local Toggle = Instance.new("TextButton")
		Toggle.Size = UDim2.new(0, 20, 0, 20)
		Toggle.Position = UDim2.new(0, level * 18 + 10, 0, 4)
		Toggle.Text = "+"
		Toggle.Font = Enum.Font.GothamBold
		Toggle.TextColor3 = Color3.fromRGB(0, 255, 200)
		Toggle.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
		Toggle.Parent = Container
		
		Toggle.MouseButton1Click:Connect(function()
			ChildFrame.Visible = not ChildFrame.Visible
			Toggle.Text = ChildFrame.Visible and "-" or "+"
			if ChildFrame.Visible and #ChildFrame:GetChildren() <= 1 then
				for _, c in ipairs(obj:GetChildren()) do createItem(c, level + 1, ChildFrame) end
			end
		end)
	end
end

-- 各ストレージをルートとして追加
createItem(game.Workspace, 0, Scroll)
createItem(game.ReplicatedStorage, 0, Scroll)
-- createItem(game.Lighting, 0, Scroll) -- 必要ならLightingなども追加可能
