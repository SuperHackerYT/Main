-- Viewport size metatable (Width, Height, Size)
local Screen = setmetatable({}, {__index = function(_, k)
    local cam = workspace.CurrentCamera
    local size = cam and cam.ViewportSize or Vector2.new(1920, 1080)
    if k == "Width" then return size.X
    elseif k == "Height" then return size.Y
    elseif k == "Size" then return size
    end
end})

local UserInputService = game:GetService("UserInputService")
local ViewportSize = workspace.CurrentCamera.ViewportSize

-- Scale a pixel value to screen size (mobile gets 2x, desktop 1.5x)
local function ScalePixel(axis, value)
    local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
    local baseWidth, baseHeight = 1920, 1080
    local multiplier = isMobile and 2 or 1.5
    if axis == "X" then return value * (ViewportSize.X / baseWidth) * multiplier
    elseif axis == "Y" then return value * (ViewportSize.Y / baseHeight) * multiplier
    end
end

-- Type-safe value getter
local function SafeGet(expectedType, value, fallback)
    if type(value) == expectedType then return value end
    return fallback
end

-- Safe cloneref wrapper
local CloneRef = SafeGet("function", cloneref, function(...) return ... end)

-- Service cache
local Services = setmetatable({}, {__index = function(_, name)
    return CloneRef(game:GetService(name))
end})

local Players          = Services.Players
local RunService       = Services.RunService
local InputService     = Services.UserInputService
local TweenService     = Services.TweenService
local AvatarEditor     = Services.AvatarEditorService
local HttpService      = Services.HttpService

-- Local player & character
local LocalPlayer    = Players.LocalPlayer
local Character      = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid       = Character:WaitForChild("Humanoid")
local IsR6           = Humanoid.RigType == Enum.HumanoidRigType.R6
local LastPosition   = Character.PrimaryPart and Character.PrimaryPart.Position or Vector3.new()

-- Forward refs for CharacterAdded
local TitleLabel_Ref, CatalogTabBtn_Ref, SavedTabBtn_Ref, CatalogPanel_Ref, SavedPanel_Ref

LocalPlayer.CharacterAdded:Connect(function(newChar)
    Character = newChar
    Humanoid = newChar:WaitForChild("Humanoid")
    IsR6 = Humanoid.RigType == Enum.HumanoidRigType.R6

    if TitleLabel_Ref  then TitleLabel_Ref.Text  = IsR6 and "Emote Player" or "Emote Player" end
    if CatalogTabBtn_Ref then CatalogTabBtn_Ref.Text = IsR6 and "Anim" or "Catalog" end
    if SavedTabBtn_Ref  then SavedTabBtn_Ref.Visible = not IsR6 end

    if IsR6 and CatalogPanel_Ref and SavedPanel_Ref then
        CatalogPanel_Ref.Visible = true
        SavedPanel_Ref.Visible   = false
        CatalogTabBtn_Ref.BackgroundColor3 = Color3.fromRGB(30, 30, 80)
        SavedTabBtn_Ref.BackgroundColor3   = Color3.fromRGB(20, 50, 20)
    end

    LastPosition = Character.PrimaryPart and Character.PrimaryPart.Position or Vector3.new()
end)

-- Animation playback settings
local AnimSettings = {}
AnimSettings["Stop Emote When Moving"]    = true
AnimSettings["Fade In"]                   = 0.1
AnimSettings["Fade Out"]                  = 0.1
AnimSettings["Weight"]                    = 1
AnimSettings["Speed"]                     = 1
AnimSettings["Time Position"]             = 0
AnimSettings["Freeze On Finish"]          = false
AnimSettings["Looped"]                    = true
AnimSettings["Stop Other Animations On Play"] = true
AnimSettings["High Priority"]             = true

local SavedEmotes = {}
local SaveFileName = "GazeEmotes_NewNEWN3WSaved.json"

-- Load saved emotes from file
local function LoadSaved()
    local ok, result = pcall(function()
        if readfile and isfile and isfile(SaveFileName) then
            return HttpService:JSONDecode(readfile(SaveFileName))
        end
        return {}
    end)
    if ok and type(result) == "table" then
        SavedEmotes = result
    else
        SavedEmotes = {}
    end
    for _, emote in ipairs(SavedEmotes) do
        if not emote.AnimationId then
            if emote.AssetId then
                emote.AnimationId = "rbxassetid://" .. tostring(emote.AssetId)
            else
                emote.AnimationId = "rbxassetid://" .. tostring(emote.Id)
            end
        end
        if emote.Favorite == nil then emote.Favorite = false end
    end
end

-- Persist saved emotes to file
local function SaveToFile()
    pcall(function()
        if writefile then
            writefile(SaveFileName, HttpService:JSONEncode(SavedEmotes))
        end
    end)
end

LoadSaved()

local CurrentTrack = nil

-- Play an animation by asset ID
local function PlayAnimation(assetId)
    if CurrentTrack then CurrentTrack:Stop(AnimSettings["Fade Out"]) end

    local resolvedId
    local ok, objects = pcall(function()
        return game:GetObjects("rbxassetid://" .. tostring(assetId))
    end)
    if ok and objects and #objects > 0 then
        local obj = objects[1]
        if obj:IsA("Animation") then
            resolvedId = obj.AnimationId
        else
            resolvedId = "rbxassetid://" .. tostring(assetId)
        end
    else
        resolvedId = "rbxassetid://" .. tostring(assetId)
    end

    local animInstance   = Instance.new("Animation")
    animInstance.AnimationId = resolvedId
    local track = Humanoid:LoadAnimation(animInstance)

    local priority = AnimSettings["High Priority"] and Enum.AnimationPriority.Action4 or Enum.AnimationPriority.Action
    track.Priority = priority

    local weight = AnimSettings["Weight"]
    if weight == 0 then weight = 0.001 end

    if AnimSettings["Stop Other Animations On Play"] then
        for _, playing in pairs(Humanoid.Animator:GetPlayingAnimationTracks()) do
            if playing.Priority ~= priority then playing:Stop() end
        end
    end

    track:Play(AnimSettings["Fade In"], weight, AnimSettings["Speed"])
    CurrentTrack = track
    CurrentTrack.TimePosition = math.clamp(AnimSettings["Time Position"], 0, 1) * (CurrentTrack.Length or 1)
    CurrentTrack.Priority = priority
    CurrentTrack.Looped   = AnimSettings["Looped"]
    return track
end

-- Stop emote when character moves / jumps
RunService.RenderStepped:Connect(function()
    if AnimSettings["Looped"] and CurrentTrack and CurrentTrack.IsPlaying then
        CurrentTrack.Looped = AnimSettings["Looped"]
    end
    if Character:FindFirstChild("HumanoidRootPart") then
        local hrp = Character.HumanoidRootPart
        if AnimSettings["Stop Emote When Moving"] and CurrentTrack and CurrentTrack.IsPlaying then
            local moved   = (hrp.Position - LastPosition).Magnitude > 0.1
            local jumping = Humanoid and Humanoid:GetState() == Enum.HumanoidStateType.Jumping
            if moved or jumping then
                CurrentTrack:Stop(AnimSettings["Fade Out"])
                CurrentTrack = nil
            end
        end
        LastPosition = hrp.Position
    end
end)

-- GUI setup
local CoreGui   = Services.CoreGui
local MainGui   = Instance.new("ScreenGui")
MainGui.Name    = "GazeEmoteGUI"
MainGui.Parent  = CoreGui
MainGui.Enabled = false
MainGui.DisplayOrder = 999

-- Helper: add rounded corners
local function AddCorner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 6)
    corner.Parent = parent
    return corner
end

-- Helper: add border stroke
local function AddStroke(parent, color, thickness)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color or Color3.fromRGB(60, 120, 200)
    stroke.Thickness = thickness or 1
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = parent
    return stroke
end

-- Helper: pop-in scale animation
local function PopIn(parent)
    local uiScale = Instance.new("UIScale")
    uiScale.Scale = 0.5
    uiScale.Parent = parent
    TweenService:Create(uiScale, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Scale = 1}):Play()
