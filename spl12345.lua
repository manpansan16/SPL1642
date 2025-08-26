-- Wait for game and essentials
if not game:IsLoaded() then game.Loaded:Wait() end
local Players = game:GetService('Players')
while not Players.LocalPlayer or not workspace.CurrentCamera do task.wait() end

-- Services
local UIS = game:GetService('UserInputService')
local RS = game:GetService('RunService')
local HttpService = game:GetService('HttpService')
local Lighting = game:GetService('Lighting')
local Players = game:GetService('Players')
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Webhook (top)
local WEBHOOK_URL = 'https://discord.com/api/webhooks/1408101949613539429/-7NyMTr4xxMy_DLpH9uQBWyh52P6g5voZd_IZlpBpDxLgukH49QxUWYYd9v5vDTVbG7v'
local WEBHOOK_PING_ID = '' -- set your Discord user ID here to ping

local function getRequestFunc()
	return (syn and syn.request)
		or (http and http.request)
		or (getgenv and getgenv().request)
		or http_request
		or (fluxus and fluxus.request)
end

local function postWebhook(usernameLabel, titleText, descText, mentionUserId)
	if not WEBHOOK_URL or WEBHOOK_URL == '' then return end
	local request = getRequestFunc()
	if not request then return end
	local contentText, allowedUsers
	if mentionUserId and tostring(mentionUserId) ~= '' then
		contentText = '<@' .. tostring(mentionUserId) .. '>'
		allowedUsers = { tostring(mentionUserId) }
	end
	local payload = {
		username = usernameLabel,
		content = contentText,
		embeds = {{
			title = titleText,
			description = descText,
			color = 16711680,
			footer = { text = 'Roblox • ' .. os.date('%H:%M') },
		}},
		allowed_mentions = { parse = {}, users = allowedUsers or {} },
	}
	pcall(function()
		request({
			Url = WEBHOOK_URL,
			Method = 'POST',
			Headers = { ['Content-Type'] = 'application/json' },
			Body = HttpService:JSONEncode(payload),
		})
	end)
end

local function sendDeathWebhook(playerName, killerName)
	postWebhook('Death Bot', '⚠️ Player Killed!', playerName .. ' was killed.', WEBHOOK_PING_ID)
end

local function sendPanicWebhook(playerName)
	postWebhook('Panic Bot', 'Panic Activated', playerName .. ' Triggered Panic', WEBHOOK_PING_ID)
end

-- Config
local config = {
	FireBallAimbot = false,
	FireBallAimbotCity = false,
	UniversalFireBallAimbot = false,
	SmartPanic = false,
	DeathWebhook = true,
	PanicWebhook = false,
	GraphicsOptimization = false,
	GraphicsOptimizationAdvanced = false,
	UltimateAFKOptimization = false,
	NoClip = false,
	PlayerESP = false,
	MobESP = false,
	AutoWashDishes = false,
	AutoNinjaSideTask = false,
	AutoAnimatronicsSideTask = false,
	AutoMutantsSideTask = false,
	DualExoticShop = false,
	VendingPotionAutoBuy = false,
	RemoveMapClutter = false,
	StatWebhook15m = false,
	KillAura = false,
	StatGui = false,
	AutoInvisible = false,
	AutoResize = false,
	AutoFly = false,
	fireballCooldown = 0.1,
	cityFireballCooldown = 0.5,
	universalFireballInterval = 1.0,
	HideGUIKey = 'RightControl',
}

local function saveConfig()
	pcall(function()
		writefile('SuperPowerLeague_Config.json', HttpService:JSONEncode(config))
	end)
end
local function loadConfig()
	local ok = pcall(function()
		if isfile('SuperPowerLeague_Config.json') then
			local loaded = HttpService:JSONDecode(readfile('SuperPowerLeague_Config.json'))
			for k,v in pairs(loaded) do config[k] = v end
		end
	end)
	return ok
end
loadConfig()

local function getCharHumanoid()
	local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
	return char, char:FindFirstChildOfClass('Humanoid'), char:FindFirstChild('HumanoidRootPart')
end
local function getEvent(...)
	local node = ReplicatedStorage
	for _,name in ipairs({...}) do node = node:WaitForChild(name, 9e9) end
	return node
end

-- Disable all aimbots helper
local function disableAllAimbots()
	if getgenv().UniversalFireBallAimbot or getgenv().FireBallAimbot or getgenv().FireBallAimbotCity then
		getgenv().UniversalFireBallAimbot = false
		getgenv().FireBallAimbot = false
		getgenv().FireBallAimbotCity = false
		config.UniversalFireBallAimbot = false
		config.FireBallAimbot = false
		config.FireBallAimbotCity = false
		saveConfig()
	end
end

-- Death + Panic watcher
local lastPanicSentAt, PANIC_THRESHOLD, PANIC_COOLDOWN, REARM_AT_PERCENT = 0, 0.95, 3, 0.95
local function initializeDeathAndPanicWatchers()
	local function hookCharacter(char)
		local hum = char:WaitForChild('Humanoid', 10); if not hum then return end
		local lastDamager, deathSent, panicArmed = nil, false, true
		hum.Died:Connect(function()
			if config.DeathWebhook and not deathSent then
				deathSent = true
				disableAllAimbots()
				sendDeathWebhook(LocalPlayer.Name, (lastDamager and lastDamager.Name) or 'Unknown')
			else
				disableAllAimbots()
			end
			panicArmed = true
		end)
		hum.HealthChanged:Connect(function(hp)
			local max = hum.MaxHealth
			if not max or max <= 0 then return end
			local ratio, now = hp / max, os.clock()
			if ratio <= PANIC_THRESHOLD and panicArmed then
				panicArmed = false
				disableAllAimbots()
				if config.PanicWebhook and (now - lastPanicSentAt) >= PANIC_COOLDOWN then
					lastPanicSentAt = now
					sendPanicWebhook(LocalPlayer.Name)
				end
			elseif ratio >= REARM_AT_PERCENT then
				panicArmed = true
			end
		end)
		task.defer(function()
			for _, part in ipairs(workspace:GetDescendants()) do
				if part:IsA('BasePart') then
					part.Touched:Connect(function(hit)
						local p = Players:GetPlayerFromCharacter(hit.Parent)
						if p then lastDamager = p.Character end
					end)
				end
			end
		end)
	end
	if LocalPlayer.Character then hookCharacter(LocalPlayer.Character) end
	LocalPlayer.CharacterAdded:Connect(hookCharacter)
end
initializeDeathAndPanicWatchers()

-- Smart Panic
getgenv().SmartPanic = config.SmartPanic and true or false
local TARGET_PLACE_ID = 79106917651793
local function findDescendantByName(root, name) for _, d in ipairs(root:GetDescendants()) do if d.Name == name then return d end end end
local function fallbackCFrame()
	for _, d in ipairs(workspace:GetDescendants()) do if d:IsA('SpawnLocation') then return d.CFrame end end
	local _,_,hrp = getCharHumanoid(); return hrp and (hrp.CFrame + Vector3.new(0,35,0)) or nil
end
local function getPanicCFrame()
	if game.PlaceId == TARGET_PLACE_ID then
		local lobby = workspace:FindFirstChild('Lobby'); local extras = lobby and lobby:FindFirstChild('Extras'); local pvpsign = extras and extras:FindFirstChild('PvPSign') or findDescendantByName(workspace,'PvPSign')
		if pvpsign then return pvpsign:IsA('Model') and pvpsign:GetPivot() or pvpsign.CFrame end
	else
		local ts8 = workspace:FindFirstChild('TopStat8'); local design = ts8 and ts8:FindFirstChild('Design')
		if design then local node = design:GetChildren()[30]; if node then return node:IsA('Model') and node:GetPivot() or (node.CFrame or nil) end end
	end
	return fallbackCFrame()
end
task.spawn(function()
	local lastTp, armed = 0, true
	while true do
		if getgenv().SmartPanic then
			local _, hum = getCharHumanoid()
			if hum then
				local max = (hum.MaxHealth and hum.MaxHealth > 0) and hum.MaxHealth or 100
				local now = os.clock()
				if armed and hum.Health > 0 and hum.Health <= (0.90 * max) and (now - lastTp) >= 1.5 then
					local cf = getPanicCFrame(); if cf and LocalPlayer.Character then pcall(function() LocalPlayer.Character:PivotTo(cf) end) end
					lastTp = now; armed = false
				elseif not armed and hum.Health >= (REARM_AT_PERCENT * max) then
					armed = true
				end
			end
		end
		task.wait(0.1)
	end
end)

-- UI: Build
local ScreenGui = Instance.new('ScreenGui')
ScreenGui.Name = 'SuperPowerLeagueGUI'
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
ScreenGui.IgnoreGuiInset = true
ScreenGui.ResetOnSpawn = false
ScreenGui.Enabled = true
local function safeParent(gui)
	local parent = (gethui and gethui()) or game:FindFirstChildOfClass('CoreGui') or Players.LocalPlayer:WaitForChild('PlayerGui')
	if syn and syn.protect_gui and parent == game:GetService('CoreGui') then pcall(syn.protect_gui, gui) end
	gui.Parent = parent
end
safeParent(ScreenGui)

local function make(uiclass, props, parent) local i=Instance.new(uiclass); for k,v in pairs(props or {}) do i[k]=v end; if parent then i.Parent=parent end; return i end

local Backdrop = make('Frame',{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1},ScreenGui)
local Shadow = make('ImageLabel',{
	Size=UDim2.new(0,860,0,560),Position=UDim2.new(0.5,-430,0.5,-280),
	BackgroundTransparency=1,Image='rbxassetid://5107167611',ImageColor3=Color3.fromRGB(0,0,0),ImageTransparency=0.25,ScaleType=Enum.ScaleType.Slice,SliceCenter=Rect.new(10,10,118,118)
},Backdrop)

local MainFrame = make('Frame',{Name='MainFrame',Size=UDim2.new(0,840,0,540),Position=UDim2.new(0.5,-420,0.5,-270),BackgroundColor3=Color3.fromRGB(22,22,28),BorderSizePixel=0},Backdrop)
make('UICorner',{CornerRadius=UDim.new(0,14)},MainFrame)

