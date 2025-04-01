--[[
    SOLHub - Cyberpunk UI Library for Roblox Exploits
    Inspired by Rayfield with a cleaner, minimalist design
    
    Author: AI Assistant
    Version: 1.1.0
]]

local SOLHub = {
    Flags = {},
    Theme = {
        -- Main colors
        Background = Color3.fromRGB(10, 10, 15),       -- Main background
        DarkContrast = Color3.fromRGB(15, 15, 20),     -- Sidebar background
        LightContrast = Color3.fromRGB(20, 20, 30),    -- Section background
        TextColor = Color3.fromRGB(240, 240, 250),     -- Primary text color
        
        -- Accent colors (neon cyberpunk theme)
        AccentColor = Color3.fromRGB(0, 255, 196),     -- Primary accent (Cyan neon)
        AccentColor2 = Color3.fromRGB(255, 0, 93),     -- Secondary accent (Magenta neon)
        AccentColor3 = Color3.fromRGB(0, 89, 255),     -- Tertiary accent (Blue neon)
        
        -- UI element colors
        ElementBackground = Color3.fromRGB(25, 25, 35),  -- Button/element background
        ElementBorder = Color3.fromRGB(30, 30, 45),      -- Element borders
        InactiveElement = Color3.fromRGB(80, 80, 100),   -- Inactive elements
        
        -- Toggle-specific colors
        ToggleBackground = Color3.fromRGB(30, 30, 40),   -- Toggle background
        ToggleEnabled = Color3.fromRGB(0, 255, 196),     -- Toggle on state
        ToggleDisabled = Color3.fromRGB(60, 60, 75),     -- Toggle off state
        
        -- Tab-specific colors
        TabSelected = Color3.fromRGB(0, 255, 196),       -- Selected tab
        TabBackground = Color3.fromRGB(25, 25, 35),      -- Tab background
    },
    Configuration = {
        -- Window properties
        WindowSize = UDim2.new(0, 550, 0, 470),
        UICorner = 4,
        
        -- Element properties
        ElementHeight = 40,                              -- Taller elements for better spacing
        ElementPadding = 12,                             -- Increased padding between elements
        ElementCorner = 3,                               -- Slightly rounder corners
        
        -- Section properties
        SectionPadding = 15,                             -- Increased section padding
        SectionGap = 25,                                 -- Larger gap between sections
        
        -- Tab properties
        TabHeight = 40,
        TabWidth = 160,                                  -- Fixed width for tabs
        TabPadding = 10,                                 -- Increased padding between tabs
        TabsLeftPadding = 20,                            -- Left padding for tab text
        
        -- Window padding
        WindowPadding = 20,                              -- Increased window padding
        ContentPadding = 15,                             -- Increased content padding
        
        -- Animation properties
        AnimationDuration = 0.25,                        -- Slightly faster animations
        AnimationEasingStyle = Enum.EasingStyle.Quart,
        AnimationEasingDirection = Enum.EasingDirection.Out,
        
        -- Text properties
        HeaderFont = Enum.Font.GothamBold,               -- Bold font for headers
        TextFont = Enum.Font.Gotham,                     -- Regular font for elements
        TextSize = 14,
        HeaderSize = 16,                                 -- Larger size for headers
        
        -- Notification properties
        NotificationDuration = 5,
        HoverAnimationDuration = 0.2,
    }
}

-- Local Variables
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- Local Functions
local function MakeDraggable(topBarObject, object)
    local Dragging = nil
    local DragInput = nil
    local DragStart = nil
    local StartPosition = nil
    
    local function Update(input)
        local Delta = input.Position - DragStart
        local Position = UDim2.new(StartPosition.X.Scale, StartPosition.X.Offset + Delta.X, StartPosition.Y.Scale, StartPosition.Y.Offset + Delta.Y)
        object.Position = Position
    end
    
    topBarObject.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            Dragging = true
            DragStart = input.Position
            StartPosition = object.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    Dragging = false
                end
            end)
        end
    end)
    
    topBarObject.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            DragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == DragInput and Dragging then
            Update(input)
        end
    end)
end

local function Tween(object, properties, duration, style, direction)
    duration = duration or SOLHub.Configuration.AnimationDuration
    style = style or SOLHub.Configuration.AnimationEasingStyle
    direction = direction or SOLHub.Configuration.AnimationEasingDirection
    
    local tween = TweenService:Create(
        object,
        TweenInfo.new(duration, style, direction),
        properties
    )
    tween:Play()
    return tween
end

local function CreateElement(elementType, properties)
    local element = Instance.new(elementType)
    
    -- Special handling for UIStroke in the mock environment
    if elementType == "UIStroke" then
        if properties.ApplyStrokeMode == nil then
            properties.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        end
    end
    
    for property, value in pairs(properties) do
        pcall(function()
            element[property] = value
        end)
    end
    
    return element
end

local function RoundNumber(number, decimalPlaces)
    local shift = 10 ^ decimalPlaces
    return math.floor(number * shift + 0.5) / shift
end

