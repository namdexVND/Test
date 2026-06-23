-- ====================================================================
-- ⚡ CBMD HUB | KEY SYSTEM - v3.0 | Cyberpunk Layout
-- ====================================================================
local HttpService  = game:GetService("HttpService")
local Players      = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService   = game:GetService("RunService")
local LocalPlayer  = Players.LocalPlayer

-- ====== CONSTANTS ======
local FILE_NAME        = "CBMD_CDVN_KEY_CACHE.txt"
local API_TOKEN        = "695f7e6a085a446e0a3e7c89"
local WEB_URL          = "https://namdexvnd.github.io/VNDhubKEY/"
local DB               = "https://vndhubkey-default-rtdb.asia-southeast1.firebasedatabase.app"
local KEY_PREFIX       = "CBMD_"
local KEY_LENGTH       = 12
local KEY_DURATION_SEC = 8 * 3600
local INT32_MAX        = 2147483647
local PERIOD_HOURS     = 8
local TIMEOUT_SEC      = 300
local COOLDOWN_SEC     = 3

-- ====== STATE ======
local keyOk     = false
local userId    = tostring(LocalPlayer.UserId)
local checking  = false
local linkReady = false

-- ====== GENERATE KEY ======
local function generateUserKey()
    local period = math.floor(os.time() / 3600 / PERIOD_HOURS)
    local seed   = (period * 9999 + tonumber(userId)) % INT32_MAX
    math.randomseed(seed)
    local s = ""
    for _ = 1, KEY_LENGTH do
        s = s .. tostring(math.random(0, 9))
    end
    return KEY_PREFIX .. s
end

local MyCurrentKey = generateUserKey()

-- ====== VALIDATE FORMAT KEY ======
local function isValidKeyFormat(k)
    if type(k) ~= "string" then return false end
    return k:match("^CBMD_[%w_]+$") ~= nil
end

-- ====== FILE LOCAL ======
local function SaveKey(k)
    if writefile then pcall(function() writefile(FILE_NAME, k) end) end
end
local function LoadKey()
    if isfile and readfile then
        local ok, val = pcall(function()
            if isfile(FILE_NAME) then return readfile(FILE_NAME) end
            return ""
        end)
        if ok then return val or "" end
    end
    return ""
end
local _cached = LoadKey()
if _cached ~= "" then SaveKey("") end

-- ====== PARSE EXPIRE ======
local function parseExpireAt(val)
    if val == nil then return 0 end
    local n = tonumber(val)
    if n then return n end
    local s = tostring(val)
    local y, m, d = s:match("^(%d%d%d%d)-(%d%d)-(%d%d)")
    if y then
        return os.time({year=tonumber(y),month=tonumber(m),day=tonumber(d),hour=23,min=59,sec=59})
    end
    local d2, m2, y2 = s:match("^(%d%d)/(%d%d)/(%d%d%d%d)")
    if d2 then
        return os.time({year=tonumber(y2),month=tonumber(m2),day=tonumber(d2),hour=23,min=59,sec=59})
    end
    return 0
end

local function resolveFirebaseData(data)
    if data.key ~= nil or data.expireAt ~= nil or data.expire ~= nil or data.type ~= nil then
        return data
    end
    local latest = nil
    local latestExp = -1
    for _, v in pairs(data) do
        if type(v) == "table" then
            local exp = parseExpireAt(v.expireAt or v.expire)
            if exp > latestExp then
                latestExp = exp
                latest = v
            end
        end
    end
    return latest
end

-- ====== FIREBASE ======
local function saveKeyToFirebase(key)
    local keyId      = key:gsub("[^%w_]", "_")
    local url        = DB .. "/keys/" .. keyId .. ".json"
    local expireTime = os.time() + KEY_DURATION_SEC
    local data = HttpService:JSONEncode({
        key      = key,
        userId   = userId,
        expireAt = expireTime,
        type     = "normal",
        created  = os.date("%d/%m/%Y %H:%M")
    })
    local ok, err = pcall(function()
        HttpService:RequestAsync({
            Url     = url,
            Method  = "PUT",
            Headers = { ["Content-Type"] = "application/json" },
            Body    = data
        })
    end)
    if not ok then warn("[CBMD] Firebase lỗi: " .. tostring(err)) end
    return ok