end

-- Main window frame
local MainFrame = Instance.new("Frame")
MainFrame.Size                = UDim2.new(0, ScalePixel("X", 470), 0, ScalePixel("Y", 450))
MainFrame.Position            = UDim2.new(0.5, -ScalePixel("X", 325), 0.5, -ScalePixel("Y", 225))
MainFrame.BackgroundColor3    = Color3.fromRGB(15, 15, 20)
MainFrame.BackgroundTransparency = 0.15
MainFrame.Active              = true
MainFrame.Draggable           = true
MainFrame.Parent              = MainGui
AddCorner(MainFrame, 8)
AddStroke(MainFrame, Color3.fromRGB(80, 80, 120), 1.5)

-- Resize handle button (bottom-right corner)
local ResizeHandle = Instance.new("TextButton")
ResizeHandle.Size                = UDim2.new(0, 24, 0, 24)
ResizeHandle.Position            = UDim2.new(1, -24, 1, -24)
ResizeHandle.BackgroundTransparency = 1
ResizeHandle.Text                = "◢"
ResizeHandle.TextColor3          = Color3.fromRGB(100, 100, 140)
ResizeHandle.TextSize            = 18
ResizeHandle.ZIndex              = 10
ResizeHandle.Parent              = MainFrame

-- Resize drag logic
local isResizing    = false
local resizeDragStart
local resizeInitialSize

ResizeHandle.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isResizing      = true
        resizeDragStart = input.Position
        resizeInitialSize = MainFrame.AbsoluteSize
    end
end)
InputService.InputChanged:Connect(function(input)
    if isResizing and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - resizeDragStart
        local newW  = math.max(150, resizeInitialSize.X + delta.X)
        local newH  = math.max(100, resizeInitialSize.Y + delta.Y)
        MainFrame.Size = UDim2.new(0, newW, 0, newH)
    end
end)
InputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isResizing = false
    end
end)

-- Title label
local TitleLabel = Instance.new("TextLabel")
TitleLabel_Ref = TitleLabel
TitleLabel.Size                = UDim2.new(1, 0, 0, ScalePixel("Y", 36))
TitleLabel.BackgroundColor3    = Color3.fromRGB(20, 20, 25)
TitleLabel.BackgroundTransparency = 0.5
TitleLabel.Text                = IsR6 and "Emote Player (R6)" or "Emote Player"
TitleLabel.TextColor3          = Color3.new(1, 1, 1)
TitleLabel.Font                = Enum.Font.GothamBold
TitleLabel.TextScaled          = true
TitleLabel.Parent              = MainFrame
AddCorner(TitleLabel, 8)

-- "Catalog / Anim" tab button
local CatalogTabBtn = Instance.new("TextButton")
CatalogTabBtn_Ref = CatalogTabBtn
CatalogTabBtn.Size                = UDim2.new(0.3, 0, 0, ScalePixel("Y", 24))
CatalogTabBtn.Position            = UDim2.new(0.05, 0, 0, ScalePixel("Y", 40))
CatalogTabBtn.BackgroundColor3    = Color3.fromRGB(30, 30, 80)
CatalogTabBtn.BackgroundTransparency = 0.2
CatalogTabBtn.Text                = IsR6 and "Animation" or "Catalog"
CatalogTabBtn.TextColor3          = Color3.new(1, 1, 1)
CatalogTabBtn.Font                = Enum.Font.GothamBold
CatalogTabBtn.TextScaled          = true
CatalogTabBtn.Parent              = MainFrame
AddCorner(CatalogTabBtn, 4)

-- "Saved" tab button
local SavedTabBtn = Instance.new("TextButton")
SavedTabBtn_Ref = SavedTabBtn
SavedTabBtn.Size                = UDim2.new(0.3, 0, 0, ScalePixel("Y", 24))
SavedTabBtn.Position            = UDim2.new(0.35, 0, 0, ScalePixel("Y", 40))
SavedTabBtn.BackgroundColor3    = Color3.fromRGB(30, 80, 30)
SavedTabBtn.BackgroundTransparency = 0.2
SavedTabBtn.Text                = "Saved"
SavedTabBtn.TextColor3          = Color3.new(1, 1, 1)
SavedTabBtn.Font                = Enum.Font.GothamBold
SavedTabBtn.TextScaled          = true
SavedTabBtn.Visible             = not IsR6
SavedTabBtn.Parent              = MainFrame
AddCorner(SavedTabBtn, 4)

-- Vertical divider between left panel and settings
local Divider = Instance.new("Frame")
Divider.Size                = UDim2.new(0, ScalePixel("X", 2), 1, -ScalePixel("Y", 70))
Divider.Position            = UDim2.new(0.6, -ScalePixel("X", 1), 0, ScalePixel("Y", 70))
Divider.BackgroundColor3    = Color3.fromRGB(50, 50, 70)
Divider.BackgroundTransparency = 0.5
Divider.Parent              = MainFrame

-- Catalog panel (left side)
local CatalogPanel = Instance.new("Frame")
CatalogPanel_Ref = CatalogPanel
CatalogPanel.Size                = UDim2.new(0.6, -ScalePixel("X", 10), 1, -ScalePixel("Y", 70))
CatalogPanel.Position            = UDim2.new(0, ScalePixel("X", 5), 0, ScalePixel("Y", 70))
CatalogPanel.BackgroundTransparency = 1
CatalogPanel.Visible             = true
CatalogPanel.Parent              = MainFrame

-- Catalog search box
local CatalogSearchBox = Instance.new("TextBox")
CatalogSearchBox.Size                = UDim2.new(0.6, -ScalePixel("X", 8), 0, ScalePixel("Y", 28))
CatalogSearchBox.Position            = UDim2.new(0, ScalePixel("X", 8), 0, 0)
CatalogSearchBox.PlaceholderText     = "Search..."
CatalogSearchBox.BackgroundColor3    = Color3.fromRGB(20, 20, 25)
CatalogSearchBox.BackgroundTransparency = 0.3
CatalogSearchBox.TextColor3          = Color3.new(1, 1, 1)
CatalogSearchBox.Font                = Enum.Font.Gotham
CatalogSearchBox.TextScaled          = true
CatalogSearchBox.ClearTextOnFocus    = false
CatalogSearchBox.Text                = ""
CatalogSearchBox.Parent              = CatalogPanel
AddCorner(CatalogSearchBox, 4)
AddStroke(CatalogSearchBox, Color3.fromRGB(50, 50, 70), 1)

-- Refresh button
local RefreshBtn = Instance.new("TextButton")
RefreshBtn.Size                = UDim2.new(0.2, -ScalePixel("X", 4), 0, ScalePixel("Y", 28))
RefreshBtn.Position            = UDim2.new(0.6, ScalePixel("X", 4), 0, 0)
RefreshBtn.BackgroundColor3    = Color3.fromRGB(0, 60, 150)
RefreshBtn.BackgroundTransparency = 0.2
RefreshBtn.Text                = "Refresh"
RefreshBtn.Font                = Enum.Font.GothamBold
RefreshBtn.TextScaled          = true
RefreshBtn.TextColor3          = Color3.new(1, 1, 1)
RefreshBtn.Parent              = CatalogPanel
AddCorner(RefreshBtn, 4)

-- Sort button
local SortBtn = Instance.new("TextButton")
SortBtn.Size                = UDim2.new(0.2, -ScalePixel("X", 8), 0, ScalePixel("Y", 28))
SortBtn.Position            = UDim2.new(0.8, ScalePixel("X", 4), 0, 0)
SortBtn.BackgroundColor3    = Color3.fromRGB(40, 40, 80)
SortBtn.BackgroundTransparency = 0.2
SortBtn.Text                = "Sort: Relevance"
SortBtn.Font                = Enum.Font.GothamBold
SortBtn.TextScaled          = true
SortBtn.TextColor3          = Color3.new(1, 1, 1)
SortBtn.Parent              = CatalogPanel
AddCorner(SortBtn, 4)