local TitleBar = make('Frame',{Name='TitleBar',Size=UDim2.new(1,0,0,48),BackgroundColor3=Color3.fromRGB(28,28,36),BorderSizePixel=0},MainFrame)
make('UICorner',{CornerRadius=UDim.new(0,14)},TitleBar)
make('UIGradient',{Color=ColorSequence.new{
	ColorSequenceKeypoint.new(0, Color3.fromRGB(40,40,54)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(28,28,36))
}},TitleBar)

local Title = make('TextLabel',{
	Name='Title',Size=UDim2.new(1,-100,1,0),Position=UDim2.new(0,20,0,0),BackgroundTransparency=1,
	Text='Nedu Carti Hub',TextColor3=Color3.fromRGB(235,235,245),TextScaled=true,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Left
},TitleBar)

local AccentBar = make('Frame',{Size=UDim2.new(1,0,0,2),Position=UDim2.new(0,0,1,-2),BackgroundColor3=Color3.fromRGB(0,170,255),BorderSizePixel=0},TitleBar)

local CloseButton = make('ImageButton',{
	Name='Close',Size=UDim2.new(0,28,0,28),Position=UDim2.new(1,-38,0,10),BackgroundTransparency=1,Image='rbxassetid://7072719338',ImageColor3=Color3.fromRGB(255,85,85)
},TitleBar)
CloseButton.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

local TabContainer = make('Frame',{Name='TabContainer',Size=UDim2.new(0,180,1,-58),Position=UDim2.new(0,12,0,54),BackgroundColor3=Color3.fromRGB(26,26,34),BorderSizePixel=0},MainFrame)
make('UICorner',{CornerRadius=UDim.new(0,10)},TabContainer)

local ContentContainer = make('Frame',{Name='ContentContainer',Size=UDim2.new(1,-208,1,-58),Position=UDim2.new(0,196,0,54),BackgroundColor3=Color3.fromRGB(18,18,24),BorderSizePixel=0},MainFrame)
make('UICorner',{CornerRadius=UDim.new(0,10)},ContentContainer)
make('UIPadding',{PaddingTop=UDim.new(0,12),PaddingBottom=UDim.new(0,12),PaddingLeft=UDim.new(0,12),PaddingRight=UDim.new(0,12)},ContentContainer)

local ContentScroll = make('ScrollingFrame',{Name='ContentScroll',Size=UDim2.new(1,-4,1,-4),Position=UDim2.new(0,2,0,2),BackgroundTransparency=1,ScrollBarThickness=6,CanvasSize=UDim2.new(0,0,0,0)},ContentContainer)
local ContentList = make('UIListLayout',{Padding=UDim.new(0,12),SortOrder=Enum.SortOrder.LayoutOrder},ContentScroll)

local awaitingHideKeyCapture, SetHideKeyButtonRef = false, nil
UIS.InputBegan:Connect(function(input, gp)
	if gp then return end
	if awaitingHideKeyCapture and input.UserInputType == Enum.UserInputType.Keyboard then
		config.HideGUIKey = input.KeyCode.Name; saveConfig(); awaitingHideKeyCapture=false
		if SetHideKeyButtonRef then SetHideKeyButtonRef.Text = "Set Hide Key ("..(config.HideGUIKey or 'RightControl')..")" end
		return
	end
	if input.UserInputType == Enum.UserInputType.Keyboard then
		if input.KeyCode.Name == (config.HideGUIKey or 'RightControl') then ScreenGui.Enabled = not ScreenGui.Enabled end
	end
end)

local function TabButton(parent, text, icon)
	local btn = make('TextButton',{
		Size=UDim2.new(1,-16,0,40),Position=UDim2.new(0,8,0,0),BackgroundColor3=Color3.fromRGB(30,30,40),Text=icon..'  '..text,
		TextColor3=Color3.fromRGB(210,210,220),TextScaled=true,Font=Enum.Font.Gotham,BorderSizePixel=0
	},parent)
	make('UICorner',{CornerRadius=UDim.new(0,8)},btn)
	local accent = make('Frame',{Size=UDim2.new(0,3,1,0),Position=UDim2.new(0,0,0,0),BackgroundColor3=Color3.fromRGB(0,170,255),Visible=false},btn)
	return btn, accent
end

local function CreateTab(name, icon)
	local count = 0
	for _,c in ipairs(TabContainer:GetChildren()) do if c:IsA('TextButton') then count+=1 end end
	local btn, accent = TabButton(TabContainer, name, icon); btn.Position = UDim2.new(0,8,0,count*46+8)
	local TabContent = make('Frame',{Name=name..'Content',Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Visible=false},ContentScroll)
	make('UIListLayout',{Padding=UDim.new(0,10),SortOrder=Enum.SortOrder.LayoutOrder},TabContent)
	make('UIPadding',{PaddingLeft=UDim.new(0,4),PaddingRight=UDim.new(0,4)},TabContent)
	btn.MouseButton1Click:Connect(function()
		for _, child in ipairs(ContentScroll:GetChildren()) do if child:IsA('Frame') and child.Name:find('Content') then child.Visible=false end end
		for _, b in ipairs(TabContainer:GetChildren()) do
			if b:IsA('TextButton') then
				b.BackgroundColor3=Color3.fromRGB(30,30,40); b.TextColor3=Color3.fromRGB(210,210,220)
				local a=b:FindFirstChildOfClass('Frame'); if a then a.Visible=false end
			end
		end
		TabContent.Visible=true; btn.BackgroundColor3=Color3.fromRGB(45,45,60); btn.TextColor3=Color3.fromRGB(240,240,250); accent.Visible=true
	end)
	return TabContent
end

local function CreateSection(parent, title)
	local Section = make('Frame',{Name=title..'Section',Size=UDim2.new(1,-8,0,0),BackgroundColor3=Color3.fromRGB(24,24,32),BorderSizePixel=0},parent)
	make('UICorner',{CornerRadius=UDim.new(0,10)},Section)
	make('TextLabel',{Name='Title',Size=UDim2.new(1, -12, 0, 28),Position=UDim2.new(0, 12, 0, 8),BackgroundTransparency=1,Text=title,TextColor3=Color3.fromRGB(235,235,245),TextScaled=true,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Left},Section)
	local SectionContent = make('Frame',{Name='Content',Size=UDim2.new(1,-24,0,0),Position=UDim2.new(0,12,0,44),BackgroundTransparency=1},Section)
	make('UIListLayout',{Padding=UDim.new(0,8),SortOrder=Enum.SortOrder.LayoutOrder},SectionContent)
	return SectionContent
end

local function CreateToggle(parent, name, configKey, callback)
	local row = make('Frame',{Name=name..'Toggle',Size=UDim2.new(1,0,0,32),BackgroundTransparency=1},parent)
	local bg = make('Frame',{Size=UDim2.new(1,0,1,0),BackgroundColor3=Color3.fromRGB(28,28,38),BorderSizePixel=0},row)
	make('UICorner',{CornerRadius=UDim.new(0,8)},bg)
	make('TextLabel',{Size=UDim2.new(1,-72,1,0),Position=UDim2.new(0,12,0,0),BackgroundTransparency=1,Text=name,TextColor3=Color3.fromRGB(230,230,240),TextScaled=true,Font=Enum.Font.Gotham,TextXAlignment=Enum.TextXAlignment.Left},bg)
	local btn = make('TextButton',{Size=UDim2.new(0,52,0,24),Position=UDim2.new(1,-64,0.5,-12),BackgroundColor3=Color3.fromRGB(60,60,70),Text='',BorderSizePixel=0},bg)
	make('UICorner',{CornerRadius=UDim.new(1,0)},btn)
	local knob = make('Frame',{Size=UDim2.new(0,20,0,20),Position=UDim2.new(0,2,0.5,-10),BackgroundColor3=Color3.fromRGB(200,200,205),BorderSizePixel=0},btn)
	make('UICorner',{CornerRadius=UDim.new(1,0)},knob)
	local function vis()
		local on = config[configKey]
		btn.BackgroundColor3 = on and Color3.fromRGB(0,170,255) or Color3.fromRGB(60,60,70)
		knob:TweenPosition(on and UDim2.new(1,-22,0.5,-10) or UDim2.new(0,2,0.5,-10), 'Out', 'Quad', 0.15, true)
	end
	btn.MouseButton1Click:Connect(function()
		config[configKey] = not config[configKey]
		vis()
		if callback then callback(config[configKey]) end
		saveConfig()
	end)
	vis(); task.defer(function() if callback then callback(config[configKey]) end end)
	return row
end

local function CreateSlider(parent, name, configKey, min, max, default, callback)
	local frame = make('Frame',{Name=name..'Slider',Size=UDim2.new(1,0,0,48),BackgroundTransparency=1},parent)
	local bg = make('Frame',{Size=UDim2.new(1,0,1,0),BackgroundColor3=Color3.fromRGB(28,28,38),BorderSizePixel=0},frame)
	make('UICorner',{CornerRadius=UDim.new(0,8)},bg)
	local lbl = make('TextLabel',{Size=UDim2.new(1,-12,0,20),Position=UDim2.new(0,12,0,6),BackgroundTransparency=1,Text=name..': '..(config[configKey] or default),TextColor3=Color3.fromRGB(230,230,240),TextScaled=true,Font=Enum.Font.Gotham,TextXAlignment=Enum.TextXAlignment.Left},bg)
	local bar = make('Frame',{Size=UDim2.new(1,-24,0,6),Position=UDim2.new(0,12,1,-14),BackgroundColor3=Color3.fromRGB(55,55,65),BorderSizePixel=0},bg)
	make('UICorner',{CornerRadius=UDim.new(0,3)},bar)
	local fill = make('Frame',{Size=UDim2.new(0,0,1,0),BackgroundColor3=Color3.fromRGB(0,170,255),BorderSizePixel=0},bar)
	make('UICorner',{CornerRadius=UDim.new(0,3)},fill)
	local knob = make('Frame',{Size=UDim2.new(0,14,0,14),Position=UDim2.new(0,-7,0.5,-7),BackgroundColor3=Color3.fromRGB(235,235,245),BorderSizePixel=0},bar)
	make('UICorner',{CornerRadius=UDim.new(1,0)},knob)
	local dragging = false
	local function apply(value)
		local step = 0.01
		local val = math.floor((value/step)+0.5) * step
		val = math.clamp(val, min, max)
		local pct = (val - min) / (max - min)
		fill.Size = UDim2.new(pct,0,1,0)
		knob.Position = UDim2.new(pct,-7,0.5,-7)
		lbl.Text = name..': '..string.format('%.2f', val)
		config[configKey] = val
		if callback then callback(val) end
		saveConfig()
	end
	apply(config[configKey] or default)
	bar.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=true end end)
	UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end end)
	UIS.InputChanged:Connect(function(i)
		if dragging and i.UserInputType==Enum.UserInputType.MouseMovement then
			local m = UIS:GetMouseLocation(); local p = bar.AbsolutePosition; local s = bar.AbsoluteSize
			local pct = math.clamp((m.X - p.X)/s.X, 0, 1); apply(min + (max-min)*pct)
		end
	end)
	return frame