end

local function updateKeyWithUserId(key)
    local keyId = key:gsub("[^%w_]", "_")
    local url   = DB .. "/keys/" .. keyId .. ".json"
    local data = HttpService:JSONEncode({ userId = userId })
    local ok, err = pcall(function()
        HttpService:RequestAsync({
            Url     = url,
            Method  = "PATCH",
            Headers = { ["Content-Type"] = "application/json" },
            Body    = data
        })
    end)
    if not ok then warn("[CBMD] Firebase update lỗi: " .. tostring(err)) end
    return ok
end

-- ====== LINK RÚT GỌN ======
local TargetUrl     = WEB_URL .. "?ma=" .. MyCurrentKey
local ShortenedLink = TargetUrl

task.spawn(function()
    local api = "https://link4m.co/api-shorten/v2?api=" .. API_TOKEN
                .. "&url=" .. HttpService:UrlEncode(TargetUrl)
    local ok, res = pcall(function() return game:HttpGet(api) end)
    if ok and res then
        local s, d = pcall(function() return HttpService:JSONDecode(res) end)
        if s and d and d.status == "success" and d.shortenedUrl then
            ShortenedLink = d.shortenedUrl
        end
    end
    linkReady = true
    saveKeyToFirebase(MyCurrentKey)
end)

-- ====================================================================
-- 🎨 UI HELPERS
-- ====================================================================
local function make(cls, props, parent)
    local o = Instance.new(cls)
    for k, v in pairs(props) do o[k] = v end
    if parent then o.Parent = parent end
    return o
end
local function corner(r, p)
    Instance.new("UICorner", p).CornerRadius = UDim.new(0, r)
end
local function stroke(col, th, p)
    local s = Instance.new("UIStroke", p)
    s.Color = col; s.Thickness = th
    return s
end

-- ====================================================================
-- 🖥️  GUI  — Cyberpunk / Terminal Layout
-- ====================================================================
local SG = make("ScreenGui", {
    Name = "CBMD_KeyGui",
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling
}, LocalPlayer:WaitForChild("PlayerGui"))

-- Dimmer overlay
make("Frame", {
    Size = UDim2.new(1,0,1,0),
    BackgroundColor3 = Color3.fromRGB(0,0,0),
    BackgroundTransparency = 0.4,
    BorderSizePixel = 0,
    ZIndex = 1
}, SG)

-- ── OUTER GLOW RING (hiệu ứng pulse thay rainbow) ──────────────────
local GlowRing = make("Frame", {
    Size = UDim2.new(0, 412, 0, 330),
    Position = UDim2.new(0.5, -206, 0.5, -165),
    BackgroundColor3 = Color3.fromRGB(0, 230, 180),
    BackgroundTransparency = 0.72,
    BorderSizePixel = 0,
    ZIndex = 2
}, SG)
corner(22, GlowRing)

-- ── SCAN-LINE STRIPE (chạy từ trên xuống, hiệu ứng terminal) ───────
local ScanLine = make("Frame", {
    Size = UDim2.new(1, 0, 0, 3),
    Position = UDim2.new(0, 0, 0, 0),
    BackgroundColor3 = Color3.fromRGB(0, 255, 200),
    BackgroundTransparency = 0.2,
    BorderSizePixel = 0,
    ZIndex = 10,
    ClipsDescendants = false
}, GlowRing)

