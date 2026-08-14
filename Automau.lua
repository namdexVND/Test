local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local autoEnabled = false
local lastUse = 0

-- Giao diện đẹp xịn
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AutoBandageUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = player:WaitForChild("PlayerGui")

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 180, 0, 80)
Frame.Position = UDim2.new(0.1, 0, 0.1, 0)
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true -- Tính năng kéo thả mặc định của Roblox (hoặc dùng code nếu cần tùy chỉnh)
Frame.Parent = ScreenGui

local UICorner = Instance.new("UICorner", Frame)
UICorner.CornerRadius = UDim.new(0, 10)

local UIStroke = Instance.new("UIStroke", Frame)
UIStroke.Color = Color3.fromRGB(80, 80, 100)
UIStroke.Thickness = 2

local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0.8, 0, 0.5, 0)
ToggleButton.Position = UDim2.new(0.1, 0, 0.25, 0)
ToggleButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
ToggleButton.Text = "AUTO: OFF"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.TextSize = 14
ToggleButton.Parent = Frame

local BtnCorner = Instance.new("UICorner", ToggleButton)
BtnCorner.CornerRadius = UDim.new(0, 6)

-- LOGIC TỐI ƯU (KHÔNG LAG)
local function tryUseBandage()
	if not autoEnabled then return end
	
	-- Chống spam server: Chỉ cho phép dùng lại sau 0.5 giây để tránh lỗi kick
	if tick() - lastUse < 0.5 then return end
	
	local event = ReplicatedStorage:FindFirstChild("UseBandageEvent")
	if event then
		event:FireServer()
		lastUse = tick()
	end
end

-- Theo dõi máu thay đổi (Tức thì, không dùng vòng lặp)
local function onCharacterAdded(char)
	local humanoid = char:WaitForChild("Humanoid")
	humanoid.HealthChanged:Connect(function(health)
		if health > 0 and health < 85 then
			tryUseBandage()
		end
	end)
end

-- Khởi tạo ban đầu
if player.Character then onCharacterAdded(player.Character) end
player.CharacterAdded:Connect(onCharacterAdded)

-- Xử lý nút bấm
ToggleButton.MouseButton1Click:Connect(function()
	autoEnabled = not autoEnabled
	if autoEnabled then
		ToggleButton.Text = "AUTO: ON"
		ToggleButton.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
	else
		ToggleButton.Text = "AUTO: OFF"
		ToggleButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
	end
end)
