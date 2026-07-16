task.wait(0.3)

if getgenv().UniversalScriptLoaded then
	return
end
pcall(function() getgenv().UniversalScriptLoaded = true end)

if not game:IsLoaded() then
	game.Loaded:Wait()
end

local Services = setmetatable({}, {
	__index = function(self, name)
		local ok, svc = pcall(function() return game:GetService(name) end)
		if ok and svc then
			rawset(self, name, svc)
			return svc
		end
	end
})

local Players = Services.Players
local LocalPlayer = Players.LocalPlayer
local RunService = Services.RunService
local TweenService = Services.TweenService
local UserInputService = Services.UserInputService
local Lighting = Services.Lighting
local Workspace = Services.Workspace
local HttpService = Services.HttpService
local ReplicatedStorage = Services.ReplicatedStorage
local StarterGui = Services.StarterGui
local StarterPlayer = Services.StarterPlayer
local Teams = Services.Teams
local SoundService = Services.SoundService
local TextChatService = Services.TextChatService
local TeleportService = Services.TeleportService
local PathfindingService = Services.PathfindingService
local GroupService = Services.GroupService
local SocialService = Services.SocialService
local VoiceChatService = Services.VoiceChatService
local AvatarEditorService = Services.AvatarEditorService
local MaterialService = Services.MaterialService
local CaptureService = Services.CaptureService
local ProximityPromptService = Services.ProximityPromptService
local ChatService = Services.Chat
local TextService = Services.TextService
local StatsService = Services.Stats
local CoreGui = Services.CoreGui
local GuiService = Services.GuiService
local MarketplaceService = Services.MarketplaceService
local PathService = Services.PathfindingService

local cloneref = cloneref or function(...) return ... end
local hookfunction = hookfunction or function() end
local hookmetamethod = hookmetamethod or function() end
local getnamecallmethod = getnamecallmethod or function() return "" end
local checkcaller = checkcaller or function() return false end
local newcclosure = newcclosure or function(f) return f end
local getgc = getgc or function() return {} end
local setthreadidentity = setthreadidentity or (syn and syn.set_thread_identity) or function() end
local getconnections = getconnections or function() return {} end
local firetouchinterest = firetouchinterest
local fireclickdetector = fireclickdetector
local fireproximityprompt = fireproximityprompt
local gethiddenproperty = gethiddenproperty or function() return nil end
local sethiddenproperty = sethiddenproperty or function() end
local queueteleport = queue_on_teleport or (syn and syn.queue_on_teleport) or (fluxus and fluxus.queue_on_teleport) or function() end
local httprequest = request or http_request or (syn and syn.request) or (http and http.request) or (fluxus and fluxus.request)
local setclipboard = setclipboard or toclipboard or set_clipboard or function() end
local getcustomasset = getcustomasset or getsynasset or function() return "" end
local isfile = isfile or function() return false end
local writefile = writefile or function() end
local readfile = readfile or function() return "" end
local makefolder = makefolder or function() end
local isfolder = isfolder or function() return false end
local listfiles = listfiles or function() return {} end
local keypress = keypress or function() end
local keyrelease = keyrelease or function() end
local mouse1press = mouse1press or function() end
local mouse1release = mouse1release or function() end

local function notify(title, content)
	if WindUI then
		WindUI:Notify({
			Title = tostring(title),
			Content = tostring(content),
			Duration = 3,
			Icon = "bell"
		})
	end
end

local function getRoot(char)
	if not char then return nil end
	return char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
end

local function getHum(char)
	if not char then return nil end
	return char:FindFirstChildWhichIsA("Humanoid")
end

local function isR15(char)
	local hum = getHum(char)
	return hum and hum.RigType == Enum.HumanoidRigType.R15
end

local function tools(plr)
	plr = plr or LocalPlayer
	local bp = plr:FindFirstChildOfClass("Backpack")
	local char = plr.Character
	if bp and bp:FindFirstChildOfClass("Tool") then return true end
	if char and char:FindFirstChildOfClass("Tool") then return true end
	return false
end

local function randomString()
	local len = math.random(10, 20)
	local arr = {}
	for i = 1, len do
		arr[i] = string.char(math.random(32, 126))
	end
	return table.concat(arr)
end

local function isNumber(str)
	return tonumber(str) ~= nil or tostring(str) == "inf"
end

local function chatMessage(str)
	str = tostring(str)
	pcall(function()
		if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
			local channel = TextChatService.TextChannels:FindFirstChild("RBXGeneral")
			if channel then
				channel:SendAsync(str)
			end
		else
			local events = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")
			if events then
				events:FindFirstChild("SayMessageRequest"):FireServer(str, "All")
			end
		end
	end)
end

local function breakVelocity()
	local v3 = Vector3.new(0, 0, 0)
	local char = LocalPlayer.Character
	if not char then return end
	for _, part in ipairs(char:GetDescendants()) do
		if part:IsA("BasePart") then
			part.Velocity = v3
			part.RotVelocity = v3
		end
	end
end

local function toClipboard(txt)
	if setclipboard then
		setclipboard(tostring(txt))
		notify("Clipboard", "Copied to clipboard")
	else
		notify("Clipboard", "Not supported on this executor")
	end
end

