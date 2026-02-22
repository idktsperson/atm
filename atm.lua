local plrr = game.Players.LocalPlayer

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
                        if type(args[1][1]) == "RysifyAtmData" then
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


local function otherBypass()
    pcall(function()
        local gm = getrawmetatable(game)
        setreadonly(gm, false)
        local namecall = gm.__namecall
        gm.__namecall = newcclosure(function(self, ...)
            local args = {...}
            if not checkcaller() and getnamecallmethod() == "FireServer" and tostring(self) == "MainEvent" then
                if tostring(getcallingscript()) ~= "Framework" then
                    return
                end
            end
            if not checkcaller() and getnamecallmethod() == "Kick" then
                return
            end
            return namecall(self, unpack(args))
        end)
    end)
end

getgenv().Configuration = getgenv().Configuration or {
    ["Misc"] = {
        ["FightingStyle"] = "Default", -- For best results, set this to "Boxing" (highly recommended) Options: "Default", "Boxing"
    },

    ["ServerHop"] = {
        ["Enabled"] = false, -- Turn this on first if you want any of the options below to actually work
        ["Death"] = 5, -- Automatically switches servers after you die 5 times
        ["FarmerDetector"] = true, -- Switches servers if another farmer is detected in the same server
        ["NoATM"] = true, -- Switches servers if there are no ATMs left to farm
        ["NoATMDelay"] = 10, -- How many seconds to wait before server hopping if no ATMs are found.
        --If you're using "Default" fighting style, 10 seconds is recommended.
        --If you're using "Boxing", setting this to 1 is strongly recommended for maximum efficiency.
    },

    ["Webhook"] = {
        ["Enabled"] = false, -- Enable this if you want webhook notifications to be sent
        ["Url"] = "", -- Paste your Discord webhook URL here
        ["Interval"] = 10, -- How often it sends updates (in minutes)
    },

    ["Fps"] = 15, -- FPS cap. 10–20 is recommended
}

local CONFIG = getgenv().Configuration

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


local function validateConfiguration()
    local config = getgenv().Configuration
    
    if config.Misc.FightingStyle ~= "Default" and config.Misc.FightingStyle ~= "Boxing" then
        plrr:Kick("Invalid FightingStyle. Must be 'Default' or 'Boxing'")
        return false
    end
    
    if config.Webhook.Enabled then
        if config.Webhook.Url == "" or config.Webhook.Url == nil then
            plrr:Kick("Webhook Enabled but URL is empty!")
            return false
        end
        
        if not string.find(config.Webhook.Url, "discord.com/api/webhooks") then
            plrr:Kick("Invalid Webhook URL format!")
            return false
        end
    end
    
    if config.ServerHop.NoATMDelay < 1 or config.ServerHop.NoATMDelay > 60 then
        plrr:Kick("Invalid NoATMDelay. Must be between 1-60 seconds")
        return false
    end
    
    return true
end

if not validateConfiguration() then
    return
end

getgenv()._secretDebugVar = getgenv()._secretDebugVar or false
getgenv()._secretGuiVar = getgenv()._secretGuiVar or false

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
local StarterGui = game:GetService("StarterGui")

local LocalPlayer = Players.LocalPlayer
local MainEvent = ReplicatedStorage:WaitForChild("MainEvent", 10)

repeat task.wait(0.1) until game:IsLoaded() and LocalPlayer

if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("FULLY_LOADED_CHAR") then 
    repeat task.wait(0.5) until LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("FULLY_LOADED_CHAR")
    task.wait(1)
end

local Camera = Workspace.CurrentCamera

local function saveRysifyAtmData(userid, walletValue, profitValue, elapsedTime, timestamp, atmRobbed)
    local userFolder = "RysifyAtmData/"..userid
    if not isfolder("RysifyAtmData") then makefolder("RysifyAtmData") end
    if not isfolder(userFolder) then makefolder(userFolder) end

    local data = string.format("%s,%s,%s,%s", walletValue, profitValue, elapsedTime, atmRobbed)
    writefile(userFolder.."/data.txt", data)
    writefile(userFolder.."/timestamp.txt", tostring(timestamp))
end

local function loadRysifyAtmData(userid)
    local userFolder = "RysifyAtmData/"..userid
    if not isfolder(userFolder) then return nil end
    if not isfile(userFolder.."/data.txt") or not isfile(userFolder.."/timestamp.txt") then return nil end

    local lastSave = tonumber(readfile(userFolder.."/timestamp.txt"))
    if not lastSave or (tick() - lastSave > 180) then return nil end

    local data = readfile(userFolder.."/data.txt")
    local wallet, profit, elapsed, robbed = string.match(data, "([^,]+),([^,]+),([^,]+),([^,]+)")
    return tonumber(wallet), tonumber(profit), tonumber(elapsed), tonumber(robbed) or 0
end

StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, false)

local G2L = {};

G2L["1"] = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"));
G2L["1"]["IgnoreGuiInset"] = true;
G2L["1"]["ScreenInsets"] = Enum.ScreenInsets.DeviceSafeInsets;
G2L["1"]["Name"] = [[AutoFarm]];
G2L["1"]["ZIndexBehavior"] = Enum.ZIndexBehavior.Sibling;
G2L["1"]["DisplayOrder"] = 999999999;
G2L["1"]["ResetOnSpawn"] = false;

