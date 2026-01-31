print("Script Loading Please Wait...")
print("Made by _ethz on Discord")

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

-- Wait for game to load
repeat task.wait(0.1) until game:IsLoaded() and LocalPlayer

-- Wait for character to fully load
if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("FULLY_LOADED_CHAR") then 
    repeat task.wait(0.5) until LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("FULLY_LOADED_CHAR")
    task.wait(1)
end

local Camera = Workspace.CurrentCamera

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
}

setfpscap(CONFIG.Fps)

pcall(function()loadstring(game:HttpGet('https://raw.githubusercontent.com/idktsperson/stuff/refs/heads/main/AntiCheatBypass.Lua'))()end)
pcall(function()loadstring(game:HttpGet('https://raw.githubusercontent.com/idktsperson/stuff/refs/heads/main/AntiSit.lua'))()end)
--pcall(function()loadstring(game:HttpGet('https://raw.githubusercontent.com/idktsperson/stuff/refs/heads/main/Optimization.Lua'))()end)

local OcclusionCamera = {}

function OcclusionCamera.Enable()
    pcall(function()
        sethiddenproperty(Camera, "DevCameraOcclusionMode", "Invisicam")
        Utils.Log("Occlusion Camera enabled (Invisicam)")
    end)
end

function OcclusionCamera.Disable()
    pcall(function()
        sethiddenproperty(Camera, "DevCameraOcclusionMode", "Zoom")
    end)
end

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

local Webhook = {}

function Webhook.Send(title, description, color)
    if not CONFIG.WebhookEnabled or CONFIG.Webhook == "" then return end
    
    task.spawn(function()
        pcall(function()
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
                                string.format("%,d", STATE.totalCashCollected):gsub(",", "."),
                                STATE.atmRobbed,
                                string.format("%,d", currentCash):gsub(",", "."),
                                Utils.FormatTime(sessionTime)
                            ),
                            ["inline"] = false
                        },
                        {
                            ["name"] = "📊 Statistics",
                            ["value"] = string.format(
                                "Deaths: **%d**\nCash/Hour: **$%s**\nATM/Hour: **%.1f**",
                                STATE.deathCount,
                                string.format("%,d", math.floor(STATE.totalCashCollected / (sessionTime / 3600))):gsub(",", "."),
                                STATE.atmRobbed / (sessionTime / 3600)
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
            
            request({
                Url = CONFIG.Webhook,
                Method = "POST",
                Headers = {["Content-Type"] = "application/json"},
                Body = HttpService:JSONEncode(embed)
            })
        end)
    end)
end

-- ════════════════════════════════════════════════════════════════
-- CASH AURA SYSTEM (ADVANCED)
-- ════════════════════════════════════════════════════════════════

local CashAura = {}
local Drops = Workspace:FindFirstChild("Ignored") and Workspace.Ignored:FindFirstChild("Drop")
local isProcessing = false

function CashAura.Start()
    if STATE.cashAuraActive then return end
    
    STATE.cashAuraActive = true
    Utils.Log("Cash Aura activated (Advanced Mode)")
    
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
                    if drop.Name == "MoneyDrop" and not isProcessing then
                        local distance = (drop.Position - playerPos).Magnitude
                        
                        if distance <= 12 then
                            isProcessing = true
                            
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
                                
                                -- Point camera at money drop with random offset
                                local offset = Vector3.new(
                                    math.random(-30, 30) / 100,
                                    2,
                                    math.random(-30, 30) / 100
                                )
                                Camera.CFrame = CFrame.lookAt(drop.Position + offset, drop.Position)
                                
                                -- Click at center of screen
                                local viewportCenter = Camera.ViewportSize / 2
                                VirtualInputManager:SendMouseButtonEvent(viewportCenter.X, viewportCenter.Y, 0, true, game, 1)
                                task.wait(0.15)
                                VirtualInputManager:SendMouseButtonEvent(viewportCenter.X, viewportCenter.Y, 0, false, game, 1)
                                
                                -- Update distance
                                if Utils.IsValidCharacter(LocalPlayer.Character) then
                                    distance = (drop.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                                else
                                    break
                                end
                                
                            until not drop or drop.Parent == nil or distance > 12
                            
                            -- Restore camera
                            Camera.CameraType = Enum.CameraType.Custom
                            Camera.CameraSubject = LocalPlayer.Character.Humanoid
                            
                            isProcessing = false
                            STATE.totalCashCollected = STATE.totalCashCollected + 10
                        end
                    end
                end
            end)
        end
        
        -- Cleanup when stopped
        pcall(function()
            Camera.CameraType = Enum.CameraType.Custom
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                Camera.CameraSubject = LocalPlayer.Character.Humanoid
            end
        end)
    end)
