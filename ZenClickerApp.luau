local _RS = game:GetService("ReplicatedStorage")

local Remotes = {
    Clicker = _RS:WaitForChild("Remotes"):WaitForChild("Clicker"),
    Rebirth = _RS:WaitForChild("Remotes"):WaitForChild("Rebirth")
}

local function _HTTP_GET(url)
    ---@diagnostic disable-next-line: undefined-global
    if syn and syn.request then
        ---@diagnostic disable-next-line: undefined-global
        return syn.request({
            Url = url,
            Method = "GET"
        }).Body
        ---@diagnostic disable-next-line: undefined-global
    elseif http and http.request then
        ---@diagnostic disable-next-line: undefined-global
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

local ZenLib = loadstring(_HTTP_GET(
    "https://raw.githubusercontent.com/wafflehousefootjobplease/c/refs/heads/main/ui_lib_zen.luau"))()

-- ================ CLICKER CORE FUNCTIONALITY ================
local ClickerLib = {}
ClickerLib.Running = false
ClickerLib.UIElements = {}

local function updateStatus()
    if ClickerLib.UIElements.StatusLabel then
        ClickerLib.UIElements.StatusLabel:Set("Status: " .. (ClickerLib.Running and "Running" or "Idle"))
    end
end

function ClickerLib:Click()
    Remotes.Clicker:FireServer()
end

function ClickerLib:Rebirth()
    Remotes.Rebirth:FireServer()
    task.wait(0.1)
end

function ClickerLib:Start()
    if self.Running then
        return self
    end

    self.Running = true

    if self.ClickLoop then
        task.cancel(self.ClickLoop)
    end

    self.ClickLoop = task.spawn(function()
        while self.Running do
            self:Click()
            task.wait(0.01)
        end
    end)

    updateStatus()
    return self
end

function ClickerLib:Stop()
    self.Running = false

    if self.UIElements.AutoClickToggle and self.UIElements.AutoClickToggle.Value ~= self.Running then
        self.UIElements.AutoClickToggle:Set(false)
    end

    if self.ClickLoop then
        task.cancel(self.ClickLoop)
        self.ClickLoop = nil
    end

    updateStatus()
    return self
end

function ClickerLib:GetStatus()
    return {
        Running = self.Running
    }
end

-- ================ END CLICKER CORE FUNCTIONALITY ================

-- ================ UI CREATION ================
local Window = ZenLib:CreateWindow({
    Title = "Zen Clicker v1.1",
    Size = UDim2.new(0, 600, 0, 450),
    AccentColor = Color3.fromRGB(119, 0, 255)
})

local MainTab = Window:CreateTab("Main")
local ControlsSection = MainTab:CreateSection("Controls")
local RebirthSection = MainTab:CreateSection("Rebirth")
local StatusSection = MainTab:CreateSection("Status")
local InfoSection = MainTab:CreateSection("Information")

ClickerLib.UIElements.AutoClickToggle = ControlsSection:AddToggle("Auto Click", false, function(state)
    if state then
        ClickerLib:Start()
    else
        ClickerLib:Stop()
    end
end)

ClickerLib.UIElements.RebirthButton = RebirthSection:AddButton("Rebirth Now", function()
    task.spawn(function()
        local prevState = ClickerLib:GetStatus()
        if prevState.Running then
            ClickerLib:Stop()
            task.wait(0.3)
        end

        ClickerLib:Rebirth()

        if prevState.Running then
            task.wait(0.1)
            ClickerLib:Start()
        end
    end)
end)

ClickerLib.UIElements.StatusLabel = StatusSection:AddLabel("Status: Idle")

InfoSection:AddLabel("Zen Clicker v1.1 by smxa")
InfoSection:AddLabel("Press RightCtrl to toggle UI")

-- ================ END UI CREATION ================
