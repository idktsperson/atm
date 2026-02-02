--[[
    Da Hood ATM Farm System - ULTIMATE OPTIMIZED VERSION
    Features: Camera Clip, Executor Detection, Smart Positioning, Safe AFK Zone
]]

-- ════════════════════════════════════════════════════════════════
-- CONFIGURATION
-- ════════════════════════════════════════════════════════════════

getgenv().Configuration = getgenv().Configuration or {
    ['ServerHop'] = false,
    ['ServerHopNum'] = 5,
    ['WebhookEnabled'] = false,
    ['Webhook'] = "",
    ['WebhookInterval'] = 2,
    ['Fps'] = 15,
}

local CONFIG = getgenv().Configuration

-- ════════════════════════════════════════════════════════════════
-- SERVICES
-- ════════════════════════════════════════════════════════════════

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local MainEvent = ReplicatedStorage:WaitForChild("MainEvent", 10)

-- Wait for game to load
repeat task.wait(0.1) until game:IsLoaded() and LocalPlayer

-- Wait for character to fully load
if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("FULLY_LOADED_CHAR") then 
    repeat task.wait(0.5) until LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("FULLY_LOADED_CHAR")
    task.wait(1)
end

local Camera = Workspace.CurrentCamera

-- ════════════════════════════════════════════════════════════════
-- EXECUTOR DETECTION
-- ════════════════════════════════════════════════════════════════

local EXECUTOR_TYPE = "UNKNOWN"

local function detectExecutor()
    if identifyexecutor then
        local executor = identifyexecutor()
        if string.find(string.lower(executor), "solara") then
            EXECUTOR_TYPE = "SOLARA"
        elseif string.find(string.lower(executor), "xeno") then
            EXECUTOR_TYPE = "XENO"
        else
            EXECUTOR_TYPE = "OTHER"
        end
    elseif getexecutorname then
        local executor = getexecutorname()
        if string.find(string.lower(executor), "solara") then
            EXECUTOR_TYPE = "SOLARA"
        elseif string.find(string.lower(executor), "xeno") then
            EXECUTOR_TYPE = "XENO"
        else
            EXECUTOR_TYPE = "OTHER"
        end
    else
        EXECUTOR_TYPE = "OTHER"
    end
    
    return EXECUTOR_TYPE
end

local DETECTED_EXECUTOR = detectExecutor()

-- ════════════════════════════════════════════════════════════════
-- SAFE AFK ZONE
-- ════════════════════════════════════════════════════════════════

local SAFE_ZONE = {
    Position = Vector3.new(-3363.70337, 91784.7188, 11727.2256),
    Orientation = CFrame.new(0, 0, 0, 0.102251053, 5.01812885e-08, 0.994758606, 1.7767182e-12, 1, -5.04458768e-08, -0.994758606, 5.15991161e-09, 0.102251053),
    Part = nil
}

local function createSafeZone()
    if SAFE_ZONE.Part then
        SAFE_ZONE.Part:Destroy()
    end
    
    local part = Instance.new("Part")
    part.Size = Vector3.new(20, 1, 20)
    part.Position = SAFE_ZONE.Position
    part.Anchored = true
    part.CanCollide = true
    part.Transparency = 0.5
    part.Material = Enum.Material.Neon
    part.Color = Color3.fromRGB(46, 204, 113)
    part.Name = "SafeZonePlatform"
    part.Parent = Workspace
    
    SAFE_ZONE.Part = part
    Utils.Log("Safe zone created at sky position")
end

local function teleportToSafeZone()
    pcall(function()
        if not SAFE_ZONE.Part then
            createSafeZone()
        end
        
        if Utils.IsValidCharacter(LocalPlayer.Character) then
            LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(SAFE_ZONE.Position + Vector3.new(0, 3, 0))
            Utils.Log("Teleported to safe AFK zone")
        end
    end)
end

-- ════════════════════════════════════════════════════════════════
-- STATE MANAGEMENT
-- ════════════════════════════════════════════════════════════════

