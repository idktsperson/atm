local plrr = game.Players.LocalPlayer

local function validateSettings()
    if not getgenv()._ATMFARM then
        plrr:Kick("Invalid Configuration - Missing _ATMFARM")
        return false
    end
    
    local expectedHash = "ATM_FARM_V10_BY_ETHZ"
    if getgenv()._ATMFARM.Hash ~= expectedHash then
        plrr:Kick("Tampering Detected - Configuration Modified")
        return false
    end

    local expectedDiscord = "Made by _ethz on Discord."
    if getgenv()._ATMFARM.Discord ~= expectedDiscord then
        plrr:Kick("Tampering Detected - Configuration Modified")
        return false
    end

    local expectedWarning = "If you paid for this script, you got scammed! This is FREE."
    if getgenv()._ATMFARM.Warning ~= expectedWarning then
        plrr:Kick("Tampering Detected - Configuration Modified")
        return false
    end

    local expectedExecute = "DO NOT edit _ATMFARM or you'll be kicked. Good Boy."
    if getgenv()._ATMFARM.Execute ~= expectedExecute then
        plrr:Kick("Tampering Detected - Configuration Modified")
        return false
    end
    
    return true
end

task.wait(0.5)
if not validateSettings() then
    return
end

getgenv().secretDebug = getgenv().secretDebug or false

getgenv().Configuration = getgenv().Configuration or {
    ['ServerHop'] = false,
    ['ServerHopNum'] = 5,
    ['WebhookEnabled'] = false,
    ['Webhook'] = "",
    ['WebhookInterval'] = 2,
    ['Fps'] = 15,
}

local CONFIG = getgenv().Configuration

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

repeat task.wait(0.1) until game:IsLoaded() and LocalPlayer

if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("FULLY_LOADED_CHAR") then 
    repeat task.wait(0.5) until LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("FULLY_LOADED_CHAR")
    task.wait(1)
end

local Camera = Workspace.CurrentCamera

local function createNotificationBar()
    local config = getgenv()._ATMFARM
    
    local gui = Instance.new("ScreenGui")
    gui.Name = "ATMFarmNotify"
    gui.DisplayOrder = 999999
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    
    local success = pcall(function()
        gui.Parent = game:GetService("CoreGui")
    end)
    
    if not success then
        gui.Parent = LocalPlayer.PlayerGui
    end
    
    local frame = Instance.new("Frame")
    frame.Name = "NotifyBar"
    frame.BackgroundColor3 = Color3.fromRGB(18, 18, 18) 
    frame.BorderSizePixel = 0
    frame.Size = UDim2.new(1, 0, 0, 25)
    frame.Position = UDim2.new(0, 0, 0, 5)
    frame.Parent = gui
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(35, 35, 35)
    stroke.Thickness = 1
    stroke.Parent = frame
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Name = "ScrollingText"
    textLabel.BackgroundTransparency = 1
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.Position = UDim2.new(0, 0, 0, 0)
    textLabel.Font = Enum.Font.FredokaOne
    textLabel.TextSize = 14
    textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    textLabel.TextXAlignment = Enum.TextXAlignment.Left
    textLabel.TextYAlignment = Enum.TextYAlignment.Center
    textLabel.ClipsDescendants = false
    textLabel.Parent = frame
    
    local padding = Instance.new("UIPadding")
    padding.PaddingLeft = UDim.new(0, 10)
    padding.Parent = textLabel
    
    local messages = {
        config.Discord or "Discord: Not Set",
        config.Warning or "Warning: Read Documentation",
        config.Execute or "Execute: Follow Instructions"
    }
    
    local scrollText = table.concat(messages, "  •  ") .. "  •            "
    textLabel.Text = scrollText .. scrollText
    
    task.spawn(function()
        local textSize = textLabel.TextBounds.X / 2
        local duration = textSize / 50
        
        while textLabel and textLabel.Parent do
            local tween = TweenService:Create(textLabel, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
                Position = UDim2.new(0, -textSize, 0, 0)
            })
            
            tween:Play()
            tween.Completed:Wait()
            
            textLabel.Position = UDim2.new(0, 0, 0, 0)
        end
    end)
    
    return gui
end

createNotificationBar()

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

local STATE = {
    currentATMIndex = 1,
    deathCount = 0,
    startingCash = Utils.GetCurrentCash(),
    atmRobbed = 0,
    sessionStartTime = os.time(),
    isRunning = false,
    cashAuraActive = false,
    cashAuraPaused = false,
    lastWebhookSent = 0,
    processedATMs = {},
    noclipConnection = nil,
    cframeLoopConnection = nil,
    lastCashCount = 0,
    noCashChangeTime = 0,
    useCameraAura = (DETECTED_EXECUTOR == "SOLARA" or DETECTED_EXECUTOR == "XENO"),
    lastProcessedReset = os.time(),
    currentTargetCFrame = nil,
}

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
            STATE.currentTargetCFrame = CFrame.new(SAFE_ZONE.Position + Vector3.new(0, 3, 0))
            Utils.Log("Teleported to safe zone")
        end
    end)
