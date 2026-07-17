--[[
    Glint - Da Hood / Da Hood Ripoffs Script
    UI Library: juanitahaxx by samet
]]

-- ============================
-- KEY SYSTEM
-- ============================

do
    local encoded = "aHR0cHM6Ly9nbGludC1rZXktYXBpLm9uci5hcHQvc2F2ZS8yNWM4OTI4MjY3"
    local function base64_decode(data)
        local b = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
        data = string.gsub(data, "[^" .. b .. "=]", "")
        return (data:gsub(".", function(x)
            if x == "=" then return "" end
            local r, f = "", (b:find(x) - 1)
            for i = 6, 1, -1 do r = r .. (f % 2 ^ i - f % 2 ^ (i - 1) > 0 and "1" or "0") end
            return r
        end):gsub("%d%d%d?%d?%d?%d?%d?%d?", function(x)
            if #x ~= 8 then return "" end
            local c = 0
            for i = 1, 8 do c = c + (x:sub(i, i) == "1" and 2 ^ (8 - i) or 0) end
            return string.char(c)
        end))
    end

    local API_URL = base64_decode(encoded)
    local KEY_FILE = "Glint/key.json"
    local HWID_FILE = "Glint/hwid.json"

    if not isfolder("Glint") then makefolder("Glint") end

    local function getHWID()
        if isfile(HWID_FILE) then return readfile(HWID_FILE) end
        local hwid = game:GetService("RbxAnalyticsService"):GetClientId()
        writefile(HWID_FILE, hwid)
        return hwid
    end

    local function loadSavedKey()
        if isfile(KEY_FILE) then
            local ok, data = pcall(function()
                return game:GetService("HttpService"):JSONDecode(readfile(KEY_FILE))
            end)
            if ok and data and data.key and data.expires and data.expires > os.time() then
                return data.key, data.expires
            end
        end
        return nil, nil
    end

    local function saveKey(key, expires)
        writefile(KEY_FILE, game:GetService("HttpService"):JSONEncode({
            key = key, expires = expires,
        }))
    end

    local function validateKey(key)
        local hwid = getHWID()
        local ok, resp = pcall(function()
            return game:HttpService():RequestAsync({
                Url = API_URL,
                Method = "POST",
                Headers = {["Content-Type"] = "application/json"},
                Body = game:GetService("HttpService"):JSONEncode({key = key, hwid = hwid}),
            })
        end)
        if ok and resp then
            if resp.StatusCode == 200 then
                local body = game:GetService("HttpService"):JSONDecode(resp.Body)
                return true, body.expires_in_seconds
            else
                local ok2, body = pcall(function()
                    return game:GetService("HttpService"):JSONDecode(resp.Body)
                end)
                return false, (ok2 and body and body.detail) or "Invalid key"
            end
        end
        return false, "Connection failed"
    end

    local savedKey = loadSavedKey()
    if not savedKey then
        local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/sametexe001/juanitahaxx/refs/heads/main/Library.lua"))()
        local KeyWindow = Library:Window({Name = "Glint"})
        local KeyPage = KeyWindow:Page({Name = "Key"})
        local KeySection = KeyPage:Section({Name = "License Key", Side = 1})
        local InfoSection = KeyPage:Section({Name = "Info", Side = 2})
        local KeyInput = ""
        local KeyVerified = false

        InfoSection:Label({Name = "Glint - Da Hood Script"})
        InfoSection:Label({Name = ""})
        InfoSection:Label({Name = "Enter your license key"})
        InfoSection:Label({Name = "to use the script."})
        InfoSection:Label({Name = ""})
        InfoSection:Label({Name = "Get a key from the seller"})

        KeySection:Textbox({
            Name = "License Key",
            Flag = "LicenseKeyInput",
            Placeholder = "GLINT-XXXX-XXXX",
            Default = "",
            Callback = function(v) KeyInput = v end
        })

        KeySection:Button({
            Name = "Submit Key",
            Callback = function()
                if KeyInput == "" then
                    Library:Notification("Enter a key!", 3, Color3.fromRGB(255, 50, 50))
                    return
                end
                Library:Notification("Validating...", 3, Color3.fromRGB(176, 176, 209))
                local valid, result = validateKey(KeyInput)
                if valid then
                    saveKey(KeyInput, os.time() + result)
                    Library:Notification("Key verified! Loading...", 3, Color3.fromRGB(50, 255, 50))
                    KeyVerified = true
                else
                    Library:Notification("Invalid: " .. tostring(result), 5, Color3.fromRGB(255, 50, 50))
                end
            end
        })

        local Watermark = KeyWindow:Watermark({Name = "Glint"})
        KeyWindow:Init()
        repeat task.wait(0.5) until KeyVerified
        pcall(function() Library:Exit() end)
        task.wait(0.5)
    end
end

-- ============================
-- MAIN SCRIPT
-- ============================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera

workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
    Camera = workspace.CurrentCamera
end)

if getgenv().GlintLoaded then
    pcall(function()
        getgenv().GlintLoaded = false
        for _, v in (getgenv().GlintConnections or {}) do
            pcall(function() v:Disconnect() end)
        end
    end)
end

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/sametexe001/juanitahaxx/refs/heads/main/Library.lua"))()