end

function CashAura.Stop()
    STATE.cashAuraActive = false
    
    pcall(function()
        Camera.CameraType = Enum.CameraType.Custom
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            Camera.CameraSubject = LocalPlayer.Character.Humanoid
        end
    end)
    
    Utils.Log("Cash Aura deactivated")
end

function CashAura.CheckNearbyDrops()
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
-- ATM DETECTION SYSTEM (VAULT FILTERED)
-- ════════════════════════════════════════════════════════════════

local ATM = {}

function ATM.IsVault(cashier)
    -- Check if it's a VAULT (filter out)
    return string.find(string.upper(cashier.Name), "VAULT") ~= nil
end

function ATM.IsATMFilled(cashier)
    -- Filter out VAULT
    if ATM.IsVault(cashier) then
        return false, nil
    end
    
    -- Method 1: Check "Open" part with specific size
    local open = cashier:FindFirstChild("Open")
    if open and open:IsA("BasePart") then
        local size = open.Size
        -- Check if size is approximately 2.6, 0.5, 0.1
        if math.abs(size.X - 2.6) < 0.1 and math.abs(size.Y - 0.5) < 0.1 and math.abs(size.Z - 0.1) < 0.1 then
            return true, open
        end
    end
    
    -- Method 2: Check for any part named "Open" (regardless of size)
    if open then
        return true, open
    end
    
    -- Method 3: Look for largest part (backup method)
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
            -- Skip VAULT and already processed
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

        local hrp = LocalPlayer.Character.HumanoidRootPart
            
        task.wait(0.2)
        
        -- Teleport 4 studs below ATM
        local targetPos = atmData.Position - Vector3.new(0, 4, 0)
        
        if Utils.IsValidCharacter(LocalPlayer.Character) then
            
            -- Position character lying down, facing sky
            hrp.CFrame = CFrame.new(targetPos) * CFrame.Angles(math.rad(90), 0, 0)

            wait(0.5)

            hrp.Anchored = true
            hrp.AssemblyLinearVelocity = Vector3.zero
            hrp.AssemblyAngularVelocity = Vector3.zero

            Noclip.Enable()
                
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
            
            -- Unfreeze character
            hrp.Anchored = false
            
            -- Disable noclip
            Noclip.Disable()
            
            -- Mark as processed
            STATE.processedATMs[atmData.Name] = true
            STATE.atmRobbed = STATE.atmRobbed + 1
            
            Utils.Log("✅ ATM broken successfully! Total: " .. STATE.atmRobbed)
        end
        
        return true
    end)
end

-- ════════════════════════════════════════════════════════════════
-- SERVER HOP SYSTEM
-- ════════════════════════════════════════════════════════════════

local ServerHop = {}