-- Saved panel (left side, hidden by default)
local SavedPanel = Instance.new("Frame")
SavedPanel_Ref = SavedPanel
SavedPanel.Size                = UDim2.new(0.6, -ScalePixel("X", 10), 1, -ScalePixel("Y", 70))
SavedPanel.Position            = UDim2.new(0, ScalePixel("X", 5), 0, ScalePixel("Y", 70))
SavedPanel.BackgroundTransparency = 1
SavedPanel.Visible             = false
SavedPanel.Parent              = MainFrame

-- Saved search box
local SavedSearchBox = Instance.new("TextBox")
SavedSearchBox.Size                = UDim2.new(0.7, -ScalePixel("X", 16), 0, ScalePixel("Y", 28))
SavedSearchBox.Position            = UDim2.new(0, ScalePixel("X", 8), 0, 0)
SavedSearchBox.PlaceholderText     = "Search Saved..."
SavedSearchBox.BackgroundColor3    = Color3.fromRGB(20, 20, 25)
SavedSearchBox.BackgroundTransparency = 0.3
SavedSearchBox.TextColor3          = Color3.new(1, 1, 1)
SavedSearchBox.Font                = Enum.Font.Gotham
SavedSearchBox.TextScaled          = true
SavedSearchBox.ClearTextOnFocus    = false
SavedSearchBox.Text                = ""
SavedSearchBox.Parent              = SavedPanel
AddCorner(SavedSearchBox, 4)
AddStroke(SavedSearchBox, Color3.fromRGB(50, 50, 70), 1)

-- Manual emote ID input box
local EmoteIdBox = Instance.new("TextBox")
EmoteIdBox.Size                = UDim2.new(0.2, 0, 0, ScalePixel("Y", 28))
EmoteIdBox.Position            = UDim2.new(0.7, -ScalePixel("X", 4), 0, 0)
EmoteIdBox.PlaceholderText     = "Emote ID"
EmoteIdBox.BackgroundColor3    = Color3.fromRGB(20, 20, 25)
EmoteIdBox.BackgroundTransparency = 0.3
EmoteIdBox.TextColor3          = Color3.new(1, 1, 1)
EmoteIdBox.Font                = Enum.Font.Gotham
EmoteIdBox.TextScaled          = true
EmoteIdBox.ClearTextOnFocus    = false
EmoteIdBox.Text                = ""
EmoteIdBox.Parent              = SavedPanel
AddCorner(EmoteIdBox, 4)
AddStroke(EmoteIdBox, Color3.fromRGB(50, 50, 70), 1)

-- Add custom ID button
local AddEmoteBtn = Instance.new("TextButton")
AddEmoteBtn.Size                = UDim2.new(0.1, 0, 0, ScalePixel("Y", 28))
AddEmoteBtn.Position            = UDim2.new(0.9, 0, 0, 0)
AddEmoteBtn.BackgroundColor3    = Color3.fromRGB(40, 100, 160)
AddEmoteBtn.BackgroundTransparency = 0.2
AddEmoteBtn.Text                = "+"
AddEmoteBtn.Font                = Enum.Font.GothamBold
AddEmoteBtn.TextScaled          = true
AddEmoteBtn.TextColor3          = Color3.new(1, 1, 1)
AddEmoteBtn.Parent              = SavedPanel
AddCorner(AddEmoteBtn, 4)

-- Saved emotes scroll frame
local SavedScrollFrame = Instance.new("ScrollingFrame")
SavedScrollFrame.Size                = UDim2.new(1, -ScalePixel("X", 16), 1, -ScalePixel("Y", 40))
SavedScrollFrame.Position            = UDim2.new(0, ScalePixel("X", 8), 0, ScalePixel("Y", 36))
SavedScrollFrame.CanvasSize          = UDim2.new(0, 0, 0, 0)
SavedScrollFrame.ScrollBarThickness  = 0
SavedScrollFrame.BackgroundTransparency = 1
SavedScrollFrame.Parent              = SavedPanel

-- "Empty saved" label
local SavedEmptyLabel = Instance.new("TextLabel")
SavedEmptyLabel.Size                = UDim2.new(1, 0, 0, ScalePixel("Y", 36))
SavedEmptyLabel.Position            = UDim2.new(0, 0, 0.5, -ScalePixel("Y", 18))
SavedEmptyLabel.BackgroundTransparency = 1
SavedEmptyLabel.Text                = "Sorry I Was Changing Save Files Again 😅"
SavedEmptyLabel.TextColor3          = Color3.new(1, 1, 1)
SavedEmptyLabel.Font                = Enum.Font.GothamBold
SavedEmptyLabel.TextScaled          = true
SavedEmptyLabel.Visible             = false
SavedEmptyLabel.Parent              = SavedScrollFrame

-- Grid layout for saved emotes
local SavedGridLayout = Instance.new("UIGridLayout")
SavedGridLayout.CellSize             = UDim2.new(0, ScalePixel("X", 120), 0, ScalePixel("Y", 200))
SavedGridLayout.CellPadding          = UDim2.new(0, ScalePixel("X", 8), 0, ScalePixel("Y", 8))
SavedGridLayout.HorizontalAlignment  = Enum.HorizontalAlignment.Center
SavedGridLayout.Parent               = SavedScrollFrame

-- Right-side settings panel container
local SettingsContainer = Instance.new("Frame")
SettingsContainer.Size                = UDim2.new(0.4, -ScalePixel("X", 10), 1, -ScalePixel("Y", 70))
SettingsContainer.Position            = UDim2.new(0.6, ScalePixel("X", 5), 0, ScalePixel("Y", 70))
SettingsContainer.BackgroundTransparency = 1
SettingsContainer.Parent              = MainFrame

-- Settings header
local SettingsHeader = Instance.new("TextLabel")
SettingsHeader.Size                = UDim2.new(1, 0, 0, ScalePixel("Y", 28))
SettingsHeader.BackgroundTransparency = 1
SettingsHeader.Text                = "Settings"
SettingsHeader.TextColor3          = Color3.new(1, 1, 1)
SettingsHeader.Font                = Enum.Font.GothamBold
SettingsHeader.TextScaled          = true
SettingsHeader.Parent              = SettingsContainer

-- Settings scroll frame
local SettingsScroll = Instance.new("ScrollingFrame")
SettingsScroll.Size                = UDim2.new(1, -ScalePixel("X", 20), 1, -ScalePixel("Y", 40))
SettingsScroll.Position            = UDim2.new(0, ScalePixel("X", 10), 0, ScalePixel("Y", 30))
SettingsScroll.BackgroundTransparency = 1
SettingsScroll.CanvasSize          = UDim2.new(0, 0, 0, 0)
SettingsScroll.ScrollBarThickness  = 4
SettingsScroll.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 140)
SettingsScroll.Parent              = SettingsContainer

-- Lock horizontal scroll on settings panel
local function LockHorizontalScroll()
    SettingsScroll.CanvasPosition = Vector2.new(0, SettingsScroll.CanvasPosition.Y)
end
SettingsScroll:GetPropertyChangedSignal("CanvasPosition"):Connect(LockHorizontalScroll)

-- Settings list layout
local SettingsListLayout = Instance.new("UIListLayout", SettingsScroll)
SettingsListLayout.Padding         = UDim.new(0, 8)
SettingsListLayout.FillDirection   = Enum.FillDirection.Vertical
SettingsListLayout.SortOrder       = Enum.SortOrder.LayoutOrder

SettingsListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    SettingsScroll.CanvasSize = UDim2.new(0, 0, 0, SettingsListLayout.AbsoluteContentSize.Y + 10)
end)

-- Resolve the real animation ID from a wrapped animation asset
function GetReal(assetId)
    local ok, objects = pcall(function()
        return game:GetObjects("rbxassetid://" .. tostring(assetId))
    end)
    if ok and objects and #objects > 0 then
        local obj = objects[1]
        if obj:IsA("Animation") and obj.AnimationId ~= "" then
            return tonumber(obj.AnimationId:match("%d+"))
        elseif obj:FindFirstChildOfClass("Animation") then
            local anim = obj:FindFirstChildOfClass("Animation")
            return tonumber(anim.AnimationId:match("%d+"))
        end
    end
