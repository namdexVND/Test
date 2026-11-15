--========================================================
-- VND HUB | DAO DA ULTIMATE V16 (SIÊU ỔN ĐỊNH - GIẢI 3 LẦN LIÊN TIẾP)
--========================================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local VirtualInputManager = game:GetService("VirtualInputManager")
local LP = Players.LocalPlayer
local PG = LP:WaitForChild("PlayerGui")

local CauHinh = {
    Bat = false, TuDongDao = false, TuDongMinigame = true,
    DangBan = false, KhoangCachDao = 18, DoLech = 0.4 -- Mở rộng biên độ để bắt chuẩn xác mọi vòng quay
}
local VI_TRI_DAO = Vector3.new(-635.327, 69.425, -205.331)
local KetNoi = {}
local Mau = {
    Nen = Color3.fromRGB(19, 17, 30),
    Bang = Color3.fromRGB(30, 27, 45),
    Tim = Color3.fromRGB(125, 80, 210),
    XanhLa = Color3.fromRGB(40, 165, 110),
    Do = Color3.fromRGB(180, 65, 80),
    Xam = Color3.fromRGB(65, 62, 82),
    Trang = Color3.fromRGB(245, 242, 255),
    Mo = Color3.fromRGB(155, 150, 175),
    XanhDuong = Color3.fromRGB(45, 145, 255)
}

-- XÓA GIAO DIỆN CŨ
for _, p in ipairs({CoreGui, PG}) do
    pcall(function()
        local cu = p:FindFirstChild("VNDRockMiner")
        if cu then cu:Destroy() end
    end)
end

-- TẠO GIAO DIỆN CHÍNH (TUYỆT ĐỐI KHÔNG CHẶN DI CHUYỂN)
local GUI = Instance.new("ScreenGui")
GUI.Name = "VNDRockMiner"
GUI.ResetOnSpawn = false
GUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
GUI.IgnoreGuiInset = true
if not pcall(function() GUI.Parent = CoreGui end) or not GUI.Parent then
    GUI.Parent = PG
end

local function BoGoc(obj, banKinh)
    local g = Instance.new("UICorner", obj)
    g.CornerRadius = UDim.new(0, banKinh or 8)
    return g
end

local Main = Instance.new("Frame", GUI)
Main.Size = UDim2.fromOffset(260, 400)
Main.Position = UDim2.new(0.5, -130, 0.4, -200)
Main.BackgroundColor3 = Mau.Nen
Main.BorderSizePixel = 0
Main.Active = false
Main.Draggable = false
BoGoc(Main, 13)

local Vien = Instance.new("UIStroke", Main)
Vien.Color = Mau.Tim
Vien.Thickness = 1.5

-- THANH TIÊU ĐỀ
local Header = Instance.new("Frame", Main)
Header.Size = UDim2.new(1, 0, 0, 47)
Header.BackgroundColor3 = Color3.fromRGB(91, 54, 155)
Header.BorderSizePixel = 0
Header.Active = false
BoGoc(Header, 13)

local Cover = Instance.new("Frame", Header)
Cover.Size = UDim2.new(1, 0, 0, 12)
Cover.Position = UDim2.new(0, 0, 1, -12)
Cover.BackgroundColor3 = Header.BackgroundColor3
Cover.BorderSizePixel = 0
Cover.Active = false

local Title = Instance.new("TextLabel", Header)
Title.Position = UDim2.fromOffset(12, 4)
Title.Size = UDim2.new(1, -55, 0, 23)
Title.BackgroundTransparency = 1
Title.Text = "VND HUB"
Title.TextColor3 = Mau.Trang
Title.Font = Enum.Font.GothamBlack
Title.TextSize = 17
Title.TextXAlignment = Enum.TextXAlignment.Left

local Sub = Instance.new("TextLabel", Header)
Sub.Position = UDim2.fromOffset(13, 26)
Sub.Size = UDim2.new(1, -55, 0, 13)
Sub.BackgroundTransparency = 1
Sub.Text = "ĐÀO ĐÁ • ULTIMATE V16"
Sub.TextColor3 = Color3.fromRGB(220, 200, 255)
Sub.Font = Enum.Font.Gotham
Sub.TextSize = 9
Sub.TextXAlignment = Enum.TextXAlignment.Left

