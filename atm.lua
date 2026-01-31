print("made by _ethz on discord")

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

local LocalPlayer = Players.LocalPlayer
local MainEvent = ReplicatedStorage:WaitForChild("MainEvent", 10)

-- ════════════════════════════════════════════════════════════════
-- STATE MANAGEMENT
-- ════════════════════════════════════════════════════════════════

local STATE = {
    currentATMIndex = 1,
    deathCount = 0,
    totalCashCollected = 0,
    sessionStartTime = os.time(),
    isRunning = false,
    cashAuraActive = false,
    lastWebhookSent = 0,
    processedATMs = {}, -- Track processed ATMs
}

-- ════════════════════════════════════════════════════════════════
-- OPTIMIZATION
-- ════════════════════════════════════════════════════════════════

setfpscap(CONFIG.Fps)

pcall(function()loadstring(game:HttpGet('https://raw.githubusercontent.com/idktsperson/stuff/refs/heads/main/AntiCheatBypass.Lua'))()end)
--pcall(function()loadstring(game:HttpGet('https://raw.githubusercontent.com/idktsperson/stuff/refs/heads/main/Optimization.Lua'))()end)

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

function Utils.TeleportTo(position, studsBelow)
    pcall(function()
        if not Utils.IsValidCharacter(LocalPlayer.Character) then return end
        
        local targetPos = position - Vector3.new(0, studsBelow or 0, 0)
        LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(targetPos)
    end)
end

function Utils.AnchorCharacter(anchor)
    pcall(function()
        if Utils.IsValidCharacter(LocalPlayer.Character) then
            LocalPlayer.Character.HumanoidRootPart.Anchored = anchor
        end
    end)
end

function Utils.Log(message)
    print("[ATM FARM] " .. message)
end

-- ════════════════════════════════════════════════════════════════
-- WEBHOOK SYSTEM
-- ════════════════════════════════════════════════════════════════

local Webhook = {}

function Webhook.Send(title, description, color)
    if not CONFIG.WebhookEnabled or CONFIG.Webhook == "" then return end
    
    pcall(function()
        local currentTime = os.time()
        if currentTime - STATE.lastWebhookSent < (CONFIG.WebhookInterval * 60) then
            return
        end
        
        STATE.lastWebhookSent = currentTime
        
        local sessionTime = os.time() - STATE.sessionStartTime
        local hours = math.floor(sessionTime / 3600)
        local minutes = math.floor((sessionTime % 3600) / 60)
        
        local embed = {
            ["embeds"] = {{
                ["title"] = title,
                ["description"] = description,
                ["color"] = color or 3447003,
                ["fields"] = {
                    {
                        ["name"] = "💰 Total Cash",
                        ["value"] = "$" .. tostring(STATE.totalCashCollected),
                        ["inline"] = true
                    },
                    {
                        ["name"] = "💀 Deaths",
                        ["value"] = tostring(STATE.deathCount),
                        ["inline"] = true
                    },
                    {
                        ["name"] = "⏱️ Session",
                        ["value"] = string.format("%dh %dm", hours, minutes),
                        ["inline"] = true
                    },
                },
                ["footer"] = {
                    ["text"] = "ATM Farm • " .. os.date("%H:%M:%S")
                },
                ["timestamp"] = os.date("!%Y-%m-%dT%H:%M:%S")
            }}
        }
        
        request({
            Url = CONFIG.Webhook,
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json"
            },
            Body = HttpService:JSONEncode(embed)
        })
    end)
end

-- ════════════════════════════════════════════════════════════════
-- CASH AURA SYSTEM
-- ════════════════════════════════════════════════════════════════

local CashAura = {}

