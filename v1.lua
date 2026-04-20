local player = game:GetService("Players").LocalPlayer
local pgui = player:WaitForChild("PlayerGui")

-- 既存のUIを削除
if pgui:FindFirstChild("StyledExplorer") then pgui.StyledExplorer:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "StyledExplorer"
ScreenGui.ResetOnSpawn = false
ScreenGui.DisplayOrder = 1000
ScreenGui.Parent = pgui

-- メインフレーム（背景を少し透かして高級感を出す）
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 350, 0, 550)
MainFrame.Position = UDim2.new(0.02, 0, 0.15, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
MainFrame.BackgroundTransparency = 0.1
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

-- 角を丸くする
local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = MainFrame

-- タイトルバー
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
Title.Text = "  WORKSPACE EXPLORER"
Title.TextColor3 = Color3.fromRGB(0, 255, 200) -- ネオンブルー
Title.TextSize = 14
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = MainFrame
local TCorner = Instance.new("UICorner")
TCorner.Parent = Title

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

    -- ホバーエフェクト用ボタン
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, 0, 1, 0)
    Btn.BackgroundTransparency = 1
    Btn.Text = ""
    Btn.Parent = Container

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -(level * 18 + 35), 1, 0)
    Label.Position = UDim2.new(0, level * 18 + 35, 0, 0)
    Label.Text = obj.Name .. " <font color='#888'>[" .. obj.ClassName .. "]</font>"
    Label.RichText = true
    Label.TextColor3 = Color3.fromRGB(230, 230, 230)
    Label.TextSize = 13
    Label.Font = Enum.Font.Gotham
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.BackgroundTransparency = 1
    Label.Parent = Container

    -- 子要素用
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
                for _, c in ipairs(children) do createItem(c, level + 1, ChildFrame) end
            end
        end)
    end
end

createItem(game.Workspace, 0, Scroll)