-- ── MAIN CARD ────────────────────────────────────────────────────────
local Card = make("Frame", {
    Size = UDim2.new(0, 400, 0, 318),
    Position = UDim2.new(0.5, -200, 0.5, -159),
    BackgroundColor3 = Color3.fromRGB(5, 8, 14),
    BorderSizePixel = 0,
    ClipsDescendants = true,
    BackgroundTransparency = 1,
    ZIndex = 3
}, SG)
corner(18, Card)

-- Glitch border (UIStroke animated)
local CardStroke = stroke(Color3.fromRGB(0, 220, 170), 1.8, Card)

-- Noise texture overlay (via gradient)
local noiseGrad = Instance.new("UIGradient", Card)
noiseGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0,   Color3.fromRGB(8, 12, 22)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(5,  8, 16)),
    ColorSequenceKeypoint.new(1,   Color3.fromRGB(3,  5, 12)),
})
noiseGrad.Rotation = 160

-- ── TOP BAR (terminal prompt style) ─────────────────────────────────
local TopBar = make("Frame", {
    Size = UDim2.new(1, 0, 0, 38),
    Position = UDim2.new(0, 0, 0, 0),
    BackgroundColor3 = Color3.fromRGB(0, 18, 14),
    BorderSizePixel = 0,
    ZIndex = 4
}, Card)
-- top bar divider line
make("Frame", {
    Size = UDim2.new(1, 0, 0, 1),
    Position = UDim2.new(0, 0, 1, 0),
    BackgroundColor3 = Color3.fromRGB(0, 200, 155),
    BackgroundTransparency = 0.5,
    BorderSizePixel = 0,
    ZIndex = 5
}, TopBar)

-- 3 dot circles (like macOS traffic light)
local dotColors = {
    Color3.fromRGB(255, 90, 90),
    Color3.fromRGB(255, 190, 50),
    Color3.fromRGB(0, 210, 130)
}
for i, col in ipairs(dotColors) do
    local dot = make("Frame", {
        Size = UDim2.new(0, 11, 0, 11),
        Position = UDim2.new(0, 10 + (i-1)*18, 0.5, -5),
        BackgroundColor3 = col,
        BorderSizePixel = 0,
        ZIndex = 6
    }, TopBar)
    corner(6, dot)
end

-- Terminal title
make("TextLabel", {
    Size = UDim2.new(1, -100, 1, 0),
    Position = UDim2.new(0, 68, 0, 0),
    BackgroundTransparency = 1,
    Text = "cbmd@hub:~/auth — key-verify v3.0",
    TextColor3 = Color3.fromRGB(0, 200, 155),
    Font = Enum.Font.Code,
    TextSize = 11,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 6
}, TopBar)

-- ── LOGO SECTION ─────────────────────────────────────────────────────
local LogoRow = make("Frame", {
    Size = UDim2.new(1, -32, 0, 52),
    Position = UDim2.new(0, 16, 0, 48),
    BackgroundTransparency = 1,
    ZIndex = 4
}, Card)

-- Hexagon-style badge
local Badge = make("Frame", {
    Size = UDim2.new(0, 44, 0, 44),
    Position = UDim2.new(0, 0, 0.5, -22),
    BackgroundColor3 = Color3.fromRGB(0, 30, 24),
    BorderSizePixel = 0,
    ZIndex = 5
}, LogoRow)
corner(8, Badge)
stroke(Color3.fromRGB(0, 200, 155), 1.5, Badge)

make("TextLabel", {
    Size = UDim2.new(1,0,1,0),
    BackgroundTransparency = 1,
    Text = "⚡",
    TextSize = 20,
    Font = Enum.Font.GothamBold,
    TextColor3 = Color3.fromRGB(0, 255, 190),
    ZIndex = 6
}, Badge)

-- Name + tag
make("TextLabel", {
    Size = UDim2.new(1, -56, 0, 26),
    Position = UDim2.new(0, 56, 0, 6),
    BackgroundTransparency = 1,
    Text = "CBMD HUB",
    TextColor3 = Color3.fromRGB(220, 255, 245),
    Font = Enum.Font.GothamBold,
    TextSize = 20,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 5
}, LogoRow)