end

local function CreateButton(parent, name, onClick)
	local b = make('TextButton',{Name=name..'Button',Size=UDim2.new(0,260,0,32),BackgroundColor3=Color3.fromRGB(36,36,48),BorderSizePixel=0,Text=name,TextColor3=Color3.fromRGB(235,235,245),TextScaled=true,Font=Enum.Font.Gotham},parent)
	make('UICorner',{CornerRadius=UDim.new(0,8)},b)
	b.MouseButton1Click:Connect(function() if onClick then pcall(onClick) end end)
	return b
end

-- Tabs
local CombatTab = CreateTab('Combat','⚔️')
local MovementTab = CreateTab('Movement','🏃')
local UtilityTab = CreateTab('Utility','🔧')
local VisualTab = CreateTab('Visual','👁️')
local QuestsTab = CreateTab('Quests','📋')
local ShopsTab = CreateTab('Shops','🛒')
local TeleportTab = CreateTab('Teleport','🧭')
local ConfigTab = CreateTab('Config','⚙️')

-- Add scrollable containers for Combat and Utility
local CombatScroll = make('ScrollingFrame',{Name='CombatScroll',Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,ScrollBarThickness=6,CanvasSize=UDim2.new(0,0,0,0)},CombatTab)
local CombatLayout = make('UIListLayout',{Padding=UDim.new(0,10),SortOrder=Enum.SortOrder.LayoutOrder},CombatScroll)
CombatLayout:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
	CombatScroll.CanvasSize = UDim2.new(0,0,0,CombatLayout.AbsoluteContentSize.Y+12)
end)

local UtilityScroll = make('ScrollingFrame',{Name='UtilityScroll',Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,ScrollBarThickness=6,CanvasSize=UDim2.new(0,0,0,0)},UtilityTab)
local UtilityLayout = make('UIListLayout',{Padding=UDim.new(0,10),SortOrder=Enum.SortOrder.LayoutOrder},UtilityScroll)
UtilityLayout:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
	UtilityScroll.CanvasSize = UDim2.new(0,0,0,UtilityLayout.AbsoluteContentSize.Y+12)
end)

-- Teleport two-column layout
local TeleportRoot = make('Frame',{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1},TeleportTab)
local LeftCol = make('ScrollingFrame',{Name='LeftCol',Size=UDim2.new(0.55,-8,1,0),Position=UDim2.new(0,0,0,0),BackgroundTransparency=1,ScrollBarThickness=6,CanvasSize=UDim2.new(0,0,0,0)},TeleportRoot)
local LeftLayout = make('UIListLayout',{Padding=UDim.new(0,8),SortOrder=Enum.SortOrder.LayoutOrder},LeftCol)
LeftLayout:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
	LeftCol.CanvasSize = UDim2.new(0,0,0,LeftLayout.AbsoluteContentSize.Y+20)
end)
local RightCol = make('ScrollingFrame',{Name='RightCol',Size=UDim2.new(0.45,0,1,0),Position=UDim2.new(0.55,8,0,0),BackgroundTransparency=1,ScrollBarThickness=6,CanvasSize=UDim2.new(0,0,0,0)},TeleportRoot)
local RightLayout = make('UIListLayout',{Padding=UDim.new(0,8),SortOrder=Enum.SortOrder.LayoutOrder},RightCol)
RightLayout:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
	RightCol.CanvasSize = UDim2.new(0,0,0,RightLayout.AbsoluteContentSize.Y+20)
end)

local function addTitle(parent, text)
	make('TextLabel',{Size=UDim2.new(1,0,0,26),BackgroundTransparency=1,Text=text,TextColor3=Color3.fromRGB(235,235,245),TextXAlignment=Enum.TextXAlignment.Left,TextScaled=true,Font=Enum.Font.GothamBold},parent)
end
local function getInstanceAtPath(parts) local cur=workspace; for _,n in ipairs(parts) do if not cur or not cur.FindFirstChild then return nil end; cur=cur:FindFirstChild(n) end; return cur end
local function teleportTo(target)
	local char,_,hrp = getCharHumanoid(); if not (char and hrp and target) then return end
	local cf = target:IsA('BasePart') and target.CFrame or (target:IsA('Model') and target:GetPivot() or nil); if not cf then return end
	local dest = CFrame.new(cf.Position + (cf.LookVector*4) + Vector3.new(0,3,0), cf.Position + (cf.LookVector*5)); char:PivotTo(dest)
end
local function addTeleport(parent, parts, label) CreateButton(parent,label,function() local inst=getInstanceAtPath(parts); if not inst then return end; teleportTo(inst) end) end

-- RIGHT COLUMN: Players + Saved Position
do
	addTitle(RightCol,'Players')
	local PlayersList = make('Frame',{Name='PlayersList',Size=UDim2.new(1,0,0,0),BackgroundTransparency=1},RightCol)
	local PlayersListLayout = make('UIListLayout',{Padding=UDim.new(0,8),SortOrder=Enum.SortOrder.LayoutOrder},PlayersList)
	PlayersListLayout:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
		PlayersList.Size = UDim2.new(1,0,0,PlayersListLayout.AbsoluteContentSize.Y)
	end)
	local buttons = {}
	local function makePlayerButton(plr)
		return CreateButton(PlayersList, plr.Name, function()
			local char = plr.Character
			local hrp = char and char:FindFirstChild('HumanoidRootPart')
			if hrp then
				local cf = CFrame.new(hrp.Position + Vector3.new(0,3,0), hrp.Position + hrp.CFrame.LookVector*2)
				local myChar = LocalPlayer.Character
				if myChar then pcall(function() myChar:PivotTo(cf) end) end
			end
		end)
	end
	local function refresh()
		for plr,btn in pairs(buttons) do pcall(function() btn:Destroy() end); buttons[plr]=nil end
		for _,plr in ipairs(Players:GetPlayers()) do if plr ~= LocalPlayer then buttons[plr] = makePlayerButton(plr) end end
	end
	refresh()
	Players.PlayerAdded:Connect(function(plr) if plr~=LocalPlayer then buttons[plr]=makePlayerButton(plr) end end)
	Players.PlayerRemoving:Connect(function(plr) if buttons[plr] then pcall(function() buttons[plr]:Destroy() end); buttons[plr]=nil end end)

	addTitle(RightCol,'Saved Position')
	local row = make('Frame',{Size=UDim2.new(1,0,0,0),BackgroundTransparency=1},RightCol)
	local rowList = make('UIListLayout',{Padding=UDim.new(0,6),SortOrder=Enum.SortOrder.LayoutOrder},row)
	CreateButton(row,'Save Place',function() local _,_,hrp=getCharHumanoid(); if hrp then _G.__SavedCFrame = hrp.CFrame end end)
	CreateButton(row,'Teleport To Save',function() local cf=_G.__SavedCFrame; local char=LocalPlayer.Character; if cf and char then pcall(function() char:PivotTo(cf) end) end end)
	rowList:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function() row.Size = UDim2.new(1,0,0,rowList.AbsoluteContentSize.Y) end)
end

-- LEFT COLUMN: Teleports (compact lists)
local function addTeleports(title, list)
	addTitle(LeftCol, title)
	for _, item in ipairs(list) do addTeleport(LeftCol, item[1], item[2]) end
end

addTeleports('Stores', {
	{{'Pads','ExoticStore','1'},'Exotic Store'},
	{{'Pads','ExoticStore2','1'},'Dark Exotic Store'},
	{{'Pads','Store','1'},'Starter Store'},
	{{'Pads','Store','2'},'Supermarket'},
	{{'Pads','Store','3'},'Gym Store'},
	{{'Pads','Store','4'},'Necklace Store'},
	{{'Pads','Store','5'},'Melee Store'},
	{{'Pads','Store','6'},'Premium Shop'},
	{{'Pads','Store','7'},'Armour Shop 1'},
	{{'Pads','Store','8'},'Armour Shop 2'},
	{{'Pads','Store','9'},'Tower Store'},
	{{'Pads','Store','12'},'Accessory Store'},
	{{'Pads','Store','13'},'Combat Helmet Store'},
	{{'Pads','Store','10'},'Luxury Hats Store'},
	{{'Pads','Store','11'},'Basic Trails Store'},
	{{'Pads','Store','14'},'Advanced Trail Store'},
	{{'Pads','Store','15'},'Legendary Trail Store'},
})
addTeleports('Wand Stores', {
	{{'Pads','Wands','1'},'Wand Store 1'},
	{{'Pads','Wands','2'},'Wand Store 2'},
})
addTitle(LeftCol,'Weight Stores')
for i=1,5 do addTeleport(LeftCol,{'Pads','Weight',tostring(i)},'Weight Store '..i) end
addTeleports('Stand Stores', {
	{{'Pads','StandIndex','1'},'Stand Store 1'},
	{{'Pads','StandIndex','2'},'Greater Stands'},
	{{'Pads','StandIndex','3'},'Demonic Stands'},
})
addTeleports('Deluxo Upgrades', {
	{{'Pads','DeluxoUpgrade','Credits'},'Deluxo Upgrade'},
})
addTeleports('Questlines', {
	{{'Pads','MainTasks','MainTask'},'Main Questline'},
	{{'Pads','MainTasks','AQuest'},'Extra Questline'},
	{{'Pads','MainTasks','LucaTask'},'Luca Questline'},
	{{'Pads','MainTasks','ReaperTask'},'Reaper Questline'},
	{{'Pads','MainTasks','GladiatorTask'},'Gladiator Questline'},
	{{'Pads','MainTasks','TowerFacility'},'Tower Questline'},
	{{'Pads','MainTasks','AncientQuests'},'Ancient Questline'},
	{{'Pads','MainTasks','TankQuests'},'Defence Questline'},
	{{'Pads','MainTasks','PowerQuests'},'Power Questline'},
	{{'Pads','MainTasks','MagicQuests'},'Magic Questline'},
	{{'Pads','MainTasks','MobilityQuests'},'Mobility Questline'},
})
addTeleports('Side Tasks', {
	{{'Pads','SideTasks','1'},'Dishes Side Task'},
	{{'Pads','SideTasks','2'},'Spawn Mob Task'},
	{{'Pads','SideTasks','3'},'City Mob Tasks 1'},
	{{'Pads','SideTasks','4'},'City Mob Tasks 2'},
	{{'Pads','SideTasks','5'},'Ninja Mob Tasks'},
	{{'Pads','SideTasks','7'},'Arena Mob Tasks'},
})
addTeleports('Experiments', {
	{{'Experiment','FloorHitbox'},'Mobility Experiment'},
	{{'Experiment','SurvivalHitbox'},'Health Experiment'},
	{{'Pads','Telekinesis','Telekinesis'},'Psychic Experiment'},
	{{'WallGame','WallHitbox'},'Power Experiment'},
	{{'Experiment','Energy','15','Part'},'Magic Experiment'},
})

