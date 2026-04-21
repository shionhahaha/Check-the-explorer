-- =================================================
-- FIXED EXPLORER (Correct Z-Index & Layout Order)
-- =================================================

local UIS = game:GetService("UserInputService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local pgui = player:WaitForChild("PlayerGui")

if pgui:FindFirstChild("StyledExplorer") then pgui.StyledExplorer:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "StyledExplorer"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = pgui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 380, 0, 550)
MainFrame.Position = UDim2.new(0.02, 0, 0.15, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui
Instance.new("UICorner").Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
Title.Text = "  REAL-TIME EXPLORER (Fixed)"
Title.TextColor3 = Color3.fromRGB(0, 255, 200)
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = MainFrame

local Scroll = Instance.new("ScrollingFrame")
Scroll.Size = UDim2.new(1, -10, 1, -45)
Scroll.Position = UDim2.new(0, 5, 0, 40)
Scroll.BackgroundTransparency = 1
Scroll.ScrollBarThickness = 4
Scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
Scroll.Parent = MainFrame

local MainList = Instance.new("UIListLayout")
MainList.SortOrder = Enum.SortOrder.LayoutOrder
MainList.Parent = Scroll

-- アイテム作成関数
local function createItem(obj, level, parentFrame)
    if not obj then return end
    
    -- このアイテム全体のまとまり（名前＋子要素）
    local ItemGroup = Instance.new("Frame")
    ItemGroup.Name = obj.Name .. "_Group"
    ItemGroup.Size = UDim2.new(1, 0, 0, 0)
    ItemGroup.AutomaticSize = Enum.AutomaticSize.Y
    ItemGroup.BackgroundTransparency = 1
    ItemGroup.Parent = parentFrame

    local GroupList = Instance.new("UIListLayout")
    GroupList.SortOrder = Enum.SortOrder.LayoutOrder
    GroupList.Parent = ItemGroup

    -- 名前を表示するバー
    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(1, 0, 0, 28)
    Container.BackgroundTransparency = 1
    Container.LayoutOrder = 1 -- 常に上にくるように固定
    Container.Parent = ItemGroup

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -(level * 18 + 85), 1, 0)
    Label.Position = UDim2.new(0, level * 18 + 35, 0, 0)
    Label.Text = obj.Name .. " <font color='#888'>[" .. obj.ClassName .. "]</font>"
    Label.RichText = true
    Label.TextColor3 = Color3.fromRGB(230, 230, 230)
    Label.TextSize = 12
    Label.Font = Enum.Font.Gotham
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.BackgroundTransparency = 1
    Label.Parent = Container

    -- 子要素を入れる枠
    local ChildFrame = Instance.new("Frame")
    ChildFrame.Size = UDim2.new(1, 0, 0, 0)
    ChildFrame.AutomaticSize = Enum.AutomaticSize.Y
    ChildFrame.BackgroundTransparency = 1
    ChildFrame.Visible = false
    ChildFrame.LayoutOrder = 2 -- 名前の直後にくるように固定
    ChildFrame.Parent = ItemGroup
    Instance.new("UIListLayout").SortOrder = Enum.SortOrder.LayoutOrder
    Instance.new("UIListLayout").Parent = ChildFrame

    -- TPボタン
    if obj:IsA("BasePart") or (obj:IsA("Model") and obj.PrimaryPart) then
        local TPBtn = Instance.new("TextButton")
        TPBtn.Size = UDim2.new(0, 35, 0, 20)
        TPBtn.Position = UDim2.new(1, -40, 0, 4)
        TPBtn.Text = "TP"
        TPBtn.Parent = Container
        TPBtn.MouseButton1Click:Connect(function()
            local target = obj:IsA("BasePart") and obj or obj.PrimaryPart
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                player.Character.HumanoidRootPart.CFrame = target.CFrame * CFrame.new(0, 3, 0)
            end
        end)
    end

    -- トグルボタン
    local Toggle = Instance.new("TextButton")
    Toggle.Size = UDim2.new(0, 20, 0, 20)
    Toggle.Position = UDim2.new(0, level * 18 + 10, 0, 4)
    Toggle.Text = "+"
    Toggle.Parent = Container
    
    Toggle.MouseButton1Click:Connect(function()
        ChildFrame.Visible = not ChildFrame.Visible
        Toggle.Text = ChildFrame.Visible and "-" or "+"
        
        -- 子要素を表示する際にまだ生成されていなければ生成
        if ChildFrame.Visible and #ChildFrame:GetChildren() <= 1 then
            for _, c in ipairs(obj:GetChildren()) do
                createItem(c, level + 1, ChildFrame)
            end
        end
    end)

    -- ストリーミング対策：子要素が追加されたらリアルタイム反映
    obj.ChildAdded:Connect(function(child)
        if ChildFrame.Visible then
            createItem(child, level + 1, ChildFrame)
        end
    end)
end

-- カテゴリの初期化
createItem(workspace, 0, Scroll)
createItem(game.ReplicatedStorage, 0, Scroll)
createItem(game.Lighting, 0, Scroll)

-- ドラッグ機能（省略なし）
local dragging, dragInput, dragStart, startPos
Title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.MouseButton1 then dragging = true; dragStart = input.Position; startPos = MainFrame.Position end
end)
UIS.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.MouseMovement then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
UIS.InputEnded:Connect(function(input) if input.UserInputType == Enum.MouseButton1 then dragging = false end end)