make("TextLabel", {
    Size = UDim2.new(1, -56, 0, 16),
    Position = UDim2.new(0, 56, 0, 32),
    BackgroundTransparency = 1,
    Text = "[ XÁC THỰC KEY ]",
    TextColor3 = Color3.fromRGB(0, 180, 140),
    Font = Enum.Font.Code,
    TextSize = 10,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 5
}, LogoRow)

-- ── DIVIDER ──────────────────────────────────────────────────────────
local Div = make("Frame", {
    Size = UDim2.new(1, -32, 0, 1),
    Position = UDim2.new(0, 16, 0, 108),
    BackgroundColor3 = Color3.fromRGB(0, 200, 155),
    BackgroundTransparency = 0.7,
    BorderSizePixel = 0,
    ZIndex = 4
}, Card)

-- ── INPUT AREA ───────────────────────────────────────────────────────
make("TextLabel", {
    Size = UDim2.new(1, -32, 0, 14),
    Position = UDim2.new(0, 16, 0, 118),
    BackgroundTransparency = 1,
    Text = "> NHẬP KEY XÁC THỰC",
    TextColor3 = Color3.fromRGB(0, 160, 120),
    Font = Enum.Font.Code,
    TextSize = 10,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 4
}, Card)

local InputBg = make("Frame", {
    Size = UDim2.new(1, -32, 0, 44),
    Position = UDim2.new(0, 16, 0, 136),
    BackgroundColor3 = Color3.fromRGB(3, 14, 11),
    BorderSizePixel = 0,
    ZIndex = 4
}, Card)
corner(8, InputBg)
local InputStroke = stroke(Color3.fromRGB(0, 100, 80), 1.2, InputBg)

-- blinking cursor label
make("TextLabel", {
    Size = UDim2.new(0, 16, 1, 0),
    Position = UDim2.new(0, 10, 0, 0),
    BackgroundTransparency = 1,
    Text = ">",
    TextColor3 = Color3.fromRGB(0, 220, 160),
    Font = Enum.Font.Code,
    TextSize = 14,
    ZIndex = 5
}, InputBg)

local TextBox = make("TextBox", {
    Size = UDim2.new(1, -40, 1, 0),
    Position = UDim2.new(0, 26, 0, 0),
    BackgroundTransparency = 1,
    PlaceholderText = "CBMD_xxxxxxxxxxxx",
    PlaceholderColor3 = Color3.fromRGB(0, 70, 55),
    Text = "",
    TextColor3 = Color3.fromRGB(0, 255, 190),
    Font = Enum.Font.Code,
    TextSize = 13,
    ClearTextOnFocus = false,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 5
}, InputBg)

TextBox.Focused:Connect(function()
    TweenService:Create(InputStroke, TweenInfo.new(0.15),
        {Color=Color3.fromRGB(0,220,160), Thickness=1.8}):Play()
    TweenService:Create(InputBg, TweenInfo.new(0.15),
        {BackgroundColor3=Color3.fromRGB(3,20,16)}):Play()
end)
TextBox.FocusLost:Connect(function()
    TweenService:Create(InputStroke, TweenInfo.new(0.15),
        {Color=Color3.fromRGB(0,100,80), Thickness=1.2}):Play()
    TweenService:Create(InputBg, TweenInfo.new(0.15),
        {BackgroundColor3=Color3.fromRGB(3,14,11)}):Play()
end)

-- ── STATUS BOX ───────────────────────────────────────────────────────
local StatusBox = make("Frame", {
    Size = UDim2.new(1, -32, 0, 28),
    Position = UDim2.new(0, 16, 0, 186),
    BackgroundColor3 = Color3.fromRGB(3, 14, 11),
    BorderSizePixel = 0,
    Visible = false,
    ZIndex = 4
}, Card)
corner(6, StatusBox)
stroke(Color3.fromRGB(0, 120, 90), 1, StatusBox)

