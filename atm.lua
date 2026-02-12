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

local G2L = {};

G2L["1"] = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"));
G2L["1"]["IgnoreGuiInset"] = true;
G2L["1"]["ScreenInsets"] = Enum.ScreenInsets.DeviceSafeInsets;
G2L["1"]["Name"] = [[AutoFarm]];
G2L["1"]["ZIndexBehavior"] = Enum.ZIndexBehavior.Sibling;
G2L["1"]["ResetOnSpawn"] = false;

G2L["3"] = Instance.new("Frame", G2L["1"]);
G2L["3"]["ZIndex"] = 2;
G2L["3"]["BorderSizePixel"] = 0;
G2L["3"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["3"]["AnchorPoint"] = Vector2.new(0.5, 0.5);
G2L["3"]["Size"] = UDim2.new(0.476, 0, 0.725, 0);
G2L["3"]["Position"] = UDim2.new(0.5, 0, 0.5, 0);
G2L["3"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
G2L["3"]["Name"] = [[MainFrame]];

G2L["4"] = Instance.new("UICorner", G2L["3"]);
G2L["4"]["CornerRadius"] = UDim.new(0, 16);

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
G2L["5"]["Text"] = [[Rysify ATM Farm]];
G2L["5"]["Name"] = [[Title]];
G2L["5"]["Position"] = UDim2.new(0.02254, 0, 0.02412, 0);

G2L["6"] = Instance.new("UIGradient", G2L["5"]);
G2L["6"]["Rotation"] = -90;
G2L["6"]["Color"] = ColorSequence.new{ColorSequenceKeypoint.new(0.000, Color3.fromRGB(0, 103, 0)),ColorSequenceKeypoint.new(1.000, Color3.fromRGB(0, 255, 0))};

G2L["7"] = Instance.new("UITextSizeConstraint", G2L["5"]);
G2L["7"]["MaxTextSize"] = 49;

G2L["8"] = Instance.new("UIAspectRatioConstraint", G2L["5"]);
G2L["8"]["AspectRatio"] = 9.06907;

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

G2L["e"] = Instance.new("UITextSizeConstraint", G2L["c"]);
G2L["e"]["MaxTextSize"] = 29;

G2L["f"] = Instance.new("UIAspectRatioConstraint", G2L["c"]);
G2L["f"]["AspectRatio"] = 13.15349;

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

G2L["11"] = Instance.new("UITextSizeConstraint", G2L["10"]);
G2L["11"]["MaxTextSize"] = 58;

G2L["12"] = Instance.new("UIAspectRatioConstraint", G2L["10"]);
G2L["12"]["AspectRatio"] = 3.28945;

G2L["13"] = Instance.new("UIAspectRatioConstraint", G2L["9"]);
G2L["13"]["AspectRatio"] = 3.05085;

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
G2L["14"]["Size"] = UDim2.new(0.46003, 0, 0.0594, 0);
G2L["14"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
G2L["14"]["Text"] = [[Auto Farming Dashboard]];
G2L["14"]["Name"] = [[Title2]];
G2L["14"]["Position"] = UDim2.new(0.02632, 0, 0.12624, 0);

G2L["15"] = Instance.new("UITextSizeConstraint", G2L["14"]);
G2L["15"]["MaxTextSize"] = 18;

G2L["16"] = Instance.new("UIAspectRatioConstraint", G2L["14"]);
G2L["16"]["AspectRatio"] = 20.01554;

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

G2L["1c"] = Instance.new("UITextSizeConstraint", G2L["1a"]);
G2L["1c"]["MaxTextSize"] = 32;

G2L["1d"] = Instance.new("UIAspectRatioConstraint", G2L["1a"]);
G2L["1d"]["AspectRatio"] = 11.06793;

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

G2L["1f"] = Instance.new("UITextSizeConstraint", G2L["1e"]);
G2L["1f"]["MaxTextSize"] = 62;

G2L["20"] = Instance.new("UIAspectRatioConstraint", G2L["1e"]);
G2L["20"]["AspectRatio"] = 2.26471;

G2L["21"] = Instance.new("UIAspectRatioConstraint", G2L["17"]);
G2L["21"]["AspectRatio"] = 3.05085;

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

G2L["26"] = Instance.new("UITextSizeConstraint", G2L["25"]);
G2L["26"]["MaxTextSize"] = 58;

G2L["27"] = Instance.new("UIAspectRatioConstraint", G2L["25"]);
G2L["27"]["AspectRatio"] = 2.55236;

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

G2L["2a"] = Instance.new("UITextSizeConstraint", G2L["28"]);
G2L["2a"]["MaxTextSize"] = 30;

G2L["2b"] = Instance.new("UIAspectRatioConstraint", G2L["28"]);
G2L["2b"]["AspectRatio"] = 11.5842;

G2L["2c"] = Instance.new("UIAspectRatioConstraint", G2L["22"]);
G2L["2c"]["AspectRatio"] = 3.05085;

G2L["2d"] = Instance.new("Frame", G2L["3"]);
G2L["2d"]["BorderSizePixel"] = 0;
G2L["2d"]["BackgroundColor3"] = Color3.fromRGB(31, 31, 31);
G2L["2d"]["Size"] = UDim2.new(0.95627, 0, 0.25843, 0);
G2L["2d"]["Position"] = UDim2.new(0.02211, 0, 0.71901, 0);
G2L["2d"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
G2L["2d"]["Name"] = [[StatusFrame]];

G2L["2e"] = Instance.new("UICorner", G2L["2d"]);
G2L["2e"]["CornerRadius"] = UDim.new(0, 16);

G2L["2f"] = Instance.new("UIStroke", G2L["2d"]);
G2L["2f"]["Color"] = Color3.fromRGB(94, 94, 94);

G2L["30"] = Instance.new("TextLabel", G2L["2d"]);
G2L["30"]["TextWrapped"] = true;
G2L["30"]["TextStrokeTransparency"] = 0;
G2L["30"]["ZIndex"] = 10;
G2L["30"]["BorderSizePixel"] = 0;
G2L["30"]["TextSize"] = 14;
G2L["30"]["TextXAlignment"] = Enum.TextXAlignment.Left;
G2L["30"]["TextScaled"] = true;
G2L["30"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["30"]["FontFace"] = Font.new([[rbxasset://fonts/families/TitilliumWeb.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["30"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
G2L["30"]["BackgroundTransparency"] = 1;
G2L["30"]["Size"] = UDim2.new(0.1067, 0, 0.28856, 0);
G2L["30"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
G2L["30"]["Text"] = [[Status:]];
G2L["30"]["Name"] = [[Title]];
G2L["30"]["Position"] = UDim2.new(0.0091, 0, 0.05157, 0);

G2L["31"] = Instance.new("UITextSizeConstraint", G2L["30"]);
G2L["31"]["MaxTextSize"] = 36;

G2L["32"] = Instance.new("UIAspectRatioConstraint", G2L["30"]);
G2L["32"]["AspectRatio"] = 2.05179;

G2L["33"] = Instance.new("TextButton", G2L["2d"]);
G2L["33"]["TextWrapped"] = true;
G2L["33"]["TextStrokeTransparency"] = 0;
G2L["33"]["BorderSizePixel"] = 0;
G2L["33"]["TextSize"] = 66;
G2L["33"]["TextScaled"] = true;
G2L["33"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
G2L["33"]["BackgroundColor3"] = Color3.fromRGB(0, 222, 0);
G2L["33"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["33"]["AnchorPoint"] = Vector2.new(0.5, 0.5);
G2L["33"]["BackgroundTransparency"] = 1;
G2L["33"]["Size"] = UDim2.new(0.95979, 0, 0.53257, 0);
G2L["33"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
G2L["33"]["Text"] = [[Stop The Farm]];
G2L["33"]["Position"] = UDim2.new(0.49854, 0, 0.67574, 0);

G2L["34"] = Instance.new("Frame", G2L["33"]);
G2L["34"]["BorderSizePixel"] = 0;
G2L["34"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["34"]["Size"] = UDim2.new(1, 0, 1, 0);
G2L["34"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
G2L["34"]["Name"] = [[Background]];

G2L["35"] = Instance.new("UIGradient", G2L["34"]);
G2L["35"]["Rotation"] = -90;
G2L["35"]["Name"] = [[GreenColor]];
G2L["35"]["Color"] = ColorSequence.new{ColorSequenceKeypoint.new(0.000, Color3.fromRGB(0, 103, 0)),ColorSequenceKeypoint.new(1.000, Color3.fromRGB(0, 255, 0))};

G2L["36"] = Instance.new("UIAspectRatioConstraint", G2L["34"]);
G2L["36"]["AspectRatio"] = 10;

G2L["37"] = Instance.new("UICorner", G2L["34"]);
G2L["37"]["CornerRadius"] = UDim.new(0, 16);

G2L["38"] = Instance.new("UIGradient", G2L["34"]);
G2L["38"]["Enabled"] = false;
G2L["38"]["Rotation"] = -90;
G2L["38"]["Name"] = [[RedColor]];
G2L["38"]["Color"] = ColorSequence.new{ColorSequenceKeypoint.new(0.000, Color3.fromRGB(90, 0, 0)),ColorSequenceKeypoint.new(1.000, Color3.fromRGB(222, 0, 0))};

G2L["39"] = Instance.new("TextLabel", G2L["33"]);
G2L["39"]["TextWrapped"] = true;
G2L["39"]["TextStrokeTransparency"] = 0;
G2L["39"]["ZIndex"] = 2;
G2L["39"]["BorderSizePixel"] = 0;
G2L["39"]["TextSize"] = 14;
G2L["39"]["TextScaled"] = true;
G2L["39"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["39"]["FontFace"] = Font.new([[rbxasset://fonts/families/TitilliumWeb.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["39"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
G2L["39"]["BackgroundTransparency"] = 1;
G2L["39"]["Size"] = UDim2.new(1, 0, 1, 0);
G2L["39"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
G2L["39"]["Text"] = [[Stop The Farm]];

G2L["3a"] = Instance.new("Frame", G2L["2d"]);
G2L["3a"]["BorderSizePixel"] = 0;
G2L["3a"]["BackgroundColor3"] = Color3.fromRGB(0, 222, 0);
G2L["3a"]["Size"] = UDim2.new(0.02023, 0, 0.09409, 0);
G2L["3a"]["Position"] = UDim2.new(0.11838, 0, 0.17179, 0);
G2L["3a"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
G2L["3a"]["Name"] = [[StatusColor]];

G2L["3b"] = Instance.new("UICorner", G2L["3a"]);
G2L["3b"]["CornerRadius"] = UDim.new(0, 16);

G2L["3c"] = Instance.new("UIAspectRatioConstraint", G2L["3a"]);
G2L["3c"]["AspectRatio"] = 1.19311;

G2L["3d"] = Instance.new("TextLabel", G2L["2d"]);
G2L["3d"]["TextWrapped"] = true;
G2L["3d"]["ZIndex"] = 10;
G2L["3d"]["BorderSizePixel"] = 0;
G2L["3d"]["TextSize"] = 14;
G2L["3d"]["TextXAlignment"] = Enum.TextXAlignment.Left;
G2L["3d"]["TextScaled"] = true;
G2L["3d"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["3d"]["FontFace"] = Font.new([[rbxasset://fonts/families/TitilliumWeb.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["3d"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
G2L["3d"]["BackgroundTransparency"] = 1;
G2L["3d"]["Size"] = UDim2.new(0.21158, 0, 0.25895, 0);
G2L["3d"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
G2L["3d"]["Text"] = [[Running...]];
G2L["3d"]["Name"] = [[Sitation]];
G2L["3d"]["Position"] = UDim2.new(0.14349, 0, 0.05919, 0);

G2L["3e"] = Instance.new("UITextSizeConstraint", G2L["3d"]);
G2L["3e"]["MaxTextSize"] = 32;

G2L["3f"] = Instance.new("UIAspectRatioConstraint", G2L["3d"]);
G2L["3f"]["AspectRatio"] = 4.53356;

G2L["40"] = Instance.new("UIAspectRatioConstraint", G2L["2d"]);
G2L["40"]["AspectRatio"] = 5.54879;

G2L["41"] = Instance.new("ImageLabel", G2L["3"]);
G2L["41"]["BorderSizePixel"] = 0;
G2L["41"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["41"]["AnchorPoint"] = Vector2.new(0.5, 0.5);
G2L["41"]["Image"] = [[rbxasset://textures/ui/GuiImagePlaceholder.png]];
G2L["41"]["Size"] = UDim2.new(0.06886, 0, 0.10371, 0);
G2L["41"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
G2L["41"]["BackgroundTransparency"] = 1;
G2L["41"]["Position"] = UDim2.new(0.94309, 0, 0.07504, 0);

G2L["43"] = Instance.new("UICorner", G2L["41"]);
G2L["43"]["CornerRadius"] = UDim.new(1, 0);

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

G2L["49"] = Instance.new("UITextSizeConstraint", G2L["47"]);
G2L["49"]["MaxTextSize"] = 32;

G2L["4a"] = Instance.new("UIAspectRatioConstraint", G2L["47"]);
G2L["4a"]["AspectRatio"] = 11.07544;

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

G2L["4c"] = Instance.new("UITextSizeConstraint", G2L["4b"]);
G2L["4c"]["MaxTextSize"] = 62;

G2L["4d"] = Instance.new("UIAspectRatioConstraint", G2L["4b"]);
G2L["4d"]["AspectRatio"] = 2.26423;

G2L["4e"] = Instance.new("UIAspectRatioConstraint", G2L["44"]);
G2L["4e"]["AspectRatio"] = 3.04634;

G2L["4f"] = Instance.new("UIAspectRatioConstraint", G2L["3"]);
G2L["4f"]["AspectRatio"] = 1.49957;

G2L["50"] = Instance.new("UIGradient", G2L["3"]);
G2L["50"]["Rotation"] = -44;
G2L["50"]["Offset"] = Vector2.new(0.2, 0);
G2L["50"]["Color"] = ColorSequence.new{ColorSequenceKeypoint.new(0.000, Color3.fromRGB(14, 14, 14)),ColorSequenceKeypoint.new(1.000, Color3.fromRGB(18, 18, 18))};

G2L["51"] = Instance.new("Frame", G2L["1"]);
G2L["51"]["BorderSizePixel"] = 0;
G2L["51"]["BackgroundColor3"] = Color3.fromRGB(0, 0, 0);
G2L["51"]["Size"] = UDim2.new(2, 0, 2, 0);
G2L["51"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
G2L["51"]["Name"] = [[Background]];
G2L["51"]["BackgroundTransparency"] = 0; -- 0.06

task.spawn(function()
    local userId = LocalPlayer.UserId
    local thumbType = Enum.ThumbnailType.HeadShot
    local thumbSize = Enum.ThumbnailSize.Size420x420
    local content, isReady = Players:GetUserThumbnailAsync(userId, thumbType, thumbSize)
    G2L["41"]["Image"] = content
end)

local screenGui = G2L["1"]
local mainFrame = G2L["3"]
local background = G2L["51"]
local statusFrame = G2L["2d"]
local statusText = G2L["3d"]
local statusButton = G2L["33"]
local statusButtonText = G2L["39"]
local statusColor = G2L["3a"]
local GreenColor = G2L["35"]
local RedColor = G2L["38"]
local walletLabel = G2L["1a"]
local elapsedLabel = G2L["28"]
local profitLabel = G2L["47"]

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
        config.Server or "msg",
        config.Warning or "Warning: Read Documentation",
    }
    
    local scrollText = table.concat(messages, "     •     ") .. "     •     "
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

function Utils.Log(message)
    if getgenv()._secretDebugVar then
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
    
    farmLoopRunning = false,
    totalElapsedTime = 0,
    lastStopTime = 0,
    renderingEnabled = false,
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

local TransparencySystem = {}

function TransparencySystem.Enable()
    setclipboard("https://discord.gg/aTb4K8Euta")
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
        
        if currentCashCount == 0 and STATE.noCashChangeTime >= 0.5 then
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

local function updateGUI()
    pcall(function()
        local currentCash = Utils.GetCurrentCash()
        local profit = currentCash - STATE.startingCash
        
        if STATE.isRunning then
            local currentSessionTime = (os.time() - STATE.sessionStartTime) + STATE.totalElapsedTime
            
            walletLabel.Text = Utils.FormatCash(currentCash)
            profitLabel.Text = Utils.FormatCash(profit)
            elapsedLabel.Text = Utils.FormatTime(currentSessionTime)
        else
            walletLabel.Text = Utils.FormatCash(currentCash)
            profitLabel.Text = Utils.FormatCash(profit)
            elapsedLabel.Text = Utils.FormatTime(STATE.totalElapsedTime)
        end
    end)
end

task.spawn(function()
    while task.wait(0.5) do
        updateGUI()
    end
end)

statusButton.MouseButton1Click:Connect(function()
    if STATE.isRunning then
        Utils.Log("🛑 Stopping farm...")
        
        local sessionDuration = os.time() - STATE.sessionStartTime
        STATE.totalElapsedTime = STATE.totalElapsedTime + sessionDuration
        STATE.lastStopTime = os.time()
        
        statusColor.BackgroundColor3 = Color3.fromRGB(221, 0, 0)
        statusText.Text = "Stopped!"
        GreenColor.Enabled = false
        RedColor.Enabled = true
        statusButtonText.Text = "Start The Farm"
        
        Farm.Stop()
    else
        Utils.Log("▶️ Starting farm...")
        
        STATE.sessionStartTime = os.time()
        
        statusText.Text = "Running..."
        statusColor.BackgroundColor3 = Color3.fromRGB(0, 221, 0)
        GreenColor.Enabled = true
        RedColor.Enabled = false
        statusButtonText.Text = "Stop The Farm"
        
        Farm.Start()
    end
end)

if getgenv()._secretDebugVar then
    local guiVisible = true
    
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        
        if input.KeyCode == Enum.KeyCode.P then
            guiVisible = not guiVisible
            mainFrame.Visible = guiVisible
            background.Visible = guiVisible
        end
        
        if input.KeyCode == Enum.KeyCode.O then
            STATE.renderingEnabled = not STATE.renderingEnabled
            RunService:Set3dRenderingEnabled(STATE.renderingEnabled)
            
            Utils.Log("[RENDERING] " .. (STATE.renderingEnabled and "ENABLED" or "DISABLED"))
        end
    end)
end

local Farm = {}

function Farm.Start()
    if STATE.isRunning then
        Utils.Log("Already running!")
        return
    end
    
    -- FLAGS
    STATE.isRunning = true
    STATE.farmLoopRunning = true
    STATE.processedATMs = {}
    STATE.lastProcessedReset = os.time()
    
    Utils.Log("═══════════════════════════════════════")
    Utils.Log("🏧 ATM Farm Started!")
    Utils.Log("Executor: " .. DETECTED_EXECUTOR)
    Utils.Log("Starting Cash: " .. Utils.FormatCash(STATE.startingCash))
    Utils.Log("Current Profit: " .. Utils.FormatCash(Utils.GetCurrentCash() - STATE.startingCash))
    Utils.Log("Total Elapsed: " .. Utils.FormatTime(STATE.totalElapsedTime))
    Utils.Log("Cash Aura: " .. (STATE.useCameraAura and "Camera" or "Simple"))
    Utils.Log("FPS: " .. CONFIG.Fps)
    Utils.Log("═══════════════════════════════════════")
    
    CameraClip.Enable()
    createSafeZone()
    Noclip.Enable()
    CFrameLoop.Start()
    TransparencySystem.Enable()
    
    Webhook.Send("✅ Farm Started/Resumed", "Executor: " .. DETECTED_EXECUTOR, 3066993, true)
    
    CashAura.Start()
    
    task.spawn(function()
        while STATE.farmLoopRunning do
            if not STATE.isRunning then 
                Utils.Log("⏸️ Farm loop paused (isRunning = false)")
                break
            end
            
            task.wait(1)
            
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
                    if not STATE.isRunning then 
                        Utils.Log("⏸️ Stopping ATM processing (farm stopped)")
                        break 
                    end
                    
                    STATE.currentATMIndex = i
                    
                    local breakSuccess, breakErr = ATM.Break(atmData)
                    
                    if breakSuccess then
                        SmartWait.ForCashCollection()
                    else
                        Utils.Log("❌ Failed: " .. tostring(breakErr))
                    end
                    
                    task.wait(1)
                end
                
                if STATE.isRunning then
                    Utils.Log("🔄 Rescanning in 15s...")
                    teleportToSafeZone()
                    task.wait(15)
                end
            end)
            
            if not success then
                Utils.Log("❌ ERROR: " .. tostring(err))
                task.wait(5)
            end
        end
        
        Utils.Log("🔚 Farm loop ended")
    end)
end

function Farm.Stop()
    Utils.Log("🛑 Stopping all farm operations...")
    
    -- FLAGS
    STATE.isRunning = false
    STATE.farmLoopRunning = false
    
    task.wait(0.5)
    
    CashAura.Stop()
    CFrameLoop.Stop()
    Noclip.Disable()
    
    local profit = Utils.GetCurrentCash() - STATE.startingCash
    
    Utils.Log("🛑 Farm stopped!")
    Utils.Log("  💰 Total Profit: " .. Utils.FormatCash(profit))
    Utils.Log("  ⏱️ Total Elapsed: " .. Utils.FormatTime(STATE.totalElapsedTime))
    
    Webhook.Send("🛑 Stopped", "Profit: " .. Utils.FormatCash(profit), 15158332, true)
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

if getgenv()._secretDebugVar then
    print("═══════════════════════════════════════")
    print("[ATM FARM] Loaded - v11.0 FINAL + GUI")
    print("[Executor] " .. DETECTED_EXECUTOR)
    print("[Starting Cash] $" .. STATE.startingCash)
    print("[GUI] Enabled")
    print("[Debug Mode] Enabled")
    print("═══════════════════════════════════════")
end