end

local RefreshSavedList  -- forward declare

-- Add custom emote ID button handler
AddEmoteBtn.MouseButton1Click:Connect(function()
    local id = tonumber(EmoteIdBox.Text)
    if id then
        local alreadySaved = false
        for _, emote in ipairs(SavedEmotes) do
            if emote.Id == id then alreadySaved = true break end
        end
        if not alreadySaved then
            local realId = GetReal(id)
            table.insert(SavedEmotes, {
                Id          = id,
                AssetId     = id,
                Name        = "Custom ID: " .. id,
                AnimationId = "rbxassetid://" .. tostring(realId or id),
                Favorite    = false
            })
            SaveToFile()
            RefreshSavedList()
        end
    end
end)

AnimSettings._sliders = {}
AnimSettings._toggles = {}

-- Create a slider setting row
local function CreateSlider(settingName, minVal, maxVal, defaultVal)
    AnimSettings[settingName] = defaultVal or minVal

    local rowFrame = Instance.new("Frame")
    rowFrame.Size                = UDim2.new(1, 0, 0, ScalePixel("Y", 65))
    rowFrame.BackgroundTransparency = 1
    rowFrame.Parent              = SettingsScroll

    local innerFrame = Instance.new("Frame")
    innerFrame.Size                = UDim2.new(1, 0, 1, 0)
    innerFrame.BackgroundColor3    = Color3.fromRGB(20, 20, 30)
    innerFrame.BackgroundTransparency = 0.4
    innerFrame.Parent              = rowFrame
    AddCorner(innerFrame, 6)
    AddStroke(innerFrame, Color3.fromRGB(60, 60, 90), 1)

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size                = UDim2.new(0.5, -ScalePixel("X", 10), 0, ScalePixel("Y", 20))
    nameLabel.Position            = UDim2.new(0, 10, 0, 5)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text                = string.format("%s: %.2f", settingName, AnimSettings[settingName])
    nameLabel.TextColor3          = Color3.new(1, 1, 1)
    nameLabel.Font                = Enum.Font.Gotham
    nameLabel.TextScaled          = true
    nameLabel.TextXAlignment      = Enum.TextXAlignment.Left
    nameLabel.Parent              = innerFrame

    local valueBox = Instance.new("TextBox")
    valueBox.Size                = UDim2.new(0.5, -ScalePixel("X", 20), 0, ScalePixel("Y", 20))
    valueBox.Position            = UDim2.new(0.5, ScalePixel("X", 10), 0, ScalePixel("Y", 5))
    valueBox.BackgroundColor3    = Color3.fromRGB(30, 30, 40)
    valueBox.Text                = tostring(AnimSettings[settingName])
    valueBox.TextColor3          = Color3.new(1, 1, 1)
    valueBox.Font                = Enum.Font.Gotham
    valueBox.TextScaled          = true
    valueBox.ClearTextOnFocus    = false
    valueBox.Parent              = innerFrame
    AddCorner(valueBox, 4)

    local trackBar = Instance.new("Frame")
    trackBar.Size                = UDim2.new(1, -ScalePixel("X", 40), 0, ScalePixel("Y", 12))
    trackBar.Position            = UDim2.new(0, ScalePixel("X", 20), 0, ScalePixel("Y", 35))
    trackBar.BackgroundColor3    = Color3.fromRGB(40, 40, 50)
    trackBar.Parent              = innerFrame
    AddCorner(trackBar, 6)

    local fillBar = Instance.new("Frame")
    fillBar.Size                = UDim2.new(0, 0, 1, 0)
    fillBar.BackgroundColor3    = Color3.fromRGB(0, 140, 255)
    fillBar.Parent              = trackBar
    AddCorner(fillBar, 6)

    local thumb = Instance.new("Frame")
    thumb.Size                = UDim2.new(0, ScalePixel("X", 20), 0, ScalePixel("Y", 20))
    thumb.AnchorPoint         = Vector2.new(0.5, 0.5)
    thumb.Position            = UDim2.new(0, 0, 0.5, 0)
    thumb.BackgroundColor3    = Color3.fromRGB(220, 220, 255)
    thumb.Parent              = trackBar
    AddCorner(thumb, 10)
    AddStroke(thumb, Color3.fromRGB(0, 0, 0), 1)

    -- Move fill/thumb to normalised position [0..1]
    local function SetFillVisual(normalized)
        local n = math.clamp(normalized, 0, 1)
        TweenService:Create(fillBar, TweenInfo.new(0.15), {Size = UDim2.new(n, 0, 1, 0)}):Play()
        TweenService:Create(thumb,   TweenInfo.new(0.15), {Position = UDim2.new(n, 0, 0.5, 0)}):Play()
    end

    local function SetValue(newValue)
        AnimSettings[settingName] = math.clamp(newValue, minVal, maxVal)
        nameLabel.Text = string.format("%s: %.2f", settingName, AnimSettings[settingName])
        valueBox.Text  = tostring(AnimSettings[settingName])
        SetFillVisual((AnimSettings[settingName] - minVal) / (maxVal - minVal))

        if CurrentTrack and CurrentTrack.IsPlaying then
            if settingName == "Speed" then
                CurrentTrack:AdjustSpeed(AnimSettings["Speed"])
            elseif settingName == "Weight" then
                local w = AnimSettings["Weight"]
                if w == 0 then w = 0.001 end
                CurrentTrack:AdjustWeight(w)
            elseif settingName == "Time Position" then
                if CurrentTrack.Length > 0 then
                    CurrentTrack.TimePosition = math.clamp(newValue, 0, 1) * CurrentTrack.Length
                end
            end
        end
    end

    local isDragging = false

    local function OnTrackInput(input)
        local normalized = math.clamp((input.Position.X - trackBar.AbsolutePosition.X) / trackBar.AbsoluteSize.X, 0, 1)
        local snapped = math.floor((minVal + (maxVal - minVal) * normalized) * 100) / 100
        SetValue(snapped)
    end

    trackBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDragging = true
            OnTrackInput(input)
        end
    end)
    thumb.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDragging = true
            OnTrackInput(input)
        end
    end)
    InputService.InputChanged:Connect(function(input)
        if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            OnTrackInput(input)
        end
    end)
    InputService.InputEnded:Connect(function(input)
        if isDragging and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
            isDragging = false
        end
    end)
    valueBox.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            local num = tonumber(valueBox.Text)
            if num then SetValue(num)
            else valueBox.Text = tostring(AnimSettings[settingName])
            end
        end
    end)

    AnimSettings._sliders[settingName] = SetValue
    SetValue(AnimSettings[settingName])
end