local Min = Instance.new("TextButton", Header)
Min.Size = UDim2.fromOffset(28, 28)
Min.Position = UDim2.new(1, -36, 0, 9)
Min.BackgroundColor3 = Color3.fromRGB(125, 85, 185)
Min.Text = "−"
Min.TextColor3 = Mau.Trang
Min.Font = Enum.Font.GothamBold
Min.TextSize = 20
Min.Active = true
BoGoc(Min, 8)

-- BẢNG TRẠNG THÁI
local BangTT = Instance.new("Frame", Main)
BangTT.Position = UDim2.fromOffset(11, 55)
BangTT.Size = UDim2.new(1, -22, 0, 43)
BangTT.BackgroundColor3 = Mau.Bang
BangTT.BorderSizePixel = 0
BangTT.Active = false
BoGoc(BangTT, 8)

local Cham = Instance.new("Frame", BangTT)
Cham.Position = UDim2.fromOffset(10, 17)
Cham.Size = UDim2.fromOffset(9, 9)
Cham.BackgroundColor3 = Mau.Xam
Cham.Active = false
BoGoc(Cham, 10)

local TrangThai = Instance.new("TextLabel", BangTT)
TrangThai.Position = UDim2.fromOffset(26, 4)
TrangThai.Size = UDim2.new(1, -32, 0, 17)
TrangThai.BackgroundTransparency = 1
TrangThai.Text = "HỆ THỐNG SẴN SÀNG"
TrangThai.TextColor3 = Mau.Trang
TrangThai.Font = Enum.Font.GothamBold
TrangThai.TextSize = 10
TrangThai.TextXAlignment = Enum.TextXAlignment.Left

local ChiTiet = Instance.new("TextLabel", BangTT)
ChiTiet.Position = UDim2.fromOffset(26, 21)
ChiTiet.Size = UDim2.new(1, -32, 0, 14)
ChiTiet.BackgroundTransparency = 1
ChiTiet.Text = "Đang chờ kích hoạt"
ChiTiet.TextColor3 = Mau.Mo
ChiTiet.Font = Enum.Font.Gotham
ChiTiet.TextSize = 9
ChiTiet.TextXAlignment = Enum.TextXAlignment.Left

local function CapNhatTT(a, b, mau)
    TrangThai.Text = a
    ChiTiet.Text = b or ""
    Cham.BackgroundColor3 = mau or Mau.Xam
end

-- BẢNG THEO DÕI KIM
local BangKim = Instance.new("Frame", Main)
BangKim.Position = UDim2.fromOffset(11, 103)
BangKim.Size = UDim2.new(1, -22, 0, 75)
BangKim.BackgroundColor3 = Mau.Bang
BangKim.BorderSizePixel = 0
BangKim.Active = false
BoGoc(BangKim, 8)

local TieuDeKim = Instance.new("TextLabel", BangKim)
TieuDeKim.Position = UDim2.fromOffset(9, 4)
TieuDeKim.Size = UDim2.new(1, -18, 0, 14)
TieuDeKim.BackgroundTransparency = 1
TieuDeKim.Text = "MÔ PHỎNG MINIGAME VÒNG TRÒN"
TieuDeKim.TextColor3 = Mau.Trang
TieuDeKim.Font = Enum.Font.GothamBold
TieuDeKim.TextSize = 9
TieuDeKim.TextXAlignment = Enum.TextXAlignment.Left

local VongTroiNen = Instance.new("Frame", BangKim)
VongTroiNen.Size = UDim2.fromOffset(45, 45)
VongTroiNen.Position = UDim2.fromOffset(12, 22)
VongTroiNen.BackgroundColor3 = Color3.fromRGB(52, 49, 67)
VongTroiNen.BorderSizePixel = 0
VongTroiNen.Active = false
local cn = Instance.new("UICorner", VongTroiNen)
cn.CornerRadius = UDim.new(1, 0)

local HolderVungXanh = Instance.new("Frame", VongTroiNen)
HolderVungXanh.Size = UDim2.new(1, 0, 1, 0)
HolderVungXanh.Position = UDim2.new(0.5, 0, 0.5, 0)
HolderVungXanh.AnchorPoint = Vector2.new(0.5, 0.5)
HolderVungXanh.BackgroundTransparency = 1

local VungXanhMinhHoi = Instance.new("Frame", HolderVungXanh)
VungXanhMinhHoi.Size = UDim2.fromOffset(12, 12)
VungXanhMinhHoi.Position = UDim2.new(0.5, -6, 0, 2)
VungXanhMinhHoi.BackgroundColor3 = Mau.XanhDuong
VungXanhMinhHoi.BorderSizePixel = 0
BoGoc(VungXanhMinhHoi, 6)