local StatusLabel = make("TextLabel", {
    Size = UDim2.new(1, -12, 1, 0),
    Position = UDim2.new(0, 8, 0, 0),
    BackgroundTransparency = 1,
    Text = "",
    TextColor3 = Color3.fromRGB(0, 220, 160),
    Font = Enum.Font.Code,
    TextSize = 11,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextTruncate = Enum.TextTruncate.AtEnd,
    ZIndex = 5
}, StatusBox)

-- ── BUTTONS (nằm ngang, terminal-style) ─────────────────────────────
local BtnCheck = make("TextButton", {
    Size = UDim2.new(0, 175, 0, 38),
    Position = UDim2.new(0, 16, 0, 224),
    BackgroundColor3 = Color3.fromRGB(0, 38, 30),
    Text = "[ XÁC THỰC ]",
    TextColor3 = Color3.fromRGB(0, 255, 180),
    Font = Enum.Font.Code,
    TextSize = 13,
    BorderSizePixel = 0,
    AutoButtonColor = false,
    ZIndex = 4
}, Card)
corner(6, BtnCheck)
stroke(Color3.fromRGB(0, 200, 140), 1.4, BtnCheck)

local BtnGet = make("TextButton", {
    Size = UDim2.new(0, 193, 0, 38),
    Position = UDim2.new(0, 199, 0, 224),
    BackgroundColor3 = Color3.fromRGB(10, 10, 10),
    Text = "[ ⏳ LẤY LINK... ]",
    TextColor3 = Color3.fromRGB(80, 120, 110),
    Font = Enum.Font.Code,
    TextSize = 12,
    BorderSizePixel = 0,
    AutoButtonColor = false,
    ZIndex = 4
}, Card)
corner(6, BtnGet)
stroke(Color3.fromRGB(40, 80, 70), 1, BtnGet)

-- ── FOOTER ───────────────────────────────────────────────────────────
make("TextLabel", {
    Size = UDim2.new(1, 0, 0, 16),
    Position = UDim2.new(0, 0, 0, 296),
    BackgroundTransparency = 1,
    Text = "// CBMD HUB  •  2026  •  secure auth",
    TextColor3 = Color3.fromRGB(0, 60, 50),
    Font = Enum.Font.Code,
    TextSize = 9,
    ZIndex = 4
}, Card)

-- ====================================================================
-- ⚡  ANIMATIONS
-- ====================================================================

-- 1) Card intro slide-up
TweenService:Create(Card, TweenInfo.new(0.45, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
    Position = UDim2.new(0.5, -200, 0.5, -159),
    BackgroundTransparency = 0
}):Play()
Card.Position = UDim2.new(0.5, -200, 0.6, -159)

-- 2) Scan-line sweep (top → bottom loop)
task.spawn(function()
    while Card.Parent do
        local tween = TweenService:Create(ScanLine,
            TweenInfo.new(2.2, Enum.EasingStyle.Linear),
            { Position = UDim2.new(0, 0, 1, 0) }
        )
        ScanLine.Position = UDim2.new(0, 0, 0, 0)
        tween:Play()
        tween.Completed:Wait()
        task.wait(0.1)
    end
end)