G2L["3"] = Instance.new("Frame", G2L["1"]);
G2L["3"]["ZIndex"] = 2;
G2L["3"]["BorderSizePixel"] = 0;
G2L["3"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["3"]["AnchorPoint"] = Vector2.new(0.5, 0.5);
G2L["3"]["Size"] = UDim2.new(0.5235, 0, 0.7494, 0);
G2L["3"]["Position"] = UDim2.new(0.49732, 0, 0.50597, 0);
G2L["3"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
G2L["3"]["Name"] = [[MainFrame]];

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
G2L["7"]["Color"] = ColorSequence.new{ColorSequenceKeypoint.new(0.000, Color3.fromRGB(0, 103, 0)),ColorSequenceKeypoint.new(1.000, Color3.fromRGB(0, 255, 0))};

G2L["8"] = Instance.new("UITextSizeConstraint", G2L["5"]);
G2L["8"]["MaxTextSize"] = 49;

G2L["9"] = Instance.new("UIAspectRatioConstraint", G2L["5"]);
G2L["9"]["AspectRatio"] = 6.46321;

G2L["a"] = Instance.new("Frame", G2L["3"]);
G2L["a"]["BorderSizePixel"] = 0;
G2L["a"]["BackgroundColor3"] = Color3.fromRGB(31, 31, 31);
G2L["a"]["Size"] = UDim2.new(0.47045, 0, 0.19745, 0);
G2L["a"]["Position"] = UDim2.new(0.02159, 0, 0.18949, 0);
G2L["a"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
G2L["a"]["Name"] = [[UsernameFrame]];

G2L["b"] = Instance.new("UICorner", G2L["a"]);
G2L["b"]["CornerRadius"] = UDim.new(0, 16);

G2L["c"] = Instance.new("UIStroke", G2L["a"]);
G2L["c"]["Color"] = Color3.fromRGB(94, 94, 94);

G2L["d"] = Instance.new("TextLabel", G2L["a"]);
G2L["d"]["TextWrapped"] = true;
G2L["d"]["TextStrokeTransparency"] = 0;
G2L["d"]["ZIndex"] = 10;
G2L["d"]["BorderSizePixel"] = 0;
G2L["d"]["TextSize"] = 14;
G2L["d"]["TextXAlignment"] = Enum.TextXAlignment.Left;
G2L["d"]["TextStrokeColor3"] = Color3.fromRGB(94, 94, 94);
G2L["d"]["TextScaled"] = true;
G2L["d"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["d"]["FontFace"] = Font.new([[rbxasset://fonts/families/FredokaOne.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["d"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
G2L["d"]["BackgroundTransparency"] = 1;
G2L["d"]["Size"] = UDim2.new(0.8744, 0, 0.25, 0);
G2L["d"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
G2L["d"]["Text"] = LocalPlayer.Name;
G2L["d"]["Name"] = [[Username]];
G2L["d"]["Position"] = UDim2.new(0.03382, 0, 0.57258, 0);

G2L["e"] = Instance.new("UIGradient", G2L["d"]);
G2L["e"]["Rotation"] = -90;
G2L["e"]["Color"] = ColorSequence.new{ColorSequenceKeypoint.new(0.000, Color3.fromRGB(0, 103, 0)),ColorSequenceKeypoint.new(1.000, Color3.fromRGB(0, 255, 0))};

G2L["f"] = Instance.new("UIAspectRatioConstraint", G2L["d"]);
G2L["f"]["AspectRatio"] = 11.67742;

G2L["10"] = Instance.new("UITextSizeConstraint", G2L["d"]);
G2L["10"]["MaxTextSize"] = 31;

G2L["11"] = Instance.new("TextLabel", G2L["a"]);
G2L["11"]["TextWrapped"] = true;
G2L["11"]["TextStrokeTransparency"] = 0;
G2L["11"]["ZIndex"] = 10;
G2L["11"]["BorderSizePixel"] = 0;
G2L["11"]["TextSize"] = 14;
G2L["11"]["TextXAlignment"] = Enum.TextXAlignment.Left;
G2L["11"]["TextScaled"] = true;
G2L["11"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["11"]["FontFace"] = Font.new([[rbxasset://fonts/families/TitilliumWeb.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["11"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
G2L["11"]["BackgroundTransparency"] = 1;
G2L["11"]["Size"] = UDim2.new(0.71256, 0, 0.46774, 0);
G2L["11"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
G2L["11"]["Text"] = [[Username]];
G2L["11"]["Name"] = [[Title]];
G2L["11"]["Position"] = UDim2.new(0.02899, 0, 0.03226, 0);

G2L["12"] = Instance.new("UIAspectRatioConstraint", G2L["11"]);
G2L["12"]["AspectRatio"] = 5.08621;

G2L["13"] = Instance.new("UITextSizeConstraint", G2L["11"]);
G2L["13"]["MaxTextSize"] = 58;

G2L["14"] = Instance.new("UIAspectRatioConstraint", G2L["a"]);
G2L["14"]["AspectRatio"] = 3.33871;

G2L["15"] = Instance.new("TextLabel", G2L["3"]);
G2L["15"]["TextWrapped"] = true;
G2L["15"]["ZIndex"] = 10;
G2L["15"]["BorderSizePixel"] = 0;
G2L["15"]["TextSize"] = 14;
G2L["15"]["TextXAlignment"] = Enum.TextXAlignment.Left;
G2L["15"]["TextScaled"] = true;
G2L["15"]["BackgroundColor3"] = Color3.fromRGB(114, 114, 114);
G2L["15"]["FontFace"] = Font.new([[rbxasset://fonts/families/Nunito.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["15"]["TextColor3"] = Color3.fromRGB(191, 191, 191);
G2L["15"]["BackgroundTransparency"] = 1;
G2L["15"]["Size"] = UDim2.new(0.46003, 0, 0.03221, 0);
G2L["15"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
G2L["15"]["Text"] = [[discord.gg/aTb4K8Euta]];
G2L["15"]["Name"] = [[Title2]];
G2L["15"]["Position"] = UDim2.new(0.02632, 0, 0.11987, 0);

G2L["16"] = Instance.new("UITextSizeConstraint", G2L["15"]);
G2L["16"]["MaxTextSize"] = 18;

G2L["17"] = Instance.new("UIAspectRatioConstraint", G2L["15"]);
G2L["17"]["AspectRatio"] = 20.01554;

G2L["18"] = Instance.new("Frame", G2L["3"]);
G2L["18"]["BorderSizePixel"] = 0;
G2L["18"]["BackgroundColor3"] = Color3.fromRGB(31, 31, 31);
G2L["18"]["Size"] = UDim2.new(0.47045, 0, 0.19745, 0);
G2L["18"]["Position"] = UDim2.new(0.02159, 0, 0.40446, 0);
G2L["18"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
G2L["18"]["Name"] = [[CashFrame]];

G2L["19"] = Instance.new("TextLabel", G2L["18"]);
G2L["19"]["TextWrapped"] = true;
G2L["19"]["TextStrokeTransparency"] = 0;
G2L["19"]["ZIndex"] = 10;
G2L["19"]["BorderSizePixel"] = 0;
G2L["19"]["TextSize"] = 14;
G2L["19"]["TextXAlignment"] = Enum.TextXAlignment.Left;
G2L["19"]["TextStrokeColor3"] = Color3.fromRGB(94, 94, 94);
G2L["19"]["TextScaled"] = true;
G2L["19"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["19"]["FontFace"] = Font.new([[rbxasset://fonts/families/FredokaOne.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["19"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
G2L["19"]["BackgroundTransparency"] = 1;
G2L["19"]["Size"] = UDim2.new(0.91304, 0, 0.25, 0);
G2L["19"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
G2L["19"]["Text"] = [[$0]];
G2L["19"]["Name"] = [[Wallet]];
G2L["19"]["Position"] = UDim2.new(0.01449, 0, 0.57258, 0);

G2L["1a"] = Instance.new("UIGradient", G2L["19"]);
G2L["1a"]["Rotation"] = -90;
G2L["1a"]["Color"] = ColorSequence.new{ColorSequenceKeypoint.new(0.000, Color3.fromRGB(0, 103, 0)),ColorSequenceKeypoint.new(1.000, Color3.fromRGB(0, 255, 0))};

G2L["1b"] = Instance.new("UIAspectRatioConstraint", G2L["19"]);
G2L["1b"]["AspectRatio"] = 12.19355;

G2L["1c"] = Instance.new("UITextSizeConstraint", G2L["19"]);
G2L["1c"]["MaxTextSize"] = 31;

G2L["1d"] = Instance.new("UIStroke", G2L["18"]);
G2L["1d"]["Color"] = Color3.fromRGB(94, 94, 94);

G2L["1e"] = Instance.new("UICorner", G2L["18"]);
G2L["1e"]["CornerRadius"] = UDim.new(0, 16);

G2L["1f"] = Instance.new("TextLabel", G2L["18"]);
G2L["1f"]["TextWrapped"] = true;
G2L["1f"]["TextStrokeTransparency"] = 0;
G2L["1f"]["ZIndex"] = 10;
G2L["1f"]["BorderSizePixel"] = 0;
G2L["1f"]["TextSize"] = 14;
G2L["1f"]["TextXAlignment"] = Enum.TextXAlignment.Left;
G2L["1f"]["TextScaled"] = true;
G2L["1f"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["1f"]["FontFace"] = Font.new([[rbxasset://fonts/families/TitilliumWeb.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["1f"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
G2L["1f"]["BackgroundTransparency"] = 1;
G2L["1f"]["Size"] = UDim2.new(0.37681, 0, 0.5, 0);
G2L["1f"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
G2L["1f"]["Text"] = [[Wallet]];
G2L["1f"]["Name"] = [[Title]];
G2L["1f"]["Position"] = UDim2.new(0.01691, 0, 0.00806, 0);

G2L["20"] = Instance.new("UIAspectRatioConstraint", G2L["1f"]);
G2L["20"]["AspectRatio"] = 2.51613;

G2L["21"] = Instance.new("UITextSizeConstraint", G2L["1f"]);
G2L["21"]["MaxTextSize"] = 62;

G2L["22"] = Instance.new("UIAspectRatioConstraint", G2L["18"]);
G2L["22"]["AspectRatio"] = 3.33871;

G2L["23"] = Instance.new("Frame", G2L["3"]);
G2L["23"]["BorderSizePixel"] = 0;
G2L["23"]["BackgroundColor3"] = Color3.fromRGB(31, 31, 31);
G2L["23"]["Size"] = UDim2.new(0.47045, 0, 0.19745, 0);
G2L["23"]["Position"] = UDim2.new(0.50568, 0, 0.18949, 0);
G2L["23"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
G2L["23"]["Name"] = [[ElapsedFrame]];

G2L["24"] = Instance.new("UICorner", G2L["23"]);
G2L["24"]["CornerRadius"] = UDim.new(0, 16);

G2L["25"] = Instance.new("UIStroke", G2L["23"]);
G2L["25"]["Color"] = Color3.fromRGB(94, 94, 94);

G2L["26"] = Instance.new("TextLabel", G2L["23"]);
G2L["26"]["TextWrapped"] = true;
G2L["26"]["TextStrokeTransparency"] = 0;
G2L["26"]["ZIndex"] = 10;
G2L["26"]["BorderSizePixel"] = 0;
G2L["26"]["TextSize"] = 14;
G2L["26"]["TextXAlignment"] = Enum.TextXAlignment.Left;
G2L["26"]["TextScaled"] = true;
G2L["26"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["26"]["FontFace"] = Font.new([[rbxasset://fonts/families/TitilliumWeb.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["26"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
G2L["26"]["BackgroundTransparency"] = 1;
G2L["26"]["Size"] = UDim2.new(0.39855, 0, 0.47581, 0);
G2L["26"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
G2L["26"]["Text"] = [[Elapsed]];
G2L["26"]["Name"] = [[Title]];
G2L["26"]["Position"] = UDim2.new(0.03382, 0, 0.02419, 0);

G2L["27"] = Instance.new("UIAspectRatioConstraint", G2L["26"]);
G2L["27"]["AspectRatio"] = 2.79661;

G2L["28"] = Instance.new("UITextSizeConstraint", G2L["26"]);
G2L["28"]["MaxTextSize"] = 59;

G2L["29"] = Instance.new("TextLabel", G2L["23"]);
G2L["29"]["TextWrapped"] = true;
G2L["29"]["TextStrokeTransparency"] = 0;
G2L["29"]["ZIndex"] = 10;
G2L["29"]["BorderSizePixel"] = 0;
G2L["29"]["TextSize"] = 14;
G2L["29"]["TextXAlignment"] = Enum.TextXAlignment.Left;
G2L["29"]["TextStrokeColor3"] = Color3.fromRGB(94, 94, 94);
G2L["29"]["TextScaled"] = true;
G2L["29"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["29"]["FontFace"] = Font.new([[rbxasset://fonts/families/FredokaOne.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["29"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
G2L["29"]["BackgroundTransparency"] = 1;
G2L["29"]["Size"] = UDim2.new(0.89614, 0, 0.24194, 0);
G2L["29"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
G2L["29"]["Text"] = [[0h 0m 0s]];
G2L["29"]["Name"] = [[Elapsed]];
G2L["29"]["Position"] = UDim2.new(0.03382, 0, 0.58065, 0);

G2L["2a"] = Instance.new("UIGradient", G2L["29"]);
G2L["2a"]["Rotation"] = -90;
G2L["2a"]["Color"] = ColorSequence.new{ColorSequenceKeypoint.new(0.000, Color3.fromRGB(0, 103, 0)),ColorSequenceKeypoint.new(1.000, Color3.fromRGB(0, 255, 0))};

G2L["2b"] = Instance.new("UIAspectRatioConstraint", G2L["29"]);
G2L["2b"]["AspectRatio"] = 12.36667;

G2L["2c"] = Instance.new("UITextSizeConstraint", G2L["29"]);
G2L["2c"]["MaxTextSize"] = 30;

G2L["2d"] = Instance.new("UIAspectRatioConstraint", G2L["23"]);
G2L["2d"]["AspectRatio"] = 3.33871;

G2L["2e"] = Instance.new("ImageLabel", G2L["3"]);
G2L["2e"]["BorderSizePixel"] = 0;
G2L["2e"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["2e"]["AnchorPoint"] = Vector2.new(0.5, 0.5);
G2L["2e"]["Image"] = [[rbxasset://textures/ui/GuiImagePlaceholder.png]];
G2L["2e"]["Size"] = UDim2.new(0.08165, 0, 0.09586, 0);
G2L["2e"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
G2L["2e"]["BackgroundTransparency"] = 1;
G2L["2e"]["Position"] = UDim2.new(0.94328, 0, 0.07194, 0);

G2L["30"] = Instance.new("UICorner", G2L["2e"]);
G2L["30"]["CornerRadius"] = UDim.new(1, 0);

G2L["31"] = Instance.new("UIAspectRatioConstraint", G2L["2e"]);
G2L["31"]["AspectRatio"] = 0.97;

G2L["32"] = Instance.new("UIGradient", G2L["3"]);
G2L["32"]["Rotation"] = -44;
G2L["32"]["Offset"] = Vector2.new(0.2, 0);
G2L["32"]["Color"] = ColorSequence.new{ColorSequenceKeypoint.new(0.000, Color3.fromRGB(14, 14, 14)),ColorSequenceKeypoint.new(1.000, Color3.fromRGB(18, 18, 18))};

G2L["33"] = Instance.new("Frame", G2L["3"]);
G2L["33"]["BorderSizePixel"] = 0;
G2L["33"]["BackgroundColor3"] = Color3.fromRGB(31, 31, 31);
G2L["33"]["Size"] = UDim2.new(0.47045, 0, 0.19745, 0);
G2L["33"]["Position"] = UDim2.new(0.02159, 0, 0.62102, 0);
G2L["33"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
G2L["33"]["Name"] = [[ProfitFrame]];

G2L["34"] = Instance.new("UICorner", G2L["33"]);
G2L["34"]["CornerRadius"] = UDim.new(0, 16);

G2L["35"] = Instance.new("UIStroke", G2L["33"]);
G2L["35"]["Color"] = Color3.fromRGB(94, 94, 94);

G2L["36"] = Instance.new("TextLabel", G2L["33"]);
G2L["36"]["TextWrapped"] = true;
G2L["36"]["TextStrokeTransparency"] = 0;
G2L["36"]["ZIndex"] = 10;
G2L["36"]["BorderSizePixel"] = 0;
G2L["36"]["TextSize"] = 14;
G2L["36"]["TextXAlignment"] = Enum.TextXAlignment.Left;
G2L["36"]["TextStrokeColor3"] = Color3.fromRGB(94, 94, 94);
G2L["36"]["TextScaled"] = true;
G2L["36"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["36"]["FontFace"] = Font.new([[rbxasset://fonts/families/FredokaOne.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["36"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
G2L["36"]["BackgroundTransparency"] = 1;
G2L["36"]["Size"] = UDim2.new(0.91304, 0, 0.25, 0);
G2L["36"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
G2L["36"]["Text"] = [[$0]];
G2L["36"]["Name"] = [[Profit]];
G2L["36"]["Position"] = UDim2.new(0.01449, 0, 0.57258, 0);

G2L["37"] = Instance.new("UIGradient", G2L["36"]);
G2L["37"]["Rotation"] = -90;
G2L["37"]["Color"] = ColorSequence.new{ColorSequenceKeypoint.new(0.000, Color3.fromRGB(0, 103, 0)),ColorSequenceKeypoint.new(1.000, Color3.fromRGB(0, 255, 0))};

G2L["38"] = Instance.new("UIAspectRatioConstraint", G2L["36"]);
G2L["38"]["AspectRatio"] = 12.19355;

G2L["39"] = Instance.new("UITextSizeConstraint", G2L["36"]);
G2L["39"]["MaxTextSize"] = 31;

G2L["3a"] = Instance.new("TextLabel", G2L["33"]);
G2L["3a"]["TextWrapped"] = true;
G2L["3a"]["TextStrokeTransparency"] = 0;
G2L["3a"]["ZIndex"] = 10;
G2L["3a"]["BorderSizePixel"] = 0;
G2L["3a"]["TextSize"] = 14;
G2L["3a"]["TextXAlignment"] = Enum.TextXAlignment.Left;
G2L["3a"]["TextScaled"] = true;
G2L["3a"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["3a"]["FontFace"] = Font.new([[rbxasset://fonts/families/TitilliumWeb.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["3a"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
G2L["3a"]["BackgroundTransparency"] = 1;
G2L["3a"]["Size"] = UDim2.new(0.33909, 0, 0.5, 0);
G2L["3a"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
G2L["3a"]["Text"] = [[Profit]];
G2L["3a"]["Name"] = [[Title]];
G2L["3a"]["Position"] = UDim2.new(0.01691, 0, 0, 0);

G2L["3b"] = Instance.new("UIAspectRatioConstraint", G2L["3a"]);
G2L["3b"]["AspectRatio"] = 2.26423;

G2L["3c"] = Instance.new("UITextSizeConstraint", G2L["3a"]);
G2L["3c"]["MaxTextSize"] = 62;

G2L["3d"] = Instance.new("UIAspectRatioConstraint", G2L["33"]);
G2L["3d"]["AspectRatio"] = 3.33871;

G2L["3e"] = Instance.new("UIStroke", G2L["3"]);
G2L["3e"]["Thickness"] = 5.5;
G2L["3e"]["Color"] = Color3.fromRGB(166, 166, 166);

G2L["3f"] = Instance.new("UIGradient", G2L["3e"]);
G2L["3f"]["Rotation"] = -90;
G2L["3f"]["Color"] = ColorSequence.new{ColorSequenceKeypoint.new(0.000, Color3.fromRGB(0, 0, 0)),ColorSequenceKeypoint.new(0.346, Color3.fromRGB(0, 0, 0)),ColorSequenceKeypoint.new(0.606, Color3.fromRGB(0, 103, 0)),ColorSequenceKeypoint.new(1.000, Color3.fromRGB(0, 255, 0))};

G2L["40"] = Instance.new("Frame", G2L["3"]);
G2L["40"]["BorderSizePixel"] = 0;
G2L["40"]["BackgroundColor3"] = Color3.fromRGB(31, 31, 31);
G2L["40"]["Size"] = UDim2.new(0.47159, 0, 0.41242, 0);
G2L["40"]["Position"] = UDim2.new(0.50568, 0, 0.40446, 0);
G2L["40"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
G2L["40"]["Name"] = [[PerHourFrame]];

G2L["41"] = Instance.new("UICorner", G2L["40"]);
G2L["41"]["CornerRadius"] = UDim.new(0, 16);

G2L["42"] = Instance.new("UIStroke", G2L["40"]);
G2L["42"]["Color"] = Color3.fromRGB(94, 94, 94);

G2L["43"] = Instance.new("TextLabel", G2L["40"]);
G2L["43"]["TextWrapped"] = true;
G2L["43"]["TextStrokeTransparency"] = 0;
G2L["43"]["ZIndex"] = 10;
G2L["43"]["BorderSizePixel"] = 0;
G2L["43"]["TextSize"] = 14;
G2L["43"]["TextXAlignment"] = Enum.TextXAlignment.Left;
G2L["43"]["TextStrokeColor3"] = Color3.fromRGB(94, 94, 94);
G2L["43"]["TextScaled"] = true;
G2L["43"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["43"]["FontFace"] = Font.new([[rbxasset://fonts/families/FredokaOne.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["43"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
G2L["43"]["BackgroundTransparency"] = 1;
G2L["43"]["Size"] = UDim2.new(0.34217, 0, 0.40154, 0);
G2L["43"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
G2L["43"]["Text"] = [[$0]];
G2L["43"]["Name"] = [[PerHour]];
G2L["43"]["Position"] = UDim2.new(0.03373, 0, 0.11969, 0);

G2L["44"] = Instance.new("UIGradient", G2L["43"]);
G2L["44"]["Rotation"] = -90;
G2L["44"]["Color"] = ColorSequence.new{ColorSequenceKeypoint.new(0.000, Color3.fromRGB(0, 103, 0)),ColorSequenceKeypoint.new(1.000, Color3.fromRGB(0, 255, 0))};

G2L["45"] = Instance.new("UIAspectRatioConstraint", G2L["43"]);
G2L["45"]["AspectRatio"] = 1.36538;

G2L["46"] = Instance.new("UITextSizeConstraint", G2L["43"]);
G2L["46"]["MaxTextSize"] = 33;

G2L["47"] = Instance.new("TextLabel", G2L["40"]);
G2L["47"]["TextWrapped"] = true;
G2L["47"]["TextStrokeTransparency"] = 0;
G2L["47"]["ZIndex"] = 10;
G2L["47"]["BorderSizePixel"] = 0;
G2L["47"]["TextSize"] = 14;
G2L["47"]["TextXAlignment"] = Enum.TextXAlignment.Left;
G2L["47"]["TextScaled"] = true;
G2L["47"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["47"]["FontFace"] = Font.new([[rbxasset://fonts/families/TitilliumWeb.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["47"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
G2L["47"]["BackgroundTransparency"] = 1;
G2L["47"]["Size"] = UDim2.new(0.35904, 0, 0.32046, 0);
G2L["47"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
G2L["47"]["Text"] = [[Per Hour]];
G2L["47"]["Name"] = [[Title]];
G2L["47"]["Position"] = UDim2.new(0.03373, 0, -0.03861, 0);

G2L["48"] = Instance.new("UIAspectRatioConstraint", G2L["47"]);
G2L["48"]["AspectRatio"] = 1.79518;

G2L["49"] = Instance.new("UITextSizeConstraint", G2L["47"]);
G2L["49"]["MaxTextSize"] = 59;

G2L["4a"] = Instance.new("Frame", G2L["40"]);
G2L["4a"]["ZIndex"] = 15;
G2L["4a"]["BorderSizePixel"] = 0;
G2L["4a"]["BackgroundColor3"] = Color3.fromRGB(16, 21, 19);
G2L["4a"]["Size"] = UDim2.new(1, 0, 0.63324, 0);
G2L["4a"]["Position"] = UDim2.new(-0, 0, 0.36676, 0);
G2L["4a"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
G2L["4a"]["Name"] = [[PerHourGraphFrame]];
G2L["4a"]["BackgroundTransparency"] = 1;

G2L["4c"] = Instance.new("UICorner", G2L["4a"]);

G2L["4d"] = Instance.new("UIAspectRatioConstraint", G2L["4a"]);
G2L["4d"]["AspectRatio"] = 2.53036;

G2L["4e"] = Instance.new("UIAspectRatioConstraint", G2L["40"]);
G2L["4e"]["AspectRatio"] = 1.60232;

G2L["4f"] = Instance.new("Frame", G2L["3"]);
G2L["4f"]["BorderSizePixel"] = 0;
G2L["4f"]["BackgroundColor3"] = Color3.fromRGB(31, 31, 31);
G2L["4f"]["Size"] = UDim2.new(0.95568, 0, 0.13057, 0);
G2L["4f"]["Position"] = UDim2.new(0.02159, 0, 0.83758, 0);
G2L["4f"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
G2L["4f"]["Name"] = [[StatusFrame]];

G2L["50"] = Instance.new("UICorner", G2L["4f"]);
G2L["50"]["CornerRadius"] = UDim.new(0, 16);

G2L["51"] = Instance.new("UIStroke", G2L["4f"]);
G2L["51"]["Color"] = Color3.fromRGB(94, 94, 94);

G2L["52"] = Instance.new("TextLabel", G2L["4f"]);
G2L["52"]["TextWrapped"] = true;
G2L["52"]["TextStrokeTransparency"] = 0;
G2L["52"]["ZIndex"] = 10;
G2L["52"]["BorderSizePixel"] = 0;
G2L["52"]["TextSize"] = 14;
G2L["52"]["TextXAlignment"] = Enum.TextXAlignment.Left;
G2L["52"]["TextScaled"] = true;
G2L["52"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["52"]["FontFace"] = Font.new([[rbxasset://fonts/families/TitilliumWeb.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["52"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
G2L["52"]["BackgroundTransparency"] = 1;
G2L["52"]["Size"] = UDim2.new(0.14605, 0, 0.53404, 0);
G2L["52"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
G2L["52"]["Text"] = [[Status:]];
G2L["52"]["Name"] = [[Title]];
G2L["52"]["Position"] = UDim2.new(0.36504, 0, 0.22841, 0);

G2L["53"] = Instance.new("UIAspectRatioConstraint", G2L["52"]);
G2L["53"]["AspectRatio"] = 2.80488;

G2L["54"] = Instance.new("UITextSizeConstraint", G2L["52"]);
G2L["54"]["MaxTextSize"] = 41;

G2L["55"] = Instance.new("TextLabel", G2L["4f"]);
G2L["55"]["TextWrapped"] = true;
G2L["55"]["TextStrokeTransparency"] = 0;
G2L["55"]["ZIndex"] = 10;
G2L["55"]["BorderSizePixel"] = 0;
G2L["55"]["TextSize"] = 14;
G2L["55"]["TextXAlignment"] = Enum.TextXAlignment.Left;
G2L["55"]["TextScaled"] = true;
G2L["55"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["55"]["FontFace"] = Font.new([[rbxasset://fonts/families/TitilliumWeb.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["55"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
G2L["55"]["BackgroundTransparency"] = 1;
G2L["55"]["Size"] = UDim2.new(0.13938, 0, 0.50965, 0);
G2L["55"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
G2L["55"]["Text"] = [[Running...]];
G2L["55"]["Name"] = [[Title]];
G2L["55"]["Position"] = UDim2.new(0.52319, 0, 0.24061, 0);

G2L["57"] = Instance.new("UIAspectRatioConstraint", G2L["55"]);
G2L["57"]["AspectRatio"] = 2.80488;

G2L["58"] = Instance.new("UITextSizeConstraint", G2L["55"]);
G2L["58"]["MaxTextSize"] = 41;

G2L["59"] = Instance.new("UICorner", G2L["3"]);
G2L["59"]["CornerRadius"] = UDim.new(0, 16);

G2L["5a"] = Instance.new("UIAspectRatioConstraint", G2L["3"]);
G2L["5a"]["AspectRatio"] = 1.40127;

G2L["5b"] = Instance.new("Frame", G2L["3"]);
G2L["5b"]["BorderSizePixel"] = 0;
G2L["5b"]["BackgroundColor3"] = Color3.fromRGB(0, 222, 0);
G2L["5b"]["Size"] = UDim2.new(0.01364, 0, 0.02707, 0);
G2L["5b"]["Position"] = UDim2.new(0.49091, 0, 0.89331, 0);
G2L["5b"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
G2L["5b"]["Name"] = [[SitationColor]];

G2L["5c"] = Instance.new("UICorner", G2L["5b"]);
G2L["5c"]["CornerRadius"] = UDim.new(1, 0);

G2L["5d"] = Instance.new("UIAspectRatioConstraint", G2L["5b"]);

G2L["5e"] = Instance.new("Frame", G2L["1"]);
G2L["5e"]["BorderSizePixel"] = 0;
G2L["5e"]["BackgroundColor3"] = Color3.fromRGB(0, 0, 0);
G2L["5e"]["Size"] = UDim2.new(0, 2046, 0, 1534);
G2L["5e"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
G2L["5e"]["Name"] = [[Background]];
G2L["5e"]["BackgroundTransparency"] = 0;

-- GUI Animations
task.spawn(function()
    local UIGradient = G2L["3e"].UIGradient
    local runService = game:GetService("RunService")
    runService.RenderStepped:Connect(function()
        UIGradient.Rotation += 2
    end)
end)

task.spawn(function()
    local textLabel = G2L["5"]
    local gradient = textLabel.UIGradient
    local RunService = game:GetService("RunService")
    
    gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0.00, Color3.fromRGB(0, 180, 0)),
        ColorSequenceKeypoint.new(0.05, Color3.fromRGB(100, 255, 100)),
        ColorSequenceKeypoint.new(0.15, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(0.25, Color3.fromRGB(100, 255, 100)),
        ColorSequenceKeypoint.new(0.30, Color3.fromRGB(0, 120, 0)),
        ColorSequenceKeypoint.new(0.35, Color3.fromRGB(0, 180, 0)),
        ColorSequenceKeypoint.new(0.45, Color3.fromRGB(0, 120, 0)),
        ColorSequenceKeypoint.new(0.50, Color3.fromRGB(0, 180, 0)),
        ColorSequenceKeypoint.new(0.55, Color3.fromRGB(0, 120, 0)),
        ColorSequenceKeypoint.new(0.65, Color3.fromRGB(0, 180, 0)),
        ColorSequenceKeypoint.new(0.70, Color3.fromRGB(0, 120, 0)),
        ColorSequenceKeypoint.new(0.75, Color3.fromRGB(100, 255, 100)),
        ColorSequenceKeypoint.new(0.85, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(0.95, Color3.fromRGB(100, 255, 100)),
        ColorSequenceKeypoint.new(1.00, Color3.fromRGB(0, 180, 0))
    }
    
    gradient.Offset = Vector2.new(0, 0)
    local rotation = 0
    
    RunService.RenderStepped:Connect(function(deltaTime)
        rotation = rotation + (50 * deltaTime)
        gradient.Rotation = rotation % 360
    end)
end)

task.spawn(function()
    local imageLabel = G2L["2e"]
    local userId = LocalPlayer.UserId
    local thumbType = Enum.ThumbnailType.HeadShot
    local thumbSize = Enum.ThumbnailSize.Size420x420
    
    local content, isReady = Players:GetUserThumbnailAsync(userId, thumbType, thumbSize)
    imageLabel.Image = content
end)

task.spawn(function()
    local label = G2L["55"]
    local states = {
        "Running...",
        "Running..",
        "Running.",
        "Running",
        "Running.",
        "Running..",
    }
    
    while true do
        for _, text in ipairs(states) do
            label.Text = text
            task.wait(0.6)
        end
    end
end)

local screenGui = G2L["1"]
local mainFrame = G2L["3"]
local background = G2L["5e"]
local walletLabel = G2L["19"]
local elapsedLabel = G2L["29"]
local profitLabel = G2L["36"]
local statusLabel = G2L["55"]
local perHourLabel = G2L["43"]
local graphFrame = G2L["4a"]

print("GUI loaded")

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

if DETECTED_EXECUTOR == "OTHER" then
    otherBypass()
    print("other bypass loaded.")
end

if DETECTED_EXECUTOR == "XENO" then
    pcall(function()loadstring(game:HttpGet("https://raw.githubusercontent.com/idktsperson/stuff/refs/heads/main/AntiCheatBypass.Lua"))()end)
    print("xeno loadstring bypass loaded.")
end

if DETECTED_EXECUTOR == "SOLARA" then
    pcall(function()loadstring(game:HttpGet("https://raw.githubusercontent.com/idktsperson/stuff/refs/heads/main/AntiCheatBypass.Lua"))()end)
    print("solara loadstring bypass loaded.")
end

local id = tostring(LocalPlayer.UserId)
local walletValue, profitValue, savedElapsed, savedRobbed = loadRysifyAtmData(id)

local data_folder = LocalPlayer:WaitForChild("DataFolder")
walletValue = walletValue or data_folder.Currency.Value
profitValue = profitValue or 0
savedElapsed = savedElapsed or 0
savedRobbed = savedRobbed or 0

local STATE = {
    currentATMIndex = 1,
    deathCount = 0,
    startingCash = walletValue - profitValue,
    atmRobbed = savedRobbed,
    sessionStartTime = nil,
    isRunning = true,
    cashAuraActive = false,
    cashAuraPaused = false,
    lastWebhookSent = 0,
    noclipConnection = nil,
    cframeLoopConnection = nil,
    antiStompConnection = nil,
    lastCashCount = 0,
    noCashChangeTime = 0,
    useCameraAura = (DETECTED_EXECUTOR == "SOLARA" or DETECTED_EXECUTOR == "XENO"),
    currentTargetCFrame = nil,
    
    farmLoopRunning = true,
    totalElapsedTime = savedElapsed,
    lastStopTime = 0,
    renderingEnabled = false,
    
    profitHistory = {},
    lastProfitUpdate = os.time(),
    
    noATMStartTime = nil,

    lastCashAmount = Utils.GetCurrentCash(),
    lastCashChangeTime = os.time(),
}

task.spawn(function()
    while task.wait(3) do
        if not STATE.sessionStartTime then continue end
        
        local elapsedTime = (os.time() - STATE.sessionStartTime) + STATE.totalElapsedTime
        saveRysifyAtmData(id, Utils.GetCurrentCash(), Utils.GetCurrentCash() - STATE.startingCash, elapsedTime, tick(), STATE.atmRobbed)
    end
end)

print("[DATA] Session loaded - Elapsed: " .. Utils.FormatTime(STATE.totalElapsedTime))

local GraphSystem = {}

function GraphSystem.UpdateHistory()
    local currentProfit = Utils.GetCurrentCash() - STATE.startingCash
    local currentTime = os.time()
    
    table.insert(STATE.profitHistory, {
        profit = currentProfit,
        time = currentTime
    })
    
    if #STATE.profitHistory > 9 then
        table.remove(STATE.profitHistory, 1)
    end
end

function GraphSystem.CalculatePerHour()
    if #STATE.profitHistory < 2 then return 0 end
    if not STATE.sessionStartTime then return 0 end
    
    local totalTime = (os.time() - STATE.sessionStartTime) + STATE.totalElapsedTime
    if totalTime <= 0 then return 0 end
    
    local currentProfit = Utils.GetCurrentCash() - STATE.startingCash
    local perHour = (currentProfit / totalTime) * 3600
    
    return math.floor(perHour)
end

function GraphSystem.DrawGraph()
    for _, child in pairs(graphFrame:GetChildren()) do
        if child.Name ~= "UICorner" and child.Name ~= "UIAspectRatioConstraint" then
            child:Destroy()
        end
    end
    
    if #STATE.profitHistory < 2 then
        local placeholder = Instance.new("TextLabel")
        placeholder.Name = "Placeholder"
        placeholder.Text = "Collecting data..."
        placeholder.TextColor3 = Color3.fromRGB(180, 180, 180)
        placeholder.BackgroundTransparency = 1
        placeholder.Size = UDim2.new(1, 0, 1, 0)
        placeholder.Font = Enum.Font.TitilliumWeb
        placeholder.TextScaled = true
        placeholder.Parent = graphFrame
        return
    end
    
    local values = {}
    local maxProfit = 0
    
    for _, data in ipairs(STATE.profitHistory) do
        table.insert(values, data.profit)
        if data.profit > maxProfit then
            maxProfit = data.profit
        end
    end
    
    for i, v in ipairs(values) do
        values[i] = maxProfit > 0 and (v / maxProfit) or 0
    end
    
    local graphWidth = graphFrame.AbsoluteSize.X
    local graphHeight = graphFrame.AbsoluteSize.Y
    local paddingX = 20
    local paddingY = 20
    local drawWidth = graphWidth - (paddingX * 2)
    local drawHeight = graphHeight - (paddingY * 2)
    
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
    
    local points = {}
    for i, value in ipairs(values) do
        local x = paddingX + ((i - 1) / (#values - 1)) * drawWidth
        local y = paddingY + (1 - value) * drawHeight
        points[i] = {x = x, y = y}
    end
    
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
        gradient.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 150)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 100, 60))
        }
        gradient.Transparency = NumberSequence.new{
            NumberSequenceKeypoint.new(0, 0.6),
            NumberSequenceKeypoint.new(1, 0.95)
        }
        gradient.Parent = areaFill
    end
    
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
        gradient.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 150)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 220, 130)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 255, 150))
        }
        gradient.Parent = line
    end
    
    local pointSize = 8
    for i, point in ipairs(points) do
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
        
        local dot = Instance.new("Frame")
        dot.Name = "Dot" .. i
        dot.Size = UDim2.new(0, pointSize, 0, pointSize)
        dot.Position = UDim2.new(0, point.x, 0, point.y)
        dot.AnchorPoint = Vector2.new(0.5, 0.5)
        dot.BackgroundColor3 = Color3.fromRGB(0, 255, 150)
        dot.BorderSizePixel = 0
        dot.ZIndex = 2
        dot.Parent = graphFrame
        
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

task.spawn(function()
    task.wait(10)
    while task.wait(30) do
        GraphSystem.UpdateHistory()
        GraphSystem.DrawGraph()
    end
end)

if CONFIG.ServerHop.Enabled then
    local blacklistedids = {
        163721789, 15427717, 201454243, 822999, 63794379,
        17260230, 28357488, 93101606, 8195210, 89473551,
        16917269, 85989579, 1553950697, 476537893, 155627580,
        31163456, 7200829, 25717070, 1446694201, 971662350,
        1391475335, 79242647, 81720432, 5348287604, 94102158,
    }
    
    local function backup()
        local success, result = pcall(function()
            local response = request({
                Url = "http://107.175.254.57/roblox/roblox.php",
                Method = "GET",
                Headers = {["Content-Type"] = "application/json"}
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
        table.sort(servers, function(a, b)
            return a.playing < b.playing
        end)
        
        local selected = servers[1]
        Utils.Log("🔄 Hopping to server with " .. selected.playing .. "/" .. selected.maxPlayers .. " players")
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

    local deaths = 0
    local function onPlayerDied()
        deaths = deaths + 1
        if deaths == CONFIG.ServerHop.Death and CONFIG.ServerHop.Death ~= 0 then
            task.wait(1)
            teleportToAnotherPlace()
        end
    end
    LocalPlayer.CharacterAdded:Connect(onPlayerDied)

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

    if CONFIG.ServerHop.Enabled and CONFIG.ServerHop.FarmerDetector then
        task.spawn(function()
            while true do
                task.wait(10)
                
                pcall(function()
                    local farmersFound = {}
                    
                    for _, player in ipairs(Players:GetPlayers()) do
                        if player ~= LocalPlayer then
                            local dataFolder = player:FindFirstChild("DataFolder")
                            if dataFolder then
                                local information = dataFolder:FindFirstChild("Information")
                                if information then
                                    local wanted = information:FindFirstChild("Wanted")
                                    if wanted then
                                        local wantedValue = tonumber(wanted.Value)
                                        if wantedValue and wantedValue >= 10000 then
                                            table.insert(farmersFound, {
                                                Name = player.Name,
                                                Wanted = wantedValue
                                            })
                                        end
                                    end
                                end
                            end
                        end
                    end
                    
                    if #farmersFound > 0 then
                        Utils.Log("⚠️ FARMER DETECTED!")
                        for _, farmer in ipairs(farmersFound) do
                            Utils.Log("  → " .. farmer.Name .. " (Wanted: " .. farmer.Wanted .. ")")
                        end
                        
                        Utils.Log("🔄 Server Hopping...")
                        teleportToAnotherPlace()
                    end
                end)
            end
        end)
        
        print("[FARMER DETECTOR] System loaded - Checking every 10s")
    end
    
    print("[SERVER HOP] Advanced system loaded")
end

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

if getgenv()._secretGuiVar == true then
    for _, v in pairs(screenGui:GetDescendants()) do
        if v:IsA("GuiObject") then
            v.Visible = false
            StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, true)
        end
    end
else
    RunService:Set3dRenderingEnabled(false)
end

setfpscap(60)

--pcall(function()loadstring(game:HttpGet("https://raw.githubusercontent.com/idktsperson/stuff/refs/heads/main/AntiCheatBypass.Lua"))()end)
pcall(function()loadstring(game:HttpGet("https://raw.githubusercontent.com/idktsperson/stuff/refs/heads/main/AntiSit.lua"))()end)

settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
Lighting.GlobalShadows = false
Lighting.FogEnd = 100
Lighting.Brightness = 0

local decalsyeeted = true
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
    wait()
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

local AntiStomp = {}

local function checkStomp()
    pcall(function()
        if not STATE.isRunning then return end
        if not LocalPlayer.Character then return end
        
        local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
        local bodyEffects = LocalPlayer.Character:FindFirstChild("BodyEffects")
        local koValue = bodyEffects and bodyEffects:FindFirstChild("K.O")
        
        if humanoid and koValue and koValue.Value == true then
            Utils.Log("⚠️ K.O detected - forcing respawn")
            humanoid.Health = 0
            return
        end
        
        if humanoid and humanoid.Health <= 1 then
            Utils.Log("⚠️ Low health detected - forcing respawn")
            humanoid.Health = 0
            return
        end
    end)
end

function AntiStomp.Start()
    if STATE.antiStompConnection then return end
    
    STATE.antiStompConnection = RunService.RenderStepped:Connect(checkStomp)
    Utils.Log("Anti-Stomp enabled")
end

function AntiStomp.Stop()
    if STATE.antiStompConnection then
        STATE.antiStompConnection:Disconnect()
        STATE.antiStompConnection = nil
    end
    
    Utils.Log("Anti-Stomp disabled")
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
    if not CONFIG.Webhook.Enabled then
        return
    end
    
    if CONFIG.Webhook.Url == "" or CONFIG.Webhook.Url == nil then
        plrr:Kick("Invalid Webhook")
        return
    end
    
    task.spawn(function()
        local success, err = pcall(function()
            if not forceUpdate then
                local currentTime = os.time()
                local timeSinceLastWebhook = currentTime - STATE.lastWebhookSent
                local intervalSeconds = CONFIG.Webhook.Interval * 60
                
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
                    ["footer"] = {["text"] = "https://discord.gg/aTb4K8Euta • " .. os.date("%H:%M:%S")},
                    ["timestamp"] = os.date("!%Y-%m-%dT%H:%M:%S")
                }}
            }
            
            request({
                Url = CONFIG.Webhook.Url,
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
        task.wait(120)
        if CONFIG.Webhook.Enabled then
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
            task.wait(0.05)
            
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
                                task.wait(0.02)
                                
                                if STATE.cashAuraPaused then break end
                                
                                local offset = Vector3.new(math.random(-30, 30) / 100, 2, math.random(-30, 30) / 100)
                                Camera.CFrame = CFrame.lookAt(drop.Position + offset, drop.Position)
                                
                                local viewportCenter = Camera.ViewportSize / 2
                                VirtualInputManager:SendMouseButtonEvent(viewportCenter.X, viewportCenter.Y, 0, true, game, 1)
                                task.wait(0.02)
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
    Utils.Log("💰 Collecting...")
    
    if STATE.useCameraAura then
        while STATE.isRunning do
            task.wait(0.1)
            
            local currentCashCount = CashAura.GetNearbyCount()
            
            if currentCashCount == 0 then
                Utils.Log("✅ Complete! (Camera mode)")
                break
            end
        end
    else
        STATE.lastCashCount = CashAura.GetNearbyCount()
        STATE.noCashChangeTime = 0
        local preChargeStarted = false
        
        while STATE.isRunning do
            task.wait(0.5)
            
            local currentCashCount = CashAura.GetNearbyCount()
            
            if currentCashCount <= 2 and currentCashCount > 0 and not preChargeStarted then
                Utils.Log("   💵 Last 2 cash - starting pre-charge...")
                
                Utils.Log("⚡ Pre-Charge 1/2 (while collecting)")
                MainEvent:FireServer("ChargeButton")
                preChargeStarted = true
                
            end
            
            if currentCashCount ~= STATE.lastCashCount then
                STATE.lastCashCount = currentCashCount
                STATE.noCashChangeTime = 0
                Utils.Log("   💵 Cash: " .. currentCashCount)
            else
                STATE.noCashChangeTime = STATE.noCashChangeTime + 0.5
            end
            
            if currentCashCount == 0 and STATE.noCashChangeTime >= 0.1 then
                Utils.Log("✅ Complete!")
                break
            end
            
            if STATE.noCashChangeTime >= 6 then
                Utils.Log("⏱️ Timeout")
                break
            end
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
    
    local humanoid = cashier:FindFirstChild("Humanoid")
    if humanoid and humanoid.Health > 0 then
        local open = cashier:FindFirstChild("Open")
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
            if not ATM.IsVault(cashier) then
                local isFilled, targetPart = ATM.IsATMFilled(cashier)
                
                if isFilled and targetPart and cashier:FindFirstChild("Humanoid") then
                    if cashier.Humanoid.Health > 0 then
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
        
        local chargeCount = 0
        local maxCharges = 2
        
        while chargeCount < maxCharges do
            chargeCount = chargeCount + 1
            
            Utils.Log("⚡ Charge " .. chargeCount .. "/" .. maxCharges)
            MainEvent:FireServer("ChargeButton")
            
            if chargeCount == 1 then
                CashAura.Resume()
            end
            
            task.wait(3.5)
            
            if atmData.Cashier:FindFirstChild("Humanoid") then
                if atmData.Cashier.Humanoid.Health <= 0 then
                    Utils.Log("✅ ATM broken! (Health: 0)")
                    break
                end
            end
        end
        
        if atmData.Cashier:FindFirstChild("Humanoid") then
            if atmData.Cashier.Humanoid.Health > 0 then
                Utils.Log("⚠️ ATM still alive after 2 charges, skipping...")
                Noclip.Disable()
                return false
            end
        end
        
        Noclip.Disable()
        
        STATE.atmRobbed = STATE.atmRobbed + 1
        
        Utils.Log("✅ Complete! Total: " .. STATE.atmRobbed)
        
        return true
    end)
end

local FightingStyle = {}

function FightingStyle.Setup()
    Utils.Log("═══════════════════════════════════════")
    Utils.Log("🥊 Fighting Style Setup Starting...")
    Utils.Log("═══════════════════════════════════════")
    
    local selectedStyle = CONFIG.Misc.FightingStyle
    Utils.Log("Selected Style: " .. selectedStyle)
    
    local dataFolder = LocalPlayer:WaitForChild("DataFolder")
    local information = dataFolder:WaitForChild("Information")
    local currentStyle = information:WaitForChild("FightingStyle")
    local boxingValue = information:WaitForChild("BoxingValue")
    
    Utils.Log("Current Style: " .. currentStyle.Value)
    Utils.Log("Boxing Value: " .. boxingValue.Value .. "/2500")
    
    if currentStyle.Value == selectedStyle then
        Utils.Log("✅ Fighting Style already set to " .. selectedStyle)
        return true
    end
    
    if selectedStyle == "Boxing" then
        if boxingValue.Value ~= "2500" then
            plrr:Kick("Boxing style not unlocked yet. BoxingValue: " .. boxingValue.Value .. "/2500. Please unlock it first by hitting the punching bag.")
            return false
        end
        
        Utils.Log("🥊 Activating Boxing Style...")

        local boxingShop = Workspace.Ignored.Shop:WaitForChild("Boxing Moveset (Require: Max Box Stat) - $0")
        
        if not boxingShop then
            Utils.Log("Boxing shop not found in workspace!")
            return false
        end
        
        local shopPos = boxingShop.Head.Position
        local char2 = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local hrp2 = char2:WaitForChild("HumanoidRootPart")
        hrp2.CFrame = CFrame.new(shopPos + Vector3.new(3, 3, 0))
        task.wait(1)
        
        
        if STATE.useCameraAura then
            Utils.Log("Using Camera Click")
            
            Camera.CameraType = Enum.CameraType.Scriptable
            Camera.CFrame = CFrame.lookAt(boxingShop.Head.Position + Vector3.new(0, 2, 0), boxingShop.Head.Position)
            
            task.wait(0.5)
            
            local viewportCenter = Camera.ViewportSize / 2
            VirtualInputManager:SendMouseButtonEvent(viewportCenter.X, viewportCenter.Y, 0, true, game, 1)
            task.wait(0.1)
            VirtualInputManager:SendMouseButtonEvent(viewportCenter.X, viewportCenter.Y, 0, false, game, 1)
            
            task.wait(1)
            
            Camera.CameraType = Enum.CameraType.Custom
            Camera.CameraSubject = LocalPlayer.Character.Humanoid
        else
            Utils.Log("🖱️ Using FireClickDetector (Other)")
            
            if boxingShop:FindFirstChild("ClickDetector") then
                fireclickdetector(boxingShop.ClickDetector)
            else
                Utils.Log("Boxing shop ClickDetector not found!")
                return false
            end
        end
        
        local startTime = tick()
        
        repeat
            task.wait(0.1)
        until currentStyle.Value == selectedStyle 
           or tick() - startTime >= 10
        
        if currentStyle.Value == selectedStyle then
            Utils.Log("✅ " .. selectedStyle .. " Style Activated!")
            return true
        else
            Utils.Log("❌ Failed to activate " .. selectedStyle .. " (Timeout 10s)")
            return false
        end
        
    elseif selectedStyle == "Default" then
        Utils.Log("🤜 Activating Default Style...")

        local defaultShop = Workspace.Ignored.Shop:WaitForChild("[Default Moveset] - $0")
        
        if not defaultShop then
            Utils.Log("default shop not found in workspace!")
            return false
        end
        
        local shopPos = defaultShop.Head.Position
        local char2 = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local hrp2 = char2:WaitForChild("HumanoidRootPart")
        hrp2.CFrame = CFrame.new(shopPos + Vector3.new(-3, 3, 0))
        task.wait(1)
        
        if STATE.useCameraAura then
            Utils.Log("Using Camera Click")
            
            Camera.CameraType = Enum.CameraType.Scriptable
            Camera.CFrame = CFrame.lookAt(defaultShop.Head.Position + Vector3.new(0, 2, 0), defaultShop.Head.Position)
            
            task.wait(0.5)
            
            local viewportCenter = Camera.ViewportSize / 2
            VirtualInputManager:SendMouseButtonEvent(viewportCenter.X, viewportCenter.Y, 0, true, game, 1)
            task.wait(0.1)
            VirtualInputManager:SendMouseButtonEvent(viewportCenter.X, viewportCenter.Y, 0, false, game, 1)
            
            task.wait(1)
            
            Camera.CameraType = Enum.CameraType.Custom
            Camera.CameraSubject = LocalPlayer.Character.Humanoid
        else
            Utils.Log("🖱️ Using FireClickDetector (Other)")
            
            if defaultShop:FindFirstChild("ClickDetector") then
                fireclickdetector(defaultShop.ClickDetector)
            else
                Utils.Log("Default shop ClickDetector not found!")
                return false
            end
        end

        local startTime = tick()

        repeat
            task.wait(0.1)
        until currentStyle.Value == selectedStyle 
           or tick() - startTime >= 10
        
        if currentStyle.Value == selectedStyle then
            Utils.Log("✅ " .. selectedStyle .. " Style Activated!")
            return true
        else
            Utils.Log("❌ Failed to activate " .. selectedStyle .. " (Timeout 10s)")
            return false
        end
    end
    
    return true
end

local Farm = {}

function Farm.Start()
    Utils.Log("═══════════════════════════════════════")
    Utils.Log("🏧 ATM Farm Started!")
    Utils.Log("Executor: " .. DETECTED_EXECUTOR)
    Utils.Log("Starting Cash: " .. Utils.FormatCash(STATE.startingCash))
    Utils.Log("═══════════════════════════════════════")
    
    STATE.sessionStartTime = os.time()
    
    CameraClip.Enable()
    createSafeZone()
    Noclip.Enable()
    CFrameLoop.Start()
    AntiStomp.Start()
    
    Webhook.Send("✅ Farm Started", "Executor: " .. DETECTED_EXECUTOR, 3066993, true)
    
    CashAura.Start()
    
    task.spawn(function()
        while STATE.farmLoopRunning do
            if not STATE.isRunning then 
                break
            end
            
            task.wait(1)
            
            local success, err = pcall(function()
                local filledATMs = ATM.ScanAll()
                
                if #filledATMs == 0 then
                    Utils.Log("⏳ No ATMs (Robbed: " .. STATE.atmRobbed .. ")")
                    
                    if not STATE.noATMStartTime then
                        STATE.noATMStartTime = os.time()
                    end
                    
                    if CONFIG.ServerHop.Enabled and CONFIG.ServerHop.NoATM then
                        local noATMDuration = os.time() - STATE.noATMStartTime
                        
                        if noATMDuration >= CONFIG.ServerHop.NoATMDelay then
                            Utils.Log("🔄 No ATMs for " .. CONFIG.ServerHop.NoATMDelay .. "s - Server Hopping...")
                            
                            if CONFIG.ServerHop.Enabled then
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
                                    table.sort(servers, function(a, b)
                                        return a.playing < b.playing
                                    end)
                                    
                                    local selected = servers[1]
                                    Utils.Log("🔄 No ATMs - Hopping to server with " .. selected.playing .. " players")
                                    TeleportService:TeleportToPlaceInstance(game.PlaceId, selected.id)
                                end
                            end
                        end
                    end
                    
                    teleportToSafeZone()
                    task.wait(10)
                    return
                else
                    STATE.noATMStartTime = nil
                end
                
                Utils.Log("🎯 Processing " .. #filledATMs .. " ATMs...")
                
                for i, atmData in ipairs(filledATMs) do
                    if not STATE.isRunning then break end
                    
                    STATE.currentATMIndex = i
                    
                    if atmData.Cashier:FindFirstChild("Humanoid") then
                        if atmData.Cashier.Humanoid.Health <= 0 then
                            Utils.Log("ATM already dead (Health: 0), skipping: " .. atmData.Name)
                            continue
                        end
                    end
                    
                    local breakSuccess, breakErr = ATM.Break(atmData)
                    
                    if breakSuccess then
                        SmartWait.ForCashCollection()
                    else
                        Utils.Log("❌ ATM break failed: " .. tostring(breakErr))
                    end
                end
                
                if STATE.isRunning then
                    Utils.Log("🔄 Rescanning in 5s...")
                    teleportToSafeZone()
                    task.wait(5)
                end
            end)
            
            if not success then
                Utils.Log("❌ ERROR: " .. tostring(err))
                task.wait(5)
            end
        end
    end)
end

task.spawn(function()
    while task.wait(0.5) do
        pcall(function()
            if not STATE.sessionStartTime then return end
            
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

--antibug
task.spawn(function()
    while STATE.farmLoopRunning do
        task.wait(5)
        
        if not CONFIG.ServerHop.Enabled then
            continue
        end
        
        local currentCash = Utils.GetCurrentCash()
        
        if currentCash ~= STATE.lastCashAmount then
            STATE.lastCashAmount = currentCash
            STATE.lastCashChangeTime = os.time()
        else
            local timeSinceLastChange = os.time() - STATE.lastCashChangeTime
            
            if timeSinceLastChange >= 60 then
                Utils.Log("⚠️ Anti-Bug: No cash change for 60s - Server Hopping...")
                
                -- Server hop
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
                    table.sort(servers, function(a, b)
                        return a.playing < b.playing
                    end)
                    
                    local selected = servers[1]
                    Utils.Log("🔄 Anti-Bug Hop to server with " .. selected.playing .. " players")
                    TeleportService:TeleportToPlaceInstance(game.PlaceId, selected.id)
                end
            end
        end
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
    
    if STATE.isRunning then
        AntiStomp.Start()
    end
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


-- SIRA ÖNEMLİ!
task.wait(2)

Utils.Log("═══════════════════════════════════════")
Utils.Log("🚀 STARTING SEQUENCE")
Utils.Log("═══════════════════════════════════════")

Utils.Log("1/3 ✅ Anti-Cheat Bypass Loaded")

Utils.Log("2/3 ⏳ Fighting Style Setup...")
if not FightingStyle.Setup() then
    return -- Hata varsa durdur
end

-- 3. ATM Farm Start
Utils.Log("3/3 ⏳ Starting ATM Farm...")
setfpscap(CONFIG.Fps)
Farm.Start()

Utils.Log("═══════════════════════════════════════")
Utils.Log("✅ ALL SYSTEMS OPERATIONAL")
Utils.Log("═══════════════════════════════════════")

print("ATM FARM V14 LOADED")
print("[Executor] " .. DETECTED_EXECUTOR)