local STATE = {
    currentATMIndex = 1,
    deathCount = 0,
    totalCashCollected = 0,
    atmRobbed = 0,
    sessionStartTime = os.time(),
    isRunning = false,
    cashAuraActive = false,
    lastWebhookSent = 0,
    processedATMs = {},
    noclipConnection = nil,
    cframeLoopConnection = nil,
    lastCashCount = 0,
    noCashChangeTime = 0,
    useCameraAura = (DETECTED_EXECUTOR == "SOLARA" or DETECTED_EXECUTOR == "XENO"),
}

-- ════════════════════════════════════════════════════════════════
-- OPTIMIZATION
-- ════════════════════════════════════════════════════════════════

setfpscap(CONFIG.Fps)
settings().Rendering.QualityLevel = Enum.QualityLevel.Level01

-- Lighting Optimization
Lighting.GlobalShadows = false
Lighting.FogEnd = 100
Lighting.Brightness = 0

-- Workspace Optimization
for _, obj in pairs(Workspace:GetDescendants()) do
    if obj:IsA("BasePart") then
        obj.Material = Enum.Material.SmoothPlastic
        obj.CastShadow = false
        obj.Reflectance = 0
    elseif obj:IsA("Decal") or obj:IsA("Texture") then
        obj.Transparency = 1
    elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Smoke") or obj:IsA("Fire") then
        obj.Enabled = false
    elseif obj:IsA("MeshPart") then
        obj.TextureID = ""
    end
end

Workspace.DescendantAdded:Connect(function(obj)
    if obj:IsA("BasePart") then
        obj.Material = Enum.Material.SmoothPlastic
        obj.CastShadow = false
    elseif obj:IsA("Decal") or obj:IsA("Texture") then
        obj.Transparency = 1
    elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") then
        obj.Enabled = false
    end
end)

-- ════════════════════════════════════════════════════════════════
-- CAMERA NOCLIP
-- ════════════════════════════════════════════════════════════════

local CameraClip = {}

function CameraClip.Enable()
    pcall(function()
        -- Occlusion (Invisicam)
        sethiddenproperty(Camera, "DevCameraOcclusionMode", "Invisicam")
        
        -- Camera can clip through walls
        LocalPlayer.CameraMaxZoomDistance = 9e9
        LocalPlayer.CameraMinZoomDistance = 0
        LocalPlayer.CameraMode = Enum.CameraMode.Classic
    end)
    
    Utils.Log("Camera noclip enabled")
end

-- ════════════════════════════════════════════════════════════════
-- UTILITY FUNCTIONS
-- ════════════════════════════════════════════════════════════════

local Utils = {}

function Utils.IsValidCharacter(character)
    return character and character:FindFirstChild("HumanoidRootPart") and character:FindFirstChild("Humanoid") and character.Humanoid.Health > 0
end

function Utils.GetCombatTool()
    local combat = LocalPlayer.Backpack:FindFirstChild("Combat")
    if not combat and LocalPlayer.Character then
        combat = LocalPlayer.Character:FindFirstChild("Combat")
    end
    return combat
end

function Utils.EquipCombat()
    pcall(function()
        local combat = Utils.GetCombatTool()
        if combat and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid:EquipTool(combat)
        end
    end)
end

function Utils.GetCurrentCash()
    local cash = 0
    pcall(function()
        if LocalPlayer:FindFirstChild("DataFolder") and LocalPlayer.DataFolder:FindFirstChild("Currency") then
            cash = LocalPlayer.DataFolder.Currency.Value
        end
    end)
    return cash
end

function Utils.FormatTime(seconds)
    local hours = math.floor(seconds / 3600)
    local minutes = math.floor((seconds % 3600) / 60)
    local secs = seconds % 60
    return string.format("%02d:%02d:%02d", hours, minutes, secs)
end

function Utils.Log(message)
    print("[ATM FARM] " .. message)
end

-- ════════════════════════════════════════════════════════════════
-- NOCLIP SYSTEM
-- ════════════════════════════════════════════════════════════════

local Noclip = {}

