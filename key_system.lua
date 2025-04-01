
-- Main Hub Component Structure
local HubComponent = {
    Version = "1.0.0",
    Theme = {
        Background = Color3.fromRGB(10, 10, 15),
        Foreground = Color3.fromRGB(20, 20, 25),
        Accent = Color3.fromRGB(0, 255, 196),
        Text = Color3.fromRGB(240, 240, 250)
    },
    Config = {
        WindowSize = Vector2.new(550, 470),
        ElementHeight = 35,
        Padding = 10,
        AnimationSpeed = 0.2,
        Font = Enum.Font.Gotham
    },
    Flags = {},
    Windows = {},
    Active = true
}

-- Environment setup
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- Initialize hub component
function HubComponent:Init()
    -- Set up environment protection
    if gethui then
        self.ScreenGui = Instance.new("ScreenGui")
        self.ScreenGui.Parent = gethui()
    elseif syn and syn.protect_gui then
        self.ScreenGui = Instance.new("ScreenGui")
        syn.protect_gui(self.ScreenGui)
        self.ScreenGui.Parent = CoreGui
    else
        self.ScreenGui = Instance.new("ScreenGui")
        self.ScreenGui.Parent = CoreGui
    end
    
    self.ScreenGui.Name = "HubComponent_" .. game.PlaceId
    self.ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    self.ScreenGui.ResetOnSpawn = false
    
    return self
end

-- Core utility functions
function HubComponent:CreateTween(instance, properties, duration)
    duration = duration or self.Config.AnimationSpeed
    local tween = TweenService:Create(
        instance,
        TweenInfo.new(duration, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
        properties
    )
    return tween
end

function HubComponent:MakeDraggable(frame, handle)
    local dragToggle, dragStart, startPos
    
    handle = handle or frame
    
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragToggle = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and dragToggle then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragToggle = false
        end
    end)
end

-- Flag system
function HubComponent:SetFlag(name, value)
    self.Flags[name] = value
end

function HubComponent:GetFlag(name)
    return self.Flags[name]
end

-- Theme management
function HubComponent:SetTheme(theme)
    for key, value in pairs(theme) do
        if self.Theme[key] then
            self.Theme[key] = value
        end
    end
end

-- Configuration management
function HubComponent:SetConfig(config)
    for key, value in pairs(config) do
        if self.Config[key] then
            self.Config[key] = value
        end
    end
end

-- Cleanup
function HubComponent:Destroy()
    self.Active = false
    if self.ScreenGui then
        self.ScreenGui:Destroy()
    end
    self.Windows = {}
    self.Flags = {}
end

-- Return the component
return HubComponent