getgenv().GlintLoaded = true
local GlintFlags = {
    AimbotEnabled = false, FOVEnabled = true, FOVSize = 150, FOVFilled = false,
    FOVColor = Color3.fromRGB(176, 176, 209), FOVAlpha = 0.8, TargetPart = "Head",
    AimbotSmoothness = 50, AimbotPrediction = 0.165, AimbotMethod = "Camera",
    TeamCheck = false, WallCheck = false,
    SilentAimEnabled = false, SilentAimPart = "Head", SilentAimPrediction = 0.165,
    SilentAimHitChance = 100, SilentAimShowFOV = false, SilentAimFOVSize = 250,
    SilentAimFOVColor = Color3.fromRGB(255, 0, 0), SilentAimFOVAlpha = 0.6,
    ESPEnabled = false, ESPBoxes = true, ESPBoxColor = Color3.fromRGB(255, 255, 255),
    ESPNames = true, ESPNameColor = Color3.fromRGB(255, 255, 255),
    ESPHealthBar = true, ESPHealthText = true, ESPDistance = true,
    ESPTracers = false, ESPTracerColor = Color3.fromRGB(176, 176, 209),
    ESPSkeleton = false, ESPSkeletonColor = Color3.fromRGB(200, 200, 200),
    ESPHeadDot = false, ESPSnaplines = false, ESPSnaplineColor = Color3.fromRGB(176, 176, 209),
    ESPMaxDistance = 2000,
    ChamsEnabled = false, ChamsFillColor = Color3.fromRGB(176, 176, 209),
    ChamsOutlineColor = Color3.fromRGB(255, 255, 255), ChamsTransparency = 75,
    CrosshairEnabled = false, CrosshairSize = 8, CrosshairColor = Color3.fromRGB(255, 50, 50),
    CrosshairGap = 3,
    SpeedEnabled = false, SpeedValue = 16,
    FlyEnabled = false, FlySpeed = 80,
    NoClipEnabled = false, InfiniteJumpEnabled = false, JumpPowerValue = 50,
    AntiAFK = true, AutoReset = false, AutoResetHealth = 30,
}
getgenv().GlintFlags = GlintFlags
local Connections = {}
getgenv().GlintConnections = Connections

local function Connect(signal, callback)
    local conn = signal:Connect(callback)
    table.insert(Connections, conn)
    return conn
end

-- ============================
-- DA HOOD UTILITIES
-- ============================

local function isKoed(player)
    if not player or not player.Character then return true end
    local bodyEffects = player.Character:FindFirstChild("BodyEffects")
    if bodyEffects then
        local ko = bodyEffects:FindFirstChild("K.O")
        if ko and ko.Value then return true end
    end
    if player.Character:FindFirstChild("GRABBING_CONSTRAINT") then return true end
    return false
end

local function isAlive(player)
    if not player or not player.Character then return false end
    local hrp = player.Character:FindFirstChild("HumanoidRootPart")
    local hum = player.Character:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum or hum.Health <= 0 then return false end
    if isKoed(player) then return false end
    return true
end

local function getTeamCheck(player)
    if not player then return false end
    if GlintFlags.TeamCheck and player.Team and player.Team == LocalPlayer.Team then
        return true
    end
    return false
end

local function getWallCheck(player)
    if not player or not player.Character or not GlintFlags.WallCheck then return false end
    local hrp = player.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    local myChar = LocalPlayer.Character
    if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return false end
    local params = RaycastParams.new()
    params.FilterDescendantsInstances = {LocalPlayer.Character}
    params.FilterType = Enum.RaycastFilterType.Exclude
    local result = workspace:Raycast(Camera.CFrame.Position, hrp.Position - Camera.CFrame.Position, params)
    if result then
        local hitModel = result.Instance:FindFirstAncestorOfClass("Model")
        if hitModel and hitModel ~= player.Character then return true end
    end
    return false
end

local function getClosestPlayer()
    local closest, shortest = nil, math.huge
    local screenCenter = Camera.ViewportSize / 2
    for _, player in Players:GetPlayers() do
        if player == LocalPlayer then continue end
        if not isAlive(player) or getTeamCheck(player) or getWallCheck(player) then continue end
        local hrp = player.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then continue end
        local screenPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
        if not onScreen then continue end
        local dist = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
        if GlintFlags.FOVEnabled and dist > (GlintFlags.FOVSize or 150) then continue end
        if dist < shortest then shortest = dist; closest = player end
    end
    return closest
end

local function getTargetPart(player)
    if not player or not player.Character then return nil end
    return player.Character:FindFirstChild(GlintFlags.TargetPart or "Head")
        or player.Character:FindFirstChild("HumanoidRootPart")
end

local function getTargetPartByName(player, partName)
    if not player or not player.Character then return nil end
    return player.Character:FindFirstChild(partName)
        or player.Character:FindFirstChild("HumanoidRootPart")
end

-- ============================
-- UI SETUP
-- ============================

local Window = Library:Window({Name = "Glint"})
local Watermark = Window:Watermark({Name = "Glint"})
local KeybindList = Window:KeybindList()

do
    local FPS, FrameCount, Elapsed = 0, 0, 0
    local FPSLabel = Watermark:Add("FPS: ")
    local TimeLabel = Watermark:Add("")
    Connect(RunService.RenderStepped, function(dt)
        FrameCount += 1; Elapsed += dt
        if Elapsed >= 1 then
            FPS = math.floor(FrameCount / Elapsed)
            FPSLabel:SetText("FPS: " .. FPS)
            FrameCount, Elapsed = 0, 0
        end
        TimeLabel:SetText("Glint | " .. os.date("%H:%M:%S"))
    end)
end

-- ============================
-- COMBAT TAB
-- ============================

local CombatPage = Window:Page({Name = "Combat"})
local AimbotSection = CombatPage:Section({Name = "Aimbot", Side = 1})
local SilentAimSection = CombatPage:Section({Name = "Silent Aim", Side = 2})

