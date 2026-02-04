--[[
    Da Hood ATM Farm System - CRASH SOUND DETECTION
    Camera pauses during ATM breaking, crash sound verification
]]

-- ════════════════════════════════════════════════════════════════
-- SECRET DEBUG MODE
-- ════════════════════════════════════════════════════════════════

getgenv().secretDebug = getgenv().secretDebug or false

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
    if getgenv().secretDebug then
        print("[ATM FARM] " .. message)
    end
end

-- ════════════════════════════════════════════════════════════════
-- EXECUTOR DETECTION
-- ════════════════════════════════════════════════════════════════

local EXECUTOR_TYPE = "UNKNOWN"

local function detectExecutor()
    if identifyexecutor then
        local success, executor = pcall(identifyexecutor)
        if success and executor then
            if string.find(string.lower(executor), "solara") then
                return "SOLARA"
            elseif string.find(string.lower(executor), "xeno") then
                return "XENO"
            end
        end
    end
    
    if getexecutorname then
        local success, executor = pcall(getexecutorname)
        if success and executor then
            if string.find(string.lower(executor), "solara") then
                return "SOLARA"
            elseif string.find(string.lower(executor), "xeno") then
                return "XENO"
            end
        end
    end
    
    return "OTHER"
end

local DETECTED_EXECUTOR = detectExecutor()
Utils.Log("Detected executor: " .. DETECTED_EXECUTOR)

-- ════════════════════════════════════════════════════════════════
-- STATE MANAGEMENT
-- ════════════════════════════════════════════════════════════════

local STATE = {
    currentATMIndex = 1,
    deathCount = 0,
    startingCash = Utils.GetCurrentCash(),
    atmRobbed = 0,
    sessionStartTime = os.time(),
    isRunning = false,
    cashAuraActive = false,
    cashAuraPaused = false,  -- NEW: Pause flag
    lastWebhookSent = 0,
    processedATMs = {},
    noclipConnection = nil,
    cframeLoopConnection = nil,
    lastCashCount = 0,
    noCashChangeTime = 0,
    useCameraAura = (DETECTED_EXECUTOR == "SOLARA" or DETECTED_EXECUTOR == "XENO"),
    lastProcessedReset = os.time(),
}

-- ════════════════════════════════════════════════════════════════
-- SAFE AFK ZONE
-- ════════════════════════════════════════════════════════════════

local SAFE_ZONE = {
    Position = Vector3.new(-3363.70337, 91784.7188, 11727.2256),
    Part = nil
}

local function createSafeZone()
    pcall(function()
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
        Utils.Log("Safe zone created")
    end)
end

local function teleportToSafeZone()
    pcall(function()
        if not SAFE_ZONE.Part then
            createSafeZone()
        end
        
        if Utils.IsValidCharacter(LocalPlayer.Character) then
            LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(SAFE_ZONE.Position + Vector3.new(0, 3, 0))
            Utils.Log("Teleported to safe zone")
        end
    end)
end

-- ════════════════════════════════════════════════════════════════
-- OPTIMIZATION
-- ════════════════════════════════════════════════════════════════

setfpscap(CONFIG.Fps)

settings().Rendering.QualityLevel = Enum.QualityLevel.Level01

pcall(function()loadstring(game:HttpGet("https://raw.githubusercontent.com/idktsperson/stuff/refs/heads/main/AntiCheatBypass.Lua"))()end)
pcall(function()loadstring(game:HttpGet("https://raw.githubusercontent.com/idktsperson/stuff/refs/heads/main/AntiSit.lua"))()end)

Lighting.GlobalShadows = false
Lighting.FogEnd = 100
Lighting.Brightness = 0

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
-- CAMERA SYSTEM
-- ════════════════════════════════════════════════════════════════

local CameraClip = {}

function CameraClip.Enable()
    pcall(function()
        sethiddenproperty(Camera, "DevCameraOcclusionMode", Enum.DevCameraOcclusionMode.Invisicam)
        LocalPlayer.CameraMaxZoomDistance = 9e9
        LocalPlayer.CameraMinZoomDistance = 0
        LocalPlayer.CameraMode = Enum.CameraMode.Classic
        
        pcall(function()
            Camera.FieldOfView = 70
        end)
        
        Utils.Log("Camera occlusion enabled")
    end)
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
-- CFRAME LOOP
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
-- CRASH SOUND DETECTOR
-- ════════════════════════════════════════════════════════════════