local function getPlayer(input, speaker)
	speaker = speaker or LocalPlayer
	local targets = {}
	if not input or input == "" then
		table.insert(targets, speaker)
		return targets
	end
	input = tostring(input):lower()

	if input == "all" then
		for _, p in ipairs(Players:GetPlayers()) do
			table.insert(targets, p)
		end
	elseif input == "others" then
		for _, p in ipairs(Players:GetPlayers()) do
			if p ~= speaker then
				table.insert(targets, p)
			end
		end
	elseif input == "me" then
		table.insert(targets, speaker)
	elseif input == "random" then
		local others = {}
		for _, p in ipairs(Players:GetPlayers()) do
			if p ~= speaker then
				table.insert(others, p)
			end
		end
		if #others > 0 then
			table.insert(targets, others[math.random(1, #others)])
		end
	elseif input:sub(1, 1) == "%" then
		local teamName = input:sub(2)
		for _, p in ipairs(Players:GetPlayers()) do
			if p.Team and p.Team.Name:lower():find(teamName, 1, true) then
				table.insert(targets, p)
			end
		end
	elseif input == "allies" or input == "team" then
		for _, p in ipairs(Players:GetPlayers()) do
			if p.Team == speaker.Team then
				table.insert(targets, p)
			end
		end
	elseif input == "enemies" or input == "nonteam" then
		for _, p in ipairs(Players:GetPlayers()) do
			if p.Team ~= speaker.Team then
				table.insert(targets, p)
			end
		end
	elseif input == "friends" then
		for _, p in ipairs(Players:GetPlayers()) do
			if p:IsFriendsWith(speaker.UserId) then
				table.insert(targets, p)
			end
		end
	elseif input == "nonfriends" then
		for _, p in ipairs(Players:GetPlayers()) do
			if not p:IsFriendsWith(speaker.UserId) then
				table.insert(targets, p)
			end
		end
	elseif input == "bacons" then
		for _, p in ipairs(Players:GetPlayers()) do
			if p.Character and p.Character:FindFirstChild("Head") then
				local mesh = p.Character.Head:FindFirstChildOfClass("SpecialMesh")
				if mesh and (mesh.MeshId:find("1388172") or mesh.MeshId:find("1388165")) then
					table.insert(targets, p)
				end
			end
		end
	elseif input == "nearest" then
		local nearest, dist = nil, math.huge
		local myRoot = getRoot(speaker.Character)
		if myRoot then
			for _, p in ipairs(Players:GetPlayers()) do
				if p ~= speaker and p.Character and getRoot(p.Character) then
					local d = (getRoot(p.Character).Position - myRoot.Position).Magnitude
					if d < dist then
						dist = d
						nearest = p
					end
				end
			end
		end
		if nearest then table.insert(targets, nearest) end
	elseif input == "farthest" then
		local farthest, dist = nil, 0
		local myRoot = getRoot(speaker.Character)
		if myRoot then
			for _, p in ipairs(Players:GetPlayers()) do
				if p ~= speaker and p.Character and getRoot(p.Character) then
					local d = (getRoot(p.Character).Position - myRoot.Position).Magnitude
					if d > dist then
						dist = d
						farthest = p
					end
				end
			end
		end
		if farthest then table.insert(targets, farthest) end
	elseif input == "alive" then
		for _, p in ipairs(Players:GetPlayers()) do
			if p.Character and getHum(p.Character) and getHum(p.Character).Health > 0 then
				table.insert(targets, p)
			end
		end
	elseif input == "dead" then
		for _, p in ipairs(Players:GetPlayers()) do
			if p.Character and getHum(p.Character) and getHum(p.Character).Health <= 0 then
				table.insert(targets, p)
			end
		end
	elseif input:sub(1, 1) == "@" then
		local uname = input:sub(2)
		for _, p in ipairs(Players:GetPlayers()) do
			if p.Name:lower():find(uname, 1, true) then
				table.insert(targets, p)
				break
			end
		end
	elseif input:sub(1, 3) == "age" then
		local age = tonumber(input:sub(4)) or 0
		for _, p in ipairs(Players:GetPlayers()) do
			if p.AccountAge <= age then
				table.insert(targets, p)
			end
		end
	elseif input:sub(1, 3) == "rad" then
		local rad = tonumber(input:sub(4)) or 0
		local myRoot = getRoot(speaker.Character)
		if myRoot then
			for _, p in ipairs(Players:GetPlayers()) do
				if p ~= speaker and p.Character and getRoot(p.Character) then
					if (getRoot(p.Character).Position - myRoot.Position).Magnitude <= rad then
						table.insert(targets, p)
					end
				end
			end
		end
	elseif input:sub(1, 5) == "group" then
		local gid = tonumber(input:sub(6)) or 0
		for _, p in ipairs(Players:GetPlayers()) do
			if p:IsInGroup(gid) then
				table.insert(targets, p)
			end
		end
	elseif input:sub(1, 1) == "#" then
		local num = tonumber(input:sub(2)) or 1
		local pool = {}
		for _, p in ipairs(Players:GetPlayers()) do
			if p ~= speaker then
				table.insert(pool, p)
			end
		end
		for i = 1, math.min(num, #pool) do
			local idx = math.random(1, #pool)
			table.insert(targets, pool[idx])
			table.remove(pool, idx)
		end
	else
		for _, p in ipairs(Players:GetPlayers()) do
			if p.Name:lower():find(input, 1, true) or p.DisplayName:lower():find(input, 1, true) then
				table.insert(targets, p)
				break
			end
		end
	end
	return targets
end

local currentPlayerList = {}
local refreshPending = false
local refreshDebounce = nil

local function getPlayerNames()
	local names = {}
	for _, p in ipairs(Players:GetPlayers()) do
		table.insert(names, p.Name)
	end
	return names
end

local function compareLists(old, new)
	if #old ~= #new then return false end
	for i, name in ipairs(old) do
		if name ~= new[i] then return false end
	end
	return true
end

local Connections = {}
local Toggles = {}
local Values = {}
local PlayerDropdowns = {}
local SelectedPlayers = {}
local selectedTpPlayer = ""

local WindUI = loadstring(game:HttpGet("https://article-hub-studio.github.io/WindUI-Skibidi/loader.lua"))()
WindUI:SetNotificationLower(true)

local Window = WindUI:CreateWindow({
	Title = "Universal Script",
	Icon = "zap",
	Author = "Elvis Fofo",
	Theme = "Dark",
	NewElements = false,
	IconsThemed = true,
	Transparent = true,
	Acrylic = false,
})

Window:Tag({
	Title = "v1.0",
	Icon = "github",
	Color = Color3.fromHex("#5eccff"),
	Radius = 7,
})

Window:EditOpenButton({
	Title = "Open Script",
	Icon = "zap",
	CornerRadius = UDim.new(0, 16),
	StrokeThickness = 2,
	Color = ColorSequence.new(
		Color3.fromHex("3deb51"),
		Color3.fromHex("00a613")
	),
	OnlyMobile = false,
	Enabled = true,
	Draggable = true,
})

local Tabs = {}
Tabs.Movement = Window:Tab({ Title = "Movement", Icon = "move" })
Tabs.Player = Window:Tab({ Title = "Player", Icon = "user" })
Tabs.Visuals = Window:Tab({ Title = "Visuals", Icon = "eye" })
Tabs.Teleports = Window:Tab({ Title = "Teleports", Icon = "map-pin" })
Tabs.Server = Window:Tab({ Title = "Server", Icon = "globe" })
Tabs.Utilities = Window:Tab({ Title = "Utilities", Icon = "wrench" })
Tabs.Fun = Window:Tab({ Title = "Fun", Icon = "smile" })
Tabs.Misc = Window:Tab({ Title = "Miscellaneous", Icon = "columns-2" })

local function refreshPlayerDropdowns()
	local names = getPlayerNames()
	for key, dropdown in pairs(PlayerDropdowns) do
		pcall(function()
			dropdown:SetValues(names)
		end)
	end
end

Players.PlayerAdded:Connect(refreshPlayerDropdowns)
Players.PlayerRemoving:Connect(refreshPlayerDropdowns)

Tabs.Movement:Section({ Title = "Flight", Opened = true })

xpcall(function()
	IsOnMobile = table.find({Enum.Platform.Android, Enum.Platform.IOS}, UserInputService:GetPlatform())
end, function()
	IsOnMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
end)

local lp   = Players.LocalPlayer
FLYING      = false
QEfly       = true
iyflyspeed  = 1
vehicleflyspeed = 1
local flyKeyDown, flyKeyUp

local function getRoot(char)
	return char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso"))
end

function sFLY(vfly)
	local plr  = Players.LocalPlayer
	local char = plr.Character or plr.CharacterAdded:Wait()
	local humanoid = char:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		repeat task.wait() until char:FindFirstChildOfClass("Humanoid")
		humanoid = char:FindFirstChildOfClass("Humanoid")
	end
	if flyKeyDown or flyKeyUp then
		flyKeyDown:Disconnect()
		flyKeyUp:Disconnect()
	end
	local T = getRoot(char)
	if not T then return end
	local CONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
	local lCONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
	local SPEED = 0
	local function FLY()
		FLYING = true
		local BG = Instance.new("BodyGyro")
		local BV = Instance.new("BodyVelocity")
		BG.P = 9e4
		BG.Parent = T
		BV.Parent = T
		BG.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
		BG.CFrame = T.CFrame
		BV.Velocity = Vector3.new(0, 0, 0)
		BV.MaxForce = Vector3.new(9e9, 9e9, 9e9)
		task.spawn(function()
			repeat task.wait()
				local camera = workspace.CurrentCamera
				if not vfly and humanoid then
					humanoid.PlatformStand = true
				end
				if CONTROL.L + CONTROL.R ~= 0 or CONTROL.F + CONTROL.B ~= 0 or CONTROL.Q + CONTROL.E ~= 0 then
					SPEED = 50
				elseif SPEED ~= 0 then
					SPEED = 0
				end
				if (CONTROL.L + CONTROL.R) ~= 0 or (CONTROL.F + CONTROL.B) ~= 0 or (CONTROL.Q + CONTROL.E) ~= 0 then
					BV.Velocity = ((camera.CFrame.LookVector * (CONTROL.F + CONTROL.B)) + ((camera.CFrame * CFrame.new(CONTROL.L + CONTROL.R, (CONTROL.F + CONTROL.B + CONTROL.Q + CONTROL.E) * 0.2, 0).p) - camera.CFrame.p)) * SPEED
					lCONTROL = {F = CONTROL.F, B = CONTROL.B, L = CONTROL.L, R = CONTROL.R}
				elseif (CONTROL.L + CONTROL.R) == 0 and (CONTROL.F + CONTROL.B) == 0 and (CONTROL.Q + CONTROL.E) == 0 and SPEED ~= 0 then
					BV.Velocity = ((camera.CFrame.LookVector * (lCONTROL.F + lCONTROL.B)) + ((camera.CFrame * CFrame.new(lCONTROL.L + lCONTROL.R, (lCONTROL.F + lCONTROL.B + CONTROL.Q + CONTROL.E) * 0.2, 0).p) - camera.CFrame.p)) * SPEED
				else
					BV.Velocity = Vector3.new(0, 0, 0)
				end
				BG.CFrame = camera.CFrame
			until not FLYING
			CONTROL  = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
			lCONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
			SPEED = 0
			BG:Destroy()
			BV:Destroy()
			if humanoid then humanoid.PlatformStand = false end
		end)
	end
	flyKeyDown = UserInputService.InputBegan:Connect(function(input, processed)
		if processed then return end
		if input.KeyCode == Enum.KeyCode.W then CONTROL.F = (vfly and vehicleflyspeed or iyflyspeed)
		elseif input.KeyCode == Enum.KeyCode.S then CONTROL.B = -(vfly and vehicleflyspeed or iyflyspeed)
		elseif input.KeyCode == Enum.KeyCode.A then CONTROL.L = -(vfly and vehicleflyspeed or iyflyspeed)
		elseif input.KeyCode == Enum.KeyCode.D then CONTROL.R = (vfly and vehicleflyspeed or iyflyspeed)
		elseif input.KeyCode == Enum.KeyCode.E and QEfly then CONTROL.Q = (vfly and vehicleflyspeed or iyflyspeed) * 2
		elseif input.KeyCode == Enum.KeyCode.Q and QEfly then CONTROL.E = -(vfly and vehicleflyspeed or iyflyspeed) * 2
		end
		pcall(function() workspace.CurrentCamera.CameraType = Enum.CameraType.Track end)
	end)
	flyKeyUp = UserInputService.InputEnded:Connect(function(input, processed)
		if processed then return end
		if input.KeyCode == Enum.KeyCode.W then CONTROL.F = 0
		elseif input.KeyCode == Enum.KeyCode.S then CONTROL.B = 0
		elseif input.KeyCode == Enum.KeyCode.A then CONTROL.L = 0
		elseif input.KeyCode == Enum.KeyCode.D then CONTROL.R = 0
		elseif input.KeyCode == Enum.KeyCode.E then CONTROL.Q = 0
		elseif input.KeyCode == Enum.KeyCode.Q then CONTROL.E = 0
		end
	end)
	FLY()
end

function NOFLY()
	FLYING = false
	if flyKeyDown or flyKeyUp then flyKeyDown:Disconnect()
		flyKeyUp:Disconnect() end
	pcall(function()
		if Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
			Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid").PlatformStand = false
		end
		workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
	end)
end

local velocityHandlerName = "IYMobileVel_" .. math.random(1000, 9999)
local gyroHandlerName     = "IYMobileGyro_" .. math.random(1000, 9999)
local mfly1, mfly2

local function unmobilefly(speaker)
	pcall(function()
		FLYING = false
		local root = getRoot(speaker.Character)
		if root then
			local vel = root:FindFirstChild(velocityHandlerName)
			if vel then vel:Destroy() end
			local gyro = root:FindFirstChild(gyroHandlerName)
			if gyro then gyro:Destroy() end
		end
		if speaker.Character then
			local hum = speaker.Character:FindFirstChildWhichIsA("Humanoid")
			if hum then hum.PlatformStand = false end
		end
		if mfly1 then mfly1:Disconnect()
			mfly1 = nil end
		if mfly2 then mfly2:Disconnect()
			mfly2 = nil end
	end)
end

local function mobilefly(speaker, vfly)
	unmobilefly(speaker)
	FLYING = true
	local root = getRoot(speaker.Character)
	if not root then return end
	local camera = workspace.CurrentCamera
	local v3zero = Vector3.new(0, 0, 0)
	local v3inf  = Vector3.new(9e9, 9e9, 9e9)
	local controlModule = speaker.PlayerScripts:FindFirstChild("PlayerModule")
	if controlModule then
		controlModule = controlModule:FindFirstChild("ControlModule")
		if controlModule then
			controlModule = require(controlModule)
		end
	end
	if not controlModule then return end
	local bv = Instance.new("BodyVelocity")
	bv.Name = velocityHandlerName
	bv.Parent = root
	bv.MaxForce = v3zero
	bv.Velocity = v3zero
	local bg = Instance.new("BodyGyro")
	bg.Name = gyroHandlerName
	bg.Parent = root
	bg.MaxTorque = v3inf
	bg.P = 1000
	bg.D = 50
	mfly2 = RunService.RenderStepped:Connect(function()
		root = getRoot(speaker.Character)
		camera = workspace.CurrentCamera
		if speaker.Character and root and root:FindFirstChild(velocityHandlerName) and root:FindFirstChild(gyroHandlerName) then
			local humanoid = speaker.Character:FindFirstChildWhichIsA("Humanoid")
			local VH = root:FindFirstChild(velocityHandlerName)
			local GH = root:FindFirstChild(gyroHandlerName)
			VH.MaxForce = v3inf
			GH.MaxTorque = v3inf
			if not vfly and humanoid then humanoid.PlatformStand = true end
			GH.CFrame = camera.CoordinateFrame
			VH.Velocity = Vector3.new()
			local direction = controlModule:GetMoveVector()
			if direction.X ~= 0 then VH.Velocity = VH.Velocity + camera.CFrame.RightVector * (direction.X * ((vfly and vehicleflyspeed or iyflyspeed) * 50)) end
			if direction.Z ~= 0 then VH.Velocity = VH.Velocity - camera.CFrame.LookVector * (direction.Z * ((vfly and vehicleflyspeed or iyflyspeed) * 50)) end
		end
	end)
end

Tabs.Movement:Toggle({
	Title = "Fly",
	Desc = "Fly yourself. Works on both PC and mobile.",
	Value = false,
	Callback = function(state)
		if state then
			if not IsOnMobile then
				NOFLY()
				task.wait()
				sFLY()
				WindUI:Notify({Title = "Fly", Content = "Fly enabled", Duration = 1.5})
			else
				mobilefly(lp)
				WindUI:Notify({Title = "Fly", Content = "Fly enabled (Mobile)", Duration = 1.5})
			end
		else
			if not IsOnMobile then
				NOFLY()
				WindUI:Notify({Title = "Fly", Content = "Fly disabled", Duration = 1.5})
			else
				unmobilefly(lp)
				WindUI:Notify({Title = "Fly", Content = "Fly disabled (Mobile)", Duration = 1.5})
			end
		end
	end
})

Tabs.Movement:Slider({
	Title = "Fly Speed",
	Desc = "Set fly speed. Default=1",
	Step = 1,
	Value = {Min = 1, Max = 100, Default = 1},
	Callback = function(v)
		iyflyspeed = v
	end
})

Tabs.Movement:Toggle({
	Title = "Vehicle Fly (PC Only)",
	Desc = "Fly while in a vehicle",
	Value = false,
	Callback = function(state)
		if state then
			local seat = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") and LocalPlayer.Character:FindFirstChildOfClass("Humanoid").SeatPart
			if not seat then notify("Movement", "Not in a vehicle") return end
			local vehicle = seat.Parent
			while vehicle and vehicle.ClassName ~= "Model" do
				vehicle = vehicle.Parent
			end
			if not vehicle then return end
			local vRoot = vehicle:FindFirstChildWhichIsA("BasePart")
			if not vRoot then return end
			flyGyro = Instance.new("BodyGyro")
			flyGyro.P = 9e4
			flyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
			flyGyro.CFrame = vRoot.CFrame
			flyGyro.Parent = vRoot
			flyVel = Instance.new("BodyVelocity")
			flyVel.Velocity = Vector3.zero
			flyVel.MaxForce = Vector3.new(9e9, 9e9, 9e9)
			flyVel.Parent = vRoot
			flyConn = RunService.RenderStepped:Connect(function()
				local cam = Workspace.CurrentCamera
				local dir = Vector3.zero
				if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + cam.CFrame.LookVector end
				if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - cam.CFrame.LookVector end
				if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - cam.CFrame.RightVector end
				if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + cam.CFrame.RightVector end
				if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0, 1, 0) end
				if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir = dir - Vector3.new(0, 1, 0) end
				if dir.Magnitude > 0 then dir = dir.Unit * flySpeed end
				flyVel.Velocity = dir
				flyGyro.CFrame = cam.CFrame
			end)
		else
			if flyConn then flyConn:Disconnect() flyConn = nil end
			if flyGyro then flyGyro:Destroy() flyGyro = nil end
			if flyVel then flyVel:Destroy() flyVel = nil end
		end
	end
})

Tabs.Movement:Section({ Title = "Collision", Opened = true })

Tabs.Movement:Toggle({
	Title = "Noclip",
	Desc = "Walk through walls",
	Value = false,
	Callback = function(state)
		if state then
			Connections.Noclip = RunService.Stepped:Connect(function()
				local char = LocalPlayer.Character
				if char then
					for _, v in ipairs(char:GetDescendants()) do
						if v:IsA("BasePart") then
							v.CanCollide = false
						end
					end
				end
			end)
		else
			if Connections.Noclip then Connections.Noclip:Disconnect() Connections.Noclip = nil end
		end
	end
})

Tabs.Movement:Toggle({
	Title = "Vehicle Noclip",
	Desc = "Noclip for vehicle parts",
	Value = false,
	Callback = function(state)
		if state then
			local seat = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") and LocalPlayer.Character:FindFirstChildOfClass("Humanoid").SeatPart
			if not seat then notify("Movement", "Not in a vehicle") return end
			local vehicle = seat.Parent
			while vehicle and vehicle.ClassName ~= "Model" do
				vehicle = vehicle.Parent
			end
			if not vehicle then return end
			Values.VNoclipParts = {}
			for _, v in ipairs(vehicle:GetDescendants()) do
				if v:IsA("BasePart") and v.CanCollide then
					v.CanCollide = false
					table.insert(Values.VNoclipParts, v)
				end
			end
		else
			if Values.VNoclipParts then
				for _, v in ipairs(Values.VNoclipParts) do
					if v and v.Parent then
						v.CanCollide = true
					end
				end
				Values.VNoclipParts = {}
			end
		end
	end
})

Tabs.Movement:Toggle({
	Title = "Anti Void",
	Desc = "Prevent falling into void",
	Value = false,
	Callback = function(state)
		if state then
			Values.OrgDestroyHeight = Workspace.FallenPartsDestroyHeight
			Connections.AntiVoid = RunService.Stepped:Connect(function()
				local root = getRoot(LocalPlayer.Character)
				if root and root.Position.Y <= (Values.OrgDestroyHeight or -500) + 25 then
					root.Velocity = root.Velocity + Vector3.new(0, 250, 0)
				end
			end)
		else
			if Connections.AntiVoid then Connections.AntiVoid:Disconnect() Connections.AntiVoid = nil end
		end
	end
})

Tabs.Movement:Section({ Title = "Speed & Power", Opened = true })

Tabs.Movement:Slider({
	Title = "WalkSpeed",
	Desc = "Movement speed",
	Step = 1,
	Value = { Min = 0, Max = 500, Default = 16 },
	Callback = function(v)
		Values.LoopSpeed = v
		local hum = getHum(LocalPlayer.Character)
		if hum then hum.WalkSpeed = v end
	end
})

Tabs.Movement:Slider({
	Title = "JumpPower / Height",
	Desc = "Jump strength",
	Step = 1,
	Value = { Min = 0, Max = 300, Default = 50 },
	Callback = function(v)
		Values.LoopJump = v
		local hum = getHum(LocalPlayer.Character)
		if hum then
			if hum.UseJumpPower then hum.JumpPower = v else hum.JumpHeight = v end
		end
	end
})

Tabs.Movement:Slider({
	Title = "Gravity",
	Desc = "Workspace gravity",
	Step = 1,
	Value = { Min = 0, Max = 450, Default = 196 },
	Callback = function(v)
		Workspace.Gravity = v
	end
})

Tabs.Movement:Slider({
	Title = "Hip Height",
	Desc = "Character hip height",
	Step = 0.1,
	Value = { Min = 1, Max = 45, Default = 2.1 },
	Callback = function(v)
		local hum = getHum(LocalPlayer.Character)
		if hum then hum.HipHeight = v end
	end
})

Tabs.Movement:Slider({
	Title = "Max Slope Angle",
	Desc = "Maximum walkable angle",
	Step = 1,
	Value = { Min = 0, Max = 89, Default = 89 },
	Callback = function(v)
		local hum = getHum(LocalPlayer.Character)
		if hum then hum.MaxSlopeAngle = v end
	end
})

Tabs.Movement:Toggle({
	Title = "Loop WalkSpeed",
	Desc = "Lock walkspeed value",
	Value = false,
	Callback = function(state)
		if state then
			local function loop()
				local hum = getHum(LocalPlayer.Character)
				if hum then hum.WalkSpeed = Values.LoopSpeed or 16 end
			end
			loop()
			Connections.LoopSpeed = RunService.RenderStepped:Connect(loop)
		else
			if Connections.LoopSpeed then Connections.LoopSpeed:Disconnect() Connections.LoopSpeed = nil end
		end
	end
})

Tabs.Movement:Toggle({
	Title = "Loop JumpPower",
	Desc = "Lock jump power value",
	Value = false,
	Callback = function(state)
		if state then
			local function loop()
				local hum = getHum(LocalPlayer.Character)
				if hum then
					if hum.UseJumpPower then hum.JumpPower = Values.LoopJump or 50 else hum.JumpHeight = Values.LoopJump or 50 end
				end
			end
			loop()
			Connections.LoopJump = RunService.RenderStepped:Connect(loop)
		else
			if Connections.LoopJump then Connections.LoopJump:Disconnect() Connections.LoopJump = nil end
		end
	end
})

Tabs.Movement:Input({
	Title = "Spoof WalkSpeed Value",
	Desc = "Spoof walkspeed to this value",
	Value = "16",
	Placeholder = "Speed...",
	Callback = function(v)
		if hookmetamethod then
			local char = LocalPlayer.Character
			local stored = tonumber(v) or 16
			local idx; idx = hookmetamethod(game, "__index", newcclosure(function(self, key)
				if not checkcaller() and typeof(self) == "Instance" and self:IsA("Humanoid") and (key == "WalkSpeed" or key == "walkSpeed") and self:IsDescendantOf(char) then
					return stored
				end
				return idx(self, key)
			end))
			local nidx; nidx = hookmetamethod(game, "__newindex", newcclosure(function(self, key, value)
				if not checkcaller() and typeof(self) == "Instance" and self:IsA("Humanoid") and (key == "WalkSpeed" or key == "walkSpeed") and self:IsDescendantOf(char) then
					stored = tonumber(value)
				end
				return nidx(self, key, value)
			end))
		else
			notify("Movement", "Missing hookmetamethod")
		end
	end
})

Tabs.Movement:Input({
	Title = "Spoof JumpPower Value",
	Desc = "Spoof jumppower to this value",
	Value = "50",
	Placeholder = "Power...",
	Callback = function(v)
		if hookmetamethod then
			local char = LocalPlayer.Character
			local stored = tonumber(v) or 50
			local idx; idx = hookmetamethod(game, "__index", newcclosure(function(self, key)
				if not checkcaller() and typeof(self) == "Instance" and self:IsA("Humanoid") and (key == "JumpPower" or key == "jumpPower") and self:IsDescendantOf(char) then
					return stored
				end
				return idx(self, key)
			end))
			local nidx; nidx = hookmetamethod(game, "__newindex", newcclosure(function(self, key, value)
				if not checkcaller() and typeof(self) == "Instance" and self:IsA("Humanoid") and (key == "JumpPower" or key == "jumpPower") and self:IsDescendantOf(char) then
					stored = tonumber(value)
				end
				return nidx(self, key, value)
			end))
		else
			notify("Movement", "Missing hookmetamethod")
		end
	end
})

Tabs.Movement:Section({ Title = "Jumping", Opened = true })

Tabs.Movement:Toggle({
	Title = "Infinite Jump",
	Desc = "Jump in mid-air",
	Value = false,
	Callback = function(state)
		if state then
			Connections.InfJump = UserInputService.JumpRequest:Connect(function()
				local hum = getHum(LocalPlayer.Character)
				if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
			end)
		else
			if Connections.InfJump then Connections.InfJump:Disconnect() Connections.InfJump = nil end
		end
	end
})

Tabs.Movement:Toggle({
	Title = "Fly Jump",
	Desc = "Jump while flying",
	Value = false,
	Callback = function(state)
		if state then
			Connections.FlyJump = UserInputService.JumpRequest:Connect(function()
				local hum = getHum(LocalPlayer.Character)
				if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
			end)
		else
			if Connections.FlyJump then Connections.FlyJump:Disconnect() Connections.FlyJump = nil end
		end
	end
})

Tabs.Movement:Toggle({
	Title = "Auto Jump",
	Desc = "Auto-hop obstacles",
	Value = false,
	Callback = function(state)
		if state then
			Connections.AutoJump = RunService.RenderStepped:Connect(function()
				local char = LocalPlayer.Character
				local hum = getHum(char)
				local root = getRoot(char)
				if not hum or not root then return end
				local r1 = Workspace:FindPartOnRay(Ray.new(root.Position - Vector3.new(0, 1.5, 0), root.CFrame.LookVector * 3), char)
				local r2 = Workspace:FindPartOnRay(Ray.new(root.Position + Vector3.new(0, 1.5, 0), root.CFrame.LookVector * 3), char)
				if r1 or r2 then hum.Jump = true end
			end)
		else
			if Connections.AutoJump then Connections.AutoJump:Disconnect() Connections.AutoJump = nil end
		end
	end
})

Tabs.Movement:Toggle({
	Title = "Edge Jump",
	Desc = "Jump at ledges",
	Value = false,
	Callback = function(state)
		if state then
			local lastState, lastCF
			Connections.EdgeJump = RunService.RenderStepped:Connect(function()
				local char = LocalPlayer.Character
				local hum = getHum(char)
				local root = getRoot(char)
				if not hum or not root then return end
				local st = hum:GetState()
				if lastState ~= st and st == Enum.HumanoidStateType.Freefall and lastState ~= Enum.HumanoidStateType.Jumping then
					root.CFrame = lastCF
					root.Velocity = Vector3.new(root.Velocity.X, hum.JumpPower or hum.JumpHeight, root.Velocity.Z)
				end
				lastState = st
				lastCF = root.CFrame
			end)
		else
			if Connections.EdgeJump then Connections.EdgeJump:Disconnect() Connections.EdgeJump = nil end
		end
	end
})

Tabs.Movement:Section({ Title = "Movement Modifiers", Opened = true })

local tpWalkSpeed = 5
Tabs.Movement:Slider({
	Title = "Teleport Walk Speed",
	Desc = "Speed for teleport-walk",
	Step = 1,
	Value = { Min = 1, Max = 50, Default = 5 },
	Callback = function(v) tpWalkSpeed = v end
})

Tabs.Movement:Toggle({
	Title = "Teleport Walk",
	Desc = "Walkspeed but uses translateby to character to bypass ACs.",
	Value = false,
	Callback = function(state)
		if state then
			Connections.TpWalk = RunService.Heartbeat:Connect(function(dt)
				local char = LocalPlayer.Character
				local hum = getHum(char)
				if not char or not hum then return end
				if hum.MoveDirection.Magnitude > 0 then
					char:TranslateBy(hum.MoveDirection * tpWalkSpeed * dt * 10)
				end
			end)
		else
			if Connections.TpWalk then Connections.TpWalk:Disconnect() Connections.TpWalk = nil end
		end
	end
})

local spinSpeed = 20
Tabs.Movement:Slider({
	Title = "Spin Speed",
	Desc = "Rotation speed",
	Step = 1,
	Value = { Min = 1, Max = 100, Default = 20 },
	Callback = function(v)
		spinSpeed = v
		if Toggles.Spin then
			local root = getRoot(LocalPlayer.Character)
			if root then
				for _, v2 in ipairs(root:GetChildren()) do
					if v2.Name == "Spinning" and v2:IsA("BodyAngularVelocity") then
						v2.AngularVelocity = Vector3.new(0, spinSpeed, 0)
					end
				end
			end
		end
	end
})

Tabs.Movement:Toggle({
	Title = "Spin",
	Desc = "Spin your character",
	Value = false,
	Callback = function(state)
		Toggles.Spin = state
		local root = getRoot(LocalPlayer.Character)
		if not root then return end
		if state then
			for _, v in ipairs(root:GetChildren()) do
				if v.Name == "Spinning" then v:Destroy() end
			end
			local spin = Instance.new("BodyAngularVelocity")
			spin.Name = "Spinning"
			spin.MaxTorque = Vector3.new(0, math.huge, 0)
			spin.AngularVelocity = Vector3.new(0, spinSpeed, 0)
			spin.Parent = root
		else
			for _, v in ipairs(root:GetChildren()) do
				if v.Name == "Spinning" then v:Destroy() end
			end
		end
	end
})

Tabs.Movement:Toggle({
	Title = "AutoRotate",
	Desc = "Character auto rotation",
	Value = true,
	Callback = function(state)
		local hum = getHum(LocalPlayer.Character)
		if hum then hum.AutoRotate = state end
	end
})

Tabs.Movement:Toggle({
	Title = "PlatformStand",
	Desc = "Ragdoll state",
	Value = false,
	Callback = function(state)
		local hum = getHum(LocalPlayer.Character)
		if hum then hum.PlatformStand = state end
	end
})

Tabs.Movement:Button({
	Title = "Sit",
	Callback = function()
		local hum = getHum(LocalPlayer.Character)
		if hum then hum.Sit = true end
	end
})

Tabs.Movement:Button({
	Title = "Lay Down",
	Callback = function()
		local hum = getHum(LocalPlayer.Character)
		local root = getRoot(LocalPlayer.Character)
		if hum and root then
			hum.Sit = true
			task.wait(0.1)
			root.CFrame = root.CFrame * CFrame.Angles(math.pi * 0.5, 0, 0)
			for _, v in ipairs(hum:GetPlayingAnimationTracks()) do
				v:Stop()
			end
		end
	end
})

Tabs.Movement:Button({
	Title = "Jump",
	Callback = function()
		local hum = getHum(LocalPlayer.Character)
		if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
	end
})

Tabs.Movement:Button({
	Title = "Break Velocity",
	Callback = function()
		breakVelocity()
	end
})

Tabs.Movement:Toggle({
	Title = "NoRotate",
	Desc = "Disable auto rotation",
	Value = false,
	Callback = function(state)
		local hum = getHum(LocalPlayer.Character)
		if hum then hum.AutoRotate = not state end
	end
})

Tabs.Player:Section({ Title = "Universal Aim Hacks", Opened = true })

Tabs.Player:Button({
	Title = "Load AimHacks",
	Desc = "70+ Features",
	Callback = function()
		loadstring(game:HttpGet("https://gist.githubusercontent.com/hm5650/54370878acaa21e72fa0b56e8b91cc98/raw/bf17eaa82356c2bfd4b050d57d017948946c53d6/HBSS.lua"))()
	end
})

Tabs.Player:Section({ Title = "Health & State", Opened = true })

Tabs.Player:Button({
	Title = "God Mode",
	Callback = function()
		local char = LocalPlayer.Character
		local cam = Workspace.CurrentCamera
		local pos = cam.CFrame
		local hum = getHum(char)
		if not hum then return end
		local newHum = hum:Clone()
		newHum.Parent = char
		LocalPlayer.Character = nil
		newHum:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
		newHum:SetStateEnabled(Enum.HumanoidStateType.Physics, false)
		newHum.BreakJointsOnDeath = true
		hum:Destroy()
		LocalPlayer.Character = char
		cam.CameraSubject = newHum
		cam.CFrame = pos
		newHum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
		local anim = char:FindFirstChild("Animate")
		if anim then
			anim.Disabled = true
			task.wait()
			anim.Disabled = false
		end
		newHum.Health = newHum.MaxHealth
		notify("Player", "God mode applied")
	end
})

Tabs.Player:Button({
	Title = "Reset",
	Callback = function()
		local hum = getHum(LocalPlayer.Character)
		if hum then
			hum:ChangeState(Enum.HumanoidStateType.Dead)
		else
			LocalPlayer.Character:BreakJoints()
		end
	end
})

Tabs.Player:Button({
	Title = "Respawn",
	Callback = function()
		local pos = LocalPlayer.Character and getRoot(LocalPlayer.Character) and getRoot(LocalPlayer.Character).CFrame
		LocalPlayer.Character = nil
		LocalPlayer.CharacterAdded:Wait()
		task.wait(0.3)
		if pos then
			local root = getRoot(LocalPlayer.Character)
			if root then root.CFrame = pos end
		end
	end
})

Tabs.Player:Button({
	Title = "Refresh",
	Callback = function()
		local pos = LocalPlayer.Character and getRoot(LocalPlayer.Character) and getRoot(LocalPlayer.Character).CFrame
		local hum = getHum(LocalPlayer.Character)
		if hum then hum.Health = 0 end
		LocalPlayer.CharacterAdded:Wait()
		task.wait(0.3)
		if pos then
			local root = getRoot(LocalPlayer.Character)
			if root then root.CFrame = pos end
		end
	end
})

local InvisibleEnabled = false
local LocalPlayer = game.Players.LocalPlayer
local Character = nil
local Humanoid = nil
local HumanoidRootPart = nil
local VisibleParts = {}
local Connections = {}
local isSetup = false

local function SetupCharacter()
    Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    Humanoid = Character:WaitForChild("Humanoid")
    HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
    VisibleParts = {}

    for _, descendant in pairs(Character:GetDescendants()) do
        if descendant:IsA("BasePart") and descendant.Transparency == 0 then
            table.insert(VisibleParts, descendant)
        end
    end
end

local function SetInvisible(state)
    InvisibleEnabled = state
    local transparency = state and 0.5 or 0
    for _, part in pairs(VisibleParts) do
        pcall(function()
            part.Transparency = transparency
        end)
    end
end

local function StartInvisibilityLoop()
    if Connections.Heartbeat then
        Connections.Heartbeat:Disconnect()
        Connections.Heartbeat = nil
    end
    
    Connections.Heartbeat = game:GetService("RunService").Heartbeat:Connect(function()
        if InvisibleEnabled and Character and HumanoidRootPart and Humanoid then
            local OriginalCFrame = HumanoidRootPart.CFrame
            local OriginalCameraOffset = Humanoid.CameraOffset

            local DownCFrame = OriginalCFrame * CFrame.new(0, -200000, 0)
            HumanoidRootPart.CFrame = DownCFrame
            Humanoid.CameraOffset = DownCFrame:ToObjectSpace(CFrame.new(OriginalCFrame.Position)).Position

            game:GetService("RunService").RenderStepped:Wait()

            HumanoidRootPart.CFrame = OriginalCFrame
            Humanoid.CameraOffset = OriginalCameraOffset
        end
    end)
end

local function Initialize()
    if isSetup then return end
    isSetup = true
    
    SetupCharacter()
    
    Connections.CharacterAdded = LocalPlayer.CharacterAdded:Connect(function()
        InvisibleEnabled = false
        SetupCharacter()
        if Connections.Heartbeat then
            Connections.Heartbeat:Disconnect()
            Connections.Heartbeat = nil
        end
    end)
    
    StartInvisibilityLoop()
end

Initialize()

Tabs.Player:Toggle({
    Title = "Invisible",
    Desc = "Become invisible",
    Value = false,
    Callback = function(state)
        if not isSetup then
            Initialize()
        end
        
        if not Character or not HumanoidRootPart then
            SetupCharacter()
        end
        
        SetInvisible(state)
        
        if state and not Connections.Heartbeat then
            StartInvisibilityLoop()
        elseif not state and Connections.Heartbeat then
            Connections.Heartbeat:Disconnect()
            Connections.Heartbeat = nil
        end
    end
})

Tabs.Player:Toggle({
	Title = "Tool Invisible",
	Desc = "Invis using a tool",
	Value = false,
	Callback = function(state)
		if state then
			local char = LocalPlayer.Character
			if not char then return end
			local box = Instance.new("Part")
			box.Anchored = true
			box.CanCollide = true
			box.Size = Vector3.new(10, 1, 10)
			box.Position = Vector3.new(0, 10000, 0)
			box.Parent = Workspace
			local touched
			touched = box.Touched:Connect(function(part)
				if part.Parent == char then
					local hrp = getRoot(char)
					if hrp then
						local new = hrp:Clone()
						task.wait(0.25)
						hrp:Destroy()
						new.Parent = char
						char:MoveTo(Values.TpLocation or box.Position)
					end
				end
			end)
			Values.TinvisTouch = touched
			Values.TinvisBox = box
		else
			if Values.TinvisTouch then Values.TinvisTouch:Disconnect() end
			if Values.TinvisBox then Values.TinvisBox:Destroy() end
		end
	end
})

Tabs.Player:Toggle({
	Title = "No Sit",
	Desc = "Prevent sitting",
	Value = false,
	Callback = function(state)
		local hum = getHum(LocalPlayer.Character)
		if hum then hum:SetStateEnabled(Enum.HumanoidStateType.Seated, not state) end
	end
})

Tabs.Player:Toggle({
	Title = "Stun",
	Desc = "Platform stand",
	Value = false,
	Callback = function(state)
		local hum = getHum(LocalPlayer.Character)
		if hum then hum.PlatformStand = state end
	end
})

Tabs.Player:Button({
	Title = "Enable State",
	Callback = function()
		local hum = getHum(LocalPlayer.Character)
		if hum then
			hum:SetStateEnabled(Enum.HumanoidStateType.Running, true)
			hum:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
			hum:SetStateEnabled(Enum.HumanoidStateType.GettingUp, true)
			hum:SetStateEnabled(Enum.HumanoidStateType.Swimming, true)
			hum:SetStateEnabled(Enum.HumanoidStateType.Climbing, true)
			hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
			hum:SetStateEnabled(Enum.HumanoidStateType.Flying, true)
		end
	end
})

Tabs.Player:Button({
	Title = "Disable State",
	Callback = function()
		local hum = getHum(LocalPlayer.Character)
		if hum then
			hum:SetStateEnabled(Enum.HumanoidStateType.Running, false)
			hum:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
			hum:SetStateEnabled(Enum.HumanoidStateType.GettingUp, false)
			hum:SetStateEnabled(Enum.HumanoidStateType.Swimming, false)
			hum:SetStateEnabled(Enum.HumanoidStateType.Climbing, false)
			hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
			hum:SetStateEnabled(Enum.HumanoidStateType.Flying, false)
		end
	end
})

Tabs.Player:Section({ Title = "Body Modifications", Opened = true })

Tabs.Player:Button({
	Title = "No Limbs",
	Callback = function()
		local char = LocalPlayer.Character
		if not char then return end
		if isR15(char) then
			for _, v in ipairs(char:GetChildren()) do
				if v:IsA("BasePart") and (v.Name == "RightUpperLeg" or v.Name == "LeftUpperLeg" or v.Name == "RightUpperArm" or v.Name == "LeftUpperArm") then
					v:Destroy()
				end
			end
		else
			for _, v in ipairs(char:GetChildren()) do
				if v:IsA("BasePart") and (v.Name == "Right Leg" or v.Name == "Left Leg" or v.Name == "Right Arm" or v.Name == "Left Arm") then
					v:Destroy()
				end
			end
		end
	end
})

Tabs.Player:Button({
	Title = "No Arms",
	Callback = function()
		local char = LocalPlayer.Character
		if not char then return end
		if isR15(char) then
			for _, v in ipairs(char:GetChildren()) do
				if v:IsA("BasePart") and (v.Name == "RightUpperArm" or v.Name == "LeftUpperArm") then
					v:Destroy()
				end
			end
		else
			for _, v in ipairs(char:GetChildren()) do
				if v:IsA("BasePart") and (v.Name == "Right Arm" or v.Name == "Left Arm") then
					v:Destroy()
				end
			end
		end
	end
})

Tabs.Player:Button({
	Title = "No Legs",
	Callback = function()
		local char = LocalPlayer.Character
		if not char then return end
		if isR15(char) then
			for _, v in ipairs(char:GetChildren()) do
				if v:IsA("BasePart") and (v.Name == "RightUpperLeg" or v.Name == "LeftUpperLeg") then
					v:Destroy()
				end
			end
		else
			for _, v in ipairs(char:GetChildren()) do
				if v:IsA("BasePart") and (v.Name == "Right Leg" or v.Name == "Left Leg") then
					v:Destroy()
				end
			end
		end
	end
})

Tabs.Player:Button({
	Title = "Remove Face",
	Callback = function()
		local char = LocalPlayer.Character
		if not char then return end
		for _, v in ipairs(char:GetDescendants()) do
			if v:IsA("Decal") and v.Name == "face" then
				v:Destroy()
			end
		end
	end
})

Tabs.Player:Button({
	Title = "Naked",
	Callback = function()
		local char = LocalPlayer.Character
		if not char then return end
		for _, v in ipairs(char:GetDescendants()) do
			if v:IsA("Clothing") or v:IsA("ShirtGraphic") then
				v:Destroy()
			end
		end
	end
})

Tabs.Player:Button({
	Title = "Block Head",
	Callback = function()
		local head = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Head")
		if head then
			local mesh = head:FindFirstChildOfClass("SpecialMesh")
			if mesh then mesh:Destroy() end
		end
	end
})

Tabs.Player:Button({
	Title = "Block Hats",
	Callback = function()
		local hum = getHum(LocalPlayer.Character)
		if not hum then return end
		for _, acc in ipairs(hum:GetAccessories()) do
			for _, v in ipairs(acc:GetDescendants()) do
				if v:IsA("SpecialMesh") then
					v:Destroy()
				end
			end
		end
	end
})

Tabs.Player:Button({
	Title = "Block Tool",
	Callback = function()
		local char = LocalPlayer.Character
		if not char then return end
		for _, v in ipairs(char:GetChildren()) do
			if v:IsA("Tool") or v:IsA("HopperBin") then
				for _, c in ipairs(v:GetDescendants()) do
					if c:IsA("SpecialMesh") then
						c:Destroy()
					end
				end
			end
		end
	end
})

Tabs.Player:Button({
	Title = "Creeper",
	Callback = function()
		local char = LocalPlayer.Character
		if not char then return end
		local head = char:FindFirstChild("Head")
		if head then
			local mesh = head:FindFirstChildOfClass("SpecialMesh")
			if mesh then mesh:Destroy() end
		end
		if isR15(char) then
			local ra = char:FindFirstChild("RightUpperArm")
			local la = char:FindFirstChild("LeftUpperArm")
			if ra then ra:Destroy() end
			if la then la:Destroy() end
		else
			local ra = char:FindFirstChild("Right Arm")
			local la = char:FindFirstChild("Left Arm")
			if ra then ra:Destroy() end
			if la then la:Destroy() end
		end
		local hum = getHum(char)
		if hum then
			pcall(function() hum:RemoveAccessories() end)
		end
	end
})

Tabs.Player:Button({
	Title = "Split",
	Callback = function()
		local char = LocalPlayer.Character
		if not char then return end
		if isR15(char) then
			local waist = char:FindFirstChild("UpperTorso") and char.UpperTorso:FindFirstChild("Waist")
			if waist then waist:Destroy() end
		else
			notify("Player", "Split requires R15")
		end
	end
})

Tabs.Player:Button({
	Title = "Nil Character",
	Callback = function()
		if LocalPlayer.Character then
			LocalPlayer.Character.Parent = nil
		end
	end
})

Tabs.Player:Button({
	Title = "Unnil Character",
	Callback = function()
		if LocalPlayer.Character then
			LocalPlayer.Character.Parent = Workspace
		end
	end
})

Tabs.Player:Button({
	Title = "Remove Root",
	Callback = function()
		local char = LocalPlayer.Character
		if not char then return end
		char.Parent = nil
		local hrp = getRoot(char)
		if hrp then hrp:Destroy() end
		char.Parent = Workspace
	end
})

Tabs.Player:Button({
	Title = "Replace Root",
	Callback = function()
		local char = LocalPlayer.Character
		if not char then return end
		local hrp = getRoot(char)
		if not hrp then return end
		local oldCF = hrp.CFrame
		local oldParent = char.Parent
		char.Parent = game
		local new = hrp:Clone()
		new.Parent = char
		hrp:Destroy()
		new.CFrame = oldCF
		char.Parent = oldParent
	end
})

Tabs.Player:Button({
	Title = "Clear Appearance",
	Callback = function()
		LocalPlayer:ClearCharacterAppearance()
	end
})

Tabs.Player:Slider({
	Title = "Head Size",
	Desc = "Scale your head",
	Step = 0.5,
	Value = { Min = 1, Max = 20, Default = 1 },
	Callback = function(v)
		local head = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Head")
		if head and head:IsA("BasePart") then
			head.Size = Vector3.new(2, 1, 1) * v
		end
	end
})

Tabs.Player:Slider({
	Title = "Hitbox Size",
	Desc = "Expand root part",
	Step = 0.5,
	Value = { Min = 1, Max = 20, Default = 1 },
	Callback = function(v)
		local root = getRoot(LocalPlayer.Character)
		if root and root:IsA("BasePart") then
			root.Size = Vector3.new(2, 1, 1) * v
			root.Transparency = 0.4
		end
	end
})

Tabs.Player:Toggle({
	Title = "Strengthen",
	Desc = "Increase density",
	Value = false,
	Callback = function(state)
		local char = LocalPlayer.Character
		if not char then return end
		for _, v in ipairs(char:GetDescendants()) do
			if v:IsA("BasePart") then
				if state then
					v.CustomPhysicalProperties = PhysicalProperties.new(100, 0.3, 0.5)
				else
					v.CustomPhysicalProperties = PhysicalProperties.new(0.7, 0.3, 0.5)
				end
			end
		end
	end
})

Tabs.Player:Toggle({
	Title = "Weaken",
	Desc = "Decrease density",
	Value = false,
	Callback = function(state)
		local char = LocalPlayer.Character
		if not char then return end
		for _, v in ipairs(char:GetDescendants()) do
			if v:IsA("BasePart") then
				if state then
					v.CustomPhysicalProperties = PhysicalProperties.new(0, 0.3, 0.5)
				else
					v.CustomPhysicalProperties = PhysicalProperties.new(0.7, 0.3, 0.5)
				end
			end
		end
	end
})

Tabs.Player:Section({ Title = "Animations", Opened = true })

local danceTrack
Tabs.Player:Button({
	Title = "Dance",
	Callback = function()
		if danceTrack then pcall(function() danceTrack:Stop() danceTrack:Destroy() end) end
		local hum = getHum(LocalPlayer.Character)
		if not hum then return end
		local dances = {"27789359", "30196114", "248263260", "45834924", "33796059", "28488254", "52155728"}
		if isR15(LocalPlayer.Character) then
			dances = {"3333432454", "4555808220", "4049037604", "4555782893", "10214311282", "10714010337", "10713981723", "10714372526", "10714076981", "10714392151", "11444443576"}
		end
		local anim = Instance.new("Animation")
		anim.AnimationId = "rbxassetid://" .. dances[math.random(1, #dances)]
		danceTrack = hum:LoadAnimation(anim)
		danceTrack.Looped = true
		danceTrack:Play()
	end
})

Tabs.Player:Button({
	Title = "Stop Dance",
	Callback = function()
		if danceTrack then
			pcall(function() danceTrack:Stop() danceTrack:Destroy() end)
			danceTrack = nil
		end
	end
})

Tabs.Player:Input({
	Title = "Play Animation",
	Desc = "Enter animation ID",
	Value = "",
	Placeholder = "Animation ID...",
	Callback = function(id)
		local hum = getHum(LocalPlayer.Character)
		if not hum then return end
		if id == "" then return end
		if not id:find("rbxassetid://") then id = "rbxassetid://" .. id end
		local anim = Instance.new("Animation")
		anim.AnimationId = id
		local track = hum:LoadAnimation(anim)
		track.Priority = Enum.AnimationPriority.Action
		track:Play()
	end
})

Tabs.Player:Input({
	Title = "Play Emote",
	Desc = "Enter emote ID",
	Value = "",
	Placeholder = "Emote ID...",
	Callback = function(id)
		local hum = getHum(LocalPlayer.Character)
		if not hum or id == "" then return end
		local ok, track = pcall(function()
			return hum:PlayEmoteAndGetAnimTrackById(tonumber(id))
		end)
		if ok and track then
			track:Play()
		end
	end
})

Tabs.Player:Button({
	Title = "Stop Animations",
	Callback = function()
		local hum = getHum(LocalPlayer.Character)
		if hum then
			for _, v in ipairs(hum:GetPlayingAnimationTracks()) do
				v:Stop()
			end
		end
	end
})

Tabs.Player:Button({
	Title = "Refresh Animations",
	Callback = function()
		local char = LocalPlayer.Character
		if not char then return end
		local anim = char:FindFirstChild("Animate")
		if anim then
			anim.Disabled = true
			task.wait()
			anim.Disabled = false
		end
	end
})

Tabs.Player:Button({
	Title = "Freeze Animations",
	Callback = function()
		local hum = getHum(LocalPlayer.Character)
		if hum then
			for _, v in ipairs(hum:GetPlayingAnimationTracks()) do
				v:AdjustSpeed(0)
			end
		end
	end
})

Tabs.Player:Button({
	Title = "Unfreeze Animations",
	Callback = function()
		local hum = getHum(LocalPlayer.Character)
		if hum then
			for _, v in ipairs(hum:GetPlayingAnimationTracks()) do
				v:AdjustSpeed(1)
			end
		end
	end
})

Tabs.Player:Button({
	Title = "Loop Animations",
	Callback = function()
		local hum = getHum(LocalPlayer.Character)
		if hum then
			for _, v in ipairs(hum:GetPlayingAnimationTracks()) do
				v.Looped = true
			end
		end
	end
})

Tabs.Player:Button({
	Title = "Animation Speed",
	Callback = function()

		local hum = getHum(LocalPlayer.Character)
		if hum then
			for _, v in ipairs(hum:GetPlayingAnimationTracks()) do
				v:AdjustSpeed(2)
			end
		end
	end
})

Tabs.Player:Button({
	Title = "Spasm (R6)",
	Callback = function()
		if isR15(LocalPlayer.Character) then
			notify("Player", "Spasm requires R6")
			return
		end
		local hum = getHum(LocalPlayer.Character)
		if not hum then return end
		local anim = Instance.new("Animation")
		anim.AnimationId = "rbxassetid://33796059"
		local track = hum:LoadAnimation(anim)
		track:Play()
		track:AdjustSpeed(99)
	end
})

Tabs.Player:Button({
	Title = "Head Throw (R6)",
	Callback = function()
		if isR15(LocalPlayer.Character) then
			notify("Player", "Head throw requires R6")
			return
		end
		local hum = getHum(LocalPlayer.Character)
		if not hum then return end
		local anim = Instance.new("Animation")
		anim.AnimationId = "rbxassetid://35154961"
		local track = hum:LoadAnimation(anim)
		track:Play(0)
		track:AdjustSpeed(1)
	end
})

Tabs.Player:Toggle({
	Title = "Sitwalk",
	Desc = "Walk while sitting",
	Value = false,
	Callback = function(state)
		local char = LocalPlayer.Character
		if not char then return end
		local anims = char:FindFirstChild("Animate")
		if not anims then return end
		local sit = anims:FindFirstChild("sit")
		if not sit then return end
		local sitAnim = sit:FindFirstChildWhichIsA("Animation")
		if not sitAnim then return end
		if state then
			Values.SitwalkIdle = anims.idle:FindFirstChildWhichIsA("Animation") and anims.idle:FindFirstChildWhichIsA("Animation").AnimationId
			Values.SitwalkWalk = anims.walk:FindFirstChildWhichIsA("Animation") and anims.walk:FindFirstChildWhichIsA("Animation").AnimationId
			Values.SitwalkRun = anims.run:FindFirstChildWhichIsA("Animation") and anims.run:FindFirstChildWhichIsA("Animation").AnimationId
			Values.SitwalkJump = anims.jump:FindFirstChildWhichIsA("Animation") and anims.jump:FindFirstChildWhichIsA("Animation").AnimationId
			if anims.idle:FindFirstChildWhichIsA("Animation") then anims.idle:FindFirstChildWhichIsA("Animation").AnimationId = sitAnim.AnimationId end
			if anims.walk:FindFirstChildWhichIsA("Animation") then anims.walk:FindFirstChildWhichIsA("Animation").AnimationId = sitAnim.AnimationId end
			if anims.run:FindFirstChildWhichIsA("Animation") then anims.run:FindFirstChildWhichIsA("Animation").AnimationId = sitAnim.AnimationId end
			if anims.jump:FindFirstChildWhichIsA("Animation") then anims.jump:FindFirstChildWhichIsA("Animation").AnimationId = sitAnim.AnimationId end
			local hum = getHum(char)
			if hum then
				hum.HipHeight = not isR15(char) and -1.5 or 0.5
			end
		else
			if Values.SitwalkIdle and anims.idle:FindFirstChildWhichIsA("Animation") then anims.idle:FindFirstChildWhichIsA("Animation").AnimationId = Values.SitwalkIdle end
			if Values.SitwalkWalk and anims.walk:FindFirstChildWhichIsA("Animation") then anims.walk:FindFirstChildWhichIsA("Animation").AnimationId = Values.SitwalkWalk end
			if Values.SitwalkRun and anims.run:FindFirstChildWhichIsA("Animation") then anims.run:FindFirstChildWhichIsA("Animation").AnimationId = Values.SitwalkRun end
			if Values.SitwalkJump and anims.jump:FindFirstChildWhichIsA("Animation") then anims.jump:FindFirstChildWhichIsA("Animation").AnimationId = Values.SitwalkJump end
		end
	end
})

Tabs.Player:Toggle({
	Title = "No Animations",
	Desc = "Disable animate script",
	Value = false,
	Callback = function(state)
		local char = LocalPlayer.Character
		if not char then return end
		local anim = char:FindFirstChild("Animate")
		if anim then
			anim.Disabled = state
		end
	end
})

Tabs.Player:Button({
	Title = "Copy Animation",
	Callback = function()
		if selectedTpPlayer == "" then notify("Player", "No player selected") return end
		local targets = getPlayer(selectedTpPlayer)
		local target = targets[1]
		if not target or not target.Character then return end
		local myHum = getHum(LocalPlayer.Character)
		local theirHum = getHum(target.Character)
		if not myHum or not theirHum then return end
		for _, v in ipairs(myHum:GetPlayingAnimationTracks()) do
			v:Stop()
		end
		for _, v in ipairs(theirHum:GetPlayingAnimationTracks()) do
			if not v.Animation.AnimationId:find("507768375") then
				local anim = myHum:LoadAnimation(v.Animation)
				anim:Play(0.1, 1, v.Speed)
				anim.TimePosition = v.TimePosition
				task.spawn(function()
					v.Stopped:Wait()
					anim:Stop()
					anim:Destroy()
				end)
			end
		end
	end
})

Tabs.Player:Button({
	Title = "Copy Animation ID",
	Callback = function()
		local hum = getHum(LocalPlayer.Character)
		if not hum then return end
		local result = "Animations:"
		for _, v in ipairs(hum:GetPlayingAnimationTracks()) do
			local id = v.Animation.AnimationId
			if not id:find("507768375") and not id:find("180435571") then
				result = result .. "\n" .. id
			end
		end
		toClipboard(result)
	end
})

Tabs.Visuals:Section({ Title = "ESP & Highlights", Opened = true })

ESPenabled = false
CHMSenabled = false
espTransparency = 0

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local lp = Players.LocalPlayer
local COREGUI = game:GetService("CoreGui") or lp:FindFirstChildWhichIsA("PlayerGui")

local function getRoot(character)
    return character and character:FindFirstChild("HumanoidRootPart")
end

local function round(num, decimal)
    return math.floor(num * (10^decimal) + 0.5) / (10^decimal)
end

function ESP(plr, logic)
    task.spawn(function()
        if plr.Name == lp.Name or not plr.Character then return end        
        local espName = plr.Name.."_ESP"
        local oldESP = COREGUI:FindFirstChild(espName)
        if oldESP then oldESP:Destroy() end
        local character = plr.Character
        if not character or not getRoot(character) or not character:FindFirstChildOfClass("Humanoid") then
            repeat task.wait(0.5) until plr.Character and getRoot(plr.Character) and plr.Character:FindFirstChildOfClass("Humanoid")
            character = plr.Character
        end        
        if not character then return end        
        local ESPholder = Instance.new("Folder")
        ESPholder.Name = espName
        ESPholder.Parent = COREGUI        
        local adornments = {}
        for _, n in ipairs(character:GetChildren()) do
            if n:IsA("BasePart") then
                local a = Instance.new("BoxHandleAdornment")
                a.Name = plr.Name
                a.Parent = ESPholder
                a.Adornee = n
                a.AlwaysOnTop = true
                a.ZIndex = 10
                a.Size = n.Size
                a.Transparency = espTransparency                
                if logic then
                    a.Color = BrickColor.new(plr.TeamColor == lp.TeamColor and "Bright green" or "Bright red")
                else
                    a.Color = plr.TeamColor
                end
                adornments[n] = a
            end
        end
        
        local bg = nil
        local tl = nil
        if character:FindFirstChild("Head") then
            bg = Instance.new("BillboardGui")
            tl = Instance.new("TextLabel")
            bg.Adornee = character.Head
            bg.Name = plr.Name
            bg.Parent = ESPholder
            bg.Size = UDim2.new(0,100,0,150)
            bg.StudsOffset = Vector3.new(0,1,0)
            bg.AlwaysOnTop = true
            
            tl.Parent = bg
            tl.BackgroundTransparency = 1
            tl.Position = UDim2.new(0,0,0,-50)
            tl.Size = UDim2.new(0,100,0,100)
            tl.Font = Enum.Font.SourceSansSemibold
            tl.TextSize = 20
            tl.TextColor3 = Color3.new(1,1,1)
            tl.TextStrokeTransparency = 0
            tl.TextYAlignment = Enum.TextYAlignment.Bottom
            tl.ZIndex = 10
            tl.Text = "Name: "..plr.Name
        end
        
        local connections = {}
        local isActive = true
        
        connections.CharacterAdded = plr.CharacterAdded:Connect(function(newChar)
            if ESPenabled and isActive then
                for _, conn in pairs(connections) do
                    if conn and conn.Disconnect then conn:Disconnect() end
                end
                ESPholder:Destroy()
                task.wait(0.1)
                ESP(plr, logic)
            else
                for _, conn in pairs(connections) do
                    if conn and conn.Disconnect then conn:Disconnect() end
                end
            end
        end)
        
        connections.TeamChange = plr:GetPropertyChangedSignal("TeamColor"):Connect(function()
            if ESPenabled and isActive and ESPholder.Parent then
                if logic then
                    local teamColor = plr.TeamColor == lp.TeamColor and "Bright green" or "Bright red"
                    for _, adrn in pairs(ESPholder:GetChildren()) do
                        if adrn:IsA("BoxHandleAdornment") then
                            adrn.Color = BrickColor.new(teamColor)
                        end
                    end
                else
                    for _, adrn in pairs(ESPholder:GetChildren()) do
                        if adrn:IsA("BoxHandleAdornment") then
                            adrn.Color = plr.TeamColor
                        end
                    end
                end
            end
        end)        
        connections.Removed = ESPholder.AncestryChanged:Connect(function()
            if not ESPholder.Parent then
                isActive = false
                for _, conn in pairs(connections) do
                    if conn and conn.Disconnect then conn:Disconnect() end
                end
            end
        end)
        
        local updateConnection
        updateConnection = RunService.Heartbeat:Connect(function()
            if not COREGUI:FindFirstChild(espName) or not isActive then
                updateConnection:Disconnect()
                return
            end            
            if plr.Character and getRoot(plr.Character) and plr.Character:FindFirstChildOfClass("Humanoid") and 
               lp.Character and getRoot(lp.Character) and tl then                
                local root1 = getRoot(lp.Character)
                local root2 = getRoot(plr.Character)
                if root1 and root2 then
                    local pos = math.floor((root1.Position - root2.Position).Magnitude)
                    local health = round(plr.Character:FindFirstChildOfClass("Humanoid").Health, 1)
                    tl.Text = "Name: "..plr.Name.." | Health: "..health.." | Studs: "..pos
                end
            end
        end)
        connections.Update = updateConnection
    end)
end

function CHMS(plr)
    task.spawn(function()
        if plr.Name == lp.Name or not plr.Character then return end        
        local chmsName = plr.Name.."_CHMS"        
        local oldCHMS = COREGUI:FindFirstChild(chmsName)
        if oldCHMS then oldCHMS:Destroy() end        
        local character = plr.Character
        if not character or not getRoot(character) or not character:FindFirstChildOfClass("Humanoid") then
            repeat task.wait(0.5) until plr.Character and getRoot(plr.Character) and plr.Character:FindFirstChildOfClass("Humanoid")
            character = plr.Character
        end        
        if not character then return end        
        local ESPholder = Instance.new("Folder")
        ESPholder.Name = chmsName
        ESPholder.Parent = COREGUI        
        local currentColor = plr.TeamColor        
        for _, n in ipairs(character:GetChildren()) do
            if n:IsA("BasePart") then
                local a = Instance.new("BoxHandleAdornment")
                a.Name = plr.Name
                a.Parent = ESPholder
                a.Adornee = n
                a.AlwaysOnTop = true
                a.ZIndex = 10
                a.Size = n.Size
                a.Transparency = espTransparency
                a.Color = currentColor
            end
        end
        
        local connections = {}
        local isActive = true
        
        connections.CharacterAdded = plr.CharacterAdded:Connect(function()
            if CHMSenabled and isActive then
                for _, conn in pairs(connections) do
                    if conn and conn.Disconnect then conn:Disconnect() end
                end
                ESPholder:Destroy()
                task.wait(0.1)
                CHMS(plr)
            else
                for _, conn in pairs(connections) do
                    if conn and conn.Disconnect then conn:Disconnect() end
                end
            end
        end)
        
        connections.TeamChange = plr:GetPropertyChangedSignal("TeamColor"):Connect(function()
            if CHMSenabled and isActive and ESPholder.Parent then
                currentColor = plr.TeamColor
                for _, adrn in pairs(ESPholder:GetChildren()) do
                    if adrn:IsA("BoxHandleAdornment") then
                        adrn.Color = currentColor
                    end
                end
            end
        end)        
        connections.Removed = ESPholder.AncestryChanged:Connect(function()
            if not ESPholder.Parent then
                isActive = false
                for _, conn in pairs(connections) do
                    if conn and conn.Disconnect then conn:Disconnect() end
                end
            end
        end)
    end)
end

Tabs.Visuals:Toggle({
    Title="ESP", Desc="Show all players with name/health/distance. ",
    Value=false,
    Callback=function(state)
        ESPenabled = state
        if state then
            for _, p in ipairs(Players:GetPlayers()) do ESP(p, false) end
            notify("ESP","ESP Enabled")
        else
            for _, v in pairs(COREGUI:GetChildren()) do
                if v.Name:find("_ESP") then v:Destroy() end
            end
            notify("ESP","ESP Disabled")
        end
    end
})

Tabs.Visuals:Toggle({
    Title="ESP Team", Desc="ESP with team colours — green=ally, red=enemy.",
    Value=false,
    Callback=function(state)
        ESPenabled = state
        if state then
            for _, p in ipairs(Players:GetPlayers()) do ESP(p, true) end
        else
            for _, v in pairs(COREGUI:GetChildren()) do
                if v.Name:find("_ESP") then v:Destroy() end
            end
        end
    end
})

Tabs.Visuals:Slider({
    Title="ESP Transparency", Desc="Box transparency for ESP/Chams. Default=0",
    Step=0.1, Value={Min=0,Max=1,Default=0},
    Callback=function(v) 
        espTransparency = v
        for _, folder in pairs(COREGUI:GetChildren()) do
            if folder.Name:find("_ESP") or folder.Name:find("_CHMS") then
                for _, adrn in pairs(folder:GetChildren()) do
                    if adrn:IsA("BoxHandleAdornment") then
                        adrn.Transparency = v
                    end
                end
            end
        end
    end
})

Tabs.Visuals:Toggle({
    Title="Chams", Desc="ESP without text overlay. ",
    Value=false,
    Callback=function(state)
        CHMSenabled = state
        if state then
            for _, p in ipairs(Players:GetPlayers()) do CHMS(p) end
        else
            for _, v in pairs(COREGUI:GetChildren()) do
                if v.Name:find("_CHMS") then v:Destroy() end
            end
        end
    end
})

Tabs.Visuals:Toggle({
	Title = "X-Ray",
	Desc = "See through parts",
	Value = false,
	Callback = function(state)
		for _, v in ipairs(Workspace:GetDescendants()) do
			if v:IsA("BasePart") then
				local parent = v.Parent
				local grandparent = parent and parent.Parent
				if not (parent and parent:FindFirstChildWhichIsA("Humanoid")) and not (grandparent and grandparent:FindFirstChildWhichIsA("Humanoid")) then
					v.LocalTransparencyModifier = state and 0.5 or 0
				end
			end
		end
	end
})

Tabs.Visuals:Toggle({
	Title = "Loop X-Ray",
	Desc = "Persistent x-ray",
	Value = false,
	Callback = function(state)
		if state then
			Connections.LoopXRay = RunService.RenderStepped:Connect(function()
				for _, v in ipairs(Workspace:GetDescendants()) do
					if v:IsA("BasePart") then
						local parent = v.Parent
						local grandparent = parent and parent.Parent
						if not (parent and parent:FindFirstChildWhichIsA("Humanoid")) and not (grandparent and grandparent:FindFirstChildWhichIsA("Humanoid")) then
							v.LocalTransparencyModifier = 0.5
						end
					end
				end
			end)
		else
			if Connections.LoopXRay then Connections.LoopXRay:Disconnect() Connections.LoopXRay = nil end
			for _, v in ipairs(Workspace:GetDescendants()) do
				if v:IsA("BasePart") then
					local parent = v.Parent
					local grandparent = parent and parent.Parent
					if not (parent and parent:FindFirstChildWhichIsA("Humanoid")) and not (grandparent and grandparent:FindFirstChildWhichIsA("Humanoid")) then
						v.LocalTransparencyModifier = 0
					end
				end
			end
		end
	end
})

Tabs.Visuals:Toggle({
	Title = "Fullbright",
	Desc = "Remove shadows",
	Value = false,
	Callback = function(state)
		if state then
			Lighting.Brightness = 2
			Lighting.ClockTime = 14
			Lighting.FogEnd = 100000
			Lighting.GlobalShadows = false
			Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
		else
			Lighting.Brightness = 1
			Lighting.ClockTime = 12
			Lighting.FogEnd = 1000
			Lighting.GlobalShadows = true
			Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
		end
	end
})

Tabs.Visuals:Toggle({
	Title = "Loop Fullbright",
	Desc = "Keep fullbright active",
	Value = false,
	Callback = function(state)
		if state then
			Connections.LoopFullbright = RunService.RenderStepped:Connect(function()
				Lighting.Brightness = 2
				Lighting.ClockTime = 14
				Lighting.FogEnd = 100000
				Lighting.GlobalShadows = false
				Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
			end)
		else
			if Connections.LoopFullbright then Connections.LoopFullbright:Disconnect() Connections.LoopFullbright = nil end
		end
	end
})

Tabs.Visuals:Button({
	Title = "No Fog",
	Callback = function()
		Lighting.FogEnd = 100000
		for _, v in ipairs(Lighting:GetDescendants()) do
			if v:IsA("Atmosphere") then
				v:Destroy()
			end
		end
	end
})

Tabs.Visuals:Slider({
	Title = "Brightness",
	Desc = "Lighting brightness",
	Step = 0.1,
	Value = { Min = 0, Max = 10, Default = 1 },
	Callback = function(v)
		Lighting.Brightness = v
	end
})

Tabs.Visuals:Slider({
	Title = "Clock Time",
	Desc = "Time of day",
	Step = 0.5,
	Value = { Min = 0, Max = 24, Default = 12 },
	Callback = function(v)
		Lighting.ClockTime = v
	end
})

Tabs.Visuals:Colorpicker({
	Title = "Ambient Color",
	Desc = "Set ambient lighting",
	Default = Lighting.Ambient,
	Callback = function(color)
		Lighting.Ambient = color
		Lighting.OutdoorAmbient = color
	end
})

Tabs.Visuals:Toggle({
	Title = "Show Bounding Boxes",
	Desc = "Debug rendering",
	Value = false,
	Callback = function(state)
		settings():GetService("RenderSettings").ShowBoundingBoxes = state
	end
})

Tabs.Visuals:Toggle({
	Title = "Hitboxes",
	Desc = "Show collision boxes",
	Value = false,
	Callback = function(state)
		settings():GetService("RenderSettings").ShowBoundingBoxes = state
	end
})

Tabs.Visuals:Toggle({
	Title = "Stare At Selected",
	Desc = "Look at target player",
	Value = false,
	Callback = function(state)
		if state then
			if selectedTpPlayer == "" then notify("Visuals", "No player selected") return end
			Connections.Stare = RunService.RenderStepped:Connect(function()
				local targets = getPlayer(selectedTpPlayer)
				local target = targets[1]
				if target and target.Character and getRoot(target.Character) and LocalPlayer.Character and getRoot(LocalPlayer.Character) then
					local myRoot = getRoot(LocalPlayer.Character)
					local tPos = getRoot(target.Character).Position
					local myPos = myRoot.Position
					myRoot.CFrame = CFrame.new(myPos, Vector3.new(tPos.X, myPos.Y, tPos.Z))
				end
			end)
		else
			if Connections.Stare then Connections.Stare:Disconnect() Connections.Stare = nil end
		end
	end
})

Tabs.Teleports:Section({ Title = "Player Target", Opened = true })

local tpPlayerDropdown = Tabs.Teleports:Dropdown({
	Title = "Select Player",
	Desc = "Target for teleport actions",
	Values = getPlayerNames(),
	Multi = false,
	AllowNone = true,
	Callback = function(option)
		if typeof(option) == "table" then
			selectedTpPlayer = option[1] or ""
		elseif typeof(option) == "string" then
			selectedTpPlayer = option
		else
			selectedTpPlayer = ""
		end
	end
})

PlayerDropdowns.Teleports = tpPlayerDropdown

local function refreshDropdown()
	if tpPlayerDropdown then
		local names = getPlayerNames()
		tpPlayerDropdown:Refresh(names)
	end
end

Players.PlayerAdded:Connect(refreshDropdown)
Players.PlayerRemoving:Connect(refreshDropdown)

Tabs.Teleports:Button({
	Title = "Goto Player",
	Callback = function()
		if selectedTpPlayer == "" then notify("Teleport", "No player selected") return end
		local targets = getPlayer(selectedTpPlayer)
		for _, p in ipairs(targets) do
			if p.Character and getRoot(p.Character) and LocalPlayer.Character and getRoot(LocalPlayer.Character) then
				getRoot(LocalPlayer.Character).CFrame = getRoot(p.Character).CFrame + Vector3.new(0, 3, 0)
				break
			end
		end
	end
})

Tabs.Teleports:Button({
	Title = "Bring Player",
	Callback = function()
		if selectedTpPlayer == "" then notify("Teleport", "No player selected") return end
		local targets = getPlayer(selectedTpPlayer)
		for _, p in ipairs(targets) do
			if p.Character and getRoot(p.Character) and LocalPlayer.Character and getRoot(LocalPlayer.Character) then
				getRoot(p.Character).CFrame = getRoot(LocalPlayer.Character).CFrame + Vector3.new(3, 1, 0)
				break
			end
		end
	end
})

Tabs.Teleports:Button({
	Title = "Client Bring",
	Callback = function()
		if selectedTpPlayer == "" then notify("Teleport", "No player selected") return end
		local targets = getPlayer(selectedTpPlayer)
		for _, p in ipairs(targets) do
			if p.Character and getRoot(p.Character) and LocalPlayer.Character and getRoot(LocalPlayer.Character) then
				local hum = getHum(p.Character)
				if hum then hum.Sit = false end
				task.wait()
				getRoot(p.Character).CFrame = getRoot(LocalPlayer.Character).CFrame + Vector3.new(3, 1, 0)
				break
			end
		end
	end
})

Tabs.Teleports:Toggle({
	Title = "Loop Goto",
	Desc = "Continuously teleport to player",
	Value = false,
	Callback = function(state)
		if state then
			Connections.LoopGoto = RunService.Heartbeat:Connect(function()
				if selectedTpPlayer == "" then return end
				local targets = getPlayer(selectedTpPlayer)
				for _, p in ipairs(targets) do
					if p.Character and getRoot(p.Character) and LocalPlayer.Character and getRoot(LocalPlayer.Character) then
						getRoot(LocalPlayer.Character).CFrame = getRoot(p.Character).CFrame + Vector3.new(0, 3, 0)
						break
					end
				end
			end)
		else
			if Connections.LoopGoto then Connections.LoopGoto:Disconnect() Connections.LoopGoto = nil end
		end
	end
})

Tabs.Teleports:Toggle({
	Title = "Loop Bring",
	Desc = "Continuously bring player",
	Value = false,
	Callback = function(state)
		if state then
			Connections.LoopBring = RunService.Heartbeat:Connect(function()
				if selectedTpPlayer == "" then return end
				local targets = getPlayer(selectedTpPlayer)
				for _, p in ipairs(targets) do
					if p.Character and getRoot(p.Character) and LocalPlayer.Character and getRoot(LocalPlayer.Character) then
						getRoot(p.Character).CFrame = getRoot(LocalPlayer.Character).CFrame + Vector3.new(3, 1, 0)
						break
					end
				end
			end)
		else
			if Connections.LoopBring then Connections.LoopBring:Disconnect() Connections.LoopBring = nil end
		end
	end
})

Tabs.Teleports:Button({
	Title = "Walk To",
	Callback = function()
		if selectedTpPlayer == "" then notify("Teleport", "No player selected") return end
		local targets = getPlayer(selectedTpPlayer)
		for _, p in ipairs(targets) do
			if p.Character and getRoot(p.Character) and LocalPlayer.Character then
				local hum = getHum(LocalPlayer.Character)
				if hum then
					hum:MoveTo(getRoot(p.Character).Position)
				end
				break
			end
		end
	end
})

Tabs.Teleports:Button({
	Title = "Pathfind Walk To",
	Callback = function()
		if selectedTpPlayer == "" then notify("Teleport", "No player selected") return end
		local targets = getPlayer(selectedTpPlayer)
		for _, p in ipairs(targets) do
			if p.Character and getRoot(p.Character) and LocalPlayer.Character then
				local hum = getHum(LocalPlayer.Character)
				if not hum then return end
				local path = PathfindingService:CreatePath()
				local success = pcall(function()
					path:ComputeAsync(getRoot(LocalPlayer.Character).Position, getRoot(p.Character).Position)
				end)
				if success then
					for _, waypoint in ipairs(path:GetWaypoints()) do
						hum:MoveTo(waypoint.Position)
						hum.MoveToFinished:Wait()
					end
				else
					hum:MoveTo(getRoot(p.Character).Position)
				end
				break
			end
		end
	end
})

Tabs.Teleports:Button({
	Title = "Head Sit",
	Callback = function()
		if selectedTpPlayer == "" then notify("Teleport", "No player selected") return end
		local targets = getPlayer(selectedTpPlayer)
		for _, p in ipairs(targets) do
			if p.Character and getRoot(p.Character) and LocalPlayer.Character then
				local hum = getHum(LocalPlayer.Character)
				if hum then hum.Sit = true end
				if Connections.HeadSit then Connections.HeadSit:Disconnect() end
				Connections.HeadSit = RunService.Heartbeat:Connect(function()
					if not p.Character or not getRoot(p.Character) or not LocalPlayer.Character or not getRoot(LocalPlayer.Character) then
						if Connections.HeadSit then Connections.HeadSit:Disconnect() Connections.HeadSit = nil end
						return
					end
					local myHum = getHum(LocalPlayer.Character)
					if myHum and myHum.Sit then
						getRoot(LocalPlayer.Character).CFrame = getRoot(p.Character).CFrame * CFrame.new(0, 1.6, 0.4)
					else
						if Connections.HeadSit then Connections.HeadSit:Disconnect() Connections.HeadSit = nil end
					end
				end)
				break
			end
		end
	end
})

local orbitSpeed = 0.2
local orbitDistance = 6
Tabs.Teleports:Slider({
	Title = "Orbit Speed",
	Desc = "Rotation speed",
	Step = 0.1,
	Value = { Min = 0.1, Max = 5, Default = 0.2 },
	Callback = function(v) orbitSpeed = v end
})

Tabs.Teleports:Slider({
	Title = "Orbit Distance",
	Desc = "Radius from target",
	Step = 0.5,
	Value = { Min = 1, Max = 20, Default = 6 },
	Callback = function(v) orbitDistance = v end
})

local orbitConn, orbitRender
Tabs.Teleports:Toggle({
	Title = "Orbit",
	Desc = "Orbit around selected player",
	Value = false,
	Callback = function(state)
		if state then
			if selectedTpPlayer == "" then notify("Teleport", "No player selected") return end
			local targets = getPlayer(selectedTpPlayer)
			local target = targets[1]
			if not target or not target.Character or not getRoot(target.Character) then return end
			local rotation = 0
			local root = getRoot(LocalPlayer.Character)
			if not root then return end
			orbitConn = RunService.Heartbeat:Connect(function()
				rotation = rotation + orbitSpeed
				local troot = getRoot(target.Character)
				if troot and root and root.Parent then
					root.CFrame = CFrame.new(troot.Position) * CFrame.Angles(0, math.rad(rotation), 0) * CFrame.new(orbitDistance, 0, 0)
				end
			end)
			orbitRender = RunService.RenderStepped:Connect(function()
				local troot = getRoot(target.Character)
				if troot and root and root.Parent then
					root.CFrame = CFrame.new(root.Position, troot.Position)
				end
			end)
		else
			if orbitConn then orbitConn:Disconnect() orbitConn = nil end
			if orbitRender then orbitRender:Disconnect() orbitRender = nil end
		end
	end
})

Tabs.Teleports:Section({ Title = "Position", Opened = true })

local tpX, tpY, tpZ = 0, 0, 0
Tabs.Teleports:Input({
	Title = "X Coordinate",
	Value = "0",
	Placeholder = "X...",
	Callback = function(v) tpX = tonumber(v) or 0 end
})

Tabs.Teleports:Input({
	Title = "Y Coordinate",
	Value = "0",
	Placeholder = "Y...",
	Callback = function(v) tpY = tonumber(v) or 0 end
})

Tabs.Teleports:Input({
	Title = "Z Coordinate",
	Value = "0",
	Placeholder = "Z...",
	Callback = function(v) tpZ = tonumber(v) or 0 end
})

Tabs.Teleports:Button({
	Title = "Teleport to Position",
	Callback = function()
		local root = getRoot(LocalPlayer.Character)
		if root then root.CFrame = CFrame.new(tpX, tpY, tpZ) end
	end
})

Tabs.Teleports:Button({
	Title = "Tween to Position",
	Callback = function()
		local root = getRoot(LocalPlayer.Character)
		if root then
			TweenService:Create(root, TweenInfo.new(1, Enum.EasingStyle.Linear), {CFrame = CFrame.new(tpX, tpY, tpZ)}):Play()
		end
	end
})

Tabs.Teleports:Button({
	Title = "Offset",
	Callback = function()
		local root = getRoot(LocalPlayer.Character)
		if root then
			root.CFrame = root.CFrame + Vector3.new(tpX, tpY, tpZ)
		end
	end
})

Tabs.Teleports:Button({
	Title = "Copy Position",
	Callback = function()
		local root = getRoot(LocalPlayer.Character)
		if root then
			local pos = root.Position
			local txt = math.round(pos.X) .. ", " .. math.round(pos.Y) .. ", " .. math.round(pos.Z)
			toClipboard(txt)
		end
	end
})

Tabs.Teleports:Button({
	Title = "Mouse Teleport",
	Callback = function()
		local root = getRoot(LocalPlayer.Character)
		local mouse = LocalPlayer:GetMouse()
		if root and mouse then
			root.CFrame = CFrame.new(mouse.Hit.X, mouse.Hit.Y + 3, mouse.Hit.Z)
			breakVelocity()
		end
	end
})

Tabs.Teleports:Button({
	Title = "Teleport Tool",
	Callback = function()
		local tool = Instance.new("Tool")
		tool.Name = "Teleport Tool"
		tool.RequiresHandle = false
		tool.Parent = LocalPlayer:FindFirstChildOfClass("Backpack")
		tool.Activated:Connect(function()
			local root = getRoot(LocalPlayer.Character)
			local mouse = LocalPlayer:GetMouse()
			if root and mouse then
				root.CFrame = CFrame.new(mouse.Hit.X, mouse.Hit.Y + 3, mouse.Hit.Z)
				breakVelocity()
			end
		end)
	end
})

Tabs.Teleports:Button({
	Title = "Through",
	Callback = function()
		local root = getRoot(LocalPlayer.Character)
		if root then
			root.CFrame = root.CFrame + root.CFrame.LookVector * 5
		end
	end
})

Tabs.Teleports:Button({
	Title = "Walk to Position",
	Callback = function()
		local hum = getHum(LocalPlayer.Character)
		if hum then
			hum.WalkToPoint = Vector3.new(tpX, tpY, tpZ)
		end
	end
})

Tabs.Teleports:Section({ Title = "Parts & Models", Opened = true })

local partNameInput = ""
Tabs.Teleports:Input({
	Title = "Part/Model Name",
	Value = "",
	Placeholder = "Name...",
	Callback = function(v) partNameInput = v end
})

Tabs.Teleports:Button({
	Title = "Goto Part",
	Callback = function()
		if partNameInput == "" then return end
		for _, v in ipairs(Workspace:GetDescendants()) do
			if v:IsA("BasePart") and v.Name:lower() == partNameInput:lower() then
				local root = getRoot(LocalPlayer.Character)
				if root then root.CFrame = v.CFrame end
				break
			end
		end
	end
})

Tabs.Teleports:Button({
	Title = "Goto Model",
	Callback = function()
		if partNameInput == "" then return end
		for _, v in ipairs(Workspace:GetDescendants()) do
			if v:IsA("Model") and v.Name:lower() == partNameInput:lower() then
				local root = getRoot(LocalPlayer.Character)
				if root then root.CFrame = v:GetModelCFrame() end
				break
			end
		end
	end
})

Tabs.Teleports:Button({
	Title = "Bring Part",
	Callback = function()
		if partNameInput == "" then return end
		for _, v in ipairs(Workspace:GetDescendants()) do
			if v:IsA("BasePart") and v.Name:lower() == partNameInput:lower() then
				local root = getRoot(LocalPlayer.Character)
				if root then v.CFrame = root.CFrame end
				break
			end
		end
	end
})

Tabs.Teleports:Section({ Title = "Fling", Opened = true })

Tabs.Teleports:Button({
	Title = "Fling GUI",
	Callback = function()
		loadstring(game:HttpGet("https://paste.rs/jqxgD"))()
	end
})

Tabs.Teleports:Toggle({
	Title = "Walk Fling",
	Desc = "Fling while walking",
	Value = false,
	Callback = function(state)
		if state then
			local char = LocalPlayer.Character
			local hum = getHum(char)
			if hum then
				hum.Died:Connect(function()
					if Connections.WalkFling then
						Connections.WalkFling:Disconnect()
						Connections.WalkFling = nil
					end
				end)
			end
			Connections.WalkFling = RunService.Heartbeat:Connect(function()
				local c = LocalPlayer.Character
				local r = getRoot(c)
				if not r then return end
				local vel = r.Velocity
				r.Velocity = vel * 10000 + Vector3.new(0, 10000, 0)
				RunService.RenderStepped:Wait()
				if r and r.Parent then
					r.Velocity = vel
				end
			end)
		else
			if Connections.WalkFling then
				Connections.WalkFling:Disconnect()
				Connections.WalkFling = nil
			end
		end
	end
})

Tabs.Teleports:Toggle({
	Title = "Anti Fling",
	Desc = "Prevent being flung",
	Value = false,
	Callback = function(state)
		if state then
			Connections.AntiFling = RunService.Stepped:Connect(function()
				for _, plr in ipairs(Players:GetPlayers()) do
					if plr ~= LocalPlayer and plr.Character then
						for _, v in ipairs(plr.Character:GetDescendants()) do
							if v:IsA("BasePart") then
								v.CanCollide = false
							end
						end
					end
				end
			end)
		else
			if Connections.AntiFling then
				Connections.AntiFling:Disconnect()
				Connections.AntiFling = nil
			end
		end
	end
})

Tabs.Server:Section({ Title = "Chat & Logs", Opened = true })

local chatLogsEnabled = false
local joinLogsEnabled = false

Tabs.Server:Toggle({
	Title = "Chat Logs",
	Desc = "Log chat messages to console",
	Value = false,
	Callback = function(state)
		chatLogsEnabled = state
	end
})

Tabs.Server:Toggle({
	Title = "Join Logs",
	Desc = "Log joins to console",
	Value = false,
	Callback = function(state)
		joinLogsEnabled = state
	end
})

local function logChat(player, message)
	if not chatLogsEnabled then return end
	print("[CHAT] " .. player.Name .. ": " .. message)
end

local function logJoin(player)
	if not joinLogsEnabled then return end
	print("[JOIN] " .. player.Name .. " joined")
end

if TextChatService.MessageReceived then
	TextChatService.MessageReceived:Connect(function(msg)
		if msg.TextSource then
			local plr = Players:GetPlayerByUserId(msg.TextSource.UserId)
			if plr then logChat(plr, msg.Text) end
		end
	end)
else
	for _, plr in ipairs(Players:GetPlayers()) do
		plr.Chatted:Connect(function(msg) logChat(plr, msg) end)
	end
	Players.PlayerAdded:Connect(function(plr)
		plr.Chatted:Connect(function(msg) logChat(plr, msg) end)
	end)
end
Players.PlayerAdded:Connect(logJoin)

Tabs.Server:Section({ Title = "Server", Opened = true })

Tabs.Server:Button({
	Title = "Universe Viewer",
	Callback = function()
		loadstring(game:HttpGet("https://raw.githubusercontent.com/ltseverydayyou/uuuuuuu/main/Universe%20Viewer"))()
	end
})

Tabs.Server:Button({
	Title = "Rejoin",
	Callback = function()
		TeleportService:Teleport(game.PlaceId, LocalPlayer)
	end
})

Tabs.Server:Button({
	Title = "Server Hop",
	Callback = function()
		local servers = {}
		local req = httprequest
		if req then
			local ok, res = pcall(function()
				return req({
					Url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100",
					Method = "GET"
				})
			end)
			if ok and res and res.Body then
				local data = HttpService:JSONDecode(res.Body)
				if data and data.data then
					for _, s in ipairs(data.data) do
						if s.playing < s.maxPlayers and s.id ~= game.JobId then
							table.insert(servers, s.id)
						end
					end
				end
			end
		end
		if #servers > 0 then
			TeleportService:TeleportToPlaceInstance(game.PlaceId, servers[math.random(1, #servers)], LocalPlayer)
		else
			notify("Server", "Could not find servers")
		end
	end
})

Tabs.Server:Button({
	Title = "Copy JobId",
	Callback = function()
		setclipboard(game.JobId)
		notify("Server", "JobId copied")
	end
})

Tabs.Server:Button({
	Title = "Copy PlaceId",
	Callback = function()
		setclipboard(tostring(game.PlaceId))
		notify("Server", "PlaceId copied")
	end
})

Tabs.Server:Section({ Title = "Watchers", Opened = true })

Tabs.Server:Toggle({
	Title = "Staff Watch",
	Desc = "Notify when staff join",
	Value = false,
	Callback = function(state)
		if state then
			if game.CreatorType ~= Enum.CreatorType.Group then
				notify("Server", "Game is not group-owned")
				return
			end
			local staffRoles = {"mod", "admin", "staff", "dev", "founder", "owner", "supervis", "manager", "management", "executive", "president", "chairman", "chairwoman", "chairperson", "director"}
			local function check(plr)
				local role = plr:GetRoleInGroup(game.CreatorId):lower()
				for _, r in ipairs(staffRoles) do
					if role:find(r) then
						notify("Staff Watch", plr.Name .. " is a " .. role)
						break
					end
				end
			end
			for _, plr in ipairs(Players:GetPlayers()) do check(plr) end
			Connections.StaffWatch = Players.PlayerAdded:Connect(check)
		else
			if Connections.StaffWatch then Connections.StaffWatch:Disconnect() Connections.StaffWatch = nil end
		end
	end
})

local roleWatchGroup = 0
local roleWatchRole = ""
Tabs.Server:Input({
	Title = "Role Watch Group ID",
	Value = "",
	Placeholder = "Group ID...",
	Callback = function(v)
		roleWatchGroup = tonumber(v) or 0
	end
})

Tabs.Server:Input({
	Title = "Role Watch Role Name",
	Value = "",
	Placeholder = "Role name...",
	Callback = function(v)
		roleWatchRole = v
	end
})

Tabs.Server:Toggle({
	Title = "Role Watch",
	Desc = "Watch for specific role",
	Value = false,
	Callback = function(state)
		if state then
			Connections.RoleWatch = Players.PlayerAdded:Connect(function(plr)
				if roleWatchGroup == 0 then return end
				if plr:IsInGroup(roleWatchGroup) then
					local role = plr:GetRoleInGroup(roleWatchGroup)
					if role:lower() == roleWatchRole:lower() then
						notify("Role Watch", plr.Name .. " joined with role " .. role)
					end
				end
			end)
		else
			if Connections.RoleWatch then Connections.RoleWatch:Disconnect() Connections.RoleWatch = nil end
		end
	end
})

Tabs.Server:Button({
	Title = "Find Friend Groups",
	Callback = function()
		notify("Server", "Checking players...")
		local graph = {}
		local seen = {}
		local groups = {}
		for _, p in ipairs(Players:GetPlayers()) do
			graph[p] = {}
		end
		for i = 1, #Players:GetPlayers() do
			for j = i + 1, #Players:GetPlayers() do
				local p1 = Players:GetPlayers()[i]
				local p2 = Players:GetPlayers()[j]
				local ok, res = pcall(function() return p1:IsFriendsWithAsync(p2.UserId) end)
				if ok and res then
					table.insert(graph[p1], p2)
					table.insert(graph[p2], p1)
				end
			end
		end
		local function dfs(player, group)
			seen[player] = true
			table.insert(group, player)
			for _, possible in ipairs(graph[player]) do
				if not seen[possible] then
					dfs(possible, group)
				end
			end
		end
		for _, p in ipairs(Players:GetPlayers()) do
			if not seen[p] then
				local group = {}
				dfs(p, group)
				if #group > 1 then
					table.insert(groups, group)
				end
			end
		end
		local result = ""
		for i, group in ipairs(groups) do
			local names = {}
			for _, p in ipairs(group) do
				table.insert(names, p.Name)
			end
			result = result .. i .. ". " .. table.concat(names, ", ") .. "\n"
		end
		if result == "" then result = "No friend groups found" end
		notify("Friend Groups", result)
	end
})

Tabs.Utilities:Section({ Title = "Exploit Tools", Opened = true })

Tabs.Utilities:Button({
	Title = "Dex Explorer",
	Callback = function()
		notify("Utilities", "Loading Dex...")
		loadstring(game:HttpGet("https://raw.githubusercontent.com/peyton2465/Dex/master/out.lua"))()
	end
})

Tabs.Utilities:Button({
	Title = "Remote Spy",
	Callback = function()
		notify("Utilities", "Loading Remote Spy...")
		loadstring(game:HttpGet("https://raw.githubusercontent.com/ltseverydayyou/uuuuuuu/refs/heads/main/SimpleSpyRework.luau"))()
	end
})

Tabs.Utilities:Button({
	Title = "Cobalt Spy",
	Callback = function()
		notify("Utilities", "Loading Cobalt...")
		loadstring(game:HttpGet("https://github.com/notpoiu/cobalt/releases/latest/download/Cobalt.luau"))()
	end
})

Tabs.Utilities:Button({
	Title = "Turtle Spy",
	Callback = function()
		notify("Utilities", "Loading Turtle ...")
		loadstring(game:HttpGet("https://raw.githubusercontent.com/ltseverydayyou/uuuuuuu/main/Turtle%20Spy.lua"))()
	end
})

Tabs.Utilities:Button({
	Title = "Console",
	Callback = function()
		StarterGui:SetCore("DevConsoleVisible", true)
	end
})

Tabs.Utilities:Section({ Title = "Interactions", Opened = true })

Tabs.Utilities:Button({
	Title = "Fire Click Detectors",
	Callback = function()
		if not fireclickdetector then
			notify("Utilities", "Missing fireclickdetector")
			return
		end
		for _, v in ipairs(Workspace:GetDescendants()) do
			if v:IsA("ClickDetector") then
				fireclickdetector(v)
			end
		end
	end
})

Tabs.Utilities:Button({
	Title = "Fire Proximity Prompts",
	Callback = function()
		if not fireproximityprompt then
			notify("Utilities", "Missing fireproximityprompt")
			return
		end
		for _, v in ipairs(Workspace:GetDescendants()) do
			if v:IsA("ProximityPrompt") then
				fireproximityprompt(v)
			end
		end
	end
})

Tabs.Utilities:Toggle({
	Title = "Instant Proximity Prompts",
	Desc = "Skip hold duration",
	Value = false,
	Callback = function(state)
		if state then
			if not fireproximityprompt then
				notify("Utilities", "Missing fireproximityprompt")
				return
			end
			Connections.InstantPP = ProximityPromptService.PromptButtonHoldBegan:Connect(function(prompt)
				fireproximityprompt(prompt)
			end)
		else
			if Connections.InstantPP then Connections.InstantPP:Disconnect() Connections.InstantPP = nil end
		end
	end
})

Tabs.Utilities:Button({
	Title = "No Click Detector Limits",
	Callback = function()
		for _, v in ipairs(Workspace:GetDescendants()) do
			if v:IsA("ClickDetector") then
				v.MaxActivationDistance = math.huge
			end
		end
	end
})

Tabs.Utilities:Button({
	Title = "No Proximity Prompt Limits",
	Callback = function()
		for _, v in ipairs(Workspace:GetDescendants()) do
			if v:IsA("ProximityPrompt") then
				v.MaxActivationDistance = math.huge
			end
		end
	end
})

Tabs.Utilities:Button({
	Title = "Touch Interests",
	Callback = function()
		if not firetouchinterest then
			notify("Utilities", "Missing firetouchinterest")
			return
		end
		local root = getRoot(LocalPlayer.Character)
		if not root then return end
		for _, v in ipairs(Workspace:GetDescendants()) do
			if v:IsA("TouchTransmitter") then
				local part = v:FindFirstAncestorWhichIsA("BasePart")
				if part then
					firetouchinterest(part, root, 0)
					firetouchinterest(part, root, 1)
				end
			end
		end
	end
})

Tabs.Utilities:Section({ Title = "Tools", Opened = true })

Tabs.Utilities:Button({
	Title = "Grab All Tools",
	Callback = function()
		local hum = getHum(LocalPlayer.Character)
		if not hum then return end
		for _, child in ipairs(Workspace:GetChildren()) do
			if child:IsA("BackpackItem") and child:FindFirstChild("Handle") then
				hum:EquipTool(child)
			end
		end
	end
})

Tabs.Utilities:Toggle({
	Title = "Auto Grab Tools",
	Desc = "Pick up dropped tools",
	Value = false,
	Callback = function(state)
		if state then
			Connections.GrabTools = Workspace.ChildAdded:Connect(function(child)
				if child:IsA("BackpackItem") and child:FindFirstChild("Handle") then
					local h = getHum(LocalPlayer.Character)
					if h then h:EquipTool(child) end
				end
			end)
		else
			if Connections.GrabTools then Connections.GrabTools:Disconnect() Connections.GrabTools = nil end
		end
	end
})

Tabs.Utilities:Button({
	Title = "Clear Tools",
	Callback = function()
		local bp = LocalPlayer:FindFirstChildOfClass("Backpack")
		if bp then
			for _, v in ipairs(bp:GetChildren()) do
				if v:IsA("Tool") or v:IsA("HopperBin") then
					v:Destroy()
				end
			end
		end
		local char = LocalPlayer.Character
		if char then
			for _, v in ipairs(char:GetChildren()) do
				if v:IsA("Tool") or v:IsA("HopperBin") then
					v:Destroy()
				end
			end
		end
	end
})

Tabs.Utilities:Button({
	Title = "Equip Tools",
	Callback = function()
		local bp = LocalPlayer:FindFirstChildOfClass("Backpack")
		if bp then
			for _, v in ipairs(bp:GetChildren()) do
				if v:IsA("Tool") or v:IsA("HopperBin") then
					v.Parent = LocalPlayer.Character
				end
			end
		end
	end
})

Tabs.Utilities:Button({
	Title = "Unequip Tools",
	Callback = function()
		local hum = getHum(LocalPlayer.Character)
		if hum then hum:UnequipTools() end
	end
})

Tabs.Utilities:Button({
	Title = "Drop Tools",
	Callback = function()
		for _, v in ipairs(LocalPlayer.Backpack:GetChildren()) do
			if v:IsA("Tool") then
				v.Parent = LocalPlayer.Character
			end
		end
		task.wait()
		for _, v in ipairs(LocalPlayer.Character:GetChildren()) do
			if v:IsA("Tool") then
				v.Parent = Workspace
			end
		end
	end
})

Tabs.Utilities:Button({
	Title = "Droppable Tools",
	Callback = function()
		local char = LocalPlayer.Character
		if char then
			for _, v in ipairs(char:GetChildren()) do
				if v:IsA("Tool") then
					v.CanBeDropped = true
				end
			end
		end
		local bp = LocalPlayer:FindFirstChildOfClass("Backpack")
		if bp then
			for _, v in ipairs(bp:GetChildren()) do
				if v:IsA("Tool") then
					v.CanBeDropped = true
				end
			end
		end
	end
})

Tabs.Utilities:Button({
	Title = "Copy Tools from Player",
	Callback = function()
		if selectedTpPlayer == "" then notify("Utilities", "No player selected") return end
		local targets = getPlayer(selectedTpPlayer)
		for _, p in ipairs(targets) do
			local bp = p:FindFirstChildOfClass("Backpack")
			if bp then
				for _, v in ipairs(bp:GetChildren()) do
					if v:IsA("Tool") or v:IsA("HopperBin") then
						v:Clone().Parent = LocalPlayer:FindFirstChildOfClass("Backpack")
					end
				end
			end
			break
		end
	end
})

Tabs.Utilities:Section({ Title = "Combat", Opened = true })

local reachSize = 60
Tabs.Utilities:Slider({
	Title = "Reach Size",
	Desc = "Tool reach distance",
	Step = 1,
	Value = { Min = 1, Max = 100, Default = 60 },
	Callback = function(v) reachSize = v end
})

Tabs.Utilities:Toggle({
	Title = "Reach",
	Desc = "Extend tool hitbox",
	Value = false,
	Callback = function(state)
		local char = LocalPlayer.Character
		if not char then return end
		for _, v in ipairs(char:GetDescendants()) do
			if v:IsA("Tool") and v:FindFirstChild("Handle") then
				if state then
					if not v.Handle:FindFirstChild("ReachBox") then
						local box = Instance.new("SelectionBox")
						box.Name = "ReachBox"
						box.Adornee = v.Handle
						box.Parent = v.Handle
					end
					v.Handle.Massless = true
					v.Handle.Size = Vector3.new(0.5, 0.5, reachSize)
					v.GripPos = Vector3.new(0, 0, 0)
				else
					local box = v.Handle:FindFirstChild("ReachBox")
					if box then box:Destroy() end
					v.Handle.Size = Vector3.new(1, 1, 1)
				end
			end
		end
	end
})

Tabs.Utilities:Toggle({
	Title = "Box Reach",
	Desc = "Box shaped reach",
	Value = false,
	Callback = function(state)
		local char = LocalPlayer.Character
		if not char then return end
		for _, v in ipairs(char:GetDescendants()) do
			if v:IsA("Tool") and v:FindFirstChild("Handle") then
				if state then
					if not v.Handle:FindFirstChild("ReachBox") then
						local box = Instance.new("SelectionBox")
						box.Name = "ReachBox"
						box.Adornee = v.Handle
						box.Parent = v.Handle
					end
					v.Handle.Massless = true
					v.Handle.Size = Vector3.new(reachSize, reachSize, reachSize)
					v.GripPos = Vector3.new(0, 0, 0)
				else
					local box = v.Handle:FindFirstChild("ReachBox")
					if box then box:Destroy() end
					v.Handle.Size = Vector3.new(1, 1, 1)
				end
			end
		end
	end
})

Tabs.Utilities:Input({
	Title = "Grip Position",
	Desc = "X Y Z",
	Value = "0 0 0",
	Placeholder = "0 0 0",
	Callback = function(v)
		local nums = {}
		for n in v:gmatch("%S+") do
			table.insert(nums, tonumber(n) or 0)
		end
		local char = LocalPlayer.Character
		if not char then return end
		for _, tool in ipairs(char:GetDescendants()) do
			if tool:IsA("Tool") then
				tool.Parent = LocalPlayer:FindFirstChildOfClass("Backpack")
				tool.GripPos = Vector3.new(nums[1] or 0, nums[2] or 0, nums[3] or 0)
				tool.Parent = char
			end
		end
	end
})

Tabs.Utilities:Toggle({
	Title = "Auto Click",
	Desc = "Rapid left clicks",
	Value = false,
	Callback = function(state)
		if state then
			if not mouse1press then
				notify("Utilities", "Missing mouse1press")
				return
			end
			Toggles.AutoClick = true
			Connections.AutoClick = task.spawn(function()
				while Toggles.AutoClick do
					mouse1press()
					task.wait(0.05)
					mouse1release()
					task.wait(0.05)
				end
			end)
		else
			Toggles.AutoClick = false
		end
	end
})

Tabs.Utilities:Section({ Title = "Misc Utilities", Opened = true })

Tabs.Utilities:Button({
	Title = "Fullbright",
	Callback = function()
		Lighting.Brightness = 2
		Lighting.ClockTime = 14
		Lighting.FogEnd = 100000
		Lighting.GlobalShadows = false
		Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
	end
})

Tabs.Utilities:Button({
	Title = "Restore Lighting",
	Callback = function()
		Lighting.Brightness = 1
		Lighting.ClockTime = 12
		Lighting.FogEnd = 1000
		Lighting.GlobalShadows = true
		Lighting.Ambient = Color3.fromRGB(128, 128, 128)
		Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
	end
})

Tabs.Utilities:Button({
	Title = "Day",
	Callback = function()
		Lighting.ClockTime = 14
	end
})

Tabs.Utilities:Button({
	Title = "Night",
	Callback = function()
		Lighting.ClockTime = 0
	end
})

Tabs.Utilities:Button({
	Title = "Remove Terrain",
	Callback = function()
		local terrain = Workspace:FindFirstChildOfClass("Terrain")
		if terrain then terrain:Clear() end
	end
})

Tabs.Utilities:Button({
	Title = "Clear Nil Instances",
	Callback = function()
		if getnilinstances then
			for _, v in ipairs(getnilinstances()) do
				v:Destroy()
			end
		else
			notify("Utilities", "Missing getnilinstances")
		end
	end
})

Tabs.Utilities:Input({
	Title = "Destroy Height",
	Value = tostring(Workspace.FallenPartsDestroyHeight),
	Placeholder = "Height...",
	Callback = function(v)
		local num = tonumber(v)
		if num then Workspace.FallenPartsDestroyHeight = num end
	end
})

Tabs.Utilities:Toggle({
	Title = "Anti Void",
	Desc = "Prevent void death",
	Value = false,
	Callback = function(state)
		if state then
			Values.OrgDestroyHeight = Workspace.FallenPartsDestroyHeight
			Connections.AntiVoid = RunService.Stepped:Connect(function()
				local root = getRoot(LocalPlayer.Character)
				if root and root.Position.Y <= (Values.OrgDestroyHeight or -500) + 25 then
					root.Velocity = root.Velocity + Vector3.new(0, 250, 0)
				end
			end)
		else
			if Connections.AntiVoid then Connections.AntiVoid:Disconnect() Connections.AntiVoid = nil end
		end
	end
})

Tabs.Utilities:Button({
	Title = "Fake Out",
	Callback = function()
		local root = getRoot(LocalPlayer.Character)
		if not root then return end
		local old = root.CFrame
		if Connections.AntiVoid then Connections.AntiVoid:Disconnect() Connections.AntiVoid = nil end
		Workspace.FallenPartsDestroyHeight = 0
		root.CFrame = CFrame.new(Vector3.new(0, Workspace.FallenPartsDestroyHeight - 25, 0))
		task.wait(1)
		root.CFrame = old
		Workspace.FallenPartsDestroyHeight = -500
	end
})

Tabs.Utilities:Toggle({
	Title = "Loop Fullbright",
	Desc = "Persistent fullbright",
	Value = false,
	Callback = function(state)
		if state then
			Connections.LoopFullbright2 = RunService.RenderStepped:Connect(function()
				Lighting.Brightness = 2
				Lighting.ClockTime = 14
				Lighting.FogEnd = 100000
				Lighting.GlobalShadows = false
				Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
			end)
		else
			if Connections.LoopFullbright2 then Connections.LoopFullbright2:Disconnect() Connections.LoopFullbright2 = nil end
		end
	end
})

Tabs.Utilities:Toggle({
	Title = "Global Shadows",
	Desc = "Toggle shadows",
	Value = true,
	Callback = function(state)
		Lighting.GlobalShadows = state
	end
})

Tabs.Utilities:Colorpicker({
	Title = "Ambient Color",
	Desc = "Set ambient",
	Default = Lighting.Ambient,
	Callback = function(color)
		Lighting.Ambient = color
		Lighting.OutdoorAmbient = color
	end
})

Tabs.Utilities:Button({
	Title = "Notify Ping",
	Callback = function()
		notify("Ping", math.round(LocalPlayer:GetNetworkPing() * 1000) .. "ms")
	end
})

Tabs.Fun:Section({ Title = "Trolling", Opened = true })

Tabs.Fun:Button({
	Title = "Scare Selected Player",
	Callback = function()
		if selectedTpPlayer == "" then notify("Fun", "No player selected") return end
		local targets = getPlayer(selectedTpPlayer)
		for _, p in ipairs(targets) do
			local troot = p.Character and getRoot(p.Character)
			local myRoot = getRoot(LocalPlayer.Character)
			if troot and myRoot and p ~= LocalPlayer then
				local old = myRoot.CFrame
				myRoot.CFrame = troot.CFrame + troot.CFrame.LookVector * 2
				myRoot.CFrame = CFrame.new(myRoot.Position, troot.Position)
				task.wait(0.5)
				myRoot.CFrame = old
			end
			break
		end
	end
})

Tabs.Fun:Button({
	Title = "Trip",
	Callback = function()
		local hum = getHum(LocalPlayer.Character)
		local root = getRoot(LocalPlayer.Character)
		if hum and root then
			hum:ChangeState(Enum.HumanoidStateType.FallingDown)
			root.Velocity = root.CFrame.LookVector * 30
		end
	end
})

Tabs.Fun:Button({
	Title = "All Emotes Player",
	Callback = function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/SuperHackerYT/Main/refs/heads/main/EmotePlayer.lua"))()
	end
})

Tabs.Fun:Toggle({
	Title = "Carpet Selected Player",
	Desc = "Be Someone's Carpet (R6)",
	Value = false,
	Callback = function(state)
		if state then
			if isR15(LocalPlayer.Character) then
				notify("Fun", "Carpet requires R6")
				return
			end
			if selectedTpPlayer == "" then notify("Fun", "No player selected") return end
			local targets = getPlayer(selectedTpPlayer)
			local target = targets[1]
			if not target or not target.Character then return end
			local hum = getHum(LocalPlayer.Character)
			if not hum then return end
			local anim = Instance.new("Animation")
			anim.AnimationId = "rbxassetid://282574440"
			local track = hum:LoadAnimation(anim)
			track:Play(0.1, 1, 1)
			local died = hum.Died:Connect(function()
				track:Stop()
				if Connections.Carpet then Connections.Carpet:Disconnect() Connections.Carpet = nil end
			end)
			Connections.Carpet = RunService.Heartbeat:Connect(function()
				local troot = getRoot(target.Character)
				local myRoot = getRoot(LocalPlayer.Character)
				if troot and myRoot then
					myRoot.CFrame = troot.CFrame
				end
			end)
			Connections.CarpetDied = died
		else
			if Connections.Carpet then Connections.Carpet:Disconnect() Connections.Carpet = nil end
			if Connections.CarpetDied then Connections.CarpetDied:Disconnect() Connections.CarpetDied = nil end
		end
	end
})

Tabs.Fun:Toggle({
	Title = "Hat Spin",
	Desc = "Spin your hats",
	Value = false,
	Callback = function(state)
		if state then
			local hum = getHum(LocalPlayer.Character)
			if not hum then return end
			for _, acc in ipairs(hum:GetAccessories()) do
				local handle = acc:FindFirstChild("Handle")
				if handle then
					local bp = Instance.new("BodyPosition")
					bp.Name = randomString()
					bp.Parent = handle
					bp.P = 30000
					bp.D = 50
					local ba = Instance.new("BodyAngularVelocity")
					ba.Name = randomString()
					ba.Parent = handle
					ba.AngularVelocity = Vector3.new(0, 100, 0)
					ba.MaxTorque = Vector3.new(0, 200, 0)
					local weld = handle:FindFirstChildOfClass("Weld")
					if weld then weld:Destroy() end
				end
			end
			Connections.HatSpin = RunService.Stepped:Connect(function()
				local head = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Head")
				if head then
					for _, acc in ipairs(hum:GetAccessories()) do
						local handle = acc:FindFirstChild("Handle")
						if handle then
							local bp = handle:FindFirstChildOfClass("BodyPosition")
							if bp then bp.Position = head.Position end
						end
					end
				end
			end)
		else
			if Connections.HatSpin then Connections.HatSpin:Disconnect() Connections.HatSpin = nil end
			local hum = getHum(LocalPlayer.Character)
			if hum then
				for _, acc in ipairs(hum:GetAccessories()) do
					local handle = acc:FindFirstChild("Handle")
					if handle then
						for _, c in ipairs(handle:GetChildren()) do
							if c:IsA("BodyPosition") or c:IsA("BodyAngularVelocity") then
								c:Destroy()
							end
						end
						acc.Parent = Workspace
						task.wait()
						acc.Parent = LocalPlayer.Character
					end
				end
			end
		end
	end
})

Tabs.Fun:Button({
	Title = "Clear Hats",
	Callback = function()
		if not firetouchinterest then
			notify("Fun", "Missing firetouchinterest")
			return
		end
		local char = LocalPlayer.Character
		if not char then return end
		local old = getRoot(char).CFrame
		local hats = {}
		for _, child in ipairs(Workspace:GetChildren()) do
			if child:IsA("Accessory") then
				table.insert(hats, child)
			end
		end
		local hum = getHum(char)
		if hum then
			for _, acc in ipairs(hum:GetAccessories()) do
				acc:Destroy()
			end
		end
		for _, hat in ipairs(hats) do
			if hat and hat:FindFirstChild("Handle") then
				firetouchinterest(hat.Handle, getRoot(char), 0)
				firetouchinterest(hat.Handle, getRoot(char), 1)
				task.wait()
				local newAcc = char:FindFirstChildOfClass("Accessory")
				if newAcc then newAcc:Destroy() end
			end
		end
		local hum2 = getHum(char)
		if hum2 then hum2.Health = 0 end
		LocalPlayer.CharacterAdded:Wait()
		task.wait(0.5)
		local newRoot = getRoot(LocalPlayer.Character)
		if newRoot then newRoot.CFrame = old end
	end
})

Tabs.Fun:Button({
	Title = "Jerk (If you die, it's been patched)",
	Callback = function()
loadstring(game:HttpGet("https://pastefy.app/wa3v2Vgm/raw"))("Spider Script")
loadstring(game:HttpGet("https://pastefy.app/YZoglOyJ/raw"))()
	end
})

Tabs.Fun:Section({ Title = "Loops", Opened = true })

Tabs.Fun:Toggle({
	Title = "Loop Oof",
	Desc = "Play death sounds",
	Value = false,
	Callback = function(state)
		if state then
			Toggles.LoopOof = true
			Connections.LoopOof = task.spawn(function()
				while Toggles.LoopOof do
					for _, plr in ipairs(Players:GetPlayers()) do
						if plr.Character and plr.Character:FindFirstChild("Head") then
							for _, s in ipairs(plr.Character.Head:GetChildren()) do
								if s:IsA("Sound") then
									s.Playing = true
								end
							end
						end
					end
					task.wait(0.1)
				end
			end)
		else
			Toggles.LoopOof = false
		end
	end
})

Tabs.Fun:Toggle({
	Title = "Mute Boomboxes",
	Desc = "Silence boomboxes",
	Value = false,
	Callback = function(state)
		for _, plr in ipairs(Players:GetPlayers()) do
			if plr.Character then
				for _, v in ipairs(plr.Character:GetDescendants()) do
					if v:IsA("Sound") then
						v.Playing = not state
					end
				end
			end
		end
	end
})

Tabs.Fun:Button({
	Title = "Mute Selected Player Boombox",
	Callback = function()
		if selectedTpPlayer == "" then return end
		local targets = getPlayer(selectedTpPlayer)
		for _, plr in ipairs(targets) do
			if plr.Character then
				for _, v in ipairs(plr.Character:GetDescendants()) do
					if v:IsA("Sound") then
						v.Playing = false
					end
				end
			end
		end
	end
})

Tabs.Fun:Button({
	Title = "Unmute Selected Player Boombox",
	Callback = function()
		if selectedTpPlayer == "" then return end
		local targets = getPlayer(selectedTpPlayer)
		for _, plr in ipairs(targets) do
			if plr.Character then
				for _, v in ipairs(plr.Character:GetDescendants()) do
					if v:IsA("Sound") then
						v.Playing = true
					end
				end
			end
		end
	end
})

Tabs.Misc:Section({ Title = "Waypoints", Opened = true })

local waypoints = {}
local wpNameInput = ""
Tabs.Misc:Input({
	Title = "Waypoint Name",
	Value = "",
	Placeholder = "Name...",
	Callback = function(v)
		wpNameInput = v
	end
})

Tabs.Misc:Button({
	Title = "Save Waypoint",
	Callback = function()
		if wpNameInput == "" then notify("Misc", "Enter a name") return end
		local root = getRoot(LocalPlayer.Character)
		if root then
			waypoints[wpNameInput] = root.CFrame
			notify("Misc", "Saved waypoint: " .. wpNameInput)
		end
	end
})

Tabs.Misc:Button({
	Title = "Load Waypoint",
	Callback = function()
		if wpNameInput == "" then notify("Misc", "Enter a name") return end
		if waypoints[wpNameInput] then
			local root = getRoot(LocalPlayer.Character)
			if root then root.CFrame = waypoints[wpNameInput] end
		else
			notify("Misc", "Waypoint not found")
		end
	end
})

Tabs.Misc:Button({
	Title = "Delete Waypoint",
	Callback = function()
		if waypoints[wpNameInput] then
			waypoints[wpNameInput] = nil
			notify("Misc", "Deleted waypoint")
		end
	end
})

Tabs.Misc:Section({ Title = "Environment", Opened = true })

Tabs.Misc:Button({
	Title = "No Gameplay Paused",
	Callback = function()
		game:GetService("CoreGui").RobloxGui["CoreScripts/NetworkPause"]:Destroy()
	end
})

Tabs.Misc:Toggle({
	Title = "Wall TP",
	Desc = "TP through walls on touch",
	Value = false,
	Callback = function(state)
		if state then
			local torso = LocalPlayer.Character and (LocalPlayer.Character:FindFirstChild("Torso") or LocalPlayer.Character:FindFirstChild("UpperTorso"))
			if not torso then return end
			Connections.WallTP = torso.Touched:Connect(function(hit)
				local root = getRoot(LocalPlayer.Character)
				if not root then return end
				if hit:IsA("BasePart") and hit.Position.Y > root.Position.Y - (getHum(LocalPlayer.Character) and getHum(LocalPlayer.Character).HipHeight or 0) then
					local hitP = getRoot(hit.Parent)
					if hitP then
						root.CFrame = hit.CFrame * CFrame.new(root.CFrame.LookVector.X, hitP.Size.Z / 2 + (getHum(LocalPlayer.Character) and getHum(LocalPlayer.Character).HipHeight or 0), root.CFrame.LookVector.Z)
					else
						root.CFrame = hit.CFrame * CFrame.new(root.CFrame.LookVector.X, hit.Size.Y / 2 + (getHum(LocalPlayer.Character) and getHum(LocalPlayer.Character).HipHeight or 0), root.CFrame.LookVector.Z)
					end
				end
			end)
		else
			if Connections.WallTP then Connections.WallTP:Disconnect() Connections.WallTP = nil end
		end
	end
})

Tabs.Misc:Toggle({
	Title = "Hover Name",
	Desc = "Show hovered player name",
	Value = false,
	Callback = function(state)
		if state then
			local gui = Instance.new("TextLabel")
			gui.Name = randomString()
			gui.Parent = LocalPlayer:WaitForChild("PlayerGui")
			gui.BackgroundTransparency = 1
			gui.Size = UDim2.new(0, 200, 0, 30)
			gui.Font = Enum.Font.Code
			gui.TextSize = 16
			gui.Text = ""
			gui.TextColor3 = Color3.new(1, 1, 1)
			gui.TextStrokeTransparency = 0
			gui.TextXAlignment = Enum.TextXAlignment.Left
			gui.ZIndex = 10
			local sel = Instance.new("SelectionBox")
			sel.Name = randomString()
			sel.LineThickness = 0.03
			sel.Color3 = Color3.new(1, 1, 1)
			Connections.HoverName = LocalPlayer:GetMouse().Move:Connect(function()
				local mouse = LocalPlayer:GetMouse()
				local target = mouse.Target
				if target then
					local hum = target.Parent:FindFirstChildOfClass("Humanoid") or target.Parent.Parent:FindFirstChildOfClass("Humanoid")
					if hum then
						gui.Text = hum.Parent.Name
						gui.Position = UDim2.new(0, mouse.X + 25, 0, mouse.Y)
						gui.Visible = true
						sel.Parent = hum.Parent
						sel.Adornee = hum.Parent
					else
						gui.Visible = false
						sel.Parent = nil
						sel.Adornee = nil
					end
				else
					gui.Visible = false
					sel.Parent = nil
					sel.Adornee = nil
				end
			end)
		else
			if Connections.HoverName then Connections.HoverName:Disconnect() Connections.HoverName = nil end
			local pg = LocalPlayer:WaitForChild("PlayerGui")
			for _, v in ipairs(pg:GetChildren()) do
				if v:IsA("TextLabel") then
					v:Destroy()
				end
			end
		end
	end
})

Tabs.Misc:Slider({
	Title = "Mouse Sensitivity",
	Desc = "Camera sensitivity",
	Step = 0.1,
	Value = { Min = 0.1, Max = 10, Default = 1 },
	Callback = function(v)
		UserInputService.MouseDeltaSensitivity = v
	end
})

Tabs.Misc:Toggle({
	Title = "Alignment Keys",
	Desc = "Comma/Period to rotate cam",
	Value = false,
	Callback = function(state)
		if state then
			Connections.AlignKeys = UserInputService.InputBegan:Connect(function(input, gpe)
				if gpe then return end
				if input.KeyCode == Enum.KeyCode.Comma then
					Workspace.CurrentCamera:PanUnits(-1)
				elseif input.KeyCode == Enum.KeyCode.Period then
					Workspace.CurrentCamera:PanUnits(1)
				end
			end)
			StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.EmotesMenu, false)
		else
			if Connections.AlignKeys then Connections.AlignKeys:Disconnect() Connections.AlignKeys = nil end
			StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.EmotesMenu, true)
		end
	end
})

Tabs.Misc:Toggle({
	Title = "Ctrl Lock",
	Desc = "Use Ctrl for shift lock",
	Value = false,
	Callback = function(state)
		local module = LocalPlayer:WaitForChild("PlayerScripts", 5)
		if not module then return end
		local camModule = module:WaitForChild("PlayerModule", 5)
		if not camModule then return end
		local cam = camModule:WaitForChild("CameraModule", 5)
		if not cam then return end
		local mlc = cam:WaitForChild("MouseLockController", 5)
		if not mlc then return end
		local bound = mlc:FindFirstChild("BoundKeys")
		if not bound then
			bound = Instance.new("StringValue")
			bound.Name = "BoundKeys"
			bound.Parent = mlc
		end
		bound.Value = state and "LeftControl" or "LeftShift"
	end
})

Tabs.Misc:Toggle({
	Title = "Listen To Selected",
	Desc = "Hear from target's position",
	Value = false,
	Callback = function(state)
		if state then
			if selectedTpPlayer == "" then notify("Misc", "No player selected") return end
			local targets = getPlayer(selectedTpPlayer)
			local target = targets[1]
			if not target then return end
			local function setListener(char)
				local root = getRoot(char)
				if root then
					SoundService:SetListener(Enum.ListenerType.ObjectPosition, root)
				end
			end
			if target.Character then
				setListener(target.Character)
			end
			Connections.ListenTo = target.CharacterAdded:Connect(setListener)
		else
			SoundService:SetListener(Enum.ListenerType.Camera)
			if Connections.ListenTo then Connections.ListenTo:Disconnect() Connections.ListenTo = nil end
		end
	end
})

Tabs.Misc:Section({ Title = "Voice Chat", Opened = true })

Tabs.Misc:Button({
	Title = "Mute All VC",
	Callback = function()
		pcall(function() VoiceChatService:SubscribePauseAll(true) end)
	end
})

Tabs.Misc:Button({
	Title = "Unmute All VC",
	Callback = function()
		pcall(function() VoiceChatService:SubscribePauseAll(false) end)
	end
})

Tabs.Misc:Button({
	Title = "Mute Selected VC",
	Callback = function()
		if selectedTpPlayer == "" then return end
		local targets = getPlayer(selectedTpPlayer)
		for _, p in ipairs(targets) do
			if p ~= LocalPlayer then
				pcall(function() VoiceChatService:SubscribePause(p.UserId, true) end)
			end
		end
	end
})

Tabs.Misc:Button({
	Title = "Unmute Selected VC",
	Callback = function()
		if selectedTpPlayer == "" then return end
		local targets = getPlayer(selectedTpPlayer)
		for _, p in ipairs(targets) do
			if p ~= LocalPlayer then
				pcall(function() VoiceChatService:SubscribePause(p.UserId, false) end)
			end
		end
	end
})

Tabs.Misc:Section({ Title = "Physics", Opened = true })

Tabs.Misc:Toggle({
	Title = "Freeze Unanchored",
	Desc = "Freeze all unanchored parts",
	Value = false,
	Callback = function(state)
		if state then
			local badNames = {
				"Head","UpperTorso","LowerTorso","RightUpperArm","LeftUpperArm",
				"RightLowerArm","LeftLowerArm","RightHand","LeftHand",
				"RightUpperLeg","LeftUpperLeg","RightLowerLeg","LeftLowerLeg",
				"RightFoot","LeftFoot","Torso","Right Arm","Left Arm",
				"Right Leg","Left Leg","HumanoidRootPart"
			}
			local function freeze(v)
				if (v:IsA("BasePart") or v:IsA("UnionOperation")) and not v.Anchored then
					local bad = false
					for _, n in ipairs(badNames) do
						if v.Name == n then bad = true break end
					end
					if not bad and LocalPlayer.Character and not v:IsDescendantOf(LocalPlayer.Character) then
						local bp = Instance.new("BodyPosition")
						bp.Parent = v
						bp.Position = v.Position
						bp.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
						local bg = Instance.new("BodyGyro")
						bg.Parent = v
						bg.CFrame = v.CFrame
						bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
					end
				end
			end
			for _, v in ipairs(Workspace:GetDescendants()) do
				freeze(v)
			end
			Connections.FreezeUA = Workspace.DescendantAdded:Connect(freeze)
		else
			if Connections.FreezeUA then Connections.FreezeUA:Disconnect() Connections.FreezeUA = nil end
			for _, v in ipairs(Workspace:GetDescendants()) do
				if v:IsA("BodyPosition") or v:IsA("BodyGyro") then
					v:Destroy()
				end
			end
		end
	end
})

Tabs.Misc:Button({
	Title = "TP Unanchored to Selected",
	Callback = function()
		if selectedTpPlayer == "" then notify("Misc", "No player selected") return end
		local targets = getPlayer(selectedTpPlayer)
		local target = targets[1]
		if not target or not target.Character or not target.Character:FindFirstChild("Head") then return end
		local forces = {}
		for _, part in ipairs(Workspace:GetDescendants()) do
			if part:IsA("BasePart") and not part.Anchored and not part:IsDescendantOf(LocalPlayer.Character) then
				local bp = Instance.new("BodyPosition")
				bp.Parent = part
				bp.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
				table.insert(forces, bp)
			end
		end
		for _, f in ipairs(forces) do
			f.Position = target.Character.Head.Position
		end
	end
})

Tabs.Misc:Section({ Title = "Social", Opened = true })

Tabs.Misc:Button({
	Title = "Friend Selected",
	Callback = function()
		if selectedTpPlayer == "" then return end
		local targets = getPlayer(selectedTpPlayer)
		for _, p in ipairs(targets) do
			LocalPlayer:RequestFriendship(p)
		end
	end
})

Tabs.Misc:Button({
	Title = "Unfriend Selected",
	Callback = function()
		if selectedTpPlayer == "" then return end
		local targets = getPlayer(selectedTpPlayer)
		for _, p in ipairs(targets) do
			LocalPlayer:RevokeFriendship(p)
		end
	end
})

Tabs.Misc:Button({
	Title = "Phonebook",
	Callback = function()
		local ok, can = pcall(function() return SocialService:CanSendCallInviteAsync(LocalPlayer) end)
		if ok and can then
			SocialService:PromptPhoneBook(LocalPlayer, "")
		else
			notify("Misc", "Unable to open phonebook")
		end
	end
})

Tabs.Misc:Section({ Title = "Chat", Opened = true })

local spamText = ""
local spamSpeed = 1
Tabs.Misc:Input({
	Title = "Spam Text",
	Value = "",
	Placeholder = "Text to spam...",
	Callback = function(v)
		spamText = v
	end
})

Tabs.Misc:Slider({
	Title = "Spam Speed",
	Desc = "Seconds between messages",
	Step = 0.1,
	Value = { Min = 0.1, Max = 5, Default = 1 },
	Callback = function(v)
		spamSpeed = v
	end
})

Tabs.Misc:Toggle({
	Title = "Spam",
	Desc = "Spam chat messages",
	Value = false,
	Callback = function(state)
		if state then
			Toggles.Spam = true
			Connections.Spam = task.spawn(function()
				while Toggles.Spam do
					if spamText ~= "" then
						chatMessage(spamText)
					end
					task.wait(spamSpeed)
				end
			end)
		else
			Toggles.Spam = false
		end
	end
})

Tabs.Misc:Input({
	Title = "Say Message",
	Value = "",
	Placeholder = "Message...",
	Callback = function(v)
		if v ~= "" then chatMessage(v) end
	end
})

Tabs.Misc:Input({
	Title = "Whisper (format: /w name msg)",
	Value = "",
	Placeholder = "/w player message...",
	Callback = function(v)
		if v ~= "" then chatMessage(v) end
	end
})

Tabs.Misc:Toggle({
	Title = "Bubble Chat",
	Desc = "Toggle bubble chat",
	Value = true,
	Callback = function(state)
		if TextChatService.BubbleChatConfiguration then
			TextChatService.BubbleChatConfiguration.Enabled = state
		elseif ChatService.BubbleChatEnabled ~= nil then
			ChatService.BubbleChatEnabled = state
		end
	end
})

Tabs.Misc:Toggle({
	Title = "Chat Window",
	Desc = "Toggle chat window",
	Value = true,
	Callback = function(state)
		if TextChatService.ChatWindowConfiguration then
			TextChatService.ChatWindowConfiguration.Enabled = state
		end
	end
})

Tabs.Misc:Button({
	Title = "Dark Chat",
	Callback = function()
		local bcc = TextChatService:FindFirstChildOfClass("BubbleChatConfiguration")
		local cwc = TextChatService:FindFirstChildOfClass("ChatWindowConfiguration")
		local cibc = TextChatService:FindFirstChildOfClass("ChatInputBarConfiguration")
		if bcc then
			bcc.Enabled = true
			bcc.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
			bcc.BackgroundTransparency = 0.3
			bcc.TailVisible = true
			bcc.TextColor3 = Color3.fromRGB(255, 255, 255)
		end
		if cwc then
			cwc.Enabled = true
			cwc.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
			cwc.BackgroundTransparency = 0.3
			cwc.TextColor3 = Color3.fromRGB(255, 255, 255)
			cwc.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
			cwc.TextStrokeTransparency = 0.5
		end
		if cibc then
			cibc.Enabled = true
			cibc.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
			cibc.BackgroundTransparency = 0.5
			cibc.PlaceholderColor3 = Color3.fromRGB(255, 255, 255)
			cibc.TextColor3 = Color3.fromRGB(255, 255, 255)
			cibc.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
			cibc.TextStrokeTransparency = 0.5
		end
	end
})

Tabs.Misc:Section({ Title = "Key & Automation", Opened = true })

local autoKey = ""
local autoKeyDelay = 0.1
local autoKeyRelease = 0.1
Tabs.Misc:Input({
	Title = "Auto Key",
	Value = "",
	Placeholder = "Key to press...",
	Callback = function(v)
		autoKey = v:lower()
	end
})

Tabs.Misc:Slider({
	Title = "Auto Key Delay",
	Desc = "Press delay",
	Step = 0.05,
	Value = { Min = 0.05, Max = 2, Default = 0.1 },
	Callback = function(v)
		autoKeyDelay = v
	end
})

Tabs.Misc:Toggle({
	Title = "Auto Key Press",
	Desc = "Repeatedly press key",
	Value = false,
	Callback = function(state)
		if state then
			if not keypress then
				notify("Misc", "Missing keypress")
				return
			end
			local map = {
				["0"] = 0x30, ["1"] = 0x31, ["2"] = 0x32, ["3"] = 0x33, ["4"] = 0x34,
				["5"] = 0x35, ["6"] = 0x36, ["7"] = 0x37, ["8"] = 0x38, ["9"] = 0x39,
				["a"] = 0x41, ["b"] = 0x42, ["c"] = 0x43, ["d"] = 0x44, ["e"] = 0x45,
				["f"] = 0x46, ["g"] = 0x47, ["h"] = 0x48, ["i"] = 0x49, ["j"] = 0x4A,
				["k"] = 0x4B, ["l"] = 0x4C, ["m"] = 0x4D, ["n"] = 0x4E, ["o"] = 0x4F,
				["p"] = 0x50, ["q"] = 0x51, ["r"] = 0x52, ["s"] = 0x53, ["t"] = 0x54,
				["u"] = 0x55, ["v"] = 0x56, ["w"] = 0x57, ["x"] = 0x58, ["y"] = 0x59,
				["z"] = 0x5A,
				["enter"] = 0x0D, ["shift"] = 0x10, ["ctrl"] = 0x11, ["alt"] = 0x12,
				["space"] = 0x20, ["left"] = 0x25, ["up"] = 0x26, ["right"] = 0x27, ["down"] = 0x28
			}
			local code = map[autoKey]
			if not code then notify("Misc", "Invalid key") return end
			Toggles.AutoKey = true
			Connections.AutoKey = task.spawn(function()
				while Toggles.AutoKey do
					keypress(code)
					task.wait(autoKeyRelease)
					keyrelease(code)
					task.wait(autoKeyDelay)
				end
			end)
		else
			Toggles.AutoKey = false
		end
	end
})

notify("Universal Script", "Loaded successfully by Elvis Fofo")