function CashAura.Start()
    if STATE.cashAuraActive then return end
    
    STATE.cashAuraActive = true
    Utils.Log("Cash Aura activated")
    
    task.spawn(function()
        while STATE.cashAuraActive do
            pcall(function()
                if not Utils.IsValidCharacter(LocalPlayer.Character) then return end
                
                local playerPos = LocalPlayer.Character.HumanoidRootPart.Position
                local dropsFolder = Workspace:FindFirstChild("Ignored") and Workspace.Ignored:FindFirstChild("Drop")
                
                if dropsFolder then
                    for _, drop in pairs(dropsFolder:GetChildren()) do
                        if drop.Name == "MoneyDrop" and drop:FindFirstChild("ClickDetector") then
                            local distance = (playerPos - drop.Position).Magnitude
                            
                            if distance < 12 then
                                fireclickdetector(drop.ClickDetector)
                                STATE.totalCashCollected = STATE.totalCashCollected + 10
                            end
                        end
                    end
                end
            end)
            task.wait(0.1)
        end
    end)
end

function CashAura.Stop()
    STATE.cashAuraActive = false
    Utils.Log("Cash Aura deactivated")
end

function CashAura.CheckNearbyDrops()
    local count = 0
    
    pcall(function()
        if not Utils.IsValidCharacter(LocalPlayer.Character) then return 0 end
        
        local playerPos = LocalPlayer.Character.HumanoidRootPart.Position
        local dropsFolder = Workspace:FindFirstChild("Ignored") and Workspace.Ignored:FindFirstChild("Drop")
        
        if dropsFolder then
            for _, drop in pairs(dropsFolder:GetChildren()) do
                if drop.Name == "MoneyDrop" then
                    local distance = (playerPos - drop.Position).Magnitude
                    if distance < 12 then
                        count = count + 1
                    end
                end
            end
        end
    end)
    
    return count
end

-- ════════════════════════════════════════════════════════════════
-- ATM DETECTION SYSTEM (IMPROVED)
-- ════════════════════════════════════════════════════════════════

local ATM = {}

function ATM.IsATMFilled(cashier)
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
            -- Skip if already processed
            if not STATE.processedATMs[cashier.Name] then
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
        
        -- Teleport to ATM (2 studs below)
        Utils.TeleportTo(atmData.Position, 2)
        task.wait(0.5)
        
        -- Anchor character
        Utils.AnchorCharacter(true)
        task.wait(0.2)
        
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
        
        -- Unanchor character
        Utils.AnchorCharacter(false)
        
        -- Mark as processed
        STATE.processedATMs[atmData.Name] = true
        
        Utils.Log("✅ ATM broken successfully!")
        return true
    end)
end

-- ════════════════════════════════════════════════════════════════
-- SERVER HOP SYSTEM
-- ════════════════════════════════════════════════════════════════

local ServerHop = {}

