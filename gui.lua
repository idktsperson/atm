-- ════════════════════════════════════════════════════════════════
-- RYSIFY ATM FARM GUI
-- ════════════════════════════════════════════════════════════════

local G2L = {};

-- StarterGui.AutoFarm
G2L["1"] = Instance.new("ScreenGui", game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui"));
G2L["1"]["IgnoreGuiInset"] = true;
G2L["1"]["ScreenInsets"] = Enum.ScreenInsets.DeviceSafeInsets;
G2L["1"]["Name"] = [[AutoFarm]];
G2L["1"]["ZIndexBehavior"] = Enum.ZIndexBehavior.Sibling;
G2L["1"]["ResetOnSpawn"] = false;

-- StarterGui.AutoFarm.MainFrame
G2L["3"] = Instance.new("Frame", G2L["1"]);
G2L["3"]["ZIndex"] = 2;
G2L["3"]["BorderSizePixel"] = 0;
G2L["3"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["3"]["AnchorPoint"] = Vector2.new(0.5, 0.5);
G2L["3"]["Size"] = UDim2.new(0.476, 0, 0.725, 0);
G2L["3"]["Position"] = UDim2.new(0.5, 0, 0.5, 0);
G2L["3"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
G2L["3"]["Name"] = [[MainFrame]];

-- StarterGui.AutoFarm.MainFrame.UICorner
G2L["4"] = Instance.new("UICorner", G2L["3"]);
G2L["4"]["CornerRadius"] = UDim.new(0, 16);

-- StarterGui.AutoFarm.MainFrame.Title
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

-- StarterGui.AutoFarm.MainFrame.Title.UIGradient
G2L["6"] = Instance.new("UIGradient", G2L["5"]);
G2L["6"]["Rotation"] = -90;
G2L["6"]["Color"] = ColorSequence.new{ColorSequenceKeypoint.new(0.000, Color3.fromRGB(0, 103, 0)),ColorSequenceKeypoint.new(1.000, Color3.fromRGB(0, 255, 0))};

-- StarterGui.AutoFarm.MainFrame.Title.UITextSizeConstraint
G2L["7"] = Instance.new("UITextSizeConstraint", G2L["5"]);
G2L["7"]["MaxTextSize"] = 49;

-- StarterGui.AutoFarm.MainFrame.Title.UIAspectRatioConstraint
G2L["8"] = Instance.new("UIAspectRatioConstraint", G2L["5"]);
G2L["8"]["AspectRatio"] = 9.06907;

-- StarterGui.AutoFarm.MainFrame.UsernameFrame
G2L["9"] = Instance.new("Frame", G2L["3"]);
G2L["9"]["BorderSizePixel"] = 0;
G2L["9"]["BackgroundColor3"] = Color3.fromRGB(31, 31, 31);
G2L["9"]["Size"] = UDim2.new(0.472, 0, 0.232, 0);
G2L["9"]["Position"] = UDim2.new(0.02211, 0, 0.2027, 0);
G2L["9"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
G2L["9"]["Name"] = [[UsernameFrame]];

-- StarterGui.AutoFarm.MainFrame.UsernameFrame.UICorner
G2L["a"] = Instance.new("UICorner", G2L["9"]);
G2L["a"]["CornerRadius"] = UDim.new(0, 16);

-- StarterGui.AutoFarm.MainFrame.UsernameFrame.UIStroke
G2L["b"] = Instance.new("UIStroke", G2L["9"]);
G2L["b"]["Color"] = Color3.fromRGB(94, 94, 94);

-- StarterGui.AutoFarm.MainFrame.UsernameFrame.Username
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
G2L["c"]["Text"] = [[Loading...]];
G2L["c"]["Name"] = [[Username]];
G2L["c"]["Position"] = UDim2.new(0.01835, 0, 0.52701, 0);

-- StarterGui.AutoFarm.MainFrame.UsernameFrame.Username.UIGradient
G2L["d"] = Instance.new("UIGradient", G2L["c"]);
G2L["d"]["Rotation"] = -90;
G2L["d"]["Color"] = ColorSequence.new{ColorSequenceKeypoint.new(0.000, Color3.fromRGB(0, 103, 0)),ColorSequenceKeypoint.new(1.000, Color3.fromRGB(0, 255, 0))};

-- StarterGui.AutoFarm.MainFrame.UsernameFrame.Username.UITextSizeConstraint
G2L["e"] = Instance.new("UITextSizeConstraint", G2L["c"]);
G2L["e"]["MaxTextSize"] = 29;

-- StarterGui.AutoFarm.MainFrame.UsernameFrame.Username.UIAspectRatioConstraint
G2L["f"] = Instance.new("UIAspectRatioConstraint", G2L["c"]);
G2L["f"]["AspectRatio"] = 13.15349;

-- StarterGui.AutoFarm.MainFrame.UsernameFrame.Title
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

-- StarterGui.AutoFarm.MainFrame.UsernameFrame.Title.UITextSizeConstraint
G2L["11"] = Instance.new("UITextSizeConstraint", G2L["10"]);
G2L["11"]["MaxTextSize"] = 58;

-- StarterGui.AutoFarm.MainFrame.UsernameFrame.Title.UIAspectRatioConstraint
G2L["12"] = Instance.new("UIAspectRatioConstraint", G2L["10"]);
G2L["12"]["AspectRatio"] = 3.28945;

-- StarterGui.AutoFarm.MainFrame.UsernameFrame.UIAspectRatioConstraint
G2L["13"] = Instance.new("UIAspectRatioConstraint", G2L["9"]);
G2L["13"]["AspectRatio"] = 3.05085;

-- StarterGui.AutoFarm.MainFrame.Title2
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

-- StarterGui.AutoFarm.MainFrame.Title2.UITextSizeConstraint
G2L["15"] = Instance.new("UITextSizeConstraint", G2L["14"]);
G2L["15"]["MaxTextSize"] = 18;

-- StarterGui.AutoFarm.MainFrame.Title2.UIAspectRatioConstraint
G2L["16"] = Instance.new("UIAspectRatioConstraint", G2L["14"]);
G2L["16"]["AspectRatio"] = 20.01554;

-- StarterGui.AutoFarm.MainFrame.CashFrame
G2L["17"] = Instance.new("Frame", G2L["3"]);
G2L["17"]["BorderSizePixel"] = 0;
G2L["17"]["BackgroundColor3"] = Color3.fromRGB(31, 31, 31);
G2L["17"]["Size"] = UDim2.new(0.472, 0, 0.232, 0);
G2L["17"]["Position"] = UDim2.new(0.02211, 0, 0.45451, 0);
G2L["17"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
G2L["17"]["Name"] = [[CashFrame]];

-- StarterGui.AutoFarm.MainFrame.CashFrame.UICorner
G2L["18"] = Instance.new("UICorner", G2L["17"]);
G2L["18"]["CornerRadius"] = UDim.new(0, 16);

-- StarterGui.AutoFarm.MainFrame.CashFrame.UIStroke
G2L["19"] = Instance.new("UIStroke", G2L["17"]);
G2L["19"]["Color"] = Color3.fromRGB(94, 94, 94);

-- StarterGui.AutoFarm.MainFrame.CashFrame.Wallet
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

-- StarterGui.AutoFarm.MainFrame.CashFrame.Wallet.UIGradient
G2L["1b"] = Instance.new("UIGradient", G2L["1a"]);
G2L["1b"]["Rotation"] = -90;
G2L["1b"]["Color"] = ColorSequence.new{ColorSequenceKeypoint.new(0.000, Color3.fromRGB(0, 103, 0)),ColorSequenceKeypoint.new(1.000, Color3.fromRGB(0, 255, 0))};

-- StarterGui.AutoFarm.MainFrame.CashFrame.Wallet.UITextSizeConstraint
G2L["1c"] = Instance.new("UITextSizeConstraint", G2L["1a"]);
G2L["1c"]["MaxTextSize"] = 32;

-- StarterGui.AutoFarm.MainFrame.CashFrame.Wallet.UIAspectRatioConstraint
G2L["1d"] = Instance.new("UIAspectRatioConstraint", G2L["1a"]);
G2L["1d"]["AspectRatio"] = 11.06793;

-- StarterGui.AutoFarm.MainFrame.CashFrame.Title
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

-- StarterGui.AutoFarm.MainFrame.CashFrame.Title.UITextSizeConstraint
G2L["1f"] = Instance.new("UITextSizeConstraint", G2L["1e"]);
G2L["1f"]["MaxTextSize"] = 62;

-- StarterGui.AutoFarm.MainFrame.CashFrame.Title.UIAspectRatioConstraint
G2L["20"] = Instance.new("UIAspectRatioConstraint", G2L["1e"]);
G2L["20"]["AspectRatio"] = 2.26471;

-- StarterGui.AutoFarm.MainFrame.CashFrame.UIAspectRatioConstraint
G2L["21"] = Instance.new("UIAspectRatioConstraint", G2L["17"]);
G2L["21"]["AspectRatio"] = 3.05085;

-- StarterGui.AutoFarm.MainFrame.ElapsedFrame
G2L["22"] = Instance.new("Frame", G2L["3"]);
G2L["22"]["BorderSizePixel"] = 0;
G2L["22"]["BackgroundColor3"] = Color3.fromRGB(31, 31, 31);
G2L["22"]["Size"] = UDim2.new(0.472, 0, 0.232, 0);
G2L["22"]["Position"] = UDim2.new(0.50645, 0, 0.20433, 0);
G2L["22"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
G2L["22"]["Name"] = [[ElapsedFrame]];

-- StarterGui.AutoFarm.MainFrame.ElapsedFrame.UICorner
G2L["23"] = Instance.new("UICorner", G2L["22"]);
G2L["23"]["CornerRadius"] = UDim.new(0, 16);

-- StarterGui.AutoFarm.MainFrame.ElapsedFrame.UIStroke
G2L["24"] = Instance.new("UIStroke", G2L["22"]);
G2L["24"]["Color"] = Color3.fromRGB(94, 94, 94);

-- StarterGui.AutoFarm.MainFrame.ElapsedFrame.Title
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

-- StarterGui.AutoFarm.MainFrame.ElapsedFrame.Title.UITextSizeConstraint
G2L["26"] = Instance.new("UITextSizeConstraint", G2L["25"]);
G2L["26"]["MaxTextSize"] = 58;

-- StarterGui.AutoFarm.MainFrame.ElapsedFrame.Title.UIAspectRatioConstraint
G2L["27"] = Instance.new("UIAspectRatioConstraint", G2L["25"]);
G2L["27"]["AspectRatio"] = 2.55236;

-- StarterGui.AutoFarm.MainFrame.ElapsedFrame.Elapsed
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

-- StarterGui.AutoFarm.MainFrame.ElapsedFrame.Elapsed.UIGradient
G2L["29"] = Instance.new("UIGradient", G2L["28"]);
G2L["29"]["Rotation"] = -90;
G2L["29"]["Color"] = ColorSequence.new{ColorSequenceKeypoint.new(0.000, Color3.fromRGB(0, 103, 0)),ColorSequenceKeypoint.new(1.000, Color3.fromRGB(0, 255, 0))};

-- StarterGui.AutoFarm.MainFrame.ElapsedFrame.Elapsed.UITextSizeConstraint
G2L["2a"] = Instance.new("UITextSizeConstraint", G2L["28"]);
G2L["2a"]["MaxTextSize"] = 30;

-- StarterGui.AutoFarm.MainFrame.ElapsedFrame.Elapsed.UIAspectRatioConstraint
G2L["2b"] = Instance.new("UIAspectRatioConstraint", G2L["28"]);
G2L["2b"]["AspectRatio"] = 11.5842;

-- StarterGui.AutoFarm.MainFrame.ElapsedFrame.UIAspectRatioConstraint
G2L["2c"] = Instance.new("UIAspectRatioConstraint", G2L["22"]);
G2L["2c"]["AspectRatio"] = 3.05085;

-- StarterGui.AutoFarm.MainFrame.StatusFrame
G2L["2d"] = Instance.new("Frame", G2L["3"]);
G2L["2d"]["BorderSizePixel"] = 0;
G2L["2d"]["BackgroundColor3"] = Color3.fromRGB(31, 31, 31);
G2L["2d"]["Size"] = UDim2.new(0.95627, 0, 0.25843, 0);
G2L["2d"]["Position"] = UDim2.new(0.02211, 0, 0.71901, 0);
G2L["2d"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
G2L["2d"]["Name"] = [[StatusFrame]];

-- StarterGui.AutoFarm.MainFrame.StatusFrame.UICorner
G2L["2e"] = Instance.new("UICorner", G2L["2d"]);
G2L["2e"]["CornerRadius"] = UDim.new(0, 16);

-- StarterGui.AutoFarm.MainFrame.StatusFrame.UIStroke
G2L["2f"] = Instance.new("UIStroke", G2L["2d"]);
G2L["2f"]["Color"] = Color3.fromRGB(94, 94, 94);

-- StarterGui.AutoFarm.MainFrame.StatusFrame.Title
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

-- StarterGui.AutoFarm.MainFrame.StatusFrame.Title.UITextSizeConstraint
G2L["31"] = Instance.new("UITextSizeConstraint", G2L["30"]);
G2L["31"]["MaxTextSize"] = 36;

-- StarterGui.AutoFarm.MainFrame.StatusFrame.Title.UIAspectRatioConstraint
G2L["32"] = Instance.new("UIAspectRatioConstraint", G2L["30"]);
G2L["32"]["AspectRatio"] = 2.05179;

-- StarterGui.AutoFarm.MainFrame.StatusFrame.TextButton
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

-- StarterGui.AutoFarm.MainFrame.StatusFrame.TextButton.Background
G2L["34"] = Instance.new("Frame", G2L["33"]);
G2L["34"]["BorderSizePixel"] = 0;
G2L["34"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["34"]["Size"] = UDim2.new(1, 0, 1, 0);
G2L["34"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
G2L["34"]["Name"] = [[Background]];

-- StarterGui.AutoFarm.MainFrame.StatusFrame.TextButton.Background.GreenColor
G2L["35"] = Instance.new("UIGradient", G2L["34"]);
G2L["35"]["Rotation"] = -90;
G2L["35"]["Name"] = [[GreenColor]];
G2L["35"]["Color"] = ColorSequence.new{ColorSequenceKeypoint.new(0.000, Color3.fromRGB(0, 103, 0)),ColorSequenceKeypoint.new(1.000, Color3.fromRGB(0, 255, 0))};

-- StarterGui.AutoFarm.MainFrame.StatusFrame.TextButton.Background.UIAspectRatioConstraint
G2L["36"] = Instance.new("UIAspectRatioConstraint", G2L["34"]);
G2L["36"]["AspectRatio"] = 10;

-- StarterGui.AutoFarm.MainFrame.StatusFrame.TextButton.Background.UICorner
G2L["37"] = Instance.new("UICorner", G2L["34"]);
G2L["37"]["CornerRadius"] = UDim.new(0, 16);

-- StarterGui.AutoFarm.MainFrame.StatusFrame.TextButton.Background.RedColor
G2L["38"] = Instance.new("UIGradient", G2L["34"]);
G2L["38"]["Enabled"] = false;
G2L["38"]["Rotation"] = -90;
G2L["38"]["Name"] = [[RedColor]];
G2L["38"]["Color"] = ColorSequence.new{ColorSequenceKeypoint.new(0.000, Color3.fromRGB(90, 0, 0)),ColorSequenceKeypoint.new(1.000, Color3.fromRGB(222, 0, 0))};

-- StarterGui.AutoFarm.MainFrame.StatusFrame.TextButton.TextLabel
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

-- StarterGui.AutoFarm.MainFrame.StatusFrame.StatusColor
G2L["3a"] = Instance.new("Frame", G2L["2d"]);
G2L["3a"]["BorderSizePixel"] = 0;
G2L["3a"]["BackgroundColor3"] = Color3.fromRGB(0, 222, 0);
G2L["3a"]["Size"] = UDim2.new(0.02023, 0, 0.09409, 0);
G2L["3a"]["Position"] = UDim2.new(0.11838, 0, 0.17179, 0);
G2L["3a"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
G2L["3a"]["Name"] = [[StatusColor]];

-- StarterGui.AutoFarm.MainFrame.StatusFrame.StatusColor.UICorner
G2L["3b"] = Instance.new("UICorner", G2L["3a"]);
G2L["3b"]["CornerRadius"] = UDim.new(0, 16);

-- StarterGui.AutoFarm.MainFrame.StatusFrame.StatusColor.UIAspectRatioConstraint
G2L["3c"] = Instance.new("UIAspectRatioConstraint", G2L["3a"]);
G2L["3c"]["AspectRatio"] = 1.19311;

-- StarterGui.AutoFarm.MainFrame.StatusFrame.Sitation
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

-- StarterGui.AutoFarm.MainFrame.StatusFrame.Sitation.UITextSizeConstraint
G2L["3e"] = Instance.new("UITextSizeConstraint", G2L["3d"]);
G2L["3e"]["MaxTextSize"] = 32;

-- StarterGui.AutoFarm.MainFrame.StatusFrame.Sitation.UIAspectRatioConstraint
G2L["3f"] = Instance.new("UIAspectRatioConstraint", G2L["3d"]);
G2L["3f"]["AspectRatio"] = 4.53356;

-- StarterGui.AutoFarm.MainFrame.StatusFrame.UIAspectRatioConstraint
G2L["40"] = Instance.new("UIAspectRatioConstraint", G2L["2d"]);
G2L["40"]["AspectRatio"] = 5.54879;

-- StarterGui.AutoFarm.MainFrame.ImageLabel
G2L["41"] = Instance.new("ImageLabel", G2L["3"]);
G2L["41"]["BorderSizePixel"] = 0;
G2L["41"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["41"]["AnchorPoint"] = Vector2.new(0.5, 0.5);
G2L["41"]["Image"] = [[rbxasset://textures/ui/GuiImagePlaceholder.png]];
G2L["41"]["Size"] = UDim2.new(0.06886, 0, 0.10371, 0);
G2L["41"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
G2L["41"]["BackgroundTransparency"] = 1;
G2L["41"]["Position"] = UDim2.new(0.94309, 0, 0.07504, 0);

-- StarterGui.AutoFarm.MainFrame.ImageLabel.UICorner
G2L["43"] = Instance.new("UICorner", G2L["41"]);
G2L["43"]["CornerRadius"] = UDim.new(1, 0);

-- StarterGui.AutoFarm.MainFrame.ProfitFrame
G2L["44"] = Instance.new("Frame", G2L["3"]);
G2L["44"]["BorderSizePixel"] = 0;
G2L["44"]["BackgroundColor3"] = Color3.fromRGB(31, 31, 31);
G2L["44"]["Size"] = UDim2.new(0.47194, 0, 0.23231, 0);
G2L["44"]["Position"] = UDim2.new(0.50576, 0, 0.45451, 0);
G2L["44"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
G2L["44"]["Name"] = [[ProfitFrame]];

-- StarterGui.AutoFarm.MainFrame.ProfitFrame.UICorner
G2L["45"] = Instance.new("UICorner", G2L["44"]);
G2L["45"]["CornerRadius"] = UDim.new(0, 16);

-- StarterGui.AutoFarm.MainFrame.ProfitFrame.UIStroke
G2L["46"] = Instance.new("UIStroke", G2L["44"]);
G2L["46"]["Color"] = Color3.fromRGB(94, 94, 94);

-- StarterGui.AutoFarm.MainFrame.ProfitFrame.Profit
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

-- StarterGui.AutoFarm.MainFrame.ProfitFrame.Profit.UIGradient
G2L["48"] = Instance.new("UIGradient", G2L["47"]);
G2L["48"]["Rotation"] = -90;
G2L["48"]["Color"] = ColorSequence.new{ColorSequenceKeypoint.new(0.000, Color3.fromRGB(0, 103, 0)),ColorSequenceKeypoint.new(1.000, Color3.fromRGB(0, 255, 0))};

-- StarterGui.AutoFarm.MainFrame.ProfitFrame.Profit.UITextSizeConstraint
G2L["49"] = Instance.new("UITextSizeConstraint", G2L["47"]);
G2L["49"]["MaxTextSize"] = 32;

-- StarterGui.AutoFarm.MainFrame.ProfitFrame.Profit.UIAspectRatioConstraint
G2L["4a"] = Instance.new("UIAspectRatioConstraint", G2L["47"]);
G2L["4a"]["AspectRatio"] = 11.07544;

-- StarterGui.AutoFarm.MainFrame.ProfitFrame.Title
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

-- StarterGui.AutoFarm.MainFrame.ProfitFrame.Title.UITextSizeConstraint
G2L["4c"] = Instance.new("UITextSizeConstraint", G2L["4b"]);
G2L["4c"]["MaxTextSize"] = 62;

-- StarterGui.AutoFarm.MainFrame.ProfitFrame.Title.UIAspectRatioConstraint
G2L["4d"] = Instance.new("UIAspectRatioConstraint", G2L["4b"]);
G2L["4d"]["AspectRatio"] = 2.26423;

-- StarterGui.AutoFarm.MainFrame.ProfitFrame.UIAspectRatioConstraint
G2L["4e"] = Instance.new("UIAspectRatioConstraint", G2L["44"]);
G2L["4e"]["AspectRatio"] = 3.04634;

-- StarterGui.AutoFarm.MainFrame.UIAspectRatioConstraint
G2L["4f"] = Instance.new("UIAspectRatioConstraint", G2L["3"]);
G2L["4f"]["AspectRatio"] = 1.49957;

-- StarterGui.AutoFarm.MainFrame.UIGradient
G2L["50"] = Instance.new("UIGradient", G2L["3"]);
G2L["50"]["Rotation"] = -44;
G2L["50"]["Offset"] = Vector2.new(0.2, 0);
G2L["50"]["Color"] = ColorSequence.new{ColorSequenceKeypoint.new(0.000, Color3.fromRGB(14, 14, 14)),ColorSequenceKeypoint.new(1.000, Color3.fromRGB(18, 18, 18))};

-- StarterGui.AutoFarm.Background
G2L["51"] = Instance.new("Frame", G2L["1"]);
G2L["51"]["BorderSizePixel"] = 0;
G2L["51"]["BackgroundColor3"] = Color3.fromRGB(0, 0, 0);
G2L["51"]["Size"] = UDim2.new(2, 0, 2, 0);
G2L["51"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
G2L["51"]["Name"] = [[Background]];
G2L["51"]["BackgroundTransparency"] = 0.2;

-- StarterGui.AutoFarm.Background.madeby
G2L["52"] = Instance.new("TextLabel", G2L["51"]);
G2L["52"]["TextWrapped"] = true;
G2L["52"]["BorderSizePixel"] = 0;
G2L["52"]["TextSize"] = 33;
G2L["52"]["TextStrokeColor3"] = Color3.fromRGB(255, 255, 255);
G2L["52"]["TextScaled"] = true;
G2L["52"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["52"]["FontFace"] = Font.new([[rbxasset://fonts/families/DenkOne.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["52"]["TextColor3"] = Color3.fromRGB(0, 0, 0);
G2L["52"]["BackgroundTransparency"] = 1;
G2L["52"]["Size"] = UDim2.new(0.06688, 0, 0.07749, 0);
G2L["52"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
G2L["52"]["Text"] = [[made by _ethz on discord]];
G2L["52"]["Name"] = [[madeby]];
G2L["52"]["Position"] = UDim2.new(0.00235, 0, 0.42609, 0);

-- StarterGui.AutoFarm.Background.discord
G2L["53"] = Instance.new("TextLabel", G2L["51"]);
G2L["53"]["TextWrapped"] = true;
G2L["53"]["BorderSizePixel"] = 0;
G2L["53"]["TextSize"] = 25;
G2L["53"]["TextStrokeColor3"] = Color3.fromRGB(255, 255, 255);
G2L["53"]["TextScaled"] = true;
G2L["53"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["53"]["FontFace"] = Font.new([[rbxasset://fonts/families/DenkOne.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["53"]["TextColor3"] = Color3.fromRGB(0, 0, 0);
G2L["53"]["BackgroundTransparency"] = 1;
G2L["53"]["Size"] = UDim2.new(0.09352, 0, 0.07331, 0);
G2L["53"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
G2L["53"]["Text"] = [[discord.gg/aTb4K8Euta]];
G2L["53"]["Name"] = [[discord]];
G2L["53"]["Position"] = UDim2.new(0.40308, 0, 0.42669, 0);

-- ════════════════════════════════════════════════════════════════
-- GUI CONTROLLER
-- ════════════════════════════════════════════════════════════════

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

local screenGui = G2L["1"]
local mainFrame = G2L["3"]
local background = G2L["51"]

-- GUI Elements
local statusFrame = mainFrame.StatusFrame
local statusText = statusFrame.Sitation
local statusButton = statusFrame.TextButton
local statusButtonText = statusFrame.TextButton.TextLabel
local statusColor = statusFrame.StatusColor
local GreenColor = statusFrame.TextButton.Background.GreenColor
local RedColor = statusFrame.TextButton.Background.RedColor

local usernameLabel = mainFrame.UsernameFrame.Username
local walletLabel = mainFrame.CashFrame.Wallet
local elapsedLabel = mainFrame.ElapsedFrame.Elapsed
local profitLabel = mainFrame.ProfitFrame.Profit
local avatarImage = mainFrame.ImageLabel

-- Set initial state
RedColor.Enabled = false
GreenColor.Enabled = true

-- Get player avatar
local userId = LocalPlayer.UserId
local thumbType = Enum.ThumbnailType.HeadShot
local thumbSize = Enum.ThumbnailSize.Size420x420
local content, isReady = Players:GetUserThumbnailAsync(userId, thumbType, thumbSize)
avatarImage.Image = content

-- Set username
usernameLabel.Text = LocalPlayer.Name

-- ════════════════════════════════════════════════════════════════
-- START/STOP BUTTON
-- ════════════════════════════════════════════════════════════════

statusButton.MouseButton1Click:Connect(function()
    if statusText.Text == "Running..." then
        -- Stop farm
        statusColor.BackgroundColor3 = Color3.fromRGB(221, 0, 0)
        statusText.Text = "Stopped!"
        GreenColor.Enabled = false
        RedColor.Enabled = true
        statusButtonText.Text = "Start The Farm"
        
        -- Call stop function
        if getgenv().ATMFarm and getgenv().ATMFarm.Stop then
            getgenv().ATMFarm.Stop()
        end
    else
        -- Start farm
        statusText.Text = "Running..."
        statusColor.BackgroundColor3 = Color3.fromRGB(0, 221, 0)
        GreenColor.Enabled = true
        RedColor.Enabled = false
        statusButtonText.Text = "Stop The Farm"
        
        -- Call start function
        if getgenv().ATMFarm and getgenv().ATMFarm.Start then
            getgenv().ATMFarm.Start()
        end
    end
end)

-- ════════════════════════════════════════════════════════════════
-- GUI UPDATER (Read from getgenv().GUIData)
-- ════════════════════════════════════════════════════════════════

task.spawn(function()
    while task.wait(0.5) do
        pcall(function()
            local data = getgenv().GUIData
            if data then
                -- Update wallet
                if data.Wallet then
                    walletLabel.Text = "$" .. string.format("%,d", data.Wallet):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "")
                end
                
                -- Update profit
                if data.Profit then
                    profitLabel.Text = "$" .. string.format("%,d", data.Profit):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "")
                end
                
                -- Update elapsed
                if data.Elapsed then
                    elapsedLabel.Text = data.Elapsed
                end
            end
        end)
    end
end)

-- ════════════════════════════════════════════════════════════════
-- P KEY TOGGLE (Only if debug enabled)
-- ════════════════════════════════════════════════════════════════

if getgenv()._secretDebugVar then
    local guiVisible = true
    
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        
        if input.KeyCode == Enum.KeyCode.P then
            guiVisible = not guiVisible
            mainFrame.Visible = guiVisible
            background.Visible = guiVisible
        end
    end)
end

-- ════════════════════════════════════════════════════════════════
-- RETURN GUI
-- ════════════════════════════════════════════════════════════════

return screenGui
