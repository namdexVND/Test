-- Cấu hình
local CONFIG = {
    HEAL_THRESHOLD = 0.8,        -- Ngưỡng máu để tự động hồi (80%)
    HEAL_COOLDOWN = 0.8,         -- Thời gian chờ giữa các lần hồi (giây)
    CHECK_INTERVAL = 0.1,        -- Tần suất kiểm tra
    UI_POSITION = {X = 0.1, Y = 0.1}, -- Vị trí UI
}

-- Service
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

-- Biến trạng thái
local enabled = false
local lastHeal = 0
local healRemote = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("Heal")

-- Kiểm tra remote tồn tại
if not healRemote then
    warn("Không tìm thấy Remote Heal!")
    return
end

-- Hàm tự động hồi máu
task.spawn(function()
    while task.wait(CONFIG.CHECK_INTERVAL) do
        if enabled then
            pcall(function()
                local char = player.Character
                if not char then return end
                
                local hum = char:FindFirstChildOfClass("Humanoid")
                if not hum then return end
                
                local currentHealth = hum.Health
                local maxHealth = hum.MaxHealth
                local currentTime = os.clock()
                
                -- Kiểm tra điều kiện hồi máu
                if currentHealth > 0 
                    and currentHealth < maxHealth * CONFIG.HEAL_THRESHOLD 
                    and (currentTime - lastHeal) >= CONFIG.HEAL_COOLDOWN then
                    
                    lastHeal = currentTime
                    healRemote:FireServer()
                end
            end)
        end
    end
end)

-- ===== TẠO UI ĐEN ĐẸP =====

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AutoHealUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = player:WaitForChild("PlayerGui")
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Main Frame
local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 220, 0, 120)
Frame.Position = UDim2.new(CONFIG.UI_POSITION.X, 0, CONFIG.UI_POSITION.Y, 0)
Frame.BackgroundColor3 = Color3.fromRGB(15, 15, 20) -- Đen đậm
Frame.BackgroundTransparency = 0 -- Không trong suốt
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true
Frame.Parent = ScreenGui

-- Gradient Background (đen --> đen xám)
local UIGradient = Instance.new("UIGradient")
UIGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(25, 25, 30)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 10, 15))
})
UIGradient.Parent = Frame

-- Corner
local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = Frame

-- Border sáng
local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(80, 80, 120)
UIStroke.Thickness = 2
UIStroke.Transparency = 0.5
UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
UIStroke.Parent = Frame

-- Shadow (đổ bóng)
local Shadow = Instance.new("ImageLabel")
Shadow.Size = UDim2.new(1.1, 0, 1.1, 0)
Shadow.Position = UDim2.new(-0.05, 0, -0.05, 0)
Shadow.BackgroundTransparency = 1
Shadow.Image = "rbxassetid://1316045290" -- Shadow texture
Shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
Shadow.ImageTransparency = 0.6
Shadow.ZIndex = 0
Shadow.Parent = Frame

-- Title
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Position = UDim2.new(0, 0, 0, 8)
Title.BackgroundTransparency = 1
Title.Text = "⚕️ AUTO HEAL"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextScaled = true
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.Parent = Frame

-- Line ngăn cách
local Line = Instance.new("Frame")
Line.Size = UDim2.new(0.9, 0, 0, 1)
Line.Position = UDim2.new(0.05, 0, 0.32, 0)
Line.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
Line.BackgroundTransparency = 0.5
Line.Parent = Frame

-- Toggle Button
local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0.75, 0, 0.4, 0)
ToggleButton.Position = UDim2.new(0.125, 0, 0.38, 0)
ToggleButton.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
ToggleButton.Text = "OFF"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.TextScaled = true
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.TextSize = 14
ToggleButton.AutoButtonColor = false
ToggleButton.Parent = Frame

-- Button Corner
local BtnCorner = Instance.new("UICorner")
BtnCorner.CornerRadius = UDim.new(0, 8)
BtnCorner.Parent = ToggleButton

-- Button Gradient
local BtnGradient = Instance.new("UIGradient")
BtnGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(220, 50, 50)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(180, 30, 30))
})
BtnGradient.Parent = ToggleButton

-- Status Indicator (đèn led)
local StatusDot = Instance.new("Frame")
StatusDot.Size = UDim2.new(0, 12, 0, 12)
StatusDot.Position = UDim2.new(0.88, 0, 0.08, 0)
StatusDot.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
StatusDot.BackgroundTransparency = 0.1
StatusDot.Parent = Frame

local DotCorner = Instance.new("UICorner")
DotCorner.CornerRadius = UDim.new(1, 0)
DotCorner.Parent = StatusDot