do
    AimbotSection:Toggle({Name = "Aimbot", Flag = "AimbotEnabled", Default = false,
        Callback = function(v) GlintFlags.AimbotEnabled = v end
    }):Keybind({Flag = "AimbotKeybind", Default = Enum.KeyCode.P, Mode = "Toggle",
        Callback = function(state) GlintFlags.AimbotEnabled = state end
    })
    AimbotSection:Toggle({Name = "FOV Circle", Flag = "FOVEnabled", Default = true,
        Callback = function(v) GlintFlags.FOVEnabled = v end
    })
    AimbotSection:Slider({Name = "FOV Size", Flag = "FOVSize", Min = 10, Max = 800, Default = 150, Decimals = 1, Suffix = "px",
        Callback = function(v) GlintFlags.FOVSize = v end
    })
    AimbotSection:Toggle({Name = "FOV Filled", Flag = "FOVFilled", Default = false,
        Callback = function(v) GlintFlags.FOVFilled = v end
    })
    AimbotSection:Label({Name = "FOV Color"}):Colorpicker({Flag = "FOVColor", Default = Color3.fromRGB(176, 176, 209),
        Callback = function(color) GlintFlags.FOVColor = color end
    })
    AimbotSection:Dropdown({Name = "Target Part", Flag = "TargetPart", Items = {"Head", "HumanoidRootPart", "UpperTorso", "LowerTorso"}, Default = "Head", Multi = false,
        Callback = function(v) GlintFlags.TargetPart = v end
    })
    AimbotSection:Slider({Name = "Smoothness", Flag = "AimbotSmoothness", Min = 1, Max = 100, Default = 50, Decimals = 1, Suffix = "%",
        Callback = function(v) GlintFlags.AimbotSmoothness = v end
    })
    AimbotSection:Slider({Name = "Prediction", Flag = "AimbotPrediction", Min = 0, Max = 1, Default = 0.165, Decimals = 3, Suffix = "s",
        Callback = function(v) GlintFlags.AimbotPrediction = v end
    })
    AimbotSection:Toggle({Name = "Team Check", Flag = "TeamCheck", Default = false, Callback = function(v) GlintFlags.TeamCheck = v end})
    AimbotSection:Toggle({Name = "Wall Check", Flag = "WallCheck", Default = false, Callback = function(v) GlintFlags.WallCheck = v end})
    AimbotSection:Dropdown({Name = "Aimbot Method", Flag = "AimbotMethod", Items = {"Camera", "Mouse"}, Default = "Camera", Multi = false,
        Callback = function(v) GlintFlags.AimbotMethod = v end
    })
end

do
    SilentAimSection:Toggle({Name = "Silent Aim", Flag = "SilentAimEnabled", Default = false,
        Callback = function(v) GlintFlags.SilentAimEnabled = v end
    }):Keybind({Flag = "SilentAimKeybind", Default = Enum.KeyCode.Q, Mode = "Toggle",
        Callback = function(state) GlintFlags.SilentAimEnabled = state end
    })
    SilentAimSection:Dropdown({Name = "Target Part", Flag = "SilentAimPart", Items = {"Head", "HumanoidRootPart", "UpperTorso", "LowerTorso"}, Default = "Head", Multi = false,
        Callback = function(v) GlintFlags.SilentAimPart = v end
    })
    SilentAimSection:Slider({Name = "Prediction", Flag = "SilentAimPrediction", Min = 0, Max = 1, Default = 0.165, Decimals = 3, Suffix = "s",
        Callback = function(v) GlintFlags.SilentAimPrediction = v end
    })
    SilentAimSection:Slider({Name = "Hit Chance", Flag = "SilentAimHitChance", Min = 0, Max = 100, Default = 100, Decimals = 1, Suffix = "%",
        Callback = function(v) GlintFlags.SilentAimHitChance = v end
    })
    SilentAimSection:Toggle({Name = "Show FOV", Flag = "SilentAimShowFOV", Default = false,
        Callback = function(v) GlintFlags.SilentAimShowFOV = v end
    })
    SilentAimSection:Slider({Name = "FOV Size", Flag = "SilentAimFOVSize", Min = 10, Max = 800, Default = 250, Decimals = 1, Suffix = "px",
        Callback = function(v) GlintFlags.SilentAimFOVSize = v end
    })
    SilentAimSection:Label({Name = "FOV Color"}):Colorpicker({Flag = "SilentAimFOVColor", Default = Color3.fromRGB(255, 0, 0),
        Callback = function(color) GlintFlags.SilentAimFOVColor = color end
    })
    SilentAimSection:Label({Name = "Silent Aim redirects your mouse hit to the closest enemy with velocity prediction."})
end

-- ============================
-- VISUALS TAB
-- ============================

local VisualsPage = Window:Page({Name = "Visuals"})
local ESPSection = VisualsPage:Section({Name = "ESP", Side = 1})
local EffectSection = VisualsPage:Section({Name = "Effects & Chams", Side = 2})

do
    ESPSection:Toggle({Name = "Enable ESP", Flag = "ESPEnabled", Default = false, Callback = function(v) GlintFlags.ESPEnabled = v end})
    ESPSection:Toggle({Name = "Boxes", Flag = "ESPBoxes", Default = true, Callback = function(v) GlintFlags.ESPBoxes = v end})
    ESPSection:Label({Name = "Box Color"}):Colorpicker({Flag = "ESPBoxColor", Default = Color3.fromRGB(255, 255, 255), Callback = function(c) GlintFlags.ESPBoxColor = c end})
    ESPSection:Toggle({Name = "Names", Flag = "ESPNames", Default = true, Callback = function(v) GlintFlags.ESPNames = v end})
    ESPSection:Label({Name = "Name Color"}):Colorpicker({Flag = "ESPNameColor", Default = Color3.fromRGB(255, 255, 255), Callback = function(c) GlintFlags.ESPNameColor = c end})
    ESPSection:Toggle({Name = "Health Bar", Flag = "ESPHealthBar", Default = true, Callback = function(v) GlintFlags.ESPHealthBar = v end})
    ESPSection:Toggle({Name = "Health Text", Flag = "ESPHealthText", Default = true, Callback = function(v) GlintFlags.ESPHealthText = v end})
    ESPSection:Toggle({Name = "Distance", Flag = "ESPDistance", Default = true, Callback = function(v) GlintFlags.ESPDistance = v end})
    ESPSection:Toggle({Name = "Tracers", Flag = "ESPTracers", Default = false, Callback = function(v) GlintFlags.ESPTracers = v end})
    ESPSection:Label({Name = "Tracer Color"}):Colorpicker({Flag = "ESPTracerColor", Default = Color3.fromRGB(176, 176, 209), Callback = function(c) GlintFlags.ESPTracerColor = c end})
    ESPSection:Toggle({Name = "Skeleton", Flag = "ESPSkeleton", Default = false, Callback = function(v) GlintFlags.ESPSkeleton = v end})
    ESPSection:Label({Name = "Skeleton Color"}):Colorpicker({Flag = "ESPSkeletonColor", Default = Color3.fromRGB(200, 200, 200), Callback = function(c) GlintFlags.ESPSkeletonColor = c end})
    ESPSection:Toggle({Name = "Head Dot", Flag = "ESPHeadDot", Default = false, Callback = function(v) GlintFlags.ESPHeadDot = v end})
    ESPSection:Toggle({Name = "Snaplines", Flag = "ESPSnaplines", Default = false, Callback = function(v) GlintFlags.ESPSnaplines = v end})
    ESPSection:Label({Name = "Snapline Color"}):Colorpicker({Flag = "ESPSnaplineColor", Default = Color3.fromRGB(176, 176, 209), Callback = function(c) GlintFlags.ESPSnaplineColor = c end})
    ESPSection:Slider({Name = "Max Distance", Flag = "ESPMaxDistance", Min = 50, Max = 5000, Default = 2000, Decimals = 1, Suffix = "m", Callback = function(v) GlintFlags.ESPMaxDistance = v end})