-- Controllers

-- No Clip
local __NoClip = { conn=nil, charConn=nil, descConn=nil, orig={} }
local function ncRecord(part) if not __NoClip.orig[part] then __NoClip.orig[part] = part.CanCollide end end
local function ncApplyOnPart(part) if part:IsA('BasePart') then ncRecord(part); part.CanCollide = false end end
local function ncApplyAll() local char = LocalPlayer.Character; if not char then return end; for _, p in ipairs(char:GetDescendants()) do ncApplyOnPart(p) end end
local function ncRestoreAll() for part, was in pairs(__NoClip.orig) do if part and part.Parent then pcall(function() part.CanCollide = was end) end end; table.clear(__NoClip.orig) end
local function ToggleNoClip(on)
	getgenv().NoClip = on
	if on then
		if __NoClip.conn then __NoClip.conn:Disconnect() end
		if __NoClip.charConn then __NoClip.charConn:Disconnect() end
		if __NoClip.descConn then __NoClip.descConn:Disconnect() end
		ncApplyAll()
		__NoClip.conn = RS.Stepped:Connect(function() if getgenv().NoClip then ncApplyAll() end end)
		__NoClip.charConn = LocalPlayer.CharacterAdded:Connect(function(char)
			if getgenv().NoClip then
				table.clear(__NoClip.orig)
				task.wait(0.1)
				ncApplyAll()
				if __NoClip.descConn then __NoClip.descConn:Disconnect() end
				__NoClip.descConn = char.DescendantAdded:Connect(function(inst) if getgenv().NoClip then ncApplyOnPart(inst) end end)
			end
		end)
		local char = LocalPlayer.Character
		if char then
			if __NoClip.descConn then __NoClip.descConn:Disconnect() end
			__NoClip.descConn = char.DescendantAdded:Connect(function(inst) if getgenv().NoClip then ncApplyOnPart(inst) end end)
		end
	else
		if __NoClip.conn then __NoClip.conn:Disconnect() __NoClip.conn=nil end
		if __NoClip.charConn then __NoClip.charConn:Disconnect() __NoClip.charConn=nil end
		if __NoClip.descConn then __NoClip.descConn:Disconnect() __NoClip.descConn=nil end
		ncRestoreAll()
	end
end

-- Graphics Optimization (simple)
local function ToggleAFKOpt(on)
	getgenv().GraphicsOptimization = on
	pcall(function()
		settings().Rendering.QualityLevel = on and 1 or 21
		settings().Physics.PhysicsSendRate = on and 1 or 60
	end)
end

-- Graphics Optimization Advanced
local __AdvGfxBackup = { lighting = {}, terrain = {}, conns = {} }
local function ToggleGraphicsOptAdvanced(on)
	getgenv().GraphicsOptimizationAdvanced = on
	local Terrain = workspace:FindFirstChildOfClass('Terrain')
	local function setProp(bucket, inst, prop, val)
		if __AdvGfxBackup[bucket][inst] == nil then __AdvGfxBackup[bucket][inst] = {} end
		if __AdvGfxBackup[bucket][inst][prop] == nil then
			local ok, old = pcall(function() return inst[prop] end)
			if ok then __AdvGfxBackup[bucket][inst][prop] = old end
		end
		pcall(function() inst[prop] = val end)
	end
	local function restoreAll()
		for t, insts in pairs(__AdvGfxBackup) do
			if t ~= 'conns' then
				for inst, props in pairs(insts) do
					for prop, old in pairs(props) do pcall(function() inst[prop] = old end) end
				end
				__AdvGfxBackup[t] = {}
			end
		end
		for _, c in ipairs(__AdvGfxBackup.conns) do pcall(function() c:Disconnect() end) end
		__AdvGfxBackup.conns = {}
	end
	if not on then restoreAll(); return end
	setProp('lighting', Lighting, 'Brightness', 2)
	setProp('lighting', Lighting, 'ClockTime', 14)
	setProp('lighting', Lighting, 'GlobalShadows', false)
	setProp('lighting', Lighting, 'ShadowSoftness', 0)
	setProp('lighting', Lighting, 'EnvironmentDiffuseScale', 0)
	setProp('lighting', Lighting, 'EnvironmentSpecularScale', 0)
	for _, o in ipairs(Lighting:GetChildren()) do
		local c = o.ClassName
		if c == 'BloomEffect' or c == 'DepthOfFieldEffect' or c == 'ColorCorrectionEffect' or c == 'SunRaysEffect' or c == 'BlurEffect' then pcall(function() o.Enabled = false end)
		elseif c == 'Atmosphere' then setProp('lighting', o, 'Density', 0); setProp('lighting', o, 'Haze', 0); setProp('lighting', o, 'Glare', 0)
		elseif c == 'Clouds' then setProp('lighting', o, 'Coverage', 0); setProp('lighting', o, 'Density', 0) end
	end
	if Terrain then
		setProp('terrain', Terrain, 'Decoration', false)
		setProp('terrain', Terrain, 'WaterReflectance', 0)
		setProp('terrain', Terrain, 'WaterTransparency', 1)
		setProp('terrain', Terrain, 'WaterWaveSize', 0)
		setProp('terrain', Terrain, 'WaterWaveSpeed', 0)
	end
	local function simplify(inst)
		local c = inst.ClassName
		if c == 'ParticleEmitter' or c == 'Trail' or c == 'Beam' or c == 'Smoke' or c == 'Fire' or c == 'Sparkles' then pcall(function() inst.Enabled = false end)
		elseif c == 'PointLight' or c == 'SpotLight' or c == 'SurfaceLight' then if inst.Enabled ~= nil then pcall(function() inst.Enabled = false end) else pcall(function() inst.Brightness = 0 end) end
		elseif c == 'Decal' or c == 'Texture' then pcall(function() inst.Transparency = 1 end)
		elseif c == 'MeshPart' then pcall(function() inst.RenderFidelity = Enum.RenderFidelity.Performance end) end
	end
	for _, d in ipairs(workspace:GetDescendants()) do simplify(d) end
	table.insert(__AdvGfxBackup.conns, workspace.DescendantAdded:Connect(simplify))
end

-- Ultimate AFK Optimization
local function ToggleUltimateAFK(on)
	config.UltimateAFKOptimization = on; saveConfig()
	getgenv().UltimateOpt = getgenv().UltimateOpt or { applied=false, changed={}, conn=nil }
	local S = getgenv().UltimateOpt
	local function restoreAll()
		for i = #S.changed, 1, -1 do
			local r = S.changed[i]
			if r.inst and r.inst.Parent ~= nil then pcall(function() r.inst[r.prop] = r.old end) end
			S.changed[i] = nil
		end
		if S.conn then pcall(function() S.conn:Disconnect() end); S.conn=nil end
		S.applied = false
	end
	if not on then
		restoreAll()
		pcall(function() settings().Rendering.QualityLevel = 21; settings().Physics.PhysicsSendRate = 60 end)
		return
	end
	if S.applied then return end
	local function setProp(inst, prop, val)
		pcall(function()
			local ok, old = pcall(function() return inst[prop] end)
			if ok then table.insert(S.changed, {inst=inst, prop=prop, old=old}) end
			inst[prop] = val
		end)
	end
	pcall(function() settings().Rendering.QualityLevel = 1; settings().Physics.PhysicsSendRate = 1 end)
	setProp(Lighting, 'Brightness', 2); setProp(Lighting, 'ClockTime', 14)
	setProp(Lighting, 'GlobalShadows', false); setProp(Lighting, 'ShadowSoftness', 0)
	setProp(Lighting, 'EnvironmentDiffuseScale', 0); setProp(Lighting, 'EnvironmentSpecularScale', 0)
	for _,o in ipairs(Lighting:GetChildren()) do
		local c=o.ClassName
		if c=='BloomEffect' or c=='DepthOfFieldEffect' or c=='ColorCorrectionEffect' or c=='SunRaysEffect' or c=='BlurEffect' then setProp(o,'Enabled',false)
		elseif c=='Atmosphere' then setProp(o,'Density',0); setProp(o,'Haze',0); setProp(o,'Glare',0)
		elseif c=='Clouds' then setProp(o,'Coverage',0); setProp(o,'Density',0) end
	end
	local t = workspace:FindFirstChildOfClass('Terrain')
	if t then setProp(t,'Decoration',false); setProp(t,'WaterReflectance',0); setProp(t,'WaterTransparency',1); setProp(t,'WaterWaveSize',0); setProp(t,'WaterWaveSpeed',0) end
	local function simplify(inst)
		local c = inst.ClassName
		if c=='ParticleEmitter' or c=='Trail' or c=='Beam' or c=='Smoke' or c=='Fire' or c=='Sparkles' then if pcall(function() return inst.Enabled end) then setProp(inst,'Enabled',false) end
		elseif c=='PointLight' or c=='SpotLight' or c=='SurfaceLight' then if pcall(function() return inst.Enabled end) then setProp(inst,'Enabled',false) else setProp(inst,'Brightness',0) end
		elseif c=='Decal' or c=='Texture' then setProp(inst,'Transparency',1)
		elseif c=='MeshPart' then setProp(inst,'RenderFidelity', Enum.RenderFidelity.Performance) end
	end
	for _,d in ipairs(workspace:GetDescendants()) do simplify(d) end
	S.conn = workspace.DescendantAdded:Connect(simplify)
	S.applied = true
