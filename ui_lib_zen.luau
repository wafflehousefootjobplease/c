local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

local ZenLib = {
    Toggled = true,
    Elements = {},
    Theme = {
        BackgroundColor = Color3.fromRGB(25, 25, 25),
        SectionColor = Color3.fromRGB(30, 30, 30),
        TextColor = Color3.fromRGB(255, 255, 255),
        AccentColor = Color3.fromRGB(85, 170, 255),
        OutlineColor = Color3.fromRGB(50, 50, 50),
        InfoColor = Color3.fromRGB(120, 120, 120)
    }
}

-- Utility Functions
local function CreateInstance(className, properties)
    local instance = Instance.new(className)
    for property, value in pairs(properties or {}) do
        instance[property] = value
    end
    return instance
end

local function MakeDraggable(topbarObject, object)
    local Dragging = nil
    local DragInput = nil
    local DragStart = nil
    local StartPosition = nil

    topbarObject.InputBegan:Connect(function(input)
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

    topbarObject.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            DragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == DragInput and Dragging then
            local Delta = input.Position - DragStart
            object.Position = UDim2.new(StartPosition.X.Scale, StartPosition.X.Offset + Delta.X, StartPosition.Y.Scale,
                StartPosition.Y.Offset + Delta.Y)
        end
    end)
end