end

do
    EffectSection:Toggle({Name = "Chams", Flag = "ChamsEnabled", Default = false, Callback = function(v) GlintFlags.ChamsEnabled = v end})
    EffectSection:Label({Name = "Chams Fill"}):Colorpicker({Flag = "ChamsFillColor", Default = Color3.fromRGB(176, 176, 209), Callback = function(c) GlintFlags.ChamsFillColor = c end})
    EffectSection:Label({Name = "Chams Outline"}):Colorpicker({Flag = "ChamsOutlineColor", Default = Color3.fromRGB(255, 255, 255), Callback = function(c) GlintFlags.ChamsOutlineColor = c end})
    EffectSection:Slider({Name = "Chams Transparency", Flag = "ChamsTransparency", Min = 0, Max = 100, Default = 75, Decimals = 1, Suffix = "%", Callback = function(v) GlintFlags.ChamsTransparency = v end})
    EffectSection:Toggle({Name = "Crosshair", Flag = "CrosshairEnabled", Default = false, Callback = function(v) GlintFlags.CrosshairEnabled = v end})
    EffectSection:Slider({Name = "Crosshair Size", Flag = "CrosshairSize", Min = 2, Max = 30, Default = 8, Decimals = 1, Suffix = "px", Callback = function(v) GlintFlags.CrosshairSize = v end})
    EffectSection:Label({Name = "Crosshair Color"}):Colorpicker({Flag = "CrosshairColor", Default = Color3.fromRGB(255, 50, 50), Callback = function(c) GlintFlags.CrosshairColor = c end})
    EffectSection:Slider({Name = "Crosshair Gap", Flag = "CrosshairGap", Min = 0, Max = 15, Default = 3, Decimals = 1, Suffix = "px", Callback = function(v) GlintFlags.CrosshairGap = v end})
end

-- ============================
-- MISC TAB
-- ============================

local MiscPage = Window:Page({Name = "Misc"})
local MoveSection = MiscPage:Section({Name = "Movement", Side = 1})
local MiscSection2 = MiscPage:Section({Name = "Miscellaneous", Side = 2})

do
    MoveSection:Toggle({Name = "Speed", Flag = "SpeedEnabled", Default = false,
        Callback = function(v) GlintFlags.SpeedEnabled = v; if not v then pcall(function() local h = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid"); if h then h.WalkSpeed = 16 end end) end end
    }):Keybind({Flag = "SpeedKeybind", Default = Enum.KeyCode.J, Mode = "Toggle", Callback = function(s) GlintFlags.SpeedEnabled = s end})
    MoveSection:Slider({Name = "Walk Speed", Flag = "SpeedValue", Min = 16, Max = 500, Default = 16, Decimals = 1, Suffix = " studs/s", Callback = function(v) GlintFlags.SpeedValue = v end})
    MoveSection:Toggle({Name = "Fly", Flag = "FlyEnabled", Default = false,
        Callback = function(v)
            GlintFlags.FlyEnabled = v
            if not v then pcall(function()
                local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if hrp then for _, o in hrp:GetChildren() do if o:IsA("BodyVelocity") or o:IsA("BodyGyro") then o:Destroy() end end end
                local h = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid"); if h then h.PlatformStand = false end
            end) end
        end
    }):Keybind({Flag = "FlyKeybind", Default = Enum.KeyCode.N, Mode = "Toggle", Callback = function(s) GlintFlags.FlyEnabled = s end})
    MoveSection:Slider({Name = "Fly Speed", Flag = "FlySpeed", Min = 10, Max = 200, Default = 80, Decimals = 1, Suffix = " studs/s", Callback = function(v) GlintFlags.FlySpeed = v end})
    MoveSection:Toggle({Name = "No Clip", Flag = "NoClipEnabled", Default = false, Callback = function(v) GlintFlags.NoClipEnabled = v end})
    MoveSection:Toggle({Name = "Infinite Jump", Flag = "InfiniteJumpEnabled", Default = false, Callback = function(v) GlintFlags.InfiniteJumpEnabled = v end})
    MoveSection:Slider({Name = "Jump Power", Flag = "JumpPowerValue", Min = 50, Max = 500, Default = 50, Decimals = 1, Suffix = " studs", Callback = function(v) GlintFlags.JumpPowerValue = v end})
end

do
    MiscSection2:Toggle({Name = "Anti AFK", Flag = "AntiAFK", Default = true, Callback = function(v) GlintFlags.AntiAFK = v end})
    MiscSection2:Toggle({Name = "Auto Reset", Flag = "AutoReset", Default = false, Callback = function(v) GlintFlags.AutoReset = v end})
    MiscSection2:Slider({Name = "Reset Health", Flag = "AutoResetHealth", Min = 1, Max = 100, Default = 30, Decimals = 1, Suffix = " HP", Callback = function(v) GlintFlags.AutoResetHealth = v end})
    MiscSection2:Button({Name = "Rejoin Server", Callback = function()
        game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
    end})
    MiscSection2:Button({Name = "Server Hop", Callback = function()
        pcall(function()
            local s = game:GetService("HttpService"):JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
            for _, srv in s.data do if srv.id ~= game.JobId then game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, srv.id, LocalPlayer); break end end
        end)
    end})
    MiscSection2:Button({Name = "Anti Lag", Callback = function()
        pcall(function()
            for _, v in workspace:GetDescendants() do
                if v:IsA("BasePart") and not v:IsDescendantOf(LocalPlayer.Character or nil) then v.Material = Enum.Material.SmoothPlastic
                elseif v:IsA("Decal") or v:IsA("Texture") or v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Beam") then v:Destroy() end
            end
            collectgarbage("collect")
        end)
    end})