end

setfpscap(CONFIG.Fps)

pcall(function()loadstring(game:HttpGet("https://raw.githubusercontent.com/idktsperson/stuff/refs/heads/main/AntiCheatBypass.Lua"))()end)
pcall(function()loadstring(game:HttpGet("https://raw.githubusercontent.com/idktsperson/stuff/refs/heads/main/AntiSit.lua"))()end)

settings().Rendering.QualityLevel = Enum.QualityLevel.Level01

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
    
    Utils.Log("Noclip enabled")
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
    
    Utils.Log("Noclip disabled")
end

local CFrameLoop = {}

function CFrameLoop.Start()
    if STATE.cframeLoopConnection then return end
    
    STATE.currentTargetCFrame = CFrame.new(SAFE_ZONE.Position + Vector3.new(0, 3, 0))
    
    STATE.cframeLoopConnection = RunService.Heartbeat:Connect(function()
        pcall(function()
            if Utils.IsValidCharacter(LocalPlayer.Character) and STATE.currentTargetCFrame then
                LocalPlayer.Character.HumanoidRootPart.CFrame = STATE.currentTargetCFrame
                LocalPlayer.Character.HumanoidRootPart.AssemblyLinearVelocity = Vector3.zero
                LocalPlayer.Character.HumanoidRootPart.AssemblyAngularVelocity = Vector3.zero
            end
        end)
    end)
    
    Utils.Log("Permanent CFrame loop started")
end

function CFrameLoop.UpdatePosition(newCFrame)
    STATE.currentTargetCFrame = newCFrame
    Utils.Log("CFrame position updated")
end

function CFrameLoop.Stop()
    if STATE.cframeLoopConnection then
        STATE.cframeLoopConnection:Disconnect()
        STATE.cframeLoopConnection = nil
        STATE.currentTargetCFrame = nil
    end
    
    Utils.Log("CFrame loop stopped")
end

local Webhook = {}

function Webhook.Send(title, description, color, forceUpdate)
    if CONFIG.WebhookEnabled and (CONFIG.Webhook == "" or CONFIG.Webhook == nil) then
        Utils.Log("⚠️ Webhook enabled but URL is empty!")
        return
    end
    
    if not CONFIG.WebhookEnabled then
        Utils.Log("Webhook disabled, skipping send")
        return
    end
    
    task.spawn(function()
        local success, err = pcall(function()
            if not forceUpdate then
                local currentTime = os.time()
                local timeSinceLastWebhook = currentTime - STATE.lastWebhookSent
                local intervalSeconds = CONFIG.WebhookInterval * 60
                
                if timeSinceLastWebhook < intervalSeconds then
                    Utils.Log("Webhook skipped (interval: " .. timeSinceLastWebhook .. "/" .. intervalSeconds .. "s)")
                    return
                end
            end
            
            STATE.lastWebhookSent = os.time()
            
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
                    ["footer"] = {["text"] = "Made by _ethz on Discord! • " .. os.date("%H:%M:%S")},
                    ["timestamp"] = os.date("!%Y-%m-%dT%H:%M:%S")
                }}
            }
            
            request({
                Url = CONFIG.Webhook,
                Method = "POST",
                Headers = {["Content-Type"] = "application/json"},
                Body = HttpService:JSONEncode(embed)
            })
            
            Utils.Log("Webhook sent! (Profit: $" .. profit .. ")")
        end)
        
        if not success then
            Utils.Log("Webhook error: " .. tostring(err))
        end
    end)
end

task.spawn(function()
    while true do
        task.wait(60)
        
        if STATE.isRunning and CONFIG.WebhookEnabled then
            Webhook.Send("📊 Farm Update", "Periodic status update", 3447003, false)
        end
    end
end)

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

local ATMPositioning = {}

function ATMPositioning.GetOffset(atmPosition)
    local x = math.floor(atmPosition.X + 0.5)
    local z = math.floor(atmPosition.Z + 0.5)
    
    Utils.Log("  ATM Position: X=" .. x .. " Z=" .. z)
    
    if (x >= -625 and x <= -624) and (z >= -287 and z <= -286) then
        Utils.Log("  → Left ATM detected, offsetting +3 studs RIGHT")
        return Vector3.new(3, 0, 0)
    end
    
    if (x >= -628 and x <= -627) and (z >= -287 and z <= -286) then
        Utils.Log("  → Right ATM detected, offsetting -3 studs LEFT")
        return Vector3.new(-3, 0, 0)
    end
    
    Utils.Log("  → Normal ATM, no offset")
    return Vector3.new(0, 0, 0)