function ZenLib:CreateWindow(config)
    config = config or {}
    config.Title = config.Title or "Zen UI"
    config.Size = config.Size or UDim2.new(0, 550, 0, 400)

    -- Remove existing GUI if exists
    if CoreGui:FindFirstChild("ZenLibUI") then
        CoreGui:FindFirstChild("ZenLibUI"):Destroy()
    end

    -- Main UI Components
    local UI = CreateInstance("ScreenGui", {
        Name = "ZenLibUI",
        Parent = CoreGui,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    })

    local Main = CreateInstance("Frame", {
        Name = "Main",
        Parent = UI,
        BackgroundColor3 = self.Theme.BackgroundColor,
        BorderColor3 = self.Theme.OutlineColor,
        BorderSizePixel = 1,
        Position = UDim2.new(0.5, -config.Size.X.Offset / 2, 0.5, -config.Size.Y.Offset / 2),
        Size = config.Size,
        ClipsDescendants = true
    })

    local UICorner = CreateInstance("UICorner", {
        CornerRadius = UDim.new(0, 6),
        Parent = Main
    })

    local Topbar = CreateInstance("Frame", {
        Name = "Topbar",
        Parent = Main,
        BackgroundColor3 = self.Theme.SectionColor,
        Size = UDim2.new(1, 0, 0, 30)
    })

    local TopbarCorner = CreateInstance("UICorner", {
        CornerRadius = UDim.new(0, 6),
        Parent = Topbar
    })

    local Title = CreateInstance("TextLabel", {
        Name = "Title",
        Parent = Topbar,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 0),
        Size = UDim2.new(0.5, 0, 1, 0),
        Font = Enum.Font.GothamBold,
        Text = config.Title,
        TextColor3 = self.Theme.TextColor,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    local CloseButton = CreateInstance("TextButton", {
        Name = "CloseButton",
        Parent = Topbar,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -25, 0, 5),
        Size = UDim2.new(0, 20, 0, 20),
        Font = Enum.Font.GothamBold,
        Text = "×",
        TextColor3 = self.Theme.TextColor,
        TextSize = 20
    })

    local MinimizeButton = CreateInstance("TextButton", {
        Name = "MinimizeButton",
        Parent = Topbar,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -50, 0, 5),
        Size = UDim2.new(0, 20, 0, 20),
        Font = Enum.Font.GothamBold,
        Text = "-",
        TextColor3 = self.Theme.TextColor,
        TextSize = 20
    })

    local TabHolder = CreateInstance("Frame", {
        Name = "TabHolder",
        Parent = Main,
        BackgroundColor3 = self.Theme.SectionColor,
        Position = UDim2.new(0, 10, 0, 40),
        Size = UDim2.new(0, 130, 1, -50)
    })

    local TabHolderCorner = CreateInstance("UICorner", {
        CornerRadius = UDim.new(0, 6),
        Parent = TabHolder
    })

    local TabList = CreateInstance("ScrollingFrame", {
        Name = "TabList",
        Parent = TabHolder,
        Active = true,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 10),
        Size = UDim2.new(1, 0, 1, -20),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 0,
        AutomaticCanvasSize = Enum.AutomaticSize.Y
    })

    local TabListLayout = CreateInstance("UIListLayout", {
        Parent = TabList,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 5)
    })

    local TabListPadding = CreateInstance("UIPadding", {
        Parent = TabList,
        PaddingLeft = UDim.new(0, 10),
        PaddingRight = UDim.new(0, 10)
    })

    local ContentContainer = CreateInstance("Frame", {
        Name = "ContentContainer",
        Parent = Main,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 150, 0, 40),
        Size = UDim2.new(1, -160, 1, -50)
    })

    -- Make the UI draggable
    MakeDraggable(Topbar, Main)

    -- UI Functions
    CloseButton.MouseButton1Click:Connect(function()
        UI:Destroy()
    end)

    local minimized = false
    MinimizeButton.MouseButton1Click:Connect(function()
        minimized = not minimized

        if minimized then
            Main:TweenSize(UDim2.new(0, config.Size.X.Offset, 0, 30), Enum.EasingDirection.Out, Enum.EasingStyle.Quart,
                0.3, true)
        else
            Main:TweenSize(config.Size, Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.3, true)
        end
    end)

    local Window = {}
    local Tabs = {}

    -- Create Tab Function
    function Window:CreateTab(name, icon)
        local TabButton = CreateInstance("TextButton", {
            Name = name .. "Tab",
            Parent = TabList,
            BackgroundColor3 = self.Theme and self.Theme.AccentColor or ZenLib.Theme.AccentColor,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 30),
            Font = Enum.Font.Gotham,
            Text = name,
            TextColor3 = ZenLib.Theme.TextColor,
            TextSize = 14
        })

        local TabButtonCorner = CreateInstance("UICorner", {
            CornerRadius = UDim.new(0, 6),
            Parent = TabButton
        })

        if icon then
            local TabIcon = CreateInstance("ImageLabel", {
                Name = "Icon",
                Parent = TabButton,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 5, 0.5, -10),
                Size = UDim2.new(0, 20, 0, 20),
                Image = icon
            })

            TabButton.TextXAlignment = Enum.TextXAlignment.Center
        end

        local TabContent = CreateInstance("ScrollingFrame", {
            Name = name .. "Content",
            Parent = ContentContainer,
            Active = true,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            CanvasSize = UDim2.new(0, 0, 0, 0),
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = ZenLib.Theme.AccentColor,
            Visible = false,
            AutomaticCanvasSize = Enum.AutomaticSize.Y
        })

        local ContentList = CreateInstance("UIListLayout", {
            Parent = TabContent,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 10)
        })

        local ContentPadding = CreateInstance("UIPadding", {
            Parent = TabContent,
            PaddingLeft = UDim.new(0, 10),
            PaddingRight = UDim.new(0, 10),
            PaddingTop = UDim.new(0, 10)
        })

        -- Tab Selection Logic
        TabButton.MouseButton1Click:Connect(function()
            for _, tab in pairs(Tabs) do
                tab.TabButton.BackgroundTransparency = 1
                tab.TabContent.Visible = false
            end

            TabButton.BackgroundTransparency = 0
            TabContent.Visible = true
        end)

        -- Auto-select first tab
        if #Tabs == 0 then
            TabButton.BackgroundTransparency = 0
            TabContent.Visible = true
        end

        local Tab = {
            TabButton = TabButton,
            TabContent = TabContent
        }

        table.insert(Tabs, Tab)

        -- Tab Elements
        function Tab:CreateSection(title)
            local Section = CreateInstance("Frame", {
                Name = title .. "Section",
                Parent = TabContent,
                BackgroundColor3 = ZenLib.Theme.SectionColor,
                Size = UDim2.new(1, 0, 0, 36), -- Dynamic height
                AutomaticSize = Enum.AutomaticSize.Y
            })

            local SectionCorner = CreateInstance("UICorner", {
                CornerRadius = UDim.new(0, 6),
                Parent = Section
            })

            local SectionTitle = CreateInstance("TextLabel", {
                Name = "Title",
                Parent = Section,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 0),
                Size = UDim2.new(1, -20, 0, 26),
                Font = Enum.Font.GothamBold,
                Text = title,
                TextColor3 = ZenLib.Theme.TextColor,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left
            })

            local SectionContainer = CreateInstance("Frame", {
                Name = "Container",
                Parent = Section,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 0, 0, 26),
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y
            })

            local SectionLayout = CreateInstance("UIListLayout", {
                Parent = SectionContainer,
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 8)
            })

            local SectionPadding = CreateInstance("UIPadding", {
                Parent = SectionContainer,
                PaddingLeft = UDim.new(0, 10),
                PaddingRight = UDim.new(0, 10),
                PaddingBottom = UDim.new(0, 10)
            })

            local SectionElements = {}

            -- Section Elements
            function SectionElements:AddButton(text, callback)
                callback = callback or function()
                end

                local Button = CreateInstance("TextButton", {
                    Name = text .. "Button",
                    Parent = SectionContainer,
                    BackgroundColor3 = ZenLib.Theme.AccentColor,
                    Size = UDim2.new(1, 0, 0, 32),
                    Font = Enum.Font.Gotham,
                    Text = text,
                    TextColor3 = ZenLib.Theme.TextColor,
                    TextSize = 14,
                    AutoButtonColor = false
                })

                local ButtonCorner = CreateInstance("UICorner", {
                    CornerRadius = UDim.new(0, 4),
                    Parent = Button
                })

                Button.MouseButton1Click:Connect(function()
                    callback()

                    -- Animation
                    Button.BackgroundColor3 = ZenLib.Theme.SectionColor
                    TweenService:Create(Button, TweenInfo.new(0.3), {
                        BackgroundColor3 = ZenLib.Theme.AccentColor
                    }):Play()
                end)

                return Button
            end

            function SectionElements:AddToggle(text, default, callback)
                default = default or false
                callback = callback or function()
                end

                local Toggle = CreateInstance("Frame", {
                    Name = text .. "Toggle",
                    Parent = SectionContainer,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 32)
                })

                local ToggleLabel = CreateInstance("TextLabel", {
                    Name = "Label",
                    Parent = Toggle,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 0, 0, 0),
                    Size = UDim2.new(1, -50, 1, 0),
                    Font = Enum.Font.Gotham,
                    Text = text,
                    TextColor3 = ZenLib.Theme.TextColor,
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Left
                })

                local ToggleButton = CreateInstance("Frame", {
                    Name = "Button",
                    Parent = Toggle,
                    BackgroundColor3 = default and ZenLib.Theme.AccentColor or ZenLib.Theme.SectionColor,
                    Position = UDim2.new(1, -40, 0.5, -10),
                    Size = UDim2.new(0, 40, 0, 20)
                })

                local ToggleButtonCorner = CreateInstance("UICorner", {
                    CornerRadius = UDim.new(0, 10),
                    Parent = ToggleButton
                })

                local ToggleCircle = CreateInstance("Frame", {
                    Name = "Circle",
                    Parent = ToggleButton,
                    BackgroundColor3 = ZenLib.Theme.TextColor,
                    Position = UDim2.new(default and 0.5 or 0, default and 0 or 2, 0.5, -8),
                    Size = UDim2.new(0, 16, 0, 16)
                })

                local ToggleCircleCorner = CreateInstance("UICorner", {
                    CornerRadius = UDim.new(1, 0),
                    Parent = ToggleCircle
                })

                local ToggleClickArea = CreateInstance("TextButton", {
                    Name = "ClickArea",
                    Parent = Toggle,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    Text = ""
                })

                local toggled = default

                ToggleClickArea.MouseButton1Click:Connect(function()
                    toggled = not toggled

                    if toggled then
                        TweenService:Create(ToggleButton, TweenInfo.new(0.2), {
                            BackgroundColor3 = ZenLib.Theme.AccentColor
                        }):Play()
                        TweenService:Create(ToggleCircle, TweenInfo.new(0.2), {
                            Position = UDim2.new(0.5, 0, 0.5, -8)
                        }):Play()
                    else
                        TweenService:Create(ToggleButton, TweenInfo.new(0.2), {
                            BackgroundColor3 = ZenLib.Theme.SectionColor
                        }):Play()
                        TweenService:Create(ToggleCircle, TweenInfo.new(0.2), {
                            Position = UDim2.new(0, 2, 0.5, -8)
                        }):Play()
                    end

                    callback(toggled)
                end)

                local ToggleObj = {
                    Value = default,
                    Set = function(self, value)
                        toggled = value
                        if toggled then
                            TweenService:Create(ToggleButton, TweenInfo.new(0.2), {
                                BackgroundColor3 = ZenLib.Theme.AccentColor
                            }):Play()
                            TweenService:Create(ToggleCircle, TweenInfo.new(0.2), {
                                Position = UDim2.new(0.5, 0, 0.5, -8)
                            }):Play()
                        else
                            TweenService:Create(ToggleButton, TweenInfo.new(0.2), {
                                BackgroundColor3 = ZenLib.Theme.SectionColor
                            }):Play()
                            TweenService:Create(ToggleCircle, TweenInfo.new(0.2), {
                                Position = UDim2.new(0, 2, 0.5, -8)
                            }):Play()
                        end
                        callback(toggled)
                        self.Value = toggled
                    end
                }

                return ToggleObj
            end

            function SectionElements:AddSlider(text, min, max, default, callback)
                min = min or 0
                max = max or 100
                default = default or min
                callback = callback or function()
                end

                local Slider = CreateInstance("Frame", {
                    Name = text .. "Slider",
                    Parent = SectionContainer,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 50)
                })

                local SliderLabel = CreateInstance("TextLabel", {
                    Name = "Label",
                    Parent = Slider,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 0, 0, 0),
                    Size = UDim2.new(1, -50, 0, 20),
                    Font = Enum.Font.Gotham,
                    Text = text,
                    TextColor3 = ZenLib.Theme.TextColor,
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Left
                })

                local SliderValue = CreateInstance("TextLabel", {
                    Name = "Value",
                    Parent = Slider,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(1, -45, 0, 0),
                    Size = UDim2.new(0, 45, 0, 20),
                    Font = Enum.Font.Gotham,
                    Text = tostring(default),
                    TextColor3 = ZenLib.Theme.TextColor,
                    TextSize = 14
                })

                local SliderBg = CreateInstance("Frame", {
                    Name = "Background",
                    Parent = Slider,
                    BackgroundColor3 = ZenLib.Theme.SectionColor,
                    Position = UDim2.new(0, 0, 0, 25),
                    Size = UDim2.new(1, 0, 0, 8)
                })

                local SliderBgCorner = CreateInstance("UICorner", {
                    CornerRadius = UDim.new(0, 4),
                    Parent = SliderBg
                })

                local SliderFill = CreateInstance("Frame", {
                    Name = "Fill",
                    Parent = SliderBg,
                    BackgroundColor3 = ZenLib.Theme.AccentColor,
                    Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
                })

                local SliderFillCorner = CreateInstance("UICorner", {
                    CornerRadius = UDim.new(0, 4),
                    Parent = SliderFill
                })

                local SliderButton = CreateInstance("TextButton", {
                    Name = "Button",
                    Parent = SliderBg,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    Text = ""
                })

                local function updateSlider(input)
                    local sizeX = math.clamp((input.Position.X - SliderBg.AbsolutePosition.X) / SliderBg.AbsoluteSize.X,
                        0, 1)
                    local value = math.floor(min + (max - min) * sizeX)

                    SliderValue.Text = tostring(value)
                    SliderFill:TweenSize(UDim2.new(sizeX, 0, 1, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quad,
                        0.1, true)

                    callback(value)
                    return value
                end

                SliderButton.MouseButton1Down:Connect(function()
                    local value = updateSlider({
                        Position = UserInputService:GetMouseLocation()
                    })

                    local connection
                    connection = RunService.RenderStepped:Connect(function()
                        if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
                            value = updateSlider({
                                Position = UserInputService:GetMouseLocation()
                            })
                        else
                            connection:Disconnect()
                        end
                    end)
                end)

                local SliderObj = {
                    Value = default,
                    Min = min,
                    Max = max,
                    Set = function(self, value)
                        value = math.clamp(value, min, max)
                        SliderValue.Text = tostring(value)
                        SliderFill:TweenSize(UDim2.new((value - min) / (max - min), 0, 1, 0), Enum.EasingDirection.Out,
                            Enum.EasingStyle.Quad, 0.1, true)
                        callback(value)
                        self.Value = value
                    end
                }

                return SliderObj
            end

            function SectionElements:AddDropdown(text, options, default, callback)
                options = options or {}
                default = default or options[1]
                callback = callback or function()
                end

                local Dropdown = CreateInstance("Frame", {
                    Name = text .. "Dropdown",
                    Parent = SectionContainer,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 40)
                })

                local DropdownLabel = CreateInstance("TextLabel", {
                    Name = "Label",
                    Parent = Dropdown,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 0, 0, 0),
                    Size = UDim2.new(1, 0, 0, 20),
                    Font = Enum.Font.Gotham,
                    Text = text,
                    TextColor3 = ZenLib.Theme.TextColor,
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Left
                })

                local DropdownButton = CreateInstance("TextButton", {
                    Name = "Button",
                    Parent = Dropdown,
                    BackgroundColor3 = ZenLib.Theme.SectionColor,
                    Position = UDim2.new(0, 0, 0, 20),
                    Size = UDim2.new(1, 0, 0, 20),
                    Font = Enum.Font.Gotham,
                    Text = default or "Select...",
                    TextColor3 = ZenLib.Theme.TextColor,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left
                })

                local DropdownButtonPadding = CreateInstance("UIPadding", {
                    Parent = DropdownButton,
                    PaddingLeft = UDim.new(0, 10)
                })

                local DropdownButtonCorner = CreateInstance("UICorner", {
                    CornerRadius = UDim.new(0, 4),
                    Parent = DropdownButton
                })

                local DropdownIcon = CreateInstance("ImageLabel", {
                    Name = "Icon",
                    Parent = DropdownButton,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(1, -20, 0.5, -8),
                    Size = UDim2.new(0, 16, 0, 16),
                    Rotation = 0,
                    Image = "rbxassetid://3926307971",
                    ImageRectOffset = Vector2.new(324, 524),
                    ImageRectSize = Vector2.new(36, 36)
                })

                local DropdownContent = CreateInstance("Frame", {
                    Name = "Content",
                    Parent = Dropdown,
                    BackgroundColor3 = ZenLib.Theme.SectionColor,
                    Position = UDim2.new(0, 0, 0, 42),
                    Size = UDim2.new(1, 0, 0, 0),
                    Visible = false,
                    ClipsDescendants = true,
                    ZIndex = 5
                })

                local DropdownContentCorner = CreateInstance("UICorner", {
                    CornerRadius = UDim.new(0, 4),
                    Parent = DropdownContent
                })

                local DropdownOptionsList = CreateInstance("ScrollingFrame", {
                    Name = "OptionsList",
                    Parent = DropdownContent,
                    Active = true,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 0, 0, 0),
                    Size = UDim2.new(1, 0, 1, 0),
                    CanvasSize = UDim2.new(0, 0, 0, 0),
                    ScrollBarThickness = 3,
                    ScrollBarImageColor3 = ZenLib.Theme.AccentColor,
                    ZIndex = 5,
                    AutomaticCanvasSize = Enum.AutomaticSize.Y
                })

                local OptionsListLayout = CreateInstance("UIListLayout", {
                    Parent = DropdownOptionsList,
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Padding = UDim.new(0, 2)
                })

                local OptionsListPadding = CreateInstance("UIPadding", {
                    Parent = DropdownOptionsList,
                    PaddingLeft = UDim.new(0, 5),
                    PaddingRight = UDim.new(0, 5),
                    PaddingTop = UDim.new(0, 5),
                    PaddingBottom = UDim.new(0, 5)
                })

                -- Create dropdown options
                local dropped = false
                local optionButtons = {}

                local function updateDropdown()
                    for _, option in ipairs(optionButtons) do
                        option:Destroy()
                    end
                    optionButtons = {}

                    local optionHeight = 25
                    local contentHeight = math.min(#options * (optionHeight + 2) + 10, 150)

                    for i, option in ipairs(options) do
                        local OptionButton = CreateInstance("TextButton", {
                            Name = "Option" .. i,
                            Parent = DropdownOptionsList,
                            BackgroundColor3 = ZenLib.Theme.BackgroundColor,
                            Size = UDim2.new(1, -10, 0, optionHeight),
                            Font = Enum.Font.Gotham,
                            Text = option,
                            TextColor3 = ZenLib.Theme.TextColor,
                            TextSize = 12,
                            ZIndex = 6
                        })

                        local OptionButtonCorner = CreateInstance("UICorner", {
                            CornerRadius = UDim.new(0, 4),
                            Parent = OptionButton
                        })

                        OptionButton.MouseButton1Click:Connect(function()
                            DropdownButton.Text = option
                            dropped = false
                            DropdownContent:TweenSize(UDim2.new(1, 0, 0, 0), Enum.EasingDirection.Out,
                                Enum.EasingStyle.Quart, 0.2, true, function()
                                    DropdownContent.Visible = false
                                end)

                            TweenService:Create(DropdownIcon, TweenInfo.new(0.2), {
                                Rotation = 0
                            }):Play()
                            callback(option)
                        end)

                        OptionButton.MouseEnter:Connect(function()
                            TweenService:Create(OptionButton, TweenInfo.new(0.2), {
                                BackgroundColor3 = ZenLib.Theme.AccentColor
                            }):Play()
                        end)

                        OptionButton.MouseLeave:Connect(function()
                            TweenService:Create(OptionButton, TweenInfo.new(0.2), {
                                BackgroundColor3 = ZenLib.Theme.BackgroundColor
                            }):Play()
                        end)

                        table.insert(optionButtons, OptionButton)
                    end

                    DropdownContent.Size = UDim2.new(1, 0, 0, contentHeight)
                end

                updateDropdown()

                DropdownButton.MouseButton1Click:Connect(function()
                    dropped = not dropped

                    if dropped then
                        DropdownContent.Visible = true
                        DropdownContent:TweenSize(UDim2.new(1, 0, 0, math.min(#options * 27 + 10, 150)),
                            Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.2, true)

                        TweenService:Create(DropdownIcon, TweenInfo.new(0.2), {
                            Rotation = 180
                        }):Play()
                    else
                        DropdownContent:TweenSize(UDim2.new(1, 0, 0, 0), Enum.EasingDirection.Out,
                            Enum.EasingStyle.Quart, 0.2, true, function()
                                DropdownContent.Visible = false
                            end)

                        TweenService:Create(DropdownIcon, TweenInfo.new(0.2), {
                            Rotation = 0
                        }):Play()
                    end
                end)

                local DropdownObj = {
                    Value = default,
                    Options = options,
                    Set = function(self, value)
                        if table.find(options, value) then
                            DropdownButton.Text = value
                            self.Value = value
                            callback(value)
                        end
                    end,
                    SetOptions = function(self, newOptions, newValue)
                        options = newOptions
                        updateDropdown()

                        if newValue then
                            self:Set(newValue)
                        elseif not table.find(newOptions, self.Value) and #newOptions > 0 then
                            self:Set(newOptions[1])
                        end
                    end,
                    AddOption = function(self, option)
                        if not table.find(options, option) then
                            table.insert(options, option)
                            updateDropdown()
                        end
                    end,
                    RemoveOption = function(self, option)
                        local index = table.find(options, option)
                        if index then
                            table.remove(options, index)
                            updateDropdown()

                            if self.Value == option and #options > 0 then
                                self:Set(options[1])
                            end
                        end
                    end
                }

                if default and table.find(options, default) then
                    DropdownButton.Text = default
                    callback(default)
                elseif #options > 0 then
                    DropdownButton.Text = options[1]
                    DropdownObj.Value = options[1]
                    callback(options[1])
                end

                return DropdownObj
            end

            function SectionElements:AddColorPicker(text, default, callback)
                default = default or Color3.fromRGB(255, 255, 255)
                callback = callback or function()
                end

                local ColorPicker = CreateInstance("Frame", {
                    Name = text .. "ColorPicker",
                    Parent = SectionContainer,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 40)
                })

                local ColorLabel = CreateInstance("TextLabel", {
                    Name = "Label",
                    Parent = ColorPicker,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 0, 0, 0),
                    Size = UDim2.new(1, -40, 1, 0),
                    Font = Enum.Font.Gotham,
                    Text = text,
                    TextColor3 = ZenLib.Theme.TextColor,
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Left
                })

                local ColorDisplay = CreateInstance("Frame", {
                    Name = "Display",
                    Parent = ColorPicker,
                    BackgroundColor3 = default,
                    Position = UDim2.new(1, -30, 0.5, -10),
                    Size = UDim2.new(0, 30, 0, 20)
                })

                local ColorDisplayCorner = CreateInstance("UICorner", {
                    CornerRadius = UDim.new(0, 4),
                    Parent = ColorDisplay
                })

                local ColorPickerArea = CreateInstance("Frame", {
                    Name = "PickerArea",
                    Parent = ColorPicker,
                    BackgroundColor3 = ZenLib.Theme.SectionColor,
                    Position = UDim2.new(0, 0, 1, 5),
                    Size = UDim2.new(1, 0, 0, 120),
                    Visible = false,
                    ZIndex = 10
                })

                local ColorPickerAreaCorner = CreateInstance("UICorner", {
                    CornerRadius = UDim.new(0, 4),
                    Parent = ColorPickerArea
                })

                -- Simplified color picker implementation
                local ColorHSV = CreateInstance("ImageLabel", {
                    Name = "ColorHSV",
                    Parent = ColorPickerArea,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, 10),
                    Size = UDim2.new(1, -60, 0, 100),
                    Image = "rbxassetid://6523286724",
                    ZIndex = 11
                })

                local ColorSaturation = CreateInstance("ImageLabel", {
                    Name = "Saturation",
                    Parent = ColorPickerArea,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(1, -40, 0, 10),
                    Size = UDim2.new(0, 30, 0, 100),
                    Image = "rbxassetid://3641079629",
                    ZIndex = 11
                })

                local ColorSelector = CreateInstance("TextButton", {
                    Name = "Selector",
                    Parent = ColorPickerArea,
                    Text = "",
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, 10),
                    Size = UDim2.new(1, -60, 0, 100),
                    ZIndex = 12
                })

                local SaturationSelector = CreateInstance("TextButton", {
                    Name = "SatSelector",
                    Parent = ColorPickerArea,
                    Text = "",
                    BackgroundTransparency = 1,
                    Position = UDim2.new(1, -40, 0, 10),
                    Size = UDim2.new(0, 30, 0, 100),
                    ZIndex = 12
                })

                local H, S, V = Color3.toHSV(default)
                local color = default
                local opened = false

                local function updateColor()
                    color = Color3.fromHSV(H, S, V)
                    ColorDisplay.BackgroundColor3 = color
                    callback(color)
                end

                ColorDisplay.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        opened = not opened
                        ColorPickerArea.Visible = opened
                    end
                end)

                SaturationSelector.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        local satConnection
                        satConnection = RunService.RenderStepped:Connect(function()
                            if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
                                local satY = (UserInputService:GetMouseLocation().Y -
                                                 SaturationSelector.AbsolutePosition.Y) /
                                                 SaturationSelector.AbsoluteSize.Y
                                satY = math.clamp(satY, 0, 1)
                                V = 1 - satY
                                updateColor()
                            else
                                satConnection:Disconnect()
                            end
                        end)
                    end
                end)

                ColorSelector.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        local colorConnection
                        colorConnection = RunService.RenderStepped:Connect(function()
                            if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
                                local colorX =
                                    (UserInputService:GetMouseLocation().X - ColorSelector.AbsolutePosition.X) /
                                        ColorSelector.AbsoluteSize.X
                                local colorY =
                                    (UserInputService:GetMouseLocation().Y - ColorSelector.AbsolutePosition.Y) /
                                        ColorSelector.AbsoluteSize.Y

                                colorX = math.clamp(colorX, 0, 1)
                                colorY = math.clamp(colorY, 0, 1)

                                H = colorX
                                S = 1 - colorY

                                updateColor()
                            else
                                colorConnection:Disconnect()
                            end
                        end)
                    end
                end)

                return {
                    Value = color,
                    Set = function(self, newColor)
                        H, S, V = Color3.toHSV(newColor)
                        updateColor()
                        self.Value = color
                    end
                }
            end

            function SectionElements:AddTextbox(text, default, callback)
                default = default or ""
                callback = callback or function()
                end

                local Textbox = CreateInstance("Frame", {
                    Name = text .. "Textbox",
                    Parent = SectionContainer,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 40)
                })

                local TextboxLabel = CreateInstance("TextLabel", {
                    Name = "Label",
                    Parent = Textbox,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 0, 0, 0),
                    Size = UDim2.new(1, 0, 0, 20),
                    Font = Enum.Font.Gotham,
                    Text = text,
                    TextColor3 = ZenLib.Theme.TextColor,
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Left
                })

                local TextboxInput = CreateInstance("TextBox", {
                    Name = "Input",
                    Parent = Textbox,
                    BackgroundColor3 = ZenLib.Theme.SectionColor,
                    Position = UDim2.new(0, 0, 0, 20),
                    Size = UDim2.new(1, 0, 0, 20),
                    Font = Enum.Font.Gotham,
                    Text = default,
                    TextColor3 = ZenLib.Theme.TextColor,
                    TextSize = 12,
                    TextWrapped = true,
                    ClearTextOnFocus = false,
                    ClipsDescendants = true
                })

                local TextboxInputCorner = CreateInstance("UICorner", {
                    CornerRadius = UDim.new(0, 4),
                    Parent = TextboxInput
                })

                local TextboxPadding = CreateInstance("UIPadding", {
                    Parent = TextboxInput,
                    PaddingLeft = UDim.new(0, 10),
                    PaddingRight = UDim.new(0, 10)
                })

                TextboxInput.FocusLost:Connect(function(enterPressed)
                    callback(TextboxInput.Text)
                end)

                return {
                    Value = default,
                    Set = function(self, value)
                        TextboxInput.Text = value
                        self.Value = value
                        callback(value)
                    end
                }
            end

            function SectionElements:AddLabel(text)
                local Label = CreateInstance("TextLabel", {
                    Name = "Label",
                    Parent = SectionContainer,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 20),
                    Font = Enum.Font.Gotham,
                    Text = text,
                    TextColor3 = ZenLib.Theme.TextColor,
                    TextSize = 14,
                    TextWrapped = true,
                    TextXAlignment = Enum.TextXAlignment.Left
                })

                return {
                    Set = function(self, value)
                        Label.Text = value
                    end
                }
            end

            function SectionElements:AddDivider()
                local Divider = CreateInstance("Frame", {
                    Name = "Divider",
                    Parent = SectionContainer,
                    BackgroundColor3 = ZenLib.Theme.OutlineColor,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 0, 1)
                })

                return Divider
            end

            return SectionElements
        end

        return Tab
    end

    return Window
end

-- Keyboard shortcuts
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.RightControl then
        ZenLib.Toggled = not ZenLib.Toggled

        for _, element in pairs(ZenLib.Elements) do
            if element.Instance then
                element.Instance.Visible = ZenLib.Toggled
            end
        end
    end
end)

return ZenLib