-- Create UI components
function SOLHub:CreateWindow(config)
    config = config or {}
    local windowConfig = {
        Title = config.Title or "SOLHub",
        SubTitle = config.SubTitle or "Cyberpunk UI Library",
        ConfigurationSaving = config.ConfigurationSaving or {
            Enabled = false,
            FolderName = nil,
            FileName = "SOLHubConfig"
        },
        KeySystem = config.KeySystem or false,
        KeySettings = config.KeySettings or {
            Title = "SOLHub Key System",
            Subtitle = "Key System",
            Note = "No method of obtaining the key is provided",
            Key = {"Hello", "World"}
        }
    }
    
    local ScreenGui
    if syn and syn.protect_gui then
        ScreenGui = Instance.new("ScreenGui")
        syn.protect_gui(ScreenGui)
        ScreenGui.Parent = CoreGui
    elseif gethui then
        ScreenGui = Instance.new("ScreenGui")
        ScreenGui.Parent = gethui()
    else
        ScreenGui = Instance.new("ScreenGui")
        ScreenGui.Parent = CoreGui
    end
    
    ScreenGui.Name = "SOLHub_" .. windowConfig.Title
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.ResetOnSpawn = false
    
    -- Main Window Frame
    local MainFrame = CreateElement("Frame", {
        Name = "MainFrame",
        Parent = ScreenGui,
        BackgroundColor3 = SOLHub.Theme.Background,
        BorderSizePixel = 0,
        Position = UDim2.new(0.5, -SOLHub.Configuration.WindowSize.X.Offset / 2, 0.5, -SOLHub.Configuration.WindowSize.Y.Offset / 2),
        Size = SOLHub.Configuration.WindowSize,
        ClipsDescendants = true
    })
    
    local UICorner = CreateElement("UICorner", {
        Parent = MainFrame,
        CornerRadius = UDim.new(0, SOLHub.Configuration.UICorner)
    })
    
    local Glow = CreateElement("ImageLabel", {
        Name = "Glow",
        Parent = MainFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, -15, 0, -15),
        Size = UDim2.new(1, 30, 1, 30),
        ZIndex = 0,
        Image = "rbxassetid://5028857084",
        ImageColor3 = SOLHub.Theme.AccentColor,
        ImageTransparency = 0.5,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(24, 24, 276, 276)
    })
    
    -- TopBar
    local TopBar = CreateElement("Frame", {
        Name = "TopBar",
        Parent = MainFrame,
        BackgroundColor3 = SOLHub.Theme.DarkContrast,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 40)
    })
    
    local UICornerTopBar = CreateElement("UICorner", {
        Parent = TopBar,
        CornerRadius = UDim.new(0, SOLHub.Configuration.UICorner)
    })
    
    local TopBarGradient = CreateElement("UIGradient", {
        Parent = TopBar,
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 30, 40)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 15, 25))
        }),
        Rotation = 90
    })
    
    local TitleText = CreateElement("TextLabel", {
        Name = "Title",
        Parent = TopBar,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 12, 0, 0),
        Size = UDim2.new(0.5, -20, 1, 0),
        Font = SOLHub.Configuration.TextFont,
        Text = windowConfig.Title,
        TextColor3 = SOLHub.Theme.TextColor,
        TextSize = 18,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    local SubTitleText = CreateElement("TextLabel", {
        Name = "SubTitle",
        Parent = TopBar,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 12, 0.65, 0),
        Size = UDim2.new(0.5, -20, 0.35, 0),
        Font = Enum.Font.Gotham,
        Text = windowConfig.SubTitle,
        TextColor3 = Color3.fromRGB(180, 180, 190),
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    -- Cyberpunk-style neon line under the title bar
    local NeonLine = CreateElement("Frame", {
        Name = "NeonLine",
        Parent = TopBar,
        BackgroundColor3 = SOLHub.Theme.AccentColor,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 1, 0),
        Size = UDim2.new(1, 0, 0, 1),
        ZIndex = 3
    })
    
    -- Add glow effect to the neon line
    local NeonGlow = CreateElement("ImageLabel", {
        Name = "NeonGlow",
        Parent = NeonLine,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, -5, 0, -5),
        Size = UDim2.new(1, 10, 0, 10),
        Image = "rbxassetid://5028857084",
        ImageColor3 = SOLHub.Theme.AccentColor,
        ImageTransparency = 0.3
    })
    
    -- Make the neon line glow effect
    spawn(function()
        local iteration = 0
        while MainFrame.Parent do
            local hue = tick() % 10 / 10
            local rainbow = Color3.fromHSV(hue, 0.8, 1)
            Tween(NeonLine, {BackgroundColor3 = rainbow}, 1)
            Tween(NeonGlow, {ImageColor3 = rainbow}, 1)
            wait(0.5)
            
            -- For demo environment, limit iterations
            if _G.DEMO_MAX_ITERATIONS then
                iteration = iteration + 1
                if iteration >= _G.DEMO_MAX_ITERATIONS then
                    print("Demo: Neon effect loop limited to " .. _G.DEMO_MAX_ITERATIONS .. " iterations")
                    break
                end
            end
        end
    end)
    
    -- Close Button
    local CloseButton = CreateElement("ImageButton", {
        Name = "CloseButton",
        Parent = TopBar,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -30, 0.5, -10),
        Size = UDim2.new(0, 20, 0, 20),
        Image = "rbxassetid://6031094678",
        ImageColor3 = Color3.fromRGB(180, 180, 190)
    })
    
    CloseButton.MouseEnter:Connect(function()
        Tween(CloseButton, {ImageColor3 = SOLHub.Theme.AccentColor2})
    end)
    
    CloseButton.MouseLeave:Connect(function()
        Tween(CloseButton, {ImageColor3 = Color3.fromRGB(180, 180, 190)})
    end)
    
    CloseButton.MouseButton1Click:Connect(function()
        Tween(MainFrame, {Size = UDim2.new(0, SOLHub.Configuration.WindowSize.X.Offset, 0, 0)}, 0.5)
        Tween(Glow, {ImageTransparency = 1}, 0.5)
        wait(0.5)
        ScreenGui:Destroy()
    end)
    
    -- Make window draggable
    MakeDraggable(TopBar, MainFrame)
    
    -- TabContainer
    local TabContainer = CreateElement("Frame", {
        Name = "TabContainer",
        Parent = MainFrame,
        BackgroundColor3 = SOLHub.Theme.DarkContrast,
        BorderSizePixel = 0,
        Position = UDim2.new(0, SOLHub.Configuration.WindowPadding, 0, 50),
        Size = UDim2.new(0, 140, 1, -(50 + SOLHub.Configuration.WindowPadding)),
        ZIndex = 2
    })
    
    local UICornerTabContainer = CreateElement("UICorner", {
        Parent = TabContainer,
        CornerRadius = UDim.new(0, SOLHub.Configuration.UICorner)
    })
    
    local TabContainerPadding = CreateElement("UIPadding", {
        Parent = TabContainer,
        PaddingBottom = UDim.new(0, SOLHub.Configuration.WindowPadding),
        PaddingLeft = UDim.new(0, SOLHub.Configuration.WindowPadding),
        PaddingRight = UDim.new(0, SOLHub.Configuration.WindowPadding),
        PaddingTop = UDim.new(0, SOLHub.Configuration.WindowPadding)
    })
    
    local TabList = CreateElement("ScrollingFrame", {
        Name = "TabList",
        Parent = TabContainer,
        Active = true,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 1, 0),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = SOLHub.Theme.AccentColor,
        VerticalScrollBarPosition = Enum.VerticalScrollBarPosition.Right
    })
    
    local TabListLayout = CreateElement("UIListLayout", {
        Parent = TabList,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, SOLHub.Configuration.TabPadding)
    })
    
    -- Content Container
    local ContentContainer = CreateElement("Frame", {
        Name = "ContentContainer",
        Parent = MainFrame,
        BackgroundColor3 = SOLHub.Theme.DarkContrast,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 140 + SOLHub.Configuration.WindowPadding * 2, 0, 50),
        Size = UDim2.new(1, -(140 + SOLHub.Configuration.WindowPadding * 3), 1, -(50 + SOLHub.Configuration.WindowPadding)),
        ZIndex = 2
    })
    
    local UICornerContent = CreateElement("UICorner", {
        Parent = ContentContainer,
        CornerRadius = UDim.new(0, SOLHub.Configuration.UICorner)
    })
    
    local ContentContainerPadding = CreateElement("UIPadding", {
        Parent = ContentContainer,
        PaddingBottom = UDim.new(0, SOLHub.Configuration.WindowPadding),
        PaddingLeft = UDim.new(0, SOLHub.Configuration.WindowPadding),
        PaddingRight = UDim.new(0, SOLHub.Configuration.WindowPadding),
        PaddingTop = UDim.new(0, SOLHub.Configuration.WindowPadding)
    })
    
    -- Tab System Logic
    local Window = {}
    local Tabs = {}
    local ActiveTab = nil
    
    function Window:CreateTab(tabConfig)
        tabConfig = tabConfig or {}
        local tabInfo = {
            Name = tabConfig.Name or "Tab",
            Icon = tabConfig.Icon
        }
        
        -- Create Tab Button
        local TabButton = CreateElement("TextButton", {
            Name = tabInfo.Name .. "Button",
            Parent = TabList,
            BackgroundColor3 = SOLHub.Theme.ElementBackground,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, SOLHub.Configuration.TabHeight),
            Text = "",
            AutoButtonColor = false
        })
        
        local UICornerTabButton = CreateElement("UICorner", {
            Parent = TabButton,
            CornerRadius = UDim.new(0, SOLHub.Configuration.UICorner)
        })
        
        local TabIcon = nil
        if tabInfo.Icon then
            TabIcon = CreateElement("ImageLabel", {
                Name = "Icon",
                Parent = TabButton,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0.5, -10),
                Size = UDim2.new(0, 20, 0, 20),
                Image = tabInfo.Icon,
                ImageColor3 = SOLHub.Theme.TextColor
            })
        end
        
        local TabText = CreateElement("TextLabel", {
            Name = "TabName",
            Parent = TabButton,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, tabInfo.Icon and 40 or 10, 0, 0),
            Size = UDim2.new(1, tabInfo.Icon and -50 or -20, 1, 0),
            Font = SOLHub.Configuration.TextFont,
            Text = tabInfo.Name,
            TextColor3 = SOLHub.Theme.TextColor,
            TextSize = SOLHub.Configuration.TextSize,
            TextXAlignment = Enum.TextXAlignment.Left
        })
        
        -- Create Tab Content
        local TabContent = CreateElement("ScrollingFrame", {
            Name = tabInfo.Name .. "Content",
            Parent = ContentContainer,
            Active = true,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 1, 0),
            CanvasSize = UDim2.new(0, 0, 0, 0),
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = SOLHub.Theme.AccentColor,
            Visible = false
        })
        
        local ElementList = CreateElement("UIListLayout", {
            Parent = TabContent,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, SOLHub.Configuration.ElementPadding)
        })
        
        -- Update Canvas Size function
        local function UpdateCanvasSize()
            TabContent.CanvasSize = UDim2.new(0, 0, 0, ElementList.AbsoluteContentSize.Y + SOLHub.Configuration.WindowPadding)
        end
        
        ElementList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(UpdateCanvasSize)
        
        -- Tab Selection Logic
        TabButton.MouseEnter:Connect(function()
            if TabContent ~= ActiveTab then
                Tween(TabButton, {BackgroundColor3 = SOLHub.Theme.ElementBorder})
            end
        end)
        
        TabButton.MouseLeave:Connect(function()
            if TabContent ~= ActiveTab then
                Tween(TabButton, {BackgroundColor3 = SOLHub.Theme.ElementBackground})
            end
        end)
        
        TabButton.MouseButton1Click:Connect(function()
            if TabContent ~= ActiveTab then
                -- Deactivate current tab
                if ActiveTab then
                    ActiveTab.Visible = false
                    local activeTabButton = TabList:FindFirstChild(ActiveTab.Name:gsub("Content", "Button"))
                    if activeTabButton then
                        Tween(activeTabButton, {BackgroundColor3 = SOLHub.Theme.ElementBackground})
                    end
                end
                
                -- Activate new tab
                ActiveTab = TabContent
                TabContent.Visible = true
                Tween(TabButton, {BackgroundColor3 = SOLHub.Theme.AccentColor})
                
                -- Update accent color on tab button
                if TabIcon then
                    Tween(TabIcon, {ImageColor3 = Color3.new(1, 1, 1)})
                end
                Tween(TabText, {TextColor3 = Color3.new(1, 1, 1)})
            end
        end)
        
        -- Tab Methods
        local Tab = {}
        
        function Tab:CreateSection(sectionConfig)
            sectionConfig = sectionConfig or {}
            local sectionInfo = {
                Name = sectionConfig.Name or "Section",
                ContentPadding = sectionConfig.ContentPadding or SOLHub.Configuration.ElementPadding
            }
            
            local SectionContainer = CreateElement("Frame", {
                Name = sectionInfo.Name .. "Section",
                Parent = TabContent,
                BackgroundColor3 = SOLHub.Theme.ElementBackground,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 40) -- Initial size, will be updated
                -- AutomaticSize is mocked in the demo environment
            })
            
            local UICornerSection = CreateElement("UICorner", {
                Parent = SectionContainer,
                CornerRadius = UDim.new(0, SOLHub.Configuration.UICorner)
            })
            
            local SectionTitle = CreateElement("TextLabel", {
                Name = "Title",
                Parent = SectionContainer,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 5),
                Size = UDim2.new(1, -20, 0, 30),
                Font = SOLHub.Configuration.TextFont,
                Text = sectionInfo.Name,
                TextColor3 = SOLHub.Theme.TextColor,
                TextSize = SOLHub.Configuration.TextSize + 2,
                TextXAlignment = Enum.TextXAlignment.Left
            })
            
            -- Cyberpunk-style neon line under section title
            local SectionNeonLine = CreateElement("Frame", {
                Name = "NeonLine",
                Parent = SectionTitle,
                BackgroundColor3 = SOLHub.Theme.AccentColor,
                BorderSizePixel = 0,
                Position = UDim2.new(0, 0, 1, 0),
                Size = UDim2.new(0, 30, 0, 1),
                ZIndex = 3
            })
            
            -- Add subtle glow effect to the section neon line
            local SectionNeonGlow = CreateElement("ImageLabel", {
                Name = "NeonGlow",
                Parent = SectionNeonLine,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, -3, 0, -3),
                Size = UDim2.new(1, 6, 0, 6),
                Image = "rbxassetid://5028857084",
                ImageColor3 = SOLHub.Theme.AccentColor,
                ImageTransparency = 0.3
            })
            
            local SectionContent = CreateElement("Frame", {
                Name = "Content",
                Parent = SectionContainer,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 0, 0, 40),
                Size = UDim2.new(1, 0, 0, 0)
                -- AutomaticSize is mocked in the demo environment
            })
            
            local SectionPadding = CreateElement("UIPadding", {
                Parent = SectionContent,
                PaddingBottom = UDim.new(0, 10),
                PaddingLeft = UDim.new(0, 10),
                PaddingRight = UDim.new(0, 10),
                PaddingTop = UDim.new(0, 0)
            })
            
            local SectionLayout = CreateElement("UIListLayout", {
                Parent = SectionContent,
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, sectionInfo.ContentPadding)
            })
            
            -- Update Canvas Size when section content changes
            SectionLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                UpdateCanvasSize()
            end)
            
            -- Section Methods
            local Section = {}
            
            function Section:AddButton(config)
                config = config or {}
                local buttonConfig = {
                    Name = config.Name or "Button",
                    Callback = config.Callback or function() end
                }
                
                -- Clean, minimal button based on reference image
                local Button = CreateElement("Frame", {
                    Name = buttonConfig.Name .. "Button",
                    Parent = SectionContent,
                    BackgroundColor3 = SOLHub.Theme.ElementBackground,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 0, SOLHub.Configuration.ElementHeight)
                })
                
                local UICornerButton = CreateElement("UICorner", {
                    Parent = Button,
                    CornerRadius = UDim.new(0, SOLHub.Configuration.ElementCorner)
                })
                
                -- Remove border stroke for cleaner look
                
                local ButtonTitle = CreateElement("TextLabel", {
                    Name = "Title",
                    Parent = Button,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 15, 0, 0),  -- More left padding
                    Size = UDim2.new(1, -30, 1, 0),
                    Font = SOLHub.Configuration.TextFont,
                    Text = buttonConfig.Name,
                    TextColor3 = SOLHub.Theme.TextColor,
                    TextSize = SOLHub.Configuration.TextSize,
                    TextXAlignment = Enum.TextXAlignment.Center  -- Center-aligned text
                })
                
                local ButtonClickArea = CreateElement("TextButton", {
                    Name = "ClickArea",
                    Parent = Button,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    Text = "",
                    ZIndex = 5
                })
                
                -- Clean, modern hover interaction
                ButtonClickArea.MouseEnter:Connect(function()
                    -- Darken background on hover
                    Tween(Button, {BackgroundColor3 = Color3.fromRGB(30, 30, 40)}, SOLHub.Configuration.HoverAnimationDuration)
                    Tween(ButtonTitle, {TextColor3 = SOLHub.Theme.AccentColor}, SOLHub.Configuration.HoverAnimationDuration)
                end)
                
                ButtonClickArea.MouseLeave:Connect(function()
                    -- Return to original colors
                    Tween(Button, {BackgroundColor3 = SOLHub.Theme.ElementBackground}, SOLHub.Configuration.HoverAnimationDuration)
                    Tween(ButtonTitle, {TextColor3 = SOLHub.Theme.TextColor}, SOLHub.Configuration.HoverAnimationDuration)
                end)
                
                -- Cyberpunk-style click effect
                ButtonClickArea.MouseButton1Down:Connect(function()
                    -- Create a ripple effect
                    local Ripple = CreateElement("Frame", {
                        Name = "Ripple",
                        Parent = Button,
                        BackgroundColor3 = SOLHub.Theme.AccentColor,
                        BackgroundTransparency = 0.7,
                        BorderSizePixel = 0,
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        Position = UDim2.new(0.5, 0, 0.5, 0),
                        ZIndex = 2
                    })
                    
                    local RippleCorner = CreateElement("UICorner", {
                        Parent = Ripple,
                        CornerRadius = UDim.new(1, 0)
                    })
                    
                    -- Start small, expand to full button size
                    Ripple.Size = UDim2.new(0, 0, 0, 0)
                    local targetSize = UDim2.new(0, Button.AbsoluteSize.X * 1.5, 0, Button.AbsoluteSize.X * 1.5)
                    Tween(Ripple, {Size = targetSize, BackgroundTransparency = 1}, 0.5)
                    
                    -- Remove the ripple after animation completes
                    Debris:AddItem(Ripple, 0.5)
                end)
                
                ButtonClickArea.MouseButton1Click:Connect(function()
                    -- Execute callback
                    task.spawn(buttonConfig.Callback)
                end)
                
                return Button
            end
            
            function Section:AddToggle(config)
                config = config or {}
                local toggleConfig = {
                    Name = config.Name or "Toggle",
                    Default = config.Default or false,
                    Flag = config.Flag,
                    Callback = config.Callback or function() end
                }
                
                -- Main toggle container
                local Toggle = CreateElement("Frame", {
                    Name = toggleConfig.Name .. "Toggle",
                    Parent = SectionContent,
                    BackgroundColor3 = SOLHub.Theme.ElementBackground,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 0, SOLHub.Configuration.ElementHeight)
                })
                
                local UICornerToggle = CreateElement("UICorner", {
                    Parent = Toggle,
                    CornerRadius = UDim.new(0, SOLHub.Configuration.ElementCorner)
                })
                
                -- Remove the border stroke for a cleaner look
                -- Instead, use a slightly darker background
                
                -- Toggle label with more padding on the left
                local ToggleTitle = CreateElement("TextLabel", {
                    Name = "Title",
                    Parent = Toggle,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 15, 0, 0),
                    Size = UDim2.new(1, -60, 1, 0),
                    Font = SOLHub.Configuration.TextFont,
                    Text = toggleConfig.Name,
                    TextColor3 = SOLHub.Theme.TextColor,
                    TextSize = SOLHub.Configuration.TextSize,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                
                -- Circular toggle (simplified design based on reference)
                local ToggleCircle = CreateElement("Frame", {
                    Name = "Circle",
                    Parent = Toggle,
                    AnchorPoint = Vector2.new(1, 0.5),
                    BackgroundColor3 = SOLHub.Theme.ToggleDisabled,
                    BorderSizePixel = 0,
                    Position = UDim2.new(1, -15, 0.5, 0),
                    Size = UDim2.new(0, 22, 0, 22),
                    ZIndex = 3
                })
                
                local UICornerCircle = CreateElement("UICorner", {
                    Parent = ToggleCircle,
                    CornerRadius = UDim.new(1, 0)
                })
                
                -- Glow effect for the toggle
                local ToggleGlow = CreateElement("ImageLabel", {
                    Name = "Glow",
                    Parent = ToggleCircle,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, -5, 0, -5),
                    Size = UDim2.new(1, 10, 1, 10),
                    Image = "rbxassetid://5028857084",
                    ImageColor3 = SOLHub.Theme.AccentColor,
                    ImageTransparency = 1
                })
                
                -- Click area for the entire toggle
                local ToggleClickArea = CreateElement("TextButton", {
                    Name = "ClickArea",
                    Parent = Toggle,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    Text = "",
                    ZIndex = 5
                })
                
                -- Toggle State
                local Enabled = toggleConfig.Default
                
                -- Update toggle state visually (simplified for the new design)
                local function UpdateToggle()
                    if Enabled then
                        -- When enabled: cyan circle with glow
                        Tween(ToggleCircle, {BackgroundColor3 = SOLHub.Theme.ToggleEnabled})
                        Tween(ToggleGlow, {ImageTransparency = 0.7})
                    else
                        -- When disabled: dark gray circle without glow
                        Tween(ToggleCircle, {BackgroundColor3 = SOLHub.Theme.ToggleDisabled})
                        Tween(ToggleGlow, {ImageTransparency = 1})
                    end
                end
                
                -- Set initial state
                UpdateToggle()
                
                -- Set flag if provided
                if toggleConfig.Flag then
                    SOLHub.Flags[toggleConfig.Flag] = Enabled
                end
                
                -- Toggle Interaction
                ToggleClickArea.MouseEnter:Connect(function()
                    -- Subtle hover effect for the toggle
                    Tween(Toggle, {BackgroundColor3 = Color3.fromRGB(30, 30, 40)}, SOLHub.Configuration.HoverAnimationDuration)
                end)
                
                ToggleClickArea.MouseLeave:Connect(function()
                    -- Restore normal background color
                    Tween(Toggle, {BackgroundColor3 = SOLHub.Theme.ElementBackground}, SOLHub.Configuration.HoverAnimationDuration)
                end)
                
                ToggleClickArea.MouseButton1Click:Connect(function()
                    Enabled = not Enabled
                    UpdateToggle()
                    
                    -- Update flag if provided
                    if toggleConfig.Flag then
                        SOLHub.Flags[toggleConfig.Flag] = Enabled
                    end
                    
                    -- Call callback
                    task.spawn(function()
                        toggleConfig.Callback(Enabled)
                    end)
                end)
                
                -- Toggle Methods
                local ToggleApi = {}
                
                function ToggleApi:Set(value)
                    Enabled = value
                    UpdateToggle()
                    
                    -- Update flag if provided
                    if toggleConfig.Flag then
                        SOLHub.Flags[toggleConfig.Flag] = Enabled
                    end
                    
                    -- Call callback
                    task.spawn(function()
                        toggleConfig.Callback(Enabled)
                    end)
                end
                
                return ToggleApi
            end
            
            function Section:AddSlider(config)
                config = config or {}
                local sliderConfig = {
                    Name = config.Name or "Slider",
                    Min = config.Min or 0,
                    Max = config.Max or 100,
                    Default = config.Default or 50,
                    Increment = config.Increment or 1,
                    ValueName = config.ValueName or "",
                    Flag = config.Flag,
                    Callback = config.Callback or function() end
                }
                
                -- Make sure default value is within range and respects increment
                sliderConfig.Default = math.clamp(sliderConfig.Default, sliderConfig.Min, sliderConfig.Max)
                sliderConfig.Default = sliderConfig.Min + (math.floor((sliderConfig.Default - sliderConfig.Min) / sliderConfig.Increment + 0.5) * sliderConfig.Increment)
                
                -- Clean, minimal slider design based on reference image
                local Slider = CreateElement("Frame", {
                    Name = sliderConfig.Name .. "Slider",
                    Parent = SectionContent,
                    BackgroundColor3 = SOLHub.Theme.ElementBackground,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 0, SOLHub.Configuration.ElementHeight * 1.5)
                })
                
                local UICornerSlider = CreateElement("UICorner", {
                    Parent = Slider,
                    CornerRadius = UDim.new(0, SOLHub.Configuration.ElementCorner)
                })
                
                -- Removing the border stroke for a cleaner look
                
                local SliderTitle = CreateElement("TextLabel", {
                    Name = "Title",
                    Parent = Slider,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, 0),
                    Size = UDim2.new(1, -20, 0, SOLHub.Configuration.ElementHeight),
                    Font = SOLHub.Configuration.TextFont,
                    Text = sliderConfig.Name,
                    TextColor3 = SOLHub.Theme.TextColor,
                    TextSize = SOLHub.Configuration.TextSize,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                
                local SliderValue = CreateElement("TextLabel", {
                    Name = "Value",
                    Parent = Slider,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(1, -60, 0, 0),
                    Size = UDim2.new(0, 50, 0, SOLHub.Configuration.ElementHeight),
                    Font = SOLHub.Configuration.TextFont,
                    Text = tostring(sliderConfig.Default) .. " " .. sliderConfig.ValueName,
                    TextColor3 = SOLHub.Theme.TextColor,
                    TextSize = SOLHub.Configuration.TextSize,
                    TextXAlignment = Enum.TextXAlignment.Right
                })
                
                local SliderTrack = CreateElement("Frame", {
                    Name = "Track",
                    Parent = Slider,
                    BackgroundColor3 = SOLHub.Theme.LightContrast,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 10, 0, SOLHub.Configuration.ElementHeight + 2),
                    Size = UDim2.new(1, -20, 0, 6)
                })
                
                local UICornerTrack = CreateElement("UICorner", {
                    Parent = SliderTrack,
                    CornerRadius = UDim.new(1, 0)
                })
                
                local SliderFill = CreateElement("Frame", {
                    Name = "Fill",
                    Parent = SliderTrack,
                    BackgroundColor3 = SOLHub.Theme.AccentColor,
                    BorderSizePixel = 0,
                    Size = UDim2.new(0, 0, 1, 0)
                })
                
                local UICornerFill = CreateElement("UICorner", {
                    Parent = SliderFill,
                    CornerRadius = UDim.new(1, 0)
                })
                
                -- Add cyberpunk glow to the slider fill
                local SliderGlow = CreateElement("ImageLabel", {
                    Name = "Glow",
                    Parent = SliderFill,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, -2, 0, -2),
                    Size = UDim2.new(1, 4, 1, 4),
                    Image = "rbxassetid://5028857084",
                    ImageColor3 = SOLHub.Theme.AccentColor,
                    ImageTransparency = 0.5
                })
                
                local SliderButton = CreateElement("TextButton", {
                    Name = "Button",
                    Parent = Slider,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, SOLHub.Configuration.ElementHeight),
                    Size = UDim2.new(1, -20, 0, 10),
                    Text = ""
                })
                
                -- Slider functionality
                local Value = sliderConfig.Default
                local Dragging = false
                
                -- Update fill based on value
                local function UpdateSlider()
                    local Percent = (Value - sliderConfig.Min) / (sliderConfig.Max - sliderConfig.Min)
                    SliderFill.Size = UDim2.new(Percent, 0, 1, 0)
                    SliderValue.Text = tostring(RoundNumber(Value, 2)) .. " " .. sliderConfig.ValueName
                    
                    -- Update flag if provided
                    if sliderConfig.Flag then
                        SOLHub.Flags[sliderConfig.Flag] = Value
                    end
                    
                    -- Call callback
                    task.spawn(function()
                        sliderConfig.Callback(Value)
                    end)
                end
                
                -- Set initial fill
                UpdateSlider()
                
                -- Slider interaction with clean, modern design
                SliderButton.MouseButton1Down:Connect(function()
                    Dragging = true
                    -- Slightly darken slider on click
                    Tween(Slider, {BackgroundColor3 = Color3.fromRGB(30, 30, 40)}, SOLHub.Configuration.HoverAnimationDuration)
                end)
                
                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 and Dragging then
                        Dragging = false
                        -- Return to original color when released
                        Tween(Slider, {BackgroundColor3 = SOLHub.Theme.ElementBackground}, SOLHub.Configuration.HoverAnimationDuration)
                    end
                end)
                
                SliderButton.MouseEnter:Connect(function()
                    -- Subtle hover effect 
                    Tween(Slider, {BackgroundColor3 = Color3.fromRGB(30, 30, 40)}, SOLHub.Configuration.HoverAnimationDuration)
                end)
                
                SliderButton.MouseLeave:Connect(function()
                    if not Dragging then
                        -- Return to original color when mouse leaves
                        Tween(Slider, {BackgroundColor3 = SOLHub.Theme.ElementBackground}, SOLHub.Configuration.HoverAnimationDuration)
                    end
                end)
                
                -- Update value on mouse move
                UserInputService.InputChanged:Connect(function(input)
                    if Dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                        -- Calculate the new value based on mouse position
                        local MousePosition = UserInputService:GetMouseLocation()
                        local RelativePosition = (MousePosition.X - SliderTrack.AbsolutePosition.X) / SliderTrack.AbsoluteSize.X
                        RelativePosition = math.clamp(RelativePosition, 0, 1)
                        
                        -- Calculate value respecting increment
                        local NewValue = sliderConfig.Min + (RelativePosition * (sliderConfig.Max - sliderConfig.Min))
                        NewValue = sliderConfig.Min + (math.floor((NewValue - sliderConfig.Min) / sliderConfig.Increment + 0.5) * sliderConfig.Increment)
                        NewValue = math.clamp(NewValue, sliderConfig.Min, sliderConfig.Max)
                        
                        if NewValue ~= Value then
                            Value = NewValue
                            UpdateSlider()
                        end
                    end
                end)
                
                -- Slider API
                local SliderApi = {}
                
                function SliderApi:Set(value)
                    value = math.clamp(value, sliderConfig.Min, sliderConfig.Max)
                    value = sliderConfig.Min + (math.floor((value - sliderConfig.Min) / sliderConfig.Increment + 0.5) * sliderConfig.Increment)
                    Value = value
                    UpdateSlider()
                end
                
                function SliderApi:GetValue()
                    return Value
                end
                
                return SliderApi
            end
            
            function Section:AddDropdown(config)
                config = config or {}
                local dropdownConfig = {
                    Name = config.Name or "Dropdown",
                    Options = config.Options or {},
                    Default = config.Default,
                    Flag = config.Flag,
                    Callback = config.Callback or function() end,
                    MultiSelection = config.MultiSelection or false
                }
                
                -- Validate default value(s)
                local DefaultOption = nil
                local SelectedOptions = {}
                
                if dropdownConfig.MultiSelection then
                    if dropdownConfig.Default and type(dropdownConfig.Default) == "table" then
                        for _, option in pairs(dropdownConfig.Default) do
                            for _, validOption in pairs(dropdownConfig.Options) do
                                if option == validOption then
                                    SelectedOptions[option] = true
                                    break
                                end
                            end
                        end
                    end
                else
                    if dropdownConfig.Default then
                        for _, option in pairs(dropdownConfig.Options) do
                            if option == dropdownConfig.Default then
                                DefaultOption = option
                                break
                            end
                        end
                    end
                    if not DefaultOption and #dropdownConfig.Options > 0 then
                        DefaultOption = dropdownConfig.Options[1]
                    end
                end
                
                -- Create clean, minimal Dropdown based on reference image
                local Dropdown = CreateElement("Frame", {
                    Name = dropdownConfig.Name .. "Dropdown",
                    Parent = SectionContent,
                    BackgroundColor3 = SOLHub.Theme.ElementBackground,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 0, SOLHub.Configuration.ElementHeight),
                    ClipsDescendants = true
                })
                
                local UICornerDropdown = CreateElement("UICorner", {
                    Parent = Dropdown,
                    CornerRadius = UDim.new(0, SOLHub.Configuration.ElementCorner)
                })
                
                -- Remove border stroke for a cleaner look
                
                local DropdownTitle = CreateElement("TextLabel", {
                    Name = "Title",
                    Parent = Dropdown,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, 0),
                    Size = UDim2.new(1, -40, 0, SOLHub.Configuration.ElementHeight),
                    Font = SOLHub.Configuration.TextFont,
                    Text = dropdownConfig.Name,
                    TextColor3 = SOLHub.Theme.TextColor,
                    TextSize = SOLHub.Configuration.TextSize,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                
                local DropdownSelection = CreateElement("TextLabel", {
                    Name = "Selection",
                    Parent = Dropdown,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, SOLHub.Configuration.ElementHeight),
                    Size = UDim2.new(1, -20, 0, SOLHub.Configuration.ElementHeight),
                    Font = SOLHub.Configuration.TextFont,
                    Text = DefaultOption or "Select option...",
                    TextColor3 = SOLHub.Theme.TextColor,
                    TextSize = SOLHub.Configuration.TextSize,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                
                local DropdownArrow = CreateElement("ImageLabel", {
                    Name = "Arrow",
                    Parent = Dropdown,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(1, -25, 0, SOLHub.Configuration.ElementHeight/2 - 7.5),
                    Size = UDim2.new(0, 15, 0, 15),
                    Image = "rbxassetid://6031091004",
                    ImageColor3 = SOLHub.Theme.TextColor,
                    Rotation = 0
                })
                
                local DropdownButton = CreateElement("TextButton", {
                    Name = "Button",
                    Parent = Dropdown,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, SOLHub.Configuration.ElementHeight),
                    Text = ""
                })
                
                local DropdownContent = CreateElement("ScrollingFrame", {
                    Name = "Content",
                    Parent = Dropdown,
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 0, 0, SOLHub.Configuration.ElementHeight),
                    Size = UDim2.new(1, 0, 0, 0),
                    CanvasSize = UDim2.new(0, 0, 0, 0),
                    ScrollBarThickness = 3,
                    ScrollBarImageColor3 = SOLHub.Theme.AccentColor,
                    Visible = false
                })
                
                local DropdownContentLayout = CreateElement("UIListLayout", {
                    Parent = DropdownContent,
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Padding = UDim.new(0, 2)
                })
                
                local DropdownContentPadding = CreateElement("UIPadding", {
                    Parent = DropdownContent,
                    PaddingLeft = UDim.new(0, 5),
                    PaddingRight = UDim.new(0, 5),
                    PaddingTop = UDim.new(0, 5),
                    PaddingBottom = UDim.new(0, 5)
                })
                
                -- Populate dropdown options
                local function AddOption(option)
                    local OptionButton = CreateElement("TextButton", {
                        Name = option .. "Option",
                        Parent = DropdownContent,
                        BackgroundColor3 = SOLHub.Theme.ElementBackground,
                        BorderSizePixel = 0,
                        Size = UDim2.new(1, 0, 0, SOLHub.Configuration.ElementHeight - 10),
                        Font = SOLHub.Configuration.TextFont,
                        Text = option,
                        TextColor3 = SOLHub.Theme.TextColor,
                        TextSize = SOLHub.Configuration.TextSize,
                        AutoButtonColor = false
                    })
                    
                    local UICornerOption = CreateElement("UICorner", {
                        Parent = OptionButton,
                        CornerRadius = UDim.new(0, SOLHub.Configuration.UICorner)
                    })
                    
                    local isSelected = false
                    
                    if dropdownConfig.MultiSelection then
                        isSelected = SelectedOptions[option] == true
                    else
                        isSelected = option == DefaultOption
                    end
                    
                    -- Show selection for default values
                    if isSelected then
                        OptionButton.BackgroundColor3 = SOLHub.Theme.AccentColor
                        OptionButton.TextColor3 = Color3.fromRGB(255, 255, 255)
                    end
                    
                    -- Option interaction
                    OptionButton.MouseEnter:Connect(function()
                        if not isSelected then
                            Tween(OptionButton, {BackgroundColor3 = SOLHub.Theme.ElementBorder}, SOLHub.Configuration.HoverAnimationDuration)
                        end
                    end)
                    
                    OptionButton.MouseLeave:Connect(function()
                        if not isSelected then
                            Tween(OptionButton, {BackgroundColor3 = SOLHub.Theme.ElementBackground}, SOLHub.Configuration.HoverAnimationDuration)
                        end
                    end)
                    
                    OptionButton.MouseButton1Click:Connect(function()
                        if dropdownConfig.MultiSelection then
                            -- Toggle selection for this option
                            isSelected = not isSelected
                            SelectedOptions[option] = isSelected or nil
                            
                            -- Update visual
                            if isSelected then
                                Tween(OptionButton, {BackgroundColor3 = SOLHub.Theme.AccentColor, TextColor3 = Color3.fromRGB(255, 255, 255)})
                            else
                                Tween(OptionButton, {BackgroundColor3 = SOLHub.Theme.ElementBackground, TextColor3 = SOLHub.Theme.TextColor})
                            end
                            
                            -- Update selection text
                            local selectedCount = 0
                            local selectedList = {}
                            for opt, selected in pairs(SelectedOptions) do
                                if selected then
                                    selectedCount = selectedCount + 1
                                    table.insert(selectedList, opt)
                                end
                            end
                            
                            if selectedCount == 0 then
                                DropdownSelection.Text = "None selected"
                            elseif selectedCount <= 2 then
                                DropdownSelection.Text = table.concat(selectedList, ", ")
                            else
                                DropdownSelection.Text = selectedCount .. " options selected"
                            end
                            
                            -- Update flag and call callback
                            if dropdownConfig.Flag then
                                SOLHub.Flags[dropdownConfig.Flag] = selectedList
                            end
                            task.spawn(function()
                                dropdownConfig.Callback(selectedList)
                            end)
                            
                        else
                            -- Single selection - deselect old, select new
                            for _, child in pairs(DropdownContent:GetChildren()) do
                                if child:IsA("TextButton") and child ~= OptionButton then
                                    Tween(child, {BackgroundColor3 = SOLHub.Theme.ElementBackground, TextColor3 = SOLHub.Theme.TextColor})
                                end
                            end
                            
                            isSelected = true
                            DefaultOption = option
                            DropdownSelection.Text = option
                            Tween(OptionButton, {BackgroundColor3 = SOLHub.Theme.AccentColor, TextColor3 = Color3.fromRGB(255, 255, 255)})
                            
                            -- Update flag and call callback
                            if dropdownConfig.Flag then
                                SOLHub.Flags[dropdownConfig.Flag] = option
                            end
                            task.spawn(function()
                                dropdownConfig.Callback(option)
                            end)
                            
                            -- Close dropdown after selection for single selection mode
                            CloseDropdown()
                        end
                    end)
                    
                    return OptionButton
                end
                
                for _, option in pairs(dropdownConfig.Options) do
                    AddOption(option)
                end
                
                -- Adjust content canvas size
                DropdownContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                    DropdownContent.CanvasSize = UDim2.new(0, 0, 0, DropdownContentLayout.AbsoluteContentSize.Y + 10)
                end)
                
                -- Dropdown open/close functionality
                local IsOpen = false
                
                -- Function to close the dropdown
                function CloseDropdown()
                    IsOpen = false
                    Tween(Dropdown, {Size = UDim2.new(1, 0, 0, SOLHub.Configuration.ElementHeight)})
                    Tween(DropdownArrow, {Rotation = 0})
                    DropdownContent.Visible = false
                end
                
                -- Open/close dropdown on button click
                DropdownButton.MouseButton1Click:Connect(function()
                    IsOpen = not IsOpen
                    
                    if IsOpen then
                        -- Calculate content height (limited to 150px)
                        local contentHeight = math.min(DropdownContentLayout.AbsoluteContentSize.Y + 10, 150)
                        Tween(Dropdown, {Size = UDim2.new(1, 0, 0, SOLHub.Configuration.ElementHeight + contentHeight + 5)})
                        Tween(DropdownArrow, {Rotation = 180})
                        DropdownContent.Size = UDim2.new(1, 0, 0, contentHeight)
                        DropdownContent.Visible = true
                    else
                        CloseDropdown()
                    end
                end)
                
                -- Hover effect for button with cleaner style
                DropdownButton.MouseEnter:Connect(function()
                    -- Slightly darken background on hover
                    Tween(Dropdown, {BackgroundColor3 = Color3.fromRGB(30, 30, 40)}, SOLHub.Configuration.HoverAnimationDuration)
                end)
                
                DropdownButton.MouseLeave:Connect(function()
                    -- Return to original color when not hovering
                    Tween(Dropdown, {BackgroundColor3 = SOLHub.Theme.ElementBackground}, SOLHub.Configuration.HoverAnimationDuration)
                end)
                
                -- Close dropdown when clicking elsewhere
                UserInputService.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        local absPos = Dropdown.AbsolutePosition
                        local absSize = Dropdown.AbsoluteSize
                        local mousePos = UserInputService:GetMouseLocation()
                        
                        if IsOpen and (mousePos.X < absPos.X or mousePos.X > absPos.X + absSize.X or mousePos.Y < absPos.Y or mousePos.Y > absPos.Y + absSize.Y) then
                            CloseDropdown()
                        end
                    end
                end)
                
                -- Set initial values for flag
                if dropdownConfig.Flag then
                    if dropdownConfig.MultiSelection then
                        local selectedList = {}
                        for option, selected in pairs(SelectedOptions) do
                            if selected then
                                table.insert(selectedList, option)
                            end
                        end
                        SOLHub.Flags[dropdownConfig.Flag] = selectedList
                    else
                        SOLHub.Flags[dropdownConfig.Flag] = DefaultOption
                    end
                end
                
                -- Set initial selection text for multi-selection
                if dropdownConfig.MultiSelection then
                    local selectedCount = 0
                    local selectedList = {}
                    for option, selected in pairs(SelectedOptions) do
                        if selected then
                            selectedCount = selectedCount + 1
                            table.insert(selectedList, option)
                        end
                    end
                    
                    if selectedCount == 0 then
                        DropdownSelection.Text = "None selected"
                    elseif selectedCount <= 2 then
                        DropdownSelection.Text = table.concat(selectedList, ", ")
                    else
                        DropdownSelection.Text = selectedCount .. " options selected"
                    end
                end
                
                -- Dropdown API
                local DropdownApi = {}
                
                function DropdownApi:Set(value)
                    if dropdownConfig.MultiSelection and type(value) == "table" then
                        -- Clear current selections
                        SelectedOptions = {}
                        
                        -- Update each option
                        for _, child in pairs(DropdownContent:GetChildren()) do
                            if child:IsA("TextButton") then
                                local optionName = child.Text
                                local selected = false
                                
                                -- Check if this option is in the value table
                                for _, selectedOption in pairs(value) do
                                    if optionName == selectedOption then
                                        selected = true
                                        SelectedOptions[optionName] = true
                                        break
                                    end
                                end
                                
                                -- Update visual
                                if selected then
                                    Tween(child, {BackgroundColor3 = SOLHub.Theme.AccentColor, TextColor3 = Color3.fromRGB(255, 255, 255)})
                                else
                                    Tween(child, {BackgroundColor3 = SOLHub.Theme.ElementBackground, TextColor3 = SOLHub.Theme.TextColor})
                                end
                            end
                        end
                        
                        -- Update selection text
                        local selectedCount = 0
                        local selectedList = {}
                        for option, selected in pairs(SelectedOptions) do
                            if selected then
                                selectedCount = selectedCount + 1
                                table.insert(selectedList, option)
                            end
                        end
                        
                        if selectedCount == 0 then
                            DropdownSelection.Text = "None selected"
                        elseif selectedCount <= 2 then
                            DropdownSelection.Text = table.concat(selectedList, ", ")
                        else
                            DropdownSelection.Text = selectedCount .. " options selected"
                        end
                        
                        -- Update flag and call callback
                        if dropdownConfig.Flag then
                            SOLHub.Flags[dropdownConfig.Flag] = selectedList
                        end
                        task.spawn(function()
                            dropdownConfig.Callback(selectedList)
                        end)
                        
                    elseif not dropdownConfig.MultiSelection and type(value) == "string" then
                        -- Update the dropdown value directly without needing to access children
                        DefaultOption = value
                        DropdownSelection.Text = value
                        
                        -- Update flag and call callback
                        if dropdownConfig.Flag then
                            SOLHub.Flags[dropdownConfig.Flag] = value
                        end
                        task.spawn(function()
                            dropdownConfig.Callback(value)
                        end)
                                
                        -- Skip attempting to iterate through children in mock environment
                        if DropdownContent.ClassName ~= "MockScrollingFrame" then
                            -- Find the option and simulate a click
                            for _, child in pairs(DropdownContent:GetChildren()) do
                                if child:IsA("TextButton") and child.Text == value then
                                    -- Deselect all options
                                    for _, otherChild in pairs(DropdownContent:GetChildren()) do
                                        if otherChild:IsA("TextButton") then
                                            Tween(otherChild, {BackgroundColor3 = SOLHub.Theme.ElementBackground, TextColor3 = SOLHub.Theme.TextColor})
                                        end
                                    end
                                
                                    -- Select this option
                                    Tween(child, {BackgroundColor3 = SOLHub.Theme.AccentColor, TextColor3 = Color3.fromRGB(255, 255, 255)})
                                    break
                                end
                            end
                        end
                    end
                end
                
                function DropdownApi:Refresh(options, keepSelection)
                    dropdownConfig.Options = options
                    
                    -- Skip children manipulation in mock environment
                    if DropdownContent.ClassName == "MockScrollingFrame" then
                        -- Just update the options data
                        return
                    end
                    
                    -- Clear current options
                    for _, child in pairs(DropdownContent:GetChildren()) do
                        if child:IsA("TextButton") then
                            child:Destroy()
                        end
                    end
                    
                    -- Track old selections if keeping them
                    local oldSelectedOptions = {}
                    if keepSelection then
                        if dropdownConfig.MultiSelection then
                            oldSelectedOptions = SelectedOptions
                        else
                            oldSelectedOptions[DefaultOption] = true
                        end
                    end
                    
                    -- Reset selection data
                    SelectedOptions = {}
                    DefaultOption = nil
                    
                    -- Add new options and restore selections if keeping them
                    for _, option in pairs(options) do
                        if keepSelection and oldSelectedOptions[option] then
                            if dropdownConfig.MultiSelection then
                                SelectedOptions[option] = true
                            else
                                DefaultOption = option
                            end
                        end
                        
                        -- Skip AddOption in mock environment
                        if DropdownContent.ClassName ~= "MockScrollingFrame" then
                            AddOption(option)
                        end
                    end
                    
                    -- Update selection text
                    if dropdownConfig.MultiSelection then
                        local selectedCount = 0
                        local selectedList = {}
                        for option, selected in pairs(SelectedOptions) do
                            if selected then
                                selectedCount = selectedCount + 1
                                table.insert(selectedList, option)
                            end
                        end
                        
                        if selectedCount == 0 then
                            DropdownSelection.Text = "None selected"
                        elseif selectedCount <= 2 then
                            DropdownSelection.Text = table.concat(selectedList, ", ")
                        else
                            DropdownSelection.Text = selectedCount .. " options selected"
                        end
                    else
                        DropdownSelection.Text = DefaultOption or "Select option..."
                    end
                    
                    -- Update flag
                    if dropdownConfig.Flag then
                        if dropdownConfig.MultiSelection then
                            local selectedList = {}
                            for option, selected in pairs(SelectedOptions) do
                                if selected then
                                    table.insert(selectedList, option)
                                end
                            end
                            SOLHub.Flags[dropdownConfig.Flag] = selectedList
                        else
                            SOLHub.Flags[dropdownConfig.Flag] = DefaultOption
                        end
                    end
                end
                
                return DropdownApi
            end
            
            function Section:AddColorPicker(config)
                config = config or {}
                local colorConfig = {
                    Name = config.Name or "Color Picker",
                    Default = config.Default or Color3.fromRGB(255, 255, 255),
                    Flag = config.Flag,
                    Callback = config.Callback or function() end
                }
                
                local ColorPicker = CreateElement("Frame", {
                    Name = colorConfig.Name .. "ColorPicker",
                    Parent = SectionContent,
                    BackgroundColor3 = SOLHub.Theme.ElementBackground,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 0, SOLHub.Configuration.ElementHeight),
                    ClipsDescendants = true
                })
                
                local UICornerColorPicker = CreateElement("UICorner", {
                    Parent = ColorPicker,
                    CornerRadius = UDim.new(0, SOLHub.Configuration.UICorner)
                })
                
                local ColorPickerStroke = CreateElement("UIStroke", {
                    Parent = ColorPicker,
                    -- ApplyStrokeMode has a default value in CreateElement
                    Color = SOLHub.Theme.ElementBorder,
                    Thickness = 1
                })
                
                local ColorTitle = CreateElement("TextLabel", {
                    Name = "Title",
                    Parent = ColorPicker,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, 0),
                    Size = UDim2.new(1, -60, 1, 0),
                    Font = SOLHub.Configuration.TextFont,
                    Text = colorConfig.Name,
                    TextColor3 = SOLHub.Theme.TextColor,
                    TextSize = SOLHub.Configuration.TextSize,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                
                local ColorDisplay = CreateElement("Frame", {
                    Name = "ColorDisplay",
                    Parent = ColorPicker,
                    BackgroundColor3 = colorConfig.Default,
                    BorderSizePixel = 0,
                    Position = UDim2.new(1, -50, 0.5, -10),
                    Size = UDim2.new(0, 40, 0, 20)
                })
                
                local UICornerDisplay = CreateElement("UICorner", {
                    Parent = ColorDisplay,
                    CornerRadius = UDim.new(0, SOLHub.Configuration.UICorner)
                })
                
                local ColorGlow = CreateElement("ImageLabel", {
                    Name = "Glow",
                    Parent = ColorDisplay,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, -5, 0, -5),
                    Size = UDim2.new(1, 10, 1, 10),
                    Image = "rbxassetid://5028857084",
                    ImageColor3 = colorConfig.Default,
                    ImageTransparency = 0.6
                })
                
                local ColorButton = CreateElement("TextButton", {
                    Name = "Button",
                    Parent = ColorPicker,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    Text = ""
                })
                
                -- Color Picker Expanded UI
                local ColorPickerExpanded = CreateElement("Frame", {
                    Name = "Expanded",
                    Parent = ColorPicker,
                    BackgroundColor3 = SOLHub.Theme.ElementBackground,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 0, 0, SOLHub.Configuration.ElementHeight),
                    Size = UDim2.new(1, 0, 0, 0),
                    Visible = false
                })
                
                local UICornerExpanded = CreateElement("UICorner", {
                    Parent = ColorPickerExpanded,
                    CornerRadius = UDim.new(0, SOLHub.Configuration.UICorner)
                })
                
                -- Color picker content to be added when expanded
                local ColorPickerContent = CreateElement("Frame", {
                    Name = "Content",
                    Parent = ColorPickerExpanded,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, 10),
                    Size = UDim2.new(1, -20, 1, -20)
                })
                
                -- Set initial flag value
                local SelectedColor = colorConfig.Default
                if colorConfig.Flag then
                    SOLHub.Flags[colorConfig.Flag] = SelectedColor
                end
                
                -- Color picker functionality
                local IsOpen = false
                
                -- Function to close the color picker
                local function CloseColorPicker()
                    IsOpen = false
                    Tween(ColorPicker, {Size = UDim2.new(1, 0, 0, SOLHub.Configuration.ElementHeight)})
                    ColorPickerExpanded.Visible = false
                end
                
                -- Open/close color picker on button click
                ColorButton.MouseButton1Click:Connect(function()
                    IsOpen = not IsOpen
                    
                    if IsOpen then
                        Tween(ColorPicker, {Size = UDim2.new(1, 0, 0, SOLHub.Configuration.ElementHeight + 170)})
                        ColorPickerExpanded.Size = UDim2.new(1, 0, 0, 160)
                        ColorPickerExpanded.Visible = true
                        
                        -- Create the color picker UI elements
                        if not ColorPickerContent:FindFirstChild("ColorSpace") then
                            -- The main color space (hue and saturation)
                            local ColorSpace = CreateElement("ImageLabel", {
                                Name = "ColorSpace",
                                Parent = ColorPickerContent,
                                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                                BorderSizePixel = 0,
                                Position = UDim2.new(0, 0, 0, 0),
                                Size = UDim2.new(1, -30, 0, 100),
                                Image = "rbxassetid://4155801252"
                            })
                            
                            local UICornerColorSpace = CreateElement("UICorner", {
                                Parent = ColorSpace,
                                CornerRadius = UDim.new(0, SOLHub.Configuration.UICorner)
                            })
                            
                            local ColorSpaceSelector = CreateElement("Frame", {
                                Name = "Selector",
                                Parent = ColorSpace,
                                AnchorPoint = Vector2.new(0.5, 0.5),
                                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                                BorderColor3 = Color3.fromRGB(0, 0, 0),
                                BorderSizePixel = 1,
                                Position = UDim2.new(0.5, 0, 0.5, 0),
                                Size = UDim2.new(0, 6, 0, 6)
                            })
                            
                            local UICornerSelector = CreateElement("UICorner", {
                                Parent = ColorSpaceSelector,
                                CornerRadius = UDim.new(1, 0)
                            })
                            
                            -- The value/brightness slider
                            local ValueSlider = CreateElement("Frame", {
                                Name = "ValueSlider",
                                Parent = ColorPickerContent,
                                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                                BorderSizePixel = 0,
                                Position = UDim2.new(1, -20, 0, 0),
                                Size = UDim2.new(0, 20, 0, 100)
                            })
                            
                            local UICornerValueSlider = CreateElement("UICorner", {
                                Parent = ValueSlider,
                                CornerRadius = UDim.new(0, SOLHub.Configuration.UICorner)
                            })
                            
                            local ValueGradient = CreateElement("UIGradient", {
                                Parent = ValueSlider,
                                Color = ColorSequence.new({
                                    ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 0)),
                                    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
                                }),
                                Rotation = 90
                            })
                            
                            local ValueSliderSelector = CreateElement("Frame", {
                                Name = "Selector",
                                Parent = ValueSlider,
                                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                                BorderColor3 = Color3.fromRGB(0, 0, 0),
                                BorderSizePixel = 1,
                                Position = UDim2.new(0, 0, 0.5, 0),
                                Size = UDim2.new(1, 0, 0, 3)
                            })
                            
                            -- RGB Input fields
                            local RGBContainer = CreateElement("Frame", {
                                Name = "RGBContainer",
                                Parent = ColorPickerContent,
                                BackgroundTransparency = 1,
                                Position = UDim2.new(0, 0, 0, 110),
                                Size = UDim2.new(1, 0, 0, 30)
                            })
                            
                            local RGBLayout = CreateElement("UIListLayout", {
                                Parent = RGBContainer,
                                FillDirection = Enum.FillDirection.Horizontal,
                                Padding = UDim.new(0, 5),
                                SortOrder = Enum.SortOrder.LayoutOrder
                            })
                            
                            -- RGB input functions
                            local function CreateRGBInput(name, value, order)
                                local RGBInput = CreateElement("Frame", {
                                    Name = name .. "Input",
                                    Parent = RGBContainer,
                                    BackgroundColor3 = SOLHub.Theme.ElementBackground,
                                    BorderSizePixel = 0,
                                    Size = UDim2.new(0, 70, 1, 0),
                                    LayoutOrder = order
                                })
                                
                                local UICornerRGB = CreateElement("UICorner", {
                                    Parent = RGBInput,
                                    CornerRadius = UDim.new(0, SOLHub.Configuration.UICorner)
                                })
                                
                                local RGBLabel = CreateElement("TextLabel", {
                                    Name = "Label",
                                    Parent = RGBInput,
                                    BackgroundTransparency = 1,
                                    Position = UDim2.new(0, 5, 0, 0),
                                    Size = UDim2.new(0, 15, 1, 0),
                                    Font = SOLHub.Configuration.TextFont,
                                    Text = name,
                                    TextColor3 = name == "R" and Color3.fromRGB(255, 120, 120) or 
                                               name == "G" and Color3.fromRGB(120, 255, 120) or 
                                               Color3.fromRGB(120, 120, 255),
                                    TextSize = SOLHub.Configuration.TextSize
                                })
                                
                                local RGBTextBox = CreateElement("TextBox", {
                                    Name = "Input",
                                    Parent = RGBInput,
                                    BackgroundTransparency = 1,
                                    Position = UDim2.new(0, 20, 0, 0),
                                    Size = UDim2.new(1, -25, 1, 0),
                                    Font = SOLHub.Configuration.TextFont,
                                    Text = tostring(value),
                                    TextColor3 = SOLHub.Theme.TextColor,
                                    TextSize = SOLHub.Configuration.TextSize,
                                    ClearTextOnFocus = true
                                })
                                
                                -- Input validation
                                RGBTextBox.FocusLost:Connect(function(enterPressed)
                                    local inputValue = tonumber(RGBTextBox.Text)
                                    if inputValue then
                                        inputValue = math.clamp(math.floor(inputValue), 0, 255)
                                        
                                        -- Update the color based on RGB input
                                        local r, g, b = SelectedColor.R, SelectedColor.G, SelectedColor.B
                                        if name == "R" then r = inputValue/255
                                        elseif name == "G" then g = inputValue/255
                                        else b = inputValue/255 end
                                        
                                        SelectedColor = Color3.new(r, g, b)
                                        UpdateColorPicker(SelectedColor)
                                    end
                                    
                                    RGBTextBox.Text = tostring(math.floor(SelectedColor[name] * 255))
                                end)
                                
                                return RGBTextBox
                            end
                            
                            local RInput = CreateRGBInput("R", math.floor(SelectedColor.R * 255), 1)
                            local GInput = CreateRGBInput("G", math.floor(SelectedColor.G * 255), 2)
                            local BInput = CreateRGBInput("B", math.floor(SelectedColor.B * 255), 3)
                            
                            -- Color selection functions
                            local function UpdateColorFromHSV(h, s, v)
                                SelectedColor = Color3.fromHSV(h, s, v)
                                ColorDisplay.BackgroundColor3 = SelectedColor
                                ColorGlow.ImageColor3 = SelectedColor
                                
                                -- Update RGB inputs
                                RInput.Text = tostring(math.floor(SelectedColor.R * 255))
                                GInput.Text = tostring(math.floor(SelectedColor.G * 255))
                                BInput.Text = tostring(math.floor(SelectedColor.B * 255))
                                
                                -- Update flag and callback
                                if colorConfig.Flag then
                                    SOLHub.Flags[colorConfig.Flag] = SelectedColor
                                end
                                task.spawn(function()
                                    colorConfig.Callback(SelectedColor)
                                end)
                            end
                            
                            -- Initial position of selectors based on the current color
                            local h, s, v = Color3.toHSV(SelectedColor)
                            ColorSpaceSelector.Position = UDim2.new(s, 0, 1 - h, 0)
                            ValueSliderSelector.Position = UDim2.new(0, 0, 1 - v, 0)
                            
                            -- Function to handle color space selection
                            local function UpdateColorSpace()
                                local absPos = ColorSpace.AbsolutePosition
                                local absSize = ColorSpace.AbsoluteSize
                                local mousePos = UserInputService:GetMouseLocation()
                                local relativeX = math.clamp((mousePos.X - absPos.X) / absSize.X, 0, 1)
                                local relativeY = math.clamp((mousePos.Y - absPos.Y) / absSize.Y, 0, 1)
                                
                                ColorSpaceSelector.Position = UDim2.new(relativeX, 0, relativeY, 0)
                                
                                -- Get hue and saturation from the color space
                                local hue = 1 - relativeY
                                local saturation = relativeX
                                local value = 1 - ValueSliderSelector.Position.Y.Scale
                                
                                UpdateColorFromHSV(hue, saturation, value)
                                
                                -- Update the value slider gradient based on the selected hue and saturation
                                ValueGradient.Color = ColorSequence.new({
                                    ColorSequenceKeypoint.new(0, Color3.fromHSV(hue, saturation, 0)),
                                    ColorSequenceKeypoint.new(1, Color3.fromHSV(hue, saturation, 1))
                                })
                            end
                            
                            -- Function to handle value slider selection
                            local function UpdateValueSlider()
                                local absPos = ValueSlider.AbsolutePosition
                                local absSize = ValueSlider.AbsoluteSize
                                local mousePos = UserInputService:GetMouseLocation()
                                local relativeY = math.clamp((mousePos.Y - absPos.Y) / absSize.Y, 0, 1)
                                
                                ValueSliderSelector.Position = UDim2.new(0, 0, relativeY, 0)
                                
                                -- Get hue and saturation from the current color space selector position
                                local hue = 1 - ColorSpaceSelector.Position.Y.Scale
                                local saturation = ColorSpaceSelector.Position.X.Scale
                                local value = 1 - relativeY
                                
                                UpdateColorFromHSV(hue, saturation, value)
                            end
                            
                            -- Color space interaction
                            local ColorSpaceButton = CreateElement("TextButton", {
                                Name = "Button",
                                Parent = ColorSpace,
                                BackgroundTransparency = 1,
                                Size = UDim2.new(1, 0, 1, 0),
                                Text = ""
                            })
                            
                            local ColorSpaceDragging = false
                            
                            ColorSpaceButton.MouseButton1Down:Connect(function()
                                ColorSpaceDragging = true
                                UpdateColorSpace()
                            end)
                            
                            UserInputService.InputEnded:Connect(function(input)
                                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                                    ColorSpaceDragging = false
                                end
                            end)
                            
                            UserInputService.InputChanged:Connect(function(input)
                                if input.UserInputType == Enum.UserInputType.MouseMovement and ColorSpaceDragging then
                                    UpdateColorSpace()
                                end
                            end)
                            
                            -- Value slider interaction
                            local ValueSliderButton = CreateElement("TextButton", {
                                Name = "Button",
                                Parent = ValueSlider,
                                BackgroundTransparency = 1,
                                Size = UDim2.new(1, 0, 1, 0),
                                Text = ""
                            })
                            
                            local ValueSliderDragging = false
                            
                            ValueSliderButton.MouseButton1Down:Connect(function()
                                ValueSliderDragging = true
                                UpdateValueSlider()
                            end)
                            
                            UserInputService.InputEnded:Connect(function(input)
                                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                                    ValueSliderDragging = false
                                end
                            end)
                            
                            UserInputService.InputChanged:Connect(function(input)
                                if input.UserInputType == Enum.UserInputType.MouseMovement and ValueSliderDragging then
                                    UpdateValueSlider()
                                end
                            end)
                        end
                    else
                        CloseColorPicker()
                    end
                end)
                
                -- Function to update the color picker UI
                function UpdateColorPicker(color)
                    SelectedColor = color
                    ColorDisplay.BackgroundColor3 = color
                    ColorGlow.ImageColor3 = color
                    
                    -- Update flag and callback
                    if colorConfig.Flag then
                        SOLHub.Flags[colorConfig.Flag] = color
                    end
                    task.spawn(function()
                        colorConfig.Callback(color)
                    end)
                    
                    -- If the color picker UI exists, update it
                    local ColorSpace = ColorPickerContent:FindFirstChild("ColorSpace")
                    if ColorSpace then
                        local h, s, v = Color3.toHSV(color)
                        ColorSpace.Selector.Position = UDim2.new(s, 0, 1 - h, 0)
                        
                        local ValueSlider = ColorPickerContent:FindFirstChild("ValueSlider")
                        if ValueSlider then
                            ValueSlider.Selector.Position = UDim2.new(0, 0, 1 - v, 0)
                            
                            -- Update value slider gradient
                            ValueSlider.UIGradient.Color = ColorSequence.new({
                                ColorSequenceKeypoint.new(0, Color3.fromHSV(h, s, 0)),
                                ColorSequenceKeypoint.new(1, Color3.fromHSV(h, s, 1))
                            })
                        end
                        
                        -- Update RGB inputs
                        local RGBContainer = ColorPickerContent:FindFirstChild("RGBContainer")
                        if RGBContainer then
                            local RInput = RGBContainer:FindFirstChild("RInput")
                            local GInput = RGBContainer:FindFirstChild("GInput")
                            local BInput = RGBContainer:FindFirstChild("BInput")
                            
                            if RInput and GInput and BInput then
                                RInput.Input.Text = tostring(math.floor(color.R * 255))
                                GInput.Input.Text = tostring(math.floor(color.G * 255))
                                BInput.Input.Text = tostring(math.floor(color.B * 255))
                            end
                        end
                    end
                end
                
                -- Hover effect
                ColorButton.MouseEnter:Connect(function()
                    Tween(ColorPickerStroke, {Color = SOLHub.Theme.AccentColor}, SOLHub.Configuration.HoverAnimationDuration)
                end)
                
                ColorButton.MouseLeave:Connect(function()
                    Tween(ColorPickerStroke, {Color = SOLHub.Theme.ElementBorder}, SOLHub.Configuration.HoverAnimationDuration)
                end)
                
                -- Close color picker when clicking elsewhere
                UserInputService.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        local absPos = ColorPicker.AbsolutePosition
                        local absSize = ColorPicker.AbsoluteSize
                        local mousePos = UserInputService:GetMouseLocation()
                        
                        if IsOpen and (mousePos.X < absPos.X or mousePos.X > absPos.X + absSize.X or mousePos.Y < absPos.Y or mousePos.Y > absPos.Y + absSize.Y) then
                            CloseColorPicker()
                        end
                    end
                end)
                
                -- ColorPicker API
                local ColorPickerApi = {}
                
                function ColorPickerApi:Set(color)
                    UpdateColorPicker(color)
                end
                
                return ColorPickerApi
            end
            
            function Section:AddTextbox(config)
                config = config or {}
                local textboxConfig = {
                    Name = config.Name or "Textbox",
                    Default = config.Default or "",
                    TextDisappear = config.TextDisappear or false,
                    Placeholder = config.Placeholder or "Enter text...",
                    Flag = config.Flag,
                    Callback = config.Callback or function() end
                }
                
                local Textbox = CreateElement("Frame", {
                    Name = textboxConfig.Name .. "Textbox",
                    Parent = SectionContent,
                    BackgroundColor3 = SOLHub.Theme.ElementBackground,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 0, SOLHub.Configuration.ElementHeight)
                })
                
                local UICornerTextbox = CreateElement("UICorner", {
                    Parent = Textbox,
                    CornerRadius = UDim.new(0, SOLHub.Configuration.UICorner)
                })
                
                local TextboxStroke = CreateElement("UIStroke", {
                    Parent = Textbox,
                    -- ApplyStrokeMode has a default value in CreateElement
                    Color = SOLHub.Theme.ElementBorder,
                    Thickness = 1
                })
                
                local TextboxTitle = CreateElement("TextLabel", {
                    Name = "Title",
                    Parent = Textbox,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, 0),
                    Size = UDim2.new(1, -20, 0.5, 0),
                    Font = SOLHub.Configuration.TextFont,
                    Text = textboxConfig.Name,
                    TextColor3 = SOLHub.Theme.TextColor,
                    TextSize = SOLHub.Configuration.TextSize,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                
                local TextboxInput = CreateElement("TextBox", {
                    Name = "Input",
                    Parent = Textbox,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0.5, 0),
                    Size = UDim2.new(1, -20, 0.5, 0),
                    Font = SOLHub.Configuration.TextFont,
                    Text = textboxConfig.Default,
                    PlaceholderText = textboxConfig.Placeholder,
                    TextColor3 = SOLHub.Theme.AccentColor,
                    PlaceholderColor3 = Color3.fromRGB(100, 100, 120),
                    TextSize = SOLHub.Configuration.TextSize,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ClearTextOnFocus = textboxConfig.TextDisappear
                })
                
                -- Textbox interaction
                TextboxInput.Focused:Connect(function()
                    Tween(TextboxStroke, {Color = SOLHub.Theme.AccentColor}, SOLHub.Configuration.HoverAnimationDuration)
                end)
                
                TextboxInput.FocusLost:Connect(function(enterPressed)
                    Tween(TextboxStroke, {Color = SOLHub.Theme.ElementBorder}, SOLHub.Configuration.HoverAnimationDuration)
                    
                    -- Update flag
                    if textboxConfig.Flag then
                        SOLHub.Flags[textboxConfig.Flag] = TextboxInput.Text
                    end
                    
                    -- Call callback
                    task.spawn(function()
                        textboxConfig.Callback(TextboxInput.Text)
                    end)
                end)
                
                -- Set initial flag value
                if textboxConfig.Flag then
                    SOLHub.Flags[textboxConfig.Flag] = textboxConfig.Default
                end
                
                -- Textbox API
                local TextboxApi = {}
                
                function TextboxApi:Set(text)
                    TextboxInput.Text = text
                    
                    -- Update flag
                    if textboxConfig.Flag then
                        SOLHub.Flags[textboxConfig.Flag] = text
                    end
                    
                    -- Call callback
                    task.spawn(function()
                        textboxConfig.Callback(text)
                    end)
                end
                
                return TextboxApi
            end
            
            function Section:AddKeybind(config)
                config = config or {}
                local keybindConfig = {
                    Name = config.Name or "Keybind",
                    Default = config.Default,
                    Flag = config.Flag,
                    Callback = config.Callback or function() end,
                    ChangedCallback = config.ChangedCallback
                }
                
                local Keybind = CreateElement("Frame", {
                    Name = keybindConfig.Name .. "Keybind",
                    Parent = SectionContent,
                    BackgroundColor3 = SOLHub.Theme.ElementBackground,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 0, SOLHub.Configuration.ElementHeight)
                })
                
                local UICornerKeybind = CreateElement("UICorner", {
                    Parent = Keybind,
                    CornerRadius = UDim.new(0, SOLHub.Configuration.UICorner)
                })
                
                local KeybindStroke = CreateElement("UIStroke", {
                    Parent = Keybind,
                    -- ApplyStrokeMode has a default value in CreateElement
                    Color = SOLHub.Theme.ElementBorder,
                    Thickness = 1
                })
                
                local KeybindTitle = CreateElement("TextLabel", {
                    Name = "Title",
                    Parent = Keybind,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, 0),
                    Size = UDim2.new(1, -80, 1, 0),
                    Font = SOLHub.Configuration.TextFont,
                    Text = keybindConfig.Name,
                    TextColor3 = SOLHub.Theme.TextColor,
                    TextSize = SOLHub.Configuration.TextSize,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                
                local KeybindButton = CreateElement("TextButton", {
                    Name = "Button",
                    Parent = Keybind,
                    BackgroundColor3 = SOLHub.Theme.ElementBackground,
                    BorderSizePixel = 0,
                    Position = UDim2.new(1, -70, 0.5, -10),
                    Size = UDim2.new(0, 60, 0, 20),
                    Font = SOLHub.Configuration.TextFont,
                    Text = keybindConfig.Default and keybindConfig.Default.Name or "None",
                    TextColor3 = SOLHub.Theme.TextColor,
                    TextSize = SOLHub.Configuration.TextSize - 2,
                    AutoButtonColor = false
                })
                
                local UICornerButton = CreateElement("UICorner", {
                    Parent = KeybindButton,
                    CornerRadius = UDim.new(0, SOLHub.Configuration.UICorner)
                })
                
                local KeybindButtonStroke = CreateElement("UIStroke", {
                    Parent = KeybindButton,
                    -- ApplyStrokeMode has a default value in CreateElement
                    Color = SOLHub.Theme.ElementBorder,
                    Thickness = 1
                })
                
                -- Keybind functionality
                local CurrentKey = keybindConfig.Default
                local IsChangingKey = false
                
                -- Set initial flag value
                if keybindConfig.Flag and CurrentKey then
                    SOLHub.Flags[keybindConfig.Flag] = CurrentKey
                end
                
                -- Update keybind display
                local function UpdateKeybind()
                    KeybindButton.Text = CurrentKey and CurrentKey.Name or "None"
                    
                    -- Update flag
                    if keybindConfig.Flag then
                        SOLHub.Flags[keybindConfig.Flag] = CurrentKey
                    end
                    
                    -- Call changed callback if provided
                    if keybindConfig.ChangedCallback and CurrentKey then
                        task.spawn(function()
                            keybindConfig.ChangedCallback(CurrentKey)
                        end)
                    end
                end
                
                -- Start changing keybind
                KeybindButton.MouseButton1Click:Connect(function()
                    IsChangingKey = true
                    KeybindButton.Text = "..."
                    Tween(KeybindButtonStroke, {Color = SOLHub.Theme.AccentColor})
                end)
                
                -- Detect key presses for binding
                UserInputService.InputBegan:Connect(function(input, gameProcessed)
                    if not gameProcessed then
                        -- When changing keybind
                        if IsChangingKey then
                            -- Only accept keyboard inputs for binding
                            if input.UserInputType == Enum.UserInputType.Keyboard then
                                CurrentKey = input.KeyCode
                                IsChangingKey = false
                                Tween(KeybindButtonStroke, {Color = SOLHub.Theme.ElementBorder})
                                UpdateKeybind()
                            end
                        -- When key is pressed, call callback
                        elseif CurrentKey and input.KeyCode == CurrentKey then
                            task.spawn(function()
                                keybindConfig.Callback()
                            end)
                        end
                    end
                end)
                
                -- Hovering effects
                KeybindButton.MouseEnter:Connect(function()
                    if not IsChangingKey then
                        Tween(KeybindButtonStroke, {Color = SOLHub.Theme.AccentColor}, SOLHub.Configuration.HoverAnimationDuration)
                    end
                end)
                
                KeybindButton.MouseLeave:Connect(function()
                    if not IsChangingKey then
                        Tween(KeybindButtonStroke, {Color = SOLHub.Theme.ElementBorder}, SOLHub.Configuration.HoverAnimationDuration)
                    end
                end)
                
                -- Keybind API
                local KeybindApi = {}
                
                function KeybindApi:Set(key)
                    CurrentKey = key
                    IsChangingKey = false
                    UpdateKeybind()
                end
                
                function KeybindApi:GetBind()
                    return CurrentKey
                end
                
                return KeybindApi
            end
            
            function Section:AddLabel(config)
                config = config or {}
                local labelConfig = {
                    Text = config.Text or "Label",
                    Color = config.Color or SOLHub.Theme.TextColor
                }
                
                local Label = CreateElement("Frame", {
                    Name = "Label",
                    Parent = SectionContent,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 20)
                })
                
                local LabelText = CreateElement("TextLabel", {
                    Name = "Text",
                    Parent = Label,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    Font = SOLHub.Configuration.TextFont,
                    Text = labelConfig.Text,
                    TextColor3 = labelConfig.Color,
                    TextSize = SOLHub.Configuration.TextSize,
                    TextWrapped = true
                })
                
                -- Label API
                local LabelApi = {}
                
                function LabelApi:Set(text, color)
                    LabelText.Text = text
                    if color then
                        LabelText.TextColor3 = color
                    end
                end
                
                return LabelApi
            end
            
            return Section
        end
        
        -- Select first tab by default
        pcall(function()
            if TabList and TabList.GetChildren and #TabList:GetChildren() > 1 then
                for _, child in pairs(TabList:GetChildren()) do
                    if child:IsA("TextButton") then
                        child.MouseButton1Click:Fire()
                        break
                    end
                end
            else
                print("Demo: Skipping first tab selection (mock environment)")
            end
        end)
        
        -- Update TabList canvas size
        TabListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            TabList.CanvasSize = UDim2.new(0, 0, 0, TabListLayout.AbsoluteContentSize.Y)
        end)
        
        -- Set initial flag values if config saving is enabled
        if windowConfig.ConfigurationSaving.Enabled then
            -- Load configuration from file
            local function LoadConfiguration()
                -- Implementation for configuration loading would go here
                -- This is just a placeholder - actual implementation would depend on the exploit environment
            end
            
            -- Save configuration to file
            local function SaveConfiguration()
                -- Implementation for configuration saving would go here
                -- This is just a placeholder - actual implementation would depend on the exploit environment
            end
            
            -- Auto-save configuration at interval
            if windowConfig.ConfigurationSaving.AutoSave then
                spawn(function()
                    local iteration = 0
                    while MainFrame.Parent do
                        SaveConfiguration()
                        wait(windowConfig.ConfigurationSaving.AutoSaveInterval or 10)
                        
                        -- For demo environment, limit iterations
                        if _G.DEMO_MAX_ITERATIONS then
                            iteration = iteration + 1
                            if iteration >= _G.DEMO_MAX_ITERATIONS then
                                print("Demo: Auto-save loop limited to " .. _G.DEMO_MAX_ITERATIONS .. " iterations")
                                break
                            end
                        end
                    end
                end)
            end
            
            -- Save configuration when UI is closed
            RunService.RenderStepped:Connect(function()
                if not MainFrame.Parent and windowConfig.ConfigurationSaving.Enabled then
                    SaveConfiguration()
                end
            end)
            
            -- Load configuration when UI is created
            LoadConfiguration()
        end
        
        if windowConfig.KeySystem then
            -- Implementation for key system would go here
            -- This is just a placeholder - actual implementation would depend on requirements
        end
        
        return Tab
    end
    
    -- Notification system
    function Window:Notify(config)
        config = config or {}
        local notificationConfig = {
            Title = config.Title or "Notification",
            Content = config.Content or "Content",
            Duration = config.Duration or SOLHub.Configuration.NotificationDuration,
            Image = config.Image,
            Actions = config.Actions or {}
        }
        
        -- Create notification container if not exists
        local NotificationContainer = game:GetService("CoreGui"):FindFirstChild("SOLHub_Notifications")
        if not NotificationContainer then
            NotificationContainer = CreateElement("ScreenGui", {
                Name = "SOLHub_Notifications",
                Parent = game:GetService("CoreGui"),
                ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
                ResetOnSpawn = false
            })
            
            local NotificationLayout = CreateElement("UIListLayout", {
                Parent = NotificationContainer,
                FillDirection = Enum.FillDirection.Vertical,
                HorizontalAlignment = Enum.HorizontalAlignment.Right,
                SortOrder = Enum.SortOrder.LayoutOrder,
                VerticalAlignment = Enum.VerticalAlignment.Bottom,
                Padding = UDim.new(0, 10)
            })
            
            local NotificationPadding = CreateElement("UIPadding", {
                Parent = NotificationContainer,
                PaddingBottom = UDim.new(0, 10),
                PaddingRight = UDim.new(0, 10)
            })
        end
        
        -- Create notification
        local Notification = CreateElement("Frame", {
            Name = "Notification",
            Parent = NotificationContainer,
            BackgroundColor3 = SOLHub.Theme.Background,
            BorderSizePixel = 0,
            Position = UDim2.new(1, 300, 1, -10),
            Size = UDim2.new(0, 300, 0, 80),
            AnchorPoint = Vector2.new(1, 1),
            ClipsDescendants = true
        })
        
        local NotificationCorner = CreateElement("UICorner", {
            Parent = Notification,
            CornerRadius = UDim.new(0, 5)
        })
        
        local NotificationGlow = CreateElement("ImageLabel", {
            Name = "Glow",
            Parent = Notification,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, -15, 0, -15),
            Size = UDim2.new(1, 30, 1, 30),
            ZIndex = 0,
            Image = "rbxassetid://5028857084",
            ImageColor3 = SOLHub.Theme.AccentColor,
            ImageTransparency = 0.5,
            ScaleType = Enum.ScaleType.Slice,
            SliceCenter = Rect.new(24, 24, 276, 276)
        })
        
        local NotificationTitle = CreateElement("TextLabel", {
            Name = "Title",
            Parent = Notification,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 10, 0, 5),
            Size = UDim2.new(1, -20, 0, 20),
            Font = SOLHub.Configuration.TextFont,
            Text = notificationConfig.Title,
            TextColor3 = SOLHub.Theme.TextColor,
            TextSize = 18,
            TextXAlignment = Enum.TextXAlignment.Left
        })
        
        -- Cyberpunk-style neon line under title
        local NotificationLine = CreateElement("Frame", {
            Name = "Line",
            Parent = NotificationTitle,
            BackgroundColor3 = SOLHub.Theme.AccentColor,
            BorderSizePixel = 0,
            Position = UDim2.new(0, 0, 1, 0),
            Size = UDim2.new(0, 30, 0, 1)
        })
        
        local NotificationContent = CreateElement("TextLabel", {
            Name = "Content",
            Parent = Notification,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 10, 0, 30),
            Size = UDim2.new(1, -20, 0, 40),
            Font = Enum.Font.Gotham,
            Text = notificationConfig.Content,
            TextColor3 = Color3.fromRGB(200, 200, 200),
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
            TextWrapped = true
        })
        
        -- Add image if provided
        if notificationConfig.Image then
            local NotificationImage = CreateElement("ImageLabel", {
                Name = "Image",
                Parent = Notification,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 30),
                Size = UDim2.new(0, 30, 0, 30),
                Image = notificationConfig.Image
            })
            
            NotificationContent.Position = UDim2.new(0, 50, 0, 30)
            NotificationContent.Size = UDim2.new(1, -60, 0, 40)
        end
        
        -- Add actions buttons if provided
        if #notificationConfig.Actions > 0 then
            Notification.Size = UDim2.new(0, 300, 0, 80 + 30)
            
            local ActionsContainer = CreateElement("Frame", {
                Name = "Actions",
                Parent = Notification,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 70),
                Size = UDim2.new(1, -20, 0, 30)
            })
            
            local ActionsLayout = CreateElement("UIListLayout", {
                Parent = ActionsContainer,
                FillDirection = Enum.FillDirection.Horizontal,
                HorizontalAlignment = Enum.HorizontalAlignment.Right,
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 5)
            })
            
            for i, action in ipairs(notificationConfig.Actions) do
                local ActionButton = CreateElement("TextButton", {
                    Name = "Action" .. i,
                    Parent = ActionsContainer,
                    BackgroundColor3 = SOLHub.Theme.DarkContrast,
                    BorderSizePixel = 0,
                    Size = UDim2.new(0, 80, 1, 0),
                    Font = SOLHub.Configuration.TextFont,
                    Text = action.Text,
                    TextColor3 = SOLHub.Theme.TextColor,
                    TextSize = 14,
                    AutoButtonColor = false
                })
                
                local ActionButtonCorner = CreateElement("UICorner", {
                    Parent = ActionButton,
                    CornerRadius = UDim.new(0, 4)
                })
                
                -- Button hover effects
                ActionButton.MouseEnter:Connect(function()
                    Tween(ActionButton, {BackgroundColor3 = SOLHub.Theme.AccentColor}, 0.2)
                end)
                
                ActionButton.MouseLeave:Connect(function()
                    Tween(ActionButton, {BackgroundColor3 = SOLHub.Theme.DarkContrast}, 0.2)
                end)
                
                ActionButton.MouseButton1Click:Connect(function()
                    if action.Callback then
                        task.spawn(action.Callback)
                    end
                    Tween(Notification, {Position = UDim2.new(1, 300, 1, Notification.AbsolutePosition.Y)}, 0.5)
                    Tween(Notification, {BackgroundTransparency = 1}, 0.5)
                    wait(0.5)
                    Notification:Destroy()
                end)
            end
        end
        
        -- Animate notification
        Tween(Notification, {Position = UDim2.new(1, 0, 1, Notification.AbsolutePosition.Y)}, 0.5)
        
        -- Auto-close notification after duration
        spawn(function()
            wait(notificationConfig.Duration)
            if Notification.Parent then
                Tween(Notification, {Position = UDim2.new(1, 300, 1, Notification.AbsolutePosition.Y)}, 0.5)
                Tween(Notification, {BackgroundTransparency = 1}, 0.5)
                wait(0.5)
                Notification:Destroy()
            end
        end)
        
        -- Return controls for the notification
        local NotificationObj = {}
        
        function NotificationObj:Close()
            if Notification.Parent then
                Tween(Notification, {Position = UDim2.new(1, 300, 1, Notification.AbsolutePosition.Y)}, 0.5)
                Tween(Notification, {BackgroundTransparency = 1}, 0.5)
                wait(0.5)
                Notification:Destroy()
            end
        end
        
        return NotificationObj
    end
    
    return Window
end

-- Helper methods for the library
function SOLHub:Destroy()
    -- Find and remove all SOLHub GUIs
    pcall(function()
        local coreGui = game:GetService("CoreGui")
        if coreGui and coreGui.GetChildren then
            for _, gui in pairs(coreGui:GetChildren()) do
                if gui.Name:match("^SOLHub_") then
                    gui:Destroy()
                end
            end
        else
            print("Demo: Skipping GUI destruction (mock environment)")
        end
    end)
end

-- Get the value of a flag
function SOLHub:GetFlag(flag)
    return SOLHub.Flags[flag]
end

-- Set a custom theme
function SOLHub:SetTheme(theme)
    for key, value in pairs(theme) do
        if SOLHub.Theme[key] then
            SOLHub.Theme[key] = value
        end
    end
end

-- Set a global configuration option
function SOLHub:SetConfiguration(config)
    for key, value in pairs(config) do
        if SOLHub.Configuration[key] then
            SOLHub.Configuration[key] = value
        end
    end
end

return SOLHub