local HolderKim = Instance.new("Frame", VongTroiNen)
HolderKim.Size = UDim2.new(1, 0, 1, 0)
HolderKim.Position = UDim2.new(0.5, 0, 0.5, 0)
HolderKim.AnchorPoint = Vector2.new(0.5, 0.5)
HolderKim.BackgroundTransparency = 1

local KimMinHoi = Instance.new("Frame", HolderKim)
KimMinHoi.Size = UDim2.fromOffset(2, 20)
KimMinHoi.Position = UDim2.new(0.5, -1, 0.5, 0)
KimMinHoi.AnchorPoint = Vector2.new(0.5, 1.0)
KimMinHoi.BackgroundColor3 = Color3.fromRGB(255, 230, 100)
KimMinHoi.BorderSizePixel = 0
BoGoc(KimMinHoi, 1)

local ThongTinKim = Instance.new("TextLabel", BangKim)
ThongTinKim.Position = UDim2.fromOffset(65, 22)
ThongTinKim.Size = UDim2.new(1, -72, 0, 48)
ThongTinKim.BackgroundTransparency = 1
ThongTinKim.Text = "TRẠNG THÁI: ĐANG CHỜ..."
ThongTinKim.TextColor3 = Mau.Mo
ThongTinKim.Font = Enum.Font.Gotham
ThongTinKim.TextSize = 8
ThongTinKim.TextXAlignment = Enum.TextXAlignment.Left
ThongTinKim.TextYAlignment = Enum.TextYAlignment.Center
ThongTinKim.TextWrapped = true

-- TẠO NÚT CHỨC NĂNG
local function TaoNut(chu, y, mau)
    local b = Instance.new("TextButton", Main)
    b.Position = UDim2.fromOffset(11, y)
    b.Size = UDim2.new(1, -22, 0, 34)
    b.BackgroundColor3 = mau
    b.BorderSizePixel = 0
    b.Text = chu
    b.TextColor3 = Mau.Trang
    b.Font = Enum.Font.GothamBold
    b.TextSize = 10
    b.Active = true
    BoGoc(b, 8)
    return b
end

local function LayNhanVat()
    local ch = LP.Character
    return ch and ch:FindFirstChild("HumanoidRootPart")
end

-- CÁC NÚT ĐIỀU KHIỂN GIAO DIỆN
local NutDichChuyen = TaoNut("DI CHUYỂN ĐẾN KHU ĐÀO ĐÁ", 183, Mau.Tim)
NutDichChuyen.Activated:Connect(function()
    local root = LayNhanVat()
    if not root then
        CapNhatTT("KHÔNG TÌM THẤY NHÂN VẬT", "Hãy chờ nhân vật xuất hiện", Mau.Do)
        return
    end
    root.CFrame = CFrame.new(VI_TRI_DAO + Vector3.new(0, 3, 0))
    CapNhatTT("DI CHUYỂN THÀNH CÔNG", "Đã đến khu vực đào đá", Mau.XanhLa)
end)

local NutDao = TaoNut("TỰ ĐỘNG ĐÀO : TẮT", 223, Mau.Xam)
NutDao.Activated:Connect(function()
    CauHinh.TuDongDao = not CauHinh.TuDongDao
    NutDao.Text = "TỰ ĐỘNG ĐÀO : "..(CauHinh.TuDongDao and "BẬT" or "TẮT")
    NutDao.BackgroundColor3 = CauHinh.TuDongDao and Mau.XanhLa or Mau.Xam
end)

local NutMini = TaoNut("TỰ ĐỘNG MINIGAME : BẬT", 263, Mau.XanhLa)
NutMini.Activated:Connect(function()
    CauHinh.TuDongMinigame = not CauHinh.TuDongMinigame
    NutMini.Text = "TỰ ĐỘNG MINIGAME : "..(CauHinh.TuDongMinigame and "BẬT" or "TẮT")
    NutMini.BackgroundColor3 = CauHinh.TuDongMinigame and Mau.XanhLa or Mau.Xam
end)

