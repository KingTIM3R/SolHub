-- SOLHub Loader
-- This file provides a simple way to load the SOLHub UI Library
-- Usage: local SOLHub = loadstring(game:HttpGet('https://raw.githubusercontent.com/yourusername/SOLHub/main/SOLHub_Loader.lua'))()

-- Booting message
print("Booting the SOLHub Library")

-- In a normal Roblox environment, we would load directly from a URL
-- local SOLHub = loadstring(game:HttpGet("https://raw.githubusercontent.com/yourusername/SOLHub/main/SOLHub.lua"))()

-- For our mock environment, we'll load directly from the file
local SOLHub = dofile("SOLHub.lua")

print("SOLHub library loaded successfully")

-- Apply Rayfield compatibility layer if needed
-- This ensures that the API follows a similar pattern to Rayfield
if SOLHub.CreateWindow and not SOLHub.Window then
    local originalCreateWindow = SOLHub.CreateWindow
    
    -- Override the CreateWindow function to return a compatible interface
    SOLHub.CreateWindow = function(self, options)
        local window = originalCreateWindow(self, options)
        
        -- Store the original CreateTab function for later use
        local originalCreateTab = window.CreateTab
        
        -- Override the CreateTab function
        window.CreateTab = function(self, name, icon)
            local tab = originalCreateTab(self, name, icon)
            
            -- Make sure the tab has all the required methods
            if not tab.AddSection then
                -- Storage for elements
                tab.Buttons = {}
                tab.Toggles = {}
                tab.Sliders = {}
                tab.Dropdowns = {}
                tab.ColorPickers = {}
                tab.Keybinds = {}
                
                -- Section method
                tab.AddSection = function(self, name)
                    print("Creating section:", name)
                    return tab
                end
                
                -- Button method
                tab.AddButton = function(self, options)
                    print("Creating button:", options.Title)
                    table.insert(tab.Buttons, options)
                    return options
                end
                
                -- Toggle method
                tab.AddToggle = function(self, options)
                    print("Creating toggle:", options.Title)
                    options.Value = options.Default or false
                    table.insert(tab.Toggles, options)
                    return options
                end
                
                -- Slider method
                tab.AddSlider = function(self, options)
                    print("Creating slider:", options.Title)
                    options.Value = options.Default or options.Min
                    table.insert(tab.Sliders, options)
                    return options
                end
                
                -- Dropdown method
                tab.AddDropdown = function(self, options)
                    print("Creating dropdown:", options.Title)
                    options.Value = options.Default or options.List[1]
                    table.insert(tab.Dropdowns, options)
                    return options
                end
                
                -- Colorpicker method
                tab.AddColorPicker = function(self, options)
                    print("Creating colorpicker:", options.Title)
                    options.Value = options.Default or {1, 1, 1}
                    table.insert(tab.ColorPickers, options)
                    return options
                end
                
                -- Keybind method
                tab.AddKeybind = function(self, options)
                    print("Creating keybind:", options.Title)
                    options.Value = options.Default or Enum.KeyCode.Unknown
                    table.insert(tab.Keybinds, options)
                    return options
                end
            end
            
            -- Return the enhanced tab
            return tab
        end
        
        return window
    end
end

-- Return the library
return SOLHub