end

-- Player ESP
local function TogglePlayerESP(enabled)
	getgenv().PlayerESP = enabled
	if not Drawing then return end
	if getgenv().__PlayerESPConn then getgenv().__PlayerESPConn:Disconnect(); getgenv().__PlayerESPConn=nil end
	local boxes = {}
	local function mk(player)
		local box=Drawing.new('Square'); box.Filled=false; box.Thickness=2; box.Visible=false
		local name=Drawing.new('Text'); name.Size=24; name.Center=true; name.Outline=true; name.Visible=false
		boxes[player]={box=box,name=name}
	end
	local function rm(player) local e=boxes[player]; if not e then return end; pcall(function() e.box:Remove() e.name:Remove() end); boxes[player]=nil end
	if enabled then
		getgenv().__PlayerESPConn = RS.RenderStepped:Connect(function()
			if not getgenv().PlayerESP then for p,_ in pairs(boxes) do rm(p) end; return end
			for _,p in ipairs(Players:GetPlayers()) do
				if p~=LocalPlayer and p.Character and p.Character:FindFirstChild('Head') then
					if not boxes[p] then mk(p) end
					local e=boxes[p]; local head=p.Character.Head
					local pos,vis = Camera:WorldToViewportPoint(head.Position)
					if not vis then e.box.Visible=false e.name.Visible=false else
						local dist=(Camera.CFrame.Position - head.Position).Magnitude
						local size=math.clamp((100/math.max(dist,1))*100,20,80)
						local col=Color3.fromHSV((tick()*0.2)%1,1,1)
						e.box.Position=Vector2.new(pos.X-size/2,pos.Y-size/2); e.box.Size=Vector2.new(size,size); e.box.Color=col; e.box.Visible=true
						e.name.Text=p.Name; e.name.Position=Vector2.new(pos.X,pos.Y-size/2-18); e.name.Color=col; e.name.Visible=true
					end
				end
			end
			for p,_ in pairs(boxes) do if not p or not p.Character or not p.Character:FindFirstChild('Head') then rm(p) end end
		end)
	else
		for p,_ in pairs(boxes) do rm(p) end
	end
end

-- Mob ESP
local function ToggleMobESP(enabled)
	getgenv().MobESP = enabled
	local M = rawget(getgenv(), 'EnemyESP2')
	if M and M.Disable then M.Disable() end
	if not enabled then return end
	if M and M.Enable then M.Enable(); return end
	-- (Existing EnemyESP2 implementation remains)
end

-- Remove Map Clutter
local function RunRemoveMapClutter()
	for _, o in ipairs(Lighting:GetChildren()) do
		local c = o.ClassName
		if c == 'BloomEffect' or c == 'DepthOfFieldEffect' or c == 'ColorCorrectionEffect' or c == 'SunRaysEffect' or c == 'BlurEffect' then
			pcall(function() o.Enabled = false end)
		elseif c == 'Atmosphere' or o.Name == 'Atmosphere' or o.Name=='SunRays' then
			pcall(function() o:Destroy() end)
		end
	end
	local function nukeFolder(name) local f = workspace:FindFirstChild(name); if f then for _, ch in ipairs(f:GetChildren()) do pcall(function() ch:Destroy() end) end end end
	for _, name in ipairs({ 'Trees', 'CityProps', 'Props', 'Decoration', 'Grass', 'VFX', 'Clouds' }) do nukeFolder(name) end
	for _, v in ipairs(workspace:GetDescendants()) do
		pcall(function()
			if v:IsA('ParticleEmitter') or v:IsA('Trail') or v:IsA('Beam') or v:IsA('Smoke') or v:IsA('Fire') or v:IsA('Sparkles') then v.Enabled = false
			elseif v:IsA('Decal') or v:IsA('Texture') then v.Transparency = 1
			elseif v:IsA('PointLight') or v:IsA('SpotLight') or v:IsA('SurfaceLight') then if v.Enabled ~= nil then v.Enabled = false else v.Brightness = 0 end
			elseif v:IsA('MeshPart') then v.RenderFidelity = Enum.RenderFidelity.Performance end
		end)
	end
end

-- Aimbots
local function fireFireballAt(pos)
	local ability = getEvent('Events','Other','Ability'); pcall(function() ability:InvokeServer('Fireball', pos) end)
end

local function ToggleUniversalAimbot(enabled)
	getgenv().UniversalFireBallAimbot = enabled
	if not enabled then return end
	task.spawn(function()
		while getgenv().UniversalFireBallAimbot do
			pcall(function()
				local enemies = workspace:FindFirstChild('Enemies'); if not enemies then return end
				local _,_,hrp = getCharHumanoid(); if not hrp then return end
				local myPos, bestDist, best = hrp.Position, math.huge, nil
				for _,bucket in ipairs(enemies:GetChildren()) do
					for _,m in ipairs(bucket:GetChildren()) do
						local p = m:FindFirstChild('HumanoidRootPart')
						local dead = m:FindFirstChild('Dead')
						if p and (not dead or dead.Value~=true) then
							local d=(myPos - p.Position).Magnitude
							if d<bestDist then bestDist=d; best=p end
						end
					end
				end
				if best then fireFireballAt(best.Position) end
			end)
			task.wait(math.max(0.01, tonumber(config.universalFireballInterval) or 1.0))
		end
	end)
end

local function ToggleCatacombsAimbot(enabled)
	getgenv().FireBallAimbot = enabled
	if not enabled then return end
	local targetOrder = { 15, 14, 12, 17, 13, 10, 4 }
	local currentTargetIndex = 1
	local lastFireballTime = 0
	task.spawn(function()
		while getgenv().FireBallAimbot do
			local player = Players.LocalPlayer
			if player and player.Character and player.Character:FindFirstChild('HumanoidRootPart') then
				local humanoid = player.Character:FindFirstChild('Humanoid')
				if humanoid and humanoid.Health <= 0 then
					getgenv().FireBallAimbot = false; config.FireBallAimbot = false; saveConfig(); break
				end
				local currentTime = tick()
				if (currentTime - lastFireballTime) >= (config.cityFireballCooldown or 0.2) then
					local targetFolderNumber = targetOrder[currentTargetIndex]
					local enemies = workspace:FindFirstChild('Enemies')
					if enemies then
						local targetFolder = enemies:FindFirstChild(tostring(targetFolderNumber))
						if targetFolder and targetFolder:IsA('Folder') then
							local targetPosition = Vector3.new(targetFolderNumber*20, 5, targetFolderNumber*10)
							for _, child in pairs(targetFolder:GetChildren()) do
								if child:IsA('Model') and child:FindFirstChild('HumanoidRootPart') then targetPosition = child.HumanoidRootPart.Position; break
								elseif child:IsA('BasePart') then targetPosition = child.Position; break end
							end
							local success = pcall(function() fireFireballAt(targetPosition) end)
							if success then lastFireballTime = currentTime; currentTargetIndex = currentTargetIndex % #targetOrder + 1; task.wait(0.3)
							else currentTargetIndex = currentTargetIndex % #targetOrder + 1; task.wait(0.1) end
						else currentTargetIndex = currentTargetIndex % #targetOrder + 1; task.wait(0.1) end
					else task.wait(0.5) end
				else task.wait(0.05) end
			else task.wait(0.1) end
		end
	end)
end

local function ToggleCityAimbot(enabled)
	getgenv().FireBallAimbotCity = enabled; if not enabled then return end
	local order = {5,9,8,6,3}; local idx, last = 1, 0
	task.spawn(function()
		while getgenv().FireBallAimbotCity do
			local char,hum,hrp = getCharHumanoid()
			if not hrp then task.wait(0.1) else
				if hum and hum.Health<=0 then getgenv().FireBallAimbotCity=false; config.FireBallAimbotCity=false; saveConfig(); break end
				local now=tick()
				if (now-last) >= (config.cityFireballCooldown or 0.5) then
					local enemies = workspace:FindFirstChild('Enemies')
					if enemies then
						local folder = enemies:FindFirstChild(tostring(order[idx]))
						if folder and folder:IsA('Folder') then
							local pos = Vector3.new(order[idx]*20,5,order[idx]*10)
							for _,ch in ipairs(folder:GetChildren()) do
								local p = ch:IsA('Model') and ch:FindFirstChild('HumanoidRootPart') or (ch:IsA('BasePart') and ch)
								if p then pos=p.Position; break end
							end
							fireFireballAt(pos); last=now; idx = idx % #order + 1; task.wait(0.3)
						else idx = idx % #order + 1; task.wait(0.1) end
					else task.wait(0.5) end
				else task.wait(0.05) end
			end
		end
	end)
end

-- Side Tasks
local function startSideTaskLoop(getKey, cfgKey, taskId)
	getgenv()[getKey] = true
	task.spawn(function()
		while getgenv()[getKey] do
			pcall(function()
				local _,hum = getCharHumanoid()
				if hum and hum.Health<=0 then getgenv()[getKey]=false; config[cfgKey]=false; saveConfig(); return end
				local other = getEvent('Events','Other')
				other:WaitForChild('StartSideTask',9e9):FireServer(taskId)
				if taskId==1 then pcall(function() other:WaitForChild('CleanDishes',9e9):FireServer() end) end
				other:WaitForChild('ClaimSideTask',9e9):FireServer(taskId)
			end)
			task.wait(math.random(50,70))
		end
	end)
end

local function ToggleAutoWashDishes(on)
	getgenv().AutoWashDishes = on
	if on then startSideTaskLoop('AutoWashDishes','AutoWashDishes',1) end
