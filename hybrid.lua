-- ═══════════════════════════════════════════════════════════
-- ATM FARM v12.0 HYBRID (Bizim + LDHC)
-- Modern Animasyonlu GUI + Anti-Cheat Bypass + Advanced Features
-- ═══════════════════════════════════════════════════════════

local plrr = game.Players.LocalPlayer

-- ═══════════════════════════════════════════════════════════
-- 1. ANTI-CHEAT BYPASS (LDHC XVNP_L SYSTEM)
-- ═══════════════════════════════════════════════════════════

local Lua_Fetch_Connections = getconnections
local Lua_Fetch_Upvalues = getupvalues
local Lua_Hook = hookfunction 
local Lua_Hook_Method = hookmetamethod
local Lua_Unhook = restorefunction
local Lua_Replace_Function = replaceclosure
local Lua_Set_Upvalue = setupvalue
local Lua_Clone_Function = clonefunction

local Game_RunService = game:GetService("RunService")
local Game_LogService = game:GetService("LogService")
local Game_LogService_MessageOut = Game_LogService.MessageOut

local String_Lower = string.lower
local Table_Find = table.find
local Get_Type = type

local Current_Connections = {};
local Hooked_Connections = {};

local function Test_Table(Table, Return_Type)
    for TABLE_INDEX, TABLE_VALUE in Table do
        if type(TABLE_VALUE) == String_Lower(Return_Type) then
            return TABLE_VALUE, TABLE_INDEX
        end
        continue
    end
end

local good_check = 0

function auth_heart()
    return true, true
end

function XVNP_L(CONNECTION)
    local s, e = pcall(function()
        local OPENAC_TABLE = Lua_Fetch_Upvalues(CONNECTION.Function)[9]
        local OPENAC_FUNCTION = OPENAC_TABLE[1]

        Lua_Set_Upvalue(OPENAC_FUNCTION, 14, function(...)
            return function(...)
                local args = {...}
                if type(args[1]) == "table" and args[1][1] then
                    pcall(function()
                        if type(args[1][1]) == "userdata" then
                            args[1][1]:Disconnect()
                            args[1][2]:Disconnect()
                            args[1][3]:Disconnect()
                            args[1][4]:Disconnect()
                        end
                    end)
                end 
            end
        end)

        Lua_Set_Upvalue(OPENAC_FUNCTION, 1, function(...)
            task.wait(200)
        end)

        hookfunction(OPENAC_FUNCTION, function(...)
            return {}
        end)
    end)
end

local XVNP_LASTUPDATE = 0
local XVNP_UPDATEINTERVAL = 5
local XVNP_CONNECTIONSNIFFER;

XVNP_CONNECTIONSNIFFER = Game_RunService.RenderStepped:Connect(function()
    if #Lua_Fetch_Connections(Game_LogService_MessageOut) >= 2 then
        XVNP_CONNECTIONSNIFFER:Disconnect()
    end

    if tick() - XVNP_LASTUPDATE >= XVNP_UPDATEINTERVAL then
        XVNP_LASTUPDATE = tick() 

        local OpenAc_Connections = Lua_Fetch_Connections(Game_LogService_MessageOut)

        for _, CONNECTION in OpenAc_Connections do
            if not table.find(Current_Connections, CONNECTION) then
                table.insert(Current_Connections, CONNECTION)
                table.insert(Hooked_Connections, CONNECTION)
                XVNP_L(CONNECTION)
            end
        end
    end
end)

local last_beat = 0
Game_RunService.RenderStepped:Connect(function()
    if last_beat + 1 < tick() then
        last_beat = tick() + 1 

        local what, are = auth_heart()

        if not are or not what then
            if good_check <= 0 then
                game.Players.LocalPlayer:Destroy()
                return
            else
                good_check -=1
            end
        else
            good_check += 1
        end
    end
end)

print("[ANTI-CHEAT] XVNP_L Bypass loaded")