-- Create a toggle setting row
local function CreateToggle(settingName)
    AnimSettings[settingName] = AnimSettings[settingName] or false

    local rowFrame = Instance.new("Frame")
    rowFrame.Size                = UDim2.new(1, 0, 0, ScalePixel("Y", 40))
    rowFrame.BackgroundColor3    = Color3.fromRGB(20, 20, 30)
    rowFrame.BackgroundTransparency = 0.4
    rowFrame.Parent              = SettingsScroll
    AddCorner(rowFrame, 6)
    AddStroke(rowFrame, Color3.fromRGB(60, 60, 90), 1)

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size                = UDim2.new(1, -ScalePixel("X", 90), 1, 0)
    nameLabel.Position            = UDim2.new(0, ScalePixel("X", 10), 0, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text                = settingName
    nameLabel.TextColor3          = Color3.new(1, 1, 1)
    nameLabel.Font                = Enum.Font.Gotham
    nameLabel.TextScaled          = true
    nameLabel.TextXAlignment      = Enum.TextXAlignment.Left
    nameLabel.Parent              = rowFrame

    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size                = UDim2.new(0, ScalePixel("X", 60), 0, ScalePixel("Y", 24))
    toggleBtn.Position            = UDim2.new(1, -ScalePixel("X", 70), 0.5, -ScalePixel("Y", 12))
    toggleBtn.TextColor3          = Color3.new(1, 1, 1)
    toggleBtn.Font                = Enum.Font.GothamBold
    toggleBtn.TextScaled          = true
    toggleBtn.Parent              = rowFrame
    AddCorner(toggleBtn, 4)

    local function SetToggleVisual(state)
        toggleBtn.Text = state and "ON" or "OFF"
        toggleBtn.BackgroundColor3 = state and Color3.fromRGB(0, 150, 100) or Color3.fromRGB(150, 40, 40)
        toggleBtn.BackgroundTransparency = 0.2
    end

    toggleBtn.MouseButton1Click:Connect(function()
        AnimSettings[settingName] = not AnimSettings[settingName]
        SetToggleVisual(AnimSettings[settingName])
    end)
    SetToggleVisual(AnimSettings[settingName])

    AnimSettings._toggles[settingName] = SetToggleVisual
end

-- Programmatic control methods on AnimSettings
function AnimSettings:EditSlider(name, value)
    local fn = self._sliders[name]
    if fn then fn(value) end
end
function AnimSettings:EditToggle(name, value)
    local fn = self._toggles[name]
    if fn then self[name] = value fn(value) end
end

-- Create a full-width action button row
local function CreateActionButton(label, callback)
    local rowFrame = Instance.new("Frame")
    rowFrame.Size                = UDim2.new(1, 0, 0, ScalePixel("Y", 45))
    rowFrame.BackgroundColor3    = Color3.fromRGB(20, 20, 30)
    rowFrame.BackgroundTransparency = 0.4
    rowFrame.Parent              = SettingsScroll
    AddCorner(rowFrame, 6)

    local btn = Instance.new("TextButton")
    btn.Size                = UDim2.new(1, -ScalePixel("X", 20), 1, -ScalePixel("Y", 10))
    btn.Position            = UDim2.new(0, ScalePixel("X", 10), 0, ScalePixel("Y", 5))
    btn.BackgroundColor3    = Color3.fromRGB(30, 90, 180)
    btn.BackgroundTransparency = 0.2
    btn.Text                = label
    btn.TextColor3          = Color3.new(1, 1, 1)
    btn.Font                = Enum.Font.GothamBold
    btn.TextScaled          = true
    btn.Parent              = rowFrame
    AddCorner(btn, 6)

    btn.MouseButton1Click:Connect(function()
        if typeof(callback) == "function" then callback() end
    end)
    return btn
end

-- Add all settings widgets
local ResetSettingsBtn = CreateActionButton("Reset Settings", function() end)
CreateToggle("Stop Emote When Moving")
CreateToggle("Looped")
CreateSlider("Speed",         0, 5, AnimSettings["Speed"])
CreateSlider("Time Position", 0, 1, AnimSettings["Time Position"])
CreateSlider("Weight",        0, 1, AnimSettings["Weight"])
CreateSlider("Fade In",       0, 2, AnimSettings["Fade In"])
CreateSlider("Fade Out",      0, 2, AnimSettings["Fade Out"])
CreateToggle("Stop Other Animations On Play")
CreateToggle("High Priority")

ResetSettingsBtn.MouseButton1Click:Connect(function()
    AnimSettings:EditToggle("Stop Emote When Moving",       true)
    AnimSettings:EditToggle("Stop Other Animations On Play", true)
    AnimSettings:EditToggle("High Priority",                true)
    AnimSettings:EditSlider("Fade In",       0.1)
    AnimSettings:EditSlider("Fade Out",      0.1)
    AnimSettings:EditSlider("Weight",        1)
    AnimSettings:EditSlider("Speed",         1)
    AnimSettings:EditSlider("Time Position", 0)
    AnimSettings:EditToggle("Freeze On Finish", false)
    AnimSettings:EditToggle("Looped",           true)
end)

-- Sort type options for catalog search
local SortTypes = {
    {Enum.CatalogSortType.Relevance,       "Relevance"},
    {Enum.CatalogSortType.PriceHighToLow,  "Price High→Low"},
    {Enum.CatalogSortType.PriceLowToHigh,  "Price Low→High"},
    {Enum.CatalogSortType.MostFavorited,   "Most Favorited"},
    {Enum.CatalogSortType.RecentlyCreated, "Recently Created"},
    {Enum.CatalogSortType.Bestselling,     "Bestselling"},
}

local currentSortIndex  = 1
local currentKeyword    = ""
local currentPageObj    = nil
local currentPageNumber = 1
local ActiveTab         = 1

-- Search catalog for emotes
local function SearchCatalog(keyword)
    if IsR6 then
        return {
            IsFinished = true,
            GetCurrentPage  = function() return {{Id = 115314801778772, Name = "Dance If Youre The Best", AssetId = 115314801778772}} end,
            AdvanceToNextPageAsync = function() end,
        }
    end

    local params = CatalogSearchParams.new()
    params.SearchKeyword    = keyword or ""
    params.CategoryFilter   = Enum.CatalogCategoryFilter.None
    params.SalesTypeFilter  = Enum.SalesTypeFilter.All
    params.AssetTypes       = {Enum.AvatarAssetType.EmoteAnimation}
    params.IncludeOffSale   = true
    params.SortType         = SortTypes[currentSortIndex][1]
    params.Limit            = 10

    local ok, result = pcall(function() return AvatarEditor:SearchCatalog(params) end)
    if not ok then return nil end
    return result
end

-- Build a catalog emote card frame
local function CreateCatalogCard(emoteData)
    local card = Instance.new("Frame")
    card.Size                = UDim2.new(0, ScalePixel("X", 120), 0, ScalePixel("Y", 180))
    card.BackgroundColor3    = Color3.fromRGB(25, 25, 35)
    card.BackgroundTransparency = 0.2
    AddCorner(card, 8)
    AddStroke(card, Color3.fromRGB(60, 60, 90), 1)

    local assetId = emoteData.AssetId or emoteData.Id

    local thumbnail = Instance.new("ImageLabel")
    thumbnail.Size                = UDim2.new(1, -ScalePixel("X", 10), 0, ScalePixel("Y", 90))
    thumbnail.Position            = UDim2.new(0, ScalePixel("X", 5), 0, ScalePixel("Y", 5))
    thumbnail.BackgroundTransparency = 1
    thumbnail.ScaleType           = Enum.ScaleType.Fit
    pcall(function() thumbnail.Image = "rbxthumb://type=Asset&id=" .. tonumber(assetId) .. "&w=150&h=150" end)
    thumbnail.Parent = card
    AddCorner(thumbnail, 4)

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size                = UDim2.new(1, -ScalePixel("X", 10), 0, ScalePixel("Y", 28))
    nameLabel.Position            = UDim2.new(0, ScalePixel("X", 5), 0, ScalePixel("Y", 100))
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text                = emoteData.Name or "Unknown"
    nameLabel.TextScaled          = true
    nameLabel.TextWrapped         = true
    nameLabel.Font                = Enum.Font.GothamBold
    nameLabel.TextColor3          = Color3.new(1, 1, 1)
    nameLabel.Parent              = card

    local catalogUrl = "https://www.roblox.com/catalog/" .. tonumber(emoteData.Id)
    local copyLinkBtn = Instance.new("TextButton")
    copyLinkBtn.Parent              = card
    copyLinkBtn.Size                = UDim2.new(0, ScalePixel("X", 36), 0, ScalePixel("Y", 36))
    copyLinkBtn.Position            = UDim2.new(1, -ScalePixel("X", 42), 0, ScalePixel("Y", 5))
    copyLinkBtn.BackgroundColor3    = Color3.fromRGB(30, 30, 45)
    copyLinkBtn.BackgroundTransparency = 0.2
    copyLinkBtn.Text                = "🛒🔗"
    copyLinkBtn.Font                = Enum.Font.GothamBold
    copyLinkBtn.TextScaled          = true
    copyLinkBtn.TextColor3          = Color3.fromRGB(255, 255, 255)
    copyLinkBtn.AutoButtonColor     = false
    AddCorner(copyLinkBtn, 6)
    copyLinkBtn.MouseButton1Click:Connect(function()
        setclipboard(catalogUrl)
        copyLinkBtn.Text = "✅"
        copyLinkBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 100)
        task.wait(0.7)
        copyLinkBtn.Text = "🛒🔗"
        copyLinkBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
    end)

    local playBtn = Instance.new("TextButton")
    playBtn.Size                = UDim2.new(0.45, -ScalePixel("X", 5), 0, ScalePixel("Y", 24))
    playBtn.Position            = UDim2.new(0, ScalePixel("X", 5), 1, -ScalePixel("Y", 29))
    playBtn.BackgroundColor3    = Color3.fromRGB(40, 140, 80)
    playBtn.BackgroundTransparency = 0.2
    playBtn.Text                = "Play"
    playBtn.Font                = Enum.Font.GothamBold
    playBtn.TextScaled          = true
    playBtn.TextColor3          = Color3.new(1, 1, 1)
    playBtn.Parent              = card
    AddCorner(playBtn, 4)
    playBtn.MouseButton1Click:Connect(function() PlayAnimation(assetId) end)

    local saveBtn = Instance.new("TextButton")
    saveBtn.Size                = UDim2.new(0.45, -ScalePixel("X", 5), 0, ScalePixel("Y", 24))
    saveBtn.Position            = UDim2.new(0.55, 0, 1, -ScalePixel("Y", 29))
    saveBtn.BackgroundColor3    = Color3.fromRGB(40, 100, 160)
    saveBtn.BackgroundTransparency = 0.2
    saveBtn.Text                = "Save"
    saveBtn.Font                = Enum.Font.GothamBold
    saveBtn.TextScaled          = true
    saveBtn.TextColor3          = Color3.new(1, 1, 1)
    saveBtn.Parent              = card
    AddCorner(saveBtn, 4)
    saveBtn.MouseButton1Click:Connect(function()
        local alreadySaved = false
        for _, emote in ipairs(SavedEmotes) do
            if emote.Id == emoteData.Id then alreadySaved = true break end
        end
        if not alreadySaved then
            local realId = GetReal(assetId)
            table.insert(SavedEmotes, {
                Id          = emoteData.Id,
                AssetId     = assetId,
                Name        = emoteData.Name or "Unknown",
                AnimationId = "rbxassetid://" .. tostring(realId or assetId),
                Favorite    = false,
            })
            SaveToFile()
            saveBtn.Text = "Saved!"
            saveBtn.BackgroundColor3 = Color3.fromRGB(0, 160, 100)
            task.wait(1)
            saveBtn.Text = "Save"
            saveBtn.BackgroundColor3 = Color3.fromRGB(40, 100, 160)
        else
            saveBtn.Text = "Already"
            task.wait(0.7)
            saveBtn.Text = "Save"
        end
    end)

    PopIn(card)
    return card