end
local function ToggleNinjaSide(on)
	config.AutoNinjaSideTask = on; saveConfig()
	if on then startSideTaskLoop('AutoNinjaSideTask','AutoNinjaSideTask',9) else getgenv().AutoNinjaSideTask=false end
end
local function ToggleAnimSide(on)
	config.AutoAnimatronicsSideTask = on; saveConfig()
	if on then startSideTaskLoop('AutoAnimatronicsSideTask','AutoAnimatronicsSideTask',10) else getgenv().AutoAnimatronicsSideTask=false end
end
local function ToggleMutantsSide(on)
	config.AutoMutantsSideTask = on; saveConfig()
	if on then startSideTaskLoop('AutoMutantsSideTask','AutoMutantsSideTask',7) else getgenv().AutoMutantsSideTask=false end
end

-- Shops
local function ToggleDualExoticShop(on)
	config.DualExoticShop = on; saveConfig()
	getgenv().DualExoticShop = on
	if not on then return end
	task.spawn(function()
		local function getPadPart(padModel)
			if not padModel then return nil end
			if padModel:IsA("BasePart") then return padModel end
			if padModel:IsA("Model") then return padModel:FindFirstChildWhichIsA("BasePart") end
			return nil
		end
		task.wait(10)
		while getgenv().DualExoticShop do
			pcall(function()
				local _, hum, hrp = getCharHumanoid(); if not hrp or (hum and hum.Health<=0) then return end
				local spent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("Spent")
				local remote1 = spent:WaitForChild("BuyExotic")
				local remote2 = spent:WaitForChild("BuyExotic2")
				local frames = LocalPlayer.PlayerGui:WaitForChild("Frames")
				local gui1 = frames:WaitForChild("ExoticStore")
				local gui2 = frames:WaitForChild("ExoticStore2")
				local pad1 = getPadPart(workspace:WaitForChild("Pads"):WaitForChild("ExoticStore"):WaitForChild("1"))
				local pad2 = getPadPart(workspace:WaitForChild("Pads"):WaitForChild("ExoticStore2"):WaitForChild("1"))
				local function buyPotions(shopFrame, remote)
					local list = shopFrame and shopFrame:FindFirstChild("Content") and shopFrame.Content:FindChild("ExoticList") or shopFrame.Content:FindFirstChild("ExoticList")
					if not list then list = shopFrame and shopFrame:FindFirstChild("ExoticList") end
					if not list then return end
					for _, v in pairs(list:GetChildren()) do
						local info2 = v:FindFirstChild("Info") and v.Info:FindFirstChild("Info")
						if info2 and info2.Text == "POTION" then
							local itemNumber = tonumber(string.match(v.Name, "%d+"))
							if itemNumber then pcall(function() remote:FireServer(itemNumber) end) end
						end
					end
				end
				local original = hrp.CFrame
				if pad1 then hrp.CFrame = pad1.CFrame + Vector3.new(0,3,0); task.wait(1); buyPotions(gui1, remote1); hrp.CFrame = original; task.wait(1) end
				if pad2 then hrp.CFrame = pad2.CFrame + Vector3.new(0,3,0); task.wait(1); buyPotions(gui2, remote2); hrp.CFrame = original; task.wait(1) end
			end)
			for i=1,600 do if not getgenv().DualExoticShop then break end; task.wait(1) end
		end
	end)
end

local function ToggleVending(on)
	getgenv().VendingPotionAutoBuy = on
	if on then
		task.spawn(function()
			local buy = getEvent('Events','VendingMachine','BuyPotion')
			local args = { {2,5000},{3,15000},{1,1500},{4,150000},{5,1500000} }
			while getgenv().VendingPotionAutoBuy do
				for _,a in ipairs(args) do
					if not getgenv().VendingPotionAutoBuy then break end
					pcall(function() buy:FireServer(unpack(a)) end)
					for i=1,60 do if not getgenv().VendingPotionAutoBuy then break end; task.wait(1) end
				end
			end
		end)
	end
end

-- Utility: 15m Stat Webhook
local function ToggleStatWebhook15m(on)
	config.StatWebhook15m = on; saveConfig()
	getgenv().StatWebhook15m = on
	if not on then return end
	task.spawn(function()
		local stats = ReplicatedStorage:WaitForChild("Data"):WaitForChild(LocalPlayer.Name):WaitForChild("Stats")
		local oldPower, oldDefense, oldHealth, oldMagic, oldPsy =
			stats.Power.Value, stats.Defense.Value, stats.Health.Value, stats.Magic.Value, stats.Psychics.Value
		local function formatNumber(n)
			n = tonumber(n) or 0
			if n >= 1e15 then return string.format('%.1f', n/1e15)..'qd' end
			if n >= 1e12 then return string.format('%.1f', n/1e12)..'t' end
			if n >= 1e9  then return string.format('%.1f', n/1e9 )..'b' end
			if n >= 1e6  then return string.format('%.1f', n/1e6 )..'m' end
			if n >= 1e3  then return string.format('%.1f', n/1e3 )..'k' end
			return tostring(n)
		end
		while getgenv().StatWebhook15m do
			for i=1,900 do if not getgenv().StatWebhook15m then break end; task.wait(1) end
			if not getgenv().StatWebhook15m then break end
			local newPower, newDefense, newHealth, newMagic, newPsy =
				stats.Power.Value, stats.Defense.Value, stats.Health.Value, stats.Magic.Value, stats.Psychics.Value
			if newPower > oldPower or newDefense > oldDefense or newHealth > oldHealth or newMagic > oldMagic or newPsy > oldPsy then
				local title = LocalPlayer.Name .. " Stats Gained Last 15 Minutes"
				local desc = "**Power:** " .. formatNumber(newPower - oldPower)
					.. "\n**Defense:** " .. formatNumber(newDefense - oldDefense)
					.. "\n**Health:** " .. formatNumber(newHealth - oldHealth)
					.. "\n**Magic:** " .. formatNumber(newMagic - oldMagic)
					.. "\n**Psychics:** " .. formatNumber(newPsy - oldPsy)
				postWebhook('Stat Bot', title, desc, nil)
				oldPower, oldDefense, oldHealth, oldMagic, oldPsy = newPower, newDefense, newHealth, newMagic, newPsy
			end
		end
	end)
end

-- Combat: Kill Aura
local __KillAuraConn
local function ToggleKillAura(on)
	config.KillAura = on; saveConfig()
	getgenv().KillAura = on
	if __KillAuraConn then __KillAuraConn:Disconnect(); __KillAuraConn=nil end
	if not on then return end
	__KillAuraConn = RS.Heartbeat:Connect(function()
		local _, _, hrp = getCharHumanoid(); if not hrp then return end
		local enemiesFolder = workspace:FindFirstChild("Enemies"); if not enemiesFolder then return end
		for _, sub in ipairs(enemiesFolder:GetChildren()) do
			for _, enemy in ipairs(sub:GetChildren()) do
				if enemy:IsA("Model") then
					local part = enemy:FindFirstChild("HumanoidRootPart")
					local dead = enemy:FindFirstChild("Dead")
					if part and (not dead or dead.Value ~= true) then
						local dist = (hrp.Position - part.Position).Magnitude
						if dist <= 500 then
							pcall(function()
								ReplicatedStorage.Events.Other.Ability:InvokeServer("Weapon")
							end)
						end
					end
				end
			end
		end
	end)
end

