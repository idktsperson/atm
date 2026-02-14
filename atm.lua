-- ═══════════════════════════════════════════════════════════
-- ATM FARM v13.0 FINAL
-- Yeni Modern GUI + LDHC Features + Per Hour Graph
-- ═══════════════════════════════════════════════════════════

local plrr = game.Players.LocalPlayer

-- ═══════════════════════════════════════════════════════════
-- 1. ANTI-CHEAT BYPASS (LDHC XVNP_L SYSTEM)
-- ═══════════════════════════════════════════════════════════

local Lua_Fetch_Connections = getconnections
local Lua_Fetch_Upvalues = getupvalues
local Lua_Hook = hookfunction 
local Lua_Set_Upvalue = setupvalue

local Game_RunService = game:GetService("RunService")
local Game_LogService = game:GetService("LogService")
local Game_LogService_MessageOut = Game_LogService.MessageOut

local Current_Connections = {};
local Hooked_Connections = {};
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
-- YENİ MODERN GUI
-- ═══════════════════════════════════════════════════════════

local G2L = {};

G2L["1"] = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"));
G2L["1"]["IgnoreGuiInset"] = true;
G2L["1"]["ScreenInsets"] = Enum.ScreenInsets.DeviceSafeInsets;
G2L["1"]["Name"] = [[AutoFarm]];
G2L["1"]["ZIndexBehavior"] = Enum.ZIndexBehavior.Sibling;
G2L["1"]["DisplayOrder"] = 999999999;