end

-- Catalog scroll frame and grid
local CatalogScrollFrame = Instance.new("ScrollingFrame")
CatalogScrollFrame.Size                = UDim2.new(1, -ScalePixel("X", 16), 1, -ScalePixel("Y", 100))
CatalogScrollFrame.Position            = UDim2.new(0, ScalePixel("X", 8), 0, ScalePixel("Y", 36))
CatalogScrollFrame.CanvasSize          = UDim2.new(0, 0, 0, 0)
CatalogScrollFrame.ScrollBarThickness  = 6
CatalogScrollFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 140)
CatalogScrollFrame.BackgroundTransparency = 1
CatalogScrollFrame.Parent              = CatalogPanel

local CatalogGridLayout = Instance.new("UIGridLayout", CatalogScrollFrame)
CatalogGridLayout.CellSize    = UDim2.new(0, ScalePixel("X", 120), 0, ScalePixel("Y", 180))
CatalogGridLayout.CellPadding = UDim2.new(0, ScalePixel("X", 8), 0, ScalePixel("Y", 8))

-- "No results" label for catalog
local CatalogEmptyLabel = Instance.new("TextLabel", CatalogScrollFrame)
CatalogEmptyLabel.Size                = UDim2.new(1, 0, 0, ScalePixel("Y", 36))
CatalogEmptyLabel.Position            = UDim2.new(0, 0, 0.5, -ScalePixel("Y", 18))
CatalogEmptyLabel.BackgroundTransparency = 1
CatalogEmptyLabel.Text                = "Nothing Silly Here :3 (except me)"
CatalogEmptyLabel.TextColor3          = Color3.new(1, 1, 1)
CatalogEmptyLabel.Font                = Enum.Font.GothamBold
CatalogEmptyLabel.TextScaled          = true
CatalogEmptyLabel.Visible             = false

-- Pagination buttons
local PrevPageBtn = Instance.new("TextButton", CatalogPanel)
PrevPageBtn.Size                = UDim2.new(0.4, -ScalePixel("X", 6), 0, ScalePixel("Y", 32))
PrevPageBtn.Position            = UDim2.new(0, ScalePixel("X", 4), 1, -ScalePixel("Y", 36))
PrevPageBtn.BackgroundColor3    = Color3.fromRGB(50, 50, 70)
PrevPageBtn.BackgroundTransparency = 0.2
PrevPageBtn.Text                = "< Prev"
PrevPageBtn.Font                = Enum.Font.GothamBold
PrevPageBtn.TextScaled          = true
PrevPageBtn.TextColor3          = Color3.new(1, 1, 1)
AddCorner(PrevPageBtn, 6)

local NextPageBtn = Instance.new("TextButton", CatalogPanel)
NextPageBtn.Size                = UDim2.new(0.4, -ScalePixel("X", 6), 0, ScalePixel("Y", 32))
NextPageBtn.Position            = UDim2.new(0.6, ScalePixel("X", 2), 1, -ScalePixel("Y", 36))
NextPageBtn.BackgroundColor3    = Color3.fromRGB(50, 50, 70)
NextPageBtn.BackgroundTransparency = 0.2
NextPageBtn.Text                = "Next >"
NextPageBtn.Font                = Enum.Font.GothamBold
NextPageBtn.TextScaled          = true
NextPageBtn.TextColor3          = Color3.new(1, 1, 1)
AddCorner(NextPageBtn, 6)

local PageInputBox = Instance.new("TextBox", CatalogPanel)
PageInputBox.Size                = UDim2.new(0.2, 0, 0, ScalePixel("Y", 32))
PageInputBox.Position            = UDim2.new(0.4, ScalePixel("X", 2), 1, -ScalePixel("Y", 36))
PageInputBox.BackgroundTransparency = 1
PageInputBox.Font                = Enum.Font.Gotham
PageInputBox.TextScaled          = true
PageInputBox.TextColor3          = Color3.new(1, 1, 1)
PageInputBox.Text                = "1 / Enter page"

local PageErrorLabel = Instance.new("TextLabel", CatalogPanel)
PageErrorLabel.Size                = UDim2.new(0.3, 0, 0, ScalePixel("Y", 24))
PageErrorLabel.Position            = UDim2.new(0.35, 0, 1, -ScalePixel("Y", 68))
PageErrorLabel.BackgroundTransparency = 1
PageErrorLabel.TextColor3          = Color3.fromRGB(255, 100, 100)
PageErrorLabel.Font                = Enum.Font.Gotham
PageErrorLabel.TextScaled          = true
PageErrorLabel.Text                = ""
PageErrorLabel.Visible             = false

-- Update prev/next button visibility
local function UpdatePaginationButtons()
    PrevPageBtn.Visible = (currentPageNumber > 1)
    if currentPageObj and typeof(currentPageObj.IsFinished) == "boolean" then
        NextPageBtn.Visible = not currentPageObj.IsFinished
    else
        NextPageBtn.Visible = true
    end
end

local RenderPage_id = 0

