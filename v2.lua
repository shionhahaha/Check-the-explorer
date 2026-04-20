local UIS = game:GetService("UserInputService")
local player = game:GetService("Players").LocalPlayer
local pgui = player:WaitForChild("PlayerGui")
local camera = workspace.CurrentCamera

-- 既存UIの削除
if pgui:FindFirstChild("ParentTracker") then pgui.ParentTracker:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ParentTracker"
ScreenGui.Parent = pgui

-- メイン枠（親子関係を表示するコンテナ）
local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 300, 0, 400)
Main.Position = UDim2.new(0.02, 0, 0.3, 0)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
Main.BackgroundTransparency = 0.2
Main.Active = true
Main.Draggable = true
Main.Parent = ScreenGui
Instance.new("UICorner", Main)

-- タイトル
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Text = " PARENT HIERARCHY"
Title.TextColor3 = Color3.fromRGB(0, 255, 200)
Title.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Font = Enum.Font.GothamBold
Title.Parent = Main
Instance.new("UICorner", Title)

-- 親子関係を表示するリスト部分
local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -10, 1, -40)
Content.Position = UDim2.new(0, 5, 0, 35)
Content.BackgroundTransparency = 1
Content.Parent = Main

local List = Instance.new("UIListLayout")
List.Parent = Content
List.Padding = UDim.new(0, 5)

-- 階層アイテムを作成する関数
local function createStep(name, className, level)
    local Step = Instance.new("Frame")
    Step.Size = UDim2.new(1, 0, 0, 25)
    Step.BackgroundTransparency = 1
    Step.Parent = Content

    local Text = Instance.new("TextLabel")
    -- レベルに応じて右にずらす（親子関係を段々で表現）
    Text.Position = UDim2.new(0, level * 20, 0, 0)
    Text.Size = UDim2.new(1, -(level * 20), 1, 0)
    Text.Text = (level > 0 and "└ " or "") .. name .. " [" .. className .. "]"
    Text.TextColor3 = (className == "Part" or className == "MeshPart") and Color3.new(1, 1, 1) or Color3.fromRGB(180, 180, 180)
    Text.TextXAlignment = Enum.TextXAlignment.Left
    Text.Font = Enum.Font.Code
    Text.TextSize = 13
    Text.BackgroundTransparency = 1
    Text.Parent = Step
end

-- クリックで親子関係を解析
UIS.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        local mousePos = UIS:GetMouseLocation()
        local ray = camera:ViewportPointToRay(mousePos.X, mousePos.Y)
        local hit = workspace:FindPartOnRay(Ray.new(ray.Origin, ray.Direction * 5000))
        
        if hit then
            -- 以前の表示をクリア
            for _, child in ipairs(Content:GetChildren()) do
                if child:IsA("Frame") then child:Destroy() end
            end

            -- 親子リストを作成（Workspaceから自分まで）
            local lineage = {}
            local curr = hit
            while curr and curr ~= game do
                table.insert(lineage, 1, {name = curr.Name, class = curr.ClassName})
                curr = curr.Parent
            end

            -- 表示を生成（インデント付き）
            for i, data in ipairs(lineage) do
                createStep(data.name, data.class, i - 1)
            end

            -- クリックした実物を光らせる
            local h = Instance.new("Highlight", hit)
            h.FillColor = Color3.fromRGB(0, 255, 200)
            game:GetService("Debris"):AddItem(h, 0.5)
        end
    end
end)