function ServerHop.Execute()
    Utils.Log("🔄 Server hopping...")
    Webhook.Send("🔄 Server Hopping", "No ATMs found or death limit reached. Switching servers...", 16776960)
    
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
        task.wait(30) -- Wait 30 seconds before hopping
        
        -- Check again
        local atms = ATM.ScanAll()
        if #atms == 0 then
            ServerHop.Execute()
        end
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
    Utils.Log("FPS: " .. CONFIG.Fps)
    Utils.Log("Server Hop: " .. tostring(CONFIG.ServerHop))
    Utils.Log("Webhook: " .. tostring(CONFIG.WebhookEnabled))
    Utils.Log("Occlusion Camera: Enabled")
    Utils.Log("Noclip: Ready")
    Utils.Log("═══════════════════════════════════════")
    
    OcclusionCamera.Enable()
    Webhook.Send("✅ Farm Started", "ATM farming session initiated", 3066993)
    
    -- Start cash aura
    CashAura.Start()
    
    task.spawn(function()
        while STATE.isRunning do
            local success, err = pcall(function()
                -- Scan for filled ATMs
                local filledATMs = ATM.ScanAll()
                
                if #filledATMs == 0 then
                    Utils.Log("⏳ No new filled ATMs. Waiting...")
                    Utils.Log("   (Processed: " .. STATE.atmRobbed .. " ATMs so far)")
                    
                    -- Server hop if enabled
                    ServerHop.CheckNoATMs()
                    
                    task.wait(15)
                    
                    -- Reset processed ATMs every 5 minutes
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
                    
                    local breakSuccess, breakErr = ATM.Break(atmData)
                    
                    if breakSuccess then
                        Utils.Log("💰 Waiting for cash drops...")
                        
                        local maxWaitTime = 15
                        local waitedTime = 0
                        
                        while waitedTime < maxWaitTime and STATE.isRunning do
                            local nearbyDrops = CashAura.CheckNearbyDrops()
                            
                            if nearbyDrops > 0 then
                                Utils.Log("   Cash nearby: " .. nearbyDrops)
                            end
                            
                            if nearbyDrops == 0 and waitedTime > 3 then
                                Utils.Log("✅ All cash collected!")
                                break
                            end
                            
                            task.wait(1)
                            waitedTime = waitedTime + 1
                        end
                    else
                        Utils.Log("❌ Failed to break ATM: " .. tostring(breakErr))
                    end
                    
                    task.wait(2)
                end
                
                Utils.Log("🔄 All visible ATMs processed. Rescanning...")
                Webhook.Send("🔄 Scanning", "All ATMs processed. Rescanning for new ones...", 3447003)
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
    Noclip.Disable()
    
    pcall(function()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.Anchored = false
        end
    end)
    
    Utils.Log("🛑 Farm stopped!")
    Webhook.Send("🛑 Farm Stopped", "Session ended. Total profit: $" .. STATE.totalCashCollected, 15158332)
end

LocalPlayer.CharacterAdded:Connect(function(character)
    STATE.deathCount = STATE.deathCount + 1
    
    Utils.Log("💀 Death #" .. STATE.deathCount)
    Webhook.Send("💀 Death", "Character died. Total deaths: " .. STATE.deathCount, 15158332)
    
    ServerHop.CheckDeath()
    
    task.wait(0.5)
    if not character:FindFirstChild("FULLY_LOADED_CHAR") then
        repeat task.wait(0.5) until character:FindFirstChild("FULLY_LOADED_CHAR")
        task.wait(1)
    end
    
    Camera = Workspace.CurrentCamera
    OcclusionCamera.Enable()
    
    Drops = Workspace:FindFirstChild("Ignored") and Workspace.Ignored:FindFirstChild("Drop")
    
    Noclip.Disable()
end)

task.spawn(function() -- antiafk
    local vu = game:GetService("VirtualUser")
    LocalPlayer.Idled:Connect(function()
        vu:Button2Down(Vector2.new(0,0), Camera.CFrame)
        task.wait(1)
        vu:Button2Up(Vector2.new(0,0), Camera.CFrame)
    end)
end)

getgenv().DebugATM = function()
    Utils.Log("=== DEBUG INFO ===")
    local cashiers = Workspace:FindFirstChild("Cashiers")
    if cashiers then
        Utils.Log("Cashiers found: " .. #cashiers:GetChildren())
        for i, cashier in ipairs(cashiers:GetChildren()) do
            local isVault = ATM.IsVault(cashier)
            Utils.Log("Cashier #" .. i .. ": " .. cashier.Name .. (isVault and " [VAULT - FILTERED]" or ""))
            
            if not isVault then
                local open = cashier:FindFirstChild("Open")
                if open then
                    Utils.Log("  Size: " .. tostring(open.Size))
                    Utils.Log("  Position: " .. tostring(open.Position))
                else
                    Utils.Log("  No 'Open' part found")
                end
            end
        end
    else
        Utils.Log("Cashiers folder NOT FOUND")
    end
end

task.wait(2)
Farm.Start()

getgenv().ATMFarm = {
    Start = Farm.Start,
    Stop = Farm.Stop,
    Debug = getgenv().DebugATM,
    ToggleOcclusion = function()
        if Camera.DevCameraOcclusionMode == Enum.DevCameraOcclusionMode.Invisicam then
            OcclusionCamera.Disable()
        else
            OcclusionCamera.Enable()
        end
    end,
    GetStats = function()
        local sessionTime = os.time() - STATE.sessionStartTime
        return {
            Username = LocalPlayer.Name,
            DisplayName = LocalPlayer.DisplayName,
            TotalCash = STATE.totalCashCollected,
            ATMRobbed = STATE.atmRobbed,
            CurrentWallet = Utils.GetCurrentCash(),
            Deaths = STATE.deathCount,
            SessionTime = Utils.FormatTime(sessionTime),
            CashPerHour = math.floor(STATE.totalCashCollected / (sessionTime / 3600)),
            ATMPerHour = STATE.atmRobbed / (sessionTime / 3600),
            IsRunning = STATE.isRunning,
            CashAuraActive = STATE.cashAuraActive,
        }
    end,
    ResetProcessed = function()
        STATE.processedATMs = {}
        Utils.Log("Processed ATMs reset!")
    end
}

print("═══════════════════════════════════════")
print("[ATM FARM] Ultimate Version - v4.0")
print("[Features] Vault Filter, Noclip, Lying Attack")
print("[Webhook] Enhanced Statistics")
print("[Commands]")
print("  getgenv().DebugATM()")
print("  getgenv().ATMFarm.GetStats()")
print("═══════════════════════════════════════")
