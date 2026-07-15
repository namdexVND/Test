local Library = loadstring(game:HttpGetAsync("https://github.com/ActualMasterOogway/Fluent-Renewed/releases/latest/download/Fluent.luau"))()
local InterfaceManager = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/ActualMasterOogway/Fluent-Renewed/master/Addons/InterfaceManager.luau"))()

local Window = Library:CreateWindow({
    Title = "Script Hub",
    SubTitle = "Made by User",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = false,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {}
local Elements = {}
local ActiveThreads = {}
local StopCallbacks = {}

local TabOrder = {"Main", "Combat", "Player", "Visuals", "Settings"}
local TabIcons = {
    Main = "phosphor-users-bold",
    Combat = "swords",
    Player = "person-standing",
    Visuals = "eye",
    Settings = "settings"
}

local SettingsFile = "ScriptHub_Settings.json"
local Settings = {}

local LoadSettings = function()
    local success, result = pcall(function()
        local data = readfile(SettingsFile)
        if data and data ~= "" then
            return game:GetService("HttpService"):JSONDecode(data)
        end
        return {}
    end)
    if success and type(result) == "table" then
        Settings = result
    else
        Settings = {}
    end
end

local SaveSettings = function()
    pcall(function()
        writefile(SettingsFile, game:GetService("HttpService"):JSONEncode(Settings))
    end)
end

LoadSettings()

local SpawnTracked = function(fn)
    local thread = task.spawn(fn)
    table.insert(ActiveThreads, thread)
    return thread
end

local StopAllLogic = function()
    for _, thread in ipairs(ActiveThreads) do
        pcall(task.cancel, thread)
    end
    ActiveThreads = {}

    for _, fn in ipairs(StopCallbacks) do
        pcall(fn)
    end
    StopCallbacks = {}
end

local GetDefault = function(Element)
    if Element.Default ~= nil then
        return Element.Default
    end
    if Element.Mode == "Toggle" then
        return false
    elseif Element.Mode == "Slider" then
        return 0
    elseif Element.Mode == "Dropdown" then
        return ""
    elseif Element.Mode == "TextBox" then
        return ""
    elseif Element.Mode == "Colorpicker" then
        return {R = 1, G = 1, B = 1}
    elseif Element.Mode == "Keybind" then
        return "LeftControl"
    end
    return nil
end

local UIConfig = {
    Main = {
        {
            Section = "Information"
        },
        {
            Id = "Welcome",
            Mode = "Label",
            Title = "Welcome to Script Hub",
            Content = "Thank you for using Script Hub. Navigate the tabs above to configure combat, player, and visual settings."
        },
        {
            Section = "Farm Settings"
        },
        {
            Id = "AutoFarm",
            Mode = "Toggle",
            Title = "Auto Farm",
            Description = "Automatically target and farm nearby mobs in range.",
            Default = false,
            Callback = function(Value)
                print("Auto Farm:", Value)
            end
        },
        {
            Id = "AutoQuest",
            Mode = "Toggle",
            Title = "Auto Quest",
            Description = "Automatically accept and complete available quests.",
            Default = false,
            Callback = function(Value)
                print("Auto Quest:", Value)
            end
        },
        {
            Id = "AutoCollect",
            Mode = "Toggle",
            Title = "Auto Collect",
            Description = "Automatically pick up dropped items and rewards.",
            Default = false,
            Callback = function(Value)
                print("Auto Collect:", Value)
            end
        },
        {
            Id = "FarmDistance",
            Mode = "Slider",
            Title = "Farm Radius",
            Description = "Maximum radius in studs to detect and engage mobs.",
            Default = 200,
            Min = 50,
            Max = 1000,
            Callback = function(Value)
                print("Farm Radius:", Value)
            end
        },
        {
            Id = "FarmMethod",
            Mode = "Dropdown",
            Title = "Attack Method",
            Description = "Choose the attack style used when farming mobs.",
            Values = {"Melee", "Sword", "Blox Fruit", "Gun"},
            Default = "Melee",
            Callback = function(Value)
                print("Attack Method:", Value)
            end
        },
        {
            Section = "Automation"
        },
        {
            Id = "AutoEat",
            Mode = "Toggle",
            Title = "Auto Eat",
            Description = "Automatically consume food when health drops below the set threshold.",
            Default = false,
            Callback = function(Value)
                print("Auto Eat:", Value)
            end
        },
        {
            Id = "EatThreshold",
            Mode = "Slider",
            Title = "Eat Health Threshold",
            Description = "Trigger auto eat when HP falls below this percentage.",
            Default = 40,
            Min = 10,
            Max = 90,
            Callback = function(Value)
                print("Eat Threshold:", Value)
            end
        },
        {
            Id = "AntiAFK",
            Mode = "Toggle",
            Title = "Anti-AFK",
            Description = "Prevent the game from kicking you due to inactivity.",
            Default = false,
            Callback = function(Value)
                print("Anti-AFK:", Value)
            end
        },
        {
            Section = "Misc"
        },
        {
            Id = "Webhook",
            Mode = "TextBox",
            Title = "Discord Webhook",
            Description = "Paste your Discord webhook URL to receive farm notifications.",
            Default = "",
            Placeholder = "https://discord.com/api/webhooks/...",
            Callback = function(Value)
                print("Webhook:", Value)
            end
        },
        {
            Id = "ToggleKey",
            Mode = "Keybind",
            Title = "Toggle UI",
            Description = "Keybind to show or hide the Script Hub window.",
            Mode2 = "Toggle",
            Default = "LeftControl"
        }
    },

    Combat = {
        {
            Section = "Kill Aura"
        },
        {
            Id = "KillAura",
            Mode = "Toggle",
            Title = "Kill Aura",
            Description = "Automatically attack all enemies within the defined aura range.",
            Default = false,
            Callback = function(Value)
                print("Kill Aura:", Value)
            end
        },
        {
            Id = "KillAuraRange",
            Mode = "Slider",
            Title = "Aura Range",
            Description = "Radius in studs that kill aura will target enemies within.",
            Default = 15,
            Min = 5,
            Max = 60,
            Callback = function(Value)
                print("Aura Range:", Value)
            end
        },
        {
            Id = "KillAuraDelay",
            Mode = "Slider",
            Title = "Attack Delay",
            Description = "Delay in milliseconds between each aura attack hit.",
            Default = 100,
            Min = 50,
            Max = 1000,
            Callback = function(Value)
                print("Attack Delay:", Value)
            end
        },
        {
            Id = "AuraTarget",
            Mode = "Dropdown",
            Title = "Target Filter",
            Description = "Select which entity types kill aura should engage.",
            Values = {"All Enemies", "Mobs Only", "Players Only"},
            Default = "Mobs Only",
            Callback = function(Value)
                print("Aura Target:", Value)
            end
        },
        {
            Section = "Combat Assist"
        },
        {
            Id = "AutoParry",
            Mode = "Toggle",
            Title = "Auto Parry",
            Description = "Automatically parry incoming attacks at the correct timing.",
            Default = false,
            Callback = function(Value)
                print("Auto Parry:", Value)
            end
        },
        {
            Id = "AutoDodge",
            Mode = "Toggle",
            Title = "Auto Dodge",
            Description = "Automatically dodge when an enemy attack is detected.",
            Default = false,
            Callback = function(Value)
                print("Auto Dodge:", Value)
            end
        },
        {
            Id = "AimAssist",
            Mode = "Toggle",
            Title = "Aim Assist",
            Description = "Smoothly snap aim toward the nearest enemy target.",
            Default = false,
            Callback = function(Value)
                print("Aim Assist:", Value)
            end
        },
        {
            Id = "AimSmoothness",
            Mode = "Slider",
            Title = "Aim Smoothness",
            Description = "Higher values make aim movement smoother and less snappy.",
            Default = 5,
            Min = 1,
            Max = 10,
            Callback = function(Value)
                print("Aim Smoothness:", Value)
            end
        }
    },

    Player = {
        {
            Section = "Movement"
        },
        {
            Id = "WalkSpeed",
            Mode = "Slider",
            Title = "Walk Speed",
            Description = "Set the player's movement speed. Default is 16.",
            Default = 16,
            Min = 16,
            Max = 250,
            Callback = function(Value)
                if game.Players.LocalPlayer.Character then
                    game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = Value
                end
            end
        },
        {
            Id = "JumpPower",
            Mode = "Slider",
            Title = "Jump Power",
            Description = "Set the player's jump height. Default is 50.",
            Default = 50,
            Min = 50,
            Max = 300,
            Callback = function(Value)
                if game.Players.LocalPlayer.Character then
                    game.Players.LocalPlayer.Character.Humanoid.JumpPower = Value
                end
            end
        },
        {
            Id = "Noclip",
            Mode = "Toggle",
            Title = "Noclip",
            Description = "Allow the player to phase through solid objects and terrain.",
            Default = false,
            Callback = function(Value)
                print("Noclip:", Value)
            end
        },
        {
            Id = "Fly",
            Mode = "Toggle",
            Title = "Fly",
            Description = "Enable free flight mode for the local player.",
            Default = false,
            Callback = function(Value)
                print("Fly:", Value)
            end
        },
        {
            Id = "FlySpeed",
            Mode = "Slider",
            Title = "Fly Speed",
            Description = "Set the movement speed while fly mode is active.",
            Default = 50,
            Min = 10,
            Max = 300,
            Callback = function(Value)
                print("Fly Speed:", Value)
            end
        },
        {
            Section = "Character"
        },
        {
            Id = "InfiniteStamina",
            Mode = "Toggle",
            Title = "Infinite Stamina",
            Description = "Prevent stamina from depleting during sprinting or combat.",
            Default = false,
            Callback = function(Value)
                print("Infinite Stamina:", Value)
            end
        },
        {
            Id = "GodMode",
            Mode = "Toggle",
            Title = "God Mode",
            Description = "Prevent the player from taking any damage.",
            Default = false,
            Callback = function(Value)
                print("God Mode:", Value)
            end
        },
        {
            Id = "Teleport",
            Mode = "Dropdown",
            Title = "Teleport Location",
            Description = "Select a preset location to instantly teleport to.",
            Values = {"Starter Village", "Marine Base", "Skylands", "Boss Arena"},
            Default = "Starter Village",
            Callback = function(Value)
                print("Teleport to:", Value)
            end
        },
        {
            Id = "TeleportBtn",
            Mode = "Button",
            Title = "Teleport Now",
            Description = "Instantly teleport to the selected location above.",
            Callback = function()
                print("Teleporting...")
            end
        }
    },

    Visuals = {
        {
            Section = "ESP"
        },
        {
            Id = "ESP",
            Mode = "Toggle",
            Title = "ESP",
            Description = "Draw boxes and labels above all visible entities.",
            Default = false,
            Callback = function(Value)
                print("ESP:", Value)
            end
        },
        {
            Id = "ESPPlayers",
            Mode = "Toggle",
            Title = "Player ESP",
            Description = "Show ESP overlays specifically on other players.",
            Default = false,
            Callback = function(Value)
                print("Player ESP:", Value)
            end
        },
        {
            Id = "ESPMobs",
            Mode = "Toggle",
            Title = "Mob ESP",
            Description = "Show ESP overlays on mobs and NPCs in the world.",
            Default = false,
            Callback = function(Value)
                print("Mob ESP:", Value)
            end
        },
        {
            Id = "ESPColor",
            Mode = "Colorpicker",
            Title = "ESP Color",
            Description = "Set the highlight color used for all ESP overlays.",
            Default = {R = 1, G = 0, B = 0},
            Callback = function(Value)
                print("ESP Color:", Value)
            end
        },
        {
            Id = "ESPDistance",
            Mode = "Slider",
            Title = "ESP Max Distance",
            Description = "Only render ESP for entities within this distance in studs.",
            Default = 500,
            Min = 50,
            Max = 2000,
            Callback = function(Value)
                print("ESP Distance:", Value)
            end
        },
        {
            Section = "World"
        },
        {
            Id = "Fullbright",
            Mode = "Toggle",
            Title = "Fullbright",
            Description = "Remove all environmental lighting to maximize visibility.",
            Default = false,
            Callback = function(Value)
                print("Fullbright:", Value)
            end
        },
        {
            Id = "FPSBoost",
            Mode = "Toggle",
            Title = "FPS Boost",
            Description = "Reduce graphic detail and effects to improve frame rate.",
            Default = false,
            Callback = function(Value)
                print("FPS Boost:", Value)
            end
        },
        {
            Id = "FOV",
            Mode = "Slider",
            Title = "Field of View",
            Description = "Adjust the camera field of view angle.",
            Default = 70,
            Min = 50,
            Max = 120,
            Callback = function(Value)
                game.Workspace.CurrentCamera.FieldOfView = Value
            end
        }
    },

    Settings = {
        {
            Section = "Settings Manager"
        },
        {
            Id = "SettingsLabel",
            Mode = "Label",
            Title = "Manage Settings",
            Content = "Reset all settings back to their default values. This will also stop all active logic and running tasks."
        },
        {
            Id = "ResetSettings",
            Mode = "Button",
            Title = "Reset to Default",
            Description = "Clear the saved settings file and restore all values to default.",
            Callback = function() end
        }
    }
}

local ResetSettings = function()
    StopAllLogic()

    Settings = {}
    pcall(function()
        delfile(SettingsFile)
    end)

    for _, Name in ipairs(TabOrder) do
        local ElementsList = UIConfig[Name]
        if type(ElementsList) == "table" then
            for _, Element in ipairs(ElementsList) do
                if type(Element) == "table" and Element.Id and Element.Mode then
                    if Element.Mode ~= "Label" and Element.Mode ~= "Button" and Element.Mode ~= "Section" then
                        local Default = GetDefault(Element)
                        pcall(function()
                            if Element.Mode == "Toggle" and Library.Options[Element.Id] then
                                Library.Options[Element.Id]:SetValue(Default)
                            elseif Element.Mode == "Slider" and Elements[Name] and Elements[Name][Element.Id] then
                                Elements[Name][Element.Id]:SetValue(Default)
                            elseif Element.Mode == "Dropdown" and Elements[Name] and Elements[Name][Element.Id] then
                                Elements[Name][Element.Id]:SetValue(Default)
                            elseif Element.Mode == "Colorpicker" and Elements[Name] and Elements[Name][Element.Id] then
                                local DefaultColor = Color3.fromRGB(Default.R * 255, Default.G * 255, Default.B * 255)
                                Elements[Name][Element.Id]:SetValueRGB(DefaultColor)
                            elseif Element.Mode == "Keybind" and Elements[Name] and Elements[Name][Element.Id] then
                                Elements[Name][Element.Id]:SetValue(Default, Element.Mode2 or "Toggle")
                            elseif Element.Mode == "TextBox" and Library.Options[Element.Id] then
                                Library.Options[Element.Id]:SetValue(Default)
                            end
                        end)
                    end
                end
            end
        end
    end

    Library:Notify({
        Title = "Settings Reset",
        Content = "All settings have been restored to their default values.",
        SubContent = "All active logic and tasks have been stopped.",
        Duration = 4
    })
end

UIConfig.Settings[3].Callback = function()
    ResetSettings()
end

local BuildElement = function(Tab, Name, Element)
    if type(Element) ~= "table" then return end

    if Element.Section then
        Tab:AddSection(Element.Section)
        return
    end

    local Mode = Element.Mode
    local Id = Element.Id

    if not Id or not Mode then return end

    if Mode == "Label" then
        Elements[Name][Id] = Tab:CreateParagraph(Id, {
            Title = Element.Title,
            Content = Element.Content
        })
        return
    end

    local Key = Name .. "_" .. Id

    if Settings[Key] == nil and Mode ~= "Button" then
        Settings[Key] = GetDefault(Element)
        SaveSettings()
    end

    if Mode == "Toggle" then
        local Default = Settings[Key]
        Elements[Name][Id] = Tab:CreateToggle(Id, {
            Title = Element.Title,
            Description = Element.Description,
            Default = Default
        })

        if Default == true and Element.Callback then
            SpawnTracked(function()
                Element.Callback(Default)
            end)
        end

        Elements[Name][Id]:OnChanged(function(Value)
            if Value == nil then return end
            Settings[Key] = Value
            SaveSettings()
            if Element.Callback then
                if Value == true then
                    SpawnTracked(function()
                        Element.Callback(Value)
                    end)
                else
                    StopAllLogic()
                    Element.Callback(Value)
                end
            end
        end)

    elseif Mode == "Slider" then
        local Default = Settings[Key]
        Elements[Name][Id] = Tab:CreateSlider(Id, {
            Title = Element.Title,
            Description = Element.Description,
            Default = Default,
            Min = Element.Min or 0,
            Max = Element.Max or 100,
            Rounding = Element.Rounding or 1
        })

        if Element.Callback then
            SpawnTracked(function()
                Element.Callback(Default)
            end)
        end

        Elements[Name][Id]:OnChanged(function(Value)
            if Value == nil then return end
            Settings[Key] = Value
            SaveSettings()
            if Element.Callback then
                Element.Callback(Value)
            end
        end)

    elseif Mode == "Dropdown" then
        local Default = Settings[Key]
        Elements[Name][Id] = Tab:CreateDropdown(Id, {
            Title = Element.Title,
            Description = Element.Description,
            Values = Element.Values or {},
            Default = Default,
            Multi = Element.Multi or false
        })

        if Element.Callback then
            SpawnTracked(function()
                Element.Callback(Default)
            end)
        end

        Elements[Name][Id]:OnChanged(function(Value)
            if Value == nil then return end
            Settings[Key] = Value
            SaveSettings()
            if Element.Callback then
                Element.Callback(Value)
            end
        end)

    elseif Mode == "Button" then
        Elements[Name][Id] = Tab:CreateButton({
            Title = Element.Title,
            Description = Element.Description,
            Callback = Element.Callback or function() end
        })

    elseif Mode == "Keybind" then
        local Default = Settings[Key]
        Elements[Name][Id] = Tab:CreateKeybind(Id, {
            Title = Element.Title,
            Description = Element.Description,
            Mode = Element.Mode2 or "Toggle",
            Default = Default
        })

        Elements[Name][Id]:OnChanged(function()
            local Value = Elements[Name][Id].Value
            if Value == nil then return end
            Settings[Key] = Value
            SaveSettings()
        end)

    elseif Mode == "Colorpicker" then
        local C = Settings[Key]
        if type(C) ~= "table" or C.R == nil then
            C = GetDefault(Element)
            Settings[Key] = C
            SaveSettings()
        end
        local DefaultColor = Color3.fromRGB(C.R * 255, C.G * 255, C.B * 255)
        Elements[Name][Id] = Tab:CreateColorpicker(Id, {
            Title = Element.Title,
            Description = Element.Description,
            Default = DefaultColor
        })

        if Element.Callback then
            SpawnTracked(function()
                Element.Callback(DefaultColor)
            end)
        end

        Elements[Name][Id]:OnChanged(function()
            local Color = Elements[Name][Id].Value
            if Color == nil then return end
            Settings[Key] = {
                R = math.floor(Color.R * 255 + 0.5) / 255,
                G = math.floor(Color.G * 255 + 0.5) / 255,
                B = math.floor(Color.B * 255 + 0.5) / 255
            }
            SaveSettings()
            if Element.Callback then
                Element.Callback(Color)
            end
        end)

    elseif Mode == "TextBox" then
        local Default = Settings[Key]
        Elements[Name][Id] = Tab:CreateInput(Id, {
            Title = Element.Title,
            Description = Element.Description,
            Default = Default,
            Placeholder = Element.Placeholder or "",
            Numeric = Element.Numeric or false,
            Finished = Element.Finished or false,
            Callback = function(Value)
                Settings[Key] = Value
                SaveSettings()
                if Element.Callback then
                    Element.Callback(Value)
                end
            end
        })
    end
end

for _, Name in ipairs(TabOrder) do
    Elements[Name] = {}
    Tabs[Name] = Window:CreateTab({
        Title = Name,
        Icon = TabIcons[Name] or ""
    })
end

for _, Name in ipairs(TabOrder) do
    local ElementsList = UIConfig[Name]
    if Tabs[Name] and type(ElementsList) == "table" then
        for _, Element in ipairs(ElementsList) do
            BuildElement(Tabs[Name], Name, Element)
        end
    end
end

InterfaceManager:SetLibrary(Library)
InterfaceManager:SetFolder("ScriptHub")
InterfaceManager:BuildInterfaceSection(Tabs.Settings)

Window:SelectTab(1)