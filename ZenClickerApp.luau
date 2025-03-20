---@diagnostic disable: undefined-global
local _RS = game:GetService("ReplicatedStorage")
local Remotes = {
    Clicker = _RS:WaitForChild("Remotes"):WaitForChild("Clicker"),
    Rebirth = _RS:WaitForChild("Remotes"):WaitForChild("Rebirth")
}

-- HTTP utility function
local function _HTTP_GET(url)
    if syn and syn.request then
        return syn.request({
            Url = url,
            Method = "GET"
        }).Body
    elseif http and http.request then
        return http.request({
            Url = url,
            Method = "GET"
        }).Body
    elseif game:GetService("HttpService") then
        return game:GetService("HttpService"):GetAsync(url)
    else
        error("No compatible HTTP method found")
    end
end

-- Import UI library
local ZenLib = loadstring(_HTTP_GET(
    "https://raw.githubusercontent.com/wafflehousefootjobplease/c/refs/heads/main/ui_lib_zen.luau"))()

-- ================ CLICKER CORE FUNCTIONALITY ================
local ClickerLib = {}
ClickerLib.Running = false
ClickerLib.ThreadCount = 10 -- Default thread count
ClickerLib.ClickMode = "normal"
ClickerLib.UseDelay = true
ClickerLib.Stats = {
    TotalClicks = 0,
    StartTime = 0,
    ClicksPerSecond = 0
}
ClickerLib.UpdateRate = 0.2
ClickerLib.CustomArgs = nil -- For custom arguments
ClickerLib.UIElements = {} -- Store UI elements to reference them in functions

-- Function declarations

-- Stats update function (defined early so it can be referenced in other functions)
local function updateStats()
    local stats = ClickerLib:GetStats()
    local status = ClickerLib:GetStatus()

    -- Update UI labels if they exist
    if ClickerLib.UIElements.TotalClicksLabel then
        ClickerLib.UIElements.TotalClicksLabel:Set("Total Clicks: " .. stats.TotalClicks)
        ClickerLib.UIElements.CPSLabel:Set(string.format("CPS: %.1f", stats.ClicksPerSecond))
        ClickerLib.UIElements.ThreadsLabel:Set("Active Threads: " .. (status.Running and status.ThreadCount or 0))
        ClickerLib.UIElements.StatusLabel:Set("Status: " .. (status.Running and "Running" or "Idle"))
    end
end

-- Basic click function
function ClickerLib:Click()
    Remotes.Clicker:FireServer()
    self.Stats.TotalClicks = self.Stats.TotalClicks + 1
end

function ClickerLib:Rebirth()
    Remotes.Rebirth:FireServer()
end

function ClickerLib:ProcessClick()
    if self.ClickMode == "normal" then
        self:Click()
    elseif self.ClickMode == "burst" then
        -- Burst mode: sends multiple clicks at once
        for i = 1, 3 do
            self:Click()
        end
    elseif self.ClickMode == "gentle" then
        -- Gentle mode: has a small chance to not click
        if math.random() > 0.3 then
            self:Click()
        end
    end
end

function ClickerLib:Start()
    if self.Running then
        return self
    end

    self.Running = true
    self.Stats.StartTime = tick()

    -- clean up hanging threads
    if self.Threads then
        for _, thread in pairs(self.Threads) do
            task.cancel(thread)
        end
    end

    self.Threads = {}

    -- threading
    for i = 1, self.ThreadCount do
        self.Threads[i] = task.spawn(function()
            while self.Running do
                self:ProcessClick()
                if self.UseDelay then
                    task.wait(0.001)
                end
            end
        end)
    end

    return self
end

function ClickerLib:Stop()
    self.Running = false

    -- Ensure the toggle is synchronized with the actual state
    if self.UIElements.AutoClickToggle and self.UIElements.AutoClickToggle.Value ~= self.Running then
        self.UIElements.AutoClickToggle:Set(false)
    end

    if self.Threads then
        for _, thread in pairs(self.Threads) do
            task.cancel(thread)
        end
        self.Threads = {}
    end

    -- Forcefully break out of any remaining click loops
    task.delay(0.1, function()
        if self.Threads then
            for _, thread in pairs(self.Threads) do
                if coroutine.status(thread) ~= "dead" then
                    task.cancel(thread)
                end
            end
            self.Threads = {}
        end
    end)

    return self
end

function ClickerLib:SetThreadCount(count)
    self.ThreadCount = count
    if self.Running then
        self:Stop()
        self:Start()
    end

    return self
end

function ClickerLib:SetClickMode(mode)
    if mode == "normal" or mode == "burst" or mode == "gentle" then
        self.ClickMode = mode

        if self.Running then
            self:Stop()
            self:Start()
        end
    end

    return self
end

function ClickerLib:SetCustomArgs(args)
    if type(args) == "table" then
        self.CustomArgs = args
    else
        self.CustomArgs = nil
    end

    return self
end