-- ═══════════════════════════════════════════════════════════
-- VALIDATION
-- ═══════════════════════════════════════════════════════════

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

    local expectedServer = "https://discord.gg/aTb4K8Euta"
    if getgenv()._ATMFARM.Server ~= expectedServer then
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

getgenv()._secretDebugVar = getgenv()._secretDebugVar or false

getgenv().Configuration = getgenv().Configuration or {
    ['ServerHop'] = false,
    ['ServerHopNum'] = 5,
    ['WebhookEnabled'] = false,
    ['Webhook'] = "",
    ['WebhookInterval'] = 2,
    ['Fps'] = 15,
}

local CONFIG = getgenv().Configuration

-- ═══════════════════════════════════════════════════════════
-- SERVICES
-- ═══════════════════════════════════════════════════════════

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local MainEvent = ReplicatedStorage:WaitForChild("MainEvent", 10)

repeat task.wait(0.1) until game:IsLoaded() and LocalPlayer

if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("FULLY_LOADED_CHAR") then 
    repeat task.wait(0.5) until LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("FULLY_LOADED_CHAR")
    task.wait(1)
end

local Camera = Workspace.CurrentCamera

-- ═══════════════════════════════════════════════════════════
-- 3. DATA PERSISTENCE (LDHC SYSTEM)
-- ═══════════════════════════════════════════════════════════

local function saveUserData(userid, walletValue, profitValue, elapsedTime, timestamp)
    local userFolder = "userdata/"..userid
    if not isfolder("userdata") then makefolder("userdata") end
    if not isfolder(userFolder) then makefolder(userFolder) end

    local data = string.format("%s,%s,%s", walletValue, profitValue, elapsedTime)
    writefile(userFolder.."/data.txt", data)
    writefile(userFolder.."/timestamp.txt", tostring(timestamp))
end

local function loadUserData(userid)
    local userFolder = "userdata/"..userid
    if not isfolder(userFolder) then return nil end
    if not isfile(userFolder.."/data.txt") or not isfile(userFolder.."/timestamp.txt") then return nil end

    local lastSave = tonumber(readfile(userFolder.."/timestamp.txt"))
    if not lastSave or (tick() - lastSave > 180) then return nil end

    local data = readfile(userFolder.."/data.txt")
    local wallet, profit, elapsed = string.match(data, "([^,]+),([^,]+),([^,]+)")
    return tonumber(wallet), tonumber(profit), tonumber(elapsed)
end

-- ═══════════════════════════════════════════════════════════
-- MODERN ANIMASYONLU GUI
-- ═══════════════════════════════════════════════════════════

local G2L = {};

G2L["1"] = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"));
G2L["1"]["IgnoreGuiInset"] = true;
G2L["1"]["ScreenInsets"] = Enum.ScreenInsets.DeviceSafeInsets;
G2L["1"]["Name"] = [[AutoFarm]];
G2L["1"]["ZIndexBehavior"] = Enum.ZIndexBehavior.Sibling;
G2L["1"]["ResetOnSpawn"] = false;
G2L["1"]["DisplayOrder"] = 999999999;