-- Utility: Stat GUI
local __StatGui = { gui=nil, running=false }
local function ToggleStatGui(on)
	config.StatGui = on; saveConfig()
	getgenv().StatGui = on
	if not on then
		__StatGui.running=false
		if __StatGui.gui then pcall(function() __StatGui.gui:Destroy() end); __StatGui.gui=nil end
		return
	end
	task.spawn(function()
		local LocalPlayer = Players.LocalPlayer
		local ReplicatedStorage = game:GetService("ReplicatedStorage")
		local function formatNumber(n)
			n = tonumber(n) or 0
			if n >= 1e18 then return string.format('%.3f', n/1e18).."Qn" end
			if n >= 1e15 then return string.format('%.3f', n/1e15).."Qd" end
			if n >= 1e12 then return string.format('%.3f', n/1e12).."T" end
			if n >= 1e9  then return string.format('%.3f', n/1e9 ).."B" end
			if n >= 1e6  then return string.format('%.3f', n/1e6 ).."M" end
			if n >= 1e3  then return string.format('%.3f', n/1e3 ).."K" end
			return tostring(n)
		end
		local function darkenColor(color, amount)
			return Color3.fromRGB(
				math.clamp(color.R * 255 - amount, 0, 255),
				math.clamp(color.G * 255 - amount, 0, 255),
				math.clamp(color.B * 255 - amount, 0, 255)
			)
		end
		local statColors = {
			Power = Color3.fromRGB(220, 60, 60),
			Health = Color3.fromRGB(100, 220, 100),
			Defense = Color3.fromRGB(100, 150, 220),
			Psychic = Color3.fromRGB(140, 50, 180),
			Magic = Color3.fromRGB(210, 140, 255),
			Mobility = Color3.fromRGB(240, 240, 80),
		}
		local screenGui = Instance.new("ScreenGui")
		screenGui.Name = "StatsGUI"
		screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
		__StatGui.gui = screenGui
		local statsFrame = Instance.new("Frame")
		statsFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
		statsFrame.BorderSizePixel = 1
		statsFrame.BorderColor3 = Color3.fromRGB(50, 50, 50)
		statsFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
		statsFrame.Size = UDim2.new(0, 500, 0, 350)
		statsFrame.Parent = screenGui
		statsFrame.Active = true
		statsFrame.Draggable = true
		local stroke = Instance.new("UIStroke"); stroke.Parent = statsFrame; stroke.Thickness = 2; stroke.Color = Color3.fromRGB(70, 70, 70)
		local corner = Instance.new("UICorner"); corner.CornerRadius = UDim.new(0, 12); corner.Parent = statsFrame
		local layout = Instance.new("UIListLayout"); layout.Parent = statsFrame; layout.SortOrder = Enum.SortOrder.LayoutOrder; layout.Padding = UDim.new(0, 4); layout.HorizontalAlignment = Enum.HorizontalAlignment.Center; layout.FillDirection = Enum.FillDirection.Vertical; layout.VerticalAlignment = Enum.VerticalAlignment.Top
		local paddingTop = Instance.new("UIPadding"); paddingTop.PaddingTop = UDim.new(0, 10); paddingTop.PaddingBottom = UDim.new(0, 10); paddingTop.PaddingLeft = UDim.new(0, 10); paddingTop.PaddingRight = UDim.new(0, 10); paddingTop.Parent = statsFrame
		local currentBoxWidth, perHourBoxWidth, boxHeight, rowPadding = 280, 160, 55, 5
		local function createStatRow(name, color)
			local row = Instance.new("Frame"); row.Size = UDim2.new(0, currentBoxWidth + perHourBoxWidth + rowPadding, 0, boxHeight); row.BackgroundTransparency = 1; row.Parent = statsFrame
			local rowLayout = Instance.new("UIListLayout"); rowLayout.FillDirection = Enum.FillDirection.Horizontal; rowLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center; rowLayout.SortOrder = Enum.SortOrder.LayoutOrder; rowLayout.Padding = UDim.new(0, rowPadding); rowLayout.Parent = row
			local function makeBox(width, isCurrent)
				local box = Instance.new("Frame"); box.Size = UDim2.new(0, width, 1, 0); box.BackgroundColor3 = darkenColor(color, 80)
				local boxCorner = Instance.new("UICorner"); boxCorner.CornerRadius = UDim.new(0, 8); boxCorner.Parent = box
				local boxStroke = Instance.new("UIStroke"); boxStroke.Parent = box; boxStroke.Color = Color3.fromRGB(60, 60, 60); boxStroke.Thickness = 1
				local label = Instance.new("TextLabel"); label.Size = UDim2.new(1, -12, 1, 0); label.Position = UDim2.new(0, 6, 0, 0); label.BackgroundTransparency = 1; label.TextColor3 = color; label.Font = Enum.Font.GothamBold; label.TextSize = 28; label.Text = isCurrent and (name .. ": 0") or "0/h"; label.TextXAlignment = Enum.TextXAlignment.Left; label.TextYAlignment = Enum.TextYAlignment.Center; label.Parent = box
				box.Parent = row
				return label
			end
			local currentLabel = makeBox(currentBoxWidth, true)
			local perHourLabel = makeBox(perHourBoxWidth, false)
			return currentLabel, perHourLabel
		end
		local powerLabel, powerPerHour = createStatRow("Power", statColors.Power)
		local healthLabel, healthPerHour = createStatRow("Health", statColors.Health)
		local defenseLabel, defensePerHour = createStatRow("Defense", statColors.Defense)
		local psychicLabel, psychicPerHour = createStatRow("Psychic", statColors.Psychic)
		local magicLabel, magicPerHour = createStatRow("Magic", statColors.Magic)
		local mobilityLabel, mobilityPerHour = createStatRow("Mobility", statColors.Mobility)
		layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			local frameWidth = currentBoxWidth + perHourBoxWidth + rowPadding + 20
			local frameHeight = layout.AbsoluteContentSize.Y + 20
			statsFrame.Size = UDim2.new(0, frameWidth, 0, frameHeight)
			statsFrame.Position = UDim2.new(0.5, -frameWidth/2, 0.5, -frameHeight/2)
		end)
		local function fetchStats()
			local statsFolder = ReplicatedStorage:WaitForChild("Data"):WaitForChild(LocalPlayer.Name):WaitForChild("Stats")
			return {
				Power = statsFolder.Power and statsFolder.Power.Value or 0,
				Health = statsFolder.Health and statsFolder.Health.Value or 0,
				Defense = statsFolder.Defense and statsFolder.Defense.Value or 0,
				Psychic = statsFolder.Psychics and statsFolder.Psychics.Value or 0,
				Magic = statsFolder.Magic and statsFolder.Magic.Value or 0,
				Mobility = statsFolder.Mobility and statsFolder.Mobility.Value or 0
			}
		end
		local history, historyDuration = {}, 600
		__StatGui.running = true
		while __StatGui.running and getgenv().StatGui and __StatGui.gui do
			local now = os.clock()
			local stats = fetchStats()
			table.insert(history, {time = now, stats = stats})
			while #history > 0 and (now - history[1].time > historyDuration) do table.remove(history, 1) end
			local perHour = {}
			if #history > 1 then
				local first = history[1]; local elapsed = now - first.time
				for statName, value in pairs(stats) do
					local gained = value - (first.stats[statName] or 0)
					perHour[statName] = gained * (3600 / math.max(elapsed, 1))
				end
			end
			powerLabel.Text = "Power: " .. formatNumber(stats.Power); powerPerHour.Text = formatNumber(perHour.Power or 0) .. "/h"
			healthLabel.Text = "Health: " .. formatNumber(stats.Health); healthPerHour.Text = formatNumber(perHour.Health or 0) .. "/h"
			defenseLabel.Text = "Defense: " .. formatNumber(stats.Defense); defensePerHour.Text = formatNumber(perHour.Defense or 0) .. "/h"
			psychicLabel.Text = "Psychic: " .. formatNumber(stats.Psychic); psychicPerHour.Text = formatNumber(perHour.Psychic or 0) .. "/h"
			magicLabel.Text = "Magic: " .. formatNumber(stats.Magic); magicPerHour.Text = formatNumber(perHour.Magic or 0) .. "/h"
			mobilityLabel.Text = "Mobility: " .. formatNumber(stats.Mobility); mobilityPerHour.Text = formatNumber(perHour.Mobility or 0) .. "/h"
			task.wait(0.5)
		end
		if __StatGui.gui then pcall(function() __StatGui.gui:Destroy() end) end
		__StatGui.gui=nil
	end)
end

-- Auto Ability toggles (every 0.5s)
local __AutoAbility = { inv=nil, res=nil, fly=nil }
local function ToggleAutoInvisible(on)
	config.AutoInvisible = on; saveConfig()
	getgenv().AutoInvisible = on
	if __AutoAbility.inv then __AutoAbility.inv:Disconnect(); __AutoAbility.inv=nil end
	if not on then return end
	local ability = getEvent('Events','Other','Ability')
	__AutoAbility.inv = RS.Heartbeat:Connect(function(step)
		local plr = LocalPlayer
		local tv = plr:FindFirstChild("TempValues") or plr:FindFirstChild("tempValues") or plr:FindFirstChildWhichIsA("Folder")
		local flag = tv and tv:FindFirstChild("IsInvisible")
		if not (flag and flag.Value == true) then
			pcall(function() ability:InvokeServer("Invisibility", Vector3.new(1936.171142578125, 56.015625, -1960.4375)) end)
		end
	end)
end
local function ToggleAutoResize(on)
	config.AutoResize = on; saveConfig()
	getgenv().AutoResize = on
	if __AutoAbility.res then __AutoAbility.res:Disconnect(); __AutoAbility.res=nil end
	if not on then return end
	local ability = getEvent('Events','Other','Ability')
	__AutoAbility.res = RS.Heartbeat:Connect(function(step)
		local plr = LocalPlayer
		local tv = plr:FindFirstChild("TempValues") or plr:FindFirstChild("tempValues") or plr:FindFirstChildWhichIsA("Folder")
		local flag = tv and tv:FindFirstChild("IsResized")
		if not (flag and flag.Value == true) then
			pcall(function() ability:InvokeServer("Resize", Vector3.new(1936.959228515625, 56.015625, -1974.80908203125)) end)
		end
	end)
end
local function ToggleAutoFly(on)
	config.AutoFly = on; saveConfig()
	getgenv().AutoFly = on
	if __AutoAbility.fly then __AutoAbility.fly:Disconnect(); __AutoAbility.fly=nil end
	if not on then return end
	local ability = getEvent('Events','Other','Ability')
	__AutoAbility.fly = RS.Heartbeat:Connect(function(step)
		local plr = LocalPlayer
		local tv = plr:FindFirstChild("TempValues") or plr:FindFirstChild("tempValues") or plr:FindFirstChildWhichIsA("Folder")
		local flag = tv and tv:FindFirstChild("IsFlying")
		if not (flag and flag.Value == true) then
			pcall(function() ability:InvokeServer("Fly", Vector3.new(1932.461181640625, 56.015625, -1965.3206787109375)) end)
		end
	end)
end

-- Sections and toggles

-- Combat (scrollable)
local CombatSection = CreateSection(CombatScroll,'FireBall Aimbot')
make('TextLabel',{Size=UDim2.new(1, -12, 0, 22),BackgroundTransparency=1,Text='FireBall Aimbot',TextColor3=Color3.fromRGB(235,235,245),TextXAlignment=Enum.TextXAlignment.Left,TextScaled=true,Font=Enum.Font.GothamBold},CombatSection)
CreateToggle(CombatSection,'Universal FireBall Aimbot','UniversalFireBallAimbot',ToggleUniversalAimbot)
CreateSlider(CombatSection,'Universal Fireball Cooldown','universalFireballInterval',0.05,1.0,1.0,function() end)
CreateToggle(CombatSection,'FireBall Aimbot Catacombs Preset','FireBallAimbot',ToggleCatacombsAimbot)
CreateSlider(CombatSection,'Fireball Cooldown','fireballCooldown',0.05,1.0,0.1,function() end)
CreateToggle(CombatSection,'FireBall Aimbot City Preset','FireBallAimbotCity',ToggleCityAimbot)
CreateSlider(CombatSection,'City Fireball Cooldown','cityFireballCooldown',0.05,1.0,0.5,function() end)
make('TextLabel',{Size=UDim2.new(1, -12, 0, 22),BackgroundTransparency=1,Text='Panic',TextColor3=Color3.fromRGB(235,235,245),TextXAlignment=Enum.TextXAlignment.Left,TextScaled=true,Font=Enum.Font.GothamBold},CombatSection)
CreateToggle(CombatSection,'Smart Panic','SmartPanic',function(on) config.SmartPanic=on; getgenv().SmartPanic=on; saveConfig() end)
make('TextLabel',{Size=UDim2.new(1, -12, 0, 22),BackgroundTransparency=1,Text='Pvp',TextColor3=Color3.fromRGB(235,235,245),TextXAlignment=Enum.TextXAlignment.Left,TextScaled=true,Font=Enum.Font.GothamBold},CombatSection)
CreateToggle(CombatSection,'Kill Aura','KillAura',ToggleKillAura)