function Noclip.Enable()
    if STATE.noclipConnection then return end
    
    STATE.noclipConnection = RunService.Stepped:Connect(function()
        pcall(function()
            if LocalPlayer.Character then
                for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
    end)
end

function Noclip.Disable()
    if STATE.noclipConnection then
        STATE.noclipConnection:Disconnect()
        STATE.noclipConnection = nil
    end
    
    pcall(function()
        if LocalPlayer.Character then
            for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                    part.CanCollide = true
                end
            end
        end
    end)
end

-- ════════════════════════════════════════════════════════════════
-- CFRAME LOOP SYSTEM
-- ════════════════════════════════════════════════════════════════

local CFrameLoop = {}

function CFrameLoop.Start(targetCFrame)
    CFrameLoop.Stop()
    
    STATE.cframeLoopConnection = RunService.Heartbeat:Connect(function()
        pcall(function()
            if Utils.IsValidCharacter(LocalPlayer.Character) then
                LocalPlayer.Character.HumanoidRootPart.CFrame = targetCFrame
                LocalPlayer.Character.HumanoidRootPart.AssemblyLinearVelocity = Vector3.zero
                LocalPlayer.Character.HumanoidRootPart.AssemblyAngularVelocity = Vector3.zero
            end
        end)
    end)
end

function CFrameLoop.Stop()
    if STATE.cframeLoopConnection then
        STATE.cframeLoopConnection:Disconnect()
        STATE.cframeLoopConnection = nil
    end
end

-- ════════════════════════════════════════════════════════════════
-- WEBHOOK SYSTEM (FIXED)
-- ════════════════════════════════════════════════════════════════

local Webhook = {}

function Webhook.Send(title, description, color)
    if not CONFIG.WebhookEnabled or CONFIG.Webhook == "" then return end
    
    task.spawn(function()
        local success, err = pcall(function()
            local currentTime = os.time()
            if currentTime - STATE.lastWebhookSent < (CONFIG.WebhookInterval * 60) then
                return
            end
            
            STATE.lastWebhookSent = currentTime
            
            local sessionTime = os.time() - STATE.sessionStartTime
            local currentCash = Utils.GetCurrentCash()
            local playersInServer = #Players:GetPlayers()
            
            local embed = {
                ["embeds"] = {{
                    ["title"] = title,
                    ["description"] = description,
                    ["color"] = color or 3447003,
                    ["fields"] = {
                        {
                            ["name"] = "🖥️ Server Info",
                            ["value"] = string.format("Players in Server: **%d**", playersInServer),
                            ["inline"] = false
                        },
                        {
                            ["name"] = "👤 Player Info",
                            ["value"] = string.format(
                                "Username: **%s**\nDisplay Name: **%s**",
                                LocalPlayer.Name,
                                LocalPlayer.DisplayName
                            ),
                            ["inline"] = false
                        },
                        {
                            ["name"] = "💰 Auto Farm Info",
                            ["value"] = string.format(
                                "Profit: **$%s**\nRobbed: **%d**\nWallet: **$%s**\nElapsed: **%s**",
                                tostring(STATE.totalCashCollected),
                                STATE.atmRobbed,
                                tostring(currentCash),
                                Utils.FormatTime(sessionTime)
                            ),
                            ["inline"] = false
                        },
                        {
                            ["name"] = "📊 Statistics",
                            ["value"] = string.format(
                                "Deaths: **%d**\nCash/Hour: **$%s**\nATM/Hour: **%.1f**",
                                STATE.deathCount,
                                tostring(math.floor(STATE.totalCashCollected / math.max(sessionTime / 3600, 0.01))),
                                STATE.atmRobbed / math.max(sessionTime / 3600, 0.01)
                            ),
                            ["inline"] = false
                        },
                    },
                    ["footer"] = {
                        ["text"] = "Da Hood ATM Farm • " .. os.date("%H:%M:%S")
                    },
                    ["timestamp"] = os.date("!%Y-%m-%dT%H:%M:%S")
                }}
            }
            
            local body = HttpService:JSONEncode(embed)
            
            local response = request({
                Url = CONFIG.Webhook,
                Method = "POST",
                Headers = {
                    ["Content-Type"] = "application/json"
                },
                Body = body
            })
            
            Utils.Log("Webhook sent successfully!")
        end)
        
        if not success then
            Utils.Log("Webhook error: " .. tostring(err))
        end
    end)
end

-- ════════════════════════════════════════════════════════════════
-- CASH AURA SYSTEM (CAMERA - SOLARA/XENO)
-- ════════════════════════════════════════════════════════════════

local CashAuraCamera = {}
local Drops = Workspace:FindFirstChild("Ignored") and Workspace.Ignored:FindFirstChild("Drop")
local isProcessingCamera = false

function CashAuraCamera.Start()
    if STATE.cashAuraActive then return end
    
    STATE.cashAuraActive = true
    Utils.Log("Cash Aura activated (Camera Mode - " .. DETECTED_EXECUTOR .. ")")
    
    task.spawn(function()
        while STATE.cashAuraActive do
            task.wait(0.15)
            
            pcall(function()
                if not Utils.IsValidCharacter(LocalPlayer.Character) then return end
                if not Drops then
                    Drops = Workspace:FindFirstChild("Ignored") and Workspace.Ignored:FindFirstChild("Drop")
                    return
                end
                
                local playerPos = LocalPlayer.Character.HumanoidRootPart.Position
                
                for _, drop in pairs(Drops:GetChildren()) do
                    if drop.Name == "MoneyDrop" and not isProcessingCamera then
                        local distance = (drop.Position - playerPos).Magnitude
                        
                        if distance <= 12 then
                            isProcessingCamera = true
                            
                            -- Unequip all tools
                            for _, tool in pairs(LocalPlayer.Character:GetChildren()) do
                                if tool:IsA("Tool") then
                                    tool.Parent = LocalPlayer.Backpack
                                end
                            end
                            
                            -- Set camera to scriptable
                            Camera.CameraType = Enum.CameraType.Scriptable
                            
                            repeat
                                task.wait()
                                
                                -- Point camera at money drop
                                local offset = Vector3.new(
                                    math.random(-30, 30) / 100,
                                    2,
                                    math.random(-30, 30) / 100
                                )
                                Camera.CFrame = CFrame.lookAt(drop.Position + offset, drop.Position)
                                
                                -- Click at center
                                local viewportCenter = Camera.ViewportSize / 2
                                VirtualInputManager:SendMouseButtonEvent(viewportCenter.X, viewportCenter.Y, 0, true, game, 1)
                                task.wait(0.15)
                                VirtualInputManager:SendMouseButtonEvent(viewportCenter.X, viewportCenter.Y, 0, false, game, 1)
                                
                                if Utils.IsValidCharacter(LocalPlayer.Character) then
                                    distance = (drop.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                                else
                                    break
                                end
                                
                            until not drop or drop.Parent == nil or distance > 12
                            
                            -- Restore camera
                            Camera.CameraType = Enum.CameraType.Custom
                            Camera.CameraSubject = LocalPlayer.Character.Humanoid
                            
                            isProcessingCamera = false
                            STATE.totalCashCollected = STATE.totalCashCollected + 10
                        end
                    end
                end
            end)
        end
        
        pcall(function()
            Camera.CameraType = Enum.CameraType.Custom
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                Camera.CameraSubject = LocalPlayer.Character.Humanoid
            end
        end)
    end)
end

function CashAuraCamera.Stop()
    STATE.cashAuraActive = false
    
    pcall(function()
        Camera.CameraType = Enum.CameraType.Custom
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            Camera.CameraSubject = LocalPlayer.Character.Humanoid
        end
    end)
end

-- ════════════════════════════════════════════════════════════════
-- CASH AURA SYSTEM (SIMPLE - OTHER EXECUTORS)
-- ════════════════════════════════════════════════════════════════

local CashAuraSimple = {}

function CashAuraSimple.Start()
    if STATE.cashAuraActive then return end
    
    STATE.cashAuraActive = true
    Utils.Log("Cash Aura activated (Simple Mode - " .. DETECTED_EXECUTOR .. ")")
    
    task.spawn(function()
        while STATE.cashAuraActive do
            task.wait(0.1)
            
            pcall(function()
                if not Utils.IsValidCharacter(LocalPlayer.Character) then return end
                if not Drops then
                    Drops = Workspace:FindFirstChild("Ignored") and Workspace.Ignored:FindFirstChild("Drop")
                    return
                end
                
                local playerPos = LocalPlayer.Character.HumanoidRootPart.Position
                
                for _, drop in pairs(Drops:GetChildren()) do
                    if drop.Name == "MoneyDrop" and drop:FindFirstChild("ClickDetector") then
                        local distance = (drop.Position - playerPos).Magnitude
                        
                        if distance < 12 then
                            fireclickdetector(drop.ClickDetector)
                            STATE.totalCashCollected = STATE.totalCashCollected + 10
                        end
                    end
                end
            end)
        end
    end)
end

function CashAuraSimple.Stop()
    STATE.cashAuraActive = false
end

-- ════════════════════════════════════════════════════════════════
-- UNIFIED CASH AURA
-- ════════════════════════════════════════════════════════════════

local CashAura = {}

function CashAura.Start()
    if STATE.useCameraAura then
        CashAuraCamera.Start()
    else
        CashAuraSimple.Start()
    end
end

function CashAura.Stop()
    if STATE.useCameraAura then
        CashAuraCamera.Stop()
    else
        CashAuraSimple.Stop()
    end
end

function CashAura.GetNearbyCount()
    local count = 0
    
    pcall(function()
        if not Utils.IsValidCharacter(LocalPlayer.Character) then return 0 end
        if not Drops then return 0 end
        
        local playerPos = LocalPlayer.Character.HumanoidRootPart.Position
        
        for _, drop in pairs(Drops:GetChildren()) do
            if drop.Name == "MoneyDrop" then
                local distance = (drop.Position - playerPos).Magnitude
                if distance < 12 then
                    count = count + 1
                end
            end
        end
    end)
    
    return count
end

-- ════════════════════════════════════════════════════════════════
-- SMART WAIT SYSTEM
-- ════════════════════════════════════════════════════════════════

local SmartWait = {}

function SmartWait.ForCashCollection()
    Utils.Log("💰 Collecting cash drops...")
    
    STATE.lastCashCount = CashAura.GetNearbyCount()
    STATE.noCashChangeTime = 0
    
    while STATE.isRunning do
        task.wait(0.5)
        
        local currentCashCount = CashAura.GetNearbyCount()
        
        if currentCashCount ~= STATE.lastCashCount then
            STATE.lastCashCount = currentCashCount
            STATE.noCashChangeTime = 0
            Utils.Log("   💵 Cash nearby: " .. currentCashCount)
        else
            STATE.noCashChangeTime = STATE.noCashChangeTime + 0.5
        end
        
        if currentCashCount == 0 and STATE.noCashChangeTime >= 2 then
            Utils.Log("✅ All cash collected!")
            break
        end
        
        if STATE.noCashChangeTime >= 15 then
            Utils.Log("⏱️ Collection timeout")
            break
        end
    end
end

-- ════════════════════════════════════════════════════════════════
-- ATM POSITIONING (SMART OFFSET)
-- ════════════════════════════════════════════════════════════════

local ATMPositioning = {}

function ATMPositioning.GetOffset(atmPosition)
    -- Round position to avoid float comparison issues
    local x = math.floor(atmPosition.X)
    local z = math.floor(atmPosition.Z)
    
    -- Check for specific ATM positions (side by side ATMs)
    -- Left ATM: X ≈ -624, Z ≈ -286 → offset RIGHT (+3 studs on X axis)
    if x == -624 or x == -625 and z == -286 or z == -287 then
        Utils.Log("  Detected left-side ATM - offsetting right")
        return Vector3.new(3, 0, 0)
    end
    
    -- Right ATM: X ≈ -627, Z ≈ -286 → offset LEFT (-3 studs on X axis)
    if x == -627 or x == -628 and z == -286 or z == -287 then
        Utils.Log("  Detected right-side ATM - offsetting left")
        return Vector3.new(-3, 0, 0)
    end
    
    -- No offset needed
    return Vector3.new(0, 0, 0)
end

-- ════════════════════════════════════════════════════════════════
-- ATM DETECTION SYSTEM
-- ════════════════════════════════════════════════════════════════

local ATM = {}

function ATM.IsVault(cashier)
    return string.find(string.upper(cashier.Name), "VAULT") ~= nil
end

function ATM.IsATMFilled(cashier)
    if ATM.IsVault(cashier) then
        return false, nil
    end
    
    local open = cashier:FindFirstChild("Open")
    if open and open:IsA("BasePart") then
        local size = open.Size
        if math.abs(size.X - 2.6) < 0.1 and math.abs(size.Y - 0.5) < 0.1 and math.abs(size.Z - 0.1) < 0.1 then
            return true, open
        end
    end
    
    if open then
        return true, open
    end
    
    local largestPart = nil
    local largestSize = 0
    
    for _, child in ipairs(cashier:GetChildren()) do
        if child:IsA("BasePart") then
            local size = child.Size.X * child.Size.Y * child.Size.Z
            if size > largestSize then
                largestSize = size
                largestPart = child
            end
        end
    end
    
    return largestPart ~= nil, largestPart
end

function ATM.ScanAll()
    local filledATMs = {}
    
    pcall(function()
        local cashiers = Workspace:FindFirstChild("Cashiers")
        if not cashiers then
            Utils.Log("ERROR: Cashiers folder not found!")
            return
        end
        
        Utils.Log("Scanning " .. #cashiers:GetChildren() .. " cashiers...")
        
        for index, cashier in ipairs(cashiers:GetChildren()) do
            if not ATM.IsVault(cashier) and not STATE.processedATMs[cashier.Name] then
                local isFilled, targetPart = ATM.IsATMFilled(cashier)
                
                if isFilled and targetPart then
                    table.insert(filledATMs, {
                        Index = index,
                        Name = cashier.Name,
                        Position = targetPart.Position,
                        Cashier = cashier,
                        TargetPart = targetPart,
                    })
                    
                    Utils.Log("  ✓ Found filled ATM: " .. cashier.Name)
                end
            end
        end
        
        Utils.Log("Total filled ATMs: " .. #filledATMs)
    end)
    
    return filledATMs
end

function ATM.Break(atmData)
    return pcall(function()
        Utils.Log("═══════════════════════════════")
        Utils.Log("Breaking ATM: " .. atmData.Name)
        Utils.Log("═══════════════════════════════")
        
        -- Enable noclip
        Noclip.Enable()
        
        -- Get smart offset for side-by-side ATMs
        local positionOffset = ATMPositioning.GetOffset(atmData.Position)
        
        -- Calculate position: 4 studs below + smart offset
        local targetPos = atmData.Position - Vector3.new(0, 4, 0) + positionOffset
        local targetCFrame = CFrame.new(targetPos) * CFrame.Angles(math.rad(90), 0, 0)
        
        -- Start CFrame loop
        CFrameLoop.Start(targetCFrame)
        
        task.wait(0.3)
        
        -- Equip Combat
        Utils.EquipCombat()
        task.wait(0.3)
        
        -- First charge attack
        Utils.Log("⚡ Charge attack 1/2")
        MainEvent:FireServer("ChargeButton")
        task.wait(3.5)
        
        -- Second charge attack
        Utils.Log("⚡ Charge attack 2/2")
        MainEvent:FireServer("ChargeButton")
        task.wait(3.5)
        
        -- Stop CFrame loop
        CFrameLoop.Stop()
        
        -- Disable noclip
        Noclip.Disable()
        
        -- Mark as processed
        STATE.processedATMs[atmData.Name] = true
        STATE.atmRobbed = STATE.atmRobbed + 1
        
        Utils.Log("✅ ATM broken successfully! Total: " .. STATE.atmRobbed)
        
        return true
    end)
end

-- ════════════════════════════════════════════════════════════════
-- SERVER HOP SYSTEM
-- ════════════════════════════════════════════════════════════════

local ServerHop = {}

function ServerHop.Execute()
    Utils.Log("🔄 Server hopping...")
    Webhook.Send("🔄 Server Hopping", "No ATMs found or death limit reached.", 16776960)
    
    task.wait(2)
    
    pcall(function()
        local placeId = game.PlaceId
        local success, servers = pcall(function()
            return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. placeId .. "/servers/Public?sortOrder=Asc&limit=100"))
        end)
        
        if success and servers then
            for _, server in pairs(servers.data) do
                if server.id ~= game.JobId and server.playing < server.maxPlayers - 5 then
                    TeleportService:TeleportToPlaceInstance(placeId, server.id, LocalPlayer)
                    return
                end
            end
        end
        
        TeleportService:Teleport(placeId, LocalPlayer)
    end)
end

function ServerHop.CheckNoATMs()
    if CONFIG.ServerHop then
        Utils.Log("⚠️ No ATMs found - preparing to server hop...")
        task.wait(30)
        
        local atms = ATM.ScanAll()
        if #atms == 0 then
            ServerHop.Execute()
        end
    else
        -- Server hop disabled - go to safe zone
        Utils.Log("⚠️ No ATMs found - going to safe AFK zone...")
        teleportToSafeZone()
        task.wait(30)
    end
end

function ServerHop.CheckDeath()
    if CONFIG.ServerHop and STATE.deathCount >= CONFIG.ServerHopNum then
        ServerHop.Execute()
    end
end

-- ════════════════════════════════════════════════════════════════
-- MAIN FARM LOOP
-- ════════════════════════════════════════════════════════════════

local Farm = {}

function Farm.Start()
    if STATE.isRunning then
        Utils.Log("Farm already running!")
        return
    end
    
    STATE.isRunning = true
    STATE.sessionStartTime = os.time()
    STATE.processedATMs = {}
    
    Utils.Log("═══════════════════════════════════════")
    Utils.Log("🏧 ATM Farm Started!")
    Utils.Log("Executor: " .. DETECTED_EXECUTOR)
    Utils.Log("Cash Aura: " .. (STATE.useCameraAura and "Camera Mode" or "Simple Mode"))
    Utils.Log("FPS: " .. CONFIG.Fps)
    Utils.Log("Server Hop: " .. tostring(CONFIG.ServerHop))
    Utils.Log("Webhook: " .. tostring(CONFIG.WebhookEnabled))
    Utils.Log("═══════════════════════════════════════")
    
    CameraClip.Enable()
    createSafeZone()
    
    Webhook.Send("✅ Farm Started", "ATM farming session initiated\nExecutor: " .. DETECTED_EXECUTOR, 3066993)
    
    -- Start cash aura
    CashAura.Start()
    
    task.spawn(function()
        while STATE.isRunning do
            local success, err = pcall(function()
                -- Scan for filled ATMs
                local filledATMs = ATM.ScanAll()
                
                if #filledATMs == 0 then
                    Utils.Log("⏳ No new filled ATMs.")
                    Utils.Log("   (Processed: " .. STATE.atmRobbed .. " ATMs)")
                    
                    ServerHop.CheckNoATMs()
                    
                    task.wait(15)
                    
                    if (os.time() - STATE.sessionStartTime) % 300 < 15 then
                        STATE.processedATMs = {}
                        Utils.Log("🔄 Reset processed ATMs list")
                    end
                    return
                end
                
                Utils.Log("🎯 Processing " .. #filledATMs .. " ATMs...")
                
                -- Farm each ATM
                for i, atmData in ipairs(filledATMs) do
                    if not STATE.isRunning then break end
                    
                    STATE.currentATMIndex = i
                    
                    -- Break ATM
                    local breakSuccess, breakErr = ATM.Break(atmData)
                    
                    if breakSuccess then
                        SmartWait.ForCashCollection()
                    else
                        Utils.Log("❌ Failed: " .. tostring(breakErr))
                    end
                    
                    task.wait(1)
                end
                
                Utils.Log("🔄 All ATMs processed. Rescanning...")
                Webhook.Send("🔄 Scanning", "All ATMs processed.", 3447003)
                task.wait(10)
            end)
            
            if not success then
                Utils.Log("❌ ERROR: " .. tostring(err))
                task.wait(5)
            end
        end
    end)
end

function Farm.Stop()
    STATE.isRunning = false
    CashAura.Stop()
    CFrameLoop.Stop()
    Noclip.Disable()
    
    Utils.Log("🛑 Farm stopped!")
    Webhook.Send("🛑 Farm Stopped", "Session ended. Profit: $" .. STATE.totalCashCollected, 15158332)
end

-- ════════════════════════════════════════════════════════════════
-- CHARACTER HANDLERS
-- ════════════════════════════════════════════════════════════════

LocalPlayer.CharacterAdded:Connect(function(character)
    STATE.deathCount = STATE.deathCount + 1
    
    Utils.Log("💀 Death #" .. STATE.deathCount)
    Webhook.Send("💀 Death", "Total deaths: " .. STATE.deathCount, 15158332)
    
    ServerHop.CheckDeath()
    
    task.wait(0.5)
    if not character:FindFirstChild("FULLY_LOADED_CHAR") then
        repeat task.wait(0.5) until character:FindFirstChild("FULLY_LOADED_CHAR")
        task.wait(1)
    end
    
    Camera = Workspace.CurrentCamera
    CameraClip.Enable()
    Drops = Workspace:FindFirstChild("Ignored") and Workspace.Ignored:FindFirstChild("Drop")
    
    CFrameLoop.Stop()
    Noclip.Disable()
end)

-- ════════════════════════════════════════════════════════════════
-- ANTI-AFK
-- ════════════════════════════════════════════════════════════════

task.spawn(function()
    local vu = game:GetService("VirtualUser")
    LocalPlayer.Idled:Connect(function()
        vu:Button2Down(Vector2.new(0,0), Camera.CFrame)
        task.wait(1)
        vu:Button2Up(Vector2.new(0,0), Camera.CFrame)
    end)
end)

-- ════════════════════════════════════════════════════════════════
-- DEBUG
-- ════════════════════════════════════════════════════════════════

getgenv().DebugATM = function()
    Utils.Log("=== DEBUG INFO ===")
    Utils.Log("Executor: " .. DETECTED_EXECUTOR)
    Utils.Log("Cash Aura Mode: " .. (STATE.useCameraAura and "Camera" or "Simple"))
    
    local cashiers = Workspace:FindFirstChild("Cashiers")
    if cashiers then
        Utils.Log("Cashiers: " .. #cashiers:GetChildren())
    end
end

-- ════════════════════════════════════════════════════════════════
-- AUTO START
-- ════════════════════════════════════════════════════════════════

task.wait(2)
Farm.Start()

-- ════════════════════════════════════════════════════════════════
-- GLOBAL FUNCTIONS
-- ════════════════════════════════════════════════════════════════

getgenv().ATMFarm = {
    Start = Farm.Start,
    Stop = Farm.Stop,
    Debug = getgenv().DebugATM,
    SafeZone = teleportToSafeZone,
    GetStats = function()
        local sessionTime = os.time() - STATE.sessionStartTime
        return {
            Executor = DETECTED_EXECUTOR,
            CashAuraMode = STATE.useCameraAura and "Camera" or "Simple",
            TotalCash = STATE.totalCashCollected,
            ATMRobbed = STATE.atmRobbed,
            CurrentWallet = Utils.GetCurrentCash(),
            SessionTime = Utils.FormatTime(sessionTime),
        }
    end,
}

print("═══════════════════════════════════════")
print("[ATM FARM] Ultimate - v6.0")
print("[Executor] " .. DETECTED_EXECUTOR)
print("[Cash Aura] " .. (STATE.useCameraAura and "Camera Mode" or "Simple Mode"))
print("[Camera] Noclip Enabled")
print("[Safe Zone] Created")
print("═══════════════════════════════════════")