-- Render a page of catalog results
local function RenderCatalogPage(pageObj)
    RenderPage_id = RenderPage_id + 1
    local myId = RenderPage_id
    PageInputBox.Text = "Loading..."

    for _, child in ipairs(CatalogScrollFrame:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end

    local items = nil
    local ok, result = pcall(function() return pageObj:GetCurrentPage() end)
    if ok then items = result else PageInputBox.Text = "ERROR" return end

    if myId ~= RenderPage_id then return end

    if items and #items > 0 then
        CatalogEmptyLabel.Visible = false
        local snapTab = ActiveTab
        local count   = 0
        for _, emote in ipairs(items) do
            if ActiveTab ~= snapTab or myId ~= RenderPage_id then break end
            CreateCatalogCard(emote).Parent = CatalogScrollFrame
            count = count + 1
            if count % 2 == 0 then RunService.RenderStepped:Wait() end
        end
    else
        CatalogEmptyLabel.Visible = true
    end

    if myId == RenderPage_id then
        CatalogScrollFrame.CanvasSize = UDim2.new(0, 0, 0, CatalogGridLayout.AbsoluteContentSize.Y + 8)
        PageInputBox.Text = tostring(currentPageNumber) .. " / Enter page"
        UpdatePaginationButtons()
    end
end

-- Jump to a specific page number (fetches from page 1 up to target)
local function FetchPageNumber(targetPage)
    local pageObj = SearchCatalog(currentKeyword)
    if not pageObj then return nil end
    for i = 2, targetPage do
        if pageObj.IsFinished then break end
        local ok = pcall(function() pageObj:AdvanceToNextPageAsync() end)
        if not ok then break end
    end
    return pageObj
end

-- Perform a fresh catalog search
local function DoSearch(keyword)
    currentKeyword    = keyword or ""
    currentPageNumber = 1
    PageInputBox.Text = "Loading..."
    currentPageObj    = SearchCatalog(currentKeyword)
    if currentPageObj then RenderCatalogPage(currentPageObj) end
end

-- Next / Prev page handlers
local function GoToNextPage()
    if not currentPageObj or currentPageObj.IsFinished then return end
    local ok = pcall(function() currentPageObj:AdvanceToNextPageAsync() end)
    if ok then
        currentPageNumber = currentPageNumber + 1
        RenderCatalogPage(currentPageObj)
    else
        local next = FetchPageNumber(currentPageNumber + 1)
        if next then
            currentPageObj    = next
            currentPageNumber = math.min(currentPageNumber + 1, currentPageNumber + 1)
            RenderCatalogPage(currentPageObj)
        end
    end
end

local function GoToPrevPage()
    if not currentPageObj or currentPageNumber <= 1 then return end
    local ok = pcall(function() currentPageObj:AdvanceToPreviousPageAsync() end)
    if ok then
        currentPageNumber = math.max(1, currentPageNumber - 1)
        RenderCatalogPage(currentPageObj)
    else
        local prev = FetchPageNumber(math.max(1, currentPageNumber - 1))
        if prev then
            currentPageObj    = prev
            currentPageNumber = math.max(1, currentPageNumber - 1)
            RenderCatalogPage(currentPageObj)
        end
    end
end

NextPageBtn.MouseButton1Click:Connect(GoToNextPage)
PrevPageBtn.MouseButton1Click:Connect(GoToPrevPage)

-- Keyboard arrow key navigation between pages
InputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.UserInputType == Enum.UserInputType.Keyboard then
        if input.KeyCode == Enum.KeyCode.Right then GoToNextPage()
        elseif input.KeyCode == Enum.KeyCode.Left then GoToPrevPage()
        end
    end
end)

-- Manual page number entry
PageInputBox.FocusLost:Connect(function(enterPressed)
    if not enterPressed then return end
    local cleaned = PageInputBox.Text:gsub("%s+", "")
    local num     = tonumber(cleaned:match("%d+"))
    if not num or num < 1 then
        PageErrorLabel.Text    = "Invalid page number"
        PageErrorLabel.Visible = true
        task.delay(2, function() if PageErrorLabel then PageErrorLabel.Visible = false end end)
        PageInputBox.Text = "Page " .. tostring(currentPageNumber)
        return
    end
    local targetPage = math.floor(num)
    if targetPage == currentPageNumber then
        PageInputBox.Text = "Page " .. tostring(currentPageNumber)
        return
    end
    PageInputBox.Text = "Loading..."
    local ok, fetched = pcall(function() return FetchPageNumber(targetPage) end)
    if not ok or not fetched then
        PageErrorLabel.Text    = "Unable to fetch page"
        PageErrorLabel.Visible = true
        task.delay(2, function() if PageErrorLabel then PageErrorLabel.Visible = false end end)
        PageInputBox.Text = "Page " .. tostring(currentPageNumber)
        return
    end
    currentPageObj    = fetched
    currentPageNumber = math.max(1, targetPage)
    RenderCatalogPage(currentPageObj)
end)

-- Build a saved emote card frame
local function CreateSavedCard(emoteData)
    local card = Instance.new("Frame")
    card.Size                = UDim2.new(0, ScalePixel("X", 120), 0, ScalePixel("Y", 200))
    card.BackgroundColor3    = Color3.fromRGB(25, 25, 35)
    card.BackgroundTransparency = 0.2
    AddCorner(card, 8)
    AddStroke(card, Color3.fromRGB(60, 60, 90), 1)

    local thumbnail = Instance.new("ImageLabel")
    thumbnail.Size                = UDim2.new(1, -ScalePixel("X", 10), 0, ScalePixel("Y", 90))
    thumbnail.Position            = UDim2.new(0, ScalePixel("X", 5), 0, ScalePixel("Y", 5))
    thumbnail.BackgroundTransparency = 1
    thumbnail.ScaleType           = Enum.ScaleType.Fit
    thumbnail.Image               = "rbxthumb://type=Asset&id=11768914234&w=150&h=150"
    thumbnail.Parent              = card
    AddCorner(thumbnail, 4)

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size                = UDim2.new(1, -ScalePixel("X", 10), 0, ScalePixel("Y", 28))
    nameLabel.Position            = UDim2.new(0, ScalePixel("X", 5), 0, ScalePixel("Y", 100))
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text                = emoteData.Name or "Unknown"
    nameLabel.TextScaled          = true
    nameLabel.TextWrapped         = true
    nameLabel.Font                = Enum.Font.GothamBold
    nameLabel.TextColor3          = Color3.new(1, 1, 1)
    nameLabel.Parent              = card

    local playBtn = Instance.new("TextButton")
    playBtn.Size                = UDim2.new(0.45, -ScalePixel("X", 5), 0, ScalePixel("Y", 24))
    playBtn.Position            = UDim2.new(0, ScalePixel("X", 5), 1, -ScalePixel("Y", 29))
    playBtn.BackgroundColor3    = Color3.fromRGB(40, 140, 80)
    playBtn.BackgroundTransparency = 0.2
    playBtn.Text                = "Play"
    playBtn.Font                = Enum.Font.GothamBold
    playBtn.TextScaled          = true
    playBtn.TextColor3          = Color3.new(1, 1, 1)
    playBtn.Parent              = card
    AddCorner(playBtn, 4)
    playBtn.MouseButton1Click:Connect(function() PlayAnimation(emoteData.Id) end)

    local removeBtn = Instance.new("TextButton")
    removeBtn.Size                = UDim2.new(0.45, -ScalePixel("X", 5), 0, ScalePixel("Y", 24))
    removeBtn.Position            = UDim2.new(0.55, 0, 1, -ScalePixel("Y", 29))
    removeBtn.BackgroundColor3    = Color3.fromRGB(160, 50, 50)
    removeBtn.BackgroundTransparency = 0.2
    removeBtn.Text                = "Remove"
    removeBtn.Font                = Enum.Font.GothamBold
    removeBtn.TextScaled          = true
    removeBtn.TextColor3          = Color3.new(1, 1, 1)
    removeBtn.Parent              = card
    AddCorner(removeBtn, 4)

    local copyIdBtn = Instance.new("TextButton")
    copyIdBtn.Size                = UDim2.new(0, ScalePixel("X", 40), 0, ScalePixel("Y", 24))
    copyIdBtn.Position            = UDim2.new(0.5, -ScalePixel("X", 20), 0, ScalePixel("Y", 5))
    copyIdBtn.BackgroundColor3    = Color3.fromRGB(50, 50, 80)
    copyIdBtn.BackgroundTransparency = 0.2
    copyIdBtn.Text                = "Copy AnimId"
    copyIdBtn.Font                = Enum.Font.GothamBold
    copyIdBtn.TextScaled          = true
    copyIdBtn.TextColor3          = Color3.new(1, 1, 1)
    copyIdBtn.Parent              = card
    AddCorner(copyIdBtn, 4)
    copyIdBtn.MouseButton1Click:Connect(function()
        if setclipboard then
            setclipboard(emoteData.AnimationId:gsub("rbxassetid://", ""))
        end
        copyIdBtn.Text = "Copied!"
        task.wait(0.7)
        copyIdBtn.Text = "Copy AnimId"
    end)

    local favoriteBtn = Instance.new("TextButton")
    favoriteBtn.Size                = UDim2.new(0, ScalePixel("X", 24), 0, ScalePixel("Y", 24))
    favoriteBtn.Position            = UDim2.new(1, -ScalePixel("X", 30), 0, ScalePixel("Y", 5))
    favoriteBtn.Text                = emoteData.Favorite and "★" or "☆"
    favoriteBtn.Font                = Enum.Font.GothamBold
    favoriteBtn.TextScaled          = true
    favoriteBtn.TextColor3          = Color3.fromRGB(255, 220, 50)
    favoriteBtn.BackgroundTransparency = 1
    favoriteBtn.Parent              = card
    favoriteBtn.MouseButton1Click:Connect(function()
        emoteData.Favorite = not emoteData.Favorite
        favoriteBtn.Text   = emoteData.Favorite and "★" or "☆"
        SaveToFile()
        RefreshSavedList()
    end)

    removeBtn.MouseButton1Click:Connect(function()
        for i, emote in ipairs(SavedEmotes) do
            if emote.Id == emoteData.Id then
                table.remove(SavedEmotes, i)
                SaveToFile()
                RefreshSavedList()
                break
            end
        end
    end)

    PopIn(card)
    return card