-- Hiệu ứng glow cho đèn
local DotGlow = Instance.new("ImageLabel")
DotGlow.Size = UDim2.new(2.5, 0, 2.5, 0)
DotGlow.Position = UDim2.new(-0.75, 0, -0.75, 0)
DotGlow.BackgroundTransparency = 1
DotGlow.Image = "rbxassetid://5028857084"
DotGlow.ImageColor3 = Color3.fromRGB(255, 0, 0)
DotGlow.ImageTransparency = 0.6
DotGlow.Parent = StatusDot

-- Info Label
local InfoLabel = Instance.new("TextLabel")
InfoLabel.Size = UDim2.new(1, 0, 0, 20)
InfoLabel.Position = UDim2.new(0, 0, 0.82, 0)
InfoLabel.BackgroundTransparency = 1
InfoLabel.Text = "Nhấn để bật/tắt"
InfoLabel.TextColor3 = Color3.fromRGB(150, 150, 180)
InfoLabel.TextScaled = true
InfoLabel.Font = Enum.Font.Gotham
InfoLabel.TextSize = 10
InfoLabel.TextTransparency = 0.3
InfoLabel.Parent = Frame

-- Hotkey hint
local HotkeyHint = Instance.new("TextLabel")
HotkeyHint.Size = UDim2.new(0.5, 0, 0, 15)
HotkeyHint.Position = UDim2.new(0.5, 0, 0.82, 0)
HotkeyHint.BackgroundTransparency = 1
HotkeyHint.Text = "Alt + H"
HotkeyHint.TextColor3 = Color3.fromRGB(100, 100, 130)
HotkeyHint.TextScaled = true
HotkeyHint.Font = Enum.Font.Gotham
HotkeyHint.TextSize = 8
HotkeyHint.TextTransparency = 0.4
HotkeyHint.Parent = Frame

-- Animation variables
local tweenService = game:GetService("TweenService")
local isHovering = false

-- Button click handler
ToggleButton.MouseButton1Click:Connect(function()
    enabled = not enabled
    
    if enabled then
        ToggleButton.Text = "✅ ON"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(40, 200, 40)
        BtnGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(50, 220, 50)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(30, 180, 30))
        })
        StatusDot.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        DotGlow.ImageColor3 = Color3.fromRGB(0, 255, 0)
        StatusDot.BackgroundTransparency = 0
        Frame.UIStroke.Color = Color3.fromRGB(0, 255, 100)
        InfoLabel.Text = "✅ Đang tự động hồi máu"
        InfoLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
    else
        ToggleButton.Text = "❌ OFF"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
        BtnGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(220, 50, 50)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(180, 30, 30))
        })
        StatusDot.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        DotGlow.ImageColor3 = Color3.fromRGB(255, 0, 0)
        StatusDot.BackgroundTransparency = 0.1
        Frame.UIStroke.Color = Color3.fromRGB(80, 80, 120)
        InfoLabel.Text = "❌ Đã tắt tự động hồi"
        InfoLabel.TextColor3 = Color3.fromRGB(180, 180, 200)
    end
end)

-- Hover animation
ToggleButton.MouseEnter:Connect(function()
    if isHovering then return end
    isHovering = true
    
    local tween = tweenService:Create(ToggleButton, TweenInfo.new(0.15), {
        BackgroundTransparency = 0.2
    })
    tween:Play()
end)

ToggleButton.MouseLeave:Connect(function()
    isHovering = false
    
    local tween = tweenService:Create(ToggleButton, TweenInfo.new(0.15), {
        BackgroundTransparency = 0
    })
    tween:Play()
end)

-- Frame drag animation
local dragging = false
local dragStart, startPos

Frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = Frame.Position
        Frame.ZIndex = 10
    end
end)

Frame.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
        Frame.ZIndex = 1
    end
end)

game:GetService("UserInputService").InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        Frame.Position = UDim2.new(
            startPos.X.Scale, 
            startPos.X.Offset + delta.X,
            startPos.Y.Scale, 
            startPos.Y.Offset + delta.Y
        )
    end
end)

-- Hotkey (Alt + H)
game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.H and input.UserInputType == Enum.UserInputType.Keyboard then
        if input:IsModifierKeyDown(Enum.KeyCode.LeftAlt) or input:IsModifierKeyDown(Enum.KeyCode.RightAlt) then
            ToggleButton.MouseButton1Click:Fire()
        end
    end
end)

print("✅ Auto Heal Script đã được tải thành công!")
print("📌 Nhấn Alt + H để bật/tắt nhanh")