-- 3) Glitch border pulse (stroke color flicker)
task.spawn(function()
    local glitchColors = {
        Color3.fromRGB(0,  220, 170),
        Color3.fromRGB(0,  255, 210),
        Color3.fromRGB(80, 255, 200),
        Color3.fromRGB(0,  180, 140),
        Color3.fromRGB(0,  255, 255),
    }
    local i = 1
    while Card.Parent do
        task.wait(math.random(8, 22) * 0.1)
        -- short glitch burst
        for _ = 1, math.random(2, 5) do
            i = (i % #glitchColors) + 1
            CardStroke.Color = glitchColors[i]
            CardStroke.Thickness = math.random(10, 26) * 0.1
            task.wait(0.05)
        end
        -- settle
        TweenService:Create(CardStroke, TweenInfo.new(0.3),
            {Color=Color3.fromRGB(0,220,170), Thickness=1.8}):Play()
    end
end)

-- 4) GlowRing pulse
task.spawn(function()
    while GlowRing.Parent do
        TweenService:Create(GlowRing, TweenInfo.new(1.4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
            {BackgroundTransparency=0.60}):Play()
        task.wait(1.4)
        TweenService:Create(GlowRing, TweenInfo.new(1.4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
            {BackgroundTransparency=0.82}):Play()
        task.wait(1.4)
    end
end)

-- ── HOVER ──────────────────────────────────────────────────────────
local function addHover(btn, normalBg, hoverBg)
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3=hoverBg}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3=normalBg}):Play()
    end)
    btn.MouseButton1Down:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.06), {BackgroundTransparency=0.3}):Play()
    end)
    btn.MouseButton1Up:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.06), {BackgroundTransparency=0}):Play()
    end)
end
addHover(BtnCheck, Color3.fromRGB(0,38,30), Color3.fromRGB(0,55,42))
addHover(BtnGet,   Color3.fromRGB(10,10,10), Color3.fromRGB(18,28,24))

-- ── STATUS HELPER ────────────────────────────────────────────────────
local function showStatus(text, color, prefix)
    StatusBox.Visible = true
    StatusLabel.Text       = prefix .. " " .. text
    StatusLabel.TextColor3 = color
    TweenService:Create(StatusBox, TweenInfo.new(0.12), {
        BackgroundColor3 = Color3.new(color.R*0.06, color.G*0.06, color.B*0.06)
    }):Play()
end

local function setButtonsEnabled(enabled)
    BtnCheck.Active     = enabled
    BtnCheck.TextColor3 = enabled
        and Color3.fromRGB(0,255,180)
        or  Color3.fromRGB(0,80,60)
end

local function closeAndPass()
    task.wait(1.0)
    TweenService:Create(Card, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
        Position = UDim2.new(0.5,-200,0.42,-159),
        BackgroundTransparency = 1
    }):Play()
    TweenService:Create(GlowRing, TweenInfo.new(0.3),
        {BackgroundTransparency=1}):Play()
    task.wait(0.35)
    SG:Destroy()
    keyOk = true
end

-- ── LINK BUTTON READY ────────────────────────────────────────────────
task.spawn(function()
    local waited = 0
    while not linkReady and waited < 10 do
        task.wait(0.5); waited += 0.5
    end
    BtnGet.Text = ShortenedLink ~= TargetUrl
        and "[ 🔗 LẤY LINK ]"
        or  "[ 🔗 LẤY LINK (gốc) ]"
    BtnGet.TextColor3 = Color3.fromRGB(0, 220, 160)
    stroke(Color3.fromRGB(0,180,130), 1.2, BtnGet)
end)

-- ====================================================================
-- 🔘 EVENTS
-- ====================================================================
BtnGet.MouseButton1Click:Connect(function()
    if not linkReady then
        showStatus("Đang tải link...", Color3.fromRGB(255,200,0), "//")
        return
    end
    if setclipboard then
        setclipboard(ShortenedLink)
        showStatus("Đã copy! Mở link & hoàn thành quảng cáo.", Color3.fromRGB(0,220,160), ">>")
    else
        showStatus("Thiết bị không hỗ trợ copy.", Color3.fromRGB(255,100,50), "!!")
    end
end)