end

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
                    
                    Utils.Log("  ✓ " .. cashier.Name .. " at " .. tostring(targetPart.Position))
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
        
        CashAura.Pause()
        Noclip.Enable()
        
        local positionOffset = ATMPositioning.GetOffset(atmData.Position)
        
        local targetPos = atmData.Position - Vector3.new(0, 4, 0) + positionOffset
        local targetCFrame = CFrame.new(targetPos) * CFrame.Angles(math.rad(90), 0, 0)
        
        CFrameLoop.UpdatePosition(targetCFrame)
        task.wait(0.3)
        
        Utils.EquipCombat()
        task.wait(0.3)
        
        Utils.Log("⚡ Charge 1/2")
        MainEvent:FireServer("ChargeButton")
        task.wait(3.5)
        
        Utils.Log("⚡ Charge 2/2")
        MainEvent:FireServer("ChargeButton")
        task.wait(3.5)
        
        Noclip.Disable()
        
        STATE.processedATMs[atmData.Name] = true
        STATE.atmRobbed = STATE.atmRobbed + 1
        
        Utils.Log("✅ Complete! Total: " .. STATE.atmRobbed)
        
        CashAura.Resume()
        
        return true
    end)
end

local ServerHop = {}

function ServerHop.Execute()
    Utils.Log("🔄 Server hopping...")
    Webhook.Send("🔄 Server Hop", "No ATMs or death limit", 16776960, true)
    
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
    STATE.lastWebhookSent = 0
    
    Utils.Log("═══════════════════════════════════════")
    Utils.Log("🏧 ATM Farm Started!")
    Utils.Log("Executor: " .. DETECTED_EXECUTOR)
    Utils.Log("Starting Cash: $" .. STATE.startingCash)
    Utils.Log("Cash Aura: " .. (STATE.useCameraAura and "Camera" or "Simple"))
    Utils.Log("FPS: " .. CONFIG.Fps)
    Utils.Log("Webhook Interval: " .. CONFIG.WebhookInterval .. " minutes")
    Utils.Log("═══════════════════════════════════════")
    
    CameraClip.Enable()
    createSafeZone()
    Noclip.Enable()
    CFrameLoop.Start()
    
    Webhook.Send("✅ Farm Started", "Executor: " .. DETECTED_EXECUTOR, 3066993, true)
    
    CashAura.Start()
    
    task.spawn(function()
        while STATE.isRunning do
            local success, err = pcall(function()
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
    Webhook.Send("🛑 Stopped", "Profit: $" .. profit, 15158332, true)
end

LocalPlayer.CharacterAdded:Connect(function(character)
    STATE.deathCount = STATE.deathCount + 1
    
    Utils.Log("💀 Death #" .. STATE.deathCount)
    Webhook.Send("💀 Death", "Total: " .. STATE.deathCount, 15158332, true)
    
    ServerHop.CheckDeath()
    
    task.wait(0.5)
    if not character:FindFirstChild("FULLY_LOADED_CHAR") then
        repeat task.wait(0.5) until character:FindFirstChild("FULLY_LOADED_CHAR")
        task.wait(1)
    end
    
    Camera = Workspace.CurrentCamera
    CameraClip.Enable()
    Drops = Workspace:FindFirstChild("Ignored") and Workspace.Ignored:FindFirstChild("Drop")
    
    Noclip.Enable()
    CFrameLoop.Start()
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

getgenv().ATMFarm = {
    Start = Farm.Start,
    Stop = Farm.Stop,
    SafeZone = teleportToSafeZone,
    ForceWebhook = function()
        Webhook.Send("🔔 Manual Update", "Forced webhook update", 16776960, true)
    end,
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
            NextWebhook = Utils.FormatTime(math.max(0, (STATE.lastWebhookSent + (CONFIG.WebhookInterval * 60)) - os.time())),
            CFrameActive = STATE.cframeLoopConnection ~= nil,
            NoclipActive = STATE.noclipConnection ~= nil,
        }
    end,
}

task.wait(2)
Farm.Start()

if getgenv().secretDebug then
    print("═══════════════════════════════════════")
    print("[ATM FARM] Loaded - v10.0 FINAL")
    print("[Executor] " .. DETECTED_EXECUTOR)
    print("[Starting Cash] $" .. STATE.startingCash)
    print("[Permanent CFrame] Enabled")
    print("[Permanent Noclip] Enabled")
    print("[Debug Mode] Enabled")
    print("═══════════════════════════════════════")
end