function ClickerLib:SetRemotePath(path)
    if type(path) == "string" then
        local success, result = pcall(function()
            local remote = _RS
            for _, part in ipairs(string.split(path, ".")) do
                remote = remote:WaitForChild(part)
            end
            return remote
        end)

        if success then
            Remotes.Clicker = result
        end
    end

    return self
end

function ClickerLib:SetDelay(useDelay)
    self.UseDelay = useDelay
    return self
end

function ClickerLib:ResetStats()
    self.Stats.TotalClicks = 0
    self.Stats.StartTime = tick()
    self.Stats.ClicksPerSecond = 0

    return self
end

function ClickerLib:GetStats()
    -- Calculate current CPS
    local elapsedTime = tick() - self.Stats.StartTime
    if elapsedTime > 0 then
        self.Stats.ClicksPerSecond = self.Stats.TotalClicks / elapsedTime
    end

    return self.Stats
end

function ClickerLib:GetStatus()
    return {
        Running = self.Running,
        ThreadCount = self.ThreadCount,
        ClickMode = self.ClickMode,
        UseDelay = self.UseDelay
    }
end
-- ================ END CLICKER CORE FUNCTIONALITY ================

-- ================ UI CREATION ================
-- Create UI Window
local Window = ZenLib:CreateWindow({
    Title = "Zen Clicker v1.0",
    Size = UDim2.new(0, 600, 0, 450)
})

-- Create Main tab
local MainTab = Window:CreateTab("Main")
local ControlsSection = MainTab:CreateSection("Controls")
local StatsSection = MainTab:CreateSection("Statistics")

-- Create Settings tab
local SettingsTab = Window:CreateTab("Settings")
local ConfigSection = SettingsTab:CreateSection("Configuration")
local AdvancedSection = SettingsTab:CreateSection("Advanced")
local InfoSection = SettingsTab:CreateSection("Information")

-- Controls Section Elements
ClickerLib.UIElements.AutoClickToggle = ControlsSection:AddToggle("Auto Click", false, function(state)
    if state then
        ClickerLib:Start()
    else
        ClickerLib:Stop()
    end
end)

ClickerLib.UIElements.RebirthClickToggle = ControlsSection:AddToggle("Auto Rebirth", false, function(state)
    if state then
        ClickerLib:Rebirth()
    else
        ClickerLib:Stop()
    end
end)

ClickerLib.UIElements.ThreadSlider = ControlsSection:AddSlider("Thread Count", 0, 100, 10, function(value)
    ClickerLib:SetThreadCount(value)
end)

ControlsSection:AddButton("Maximize Speed", function()
    ClickerLib.UIElements.ThreadSlider:Set(100)
    if not ClickerLib.Running then
        ClickerLib.UIElements.AutoClickToggle:Set(true)
    end
end)

ControlsSection:AddButton("Rebirth", function()
    ClickerLib:Rebirth()
end)

-- Reset stats function
ControlsSection:AddButton("Reset Stats", function()
    ClickerLib:ResetStats()
end)

-- Stats Section Elements
ClickerLib.UIElements.TotalClicksLabel = StatsSection:AddLabel("Total Clicks: 0")
ClickerLib.UIElements.CPSLabel = StatsSection:AddLabel("CPS: 0")
ClickerLib.UIElements.ThreadsLabel = StatsSection:AddLabel("Active Threads: 0")
ClickerLib.UIElements.StatusLabel = StatsSection:AddLabel("Status: Idle")

-- Config Section Elements
ConfigSection:AddSlider("Update Rate", 1, 10, 2, function(value)
    -- How quickly the UI updates (lower = more frequent updates)
    ClickerLib.UpdateRate = value / 10
end)

ConfigSection:AddDropdown("Click Mode", {"Normal", "Burst", "Gentle"}, "Normal", function(option)
    local mode = option:lower()
    ClickerLib:SetClickMode(mode)
end)

-- Advanced Section
AdvancedSection:AddTextbox("Remote Path", "Remotes.Clicker", function(value)
    ClickerLib:SetRemotePath(value)
end)

AdvancedSection:AddTextbox("Custom Args (JSON)", "", function(value)
    local success, result = pcall(function()
        -- Try to parse as JSON if provided
        if value and value ~= "" then
            -- Use HttpService to parse JSON if available
            if game:GetService("HttpService") then
                return game:GetService("HttpService"):JSONDecode(value)
            else
                -- Simple JSON array parser for numbers only
                local args = {}
                for arg in string.gmatch(value:gsub("%[", ""):gsub("%]", ""):gsub("%s+", ""), "[^,]+") do
                    table.insert(args, tonumber(arg) or arg)
                end
                return args
            end
        end
        return nil
    end)

    if success then
        ClickerLib:SetCustomArgs(result)
    end
end)

InfoSection:AddLabel("Zen Clicker v1.0 by smxa")
InfoSection:AddLabel("Press RightCtrl to toggle UI")
InfoSection:AddDivider()
InfoSection:AddLabel("Server-side click validation is active")
InfoSection:AddLabel("Be careful with high thread counts!")

-- update loop
task.spawn(function()
    while true do
        updateStats() -- Update stats regardless of running state
        task.wait(ClickerLib.UpdateRate)
    end
end)