end

-- ============================
-- FOV CIRCLES (ScreenGui)
-- ============================

do
    local fovGui = Instance.new("ScreenGui")
    fovGui.Name = "GlintFOV"; fovGui.IgnoreGuiInset = true; fovGui.DisplayOrder = 998
    fovGui.Parent = LocalPlayer.PlayerGui

    local aimbotFOV = Instance.new("Frame"); aimbotFOV.Name = "AimbotFOV"
    aimbotFOV.AnchorPoint = Vector2.new(0.5, 0.5); aimbotFOV.BackgroundTransparency = 0.85
    aimbotFOV.BackgroundColor3 = Color3.fromRGB(176, 176, 209); aimbotFOV.BorderSizePixel = 0
    aimbotFOV.Visible = false; aimbotFOV.Parent = fovGui
    Instance.new("UICorner", aimbotFOV).CornerRadius = UDim.new(1, 0)
    local as = Instance.new("UIStroke", aimbotFOV); as.Thickness = 1.5; as.Color = Color3.fromRGB(176, 176, 209); as.Transparency = 0.2

    local silentFOV = Instance.new("Frame"); silentFOV.Name = "SilentFOV"
    silentFOV.AnchorPoint = Vector2.new(0.5, 0.5); silentFOV.BackgroundTransparency = 1
    silentFOV.BackgroundColor3 = Color3.fromRGB(255, 0, 0); silentFOV.BorderSizePixel = 0
    silentFOV.Visible = false; silentFOV.Parent = fovGui
    Instance.new("UICorner", silentFOV).CornerRadius = UDim.new(1, 0)
    local ss = Instance.new("UIStroke", silentFOV); ss.Thickness = 1.5; ss.Color = Color3.fromRGB(255, 0, 0); ss.Transparency = 0.4

    Connect(RunService.RenderStepped, function()
        local cx, cy = Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2
        local as2 = (GlintFlags.FOVSize or 150) * 2
        aimbotFOV.Size = UDim2.new(0, as2, 0, as2); aimbotFOV.Position = UDim2.new(0, cx, 0, cy)
        aimbotFOV.Visible = GlintFlags.FOVEnabled and GlintFlags.AimbotEnabled
        aimbotFOV.BackgroundTransparency = GlintFlags.FOVFilled and 0.7 or 1
        aimbotFOV.BackgroundColor3 = GlintFlags.FOVColor or Color3.fromRGB(176, 176, 209)
        as.Color = GlintFlags.FOVColor or Color3.fromRGB(176, 176, 209)

        local ss2 = (GlintFlags.SilentAimFOVSize or 250) * 2
        silentFOV.Size = UDim2.new(0, ss2, 0, ss2); silentFOV.Position = UDim2.new(0, cx, 0, cy)
        silentFOV.Visible = GlintFlags.SilentAimShowFOV and GlintFlags.SilentAimEnabled
        silentFOV.BackgroundColor3 = GlintFlags.SilentAimFOVColor or Color3.fromRGB(255, 0, 0)
        ss.Color = GlintFlags.SilentAimFOVColor or Color3.fromRGB(255, 0, 0)
    end)
end

-- ============================
-- AIMBOT (Camera CFrame)
-- ============================

Connect(RunService.RenderStepped, function()
    if GlintFlags.AimbotEnabled then
        local target = getClosestPlayer()
        if target and target.Character then
            local targetPart = getTargetPart(target)
            if targetPart then
                local pred = GlintFlags.AimbotPrediction or 0.165
                local pos = targetPart.Position + (targetPart.Velocity * pred)
                local smooth = math.clamp((GlintFlags.AimbotSmoothness or 50) / 100, 0.01, 1)
                if GlintFlags.AimbotMethod == "Camera" then
                    Camera.CFrame = Camera.CFrame:Lerp(CFrame.lookAt(Camera.CFrame.Position, pos), 1 - smooth)
                end
            end
        end
    end
end)

-- ============================
-- SILENT AIM (__index hook on Mouse)
-- ============================

do
    local OldIndex
    local success, err = pcall(function()
        OldIndex = hookmetamethod(game, "__index", newcclosure(function(self, k)
            if self == Mouse and (k == "Hit" or k == "Target") and not checkcaller() and GlintFlags.SilentAimEnabled then
                local target = getClosestPlayer()
                if target and target.Character then
                    local targetPart = getTargetPartByName(target, GlintFlags.SilentAimPart or "Head")
                    if targetPart then
                        if math.random(100) <= (GlintFlags.SilentAimHitChance or 100) then
                            local pred = GlintFlags.SilentAimPrediction or 0.165
                            local predictedPos = targetPart.Position + (targetPart.Velocity * pred)
                            if k == "Hit" then return CFrame.new(predictedPos) elseif k == "Target" then return targetPart end
                        end
                    end
                end
            end
            return OldIndex(self, k)
        end))
    end)
end

-- ============================
-- SPEED
-- ============================

Connect(RunService.Heartbeat, function()
    if GlintFlags.SpeedEnabled then
        pcall(function()
            local h = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if h then h.WalkSpeed = GlintFlags.SpeedValue or 16 end
        end)
    end
end)

-- ============================
-- FLY (BodyVelocity + BodyGyro)
-- ============================