local NutBat = TaoNut("BẬT ĐÀO TỰ ĐỘNG : TẮT", 303, Mau.Tim)
NutBat.Activated:Connect(function()
    CauHinh.Bat = not CauHinh.Bat
    NutBat.Text = "BẬT ĐÀO TỰ ĐỘNG : "..(CauHinh.Bat and "BẬT" or "TẮT")
    NutBat.BackgroundColor3 = CauHinh.Bat and Mau.XanhLa or Mau.Tim
    CapNhatTT(CauHinh.Bat and "HỆ THỐNG ĐANG CHẠY" or "HỆ THỐNG ĐÃ DỪNG", CauHinh.Bat and "Đang theo dõi minigame" or "Đã tạm dừng", CauHinh.Bat and Mau.XanhLa or Mau.Xam)
end)

local ThuNho = false
local KichThuocCu = Main.Size
Min.Activated:Connect(function()
    ThuNho = not ThuNho
    if ThuNho then
        KichThuocCu = Main.Size
        Main.Size = UDim2.fromOffset(260, 47)
        for _, o in ipairs(Main:GetChildren()) do
            if o ~= Header and o ~= Vien and o:IsA("GuiObject") then o.Visible = false end
        end
        Min.Text = "+"
    else
        Main.Size = KichThuocCu
        for _, o in ipairs(Main:GetChildren()) do
            if o:IsA("GuiObject") then o.Visible = true end
        end
        Min.Text = "−"
    end
end)

-- KÉO THẢ GIAO DIỆN AN TOÀN
local DangKeo = false
local ViTriBatDau, ViTriGiaoDien
Header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        DangKeo = true
        ViTriBatDau = input.Position
        ViTriGiaoDien = Main.Position
    end
end)
UIS.InputChanged:Connect(function(input)
    if DangKeo and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - ViTriBatDau
        Main.Position = UDim2.new(ViTriGiaoDien.X.Scale, ViTriGiaoDien.X.Offset + delta.X, ViTriGiaoDien.Y.Scale, ViTriGiaoDien.Y.Offset + delta.Y)
    end
end)
UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        DangKeo = false
    end
end)

-- TÌM MINIGAME VÀ ACTION BUTTON SIÊU CHÍNH XÁC
local function TimMinigame()
    for _, gui in ipairs({PG, CoreGui}) do
        local cleanGui = gui:FindFirstChild("CleanGui", true) or gui
        local mg = cleanGui:FindFirstChild("MinigameFrame", true)
        if mg and mg:IsA("Frame") and mg.Visible then
            local btn = mg:FindFirstChild("ActionButton", true) or cleanGui:FindFirstChild("ActionButton", true)
            if btn then return mg, btn end
        end
    end
    return nil, nil
end

-- KÍCH HOẠT SIÊU MẠNH (ẤN DỒN DẬP TỐC ĐỘ CAO ĐỂ ĐẢM BẢO NHẬN 3 LẦN LIÊN TIẾP)
local function BamSieuManh(button)
    if not button or not button.Parent then return end
    task.spawn(function()
        for i = 1, 2 do -- Kích hoạt lặp dồn dập 2 nhịp cực nhanh trong 1 lần bấm
            pcall(function()
                button:Activate()
                for _, conn in ipairs(getconnections(button.MouseButton1Click) or {}) do
                    conn:Fire()
                end
            end)
            pcall(function()
                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
                task.wait(0.02)
                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
            end)
            pcall(function()
                local absPos = button.AbsolutePosition
                local absSize = button.AbsoluteSize
                local centerX = absPos.X + absSize.X / 2
                local centerY = absPos.Y + absSize.Y / 2
                VirtualInputManager:SendMouseButtonEvent(centerX, centerY, 0, true, game, 1)
                VirtualInputManager:SendMouseButtonEvent(centerX, centerY, 0, false, game, 1)
            end)
            task.wait(0.03)
        end
    end)
end

local function TinhGoc(centerPos, objPos)
    local rel = objPos - centerPos
    return math.atan2(rel.Y, rel.X)
end

local TrangThaiMinigame = "CHO"

