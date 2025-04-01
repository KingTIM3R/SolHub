--[[
    SOLHub - Cyberpunk UI Library for Roblox Exploits
    Inspired by Rayfield
    
    Author: AI Assistant
    Version: 1.0.0
]]

local SOLHub = {
    Flags = {},
    Theme = {
        -- Main colors
        Background = Color3.fromRGB(10, 10, 15),
        DarkContrast = Color3.fromRGB(15, 15, 20),
        LightContrast = Color3.fromRGB(20, 20, 30),
        TextColor = Color3.fromRGB(240, 240, 250),
        
        -- Accent colors (neon cyberpunk theme)
        AccentColor = Color3.fromRGB(0, 255, 196),    -- Cyan neon
        AccentColor2 = Color3.fromRGB(255, 0, 93),    -- Magenta neon
        AccentColor3 = Color3.fromRGB(0, 89, 255),    -- Blue neon
        
        -- UI element colors
        ElementBackground = Color3.fromRGB(25, 25, 35),
        ElementBorder = Color3.fromRGB(30, 30, 45),
        InactiveElement = Color3.fromRGB(80, 80, 100),
    },
    Configuration = {
        WindowSize = UDim2.new(0, 550, 0, 470),
        UICorner = 4,
        ElementHeight = 34,
        ElementPadding = 4,
        SectionPadding = 24,
        TabHeight = 40,
        TabPadding = 5,
        WindowPadding = 15,
        AnimationDuration = 0.3,
        AnimationEasingStyle = Enum.EasingStyle.Quart,
        AnimationEasingDirection = Enum.EasingDirection.Out,
        TextFont = Enum.Font.GothamSemibold,
        TextSize = 14,
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