local CrashDetector = {}

function CrashDetector.WaitForCrash(timeout)
    local crashDetected = false
    local startTime = tick()
    
    -- Listen for crash sound
    local connection
    connection = Workspace.DescendantAdded:Connect(function(descendant)
        pcall(function()
            if descendant:IsA("Sound") and descendant.Name == "Crash" then
                crashDetected = true
                Utils.Log("  🔊 Crash sound detected!")
                connection:Disconnect()
            end
        end)
    end)
    
    -- Wait for timeout or crash
    while tick() - startTime < timeout and not crashDetected do
        task.wait(0.1)
    end
    
    connection:Disconnect()
    
    return crashDetected
end

-- ════════════════════════════════════════════════════════════════
-- WEBHOOK
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
            local profit = currentCash - STATE.startingCash
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
                            ["value"] = string.format("Username: **%s**\nDisplay Name: **%s**", LocalPlayer.Name, LocalPlayer.DisplayName),
                            ["inline"] = false
                        },
                        {
                            ["name"] = "💰 Auto Farm Info",
                            ["value"] = string.format("Profit: **$%d**\nRobbed: **%d**\nWallet: **$%d**\nElapsed: **%s**",
                                profit, STATE.atmRobbed, currentCash, Utils.FormatTime(sessionTime)),
                            ["inline"] = false
                        },
                        {
                            ["name"] = "📊 Statistics",
                            ["value"] = string.format("Deaths: **%d**\nCash/Hour: **$%d**\nATM/Hour: **%.1f**",
                                STATE.deathCount,
                                math.floor(profit / math.max(sessionTime / 3600, 0.01)),
                                STATE.atmRobbed / math.max(sessionTime / 3600, 0.01)),
                            ["inline"] = false
                        },
                    },
                    ["footer"] = {["text"] = "Da Hood ATM Farm • " .. os.date("%H:%M:%S")},
                    ["timestamp"] = os.date("!%Y-%m-%dT%H:%M:%S")
                }}
            }
            
            request({
                Url = CONFIG.Webhook,
                Method = "POST",
                Headers = {["Content-Type"] = "application/json"},
                Body = HttpService:JSONEncode(embed)
            })
            
            Utils.Log("Webhook sent! Profit: $" .. profit)
        end)
        
        if not success then
            Utils.Log("Webhook error: " .. tostring(err))
        end
    end)
end

-- ════════════════════════════════════════════════════════════════
-- CASH AURA (CAMERA MODE - WITH PAUSE)
-- ════════════════════════════════════════════════════════════════

local CashAuraCamera = {}
local Drops = Workspace:FindFirstChild("Ignored") and Workspace.Ignored:FindFirstChild("Drop")
local isProcessingCamera = false