do
    local flyBV, flyBG = nil, nil
    Connect(RunService.RenderStepped, function()
        if GlintFlags.FlyEnabled then
            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if not hrp or not hum then return end
            if not flyBV or not flyBV.Parent then
                flyBV = Instance.new("BodyVelocity"); flyBV.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                flyBV.Velocity = Vector3.zero; flyBV.P = 1e5; flyBV.Parent = hrp
            end
            if not flyBG or not flyBG.Parent then
                flyBG = Instance.new("BodyGyro"); flyBG.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
                flyBG.P = 1e5; flyBG.D = 5000; flyBG.Parent = hrp
            end
            flyBV.Velocity = Camera.CFrame.LookVector * (GlintFlags.FlySpeed or 80)
            flyBG.CFrame = Camera.CFrame
            hum.PlatformStand = true
        else
            if flyBV and flyBV.Parent then flyBV:Destroy(); flyBV = nil end
            if flyBG and flyBG.Parent then flyBG:Destroy(); flyBG = nil end
            pcall(function() local h = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid"); if h then h.PlatformStand = false end end)
        end
    end)
    Connect(LocalPlayer.CharacterAdded, function() task.wait(0.5); flyBV, flyBG = nil, nil end)
end

-- ============================
-- NOCLIP
-- ============================

Connect(RunService.Stepped, function()
    if GlintFlags.NoClipEnabled then
        pcall(function()
            local char = LocalPlayer.Character
            if char then for _, p in char:GetDescendants() do if p:IsA("BasePart") then p.CanCollide = false end end end
        end)
    end
end)

-- ============================
-- INFINITE JUMP
-- ============================

Connect(UserInputService.JumpRequest, function()
    if GlintFlags.InfiniteJumpEnabled then
        pcall(function() local h = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid"); if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end end)
    end
end)

-- ============================
-- JUMP POWER
-- ============================

Connect(RunService.Heartbeat, function()
    pcall(function()
        local h = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if h and GlintFlags.JumpPowerValue and GlintFlags.JumpPowerValue > 50 then h.UseJumpPower = true; h.JumpPower = GlintFlags.JumpPowerValue end
    end)
end)

-- ============================
-- ANTI AFK
-- ============================

do
    local VU = game:GetService("VirtualUser")
    Connect(LocalPlayer.Idled, function()
        if GlintFlags.AntiAFK then pcall(function() VU:Button2Down(Vector2.new(0,0), Camera.CFrame); task.wait(0.1); VU:Button2Up(Vector2.new(0,0), Camera.CFrame) end) end
    end)
end

-- ============================
-- AUTO RESET
-- ============================

Connect(RunService.Heartbeat, function()
    if GlintFlags.AutoReset then
        pcall(function()
            local char = LocalPlayer.Character
            if char then local h = char:FindFirstChildOfClass("Humanoid"); if h and h.Health > 0 and h.Health <= (GlintFlags.AutoResetHealth or 30) then h.Health = 0 end end
        end)
    end
end)

-- ============================
-- CROSSHAIR (ScreenGui)
-- ============================

do
    local chGui = Instance.new("ScreenGui"); chGui.Name = "GlintCrosshair"; chGui.IgnoreGuiInset = true; chGui.DisplayOrder = 999; chGui.Parent = LocalPlayer.PlayerGui
    local lines = {}
    for i = 1, 4 do
        local l = Instance.new("Frame"); l.Name = "CH_"..i; l.AnchorPoint = Vector2.new(0.5, 0.5)
        l.BackgroundColor3 = Color3.fromRGB(255, 50, 50); l.BorderSizePixel = 0; l.Visible = false; l.Parent = chGui
        table.insert(lines, l)
    end
    local dirs = {{0,-1},{0,1},{-1,0},{1,0}}
    Connect(RunService.RenderStepped, function()
        local en, sz, gp, cl = GlintFlags.CrosshairEnabled, GlintFlags.CrosshairSize or 8, GlintFlags.CrosshairGap or 3, GlintFlags.CrosshairColor or Color3.fromRGB(255, 50, 50)
        local cx, cy = Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2
        if not en then for _, l in lines do l.Visible = false end return end
        for i, l in lines do
            l.BackgroundColor3 = cl; l.Visible = true
            local dx, dy = dirs[i][1], dirs[i][2]
            if dx ~= 0 then l.Size = UDim2.new(0, sz, 0, 2); l.Position = UDim2.new(0, cx + dx * (gp + sz/2), 0, cy)
            else l.Size = UDim2.new(0, 2, 0, sz); l.Position = UDim2.new(0, cx, 0, cy + dy * (gp + sz/2)) end
        end
    end)
end

-- ============================
-- ESP SYSTEM (BillboardGui + Highlight + Beams)
-- ============================

do
    local ESPStorage = Instance.new("Folder"); ESPStorage.Name = "GlintESP"; ESPStorage.Parent = LocalPlayer.PlayerGui

    local function destroyESP(player)
        local f = ESPStorage:FindFirstChild(player.UserId .. "_esp"); if f then f:Destroy() end
    end

    local function createESP(player)
        if player == LocalPlayer then return end
        if not player.Character then return end
        local char = player.Character
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local head = char:FindFirstChild("Head")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hrp or not head or not hum or hum.Health <= 0 then return end

        destroyESP(player)
        local folder = Instance.new("Folder"); folder.Name = player.UserId .. "_esp"; folder.Parent = ESPStorage

        if GlintFlags.ESPBoxes then
            local hl = Instance.new("Highlight"); hl.Name = "Glint_Highlight"; hl.FillTransparency = 1; hl.OutlineTransparency = 0
            hl.OutlineColor = GlintFlags.ESPBoxColor or Color3.fromRGB(255, 255, 255); hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            hl.Adornee = char; hl.Parent = folder
        end

        if GlintFlags.ESPNames then
            local gui = Instance.new("BillboardGui"); gui.Name = "Glint_Name"; gui.Adornee = head
            gui.Size = UDim2.new(0, 200, 0, 40); gui.StudsOffset = Vector3.new(0, 2.5, 0)
            gui.AlwaysOnTop = true; gui.LightInfluence = 0; gui.Parent = folder
            local nl = Instance.new("TextLabel"); nl.Size = UDim2.new(1, 0, 0.6, 0); nl.BackgroundTransparency = 1
            nl.Text = player.DisplayName or player.Name; nl.TextColor3 = GlintFlags.ESPNameColor or Color3.fromRGB(255, 255, 255)
            nl.TextScaled = false; nl.TextSize = 14; nl.Font = Enum.Font.GothamBold; nl.TextStrokeTransparency = 0.3
            nl.TextStrokeColor3 = Color3.fromRGB(0, 0, 0); nl.Parent = gui
            if GlintFlags.ESPDistance then
                local dl = Instance.new("TextLabel"); dl.Name = "Glint_Distance"; dl.Size = UDim2.new(1, 0, 0.4, 0)
                dl.Position = UDim2.new(0, 0, 0.6, 0); dl.BackgroundTransparency = 1; dl.Text = ""; dl.TextColor3 = Color3.fromRGB(200, 200, 200)
                dl.TextScaled = false; dl.TextSize = 12; dl.Font = Enum.Font.Gotham; dl.TextStrokeTransparency = 0.4
                dl.TextStrokeColor3 = Color3.fromRGB(0, 0, 0); dl.Parent = gui
            end
        end

        if GlintFlags.ESPHealthBar then
            local hg = Instance.new("BillboardGui"); hg.Name = "Glint_Health"; hg.Adornee = hrp
            hg.Size = UDim2.new(0, 6, 0, 50); hg.StudsOffset = Vector3.new(-2.8, 0, 0)
            hg.AlwaysOnTop = true; hg.LightInfluence = 0; hg.Parent = folder
            local bg = Instance.new("Frame"); bg.Size = UDim2.new(1, 0, 1, 0); bg.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            bg.BorderSizePixel = 0; bg.BackgroundTransparency = 0.3; bg.Parent = hg
            local bar = Instance.new("Frame"); bar.Name = "Bar"; bar.Size = UDim2.new(1, 0, 1, 0)
            bar.Position = UDim2.new(0, 0, 0, 0); bar.AnchorPoint = Vector2.new(0, 1)
            bar.BackgroundColor3 = Color3.fromRGB(0, 255, 0); bar.BorderSizePixel = 0; bar.Parent = bg
            Instance.new("UICorner", bar).CornerRadius = UDim.new(0, 2)
        end

        if GlintFlags.ESPHealthText then
            local htg = Instance.new("BillboardGui"); htg.Name = "Glint_HealthText"; htg.Adornee = hrp
            htg.Size = UDim2.new(0, 60, 0, 20); htg.StudsOffset = Vector3.new(-2.2, 0, 0)
            htg.AlwaysOnTop = true; htg.LightInfluence = 0; htg.Parent = folder
            local htl = Instance.new("TextLabel"); htl.Size = UDim2.new(1, 0, 1, 0); htl.BackgroundTransparency = 1
            htl.Text = math.floor(hum.Health).."/"..math.floor(hum.MaxHealth); htl.TextColor3 = Color3.fromRGB(255, 255, 255)
            htl.TextScaled = false; htl.TextSize = 10; htl.Font = Enum.Font.Gotham; htl.TextStrokeTransparency = 0.3
            htl.TextStrokeColor3 = Color3.fromRGB(0, 0, 0); htl.Parent = htg
        end

        if GlintFlags.ESPHeadDot then
            local dg = Instance.new("BillboardGui"); dg.Name = "Glint_HeadDot"; dg.Adornee = head
            dg.Size = UDim2.new(0, 8, 0, 8); dg.AlwaysOnTop = true; dg.LightInfluence = 0; dg.Parent = folder
            local d = Instance.new("Frame"); d.Size = UDim2.new(1, 0, 1, 0); d.BackgroundColor3 = GlintFlags.ESPBoxColor or Color3.fromRGB(255, 255, 255)
            d.BorderSizePixel = 0; d.Parent = dg
            local dc = Instance.new("UICorner", d); dc.CornerRadius = UDim.new(1, 0)
        end

        if GlintFlags.ESPSnaplines then
            local localHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if localHRP then
                local a0 = Instance.new("Attachment"); a0.Name = "Glint_SnapAtt0"; a0.Parent = localHRP
                local a1 = Instance.new("Attachment"); a1.Name = "Glint_SnapAtt1"; a1.Parent = hrp
                local b = Instance.new("Beam"); b.Name = "Glint_Snapline"; b.Attachment0 = a0; b.Attachment1 = a1
                b.Color = ColorSequence.new(GlintFlags.ESPSnaplineColor or Color3.fromRGB(176, 176, 209))
                b.Transparency = NumberSequence.new(0.3); b.Width0 = 0.08; b.Width1 = 0.08
                b.FaceCamera = true; b.LightInfluence = 0; b.Parent = folder
            end
        end

        if GlintFlags.ESPSkeleton then
            local skelColor = GlintFlags.ESPSkeletonColor or Color3.fromRGB(200, 200, 200)
            local bones = {{"Head","UpperTorso"},{"UpperTorso","LowerTorso"},{"UpperTorso","LeftUpperArm"},{"LeftUpperArm","LeftLowerArm"},{"LeftLowerArm","LeftHand"},{"UpperTorso","RightUpperArm"},{"RightUpperArm","RightLowerArm"},{"RightLowerArm","RightHand"},{"LowerTorso","LeftUpperLeg"},{"LeftUpperLeg","LeftLowerLeg"},{"LeftLowerLeg","LeftFoot"},{"LowerTorso","RightUpperLeg"},{"RightUpperLeg","RightLowerLeg"},{"RightLowerLeg","RightFoot"}}
            for idx, pair in bones do
                local pA, pB = char:FindFirstChild(pair[1]), char:FindFirstChild(pair[2])
                if pA and pB then
                    local a0 = Instance.new("Attachment"); a0.Name = "Glint_SkelA_"..idx; a0.Parent = pA
                    local a1 = Instance.new("Attachment"); a1.Name = "Glint_SkelB_"..idx; a1.Parent = pB
                    local b = Instance.new("Beam"); b.Name = "Glint_Skel_"..idx; b.Attachment0 = a0; b.Attachment1 = a1
                    b.Color = ColorSequence.new(skelColor); b.Transparency = NumberSequence.new(0.2)
                    b.Width0 = 0.04; b.Width1 = 0.04; b.FaceCamera = true; b.LightInfluence = 0; b.Parent = folder
                end
            end
        end
    end

    local function updateESP()
        if not GlintFlags.ESPEnabled then
            for _, child in ESPStorage:GetChildren() do child:Destroy() end
            return
        end
        local localHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        for _, player in Players:GetPlayers() do
            if player == LocalPlayer then continue end
            local char = player.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            local head = char and char:FindFirstChild("Head")
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if not char or not hrp or not head or not hum or hum.Health <= 0 then destroyESP(player); continue end
            if localHRP and (hrp.Position - localHRP.Position).Magnitude > (GlintFlags.ESPMaxDistance or 2000) then destroyESP(player); continue end
            if not ESPStorage:FindFirstChild(player.UserId .. "_esp") then createESP(player) end
            local folder = ESPStorage:FindFirstChild(player.UserId .. "_esp")
            if not folder then continue end
            local hl = folder:FindFirstChild("Glint_Highlight")
            if hl then hl.Adornee = char; hl.OutlineColor = GlintFlags.ESPBoxColor or Color3.fromRGB(255, 255, 255) end
            local ng = folder:FindFirstChild("Glint_Name")
            if ng then local nl = ng:FindFirstChildOfClass("TextLabel"); if nl then nl.TextColor3 = GlintFlags.ESPNameColor or Color3.fromRGB(255, 255, 255) end
                local dl = ng:FindFirstChild("Glint_Distance"); if dl and localHRP then dl.Text = "["..math.floor((hrp.Position - localHRP.Position).Magnitude).."m]" end
            end
            local hg = folder:FindFirstChild("Glint_Health")
            if hg then local bg = hg:FindFirstChildOfClass("Frame"); if bg then local bar = bg:FindFirstChild("Bar")
                if bar then local pct = math.clamp(hum.Health / hum.MaxHealth, 0, 1); bar.Size = UDim2.new(1, 0, pct, 0)
                    bar.BackgroundColor3 = Color3.fromRGB(math.floor(255*(1-pct)), math.floor(255*pct), 0) end end end
            local htg = folder:FindFirstChild("Glint_HealthText")
            if htg then local htl = htg:FindFirstChildOfClass("TextLabel"); if htl then htl.Text = math.floor(hum.Health).."/"..math.floor(hum.MaxHealth) end end
            local sb = folder:FindFirstChild("Glint_Snapline")
            if sb then sb.Color = ColorSequence.new(GlintFlags.ESPSnaplineColor or Color3.fromRGB(176, 176, 209)) end
            local skc = GlintFlags.ESPSkeletonColor or Color3.fromRGB(200, 200, 200)
            for i = 1, 14 do local sk = folder:FindFirstChild("Glint_Skel_"..i); if sk then sk.Color = ColorSequence.new(skc) end end
        end
    end

    Players.PlayerAdded:Connect(function(player)
        player.CharacterAdded:Connect(function() task.wait(1); if GlintFlags.ESPEnabled then createESP(player) end end)
    end)
    Players.PlayerRemoving:Connect(destroyESP)
    for _, player in Players:GetPlayers() do
        if player ~= LocalPlayer then player.CharacterAdded:Connect(function() task.wait(1); if GlintFlags.ESPEnabled then createESP(player) end end) end
    end
    Connect(RunService.Heartbeat, function() pcall(updateESP) end)
end

-- ============================
-- CHAMS (BoxHandleAdornment)
-- ============================

do
    local function addChams(player)
        if player == LocalPlayer or not player.Character then return end
        local fill = GlintFlags.ChamsFillColor or Color3.fromRGB(176, 176, 209)
        local outline = GlintFlags.ChamsOutlineColor or Color3.fromRGB(255, 255, 255)
        local trans = (GlintFlags.ChamsTransparency or 75) / 100
        for _, part in player.Character:GetDescendants() do
            if part:IsA("BasePart") and part.Transparency ~= 1 and not part:FindFirstChild("GlintCham") then
                local c = Instance.new("BoxHandleAdornment"); c.Name = "GlintCham"; c.AlwaysOnTop = true; c.ZIndex = 4; c.Adornee = part
                c.Color3 = fill; c.Transparency = trans; c.Size = part.Size + Vector3.new(0.02, 0.02, 0.02); c.Parent = part
                local g = Instance.new("BoxHandleAdornment"); g.Name = "GlintChamGlow"; g.AlwaysOnTop = false; g.ZIndex = 3; g.Adornee = part
                g.Color3 = outline; g.Transparency = 0.3; g.Size = c.Size + Vector3.new(0.1, 0.1, 0.1); g.Parent = part
            end
        end
    end

    local function removeChams(player)
        if not player or not player.Character then return end
        for _, part in player.Character:GetDescendants() do
            if part:IsA("BasePart") then pcall(function() local c = part:FindFirstChild("GlintCham"); if c then c:Destroy() end
                local g = part:FindFirstChild("GlintChamGlow"); if g then g:Destroy() end end) end
        end
    end

    local lastChamsState, lastChamsUpdate = false, 0
    Connect(RunService.Heartbeat, function()
        local en = GlintFlags.ChamsEnabled; local now = tick()
        if en ~= lastChamsState or now - lastChamsUpdate > 2 then
            lastChamsState = en; lastChamsUpdate = now
            if en then for _, p in Players:GetPlayers() do if p ~= LocalPlayer then addChams(p) end end
            else for _, p in Players:GetPlayers() do removeChams(p) end end
        end
        if en then
            local fill = GlintFlags.ChamsFillColor or Color3.fromRGB(176, 176, 209)
            local outline = GlintFlags.ChamsOutlineColor or Color3.fromRGB(255, 255, 255)
            local trans = (GlintFlags.ChamsTransparency or 75) / 100
            for _, p in Players:GetPlayers() do
                if p ~= LocalPlayer and p.Character then
                    for _, part in p.Character:GetDescendants() do
                        if part:IsA("BasePart") then pcall(function()
                            local c = part:FindFirstChild("GlintCham"); if c then c.Color3 = fill; c.Transparency = trans end
                            local g = part:FindFirstChild("GlintChamGlow"); if g then g.Color3 = outline end end) end
                    end
                end
            end
        end
    end)
    Players.PlayerAdded:Connect(function(p) p.CharacterAdded:Connect(function() task.wait(1); if GlintFlags.ChamsEnabled then addChams(p) end end) end)
    for _, p in Players:GetPlayers() do if p ~= LocalPlayer then p.CharacterAdded:Connect(function() task.wait(1); if GlintFlags.ChamsEnabled then addChams(p) end end) end end
    Players.PlayerRemoving:Connect(removeChams)
end

-- ============================
-- INIT
-- ============================

Window:Init()
task.spawn(function() Library:Notification("Glint loaded - press X to open", 5, Color3.fromRGB(176, 176, 209)) end)