function ServerHop.Execute()
    Utils.Log("🔄 Server hopping...")
    Webhook.Send("🔄 Server Hopping", "Death limit reached. Switching servers...", 16776960)
    
    pcall(function()
        local placeId = game.PlaceId
        local servers = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. placeId .. "/servers/Public?sortOrder=Asc&limit=100"))
        
        for _, server in pairs(servers.data) do
            if server.id ~= game.JobId and server.playing < server.maxPlayers then
                TeleportService:TeleportToPlaceInstance(placeId, server.id, LocalPlayer)
                return
            end
        end
        
        TeleportService:Teleport(placeId, LocalPlayer)
    end)
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
    STATE.processedATMs = {} -- Reset processed ATMs
    
    Utils.Log("═══════════════════════════════════════")
    Utils.Log("🏧 ATM Farm Started!")
    Utils.Log("FPS: " .. CONFIG.Fps)
    Utils.Log("Server Hop: " .. tostring(CONFIG.ServerHop))
    Utils.Log("Webhook: " .. tostring(CONFIG.WebhookEnabled))
    Utils.Log("═══════════════════════════════════════")
    
    Webhook.Send("✅ Farm Started", "ATM farming session initiated", 3066993)
    
    -- Start cash aura
    CashAura.Start()
    
    task.spawn(function()
        while STATE.isRunning do
            local success, err = pcall(function()
                -- Scan for filled ATMs
                local filledATMs = ATM.ScanAll()
                
                if #filledATMs == 0 then
                    Utils.Log("⏳ No new filled ATMs. Waiting 15 seconds...")
                    Utils.Log("   (Processed: " .. #STATE.processedATMs .. " ATMs so far)")
                    task.wait(15)
                    
                    -- Reset processed ATMs every 5 minutes
                    if os.time() - STATE.sessionStartTime % 300 == 0 then
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
                        Utils.Log("💰 Waiting for cash drops...")
                        
                        -- Wait and collect cash
                        local maxWaitTime = 15
                        local waitedTime = 0
                        
                        while waitedTime < maxWaitTime and STATE.isRunning do
                            local nearbyDrops = CashAura.CheckNearbyDrops()
                            
                            Utils.Log("   Cash nearby: " .. nearbyDrops)
                            
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
                
                -- All ATMs done
                Utils.Log("🔄 All visible ATMs processed. Rescanning in 10 seconds...")
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
    Utils.AnchorCharacter(false)
    
    Utils.Log("🛑 Farm stopped!")
    Webhook.Send("🛑 Farm Stopped", "Session ended. Total: $" .. STATE.totalCashCollected, 15158332)
end

-- ════════════════════════════════════════════════════════════════
-- DEATH HANDLER
-- ════════════════════════════════════════════════════════════════

LocalPlayer.CharacterAdded:Connect(function(character)
    STATE.deathCount = STATE.deathCount + 1
    
    Utils.Log("💀 Death #" .. STATE.deathCount)
    Webhook.Send("💀 Death", "Total deaths: " .. STATE.deathCount, 15158332)
    
    ServerHop.CheckDeath()
    
    task.wait(3)
end)

-- ════════════════════════════════════════════════════════════════
-- ANTI-AFK
-- ════════════════════════════════════════════════════════════════

task.spawn(function()
    local vu = game:GetService("VirtualUser")
    LocalPlayer.Idled:Connect(function()
        vu:Button2Down(Vector2.new(0,0), Workspace.CurrentCamera.CFrame)
        task.wait(1)
        vu:Button2Up(Vector2.new(0,0), Workspace.CurrentCamera.CFrame)
    end)
end)

-- ════════════════════════════════════════════════════════════════
-- DEBUG COMMAND
-- ════════════════════════════════════════════════════════════════

getgenv().DebugATM = function()
    Utils.Log("=== DEBUG INFO ===")
    local cashiers = Workspace:FindFirstChild("Cashiers")
    if cashiers then
        Utils.Log("Cashiers found: " .. #cashiers:GetChildren())
        for i, cashier in ipairs(cashiers:GetChildren()) do
            Utils.Log("Cashier #" .. i .. ": " .. cashier.Name)
            local open = cashier:FindFirstChild("Open")
            if open then
                Utils.Log("  Size: " .. tostring(open.Size))
            else
                Utils.Log("  No 'Open' part found")
            end
        end
    else
        Utils.Log("Cashiers folder NOT FOUND")
    end
end

-- ════════════════════════════════════════════════════════════════
-- AUTO START
-- ════════════════════════════════════════════════════════════════

task.wait(3)
Farm.Start()

-- ════════════════════════════════════════════════════════════════
-- GLOBAL FUNCTIONS
-- ════════════════════════════════════════════════════════════════

getgenv().ATMFarm = {
    Start = Farm.Start,
    Stop = Farm.Stop,
    Debug = getgenv().DebugATM,
    GetStats = function()
        return {
            TotalCash = STATE.totalCashCollected,
            Deaths = STATE.deathCount,
            SessionTime = os.time() - STATE.sessionStartTime,
            CurrentATM = STATE.currentATMIndex,
            ProcessedATMs = #STATE.processedATMs,
            IsRunning = STATE.isRunning,
        }
    end,
    ResetProcessed = function()
        STATE.processedATMs = {}
        Utils.Log("Processed ATMs reset!")
    end
}

print("═══════════════════════════════════════")
print("[ATM FARM] Loaded - v2.0")
print("[Debug] getgenv().DebugATM()")
print("[Stats] getgenv().ATMFarm.GetStats()")
print("═══════════════════════════════════════")