-- Background
G2L["5d"] = Instance.new("Frame", G2L["1"]);
G2L["5d"]["BorderSizePixel"] = 0;
G2L["5d"]["BackgroundColor3"] = Color3.fromRGB(0, 0, 0);
G2L["5d"]["Size"] = UDim2.new(2, 0, 2, 0);
G2L["5d"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
G2L["5d"]["Name"] = [[Background]];
G2L["5d"]["BackgroundTransparency"] = 0.3;

-- MainFrame
G2L["3"] = Instance.new("Frame", G2L["1"]);
G2L["3"]["ZIndex"] = 2;
G2L["3"]["BorderSizePixel"] = 0;
G2L["3"]["BackgroundColor3"] = Color3.fromRGB(18, 18, 18);
G2L["3"]["AnchorPoint"] = Vector2.new(0.5, 0.5);
G2L["3"]["Size"] = UDim2.new(0.5235, 0, 0.7494, 0);
G2L["3"]["Position"] = UDim2.new(0.49732, 0, 0.50597, 0);
G2L["3"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
G2L["3"]["Name"] = [[MainFrame]];

G2L["58"] = Instance.new("UICorner", G2L["3"]);
G2L["58"]["CornerRadius"] = UDim.new(0, 16);

-- UIStroke with animated gradient
G2L["3d"] = Instance.new("UIStroke", G2L["3"]);
G2L["3d"]["Thickness"] = 5;
G2L["3d"]["Color"] = Color3.fromRGB(166, 166, 166);

G2L["3e"] = Instance.new("UIGradient", G2L["3d"]);
G2L["3e"]["Rotation"] = -90;
G2L["3e"]["Color"] = ColorSequence.new{
    ColorSequenceKeypoint.new(0.000, Color3.fromRGB(0, 0, 0)),
    ColorSequenceKeypoint.new(0.346, Color3.fromRGB(0, 0, 0)),
    ColorSequenceKeypoint.new(0.606, Color3.fromRGB(0, 103, 0)),
    ColorSequenceKeypoint.new(1.000, Color3.fromRGB(0, 255, 0))
};

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
G2L["5"]["Size"] = UDim2.new(0.38095, 0, 0.08259, 0);
G2L["5"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
G2L["5"]["Text"] = [[Rysify ATM Farm]];
G2L["5"]["Name"] = [[Title]];
G2L["5"]["Position"] = UDim2.new(0.02254, 0, 0.02412, 0);

G2L["7"] = Instance.new("UIGradient", G2L["5"]);
G2L["7"]["Rotation"] = -90;
G2L["7"]["Color"] = ColorSequence.new{
    ColorSequenceKeypoint.new(0.00, Color3.fromRGB(0, 180, 0)),
    ColorSequenceKeypoint.new(0.05, Color3.fromRGB(100, 255, 100)),
    ColorSequenceKeypoint.new(0.15, Color3.fromRGB(255, 255, 255)),
    ColorSequenceKeypoint.new(0.25, Color3.fromRGB(100, 255, 100)),
    ColorSequenceKeypoint.new(0.30, Color3.fromRGB(0, 120, 0)),
    ColorSequenceKeypoint.new(0.45, Color3.fromRGB(0, 120, 0)),
    ColorSequenceKeypoint.new(0.50, Color3.fromRGB(0, 180, 0)),
    ColorSequenceKeypoint.new(0.65, Color3.fromRGB(0, 180, 0)),
    ColorSequenceKeypoint.new(0.75, Color3.fromRGB(100, 255, 100)),
    ColorSequenceKeypoint.new(0.85, Color3.fromRGB(255, 255, 255)),
    ColorSequenceKeypoint.new(0.95, Color3.fromRGB(100, 255, 100)),
    ColorSequenceKeypoint.new(1.00, Color3.fromRGB(0, 180, 0))
};

G2L["8"] = Instance.new("UITextSizeConstraint", G2L["5"]);
G2L["8"]["MaxTextSize"] = 49;

-- Discord subtitle
G2L["14"] = Instance.new("TextLabel", G2L["3"]);
G2L["14"]["TextWrapped"] = true;
G2L["14"]["ZIndex"] = 10;
G2L["14"]["BorderSizePixel"] = 0;
G2L["14"]["TextSize"] = 14;
G2L["14"]["TextXAlignment"] = Enum.TextXAlignment.Left;
G2L["14"]["TextScaled"] = true;
G2L["14"]["BackgroundColor3"] = Color3.fromRGB(114, 114, 114);
G2L["14"]["FontFace"] = Font.new([[rbxasset://fonts/families/Nunito.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["14"]["TextColor3"] = Color3.fromRGB(191, 191, 191);
G2L["14"]["BackgroundTransparency"] = 1;
G2L["14"]["Size"] = UDim2.new(0.46003, 0, 0.03221, 0);
G2L["14"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
G2L["14"]["Text"] = [[discord.gg/aTb4K8Euta]];
G2L["14"]["Name"] = [[Title2]];
G2L["14"]["Position"] = UDim2.new(0.02632, 0, 0.11987, 0);

G2L["15"] = Instance.new("UITextSizeConstraint", G2L["14"]);
G2L["15"]["MaxTextSize"] = 18;

-- Username Frame
G2L["9"] = Instance.new("Frame", G2L["3"]);
G2L["9"]["BorderSizePixel"] = 0;
G2L["9"]["BackgroundColor3"] = Color3.fromRGB(31, 31, 31);
G2L["9"]["Size"] = UDim2.new(0.47045, 0, 0.19745, 0);
G2L["9"]["Position"] = UDim2.new(0.02159, 0, 0.18949, 0);
G2L["9"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
G2L["9"]["Name"] = [[UsernameFrame]];

G2L["a"] = Instance.new("UICorner", G2L["9"]);
G2L["a"]["CornerRadius"] = UDim.new(0, 16);

G2L["b"] = Instance.new("UIStroke", G2L["9"]);
G2L["b"]["Color"] = Color3.fromRGB(94, 94, 94);

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
G2L["10"]["Size"] = UDim2.new(0.71256, 0, 0.46774, 0);
G2L["10"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
G2L["10"]["Text"] = [[Username]];
G2L["10"]["Name"] = [[Title]];
G2L["10"]["Position"] = UDim2.new(0.02899, 0, 0.03226, 0);

G2L["12"] = Instance.new("UITextSizeConstraint", G2L["10"]);
G2L["12"]["MaxTextSize"] = 58;

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
G2L["c"]["Size"] = UDim2.new(0.8744, 0, 0.25, 0);
G2L["c"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
G2L["c"]["Text"] = LocalPlayer.Name;
G2L["c"]["Name"] = [[Username]];
G2L["c"]["Position"] = UDim2.new(0.03382, 0, 0.57258, 0);

G2L["d"] = Instance.new("UIGradient", G2L["c"]);
G2L["d"]["Rotation"] = -90;
G2L["d"]["Color"] = ColorSequence.new{ColorSequenceKeypoint.new(0.000, Color3.fromRGB(0, 103, 0)),ColorSequenceKeypoint.new(1.000, Color3.fromRGB(0, 255, 0))};

G2L["f"] = Instance.new("UITextSizeConstraint", G2L["c"]);
G2L["f"]["MaxTextSize"] = 31;

-- Cash Frame
G2L["17"] = Instance.new("Frame", G2L["3"]);
G2L["17"]["BorderSizePixel"] = 0;
G2L["17"]["BackgroundColor3"] = Color3.fromRGB(31, 31, 31);
G2L["17"]["Size"] = UDim2.new(0.47045, 0, 0.19745, 0);
G2L["17"]["Position"] = UDim2.new(0.02159, 0, 0.40446, 0);
G2L["17"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
G2L["17"]["Name"] = [[CashFrame]];

G2L["1d"] = Instance.new("UICorner", G2L["17"]);
G2L["1d"]["CornerRadius"] = UDim.new(0, 16);

G2L["1c"] = Instance.new("UIStroke", G2L["17"]);
G2L["1c"]["Color"] = Color3.fromRGB(94, 94, 94);

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
G2L["1e"]["Size"] = UDim2.new(0.37681, 0, 0.5, 0);
G2L["1e"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
G2L["1e"]["Text"] = [[Wallet]];
G2L["1e"]["Name"] = [[Title]];
G2L["1e"]["Position"] = UDim2.new(0.01691, 0, 0.00806, 0);

G2L["20"] = Instance.new("UITextSizeConstraint", G2L["1e"]);
G2L["20"]["MaxTextSize"] = 62;

G2L["18"] = Instance.new("TextLabel", G2L["17"]);
G2L["18"]["TextWrapped"] = true;
G2L["18"]["TextStrokeTransparency"] = 0;
G2L["18"]["ZIndex"] = 10;
G2L["18"]["BorderSizePixel"] = 0;
G2L["18"]["TextSize"] = 14;
G2L["18"]["TextXAlignment"] = Enum.TextXAlignment.Left;
G2L["18"]["TextStrokeColor3"] = Color3.fromRGB(94, 94, 94);
G2L["18"]["TextScaled"] = true;
G2L["18"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["18"]["FontFace"] = Font.new([[rbxasset://fonts/families/FredokaOne.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["18"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
G2L["18"]["BackgroundTransparency"] = 1;
G2L["18"]["Size"] = UDim2.new(0.91304, 0, 0.25, 0);
G2L["18"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
G2L["18"]["Text"] = [[$0]];
G2L["18"]["Name"] = [[Wallet]];
G2L["18"]["Position"] = UDim2.new(0.01449, 0, 0.57258, 0);

G2L["19"] = Instance.new("UIGradient", G2L["18"]);
G2L["19"]["Rotation"] = -90;
G2L["19"]["Color"] = ColorSequence.new{ColorSequenceKeypoint.new(0.000, Color3.fromRGB(0, 103, 0)),ColorSequenceKeypoint.new(1.000, Color3.fromRGB(0, 255, 0))};

G2L["1b"] = Instance.new("UITextSizeConstraint", G2L["18"]);
G2L["1b"]["MaxTextSize"] = 31;

-- Elapsed Frame
G2L["22"] = Instance.new("Frame", G2L["3"]);
G2L["22"]["BorderSizePixel"] = 0;
G2L["22"]["BackgroundColor3"] = Color3.fromRGB(31, 31, 31);
G2L["22"]["Size"] = UDim2.new(0.47045, 0, 0.19745, 0);
G2L["22"]["Position"] = UDim2.new(0.50568, 0, 0.18949, 0);
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
G2L["25"]["Size"] = UDim2.new(0.39855, 0, 0.47581, 0);
G2L["25"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
G2L["25"]["Text"] = [[Elapsed]];
G2L["25"]["Name"] = [[Title]];
G2L["25"]["Position"] = UDim2.new(0.03382, 0, 0.02419, 0);

G2L["27"] = Instance.new("UITextSizeConstraint", G2L["25"]);
G2L["27"]["MaxTextSize"] = 59;

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
G2L["28"]["Size"] = UDim2.new(0.89614, 0, 0.24194, 0);
G2L["28"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
G2L["28"]["Text"] = [[00:00:00]];
G2L["28"]["Name"] = [[Elapsed]];
G2L["28"]["Position"] = UDim2.new(0.03382, 0, 0.58065, 0);

G2L["29"] = Instance.new("UIGradient", G2L["28"]);
G2L["29"]["Rotation"] = -90;
G2L["29"]["Color"] = ColorSequence.new{ColorSequenceKeypoint.new(0.000, Color3.fromRGB(0, 103, 0)),ColorSequenceKeypoint.new(1.000, Color3.fromRGB(0, 255, 0))};

G2L["2b"] = Instance.new("UITextSizeConstraint", G2L["28"]);
G2L["2b"]["MaxTextSize"] = 30;

-- Profit Frame
G2L["32"] = Instance.new("Frame", G2L["3"]);
G2L["32"]["BorderSizePixel"] = 0;
G2L["32"]["BackgroundColor3"] = Color3.fromRGB(31, 31, 31);
G2L["32"]["Size"] = UDim2.new(0.47045, 0, 0.19745, 0);
G2L["32"]["Position"] = UDim2.new(0.02159, 0, 0.62102, 0);
G2L["32"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
G2L["32"]["Name"] = [[ProfitFrame]];

G2L["33"] = Instance.new("UICorner", G2L["32"]);
G2L["33"]["CornerRadius"] = UDim.new(0, 16);

G2L["34"] = Instance.new("UIStroke", G2L["32"]);
G2L["34"]["Color"] = Color3.fromRGB(94, 94, 94);

G2L["39"] = Instance.new("TextLabel", G2L["32"]);
G2L["39"]["TextWrapped"] = true;
G2L["39"]["TextStrokeTransparency"] = 0;
G2L["39"]["ZIndex"] = 10;
G2L["39"]["BorderSizePixel"] = 0;
G2L["39"]["TextSize"] = 14;
G2L["39"]["TextXAlignment"] = Enum.TextXAlignment.Left;
G2L["39"]["TextScaled"] = true;
G2L["39"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["39"]["FontFace"] = Font.new([[rbxasset://fonts/families/TitilliumWeb.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["39"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
G2L["39"]["BackgroundTransparency"] = 1;
G2L["39"]["Size"] = UDim2.new(0.33909, 0, 0.5, 0);
G2L["39"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
G2L["39"]["Text"] = [[Profit]];
G2L["39"]["Name"] = [[Title]];
G2L["39"]["Position"] = UDim2.new(0.01691, 0, 0, 0);

G2L["3b"] = Instance.new("UITextSizeConstraint", G2L["39"]);
G2L["3b"]["MaxTextSize"] = 62;

G2L["35"] = Instance.new("TextLabel", G2L["32"]);
G2L["35"]["TextWrapped"] = true;
G2L["35"]["TextStrokeTransparency"] = 0;
G2L["35"]["ZIndex"] = 10;
G2L["35"]["BorderSizePixel"] = 0;
G2L["35"]["TextSize"] = 14;
G2L["35"]["TextXAlignment"] = Enum.TextXAlignment.Left;
G2L["35"]["TextStrokeColor3"] = Color3.fromRGB(94, 94, 94);
G2L["35"]["TextScaled"] = true;
G2L["35"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["35"]["FontFace"] = Font.new([[rbxasset://fonts/families/FredokaOne.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["35"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
G2L["35"]["BackgroundTransparency"] = 1;
G2L["35"]["Size"] = UDim2.new(0.91304, 0, 0.25, 0);
G2L["35"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
G2L["35"]["Text"] = [[$0]];
G2L["35"]["Name"] = [[Profit]];
G2L["35"]["Position"] = UDim2.new(0.01449, 0, 0.57258, 0);

G2L["36"] = Instance.new("UIGradient", G2L["35"]);
G2L["36"]["Rotation"] = -90;
G2L["36"]["Color"] = ColorSequence.new{ColorSequenceKeypoint.new(0.000, Color3.fromRGB(0, 103, 0)),ColorSequenceKeypoint.new(1.000, Color3.fromRGB(0, 255, 0))};

G2L["38"] = Instance.new("UITextSizeConstraint", G2L["35"]);
G2L["38"]["MaxTextSize"] = 31;

-- Per Hour Frame
G2L["3f"] = Instance.new("Frame", G2L["3"]);
G2L["3f"]["BorderSizePixel"] = 0;
G2L["3f"]["BackgroundColor3"] = Color3.fromRGB(31, 31, 31);
G2L["3f"]["Size"] = UDim2.new(0.47159, 0, 0.41242, 0);
G2L["3f"]["Position"] = UDim2.new(0.50568, 0, 0.40446, 0);
G2L["3f"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
G2L["3f"]["Name"] = [[PerHourFrame]];

G2L["40"] = Instance.new("UICorner", G2L["3f"]);
G2L["40"]["CornerRadius"] = UDim.new(0, 16);

G2L["41"] = Instance.new("UIStroke", G2L["3f"]);
G2L["41"]["Color"] = Color3.fromRGB(94, 94, 94);

G2L["46"] = Instance.new("TextLabel", G2L["3f"]);
G2L["46"]["TextWrapped"] = true;
G2L["46"]["TextStrokeTransparency"] = 0;
G2L["46"]["ZIndex"] = 10;
G2L["46"]["BorderSizePixel"] = 0;
G2L["46"]["TextSize"] = 14;
G2L["46"]["TextXAlignment"] = Enum.TextXAlignment.Left;
G2L["46"]["TextScaled"] = true;
G2L["46"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["46"]["FontFace"] = Font.new([[rbxasset://fonts/families/TitilliumWeb.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["46"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
G2L["46"]["BackgroundTransparency"] = 1;
G2L["46"]["Size"] = UDim2.new(0.35904, 0, 0.32046, 0);
G2L["46"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
G2L["46"]["Text"] = [[Per Hour]];
G2L["46"]["Name"] = [[Title]];
G2L["46"]["Position"] = UDim2.new(0.03373, 0, -0.03861, 0);

G2L["48"] = Instance.new("UITextSizeConstraint", G2L["46"]);
G2L["48"]["MaxTextSize"] = 59;

G2L["42"] = Instance.new("TextLabel", G2L["3f"]);
G2L["42"]["TextWrapped"] = true;
G2L["42"]["TextStrokeTransparency"] = 0;
G2L["42"]["ZIndex"] = 10;
G2L["42"]["BorderSizePixel"] = 0;
G2L["42"]["TextSize"] = 14;
G2L["42"]["TextXAlignment"] = Enum.TextXAlignment.Left;
G2L["42"]["TextStrokeColor3"] = Color3.fromRGB(94, 94, 94);
G2L["42"]["TextScaled"] = true;
G2L["42"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["42"]["FontFace"] = Font.new([[rbxasset://fonts/families/FredokaOne.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["42"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
G2L["42"]["BackgroundTransparency"] = 1;
G2L["42"]["Size"] = UDim2.new(0.34217, 0, 0.40154, 0);
G2L["42"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
G2L["42"]["Text"] = [[$0]];
G2L["42"]["Name"] = [[PerHour]];
G2L["42"]["Position"] = UDim2.new(0.03373, 0, 0.11969, 0);

G2L["43"] = Instance.new("UIGradient", G2L["42"]);
G2L["43"]["Rotation"] = -90;
G2L["43"]["Color"] = ColorSequence.new{ColorSequenceKeypoint.new(0.000, Color3.fromRGB(0, 103, 0)),ColorSequenceKeypoint.new(1.000, Color3.fromRGB(0, 255, 0))};

G2L["45"] = Instance.new("UITextSizeConstraint", G2L["42"]);
G2L["45"]["MaxTextSize"] = 33;

-- Graph Frame
G2L["49"] = Instance.new("Frame", G2L["3f"]);
G2L["49"]["BorderSizePixel"] = 0;
G2L["49"]["BackgroundColor3"] = Color3.fromRGB(16, 21, 19);
G2L["49"]["Size"] = UDim2.new(0.99014, 0, 0.73904, 0);
G2L["49"]["Position"] = UDim2.new(-0.00241, 0, 0.24324, 0);
G2L["49"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
G2L["49"]["Name"] = [[PerHourGraphFrame]];
G2L["49"]["BackgroundTransparency"] = 1;

G2L["4b"] = Instance.new("UICorner", G2L["49"]);

-- Status Frame
G2L["4e"] = Instance.new("Frame", G2L["3"]);
G2L["4e"]["BorderSizePixel"] = 0;
G2L["4e"]["BackgroundColor3"] = Color3.fromRGB(31, 31, 31);
G2L["4e"]["Size"] = UDim2.new(0.95568, 0, 0.13057, 0);
G2L["4e"]["Position"] = UDim2.new(0.02159, 0, 0.83758, 0);
G2L["4e"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
G2L["4e"]["Name"] = [[StatusFrame]];

G2L["4f"] = Instance.new("UICorner", G2L["4e"]);
G2L["4f"]["CornerRadius"] = UDim.new(0, 16);

G2L["50"] = Instance.new("UIStroke", G2L["4e"]);
G2L["50"]["Color"] = Color3.fromRGB(94, 94, 94);

G2L["51"] = Instance.new("TextLabel", G2L["4e"]);
G2L["51"]["TextWrapped"] = true;
G2L["51"]["TextStrokeTransparency"] = 0;
G2L["51"]["ZIndex"] = 10;
G2L["51"]["BorderSizePixel"] = 0;
G2L["51"]["TextSize"] = 14;
G2L["51"]["TextXAlignment"] = Enum.TextXAlignment.Left;
G2L["51"]["TextScaled"] = true;
G2L["51"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["51"]["FontFace"] = Font.new([[rbxasset://fonts/families/TitilliumWeb.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["51"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
G2L["51"]["BackgroundTransparency"] = 1;
G2L["51"]["Size"] = UDim2.new(0.14605, 0, 0.57317, 0);
G2L["51"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
G2L["51"]["Text"] = [[Status:]];
G2L["51"]["Name"] = [[Title]];
G2L["51"]["Position"] = UDim2.new(0.36504, 0, 0.22841, 0);

G2L["53"] = Instance.new("UITextSizeConstraint", G2L["51"]);
G2L["53"]["MaxTextSize"] = 41;

G2L["54"] = Instance.new("TextLabel", G2L["4e"]);
G2L["54"]["TextWrapped"] = true;
G2L["54"]["TextStrokeTransparency"] = 0;
G2L["54"]["ZIndex"] = 10;
G2L["54"]["BorderSizePixel"] = 0;
G2L["54"]["TextSize"] = 14;
G2L["54"]["TextXAlignment"] = Enum.TextXAlignment.Left;
G2L["54"]["TextScaled"] = true;
G2L["54"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["54"]["FontFace"] = Font.new([[rbxasset://fonts/families/TitilliumWeb.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["54"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
G2L["54"]["BackgroundTransparency"] = 1;
G2L["54"]["Size"] = UDim2.new(0.14724, 0, 0.50965, 0);
G2L["54"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
G2L["54"]["Text"] = [[Running...]];
G2L["54"]["Name"] = [[StatusText]];
G2L["54"]["Position"] = UDim2.new(0.52319, 0, 0.24061, 0);

G2L["57"] = Instance.new("UITextSizeConstraint", G2L["54"]);
G2L["57"]["MaxTextSize"] = 41;

-- Status Color Indicator
G2L["5a"] = Instance.new("Frame", G2L["3"]);
G2L["5a"]["BorderSizePixel"] = 0;
G2L["5a"]["BackgroundColor3"] = Color3.fromRGB(0, 222, 0);
G2L["5a"]["Size"] = UDim2.new(0.01364, 0, 0.02707, 0);
G2L["5a"]["Position"] = UDim2.new(0.49091, 0, 0.89331, 0);
G2L["5a"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
G2L["5a"]["Name"] = [[SitationColor]];

G2L["5b"] = Instance.new("UICorner", G2L["5a"]);
G2L["5b"]["CornerRadius"] = UDim.new(1, 0);

-- Profile Picture
task.spawn(function()
    G2L["2d"] = Instance.new("ImageLabel", G2L["3"]);
    G2L["2d"]["BorderSizePixel"] = 0;
    G2L["2d"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
    G2L["2d"]["AnchorPoint"] = Vector2.new(0.5, 0.5);
    G2L["2d"]["Image"] = [[rbxasset://textures/ui/GuiImagePlaceholder.png]];
    G2L["2d"]["Size"] = UDim2.new(0.08171, 0, 0.11804, 0);
    G2L["2d"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
    G2L["2d"]["BackgroundTransparency"] = 1;
    G2L["2d"]["Position"] = UDim2.new(0.93534, 0, 0.08302, 0);
    
    local corner = Instance.new("UICorner", G2L["2d"]);
    corner["CornerRadius"] = UDim.new(1, 0);
    
    local userId = LocalPlayer.UserId
    local thumbType = Enum.ThumbnailType.HeadShot
    local thumbSize = Enum.ThumbnailSize.Size420x420
    local content, isReady = Players:GetUserThumbnailAsync(userId, thumbType, thumbSize)
    G2L["2d"]["Image"] = content
end)

-- Background Gradient
G2L["31"] = Instance.new("UIGradient", G2L["3"]);
G2L["31"]["Rotation"] = -44;
G2L["31"]["Offset"] = Vector2.new(0.2, 0);
G2L["31"]["Color"] = ColorSequence.new{
    ColorSequenceKeypoint.new(0.000, Color3.fromRGB(14, 14, 14)),
    ColorSequenceKeypoint.new(1.000, Color3.fromRGB(18, 18, 18))
};

local screenGui = G2L["1"]
local mainFrame = G2L["3"]
local background = G2L["5d"]
local walletLabel = G2L["18"]
local elapsedLabel = G2L["28"]
local profitLabel = G2L["35"]
local statusLabel = G2L["54"]
local perHourLabel = G2L["42"]
local graphFrame = G2L["49"]

-- ═══════════════════════════════════════════════════════════
-- GUI ANIMATIONS
-- ═══════════════════════════════════════════════════════════

-- Stroke rotation animation
task.spawn(function()
    local rotation = 0
    while task.wait() do
        rotation = rotation + 2
        G2L["3e"].Rotation = rotation % 360
    end
end)

-- Title gradient rotation
task.spawn(function()
    local rotation = 0
    while task.wait() do
        rotation = rotation + 50 * (1/60)
        G2L["7"].Rotation = rotation % 360
    end
end)

-- Status text animation
task.spawn(function()
    local states = {"Running...", "Running..", "Running.", "Running", "Running.", "Running.."}
    local i = 1
    while task.wait(0.6) do
        statusLabel.Text = states[i]
        i = (i % #states) + 1
    end
end)

print("[GUI] Modern GUI loaded")

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
    return string.format("%dh %dm %ds", hours, minutes, secs)
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
-- STATE + DATA PERSISTENCE
-- ═══════════════════════════════════════════════════════════

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
    isRunning = true,
    cashAuraActive = false,
    cashAuraPaused = false,
    lastWebhookSent = 0,
    processedATMs = {},  -- ← GERİ EKLENDİ
    noclipConnection = nil,
    cframeLoopConnection = nil,
    lastCashCount = 0,
    noCashChangeTime = 0,
    useCameraAura = (DETECTED_EXECUTOR == "SOLARA" or DETECTED_EXECUTOR == "XENO"),
    lastProcessedReset = os.time(),
    currentTargetCFrame = nil,
    
    farmLoopRunning = true,
    totalElapsedTime = savedElapsed,
    lastStopTime = 0,
    renderingEnabled = false,
    
    -- Per hour tracking
    profitHistory = {},
    lastProfitUpdate = os.time(),
}

-- Auto-save every second
task.spawn(function()
    while task.wait(1) do
        local elapsedTime = (os.time() - STATE.sessionStartTime) + STATE.totalElapsedTime
        saveUserData(id, Utils.GetCurrentCash(), Utils.GetCurrentCash() - STATE.startingCash, elapsedTime, tick())
    end
end)

print("[DATA] Session loaded - Elapsed: " .. Utils.FormatTime(STATE.totalElapsedTime))

-- ═══════════════════════════════════════════════════════════
-- PER HOUR GRAPH SYSTEM
-- ═══════════════════════════════════════════════════════════

local GraphSystem = {}

function GraphSystem.UpdateHistory()
    local currentProfit = Utils.GetCurrentCash() - STATE.startingCash
    local currentTime = os.time()
    
    table.insert(STATE.profitHistory, {
        profit = currentProfit,
        time = currentTime
    })
    
    -- Keep last 9 data points
    if #STATE.profitHistory > 9 then
        table.remove(STATE.profitHistory, 1)
    end
end

function GraphSystem.CalculatePerHour()
    if #STATE.profitHistory < 2 then return 0 end
    
    local totalTime = (os.time() - STATE.sessionStartTime) + STATE.totalElapsedTime
    if totalTime <= 0 then return 0 end
    
    local currentProfit = Utils.GetCurrentCash() - STATE.startingCash
    local perHour = (currentProfit / totalTime) * 3600
    
    return math.floor(perHour)
end

function GraphSystem.DrawGraph()
    -- Clear previous graph
    for _, child in pairs(graphFrame:GetChildren()) do
        if child.Name ~= "UICorner" then
            child:Destroy()
        end
    end
    
    if #STATE.profitHistory < 2 then return end
    
    local values = {}
    local maxProfit = 0
    
    for _, data in ipairs(STATE.profitHistory) do
        table.insert(values, data.profit)
        if data.profit > maxProfit then
            maxProfit = data.profit
        end
    end
    
    -- Normalize values (0 to 1)
    for i, v in ipairs(values) do
        values[i] = maxProfit > 0 and (v / maxProfit) or 0
    end
    
    local graphWidth = graphFrame.AbsoluteSize.X
    local graphHeight = graphFrame.AbsoluteSize.Y
    local paddingX = 20
    local paddingY = 20
    local drawWidth = graphWidth - (paddingX * 2)
    local drawHeight = graphHeight - (paddingY * 2)
    
    -- Draw grid
    local horizontalGridLines = 5
    local gridColor = Color3.fromRGB(70, 70, 80)
    local gridThickness = 1
    
    for i = 0, horizontalGridLines do
        local y = paddingY + (i / horizontalGridLines) * drawHeight
        local dashCount = 20
        local dashWidth = drawWidth / dashCount
        local dashLength = dashWidth * 0.6
        
        for j = 0, dashCount - 1 do
            local dashX = paddingX + (j * dashWidth)
            
            local dash = Instance.new("Frame")
            dash.Name = "HDash" .. i .. "_" .. j
            dash.Size = UDim2.new(0, dashLength, 0, gridThickness)
            dash.Position = UDim2.new(0, dashX, 0, y)
            dash.BackgroundColor3 = gridColor
            dash.BorderSizePixel = 0
            dash.ZIndex = 0
            dash.BackgroundTransparency = 0.3
            dash.Parent = graphFrame
        end
    end
    
    -- Calculate points
    local points = {}
    for i, value in ipairs(values) do
        local x = paddingX + ((i - 1) / (#values - 1)) * drawWidth
        local y = paddingY + (1 - value) * drawHeight
        points[i] = {x = x, y = y}
    end
    
    -- Draw area fill
    for i = 1, #points - 1 do
        local p1 = points[i]
        local p2 = points[i + 1]
        
        local fillHeight = (graphHeight - paddingY) - math.min(p1.y, p2.y)
        
        local areaFill = Instance.new("Frame")
        areaFill.Name = "AreaFill" .. i
        areaFill.Size = UDim2.new(0, p2.x - p1.x, 0, fillHeight + 20)
        areaFill.Position = UDim2.new(0, p1.x, 0, math.min(p1.y, p2.y))
        areaFill.BackgroundColor3 = Color3.fromRGB(0, 180, 100)
        areaFill.BorderSizePixel = 0
        areaFill.ZIndex = 0
        areaFill.BackgroundTransparency = 0.8
        areaFill.Parent = graphFrame
        
        local gradient = Instance.new("UIGradient")
        gradient.Rotation = 90
        gradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 150)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 100, 60))
        })
        gradient.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.6),
            NumberSequenceKeypoint.new(1, 0.95)
        })
        gradient.Parent = areaFill
    end
    
    -- Draw lines
    local lineThickness = 3
    for i = 1, #points - 1 do
        local p1 = points[i]
        local p2 = points[i + 1]
        
        local startVector = Vector2.new(p1.x, p1.y)
        local endVector = Vector2.new(p2.x, p2.y)
        local distance = (startVector - endVector).Magnitude
        
        local dx = p2.x - p1.x
        local dy = p2.y - p1.y
        local angle = math.atan2(dy, dx) * (180 / math.pi)
        
        -- Glow line
        local glowLine = Instance.new("Frame")
        glowLine.Name = "GlowLine" .. i
        glowLine.AnchorPoint = Vector2.new(0.5, 0.5)
        glowLine.Size = UDim2.new(0, distance, 0, lineThickness * 2.5)
        glowLine.Position = UDim2.new(0, (p1.x + p2.x) / 2, 0, (p1.y + p2.y) / 2)
        glowLine.Rotation = angle
        glowLine.BackgroundColor3 = Color3.fromRGB(0, 255, 150)
        glowLine.BackgroundTransparency = 0.8
        glowLine.BorderSizePixel = 0
        glowLine.ZIndex = 0
        glowLine.Parent = graphFrame
        
        -- Main line
        local line = Instance.new("Frame")
        line.Name = "Line" .. i
        line.AnchorPoint = Vector2.new(0.5, 0.5)
        line.Size = UDim2.new(0, distance, 0, lineThickness)
        line.Position = UDim2.new(0, (p1.x + p2.x) / 2, 0, (p1.y + p2.y) / 2)
        line.Rotation = angle
        line.BackgroundColor3 = Color3.fromRGB(0, 200, 120)
        line.BorderSizePixel = 0
        line.ZIndex = 1
        line.Parent = graphFrame
        
        local gradient = Instance.new("UIGradient")
        gradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 150)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 220, 130)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 255, 150))
        })
        gradient.Parent = line
    end
    
    -- Draw points
    local pointSize = 8
    for i, point in ipairs(points) do
        -- Outer glow
        local outerGlow = Instance.new("Frame")
        outerGlow.Name = "OuterGlow" .. i
        outerGlow.Size = UDim2.new(0, pointSize * 2.5, 0, pointSize * 2.5)
        outerGlow.Position = UDim2.new(0, point.x, 0, point.y)
        outerGlow.AnchorPoint = Vector2.new(0.5, 0.5)
        outerGlow.BackgroundColor3 = Color3.fromRGB(0, 255, 150)
        outerGlow.BackgroundTransparency = 0.7
        outerGlow.BorderSizePixel = 0
        outerGlow.ZIndex = 1
        outerGlow.Parent = graphFrame
        
        local outerCorner = Instance.new("UICorner")
        outerCorner.CornerRadius = UDim.new(1, 0)
        outerCorner.Parent = outerGlow
        
        -- Main dot
        local dot = Instance.new("Frame")
        dot.Name = "Dot" .. i
        dot.Size = UDim2.new(0, pointSize, 0, pointSize)
        dot.Position = UDim2.new(0, point.x, 0, point.y)
        dot.AnchorPoint = Vector2.new(0.5, 0.5)
        dot.BackgroundColor3 = Color3.fromRGB(0, 255, 150)
        dot.BorderSizePixel = 0
        dot.ZIndex = 2
        dot.Parent = graphFrame
        
        -- Inner dot
        local innerDot = Instance.new("Frame")
        innerDot.Name = "InnerDot"
        innerDot.Size = UDim2.new(0.4, 0, 0.4, 0)
        innerDot.Position = UDim2.new(0.5, 0, 0.5, 0)
        innerDot.AnchorPoint = Vector2.new(0.5, 0.5)
        innerDot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        innerDot.BackgroundTransparency = 0.3
        innerDot.BorderSizePixel = 0
        innerDot.ZIndex = 3
        innerDot.Parent = dot
        
        local innerCorner = Instance.new("UICorner")
        innerCorner.CornerRadius = UDim.new(1, 0)
        innerCorner.Parent = innerDot
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(1, 0)
        corner.Parent = dot
    end
end

-- Update graph every 10 seconds
task.spawn(function()
    while task.wait(10) do
        GraphSystem.UpdateHistory()
        GraphSystem.DrawGraph()
    end
end)

print("[GRAPH] Per hour system loaded")

-- ═══════════════════════════════════════════════════════════
-- ATM FARM v13.0 FINAL - PART 2
-- Advanced Server Hop + Farm Logic + All Systems
-- ═══════════════════════════════════════════════════════════

-- Bu dosya Part 1'in devamıdır. İçindekiler:
-- 1. Advanced Server Hop (LDHC System)
-- 2. Safe Zone
-- 3. Optimization
-- 4. Camera Systems
-- 5. Noclip
-- 6. CFrame Loop
-- 7. Webhook
-- 8. Cash Aura (Dual System)
-- 9. ATM Systems
-- 10. Farm Logic
-- 11. GUI Updaters

-- Part 1'deki değişkenler devam ediyor...

-- ═══════════════════════════════════════════════════════════
-- 2. ADVANCED SERVER HOP (LDHC SYSTEM)
-- ═══════════════════════════════════════════════════════════

if CONFIG.ServerHop then
    local blacklistedids = {
        163721789, 15427717, 201454243, 822999, 63794379,
        17260230, 28357488, 93101606, 8195210, 89473551,
        16917269, 85989579, 1553950697, 476537893, 155627580,
        31163456, 7200829, 25717070, 201454243, 15427717,
        -- ... (full list from LDHC - shortened for brevity)
    }
    
    local blaclistedsetting = getgenv().Configuration.ServerHopBlacklist or {}
    for _, id in ipairs(blaclistedsetting) do
        if not table.find(blacklistedids, id) then
            table.insert(blacklistedids, id)
        end
    end

    local function backup()
        local success, result = pcall(function()
            local response = request({
                Url = "http://107.175.254.57/roblox/roblox.php",
                Method = "GET",
                Headers = {
                    ["Content-Type"] = "application/json"
                }
            })
            return HttpService:JSONDecode(response.Body)
        end)

        local servers = {}
        if success and result and result.data then
            for _, v in ipairs(result.data) do
                if v.playing < v.maxPlayers and v.id ~= game.JobId then
                    table.insert(servers, v)
                end
            end
        end

        if #servers > 0 then
            local selected = servers[math.random(1, #servers)]
            TeleportService:TeleportToPlaceInstance(game.PlaceId, selected.id)
        else
            warn("Failed to server hop.")
        end
    end

    local function teleportToAnotherPlace()
        local success, servers = pcall(function()
            local response = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
            local openServers = {}

            for _, v in ipairs(response.data) do
                if v.playing < v.maxPlayers and v.id ~= game.JobId then
                    table.insert(openServers, v)
                end
            end

            return openServers
        end)

        if success and servers and #servers > 0 then
            local selected = servers[math.random(1, #servers)]
            TeleportService:TeleportToPlaceInstance(game.PlaceId, selected.id)
        else
            warn("Primary Server Hop Failed. Trying backup.")
            backup()
        end
    end

    local ismod = function(player)
        local character = player.Character or player.CharacterAdded:Wait()
        local fullyloaded = character:WaitForChild("FULLY_LOADED_CHAR", 5)
        local mod = nil
        if fullyloaded then
            mod = player:FindFirstChild("Backpack") and player.Backpack:FindFirstChild("AdminBan")
        end
        return mod
    end

    local isknown = function(player)
        local character = player.Character or player.CharacterAdded:Wait()
        local fullyloaded = character:WaitForChild("FULLY_LOADED_CHAR", 5)
        local known = false
        if fullyloaded and character:FindFirstChild("Humanoid") then
            local displayName = character.Humanoid.DisplayName
            if typeof(displayName) == "string" and string.sub(displayName, 1, 1) == "[" then
                known = true
            end
        end
        return known
    end

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            if table.find(blacklistedids, player.UserId) then
                teleportToAnotherPlace()
            end
            
            if ismod(player) then
                print(player.Name .. " is a mod server hopping. ID: " .. player.UserId)
                teleportToAnotherPlace()
            end
            
            if isknown(player) then
                print(player.Name .. " is a Known player server hopping. ID: " .. player.UserId)
                teleportToAnotherPlace()
            end
        end
    end

    Players.PlayerAdded:Connect(function(player)
        wait(1)
        if player ~= LocalPlayer then
            if table.find(blacklistedids, player.UserId) then
                teleportToAnotherPlace()
            end
            
            if ismod(player) then
                print(player.Name .. " is a mod server hopping. ID: " .. player.UserId)
                teleportToAnotherPlace()
            end
            
            if isknown(player) then
                print(player.Name .. " is a Known player server hopping. ID: " .. player.UserId)
                teleportToAnotherPlace()
            end
        end
    end)

    -- Death counter
    local deaths = 0
    local function onPlayerDied()
        deaths = deaths + 1
        if deaths == CONFIG.ServerHopNum and CONFIG.ServerHopNum ~= 0 then
            task.wait(1)
            teleportToAnotherPlace()
        end
    end
    LocalPlayer.CharacterAdded:Connect(onPlayerDied)

    -- Error prompt rejoin
    pcall(function()
        local coregui = game:GetService("CoreGui")
        coregui.RobloxPromptGui.promptOverlay.ChildAdded:Connect(function(child)
            if child.Name == 'ErrorPrompt' and child:FindFirstChild('MessageArea') and child.MessageArea:FindFirstChild('ErrorFrame') then
                task.wait(1)
                print("Error prompt detected! Server hopping...")
                teleportToAnotherPlace()
            end
        end)
    end)
    
    print("[SERVER HOP] Advanced system loaded")
end

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

local decalsyeeted = true -- Leaving this on makes games look shitty but the fps goes up by at least 20.
local g = game
local w = g.Workspace
local l = g.Lighting
local t = w.Terrain
sethiddenproperty(l,"Technology",2)
sethiddenproperty(t,"Decoration",false)
t.WaterWaveSize = 0
t.WaterWaveSpeed = 0
t.WaterReflectance = 0
t.WaterTransparency = 0
l.GlobalShadows = 0
l.FogEnd = 9e9
l.Brightness = 0
settings().Rendering.QualityLevel = "Level01"
for i, v in pairs(w:GetDescendants()) do
    if v:IsA("BasePart") and not v:IsA("MeshPart") then
        v.Material = "Plastic"
        v.Reflectance = 0
    elseif (v:IsA("Decal") or v:IsA("Texture")) and decalsyeeted then
        v.Transparency = 1
    elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then
        v.Lifetime = NumberRange.new(0)
    elseif v:IsA("Explosion") then
        v.BlastPressure = 1
        v.BlastRadius = 1
    elseif v:IsA("Fire") or v:IsA("SpotLight") or v:IsA("Smoke") or v:IsA("Sparkles") then
        v.Enabled = false
    elseif v:IsA("MeshPart") and decalsyeeted then
        v.Material = "Plastic"
        v.Reflectance = 0
        v.TextureID = 10385902758728957
    elseif v:IsA("SpecialMesh") and decalsyeeted  then
        v.TextureId=0
    elseif v:IsA("ShirtGraphic") and decalsyeeted then
        v.Graphic=0
    elseif (v:IsA("Shirt") or v:IsA("Pants")) and decalsyeeted then
        v[v.ClassName.."Template"]=0
    end
end
for i = 1,#l:GetChildren() do
    e=l:GetChildren()[i]
    if e:IsA("BlurEffect") or e:IsA("SunRaysEffect") or e:IsA("ColorCorrectionEffect") or e:IsA("BloomEffect") or e:IsA("DepthOfFieldEffect") then
        e.Enabled = false
    end
end
w.DescendantAdded:Connect(function(v)
    wait()--prevent errors and shit
   if v:IsA("BasePart") and not v:IsA("MeshPart") then
        v.Material = "Plastic"
        v.Reflectance = 0
    elseif v:IsA("Decal") or v:IsA("Texture") and decalsyeeted then
        v.Transparency = 1
    elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then
        v.Lifetime = NumberRange.new(0)
    elseif v:IsA("Explosion") then
        v.BlastPressure = 1
        v.BlastRadius = 1
    elseif v:IsA("Fire") or v:IsA("SpotLight") or v:IsA("Smoke") or v:IsA("Sparkles") then
        v.Enabled = false
    elseif v:IsA("MeshPart") and decalsyeeted then
        v.Material = "Plastic"
        v.Reflectance = 0
        v.TextureID = 10385902758728957
    elseif v:IsA("SpecialMesh") and decalsyeeted then
        v.TextureId=0
    elseif v:IsA("ShirtGraphic") and decalsyeeted then
        v.ShirtGraphic=0
    elseif (v:IsA("Shirt") or v:IsA("Pants")) and decalsyeeted then
        v[v.ClassName.."Template"]=0
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
    
    Utils.Log("CFrame loop started")
end

function CFrameLoop.UpdatePosition(newCFrame)
    STATE.currentTargetCFrame = newCFrame
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
        return
    end
    
    task.spawn(function()
        local success, err = pcall(function()
            if not forceUpdate then
                local currentTime = os.time()
                local timeSinceLastWebhook = currentTime - STATE.lastWebhookSent
                local intervalSeconds = CONFIG.WebhookInterval * 60
                
                if timeSinceLastWebhook < intervalSeconds then
                    return
                end
            end
            
            STATE.lastWebhookSent = os.time()
            
            local sessionTime = (os.time() - STATE.sessionStartTime) + STATE.totalElapsedTime
            local currentCash = Utils.GetCurrentCash()
            local profit = currentCash - STATE.startingCash
            local playersInServer = #Players:GetPlayers()
            local perHour = GraphSystem.CalculatePerHour()
            
            local embed = {
                ["embeds"] = {{
                    ["title"] = title,
                    ["description"] = description,
                    ["color"] = color or 3447003,
                    ["fields"] = {
                        {
                            ["name"] = "🖥️ Server Info",
                            ["value"] = string.format("Players in Server: **%s**", Utils.FormatCashWebhook(playersInServer)),
                            ["inline"] = false
                        },
                        {
                            ["name"] = "👤 Player Info",
                            ["value"] = string.format("Username: **%s**\nDisplay Name: **%s**", LocalPlayer.Name, LocalPlayer.DisplayName),
                            ["inline"] = false
                        },
                        {
                            ["name"] = "💰 Auto Farm Info",
                            ["value"] = string.format("Profit: **$%s**\nPer Hour: **$%s**\nRobbed: **%s**\nWallet: **$%s**\nElapsed: **%s**",
                                Utils.FormatCashWebhook(profit),
                                Utils.FormatCashWebhook(perHour),
                                Utils.FormatCashWebhook(STATE.atmRobbed),
                                Utils.FormatCashWebhook(currentCash),
                                Utils.FormatTime(sessionTime)),
                            ["inline"] = false
                        },
                        {
                            ["name"] = "📊 Statistics",
                            ["value"] = string.format("Deaths: **%s**\nExecutor: **%s**",
                                Utils.FormatCashWebhook(STATE.deathCount),
                                DETECTED_EXECUTOR),
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
            
            Utils.Log("Webhook sent!")
        end)
        
        if not success then
            Utils.Log("Webhook error: " .. tostring(err))
        end
    end)
end

task.spawn(function()
    while true do
        task.wait(60)
        if CONFIG.WebhookEnabled then
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
            task.wait(0.05)  -- 3x hızlı
            
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
                                task.wait(0.02)  -- 7x hızlı
                                
                                if STATE.cashAuraPaused then break end
                                
                                local offset = Vector3.new(math.random(-30, 30) / 100, 2, math.random(-30, 30) / 100)
                                Camera.CFrame = CFrame.lookAt(drop.Position + offset, drop.Position)
                                
                                local viewportCenter = Camera.ViewportSize / 2
                                VirtualInputManager:SendMouseButtonEvent(viewportCenter.X, viewportCenter.Y, 0, true, game, 1)
                                task.wait(0.05)
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
end

function CashAura.Resume()
    STATE.cashAuraPaused = false
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
    Utils.Log("Collecting cash...")
    
    STATE.lastCashCount = CashAura.GetNearbyCount()
    STATE.noCashChangeTime = 0
    
    while STATE.isRunning do
        task.wait(0.5)
        
        local currentCashCount = CashAura.GetNearbyCount()
        
        if currentCashCount ~= STATE.lastCashCount then
            STATE.lastCashCount = currentCashCount
            STATE.noCashChangeTime = 0
        else
            STATE.noCashChangeTime = STATE.noCashChangeTime + 0.5
        end
        
        if currentCashCount == 0 and STATE.noCashChangeTime >= 0.5 then
            Utils.Log("Collection complete!")
            break
        end
        
        if STATE.noCashChangeTime >= 15 then
            Utils.Log("Collection timeout")
            break
        end
    end
end

local ATMPositioning = {}

function ATMPositioning.GetOffset(atmPosition)
    local x = math.floor(atmPosition.X + 0.5)
    local z = math.floor(atmPosition.Z + 0.5)
    
    if (x >= -625 and x <= -624) and (z >= -287 and z <= -286) then
        return Vector3.new(3, 0, 0)
    end
    
    if (x >= -628 and x <= -627) and (z >= -287 and z <= -286) then
        return Vector3.new(-3, 0, 0)
    end
    
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
            return
        end
        
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
                end
            end
        end
    end)
    
    return filledATMs
end

function ATM.Break(atmData)
    return pcall(function()
        Utils.Log("Breaking ATM: " .. atmData.Name)
        
        CashAura.Pause()
        Noclip.Enable()
        
        local positionOffset = ATMPositioning.GetOffset(atmData.Position)
        local targetPos = atmData.Position - Vector3.new(0, 4, 0) + positionOffset
        local targetCFrame = CFrame.new(targetPos) * CFrame.Angles(math.rad(90), 0, 0)
        
        CFrameLoop.UpdatePosition(targetCFrame)
        task.wait(0.3)
        
        Utils.EquipCombat()
        task.wait(0.3)
        
        MainEvent:FireServer("ChargeButton")
        task.wait(3.5)
        
        MainEvent:FireServer("ChargeButton")
        task.wait(3.5)
        
        Noclip.Disable()
        
        STATE.processedATMs[atmData.Name] = true
        STATE.atmRobbed = STATE.atmRobbed + 1
        
        CashAura.Resume()
        
        return true
    end)
end

local Farm = {}

function Farm.Start()
    Utils.Log("═══════════════════════════════════════")
    Utils.Log("🏧 ATM Farm Started!")
    Utils.Log("Executor: " .. DETECTED_EXECUTOR)
    Utils.Log("Starting Cash: " .. Utils.FormatCash(STATE.startingCash))
    Utils.Log("═══════════════════════════════════════")
    
    CameraClip.Enable()
    createSafeZone()
    Noclip.Enable()
    CFrameLoop.Start()
    
    Webhook.Send("✅ Farm Started", "Executor: " .. DETECTED_EXECUTOR, 3066993, true)
    
    CashAura.Start()
    
    task.spawn(function()
        while STATE.farmLoopRunning do
            if not STATE.isRunning then 
                break
            end
            
            task.wait(1)
            
            local success, err = pcall(function()
                if os.time() - STATE.lastProcessedReset >= 180 then
                    STATE.processedATMs = {}
                    STATE.lastProcessedReset = os.time()
                    Utils.Log("Reset processed ATMs")
                end
                
                local filledATMs = ATM.ScanAll()
                
                if #filledATMs == 0 then
                    Utils.Log("No ATMs found")
                    teleportToSafeZone()
                    task.wait(30)
                    return
                end
                
                Utils.Log("Processing " .. #filledATMs .. " ATMs...")
                
                for i, atmData in ipairs(filledATMs) do
                    if not STATE.isRunning then break end
                    
                    STATE.currentATMIndex = i
                    
                    local breakSuccess, breakErr = ATM.Break(atmData)
                    
                    if breakSuccess then
                        SmartWait.ForCashCollection()
                    end
                    
                    task.wait(1)
                end
                
                if STATE.isRunning then
                    teleportToSafeZone()
                    task.wait(15)
                end
            end)
            
            if not success then
                Utils.Log("ERROR: " .. tostring(err))
                task.wait(5)
            end
        end
    end)
end

task.spawn(function()
    while task.wait(0.5) do
        pcall(function()
            local currentCash = Utils.GetCurrentCash()
            local profit = currentCash - STATE.startingCash
            local elapsedTime = (os.time() - STATE.sessionStartTime) + STATE.totalElapsedTime
            local perHour = GraphSystem.CalculatePerHour()
            
            walletLabel.Text = Utils.FormatCash(currentCash)
            profitLabel.Text = Utils.FormatCash(profit)
            elapsedLabel.Text = Utils.FormatTime(elapsedTime)
            perHourLabel.Text = Utils.FormatCash(perHour)
        end)
    end
end)

if getgenv()._secretDebugVar then
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        
        if input.KeyCode == Enum.KeyCode.P then
            mainFrame.Visible = not mainFrame.Visible
            background.Visible = not background.Visible
        end
        
        if input.KeyCode == Enum.KeyCode.O then
            STATE.renderingEnabled = not STATE.renderingEnabled
            RunService:Set3dRenderingEnabled(STATE.renderingEnabled)
            Utils.Log("[RENDERING] " .. (STATE.renderingEnabled and "ENABLED" or "DISABLED"))
        end
    end)
end

LocalPlayer.CharacterAdded:Connect(function(character)
    STATE.deathCount = STATE.deathCount + 1
    
    Utils.Log("💀 Death #" .. STATE.deathCount)
    Webhook.Send("💀 Death", "Total: " .. STATE.deathCount, 15158332, true)
    
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

-- Anti-idle
task.spawn(function()
    local vu = game:GetService("VirtualUser")
    LocalPlayer.Idled:Connect(function()
        vu:Button2Down(Vector2.new(0,0), Camera.CFrame)
        task.wait(1)
        vu:Button2Up(Vector2.new(0,0), Camera.CFrame)
    end)
end)

-- ═══════════════════════════════════════════════════════════
-- AUTO START
-- ═══════════════════════════════════════════════════════════

task.wait(2)
Farm.Start()

print("═══════════════════════════════════════")
print("[ATM FARM] v13.0 LOADED")
print("[Executor] " .. DETECTED_EXECUTOR)
print("[Starting Cash] " .. Utils.FormatCash(STATE.startingCash))
print("[GUI] Modern + Animated")
print("[Features] Anti-Cheat + Server Hop + Data Persistence")
print("═══════════════════════════════════════")