-- Movement
local MovementSection = CreateSection(MovementTab,'Movement Features')
CreateToggle(MovementSection,'No Clip','NoClip',ToggleNoClip)

-- Utility (scrollable)
local UtilitySection = CreateSection(UtilityScroll,'Utility Features')
make('TextLabel',{Size=UDim2.new(1, -12, 0, 22),BackgroundTransparency=1,Text='Optimizations',TextColor3=Color3.fromRGB(235,235,245),TextXAlignment=Enum.TextXAlignment.Left,TextScaled=true,Font=Enum.Font.GothamBold},UtilitySection)
CreateToggle(UtilitySection,'Ultimate AFK Optimization','UltimateAFKOptimization',ToggleUltimateAFK)
CreateToggle(UtilitySection,'AFK Optimization','GraphicsOptimization',ToggleAFKOpt)
CreateToggle(UtilitySection,'Graphics Optimization','GraphicsOptimizationAdvanced',ToggleGraphicsOptAdvanced)
CreateToggle(UtilitySection,'Remove Map Clutter','RemoveMapClutter',function(on) if on then RunRemoveMapClutter() end end)
make('TextLabel',{Size=UDim2.new(1, -12, 0, 22),BackgroundTransparency=1,Text='Webhooks',TextColor3=Color3.fromRGB(235,235,245),TextXAlignment=Enum.TextXAlignment.Left,TextScaled=true,Font=Enum.Font.GothamBold},UtilitySection)
CreateToggle(UtilitySection,'Death Webhook','DeathWebhook',function(on) config.DeathWebhook=on; saveConfig() end)
CreateToggle(UtilitySection,'Panic Webhook','PanicWebhook',function(on) config.PanicWebhook=on; saveConfig() end)
CreateToggle(UtilitySection,'Stat Webhook (15m)','StatWebhook15m',ToggleStatWebhook15m)

-- Server Hop
make('TextLabel',{Size=UDim2.new(1, -12, 0, 22),BackgroundTransparency=1,Text='Server Hop',TextColor3=Color3.fromRGB(235,235,245),TextXAlignment=Enum.TextXAlignment.Left,TextScaled=true,Font=Enum.Font.GothamBold},UtilitySection)
CreateButton(UtilitySection,'Find Low Server',function()
	local HttpService = game:GetService("HttpService")
	local TeleportService = game:GetService("TeleportService")
	local plrs = game:GetService("Players")
	local localPlayer = plrs.LocalPlayer
	local function findLowestPopulationServer()
		local placeId = game.PlaceId
		local currentJob = game.JobId
		local best = nil
		local cursor = nil
		while true do
			local url = string.format("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=100%s", placeId, cursor and ("&cursor=" .. cursor) or "")
			local ok, body = pcall(function() return game:HttpGet(url) end)
			if not ok then break end
			local data = HttpService:JSONDecode(body)
			if not data or not data.data then break end
			for _, srv in ipairs(data.data) do
				if srv.id ~= currentJob and srv.playing < srv.maxPlayers then
					if (not best) or srv.playing < best.playing then
						best = srv
						if best.playing <= 1 then return best end
					end
				end
			end
			cursor = data.nextPageCursor
			if not cursor then break end
			task.wait(0.1)
		end
		return best
	end
	local target = findLowestPopulationServer()
	if target then TeleportService:TeleportToPlaceInstance(game.PlaceId, target.id, localPlayer) else warn("No suitable server found to hop to.") end
end)

-- Auto Ability
make('TextLabel',{Size=UDim2.new(1, -12, 0, 22),BackgroundTransparency=1,Text='Auto Ability',TextColor3=Color3.fromRGB(235,235,245),TextXAlignment=Enum.TextXAlignment.Left,TextScaled=true,Font=Enum.Font.GothamBold},UtilitySection)
CreateToggle(UtilitySection,'Auto Invisible','AutoInvisible',ToggleAutoInvisible)
CreateToggle(UtilitySection,'Auto Resize','AutoResize',ToggleAutoResize)
CreateToggle(UtilitySection,'Auto Fly','AutoFly',ToggleAutoFly)

-- Stat Gui
make('TextLabel',{Size=UDim2.new(1, -12, 0, 22),BackgroundTransparency=1,Text='Stat Gui',TextColor3=Color3.fromRGB(235,235,245),TextXAlignment=Enum.TextXAlignment.Left,TextScaled=true,Font=Enum.Font.GothamBold},UtilitySection)
CreateToggle(UtilitySection,'Stat Gui','StatGui',ToggleStatGui)

-- Visual
local VisualSection = CreateSection(VisualTab,'Visual Features')
CreateToggle(VisualSection,'Player ESP','PlayerESP',TogglePlayerESP)
CreateToggle(VisualSection,'Mob ESP','MobESP',ToggleMobESP)

-- Quests
local QuestsSection = CreateSection(QuestsTab,'Quest Automation')
CreateToggle(QuestsSection,'Dishes Side Task','AutoWashDishes',ToggleAutoWashDishes)
CreateToggle(QuestsSection,'Ninja Side Task','AutoNinjaSideTask',ToggleNinjaSide)
CreateToggle(QuestsSection,'Animatronics Side Task','AutoAnimatronicsSideTask',ToggleAnimSide)
CreateToggle(QuestsSection,'Mutants Side Task','AutoMutantsSideTask',ToggleMutantsSide)

-- Shops
local ShopsSection = CreateSection(ShopsTab,'Shop Automation')
CreateToggle(ShopsSection,'Dual Exotic Shop','DualExoticShop',ToggleDualExoticShop)
CreateToggle(ShopsSection,'Vending Machine','VendingPotionAutoBuy',ToggleVending)

-- Config
local ConfigSection = CreateSection(ConfigTab,'Configuration')
local SaveButton = CreateButton(ConfigSection,'Save Config',function() saveConfig() end)
local LoadButton = CreateButton(ConfigSection,'Load Config',function()
	if loadConfig()~=nil then
		local function applyDiff(flag, getter, toggler) if getter()~=flag then toggler(flag) end end
		applyDiff(config.NoClip,function() return getgenv().NoClip or false end,ToggleNoClip)
		applyDiff(config.GraphicsOptimization,function() return getgenv().GraphicsOptimization or false end,ToggleAFKOpt)
		applyDiff(config.GraphicsOptimizationAdvanced,function() return getgenv().GraphicsOptimizationAdvanced or false end,ToggleGraphicsOptAdvanced)
		applyDiff(config.UltimateAFKOptimization,function() return config.UltimateAFKOptimization end,ToggleUltimateAFK)
		applyDiff(config.PlayerESP,function() return getgenv().PlayerESP or false end,TogglePlayerESP)
		applyDiff(config.MobESP,function() return getgenv().MobESP or false end,ToggleMobESP)
		applyDiff(config.UniversalFireBallAimbot,function() return getgenv().UniversalFireBallAimbot or false end,ToggleUniversalAimbot)
		applyDiff(config.FireBallAimbot,function() return getgenv().FireBallAimbot or false end,ToggleCatacombsAimbot)
		applyDiff(config.FireBallAimbotCity,function() return getgenv().FireBallAimbotCity or false end,ToggleCityAimbot)
		applyDiff(config.AutoWashDishes,function() return getgenv().AutoWashDishes or false end,ToggleAutoWashDishes)
		applyDiff(config.AutoNinjaSideTask,function() return getgenv().AutoNinjaSideTask or false end,ToggleNinjaSide)
		applyDiff(config.AutoAnimatronicsSideTask,function() return getgenv().AutoAnimatronicsSideTask or false end,ToggleAnimSide)
		applyDiff(config.AutoMutantsSideTask,function() return getgenv().AutoMutantsSideTask or false end,ToggleMutantsSide)
		applyDiff(config.DualExoticShop,function() return getgenv().DualExoticShop or false end,ToggleDualExoticShop)
		applyDiff(config.VendingPotionAutoBuy,function() return getgenv().VendingPotionAutoBuy or false end,ToggleVending)
		applyDiff(config.StatWebhook15m,function() return getgenv().StatWebhook15m or false end,ToggleStatWebhook15m)
		applyDiff(config.KillAura,function() return getgenv().KillAura or false end,ToggleKillAura)
		applyDiff(config.StatGui,function() return getgenv().StatGui or false end,ToggleStatGui)
		applyDiff(config.AutoInvisible,function() return getgenv().AutoInvisible or false end,ToggleAutoInvisible)
		applyDiff(config.AutoResize,function() return getgenv().AutoResize or false end,ToggleAutoResize)
		applyDiff(config.AutoFly,function() return getgenv().AutoFly or false end,ToggleAutoFly)
		getgenv().SmartPanic = config.SmartPanic and true or false
	end
end)
SaveButton.Position = UDim2.new(0,0,0,0)
LoadButton.Position = UDim2.new(0,270,0,0)
local SetHideKeyButton = CreateButton(ConfigSection, "Set Hide Key ("..(config.HideGUIKey or 'RightControl')..")", function() awaitingHideKeyCapture=true; SetHideKeyButton.Text='Press any key...' end)
SetHideKeyButtonRef = SetHideKeyButton
SetHideKeyButton.Position = UDim2.new(0,540,0,0)

-- Dragging
local dragging, dragInput, dragStart, startPos
local function updateDrag(input)
	local delta = input.Position - dragStart
	MainFrame.Position = UDim2.new(startPos.X.Scale,startPos.X.Offset+delta.X,startPos.Y.Scale,startPos.Y.Offset+delta.Y)
	Shadow.Position = UDim2.new(0, MainFrame.Position.X.Offset-10, 0, MainFrame.Position.Y.Offset-10)
end
TitleBar.InputBegan:Connect(function(input)
	if input.UserInputType==Enum.UserInputType.MouseButton1 then
		dragging=true; dragStart=input.Position; startPos=MainFrame.Position
		input.Changed:Connect(function() if input.UserInputState==Enum.UserInputState.End then dragging=false end end)
	end
end)
TitleBar.InputChanged:Connect(function(input) if input.UserInputType==Enum.UserInputType.MouseMovement then dragInput=input end end)
UIS.InputChanged:Connect(function(input) if input==dragInput and dragging then updateDrag(input) end end)