-- THEO DÕI KIM THÔNG MINH CHO CHUỖI 3 VÒNG LIÊN TIẾP
KetNoi.Minigame = RunService.RenderStepped:Connect(function()
    if not CauHinh.Bat or not CauHinh.TuDongMinigame then
        TrangThaiMinigame = "CHO"
        HolderKim.Rotation = 0
        HolderVungXanh.Rotation = 0
        return
    end

    local minigameFrame, button = TimMinigame()
    if not minigameFrame or not button then
        ThongTinKim.Text = "ĐANG CHỜ MINIGAME XUẤT HIỆN..."
        TrangThaiMinigame = "CHO"
        return
    end

    local needle = minigameFrame:FindFirstChild("Pointer", true) or minigameFrame:FindFirstChild("Needle", true) or minigameFrame:FindFirstChild("Hand", true)
    local target = minigameFrame:FindFirstChild("VisualBar", true) or minigameFrame:FindFirstChild("TargetZone", true) or minigameFrame:FindFirstChild("Bar", true)

    if needle and target then
        local center = minigameFrame.AbsolutePosition + minigameFrame.AbsoluteSize / 2
        local kimPos = needle.AbsolutePosition + needle.AbsoluteSize / 2
        local targetPos = target.AbsolutePosition + target.AbsoluteSize / 2

        local gocKim = TinhGoc(center, kimPos)
        local gocMucTieu = TinhGoc(center, targetPos)

        HolderKim.Rotation = math.deg(gocKim) + 90
        HolderVungXanh.Rotation = math.deg(gocMucTieu) + 90

        -- Tính hiệu góc hướng quay
        local hieuGoc = gocKim - gocMucTieu
        while hieuGoc > math.pi do hieuGoc = hieuGoc - (math.pi * 2) end
        while hieuGoc < -math.pi do hieuGoc = hieuGoc + (math.pi * 2) end

        ThongTinKim.Text = "ĐANG GIẢI LIÊN TIẾP\nLệch góc: " .. string.format("%.2f", hieuGoc)

        -- ĐIỀU KIỆN: Kim vừa đi qua vùng xanh (giải mượt mà qua cả 3 vòng)
        if hieuGoc >= 0.05 and hieuGoc <= CauHinh.DoLech and TrangThaiMinigame == "CHO" then
            TrangThaiMinigame = "DA_CLICK"
            CapNhatTT("ĐÃ QUA VÙNG XANH", "Đang xử lý chuỗi 3 vòng liên tiếp...", Mau.XanhLa)
            BamSieuManh(button)
            -- Thời gian hồi chiêu cực ngắn (0.25s) giúp script lập tức sẵn sàng cho vòng tiếp theo ngay lập tức
            task.delay(0.25, function()
                TrangThaiMinigame = "CHO"
            end)
        end
    else
        ThongTinKim.Text = "PHÁT HIỆN MINIGAME (AUTO CLICK)"
        BamSieuManh(button)
    end
end)

local function LayThuMucDao()
    return workspace:FindFirstChild("dao da") or workspace:FindFirstChild("Rocks") or workspace:FindFirstChild("Mining")
end

local function LayViTriPrompt(prompt)
    local parent = prompt.Parent
    if not parent then return end
    if parent:IsA("Attachment") then return parent.WorldPosition
    elseif parent:IsA("BasePart") then return parent.Position
    elseif parent:IsA("Model") then return parent:GetPivot().Position end
end

local function TimDaGanNhat()
    local root = LayNhanVat()
    local folder = LayThuMucDao()
    if not root then return end
    local tot, khoangCachTot = nil, math.huge
    for _, obj in ipairs((folder or workspace):GetDescendants()) do
        if obj:IsA("ProximityPrompt") and obj.Enabled then
            local pos = LayViTriPrompt(obj)
            if pos then
                local khoangCach = (root.Position - pos).Magnitude
                if khoangCach < khoangCachTot then
                    tot = obj
                    khoangCachTot = khoangCach
                end
            end
        end
    end
    return tot, khoangCachTot
end

task.spawn(function()
    while GUI.Parent do
        task.wait(.35)
        if CauHinh.Bat and CauHinh.TuDongDao and not CauHinh.DangBan then
            local prompt, khoangCach = TimDaGanNhat()
            if prompt and khoangCach and khoangCach <= CauHinh.KhoangCachDao then
                CauHinh.DangBan = true
                pcall(function()
                    prompt:InputHoldBegin()
                    task.wait(math.max(prompt.HoldDuration, .2))
                    prompt:InputHoldEnd()
                end)
                task.wait(.45)
                CauHinh.DangBan = false
            end
        end
    end
end)

GUI.Destroying:Connect(function()
    CauHinh.Bat = false
    CauHinh.TuDongDao = false
    CauHinh.TuDongMinigame = false
    for _, connection in pairs(KetNoi) do
        pcall(function() connection:Disconnect() end)
    end
end)

print("VND HUB | ULTIMATE V16 (HOÀN HẢO 3 VÒNG LIÊN TIẾP & KHÔNG LỖI DI CHUYỂN)")