-- Background
G2L["51"] = Instance.new("Frame", G2L["1"]);
G2L["51"]["BorderSizePixel"] = 0;
G2L["51"]["BackgroundColor3"] = Color3.fromRGB(0, 0, 0);
G2L["51"]["Size"] = UDim2.new(2, 0, 2, 0);
G2L["51"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
G2L["51"]["Name"] = [[Background]];
G2L["51"]["BackgroundTransparency"] = 0.3;

-- Main Frame
G2L["3"] = Instance.new("Frame", G2L["1"]);
G2L["3"]["ZIndex"] = 2;
G2L["3"]["BorderSizePixel"] = 0;
G2L["3"]["BackgroundColor3"] = Color3.fromRGB(18, 18, 18);
G2L["3"]["AnchorPoint"] = Vector2.new(0.5, 0.5);
G2L["3"]["Size"] = UDim2.new(0.476, 0, 0.725, 0);
G2L["3"]["Position"] = UDim2.new(0.5, 0, 0.5, 0);
G2L["3"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
G2L["3"]["Name"] = [[MainFrame]];

G2L["4"] = Instance.new("UICorner", G2L["3"]);
G2L["4"]["CornerRadius"] = UDim.new(0, 16);

G2L["stroke"] = Instance.new("UIStroke", G2L["3"]);
G2L["stroke"]["Color"] = Color3.fromRGB(0, 255, 0);
G2L["stroke"]["Thickness"] = 2;

-- Title
G2L["5"] = Instance.new("TextLabel", G2L["3"]);
G2L["5"]["TextWrapped"] = true;
G2L["5"]["ZIndex"] = 10;
G2L["5"]["BorderSizePixel"] = 0;
G2L["5"]["TextSize"] = 14;
G2L["5"]["TextXAlignment"] = Enum.TextXAlignment.Left;
G2L["5"]["TextScaled"] = true;
G2L["5"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["5"]["FontFace"] = Font.new([[rbxasset://fonts/families/FredokaOne.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["5"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
G2L["5"]["BackgroundTransparency"] = 1;
G2L["5"]["Size"] = UDim2.new(0.53454, 0, 0.08839, 0);
G2L["5"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
G2L["5"]["Text"] = [[Rysify ATM Farm v12.0]];
G2L["5"]["Name"] = [[Title]];
G2L["5"]["Position"] = UDim2.new(0.02254, 0, 0.02412, 0);

G2L["6"] = Instance.new("UIGradient", G2L["5"]);
G2L["6"]["Rotation"] = -90;
G2L["6"]["Color"] = ColorSequence.new{ColorSequenceKeypoint.new(0.000, Color3.fromRGB(0, 103, 0)),ColorSequenceKeypoint.new(1.000, Color3.fromRGB(0, 255, 0))};

G2L["7"] = Instance.new("UITextSizeConstraint", G2L["5"]);
G2L["7"]["MaxTextSize"] = 49;

-- Username Frame
G2L["9"] = Instance.new("Frame", G2L["3"]);
G2L["9"]["BorderSizePixel"] = 0;
G2L["9"]["BackgroundColor3"] = Color3.fromRGB(31, 31, 31);
G2L["9"]["Size"] = UDim2.new(0.472, 0, 0.232, 0);
G2L["9"]["Position"] = UDim2.new(0.02211, 0, 0.2027, 0);
G2L["9"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
G2L["9"]["Name"] = [[UsernameFrame]];

G2L["a"] = Instance.new("UICorner", G2L["9"]);
G2L["a"]["CornerRadius"] = UDim.new(0, 16);

G2L["b"] = Instance.new("UIStroke", G2L["9"]);
G2L["b"]["Color"] = Color3.fromRGB(94, 94, 94);

G2L["c"] = Instance.new("TextLabel", G2L["9"]);
G2L["c"]["TextWrapped"] = true;
G2L["c"]["TextStrokeTransparency"] = 0;
G2L["c"]["ZIndex"] = 10;
G2L["c"]["BorderSizePixel"] = 0;
G2L["c"]["TextSize"] = 14;
G2L["c"]["TextXAlignment"] = Enum.TextXAlignment.Left;
G2L["c"]["TextStrokeColor3"] = Color3.fromRGB(94, 94, 94);
G2L["c"]["TextScaled"] = true;
G2L["c"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["c"]["FontFace"] = Font.new([[rbxasset://fonts/families/FredokaOne.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["c"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
G2L["c"]["BackgroundTransparency"] = 1;
G2L["c"]["Size"] = UDim2.new(0.99482, 0, 0.23074, 0);
G2L["c"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
G2L["c"]["Text"] = LocalPlayer.Name;
G2L["c"]["Name"] = [[Username]];
G2L["c"]["Position"] = UDim2.new(0.01835, 0, 0.52701, 0);

G2L["d"] = Instance.new("UIGradient", G2L["c"]);
G2L["d"]["Rotation"] = -90;
G2L["d"]["Color"] = ColorSequence.new{ColorSequenceKeypoint.new(0.000, Color3.fromRGB(0, 103, 0)),ColorSequenceKeypoint.new(1.000, Color3.fromRGB(0, 255, 0))};

G2L["10"] = Instance.new("TextLabel", G2L["9"]);
G2L["10"]["TextWrapped"] = true;
G2L["10"]["TextStrokeTransparency"] = 0;
G2L["10"]["ZIndex"] = 10;
G2L["10"]["BorderSizePixel"] = 0;
G2L["10"]["TextSize"] = 14;
G2L["10"]["TextXAlignment"] = Enum.TextXAlignment.Left;
G2L["10"]["TextScaled"] = true;
G2L["10"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["10"]["FontFace"] = Font.new([[rbxasset://fonts/families/TitilliumWeb.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["10"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
G2L["10"]["BackgroundTransparency"] = 1;
G2L["10"]["Size"] = UDim2.new(0.51548, 0, 0.47809, 0);
G2L["10"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
G2L["10"]["Text"] = [[Username]];
G2L["10"]["Name"] = [[Title]];
G2L["10"]["Position"] = UDim2.new(0.00915, 0, -0.0002, 0);

-- Wallet Frame
G2L["17"] = Instance.new("Frame", G2L["3"]);
G2L["17"]["BorderSizePixel"] = 0;
G2L["17"]["BackgroundColor3"] = Color3.fromRGB(31, 31, 31);
G2L["17"]["Size"] = UDim2.new(0.472, 0, 0.232, 0);
G2L["17"]["Position"] = UDim2.new(0.02211, 0, 0.45451, 0);
G2L["17"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
G2L["17"]["Name"] = [[CashFrame]];

G2L["18"] = Instance.new("UICorner", G2L["17"]);
G2L["18"]["CornerRadius"] = UDim.new(0, 16);

G2L["19"] = Instance.new("UIStroke", G2L["17"]);
G2L["19"]["Color"] = Color3.fromRGB(94, 94, 94);

G2L["1a"] = Instance.new("TextLabel", G2L["17"]);
G2L["1a"]["TextWrapped"] = true;
G2L["1a"]["TextStrokeTransparency"] = 0;
G2L["1a"]["ZIndex"] = 10;
G2L["1a"]["BorderSizePixel"] = 0;
G2L["1a"]["TextSize"] = 14;
G2L["1a"]["TextXAlignment"] = Enum.TextXAlignment.Left;
G2L["1a"]["TextStrokeColor3"] = Color3.fromRGB(94, 94, 94);
G2L["1a"]["TextScaled"] = true;
G2L["1a"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["1a"]["FontFace"] = Font.new([[rbxasset://fonts/families/FredokaOne.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["1a"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
G2L["1a"]["BackgroundTransparency"] = 1;
G2L["1a"]["Size"] = UDim2.new(0.91457, 0, 0.2521, 0);
G2L["1a"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
G2L["1a"]["Text"] = [[$0]];
G2L["1a"]["Name"] = [[Wallet]];
G2L["1a"]["Position"] = UDim2.new(0.01568, 0, 0.5733, 0);

G2L["1b"] = Instance.new("UIGradient", G2L["1a"]);
G2L["1b"]["Rotation"] = -90;
G2L["1b"]["Color"] = ColorSequence.new{ColorSequenceKeypoint.new(0.000, Color3.fromRGB(0, 103, 0)),ColorSequenceKeypoint.new(1.000, Color3.fromRGB(0, 255, 0))};

G2L["1e"] = Instance.new("TextLabel", G2L["17"]);
G2L["1e"]["TextWrapped"] = true;
G2L["1e"]["TextStrokeTransparency"] = 0;
G2L["1e"]["ZIndex"] = 10;
G2L["1e"]["BorderSizePixel"] = 0;
G2L["1e"]["TextSize"] = 14;
G2L["1e"]["TextXAlignment"] = Enum.TextXAlignment.Left;
G2L["1e"]["TextScaled"] = true;
G2L["1e"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["1e"]["FontFace"] = Font.new([[rbxasset://fonts/families/TitilliumWeb.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["1e"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
G2L["1e"]["BackgroundTransparency"] = 1;
G2L["1e"]["Size"] = UDim2.new(0.37688, 0, 0.50771, 0);
G2L["1e"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
G2L["1e"]["Text"] = [[Wallet]];
G2L["1e"]["Name"] = [[Title]];
G2L["1e"]["Position"] = UDim2.new(0.01701, 0, 0.01523, 0);

-- Elapsed Frame
G2L["22"] = Instance.new("Frame", G2L["3"]);
G2L["22"]["BorderSizePixel"] = 0;
G2L["22"]["BackgroundColor3"] = Color3.fromRGB(31, 31, 31);
G2L["22"]["Size"] = UDim2.new(0.472, 0, 0.232, 0);
G2L["22"]["Position"] = UDim2.new(0.50645, 0, 0.20433, 0);
G2L["22"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
G2L["22"]["Name"] = [[ElapsedFrame]];

G2L["23"] = Instance.new("UICorner", G2L["22"]);
G2L["23"]["CornerRadius"] = UDim.new(0, 16);

G2L["24"] = Instance.new("UIStroke", G2L["22"]);
G2L["24"]["Color"] = Color3.fromRGB(94, 94, 94);

G2L["25"] = Instance.new("TextLabel", G2L["22"]);
G2L["25"]["TextWrapped"] = true;
G2L["25"]["TextStrokeTransparency"] = 0;
G2L["25"]["ZIndex"] = 10;
G2L["25"]["BorderSizePixel"] = 0;
G2L["25"]["TextSize"] = 14;
G2L["25"]["TextXAlignment"] = Enum.TextXAlignment.Left;
G2L["25"]["TextScaled"] = true;
G2L["25"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["25"]["FontFace"] = Font.new([[rbxasset://fonts/families/TitilliumWeb.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["25"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
G2L["25"]["BackgroundTransparency"] = 1;
G2L["25"]["Size"] = UDim2.new(0.39893, 0, 0.47684, 0);
G2L["25"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
G2L["25"]["Text"] = [[Elapsed]];
G2L["25"]["Name"] = [[Title]];
G2L["25"]["Position"] = UDim2.new(0.03455, 0, 0.03066, 0);

G2L["28"] = Instance.new("TextLabel", G2L["22"]);
G2L["28"]["TextWrapped"] = true;
G2L["28"]["TextStrokeTransparency"] = 0;
G2L["28"]["ZIndex"] = 10;
G2L["28"]["BorderSizePixel"] = 0;
G2L["28"]["TextSize"] = 14;
G2L["28"]["TextXAlignment"] = Enum.TextXAlignment.Left;
G2L["28"]["TextStrokeColor3"] = Color3.fromRGB(94, 94, 94);
G2L["28"]["TextScaled"] = true;
G2L["28"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["28"]["FontFace"] = Font.new([[rbxasset://fonts/families/FredokaOne.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["28"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
G2L["28"]["BackgroundTransparency"] = 1;
G2L["28"]["Size"] = UDim2.new(0.89472, 0, 0.23564, 0);
G2L["28"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
G2L["28"]["Text"] = [[00:00:00]];
G2L["28"]["Name"] = [[Elapsed]];
G2L["28"]["Position"] = UDim2.new(0.03589, 0, 0.58102, 0);

G2L["29"] = Instance.new("UIGradient", G2L["28"]);
G2L["29"]["Rotation"] = -90;
G2L["29"]["Color"] = ColorSequence.new{ColorSequenceKeypoint.new(0.000, Color3.fromRGB(0, 103, 0)),ColorSequenceKeypoint.new(1.000, Color3.fromRGB(0, 255, 0))};

-- Profit Frame
G2L["44"] = Instance.new("Frame", G2L["3"]);
G2L["44"]["BorderSizePixel"] = 0;
G2L["44"]["BackgroundColor3"] = Color3.fromRGB(31, 31, 31);
G2L["44"]["Size"] = UDim2.new(0.47194, 0, 0.23231, 0);
G2L["44"]["Position"] = UDim2.new(0.50576, 0, 0.45451, 0);
G2L["44"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
G2L["44"]["Name"] = [[ProfitFrame]];

G2L["45"] = Instance.new("UICorner", G2L["44"]);
G2L["45"]["CornerRadius"] = UDim.new(0, 16);

G2L["46"] = Instance.new("UIStroke", G2L["44"]);
G2L["46"]["Color"] = Color3.fromRGB(94, 94, 94);

G2L["47"] = Instance.new("TextLabel", G2L["44"]);
G2L["47"]["TextWrapped"] = true;
G2L["47"]["TextStrokeTransparency"] = 0;
G2L["47"]["ZIndex"] = 10;
G2L["47"]["BorderSizePixel"] = 0;
G2L["47"]["TextSize"] = 14;
G2L["47"]["TextXAlignment"] = Enum.TextXAlignment.Left;
G2L["47"]["TextStrokeColor3"] = Color3.fromRGB(94, 94, 94);
G2L["47"]["TextScaled"] = true;
G2L["47"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["47"]["FontFace"] = Font.new([[rbxasset://fonts/families/FredokaOne.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["47"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
G2L["47"]["BackgroundTransparency"] = 1;
G2L["47"]["Size"] = UDim2.new(0.91464, 0, 0.25158, 0);
G2L["47"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
G2L["47"]["Text"] = [[$0]];
G2L["47"]["Name"] = [[Profit]];
G2L["47"]["Position"] = UDim2.new(0.01568, 0, 0.5733, 0);

G2L["48"] = Instance.new("UIGradient", G2L["47"]);
G2L["48"]["Rotation"] = -90;
G2L["48"]["Color"] = ColorSequence.new{ColorSequenceKeypoint.new(0.000, Color3.fromRGB(0, 103, 0)),ColorSequenceKeypoint.new(1.000, Color3.fromRGB(0, 255, 0))};

G2L["4b"] = Instance.new("TextLabel", G2L["44"]);
G2L["4b"]["TextWrapped"] = true;
G2L["4b"]["TextStrokeTransparency"] = 0;
G2L["4b"]["ZIndex"] = 10;
G2L["4b"]["BorderSizePixel"] = 0;
G2L["4b"]["TextSize"] = 14;
G2L["4b"]["TextXAlignment"] = Enum.TextXAlignment.Left;
G2L["4b"]["TextScaled"] = true;
G2L["4b"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["4b"]["FontFace"] = Font.new([[rbxasset://fonts/families/TitilliumWeb.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["4b"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
G2L["4b"]["BackgroundTransparency"] = 1;
G2L["4b"]["Size"] = UDim2.new(0.37694, 0, 0.50715, 0);
G2L["4b"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
G2L["4b"]["Text"] = [[Profit]];
G2L["4b"]["Name"] = [[Title]];
G2L["4b"]["Position"] = UDim2.new(0.01701, 0, 0.01523, 0);

-- Status Frame
G2L["2d"] = Instance.new("Frame", G2L["3"]);
G2L["2d"]["BorderSizePixel"] = 0;
G2L["2d"]["BackgroundColor3"] = Color3.fromRGB(31, 31, 31);
G2L["2d"]["Size"] = UDim2.new(0.95627, 0, 0.15, 0);
G2L["2d"]["Position"] = UDim2.new(0.02211, 0, 0.81, 0);
G2L["2d"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
G2L["2d"]["Name"] = [[StatusFrame]];

G2L["2e"] = Instance.new("UICorner", G2L["2d"]);
G2L["2e"]["CornerRadius"] = UDim.new(0, 16);

G2L["2f"] = Instance.new("UIStroke", G2L["2d"]);
G2L["2f"]["Color"] = Color3.fromRGB(94, 94, 94);

G2L["30"] = Instance.new("TextLabel", G2L["2d"]);
G2L["30"]["TextWrapped"] = true;
G2L["30"]["ZIndex"] = 10;
G2L["30"]["BorderSizePixel"] = 0;
G2L["30"]["TextSize"] = 14;
G2L["30"]["TextScaled"] = true;
G2L["30"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["30"]["FontFace"] = Font.new([[rbxasset://fonts/families/TitilliumWeb.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["30"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
G2L["30"]["BackgroundTransparency"] = 1;
G2L["30"]["Size"] = UDim2.new(1, 0, 1, 0);
G2L["30"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
G2L["30"]["Text"] = [[🟢 Farm Running...]];
G2L["30"]["Name"] = [[StatusText]];

G2L["grad"] = Instance.new("UIGradient", G2L["30"]);
G2L["grad"]["Rotation"] = -90;
G2L["grad"]["Color"] = ColorSequence.new{ColorSequenceKeypoint.new(0.000, Color3.fromRGB(0, 103, 0)),ColorSequenceKeypoint.new(1.000, Color3.fromRGB(0, 255, 0))};

-- Profile Picture
task.spawn(function()
    local userId = LocalPlayer.UserId
    local thumbType = Enum.ThumbnailType.HeadShot
    local thumbSize = Enum.ThumbnailSize.Size420x420
    local content, isReady = Players:GetUserThumbnailAsync(userId, thumbType, thumbSize)
    
    G2L["41"] = Instance.new("ImageLabel", G2L["3"]);
    G2L["41"]["BorderSizePixel"] = 0;
    G2L["41"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
    G2L["41"]["AnchorPoint"] = Vector2.new(0.5, 0.5);
    G2L["41"]["Image"] = content;
    G2L["41"]["Size"] = UDim2.new(0.06886, 0, 0.10371, 0);
    G2L["41"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
    G2L["41"]["BackgroundTransparency"] = 1;
    G2L["41"]["Position"] = UDim2.new(0.94309, 0, 0.07504, 0);
    
    local corner = Instance.new("UICorner", G2L["41"]);
    corner["CornerRadius"] = UDim.new(1, 0);
end)

-- Background Gradient
G2L["50"] = Instance.new("UIGradient", G2L["3"]);
G2L["50"]["Rotation"] = -44;
G2L["50"]["Offset"] = Vector2.new(0.2, 0);
G2L["50"]["Color"] = ColorSequence.new{ColorSequenceKeypoint.new(0.000, Color3.fromRGB(14, 14, 14)),ColorSequenceKeypoint.new(1.000, Color3.fromRGB(18, 18, 18))};

local screenGui = G2L["1"]
local mainFrame = G2L["3"]
local background = G2L["51"]
local walletLabel = G2L["1a"]
local elapsedLabel = G2L["28"]
local profitLabel = G2L["47"]
local statusLabel = G2L["30"]

-- ═══════════════════════════════════════════════════════════
-- GUI ANIMATIONS
-- ═══════════════════════════════════════════════════════════

-- Fade in animation
mainFrame.BackgroundTransparency = 1
for i, v in pairs(mainFrame:GetDescendants()) do
    if v:IsA("TextLabel") or v:IsA("Frame") or v:IsA("ImageLabel") then
        if v:IsA("TextLabel") then
            v.TextTransparency = 1
        end
        if v:IsA("Frame") or v:IsA("ImageLabel") then
            v.BackgroundTransparency = 1
        end
    end
end

task.wait(0.5)

TweenService:Create(mainFrame, TweenInfo.new(1, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
    BackgroundTransparency = 0
}):Play()

task.wait(0.2)

for i, v in pairs(mainFrame:GetDescendants()) do
    if v:IsA("TextLabel") then
        TweenService:Create(v, TweenInfo.new(0.8, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
            TextTransparency = 0
        }):Play()
    end
    if v:IsA("Frame") and v.Name ~= "MainFrame" then
        TweenService:Create(v, TweenInfo.new(0.8, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
            BackgroundTransparency = 0
        }):Play()
    end
    if v:IsA("ImageLabel") then
        TweenService:Create(v, TweenInfo.new(0.8, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
            ImageTransparency = 0
        }):Play()
    end
end

-- Rainbow stroke animation
task.spawn(function()
    local hue = 0
    while task.wait(0.05) do
        hue = (hue + 1) % 360
        G2L["stroke"].Color = Color3.fromHSV(hue / 360, 1, 1)
    end
end)

-- Pulsing status text
task.spawn(function()
    while task.wait(1) do
        TweenService:Create(statusLabel, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
            TextSize = 16
        }):Play()
        task.wait(0.5)
        TweenService:Create(statusLabel, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
            TextSize = 14
        }):Play()
    end
end)

print("[GUI] Animasyonlu GUI yüklendi")

-- ═══════════════════════════════════════════════════════════
-- UTILITIES
-- ═══════════════════════════════════════════════════════════

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

function Utils.FormatCash(amount)
    local formatted = tostring(amount)
    local k
    
    while true do  
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
        if k == 0 then
            break
        end
    end
    
    return "$" .. formatted
end

function Utils.FormatCashWebhook(amount)
    local formatted = tostring(amount)
    local k
    
    while true do  
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
        if k == 0 then
            break
        end
    end
    
    return formatted
end

function Utils.Log(message)
    statusLabel.Text = "🟢 " .. message
    if getgenv()._secretDebugVar then
        print("[ATM FARM] " .. message)
    end
end

-- ═══════════════════════════════════════════════════════════
-- EXECUTOR DETECTION
-- ═══════════════════════════════════════════════════════════

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

-- ═══════════════════════════════════════════════════════════
-- STATE
-- ═══════════════════════════════════════════════════════════

-- Load previous data
local id = tostring(LocalPlayer.UserId)
local walletValue, profitValue, savedElapsed = loadUserData(id)

local data_folder = LocalPlayer:WaitForChild("DataFolder")
walletValue = walletValue or data_folder.Currency.Value
profitValue = profitValue or 0
savedElapsed = savedElapsed or 0

local STATE = {
    currentATMIndex = 1,
    deathCount = 0,
    startingCash = walletValue - profitValue,
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
    
    farmLoopRunning = false,
    totalElapsedTime = savedElapsed,
    lastStopTime = 0,
    renderingEnabled = false,
}

-- Auto-save every second
task.spawn(function()
    while task.wait(1) do
        local elapsedTime = STATE.isRunning and ((os.time() - STATE.sessionStartTime) + STATE.totalElapsedTime) or STATE.totalElapsedTime
        saveUserData(id, Utils.GetCurrentCash(), Utils.GetCurrentCash() - STATE.startingCash, elapsedTime, tick())
    end
end)

print("[DATA] Session loaded - Elapsed: " .. Utils.FormatTime(STATE.totalElapsedTime))

-- ═══════════════════════════════════════════════════════════
-- SAFE ZONE
-- ═══════════════════════════════════════════════════════════

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

-- ═══════════════════════════════════════════════════════════
-- OPTIMIZATION
-- ═══════════════════════════════════════════════════════════

RunService:Set3dRenderingEnabled(false)
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

-- ═══════════════════════════════════════════════════════════
-- SYSTEMS (continuing in next message due to length...)
-- ═══════════════════════════════════════════════════════════
