
getgenv().Configuration = getgenv().Configuration or {
    ['ServerHop'] = false,
    ['ServerHopNum'] = 5,
    ['WebhookEnabled'] = true,
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
}

-- ════════════════════════════════════════════════════════════════
-- OPTIMIZATION
-- ════════════════════════════════════════════════════════════════

setfpscap(CONFIG.Fps)

pcall(function()loadstring(game:HttpGet('https://raw.githubusercontent.com/idktsperson/stuff/refs/heads/main/AntiCheatBypass.Lua'))()end)
pcall(function()loadstring(game:HttpGet('https://raw.githubusercontent.com/idktsperson/stuff/refs/heads/main/Optimization.Lua'))()end)


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
                        ["name"] = "💰 Total Cash Collected",
                        ["value"] = "$" .. tostring(STATE.totalCashCollected),
                        ["inline"] = true
                    },
                    {
                        ["name"] = "💀 Death Count",
                        ["value"] = tostring(STATE.deathCount),
                        ["inline"] = true
                    },
                    {
                        ["name"] = "⏱️ Session Time",
                        ["value"] = string.format("%dh %dm", hours, minutes),
                        ["inline"] = true
                    },
                    {
                        ["name"] = "🏧 Current ATM",
                        ["value"] = tostring(STATE.currentATMIndex),
                        ["inline"] = true
                    },
                },
                ["footer"] = {
                    ["text"] = "Da Hood ATM Farm • " .. os.date("%H:%M:%S")
                },
                ["timestamp"] = os.date("!%Y-%m-%dT%H:%M:%S")
            }}
        }
        
        local response = request({
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
                                STATE.totalCashCollected = STATE.totalCashCollected + 10 -- Estimate
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
-- ATM DETECTION SYSTEM
-- ════════════════════════════════════════════════════════════════

local ATM = {}

function ATM.ScanAll()
    local filledATMs = {}
    
    pcall(function()
        local cashiers = Workspace:FindFirstChild("Cashiers")
        if not cashiers then
            Utils.Log("ERROR: Cashiers folder not found!")
            return
        end
        
        for index, cashier in ipairs(cashiers:GetChildren()) do
            local open = cashier:FindFirstChild("Open")
            
            if open and open.Size == Vector3.new(2.6, 0.5, 0.1) then
                table.insert(filledATMs, {
                    Index = index,
                    Name = cashier.Name,
                    Position = open.WorldPivot.Position,
                    Cashier = cashier,
                })
            end
        end
    end)
    
    return filledATMs
end

function ATM.Break(atmData)
    return pcall(function()
        Utils.Log("Breaking ATM: " .. atmData.Name .. " (#" .. atmData.Index .. ")")
        
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
        Utils.Log("Charge attack 1/2")
        MainEvent:FireServer("ChargeButton")
        task.wait(3)
        
        -- Second charge attack
        Utils.Log("Charge attack 2/2")
        MainEvent:FireServer("ChargeButton")
        task.wait(3)
        
        -- Unanchor character
        Utils.AnchorCharacter(false)
        
        Utils.Log("ATM broken successfully!")
        return true
    end)
end

-- ════════════════════════════════════════════════════════════════
-- SERVER HOP SYSTEM
-- ════════════════════════════════════════════════════════════════

local ServerHop = {}

function ServerHop.Execute()
    Utils.Log("Server hopping...")
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
        
        -- Fallback
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
    
    Utils.Log("═══════════════════════════════════════")
    Utils.Log("ATM Farm Started!")
    Utils.Log("FPS Cap: " .. CONFIG.Fps)
    Utils.Log("Server Hop: " .. tostring(CONFIG.ServerHop))
    Utils.Log("Webhook: " .. tostring(CONFIG.WebhookEnabled))
    Utils.Log("═══════════════════════════════════════")
    
    Webhook.Send("✅ Farm Started", "ATM farming session initiated", 3066993)
    
    -- Start cash aura
    CashAura.Start()
    
    task.spawn(function()
        while STATE.isRunning do
            pcall(function()
                -- Scan for filled ATMs
                local filledATMs = ATM.ScanAll()
                
                if #filledATMs == 0 then
                    Utils.Log("No filled ATMs found. Waiting...")
                    task.wait(10)
                    return
                end
                
                Utils.Log("Found " .. #filledATMs .. " filled ATMs")
                
                -- Farm each ATM
                for i, atmData in ipairs(filledATMs) do
                    if not STATE.isRunning then break end
                    
                    STATE.currentATMIndex = i
                    
                    -- Break ATM
                    local success = ATM.Break(atmData)
                    
                    if success then
                        Utils.Log("Waiting for cash drops...")
                        
                        -- Wait and collect cash
                        local maxWaitTime = 15
                        local waitedTime = 0
                        
                        while waitedTime < maxWaitTime and STATE.isRunning do
                            local nearbyDrops = CashAura.CheckNearbyDrops()
                            
                            if nearbyDrops == 0 then
                                Utils.Log("All cash collected!")
                                break
                            end
                            
                            task.wait(1)
                            waitedTime = waitedTime + 1
                        end
                    else
                        Utils.Log("Failed to break ATM, moving to next...")
                    end
                    
                    task.wait(2)
                end
                
                Utils.Log("All ATMs processed. Rescanning in 10 seconds...")
                Webhook.Send("🔄 Scanning", "All ATMs processed. Rescanning for new ones...", 3447003)
                task.wait(10)
            end)
        end
    end)
end

function Farm.Stop()
    STATE.isRunning = false
    CashAura.Stop()
    Utils.AnchorCharacter(false)
    
    Utils.Log("Farm stopped!")
    Webhook.Send("🛑 Farm Stopped", "ATM farming session ended", 15158332)
end

-- ════════════════════════════════════════════════════════════════
-- DEATH HANDLER
-- ════════════════════════════════════════════════════════════════

LocalPlayer.CharacterAdded:Connect(function(character)
    STATE.deathCount = STATE.deathCount + 1
    
    Utils.Log("Character respawned! Death count: " .. STATE.deathCount)
    Webhook.Send("💀 Death Detected", "Character died. Total deaths: " .. STATE.deathCount, 15158332)
    
    ServerHop.CheckDeath()
    
    task.wait(3)
    
    if STATE.isRunning then
        Utils.Log("Resuming farm after respawn...")
    end
end)

task.spawn(function()
    local vu = game:GetService("VirtualUser")
    LocalPlayer.Idled:Connect(function()
        vu:Button2Down(Vector2.new(0,0), Workspace.CurrentCamera.CFrame)
        task.wait(1)
        vu:Button2Up(Vector2.new(0,0), Workspace.CurrentCamera.CFrame)
    end)
end)

task.wait(3)
Farm.Start()

getgenv().ATMFarm = {
    Start = Farm.Start,
    Stop = Farm.Stop,
    GetStats = function()
        return {
            TotalCash = STATE.totalCashCollected,
            Deaths = STATE.deathCount,
            SessionTime = os.time() - STATE.sessionStartTime,
            CurrentATM = STATE.currentATMIndex,
            IsRunning = STATE.isRunning,
        }
    end
}

print("═══════════════════════════════════════")
print("[ATM FARM] Loaded Successfully!")
print("[Commands]")
print("  getgenv().ATMFarm.Start() - Start farm")
print("  getgenv().ATMFarm.Stop() - Stop farm")
print("  getgenv().ATMFarm.GetStats() - View stats")
print("═══════════════════════════════════════")