function CashAuraCamera.Start()
    if STATE.cashAuraActive then return end
    
    STATE.cashAuraActive = true
    Utils.Log("Cash Aura (Camera) activated")
    
    task.spawn(function()
        while STATE.cashAuraActive do
            task.wait(0.15)
            
            -- CHECK PAUSE FLAG
            if STATE.cashAuraPaused then
                task.wait(0.5)
                continue
            end
            
            pcall(function()
                if not Utils.IsValidCharacter(LocalPlayer.Character) then return end
                if not Drops then
                    Drops = Workspace:FindFirstChild("Ignored") and Workspace.Ignored:FindFirstChild("Drop")
                    return
                end
                
                local playerPos = LocalPlayer.Character.HumanoidRootPart.Position
                
                for _, drop in pairs(Drops:GetChildren()) do
                    if drop.Name == "MoneyDrop" and not isProcessingCamera and not STATE.cashAuraPaused then
                        local distance = (drop.Position - playerPos).Magnitude
                        
                        if distance <= 12 then
                            isProcessingCamera = true
                            
                            for _, tool in pairs(LocalPlayer.Character:GetChildren()) do
                                if tool:IsA("Tool") then
                                    tool.Parent = LocalPlayer.Backpack
                                end
                            end
                            
                            Camera.CameraType = Enum.CameraType.Scriptable
                            
                            repeat
                                task.wait()
                                
                                if STATE.cashAuraPaused then break end
                                
                                local offset = Vector3.new(math.random(-30, 30) / 100, 2, math.random(-30, 30) / 100)
                                Camera.CFrame = CFrame.lookAt(drop.Position + offset, drop.Position)
                                
                                local viewportCenter = Camera.ViewportSize / 2
                                VirtualInputManager:SendMouseButtonEvent(viewportCenter.X, viewportCenter.Y, 0, true, game, 1)
                                task.wait(0.15)
                                VirtualInputManager:SendMouseButtonEvent(viewportCenter.X, viewportCenter.Y, 0, false, game, 1)
                                
                                if Utils.IsValidCharacter(LocalPlayer.Character) then
                                    distance = (drop.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                                else
                                    break
                                end
                                
                            until not drop or drop.Parent == nil or distance > 12 or STATE.cashAuraPaused
                            
                            Camera.CameraType = Enum.CameraType.Custom
                            Camera.CameraSubject = LocalPlayer.Character.Humanoid
                            
                            isProcessingCamera = false
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
    STATE.cashAuraPaused = false
    pcall(function()
        Camera.CameraType = Enum.CameraType.Custom
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            Camera.CameraSubject = LocalPlayer.Character.Humanoid
        end
    end)
end

-- ════════════════════════════════════════════════════════════════
-- CASH AURA (SIMPLE MODE)
-- ════════════════════════════════════════════════════════════════

local CashAuraSimple = {}

function CashAuraSimple.Start()
    if STATE.cashAuraActive then return end
    
    STATE.cashAuraActive = true
    Utils.Log("Cash Aura (Simple) activated")
    
    task.spawn(function()
        while STATE.cashAuraActive do
            task.wait(0.1)
            
            if STATE.cashAuraPaused then
                task.wait(0.5)
                continue
            end
            
            pcall(function()
                if not Utils.IsValidCharacter(LocalPlayer.Character) then return end
                if not Drops then
                    Drops = Workspace:FindFirstChild("Ignored") and Workspace.Ignored:FindFirstChild("Drop")
                    return
                end
                
                local playerPos = LocalPlayer.Character.HumanoidRootPart.Position
                
                for _, drop in pairs(Drops:GetChildren()) do
                    if drop.Name == "MoneyDrop" and drop:FindFirstChild("ClickDetector") and not STATE.cashAuraPaused then
                        local distance = (drop.Position - playerPos).Magnitude
                        
                        if distance < 12 then
                            fireclickdetector(drop.ClickDetector)
                        end
                    end
                end
            end)
        end
    end)
end

function CashAuraSimple.Stop()
    STATE.cashAuraActive = false
    STATE.cashAuraPaused = false
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

function CashAura.Pause()
    STATE.cashAuraPaused = true
    Utils.Log("Cash Aura paused")
end

function CashAura.Resume()
    STATE.cashAuraPaused = false
    Utils.Log("Cash Aura resumed")
end

function CashAura.GetNearbyCount()
    local count = 0
    
    pcall(function()
        if not Utils.IsValidCharacter(LocalPlayer.Character) then return end
        if not Drops then return end
        
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
-- SMART WAIT
-- ════════════════════════════════════════════════════════════════

local SmartWait = {}

function SmartWait.ForCashCollection()
    Utils.Log("💰 Collecting...")
    
    STATE.lastCashCount = CashAura.GetNearbyCount()
    STATE.noCashChangeTime = 0
    
    while STATE.isRunning do
        task.wait(0.5)
        
        local currentCashCount = CashAura.GetNearbyCount()
        
        if currentCashCount ~= STATE.lastCashCount then
            STATE.lastCashCount = currentCashCount
            STATE.noCashChangeTime = 0
            Utils.Log("   💵 Cash: " .. currentCashCount)
        else
            STATE.noCashChangeTime = STATE.noCashChangeTime + 0.5
        end
        
        if currentCashCount == 0 and STATE.noCashChangeTime >= 2 then
            Utils.Log("✅ Complete!")
            break
        end
        
        if STATE.noCashChangeTime >= 15 then
            Utils.Log("⏱️ Timeout")
            break
        end
    end
end

-- ════════════════════════════════════════════════════════════════
-- ATM POSITIONING
-- ════════════════════════════════════════════════════════════════

local ATMPositioning = {}

function ATMPositioning.GetOffset(atmPosition)
    local x = math.floor(atmPosition.X)
    local z = math.floor(atmPosition.Z)
    
    if (x == -624 or x == -625) and (z == -286 or z == -287) then
        Utils.Log("  Left ATM → offset right")
        return Vector3.new(3, 0, 0)
    end
    
    if (x == -627 or x == -628) and (z == -286 or z == -287) then
        Utils.Log("  Right ATM → offset left")
        return Vector3.new(-3, 0, 0)
    end
    
    return Vector3.new(0, 0, 0)
end

-- ════════════════════════════════════════════════════════════════
-- ATM DETECTION
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
        if math.abs(size.X - 2.6) < 0.2 and math.abs(size.Y - 0.5) < 0.2 and math.abs(size.Z - 0.1) < 0.2 then
            return true, open
        end
    end
    
    if open then
        return true, open
    end
    
    return false, nil
end

function ATM.ScanAll()
    local filledATMs = {}
    
    pcall(function()
        local cashiers = Workspace:FindFirstChild("Cashiers")
        if not cashiers then
            Utils.Log("ERROR: No Cashiers folder!")
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
                    
                    Utils.Log("  ✓ " .. cashier.Name)
                end
            end
        end
        
        Utils.Log("Total found: " .. #filledATMs)
    end)
    
    return filledATMs
end

function ATM.Break(atmData)
    return pcall(function()
        Utils.Log("═══════════════════════════════")
        Utils.Log("Breaking: " .. atmData.Name)
        
        -- PAUSE CASH AURA
        CashAura.Pause()
        
        Noclip.Enable()
        
        local positionOffset = ATMPositioning.GetOffset(atmData.Position)
        local targetPos = atmData.Position - Vector3.new(0, 4, 0) + positionOffset
        local targetCFrame = CFrame.new(targetPos) * CFrame.Angles(math.rad(90), 0, 0)
        
        CFrameLoop.Start(targetCFrame)
        task.wait(0.3)
        
        Utils.EquipCombat()
        task.wait(0.3)
        
        -- First charge
        Utils.Log("⚡ Charge 1/2")
        MainEvent:FireServer("ChargeButton")
        task.wait(3.5)
        
        -- Second charge with crash detection
        local maxRetries = 3
        local retryCount = 0
        local crashDetected = false
        
        while retryCount < maxRetries and not crashDetected do
            Utils.Log("⚡ Charge 2/2 (Attempt " .. (retryCount + 1) .. ")")
            MainEvent:FireServer("ChargeButton")
            
            -- Wait for crash sound (2.2 seconds timeout)
            crashDetected = CrashDetector.WaitForCrash(2.2)
            
            if crashDetected then
                Utils.Log("  ✅ ATM broken successfully!")
                break
            else
                Utils.Log("  ⚠️ No crash sound - retrying...")
                retryCount = retryCount + 1
                
                if retryCount < maxRetries then
                    task.wait(1)  -- Small delay before retry
                end
            end
        end
        
        if not crashDetected then
            Utils.Log("  ❌ Failed after " .. maxRetries .. " attempts")
            -- Don't mark as processed so it can be retried later
            CFrameLoop.Stop()
            Noclip.Disable()
            CashAura.Resume()
            return false
        end
        
        CFrameLoop.Stop()
        Noclip.Disable()
        
        -- Mark as processed only if successful
        STATE.processedATMs[atmData.Name] = true
        STATE.atmRobbed = STATE.atmRobbed + 1
        
        Utils.Log("✅ Complete! Total: " .. STATE.atmRobbed)
        
        -- RESUME CASH AURA
        CashAura.Resume()
        
        return true
    end)
end

-- ════════════════════════════════════════════════════════════════
-- SERVER HOP
-- ════════════════════════════════════════════════════════════════

local ServerHop = {}

function ServerHop.Execute()
    Utils.Log("🔄 Server hopping...")
    Webhook.Send("🔄 Server Hop", "No ATMs or death limit", 16776960)
    
    task.wait(2)
    
    pcall(function()
        local placeId = game.PlaceId
        TeleportService:Teleport(placeId, LocalPlayer)
    end)
end

function ServerHop.CheckNoATMs()
    if CONFIG.ServerHop then
        Utils.Log("⚠️ No ATMs - server hop in 30s...")
        task.wait(30)
        
        local atms = ATM.ScanAll()
        if #atms == 0 then
            ServerHop.Execute()
        end
    else
        Utils.Log("⚠️ No ATMs - safe zone...")
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
-- MAIN FARM
-- ════════════════════════════════════════════════════════════════

local Farm = {}

function Farm.Start()
    if STATE.isRunning then
        Utils.Log("Already running!")
        return
    end
    
    STATE.isRunning = true
    STATE.sessionStartTime = os.time()
    STATE.startingCash = Utils.GetCurrentCash()
    STATE.processedATMs = {}
    STATE.lastProcessedReset = os.time()
    
    Utils.Log("═══════════════════════════════════════")
    Utils.Log("🏧 ATM Farm Started!")
    Utils.Log("Executor: " .. DETECTED_EXECUTOR)
    Utils.Log("Starting Cash: $" .. STATE.startingCash)
    Utils.Log("Cash Aura: " .. (STATE.useCameraAura and "Camera" or "Simple"))
    Utils.Log("FPS: " .. CONFIG.Fps)
    Utils.Log("═══════════════════════════════════════")
    
    CameraClip.Enable()
    createSafeZone()
    
    Webhook.Send("✅ Farm Started", "Executor: " .. DETECTED_EXECUTOR, 3066993)
    
    CashAura.Start()
    
    task.spawn(function()
        while STATE.isRunning do
            local success, err = pcall(function()
                -- Reset processed ATMs every 3 minutes
                if os.time() - STATE.lastProcessedReset >= 180 then
                    STATE.processedATMs = {}
                    STATE.lastProcessedReset = os.time()
                    Utils.Log("🔄 Reset processed ATMs (3 min)")
                end
                
                local filledATMs = ATM.ScanAll()
                
                if #filledATMs == 0 then
                    Utils.Log("⏳ No ATMs (Robbed: " .. STATE.atmRobbed .. ")")
                    
                    ServerHop.CheckNoATMs()
                    
                    task.wait(20)
                    return
                end
                
                Utils.Log("🎯 Processing " .. #filledATMs .. " ATMs...")
                
                for i, atmData in ipairs(filledATMs) do
                    if not STATE.isRunning then break end
                    
                    STATE.currentATMIndex = i
                    
                    local breakSuccess, breakErr = ATM.Break(atmData)
                    
                    if breakSuccess then
                        SmartWait.ForCashCollection()
                    else
                        Utils.Log("❌ Failed: " .. tostring(breakErr))
                    end
                    
                    task.wait(1)
                end
                
                Utils.Log("🔄 Rescanning in 15s...")
                Webhook.Send("🔄 Scanning", "All visible ATMs processed", 3447003)
                task.wait(15)
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
    
    local profit = Utils.GetCurrentCash() - STATE.startingCash
    
    Utils.Log("🛑 Stopped!")
    Webhook.Send("🛑 Stopped", "Profit: $" .. profit, 15158332)
end

-- ════════════════════════════════════════════════════════════════
-- CHARACTER HANDLER
-- ════════════════════════════════════════════════════════════════

LocalPlayer.CharacterAdded:Connect(function(character)
    STATE.deathCount = STATE.deathCount + 1
    
    Utils.Log("💀 Death #" .. STATE.deathCount)
    Webhook.Send("💀 Death", "Total: " .. STATE.deathCount, 15158332)
    
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
-- GLOBAL FUNCTIONS
-- ════════════════════════════════════════════════════════════════

getgenv().ATMFarm = {
    Start = Farm.Start,
    Stop = Farm.Stop,
    SafeZone = teleportToSafeZone,
    GetStats = function()
        local profit = Utils.GetCurrentCash() - STATE.startingCash
        return {
            Executor = DETECTED_EXECUTOR,
            StartingCash = STATE.startingCash,
            CurrentCash = Utils.GetCurrentCash(),
            Profit = profit,
            ATMRobbed = STATE.atmRobbed,
            SessionTime = Utils.FormatTime(os.time() - STATE.sessionStartTime),
            DeathCount = STATE.deathCount,
        }
    end,
}

-- ════════════════════════════════════════════════════════════════
-- AUTO START
-- ════════════════════════════════════════════════════════════════

task.wait(2)
Farm.Start()

if getgenv().secretDebug then
    print("═══════════════════════════════════════")
    print("[ATM FARM] Loaded - v8.0 CRASH DETECT")
    print("[Executor] " .. DETECTED_EXECUTOR)
    print("[Starting Cash] $" .. STATE.startingCash)
    print("[Debug Mode] Enabled")
    print("═══════════════════════════════════════")
end