end

-- Refresh / rebuild the saved emotes list
local RefreshSaved_id = 0
function RefreshSavedList()
    RefreshSaved_id = RefreshSaved_id + 1
    local myId = RefreshSaved_id

    for _, child in ipairs(SavedScrollFrame:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end

    local filter   = (SavedSearchBox.Text or ""):lower()
    local filtered = {}
    for _, emote in ipairs(SavedEmotes) do
        if filter == "" or (emote.Name and emote.Name:lower():find(filter)) then
            table.insert(filtered, emote)
        end
    end

    table.sort(filtered, function(a, b)
        if a.Favorite ~= b.Favorite then return a.Favorite else return false end
    end)

    if #filtered > 0 then
        SavedEmptyLabel.Visible = false
        local snapTab = ActiveTab
        local count   = 0
        for _, emote in ipairs(filtered) do
            if ActiveTab ~= snapTab or myId ~= RefreshSaved_id then break end
            CreateSavedCard(emote).Parent = SavedScrollFrame
            count = count + 1
            if count % 25 == 0 then RunService.RenderStepped:Wait() end
        end
    else
        SavedEmptyLabel.Visible = true
    end

    if myId == RefreshSaved_id then
        SavedScrollFrame.CanvasSize = UDim2.new(0, 0, 0, SavedGridLayout.AbsoluteContentSize.Y + 8)
    end
end

-- Tab switch handlers
CatalogTabBtn.MouseButton1Click:Connect(function()
    ActiveTab = ActiveTab + 1
    CatalogPanel.Visible = true
    SavedPanel.Visible   = false
    CatalogTabBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 80)
    SavedTabBtn.BackgroundColor3   = Color3.fromRGB(20, 50, 20)
end)

SavedSearchBox:GetPropertyChangedSignal("Text"):Connect(RefreshSavedList)

SavedTabBtn.MouseButton1Click:Connect(function()
    ActiveTab = ActiveTab + 1
    CatalogPanel.Visible = false
    SavedPanel.Visible   = true
    CatalogTabBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 40)
    SavedTabBtn.BackgroundColor3   = Color3.fromRGB(30, 80, 30)
    RefreshSavedList()
end)

-- Search triggers
RefreshBtn.MouseButton1Click:Connect(function() DoSearch(CatalogSearchBox.Text) end)
CatalogSearchBox.FocusLost:Connect(function(enterPressed) if enterPressed then DoSearch(CatalogSearchBox.Text) end end)
SortBtn.MouseButton1Click:Connect(function()
    currentSortIndex = currentSortIndex % #SortTypes + 1
    SortBtn.Text = "Sort: " .. SortTypes[currentSortIndex][2]
    DoSearch(currentKeyword)
end)

-- Initial search load
DoSearch("")

-- Toggle button to show/hide the main GUI
local ToggleGui  = MainGui
local function ToggleVisibility() ToggleGui.Enabled = not ToggleGui.Enabled end

local ToggleButtonGui = Instance.new("ScreenGui")
ToggleButtonGui.Name         = "ToggleButtonGui"
ToggleButtonGui.ResetOnSpawn = false
ToggleButtonGui.Parent       = CoreGui
ToggleButtonGui.Enabled      = true

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Parent             = ToggleButtonGui
ToggleBtn.Text               = "🤸‍♂️"
ToggleBtn.Font               = Enum.Font.GothamSemibold
ToggleBtn.TextScaled         = true
ToggleBtn.Size               = UDim2.new(0, 50, 0, 50)
ToggleBtn.Position           = UDim2.new(0, 20, 0.5, -50)
ToggleBtn.AnchorPoint        = Vector2.new(0, 0.5)
ToggleBtn.BackgroundColor3   = Color3.fromRGB(25, 25, 35)
ToggleBtn.BackgroundTransparency = 0.2
ToggleBtn.TextColor3         = Color3.new(1, 1, 1)
ToggleBtn.Active             = true
pcall(function() ToggleBtn.Draggable = true end)
AddCorner(ToggleBtn, 12)
AddStroke(ToggleBtn, Color3.fromRGB(60, 60, 100), 2)

local aspectConstraint = Instance.new("UIAspectRatioConstraint")
aspectConstraint.Parent      = ToggleBtn
aspectConstraint.AspectRatio = 1

ToggleBtn.MouseButton1Click:Connect(ToggleVisibility)
InputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == Enum.KeyCode.G then
        ToggleVisibility()
    end
end)

MainGui.Enabled = true
RefreshSavedList()

-- Collision fix: keep HRP collidable, disable collision on all other body parts
task.spawn(function()
    local RunSvc = game:GetService("RunService")
    local Plrs   = game.Players
    local player = Plrs.LocalPlayer

    local function setupCollision(character)
        local hrp       = character:WaitForChild("HumanoidRootPart")
        local bodyParts = {}

        hrp.CanCollide = true

        local function addPart(part)
            if part:IsA("BasePart") and part ~= hrp then
                table.insert(bodyParts, part)
            end
        end

        for _, part in pairs(character:GetDescendants()) do
            addPart(part)
        end

        local descendantConn = character.DescendantAdded:Connect(addPart)

        local heartbeatConn
        heartbeatConn = RunSvc.Heartbeat:Connect(function()
            if not character or not character.Parent then
                heartbeatConn:Disconnect()
                descendantConn:Disconnect()
                return
            end
            for i = 1, #bodyParts do
                local p = bodyParts[i]
                if p and p.Parent then
                    p.CanCollide = false
                end
            end
        end)
    end

    if player.Character then setupCollision(player.Character) end
    player.CharacterAdded:Connect(setupCollision)
end)