BtnCheck.MouseButton1Click:Connect(function()
    if checking then return end
    checking = true
    setButtonsEnabled(false)

    local input = TextBox.Text:match("^%s*(.-)%s*$")

    if input == "" then
        showStatus("Chưa nhập key!", Color3.fromRGB(255,80,80), "!!")
        task.wait(COOLDOWN_SEC); checking = false; setButtonsEnabled(true)
        return
    end

    if not isValidKeyFormat(input) then
        showStatus("Sai định dạng key (phải bắt đầu CBMD_)", Color3.fromRGB(255,60,60), "!!")
        task.wait(COOLDOWN_SEC); checking = false; setButtonsEnabled(true)
        return
    end

    showStatus("Đang xác thực...", Color3.fromRGB(255,200,0), ">>")

    local keyId = input:gsub("[^%w_]", "_")
    local url   = DB .. "/keys/" .. keyId .. ".json"
    local ok, res = pcall(function() return game:HttpGet(url) end)

    if not ok or res == nil or res == "" then
        showStatus("Lỗi kết nối Firebase!", Color3.fromRGB(255,100,0), "!!")
        task.wait(COOLDOWN_SEC); StatusBox.Visible=false; checking=false; setButtonsEnabled(true)
        return
    end

    if res == "null" then
        TextBox.Text = ""
        showStatus("Key không tồn tại! Bấm LẤY LINK.", Color3.fromRGB(255,140,0), "!!")
        task.wait(COOLDOWN_SEC); StatusBox.Visible=false; checking=false; setButtonsEnabled(true)
        return
    end

    local dok, raw = pcall(function() return HttpService:JSONDecode(res) end)
    if not dok or raw == nil then
        showStatus("Dữ liệu lỗi! Thử lại.", Color3.fromRGB(255,100,0), "!!")
        task.wait(COOLDOWN_SEC); StatusBox.Visible=false; checking=false; setButtonsEnabled(true)
        return
    end

    local data = resolveFirebaseData(raw)
    if data == nil then
        TextBox.Text = ""
        showStatus("Key không tồn tại! Bấm LẤY LINK.", Color3.fromRGB(255,140,0), "!!")
        task.wait(COOLDOWN_SEC); StatusBox.Visible=false; checking=false; setButtonsEnabled(true)
        return
    end

    local isVip      = data.type == "vip"
    local isKeyEmpty = (data.userId == nil or data.userId == "")
    local ownerOk    = isKeyEmpty or (data.userId == userId)
    local notExpired = isVip or (os.time() <= parseExpireAt(data.expireAt or data.expire))

    if not ownerOk then
        showStatus("Key không thuộc về bạn!", Color3.fromRGB(255,60,60), "!!")
        task.wait(COOLDOWN_SEC); StatusBox.Visible=false; checking=false; setButtonsEnabled(true)

    elseif not notExpired then
        local expireTs = parseExpireAt(data.expireAt or data.expire)
        local minsAgo  = math.floor((os.time() - expireTs) / 60)
        TextBox.Text   = ""
        showStatus("Hết hạn " .. minsAgo .. " phút trước!", Color3.fromRGB(255,140,0), "!!")
        task.wait(COOLDOWN_SEC); StatusBox.Visible=false; checking=false; setButtonsEnabled(true)

    else
        local timeStr
        if isVip then
            timeStr = "VIP — Vĩnh viễn 👑"
        else
            local expireTs  = parseExpireAt(data.expireAt or data.expire)
            local remaining = expireTs - os.time()
            local hrsLeft   = math.floor(remaining / 3600)
            local minsLeft  = math.floor((remaining % 3600) / 60)
            timeStr = hrsLeft > 0 and (hrsLeft.."h "..minsLeft.."m") or (minsLeft.."m")
        end

        if isKeyEmpty then
            showStatus("Đang gắn tài khoản...", Color3.fromRGB(100,255,200), ">>")
            task.wait(0.5)
            updateKeyWithUserId(input)
        end

        SaveKey(input)
        showStatus("OK  —  Còn " .. timeStr, Color3.fromRGB(0,255,180), "✓✓")
        closeAndPass()
    end
end)

-----------
--fix
-----------
repeat task.wait(0.5) until keyOk == true

------------------------------------------------------
-- 👉 DÁN CODE CHÍNH CỦA BẠN DƯỚI ĐÂY 👇
------------------------------------------------------
