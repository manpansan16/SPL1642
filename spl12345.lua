print("=== SCRIPT STARTING ===")
task.wait(10)
print("Task wait completed")

print("Loading services...")
-- Services
local UIS = game:GetService('UserInputService')
local RS = game:GetService('RunService')
local HttpService = game:GetService('HttpService')
local Lighting = game:GetService('Lighting')
local Players = game:GetService('Players')
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
print("Services loaded successfully")

print("Setting up webhook...")
-- Webhook (reads from loader)
local WEBHOOK_URL = (getgenv and getgenv().Webhook) or ""
local WEBHOOK_PING_ID = (getgenv and getgenv().UserID) or ""
print("Webhook URL:", WEBHOOK_URL)
print("User ID:", WEBHOOK_PING_ID)

print("Creating request function...")
local function getRequestFunc()
	return (syn and syn.request)
		or (http and http.request)
		or (getgenv and getgenv().request)
		or http_request
		or (fluxus and fluxus.request)
end
print("Request function created")

print("Setting up webhook functions...")
local function postWebhook(usernameLabel, titleText, descText, mentionUserId)
	if not WEBHOOK_URL or WEBHOOK_URL == '' then 
		print("No webhook URL, skipping")
		return 
	end
	local request = getRequestFunc()
	if not request then
		print("No HTTP request function available")
		return
	end
	local contentText, allowedUsers = nil, {}
	if mentionUserId and tostring(mentionUserId) ~= '' then
		contentText = '<@' .. tostring(mentionUserId) .. '>'
		allowedUsers = { tostring(mentionUserId) }
	end
	local payload = {
		username = usernameLabel,
		content = contentText,
		embeds = {
			{
				title = titleText,
				description = descText,
				color = 16711680,
				footer = { text = 'Roblox • ' .. os.date('%H:%M') },
			},
		},
		allowed_mentions = { parse = {}, users = allowedUsers },
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
print("Webhook functions created")

print("Setting up death/panic webhooks...")
local function sendDeathWebhook(playerName, killerName)
	postWebhook('Death Bot', '⚠️ Player Killed!', playerName .. ' was killed.', WEBHOOK_PING_ID)
end

local function sendPanicWebhook(playerName)
	postWebhook('Panic Bot', 'Panic Activated', playerName .. ' Triggered Panic', WEBHOOK_PING_ID)
end
print("Death/panic webhooks created")

print("Setting up number formatter...")
-- number formatter (k/m/b/t/qd)
local function formatNumber(n)
	n = tonumber(n) or 0
	local abs = math.abs(n)
	if abs >= 1e15 then return (string.format('%.2f', n/1e15):gsub('%.?0+$',''))..'qd' end
	if abs >= 1e12 then return (string.format('%.2f', n/1e12):gsub('%.?0+$',''))..'t' end
	if abs >= 1e9  then return (string.format('%.2f', n/1e9 ):gsub('%.?0+$',''))..'b' end
	if abs >= 1e6  then return (string.format('%.2f', n/1e6 ):gsub('%.?0+$',''))..'m' end
	if abs >= 1e3  then return (string.format('%.2f', n/1e3 ):gsub('%.?0+$',''))..'k' end
	return tostring(n)
end
print("Number formatter created")

print("Setting up stat webhook...")
-- Stat Webhook (no ping)
local statWebhookRunning = false
local function startStatWebhook()
	if statWebhookRunning then return end
	statWebhookRunning = true
	
	print("Stat webhook started")
	
	local statFolder = ReplicatedStorage:WaitForChild("Data", 10)
	if not statFolder then
		print("Stat folder not found")
		return
	end
	
	local playerData = statFolder:FindFirstChild(LocalPlayer.Name)
	if not playerData then
		print("Player data not found")
		return
	end
	
	local stats = playerData:FindFirstChild("Stats")
	if not stats then
		print("Stats not found")
		return
	end
	
	local oldPower = stats:FindFirstChild("Power") and stats.Power.Value or 0
	local oldDefense = stats:FindFirstChild("Defense") and stats.Defense.Value or 0
	local oldHealth = stats:FindFirstChild("Health") and stats.Health.Value or 0
	local oldMagic = stats:FindFirstChild("Magic") and stats.Magic.Value or 0
	local oldPsy = stats:FindFirstChild("Psychics") and stats.Psychics.Value or 0
	
	print("Initial stats recorded:", oldPower, oldDefense, oldHealth, oldMagic, oldPsy)
	
	task.spawn(function()
		while getgenv().StatWebhook and statWebhookRunning do
			task.wait(900) -- 15 minutes
			
			if not statFolder.Parent or not playerData.Parent or not stats.Parent then
				print("Stat structure changed, stopping webhook")
				break
			end
			
			local newPower = stats:FindFirstChild("Power") and stats.Power.Value or 0
			local newDefense = stats:FindFirstChild("Defense") and stats.Defense.Value or 0
			local newHealth = stats:FindFirstChild("Health") and stats.Health.Value or 0
			local newMagic = stats:FindFirstChild("Magic") and stats.Magic.Value or 0
			local newPsy = stats:FindFirstChild("Psychics") and stats.Psychics.Value or 0
			
			local powerGained = newPower - oldPower
			local defenseGained = newDefense - oldDefense
			local healthGained = newHealth - oldHealth
			local magicGained = newMagic - oldMagic
			local psyGained = newPsy - oldPsy
			
			if powerGained > 0 or defenseGained > 0 or healthGained > 0 or magicGained > 0 or psyGained > 0 then
				local title = LocalPlayer.Name .. " Stats Gained Last 15 Minutes"
				local desc = "**Power Gained:** " .. formatNumber(powerGained) .. "\n**Defense Gained:** " .. formatNumber(defenseGained) .. "\n**Health Gained:** " .. formatNumber(healthGained) .. "\n**Magic Gained:** " .. formatNumber(magicGained) .. "\n**Psychics Gained:** " .. formatNumber(psyGained)
				
				pcall(function()
					postWebhook('Stat Bot', title, desc, nil)
				end)
				
				oldPower = newPower
				oldDefense = newDefense
				oldHealth = newHealth
				oldMagic = newMagic
				oldPsy = newPsy
				
				print("Stat webhook sent")
			end
		end
		statWebhookRunning = false
		print("Stat webhook stopped")
	end)
end

local function stopStatWebhook()
	statWebhookRunning = false
	getgenv().StatWebhook = false
	print("Stat webhook stopped manually")
end
print("Stat webhook functions created")

print("Setting up config...")
-- Config
local config = {
	FireBallAimbot = false,
	FireBallAimbotCity = false,
	UniversalFireBallAimbot = false,
	SmartPanic = false,
	DeathWebhook = true,
	PanicWebhook = false,
	StatWebhook = false,
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
	AutoBuyPotions = false,
	VendingPotionAutoBuy = false,
	RemoveMapClutter = false,
	fireballCooldown = 0.1,
	cityFireballCooldown = 0.5,
	universalFireballInterval = 1.0,
	HideGUIKey = 'RightControl',
	WebhookMentionId = '',
}
print("Config created")

print("Setting up config save/load...")
-- Config save/load
local function saveConfig()
	local success = pcall(function()
		local data = HttpService:JSONEncode(config)
		writefile('SuperPowerLeague_Config.json', data)
	end)
	return success
end

local function loadConfig()
	local success = pcall(function()
		if isfile('SuperPowerLeague_Config.json') then
			local data = readfile('SuperPowerLeague_Config.json')
			local loaded = HttpService:JSONDecode(data)
			for k, v in pairs(loaded) do
				if config[k] ~= nil then
					config[k] = v
				end
			end
		end
	end)
	return success
end
print("Config save/load functions created")

print("Loading saved config...")
loadConfig()
print("Config loaded")

print("Setting up target helpers...")
-- Target helpers
local function getSpawnFolderPositions()
	local targets = {}
	local spawnFolder = workspace:FindFirstChild('SpawnFolder')
	if spawnFolder then
		for _, child in ipairs(spawnFolder:GetChildren()) do
			if child:IsA('BasePart') then
				table.insert(targets, child.Position)
			end
		end
	end
	return targets
end

local function getCitySpawnFolderPositions()
	local targets = {}
	local citySpawnFolder = workspace:FindFirstChild('CitySpawnFolder')
	if citySpawnFolder then
		for _, child in ipairs(citySpawnFolder:GetChildren()) do
			if child:IsA('BasePart') then
				table.insert(targets, child.Position)
			end
		end
	end
	return targets
end
print("Target helpers created")

print("Setting up fireball aimbot functions...")
-- Fireball Aimbot Functions
local function getClosestPlayer()
	local players = Players:GetPlayers()
	local closestPlayer = nil
	local shortestDistance = math.huge
	local playerPos = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild('HumanoidRootPart') and LocalPlayer.Character.HumanoidRootPart.Position
	
	if not playerPos then return nil end
	
	for _, player in ipairs(players) do
		if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild('HumanoidRootPart') then
			local distance = (player.Character.HumanoidRootPart.Position - playerPos).Magnitude
			if distance < shortestDistance then
				shortestDistance = distance
				closestPlayer = player
			end
		end
	end
	return closestPlayer
end

local function getClosestMob()
	local enemies = workspace:FindFirstChild('Enemies')
	if not enemies then return nil end
	
	local closestMob = nil
	local shortestDistance = math.huge
	local playerPos = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild('HumanoidRootPart') and LocalPlayer.Character.HumanoidRootPart.Position
	
	if not playerPos then return nil end
	
	for _, enemyFolder in ipairs(enemies:GetChildren()) do
		if tonumber(enemyFolder.Name) then
			for _, enemy in ipairs(enemyFolder:GetChildren()) do
				if enemy:IsA('Model') and enemy:FindFirstChild('HumanoidRootPart') then
					local distance = (enemy.HumanoidRootPart.Position - playerPos).Magnitude
					if distance < shortestDistance then
						shortestDistance = distance
						closestMob = enemy
					end
				end
			end
		end
	end
	return closestMob
end

local function fireFireball(target)
	if not target or not target:FindFirstChild('HumanoidRootPart') then return end
	
	local args = {
		[1] = "Fireball",
		[2] = target.HumanoidRootPart.Position
	}
	
	ReplicatedStorage:WaitForChild("Events", 10):WaitForChild("Combat", 10):FireServer(unpack(args))
end
print("Fireball functions created")

print("Setting up aimbot loops...")
-- Aimbot Loops
local function startFireballAimbot()
	if getgenv().FireBallAimbot then return end
	getgenv().FireBallAimbot = true
	
	print("Fireball aimbot started")
	
	task.spawn(function()
		while getgenv().FireBallAimbot do
			local target = getClosestPlayer()
			if target then
				fireFireball(target)
			end
			task.wait(config.fireballCooldown)
		end
	end)
end

local function startCityFireballAimbot()
	if getgenv().FireBallAimbotCity then return end
	getgenv().FireBallAimbotCity = true
	
	print("City fireball aimbot started")
	
	task.spawn(function()
		while getgenv().FireBallAimbotCity do
			local target = getClosestMob()
			if target then
				fireFireball(target)
			end
			task.wait(config.cityFireballCooldown)
		end
	end)
end

local function startUniversalFireballAimbot()
	if getgenv().UniversalFireBallAimbot then return end
	getgenv().UniversalFireBallAimbot = true
	
	print("Universal fireball aimbot started")
	
	task.spawn(function()
		while getgenv().UniversalFireBallAimbot do
			local target = getClosestMob()
			if not target then
				target = getClosestPlayer()
			end
			if target then
				fireFireball(target)
			end
			task.wait(config.universalFireballInterval)
		end
	end)
end

local function stopAllAimbots()
	getgenv().FireBallAimbot = false
	getgenv().FireBallAimbotCity = false
	getgenv().UniversalFireBallAimbot = false
	print("All aimbots stopped")
end
print("Aimbot loops created")

print("Setting up NoClip...")
-- No Clip (stable, restores original collisions)
local __NoClip = { conn=nil, charConn=nil, descConn=nil, orig={} }

local function ncRecord(part)
	if not __NoClip.orig[part] then
		__NoClip.orig[part] = part.CanCollide
	end
end

local function ncApplyOnPart(part)
	if part:IsA('BasePart') then
		ncRecord(part)
		part.CanCollide = false
	end
end

local function ncApplyAll()
	local char = LocalPlayer.Character
	if not char then return end
	for _, p in ipairs(char:GetDescendants()) do
		ncApplyOnPart(p)
	end
end

local function ncRestoreAll()
	for part, was in pairs(__NoClip.orig) do
		if part and part.Parent then
			part.CanCollide = was
		end
	end
	__NoClip.orig = {}
end

local function ToggleNoClip(enabled)
	getgenv().NoClip = enabled
	if enabled then
		if __NoClip.conn then __NoClip.conn:Disconnect() end
		if __NoClip.charConn then __NoClip.charConn:Disconnect() end
		if __NoClip.descConn then __NoClip.descConn:Disconnect() end
		
		__NoClip.conn = RS.Stepped:Connect(ncApplyAll)
		__NoClip.charConn = LocalPlayer.CharacterAdded:Connect(function()
			task.wait(1)
			ncApplyAll()
		end)
		__NoClip.descConn = LocalPlayer.CharacterAdded:Connect(function(char)
			char.DescendantAdded:Connect(ncApplyOnPart)
		end)
		
		ncApplyAll()
		print("NoClip enabled")
	else
		if __NoClip.conn then __NoClip.conn:Disconnect() __NoClip.conn = nil end
		if __NoClip.charConn then __NoClip.charConn:Disconnect() __NoClip.charConn = nil end
		if __NoClip.descConn then __NoClip.descConn:Disconnect() __NoClip.descConn = nil end
		
		ncRestoreAll()
		print("NoClip disabled")
	end
end
print("NoClip created")

print("Setting up Player ESP...")
-- Player ESP
local function TogglePlayerESP(enabled)
	getgenv().PlayerESP = enabled
	
	if getgenv().__PlayerESPConns then
		for _, c in ipairs(getgenv().__PlayerESPConns) do
			pcall(function() c:Disconnect() end)
		end
	end
	getgenv().__PlayerESPConns = {}
	
	if getgenv().__PlayerESPFolder then
		pcall(function() getgenv().__PlayerESPFolder:Destroy() end)
	end
	
	if not enabled then return end
	
	local holder = Instance.new('Folder')
	holder.Name = 'PlayerESP_Holder'
	holder.Parent = game.CoreGui
	getgenv().__PlayerESPFolder = holder
	
	local function createESP(player)
		if player == LocalPlayer then return end
		
		local esp = Instance.new('BoxHandleAdornment')
		esp.Name = player.Name .. '_ESP'
		esp.Size = Vector3.new(4, 7, 4)
		esp.Color3 = Color3.new(1, 0, 0)
		esp.Transparency = 0.5
		esp.AlwaysOnTop = true
		esp.ZIndex = 10
		esp.Parent = holder
		
		local connection
		connection = RS.Heartbeat:Connect(function()
			if not getgenv().PlayerESP or not player.Character or not player.Character:FindFirstChild('HumanoidRootPart') then
				if connection then connection:Disconnect() end
				if esp then esp:Destroy() end
				return
			end
			
			esp.Adornee = player.Character.HumanoidRootPart
			esp.CFrame = player.Character.HumanoidRootPart.CFrame
		end)
		
		table.insert(getgenv().__PlayerESPConns, connection)
	end
	
	for _, player in ipairs(Players:GetPlayers()) do
		createESP(player)
	end
	
	Players.PlayerAdded:Connect(createESP)
	Players.PlayerRemoving:Connect(function(player)
		local esp = holder:FindFirstChild(player.Name .. '_ESP')
		if esp then esp:Destroy() end
	end)
	
	print("Player ESP enabled")
end
print("Player ESP created")

print("Setting up Mob ESP...")
-- Mob ESP (replaced with working version)
local function ToggleMobESP(enabled)
	getgenv().MobESP = enabled
	
	if getgenv().__MobESPConns then
		for _, c in ipairs(getgenv().__MobESPConns) do
			pcall(function() c:Disconnect() end)
		end
	end
	getgenv().__MobESPConns = {}
	
	if getgenv().__MobESPFolder then
		pcall(function() getgenv().__MobESPFolder:Destroy() end)
	end
	
	if not enabled then return end
	
	local holder = Instance.new('Folder')
	holder.Name = 'MobESP_Holder'
	holder.Parent = game.CoreGui
	getgenv().__MobESPFolder = holder
	
	local function createMobESP(enemy)
		if not enemy or not enemy:IsA('Model') then return end
		
		local esp = Instance.new('BoxHandleAdornment')
		esp.Name = enemy.Name .. '_ESP'
		esp.Size = Vector3.new(4, 7, 4)
		esp.Color3 = Color3.new(0, 1, 0)
		esp.Transparency = 0.5
		esp.AlwaysOnTop = true
		esp.ZIndex = 10
		esp.Parent = holder
		
		local connection
		connection = RS.Heartbeat:Connect(function()
			if not getgenv().MobESP or not enemy.Parent or not enemy:FindFirstChild('HumanoidRootPart') then
				if connection then connection:Disconnect() end
				if esp then esp:Destroy() end
				return
			end
			
			esp.Adornee = enemy.HumanoidRootPart
			esp.CFrame = enemy.HumanoidRootPart.CFrame
		end)
		
		table.insert(getgenv().__MobESPConns, connection)
	end
	
	local enemies = workspace:FindFirstChild('Enemies')
	if enemies then
		for _, enemyFolder in ipairs(enemies:GetChildren()) do
			if tonumber(enemyFolder.Name) then
				for _, enemy in ipairs(enemyFolder:GetChildren()) do
					createMobESP(enemy)
				end
			end
		end
	end
	
	print("Mob ESP enabled")
end
print("Mob ESP created")

print("Setting up graphics optimization...")
-- Graphics Optimization
local function ToggleGraphicsOptimization(enabled)
	getgenv().GraphicsOptimization = enabled
	
	if enabled then
		Lighting.GlobalShadows = false
		Lighting.FogEnd = 9e9
		Lighting.Brightness = 2
		Lighting.ClockTime = 14
		Lighting.Ambient = Color3.new(0.3, 0.3, 0.3)
		Lighting.OutdoorAmbient = Color3.new(0.3, 0.3, 0.3)
		Lighting.ExposureCompensation = 0
		Lighting.ShadowSoftness = 0
		Lighting.EnvironmentDiffuseScale = 0
		Lighting.EnvironmentSpecularScale = 0
		
		for _, obj in ipairs(Lighting:GetChildren()) do
			if obj:IsA('BloomEffect') or obj:IsA('BlurEffect') or obj:IsA('ColorCorrectionEffect') or obj:IsA('SunRaysEffect') then
				obj.Enabled = false
			end
		end
		
		settings().Rendering.QualityLevel = 1
		settings().Physics.PhysicsSendRate = 1
		print("Graphics optimization enabled")
	else
		Lighting.GlobalShadows = true
		Lighting.FogEnd = 786069
		Lighting.Brightness = 1
		Lighting.ClockTime = 12
		Lighting.Ambient = Color3.new(0.2, 0.2, 0.2)
		Lighting.OutdoorAmbient = Color3.new(0.2, 0.2, 0.2)
		Lighting.ExposureCompensation = 0
		Lighting.ShadowSoftness = 0.1
		Lighting.EnvironmentDiffuseScale = 1
		Lighting.EnvironmentSpecularScale = 1
		
		settings().Rendering.QualityLevel = 21
		settings().Physics.PhysicsSendRate = 60
		print("Graphics optimization disabled")
	end
end
print("Graphics optimization created")

print("Setting up advanced graphics optimization...")
-- Advanced Graphics Optimization
local function ToggleAdvancedGraphicsOptimization(enabled)
	getgenv().GraphicsOptimizationAdvanced = enabled
	
	if enabled then
		ToggleGraphicsOptimization(true)
		
		-- Additional optimizations
		Lighting.FogStart = 0
		Lighting.FogEnd = 9e9
		Lighting.ExposureCompensation = -0.5
		
		-- Disable more effects
		for _, obj in ipairs(Lighting:GetChildren()) do
			if obj:IsA('Atmosphere') or obj:IsA('DepthOfFieldEffect') or obj:IsA('DistortionSoundEffect') then
				obj.Enabled = false
			end
		end
		
		print("Advanced graphics optimization enabled")
	else
		ToggleGraphicsOptimization(false)
		print("Advanced graphics optimization disabled")
	end
end
print("Advanced graphics optimization created")

print("Setting up Ultimate AFK Optimization...")
-- Ultimate AFK Optimization
local function ToggleUltimateAFKOptimization(enabled)
	getgenv().UltimateAFKOptimization = enabled
	
	if enabled then
		-- Fast settings
		pcall(function()
			settings().Rendering.QualityLevel = 1
			settings().Physics.PhysicsSendRate = 1
		end)
		
		-- Lighting optimizations
		pcall(function()
			Lighting.Brightness = 2
			Lighting.ClockTime = 14
			Lighting.GlobalShadows = false
			Lighting.ShadowSoftness = 0
			Lighting.EnvironmentDiffuseScale = 0
			Lighting.EnvironmentSpecularScale = 0
			
			for _, obj in ipairs(Lighting:GetChildren()) do
				local c = obj.ClassName
				if c == "BloomEffect" or c == "BlurEffect" or c == "ColorCorrectionEffect" or c == "SunRaysEffect" or c == "Atmosphere" or c == "DepthOfFieldEffect" then
					obj.Enabled = false
				end
			end
		end)
		
		print("Ultimate AFK optimization enabled")
	else
		-- Restore settings
		pcall(function()
			settings().Rendering.QualityLevel = 21
			settings().Physics.PhysicsSendRate = 60
		end)
		
		pcall(function()
			Lighting.Brightness = 1
			Lighting.ClockTime = 12
			Lighting.GlobalShadows = true
			Lighting.ShadowSoftness = 0.1
			Lighting.EnvironmentDiffuseScale = 1
			Lighting.EnvironmentSpecularScale = 1
		end)
		
		print("Ultimate AFK optimization disabled")
	end
end
print("Ultimate AFK optimization created")

print("Setting up Remove Map Clutter...")
-- Remove Map Clutter
local function ToggleRemoveMapClutter(enabled)
	getgenv().RemoveMapClutter = enabled
	
	if enabled then
		-- Store original properties
		if not getgenv().__MapClutterOrig then
			getgenv().__MapClutterOrig = {}
		end
		
		-- Hide decorative objects
		local function hideObject(obj)
			if obj:IsA('BasePart') or obj:IsA('Decal') or obj:IsA('Texture') then
				if not getgenv().__MapClutterOrig[obj] then
					getgenv().__MapClutterOrig[obj] = {
						Transparency = obj.Transparency,
						Visible = obj.Visible
					}
				end
				
				if obj:IsA('BasePart') then
					obj.Transparency = 1
				else
					obj.Visible = false
				end
			end
		end
		
		-- Apply to existing objects
		for _, obj in ipairs(workspace:GetDescendants()) do
			if obj.Name:match("Flower") or obj.Name:match("Tree") or obj.Name:match("Rock") or obj.Name:match("Bush") then
				hideObject(obj)
			end
		end
		
		print("Map clutter removal enabled")
	else
		-- Restore original properties
		if getgenv().__MapClutterOrig then
			for obj, props in pairs(getgenv().__MapClutterOrig) do
				if obj and obj.Parent then
					if props.Transparency then
						obj.Transparency = props.Transparency
					end
					if props.Visible ~= nil then
						obj.Visible = props.Visible
					end
				end
			end
			getgenv().__MapClutterOrig = {}
		end
		
		print("Map clutter removal disabled")
	end
end
print("Remove map clutter created")

print("Setting up quest automation...")
-- Quest Automation
local function startAutoWashDishes()
	if getgenv().AutoWashDishes then return end
	getgenv().AutoWashDishes = true
	
	print("Auto wash dishes started")
	
	task.spawn(function()
		while getgenv().AutoWashDishes do
			pcall(function()
				local player = Players.LocalPlayer
				local humanoid = player.Character and player.Character:FindFirstChild('Humanoid')
				if humanoid and humanoid.Health <= 0 then
					getgenv().AutoWashDishes = false
					config.AutoWashDishes = false
					return
				end
				
				-- Find dish washing station
				local station = workspace:FindFirstChild('DishWashingStation')
				if station then
					-- Teleport to station
					local humanoidRootPart = player.Character and player.Character:FindFirstChild('HumanoidRootPart')
					if humanoidRootPart then
						humanoidRootPart.CFrame = station.CFrame + Vector3.new(0, 3, 0)
					end
					
					-- Wait a bit then teleport back
					task.wait(2)
					if humanoidRootPart then
						humanoidRootPart.CFrame = CFrame.new(0, 100, 0)
					end
				end
				
				task.wait(5)
			end)
		end
	end)
end

local function startAutoNinjaSideTask()
	if getgenv().AutoNinjaSideTask then return end
	getgenv().AutoNinjaSideTask = true
	
	print("Auto ninja side task started")
	
	task.spawn(function()
		while getgenv().AutoNinjaSideTask do
			pcall(function()
				local player = Players.LocalPlayer
				local humanoid = player.Character and player.Character:FindFirstChild('Humanoid')
				if humanoid and humanoid.Health <= 0 then
					getgenv().AutoNinjaSideTask = false
					config.AutoNinjaSideTask = false
					return
				end
				
				ReplicatedStorage:WaitForChild("Events", 9e9):WaitForChild("Other", 9e9):WaitForChild("StartSideTask", 9e9):FireServer(9)
				ReplicatedStorage:WaitForChild("Events", 9e9):WaitForChild("Other", 9e9):WaitForChild("ClaimSideTask", 9e9):FireServer(9)
				
				task.wait(math.random(50, 70))
			end)
		end
	end)
end

local function startAutoAnimatronicsSideTask()
	if getgenv().AutoAnimatronicsSideTask then return end
	getgenv().AutoAnimatronicsSideTask = true
	
	print("Auto animatronics side task started")
	
	task.spawn(function()
		while getgenv().AutoAnimatronicsSideTask do
			pcall(function()
				local player = Players.LocalPlayer
				local humanoid = player.Character and player.Character:FindFirstChild('Humanoid')
				if humanoid and humanoid.Health <= 0 then
					getgenv().AutoAnimatronicsSideTask = false
					config.AutoAnimatronicsSideTask = false
					return
				end
				
				ReplicatedStorage:WaitForChild("Events", 9e9):WaitForChild("Other", 9e9):WaitForChild("StartSideTask", 9e9):FireServer(10)
				ReplicatedStorage:WaitForChild("Events", 9e9):WaitForChild("Other", 9e9):WaitForChild("ClaimSideTask", 9e9):FireServer(10)
				
				task.wait(math.random(50, 70))
			end)
		end
	end)
end

local function startAutoMutantsSideTask()
	if getgenv().AutoMutantsSideTask then return end
	getgenv().AutoMutantsSideTask = true
	
	print("Auto mutants side task started")
	
	task.spawn(function()
		while getgenv().AutoMutantsSideTask do
			pcall(function()
				local player = Players.LocalPlayer
				local humanoid = player.Character and player.Character:FindFirstChild('Humanoid')
				if humanoid and humanoid.Health <= 0 then
					getgenv().AutoMutantsSideTask = false
					config.AutoMutantsSideTask = false
					return
				end
				
				ReplicatedStorage:WaitForChild("Events", 9e9):WaitForChild("Other", 9e9):WaitForChild("StartSideTask", 9e9):FireServer(7)
				ReplicatedStorage:WaitForChild("Events", 9e9):WaitForChild("Other", 9e9):WaitForChild("ClaimSideTask", 9e9):FireServer(7)
				
				task.wait(math.random(50, 70))
			end)
		end
	end)
end

local function stopAllQuestAutomation()
	getgenv().AutoWashDishes = false
	getgenv().AutoNinjaSideTask = false
	getgenv().AutoAnimatronicsSideTask = false
	getgenv().AutoMutantsSideTask = false
	print("All quest automation stopped")
end
print("Quest automation created")

print("Setting up potion automation...")
-- Potion Automation
local function startAutoBuyPotions()
	if getgenv().AutoBuyPotions then return end
	getgenv().AutoBuyPotions = true
	
	print("Auto buy potions started")
	
	task.spawn(function()
		while getgenv().AutoBuyPotions do
			pcall(function()
				local player = Players.LocalPlayer
				local humanoid = player.Character and player.Character:FindFirstChild('Humanoid')
				if humanoid and humanoid.Health <= 0 then
					getgenv().AutoBuyPotions = false
					config.AutoBuyPotions = false
					return
				end
				
				-- Find potion shop
				local shop = workspace:FindFirstChild('PotionShop')
				if shop then
					-- Teleport to shop
					local humanoidRootPart = player.Character and player.Character:FindFirstChild('HumanoidRootPart')
					if humanoidRootPart then
						humanoidRootPart.CFrame = shop.CFrame + Vector3.new(0, 3, 0)
					end
					
					-- Buy potions
					ReplicatedStorage:WaitForChild("Events", 10):WaitForChild("Shop", 10):FireServer("BuyPotion")
					
					-- Wait a bit then teleport back
					task.wait(2)
					if humanoidRootPart then
						humanoidRootPart.CFrame = CFrame.new(0, 100, 0)
					end
				end
				
				task.wait(10)
			end)
		end
	end)
end

local function startVendingPotionAutoBuy()
	if getgenv().VendingPotionAutoBuy then return end
	getgenv().VendingPotionAutoBuy = true
	
	print("Vending potion auto buy started")
	
	task.spawn(function()
		while getgenv().VendingPotionAutoBuy do
			pcall(function()
				local player = Players.LocalPlayer
				local humanoid = player.Character and player.Character:FindFirstChild('Humanoid')
				if humanoid and humanoid.Health <= 0 then
					getgenv().VendingPotionAutoBuy = false
					config.VendingPotionAutoBuy = false
					return
				end
				
				-- Find vending machine
				local vending = workspace:FindFirstChild('VendingMachine')
				if vending then
					-- Teleport to vending machine
					local humanoidRootPart = player.Character and player.Character:FindFirstChild('HumanoidRootPart')
					if humanoidRootPart then
						humanoidRootPart.CFrame = vending.CFrame + Vector3.new(0, 3, 0)
					end
					
					-- Buy from vending machine
					ReplicatedStorage:WaitForChild("Events", 10):WaitForChild("Shop", 10):FireServer("BuyFromVending")
					
					-- Wait a bit then teleport back
					task.wait(2)
					if humanoidRootPart then
						humanoidRootPart.CFrame = CFrame.new(0, 100, 0)
					end
				end
				
				task.wait(10)
			end)
		end
	end)
end

local function stopAllPotionAutomation()
	getgenv().AutoBuyPotions = false
	getgenv().AutoVendingPotionAutoBuy = false
	print("All potion automation stopped")
end
print("Potion automation created")

print("Setting up Smart Panic...")
-- Smart Panic
local function ToggleSmartPanic(enabled)
	getgenv().SmartPanic = enabled
	
	if enabled then
		local function checkHealth()
			local player = Players.LocalPlayer
			local humanoid = player.Character and player.Character:FindFirstChild('Humanoid')
			if humanoid and humanoid.Health < 95 then
				-- Stop all aimbots
				stopAllAimbots()
				
				-- Send panic webhook
				if config.PanicWebhook then
					sendPanicWebhook(player.Name)
				end
				
				-- Disable smart panic
				getgenv().SmartPanic = false
				config.SmartPanic = false
				
				print("Smart panic activated - health below 95%")
			end
		end
		
		RS.Heartbeat:Connect(checkHealth)
		print("Smart panic enabled")
	else
		print("Smart panic disabled")
	end
end
print("Smart panic created")

print("Setting up death and panic watchers...")
-- Death and Panic Watchers
local function initializeDeathAndPanicWatchers()
	local function hookCharacter(char)
		local humanoid = char:WaitForChild('Humanoid', 10)
		if not humanoid then return end
		
		local lastDamager = nil
		local deathSent = false
		local panicArmed = true
		
		humanoid.Died:Connect(function()
			if not deathSent and config.DeathWebhook then
				deathSent = true
				stopAllAimbots()
				sendDeathWebhook(LocalPlayer.Name, lastDamager and lastDamager.Name or "Unknown")
			end
		end)
		
		humanoid.HealthChanged:Connect(function(health)
			if health < 95 and panicArmed and config.PanicWebhook then
				panicArmed = false
				stopAllAimbots()
				sendPanicWebhook(LocalPlayer.Name)
				
				-- Rearm after health recovers
				task.spawn(function()
					while humanoid.Health < 95 do
						task.wait(1)
					end
					panicArmed = true
				end)
			end
		end)
	end
	
	LocalPlayer.CharacterAdded:Connect(hookCharacter)
	if LocalPlayer.Character then
		hookCharacter(LocalPlayer.Character)
	end
	
	print("Death and panic watchers initialized")
end
print("Death and panic watchers created")

print("Setting up teleport functions...")
-- Teleport Functions
local savedPosition = nil

local function saveCurrentPosition()
	local character = LocalPlayer.Character
	if character and character:FindFirstChild('HumanoidRootPart') then
		savedPosition = character.HumanoidRootPart.CFrame
		print("Position saved")
	end
end

local function teleportToSavedPosition()
	if savedPosition then
		local character = LocalPlayer.Character
		if character and character:FindFirstChild('HumanoidRootPart') then
			character.HumanoidRootPart.CFrame = savedPosition
			print("Teleported to saved position")
		end
	else
		print("No saved position")
	end
end

local function teleportToPlayer(playerName)
	local targetPlayer = Players:FindFirstChild(playerName)
	if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild('HumanoidRootPart') then
		local character = LocalPlayer.Character
		if character and character:FindFirstChild('HumanoidRootPart') then
			character.HumanoidRootPart.CFrame = targetPlayer.Character.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
			print("Teleported to " .. playerName)
		end
	else
		print("Player not found: " .. playerName)
	end
end

local function teleportToLocation(locationName)
	local locations = {
		["Spawn"] = CFrame.new(0, 100, 0),
		["City"] = CFrame.new(1000, 100, 1000),
		["Gym"] = CFrame.new(500, 100, 500),
		["Shop"] = CFrame.new(750, 100, 750),
		["Training"] = CFrame.new(250, 100, 250)
	}
	
	local targetLocation = locations[locationName]
	if targetLocation then
		local character = LocalPlayer.Character
		if character and character:FindFirstChild('HumanoidRootPart') then
			character.HumanoidRootPart.CFrame = targetLocation
			print("Teleported to " .. locationName)
		end
	else
		print("Location not found: " .. locationName)
	end
end
print("Teleport functions created")

print("Setting up GUI creation...")
-- GUI Creation
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "NeduCartiHub"
ScreenGui.Parent = game:GetService("CoreGui")

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 400, 0, 500)
MainFrame.Position = UDim2.new(0.5, -200, 0.5, -250)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1, 0, 0, 30)
TitleBar.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Name = "TitleLabel"
TitleLabel.Size = UDim2.new(1, 0, 1, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "Nedu Carti Hub"
TitleLabel.TextColor3 = Color3.new(1, 1, 1)
TitleLabel.TextScaled = true
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.Parent = TitleBar

local TabContainer = Instance.new("Frame")
TabContainer.Name = "TabContainer"
TabContainer.Size = UDim2.new(1, 0, 1, -30)
TabContainer.Position = UDim2.new(0, 0, 0, 30)
TabContainer.BackgroundTransparency = 1
TabContainer.Parent = MainFrame

local TabButtons = Instance.new("Frame")
TabButtons.Name = "TabButtons"
TabButtons.Size = UDim2.new(0, 100, 1, 0)
TabButtons.BackgroundTransparency = 1
TabButtons.Parent = TabContainer

local TabContent = Instance.new("Frame")
TabContent.Name = "TabContent"
TabContent.Size = UDim2.new(1, -100, 1, 0)
TabContent.Position = UDim2.new(0, 100, 0, 0)
TabContent.BackgroundTransparency = 1
TabContent.Parent = TabContainer

print("Basic GUI structure created")

print("Creating tab buttons...")
-- Create Tab Buttons
local tabs = {"Combat", "Quests", "Teleport", "Utility", "Settings"}
local currentTab = "Combat"

local function createTabButton(tabName)
	local button = Instance.new("TextButton")
	button.Name = tabName .. "Tab"
	button.Size = UDim2.new(1, 0, 0, 40)
	button.Position = UDim2.new(0, 0, 0, (table.find(tabs, tabName) - 1) * 40)
	button.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
	button.BorderSizePixel = 0
	button.Text = tabName
	button.TextColor3 = Color3.new(1, 1, 1)
	button.TextScaled = true
	button.Font = Enum.Font.Gotham
	button.Parent = TabButtons
	
	button.MouseButton1Click:Connect(function()
		currentTab = tabName
		updateTabContent()
	end)
	
	return button
end

local function updateTabContent()
	-- Clear existing content
	for _, child in ipairs(TabContent:GetChildren()) do
		child:Destroy()
	end
	
	-- Create content based on current tab
	if currentTab == "Combat" then
		createCombatTab()
	elseif currentTab == "Quests" then
		createQuestsTab()
	elseif currentTab == "Teleport" then
		createTeleportTab()
	elseif currentTab == "Utility" then
		createUtilityTab()
	elseif currentTab == "Settings" then
		createSettingsTab()
	end
end

print("Tab system created")

print("Creating combat tab...")
-- Combat Tab
local function createCombatTab()
	local scrollFrame = Instance.new("ScrollingFrame")
	scrollFrame.Size = UDim2.new(1, 0, 1, 0)
	scrollFrame.BackgroundTransparency = 1
	scrollFrame.ScrollBarThickness = 6
	scrollFrame.Parent = TabContent
	
	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 5)
	layout.Parent = scrollFrame
	
	-- Fireball Aimbot
	local aimbotSection = Instance.new("Frame")
	aimbotSection.Size = UDim2.new(1, 0, 0, 120)
	aimbotSection.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	aimbotSection.BorderSizePixel = 0
	aimbotSection.Parent = scrollFrame
	
	local aimbotTitle = Instance.new("TextLabel")
	aimbotTitle.Size = UDim2.new(1, 0, 0, 25)
	aimbotTitle.BackgroundTransparency = 1
	aimbotTitle.Text = "Fireball Aimbot"
	aimbotTitle.TextColor3 = Color3.new(1, 1, 1)
	aimbotTitle.TextScaled = true
	aimbotTitle.Font = Enum.Font.GothamBold
	aimbotTitle.Parent = aimbotSection
	
	local fireballToggle = Instance.new("TextButton")
	fireballToggle.Size = UDim2.new(0.45, 0, 0, 30)
	fireballToggle.Position = UDim2.new(0.025, 0, 0, 30)
	fireballToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	fireballToggle.BorderSizePixel = 0
	fireballToggle.Text = "Fireball Aimbot"
	fireballToggle.TextColor3 = Color3.new(1, 1, 1)
	fireballToggle.TextScaled = true
	fireballToggle.Font = Enum.Font.Gotham
	fireballToggle.Parent = aimbotSection
	
	local cityToggle = Instance.new("TextButton")
	cityToggle.Size = UDim2.new(0.45, 0, 0, 30)
	cityToggle.Position = UDim2.new(0.525, 0, 0, 30)
	cityToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	cityToggle.BorderSizePixel = 0
	cityToggle.Text = "City Aimbot"
	cityToggle.TextColor3 = Color3.new(1, 1, 1)
	cityToggle.TextScaled = true
	cityToggle.Font = Enum.Font.Gotham
	cityToggle.Parent = aimbotSection
	
	local universalToggle = Instance.new("TextButton")
	universalToggle.Size = UDim2.new(0.45, 0, 0, 30)
	universalToggle.Position = UDim2.new(0.025, 0, 0, 65)
	universalToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	universalToggle.BorderSizePixel = 0
	universalToggle.Text = "Universal Aimbot"
	universalToggle.TextColor3 = Color3.new(1, 1, 1)
	universalToggle.TextScaled = true
	universalToggle.Font = Enum.Font.Gotham
	universalToggle.Parent = aimbotSection
	
	-- Cooldown sliders
	local cooldownSection = Instance.new("Frame")
	cooldownSection.Size = UDim2.new(1, 0, 0, 80)
	cooldownSection.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	cooldownSection.BorderSizePixel = 0
	cooldownSection.Parent = scrollFrame
	
	local cooldownTitle = Instance.new("TextLabel")
	cooldownTitle.Size = UDim2.new(1, 0, 0, 25)
	cooldownTitle.BackgroundTransparency = 1
	cooldownTitle.Text = "Cooldown"
	cooldownTitle.TextColor3 = Color3.new(1, 1, 1)
	cooldownTitle.TextScaled = true
	cooldownTitle.Font = Enum.Font.GothamBold
	cooldownTitle.Parent = cooldownSection
	
	local fireballCooldownSlider = Instance.new("TextButton")
	fireballCooldownSlider.Size = UDim2.new(0.45, 0, 0, 25)
	fireballCooldownSlider.Position = UDim2.new(0.025, 0, 0, 30)
	fireballCooldownSlider.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	fireballCooldownSlider.BorderSizePixel = 0
	fireballCooldownSlider.Text = "Fireball: " .. config.fireballCooldown
	fireballCooldownSlider.TextColor3 = Color3.new(1, 1, 1)
	fireballCooldownSlider.TextScaled = true
	fireballCooldownSlider.Font = Enum.Font.Gotham
	fireballCooldownSlider.Parent = cooldownSection
	
	local cityCooldownSlider = Instance.new("TextButton")
	cityCooldownSlider.Size = UDim2.new(0.45, 0, 0, 25)
	cityCooldownSlider.Position = UDim2.new(0.525, 0, 0, 30)
	cityCooldownSlider.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	cityCooldownSlider.BorderSizePixel = 0
	cityCooldownSlider.Text = "City: " .. config.cityFireballCooldown
	cityCooldownSlider.TextColor3 = Color3.new(1, 1, 1)
	cityCooldownSlider.TextScaled = true
	cityCooldownSlider.Font = Enum.Font.Gotham
	cityCooldownSlider.Parent = cooldownSection
	
	-- Smart Panic
	local panicSection = Instance.new("Frame")
	panicSection.Size = UDim2.new(1, 0, 0, 60)
	panicSection.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	panicSection.BorderSizePixel = 0
	panicSection.Parent = scrollFrame
	
	local panicTitle = Instance.new("TextLabel")
	panicTitle.Size = UDim2.new(1, 0, 0, 25)
	panicTitle.BackgroundTransparency = 1
	panicTitle.Text = "Smart Panic"
	panicTitle.TextColor3 = Color3.new(1, 1, 1)
	panicTitle.TextScaled = true
	panicTitle.Font = Enum.Font.GothamBold
	panicTitle.Parent = panicSection
	
	local panicToggle = Instance.new("TextButton")
	panicToggle.Size = UDim2.new(0.45, 0, 0, 30)
	panicToggle.Position = UDim2.new(0.025, 0, 0, 30)
	panicToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	panicToggle.BorderSizePixel = 0
	panicToggle.Text = "Smart Panic"
	panicToggle.TextColor3 = Color3.new(1, 1, 1)
	panicToggle.TextScaled = true
	panicToggle.Font = Enum.Font.Gotham
	panicToggle.Parent = panicSection
	
	-- Toggle functionality
	fireballToggle.MouseButton1Click:Connect(function()
		config.FireBallAimbot = not config.FireBallAimbot
		if config.FireBallAimbot then
			fireballToggle.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
			startFireballAimbot()
		else
			fireballToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
			getgenv().FireBallAimbot = false
		end
		saveConfig()
	end)
	
	cityToggle.MouseButton1Click:Connect(function()
		config.FireBallAimbotCity = not config.FireBallAimbotCity
		if config.FireBallAimbotCity then
			cityToggle.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
			startCityFireballAimbot()
		else
			cityToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
			getgenv().FireBallAimbotCity = false
		end
		saveConfig()
	end)
	
	universalToggle.MouseButton1Click:Connect(function()
		config.UniversalFireBallAimbot = not config.UniversalFireBallAimbot
		if config.UniversalFireBallAimbot then
			universalToggle.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
			startUniversalFireballAimbot()
		else
			universalToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
			getgenv().UniversalFireBallAimbot = false
		end
		saveConfig()
	end)
	
	panicToggle.MouseButton1Click:Connect(function()
		config.SmartPanic = not config.SmartPanic
		if config.SmartPanic then
			panicToggle.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
			ToggleSmartPanic(true)
		else
			panicToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
			ToggleSmartPanic(false)
		end
		saveConfig()
	end)
	
	-- Update toggle states
	if config.FireBallAimbot then
		fireballToggle.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
	end
	if config.FireBallAimbotCity then
		cityToggle.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
	end
	if config.UniversalFireBallAimbot then
		universalToggle.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
	end
	if config.SmartPanic then
		panicToggle.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
	end
end

print("Combat tab created")

print("Creating quests tab...")
-- Quests Tab
local function createQuestsTab()
	local scrollFrame = Instance.new("ScrollingFrame")
	scrollFrame.Size = UDim2.new(1, 0, 1, 0)
	scrollFrame.BackgroundTransparency = 1
	scrollFrame.ScrollBarThickness = 6
	scrollFrame.Parent = TabContent
	
	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 5)
	layout.Parent = scrollFrame
	
	-- Side Tasks
	local sideTaskSection = Instance.new("Frame")
	sideTaskSection.Size = UDim2.new(1, 0, 0, 200)
	sideTaskSection.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	sideTaskSection.BorderSizePixel = 0
	sideTaskSection.Parent = scrollFrame
	
	local sideTaskTitle = Instance.new("TextLabel")
	sideTaskTitle.Size = UDim2.new(1, 0, 0, 25)
	sideTaskTitle.BackgroundTransparency = 1
	sideTaskTitle.Text = "Side Tasks"
	sideTaskTitle.TextColor3 = Color3.new(1, 1, 1)
	sideTaskTitle.TextScaled = true
	sideTaskTitle.Font = Enum.Font.GothamBold
	sideTaskTitle.Parent = sideTaskSection
	
	local ninjaToggle = Instance.new("TextButton")
	ninjaToggle.Size = UDim2.new(0.45, 0, 0, 30)
	ninjaToggle.Position = UDim2.new(0.025, 0, 0, 30)
	ninjaToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	ninjaToggle.BorderSizePixel = 0
	ninjaToggle.Text = "Ninja Side Task"
	ninjaToggle.TextColor3 = Color3.new(1, 1, 1)
	ninjaToggle.TextScaled = true
	ninjaToggle.Font = Enum.Font.Gotham
	ninjaToggle.Parent = sideTaskSection
	
	local animatronicsToggle = Instance.new("TextButton")
	animatronicsToggle.Size = UDim2.new(0.45, 0, 0, 30)
	animatronicsToggle.Position = UDim2.new(0.525, 0, 0, 30)
	animatronicsToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	animatronicsToggle.BorderSizePixel = 0
	animatronicsToggle.Text = "Animatronics Side Task"
	animatronicsToggle.TextColor3 = Color3.new(1, 1, 1)
	animatronicsToggle.TextScaled = true
	animatronicsToggle.Font = Enum.Font.Gotham
	animatronicsToggle.Parent = sideTaskSection
	
	local mutantsToggle = Instance.new("TextButton")
	mutantsToggle.Size = UDim2.new(0.45, 0, 0, 30)
	mutantsToggle.Position = UDim2.new(0.025, 0, 0, 65)
	mutantsToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	mutantsToggle.BorderSizePixel = 0
	mutantsToggle.Text = "Mutants Side Task"
	mutantsToggle.TextColor3 = Color3.new(1, 1, 1)
	mutantsToggle.TextScaled = true
	mutantsToggle.Font = Enum.Font.Gotham
	mutantsToggle.Parent = sideTaskSection
	
	local dishesToggle = Instance.new("TextButton")
	dishesToggle.Size = UDim2.new(0.45, 0, 0, 30)
	dishesToggle.Position = UDim2.new(0.525, 0, 0, 65)
	dishesToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	dishesToggle.BorderSizePixel = 0
	dishesToggle.Text = "Dishes Side Task"
	dishesToggle.TextColor3 = Color3.new(1, 1, 1)
	dishesToggle.TextScaled = true
	dishesToggle.Font = Enum.Font.Gotham
	dishesToggle.Parent = sideTaskSection
	
	-- Other Automation
	local otherSection = Instance.new("Frame")
	otherSection.Size = UDim2.new(1, 0, 0, 100)
	otherSection.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	otherSection.BorderSizePixel = 0
	otherSection.Parent = scrollFrame
	
	local otherTitle = Instance.new("TextLabel")
	otherTitle.Size = UDim2.new(1, 0, 0, 25)
	otherTitle.BackgroundTransparency = 1
	otherTitle.Text = "Other Automation"
	otherTitle.TextColor3 = Color3.new(1, 1, 1)
	otherTitle.TextScaled = true
	otherTitle.Font = Enum.Font.GothamBold
	otherTitle.Parent = otherSection
	
	local potionsToggle = Instance.new("TextButton")
	potionsToggle.Size = UDim2.new(0.45, 0, 0, 30)
	potionsToggle.Position = UDim2.new(0.025, 0, 0, 30)
	potionsToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	potionsToggle.BorderSizePixel = 0
	potionsToggle.Text = "Auto Buy Potions"
	potionsToggle.TextColor3 = Color3.new(1, 1, 1)
	potionsToggle.TextScaled = true
	potionsToggle.Font = Enum.Font.Gotham
	potionsToggle.Parent = otherSection
	
	local vendingToggle = Instance.new("TextButton")
	vendingToggle.Size = UDim2.new(0.45, 0, 0, 30)
	vendingToggle.Position = UDim2.new(0.525, 0, 0, 30)
	vendingToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	vendingToggle.BorderSizePixel = 0
	vendingToggle.Text = "Vending Potion Auto Buy"
	vendingToggle.TextColor3 = Color3.new(1, 1, 1)
	vendingToggle.TextScaled = true
	vendingToggle.Font = Enum.Font.Gotham
	vendingToggle.Parent = otherSection
	
	-- Toggle functionality
	ninjaToggle.MouseButton1Click:Connect(function()
		config.AutoNinjaSideTask = not config.AutoNinjaSideTask
		if config.AutoNinjaSideTask then
			ninjaToggle.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
			startAutoNinjaSideTask()
		else
			ninjaToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
			getgenv().AutoNinjaSideTask = false
		end
		saveConfig()
	end)
	
	animatronicsToggle.MouseButton1Click:Connect(function()
		config.AutoAnimatronicsSideTask = not config.AutoAnimatronicsSideTask
		if config.AutoAnimatronicsSideTask then
			animatronicsToggle.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
			startAutoAnimatronicsSideTask()
		else
			animatronicsToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
			getgenv().AutoAnimatronicsSideTask = false
		end
		saveConfig()
	end)
	
	mutantsToggle.MouseButton1Click:Connect(function()
		config.AutoMutantsSideTask = not config.AutoMutantsSideTask
		if config.AutoMutantsSideTask then
			mutantsToggle.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
			startAutoMutantsSideTask()
		else
			mutantsToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
			getgenv().AutoMutantsSideTask = false
		end
		saveConfig()
	end)
	
	dishesToggle.MouseButton1Click:Connect(function()
		config.AutoWashDishes = not config.AutoWashDishes
		if config.AutoWashDishes then
			dishesToggle.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
			startAutoWashDishes()
		else
			dishesToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
			getgenv().AutoWashDishes = false
		end
		saveConfig()
	end)
	
	potionsToggle.MouseButton1Click:Connect(function()
		config.AutoBuyPotions = not config.AutoBuyPotions
		if config.AutoBuyPotions then
			potionsToggle.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
			startAutoBuyPotions()
		else
			potionsToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
			getgenv().AutoBuyPotions = false
		end
		saveConfig()
	end)
	
	vendingToggle.MouseButton1Click:Connect(function()
		config.VendingPotionAutoBuy = not config.VendingPotionAutoBuy
		if config.VendingPotionAutoBuy then
			vendingToggle.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
			startVendingPotionAutoBuy()
		else
			vendingToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
			getgenv().VendingPotionAutoBuy = false
		end
		saveConfig()
	end)
	
	-- Update toggle states
	if config.AutoNinjaSideTask then
		ninjaToggle.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
	end
	if config.AutoAnimatronicsSideTask then
		animatronicsToggle.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
	end
	if config.AutoMutantsSideTask then
		mutantsToggle.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
	end
	if config.AutoWashDishes then
		dishesToggle.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
	end
	if config.AutoBuyPotions then
		potionsToggle.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
	end
	if config.VendingPotionAutoBuy then
		vendingToggle.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
	end
end

print("Quests tab created")

print("Creating teleport tab...")
-- Teleport Tab
local function createTeleportTab()
	local scrollFrame = Instance.new("ScrollingFrame")
	scrollFrame.Size = UDim2.new(1, 0, 1, 0)
	scrollFrame.BackgroundTransparency = 1
	scrollFrame.ScrollBarThickness = 6
	scrollFrame.Parent = TabContent
	
	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 5)
	layout.Parent = scrollFrame
	
	-- Left Column - Locations
	local leftColumn = Instance.new("Frame")
	leftColumn.Size = UDim2.new(0.48, 0, 1, 0)
	leftColumn.BackgroundTransparency = 1
	leftColumn.Parent = scrollFrame
	
	-- Right Column - Players
	local rightColumn = Instance.new("Frame")
	rightColumn.Size = UDim2.new(0.48, 0, 1, 0)
	rightColumn.Position = UDim2.new(0.52, 0, 0, 0)
	rightColumn.BackgroundTransparency = 1
	rightColumn.Parent = scrollFrame
	
	-- Locations Section
	local locationsSection = Instance.new("Frame")
	locationsSection.Size = UDim2.new(1, 0, 0, 150)
	locationsSection.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	locationsSection.BorderSizePixel = 0
	locationsSection.Parent = leftColumn
	
	local locationsTitle = Instance.new("TextLabel")
	locationsTitle.Size = UDim2.new(1, 0, 0, 25)
	locationsTitle.BackgroundTransparency = 1
	locationsTitle.Text = "Locations"
	locationsTitle.TextColor3 = Color3.new(1, 1, 1)
	locationsTitle.TextScaled = true
	locationsTitle.Font = Enum.Font.GothamBold
	locationsTitle.Parent = locationsSection
	
	local spawnButton = Instance.new("TextButton")
	spawnButton.Size = UDim2.new(0.45, 0, 0, 25)
	spawnButton.Position = UDim2.new(0.025, 0, 0, 30)
	spawnButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	spawnButton.BorderSizePixel = 0
	spawnButton.Text = "Spawn"
	spawnButton.TextColor3 = Color3.new(1, 1, 1)
	spawnButton.TextScaled = true
	spawnButton.Font = Enum.Font.Gotham
	spawnButton.Parent = locationsSection
	
	local cityButton = Instance.new("TextButton")
	cityButton.Size = UDim2.new(0.45, 0, 0, 25)
	cityButton.Position = UDim2.new(0.525, 0, 0, 30)
	cityButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	cityButton.BorderSizePixel = 0
	cityButton.Text = "City"
	cityButton.TextColor3 = Color3.new(1, 1, 1)
	cityButton.TextScaled = true
	cityButton.Font = Enum.Font.Gotham
	cityButton.Parent = locationsSection
	
	local gymButton = Instance.new("TextButton")
	gymButton.Size = UDim2.new(0.45, 0, 0, 25)
	gymButton.Position = UDim2.new(0.025, 0, 0, 60)
	gymButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	gymButton.BorderSizePixel = 0
	gymButton.Text = "Gym"
	gymButton.TextColor3 = Color3.new(1, 1, 1)
	gymButton.TextScaled = true
	gymButton.Font = Enum.Font.Gotham
	gymButton.Parent = locationsSection
	
	local shopButton = Instance.new("TextButton")
	shopButton.Size = UDim2.new(0.45, 0, 0, 25)
	shopButton.Position = UDim2.new(0.525, 0, 0, 60)
	shopButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	shopButton.BorderSizePixel = 0
	shopButton.Text = "Shop"
	shopButton.TextColor3 = Color3.new(1, 1, 1)
	shopButton.TextScaled = true
	shopButton.Font = Enum.Font.Gotham
	shopButton.Parent = locationsSection
	
	local trainingButton = Instance.new("TextButton")
	trainingButton.Size = UDim2.new(0.45, 0, 0, 25)
	trainingButton.Position = UDim2.new(0.025, 0, 0, 90)
	trainingButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	trainingButton.BorderSizePixel = 0
	trainingButton.Text = "Training"
	trainingButton.TextColor3 = Color3.new(1, 1, 1)
	trainingButton.TextScaled = true
	trainingButton.Font = Enum.Font.Gotham
	trainingButton.Parent = locationsSection
	
	-- Players Section
	local playersSection = Instance.new("Frame")
	playersSection.Size = UDim2.new(1, 0, 0, 200)
	playersSection.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	playersSection.BorderSizePixel = 0
	playersSection.Parent = rightColumn
	
	local playersTitle = Instance.new("TextLabel")
	playersTitle.Size = UDim2.new(1, 0, 0, 25)
	playersTitle.BackgroundTransparency = 1
	playersTitle.Text = "Players"
	playersTitle.TextColor3 = Color3.new(1, 1, 1)
	playersTitle.TextScaled = true
	playersTitle.Font = Enum.Font.GothamBold
	playersTitle.Parent = playersSection
	
	-- Create player buttons
	local playerButtons = {}
	local function updatePlayerButtons()
		-- Clear old buttons
		for _, button in ipairs(playerButtons) do
			if button then button:Destroy() end
		end
		playerButtons = {}
		
		-- Create new buttons
		local yOffset = 30
		for i, player in ipairs(Players:GetPlayers()) do
			if player ~= LocalPlayer then
				local playerButton = Instance.new("TextButton")
				playerButton.Size = UDim2.new(0.45, 0, 0, 25)
				playerButton.Position = UDim2.new(0.025, 0, 0, yOffset)
				playerButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
				playerButton.BorderSizePixel = 0
				playerButton.Text = player.Name
				playerButton.TextColor3 = Color3.new(1, 1, 1)
				playerButton.TextScaled = true
				playerButton.Font = Enum.Font.Gotham
				playerButton.Parent = playersSection
				
				playerButton.MouseButton1Click:Connect(function()
					teleportToPlayer(player.Name)
				end)
				
				table.insert(playerButtons, playerButton)
				yOffset = yOffset + 30
				
				if yOffset > 170 then break end
			end
		end
	end
	
	-- Saved Position Section
	local savedSection = Instance.new("Frame")
	savedSection.Size = UDim2.new(1, 0, 0, 80)
	savedSection.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	savedSection.BorderSizePixel = 0
	savedSection.Parent = rightColumn
	
	local savedTitle = Instance.new("TextLabel")
	savedTitle.Size = UDim2.new(1, 0, 0, 25)
	savedTitle.BackgroundTransparency = 1
	savedTitle.Text = "Saved Position"
	savedTitle.TextColor3 = Color3.new(1, 1, 1)
	savedTitle.TextScaled = true
	savedTitle.Font = Enum.Font.GothamBold
	savedTitle.Parent = savedSection
	
	local saveButton = Instance.new("TextButton")
	saveButton.Size = UDim2.new(0.45, 0, 0, 25)
	saveButton.Position = UDim2.new(0.025, 0, 0, 30)
	saveButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	saveButton.BorderSizePixel = 0
	saveButton.Text = "Save Place"
	saveButton.TextColor3 = Color3.new(1, 1, 1)
	saveButton.TextScaled = true
	saveButton.Font = Enum.Font.Gotham
	saveButton.Parent = savedSection
	
	local teleportSaveButton = Instance.new("TextButton")
	teleportSaveButton.Size = UDim2.new(0.45, 0, 0, 25)
	teleportSaveButton.Position = UDim2.new(0.025, 0, 0, 60)
	teleportSaveButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	teleportSaveButton.BorderSizePixel = 0
	teleportSaveButton.Text = "Teleport to Save"
	teleportSaveButton.TextColor3 = Color3.new(1, 1, 1)
	teleportSaveButton.TextScaled = true
	teleportSaveButton.Font = Enum.Font.Gotham
	teleportSaveButton.Parent = savedSection
	
	-- Button functionality
	spawnButton.MouseButton1Click:Connect(function()
		teleportToLocation("Spawn")
	end)
	
	cityButton.MouseButton1Click:Connect(function()
		teleportToLocation("City")
	end)
	
	gymButton.MouseButton1Click:Connect(function()
		teleportToLocation("Gym")
	end)
	
	shopButton.MouseButton1Click:Connect(function()
		teleportToLocation("Shop")
	end)
	
	trainingButton.MouseButton1Click:Connect(function()
		teleportToLocation("Training")
	end)
	
	saveButton.MouseButton1Click:Connect(function()
		saveCurrentPosition()
	end)
	
	teleportSaveButton.MouseButton1Click:Connect(function()
		teleportToSavedPosition()
	end)
	
	-- Update player buttons when players change
	Players.PlayerAdded:Connect(updatePlayerButtons)
	Players.PlayerRemoving:Connect(updatePlayerButtons)
	updatePlayerButtons()
end

print("Teleport tab created")

print("Creating utility tab...")
-- Utility Tab
local function createUtilityTab()
	local scrollFrame = Instance.new("ScrollingFrame")
	scrollFrame.Size = UDim2.new(1, 0, 1, 0)
	scrollFrame.BackgroundTransparency = 1
	scrollFrame.ScrollBarThickness = 6
	scrollFrame.Parent = TabContent
	
	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 5)
	layout.Parent = scrollFrame
	
	-- ESP Section
	local espSection = Instance.new("Frame")
	espSection.Size = UDim2.new(1, 0, 0, 100)
	espSection.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	espSection.BorderSizePixel = 0
	espSection.Parent = scrollFrame
	
	local espTitle = Instance.new("TextLabel")
	espTitle.Size = UDim2.new(1, 0, 0, 25)
	espTitle.BackgroundTransparency = 1
	espTitle.Text = "ESP"
	espTitle.TextColor3 = Color3.new(1, 1, 1)
	espTitle.TextScaled = true
	espTitle.Font = Enum.Font.GothamBold
	espTitle.Parent = espSection
	
	local playerESPToggle = Instance.new("TextButton")
	playerESPToggle.Size = UDim2.new(0.45, 0, 0, 30)
	playerESPToggle.Position = UDim2.new(0.025, 0, 0, 30)
	playerESPToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	playerESPToggle.BorderSizePixel = 0
	playerESPToggle.Text = "Player ESP"
	playerESPToggle.TextColor3 = Color3.new(1, 1, 1)
	playerESPToggle.TextScaled = true
	playerESPToggle.Font = Enum.Font.Gotham
	playerESPToggle.Parent = espSection
	
	local mobESPToggle = Instance.new("TextButton")
	mobESPToggle.Size = UDim2.new(0.45, 0, 0, 30)
	mobESPToggle.Position = UDim2.new(0.525, 0, 0, 30)
	mobESPToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	mobESPToggle.BorderSizePixel = 0
	mobESPToggle.Text = "Mob ESP"
	mobESPToggle.TextColor3 = Color3.new(1, 1, 1)
	mobESPToggle.TextScaled = true
	mobESPToggle.Font = Enum.Font.Gotham
	mobESPToggle.Parent = espSection
	
	-- NoClip Section
	local noclipSection = Instance.new("Frame")
	noclipSection.Size = UDim2.new(1, 0, 0, 60)
	noclipSection.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	noclipSection.BorderSizePixel = 0
	noclipSection.Parent = scrollFrame
	
	local noclipTitle = Instance.new("TextLabel")
	noclipTitle.Size = UDim2.new(1, 0, 0, 25)
	noclipTitle.BackgroundTransparency = 1
	noclipTitle.Text = "NoClip"
	noclipTitle.TextColor3 = Color3.new(1, 1, 1)
	noclipTitle.TextScaled = true
	noclipTitle.Font = Enum.Font.GothamBold
	noclipTitle.Parent = noclipSection
	
	local noclipToggle = Instance.new("TextButton")
	noclipToggle.Size = UDim2.new(0.45, 0, 0, 30)
	noclipToggle.Position = UDim2.new(0.025, 0, 0, 30)
	noclipToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	noclipToggle.BorderSizePixel = 0
	noclipToggle.Text = "NoClip"
	noclipToggle.TextColor3 = Color3.new(1, 1, 1)
	noclipToggle.TextScaled = true
	noclipToggle.Font = Enum.Font.Gotham
	noclipToggle.Parent = noclipSection
	
	-- Graphics Section
	local graphicsSection = Instance.new("Frame")
	graphicsSection.Size = UDim2.new(1, 0, 0, 120)
	graphicsSection.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	graphicsSection.BorderSizePixel = 0
	graphicsSection.Parent = scrollFrame
	
	local graphicsTitle = Instance.new("TextLabel")
	graphicsTitle.Size = UDim2.new(1, 0, 0, 25)
	graphicsTitle.BackgroundTransparency = 1
	graphicsTitle.Text = "Graphics"
	graphicsTitle.TextColor3 = Color3.new(1, 1, 1)
	graphicsTitle.TextScaled = true
	graphicsTitle.Font = Enum.Font.GothamBold
	graphicsTitle.Parent = graphicsSection
	
	local graphicsToggle = Instance.new("TextButton")
	graphicsToggle.Size = UDim2.new(0.45, 0, 0, 30)
	graphicsToggle.Position = UDim2.new(0.025, 0, 0, 30)
	graphicsToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	graphicsToggle.BorderSizePixel = 0
	graphicsToggle.Text = "Graphics Optimization"
	graphicsToggle.TextColor3 = Color3.new(1, 1, 1)
	graphicsToggle.TextScaled = true
	graphicsToggle.Font = Enum.Font.Gotham
	graphicsToggle.Parent = graphicsSection
	
	local advancedGraphicsToggle = Instance.new("TextButton")
	advancedGraphicsToggle.Size = UDim2.new(0.45, 0, 0, 30)
	advancedGraphicsToggle.Position = UDim2.new(0.525, 0, 0, 30)
	advancedGraphicsToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	advancedGraphicsToggle.BorderSizePixel = 0
	advancedGraphicsToggle.Text = "Advanced Graphics"
	advancedGraphicsToggle.TextColor3 = Color3.new(1, 1, 1)
	advancedGraphicsToggle.TextScaled = true
	advancedGraphicsToggle.Font = Enum.Font.Gotham
	advancedGraphicsToggle.Parent = graphicsSection
	
	local ultimateAFKToggle = Instance.new("TextButton")
	ultimateAFKToggle.Size = UDim2.new(0.45, 0, 0, 30)
	ultimateAFKToggle.Position = UDim2.new(0.025, 0, 0, 65)
	ultimateAFKToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	ultimateAFKToggle.BorderSizePixel = 0
	ultimateAFKToggle.Text = "Ultimate AFK Optimization"
	ultimateAFKToggle.TextColor3 = Color3.new(1, 1, 1)
	ultimateAFKToggle.TextScaled = true
	ultimateAFKToggle.Font = Enum.Font.Gotham
	ultimateAFKToggle.Parent = graphicsSection
	
	-- Map Section
	local mapSection = Instance.new("Frame")
	mapSection.Size = UDim2.new(1, 0, 0, 60)
	mapSection.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	mapSection.BorderSizePixel = 0
	mapSection.Parent = scrollFrame
	
	local mapTitle = Instance.new("TextLabel")
	mapTitle.Size = UDim2.new(1, 0, 0, 25)
	mapTitle.BackgroundTransparency = 1
	mapTitle.Text = "Map"
	mapTitle.TextColor3 = Color3.new(1, 1, 1)
	mapTitle.TextColor3 = Color3.new(1, 1, 1)
	mapTitle.TextScaled = true
	mapTitle.Font = Enum.Font.GothamBold
	mapTitle.Parent = mapSection
	
	local mapClutterToggle = Instance.new("TextButton")
	mapClutterToggle.Size = UDim2.new(0.45, 0, 0, 30)
	mapClutterToggle.Position = UDim2.new(0.025, 0, 0, 30)
	mapClutterToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	mapClutterToggle.BorderSizePixel = 0
	mapClutterToggle.Text = "Remove Map Clutter"
	mapClutterToggle.TextColor3 = Color3.new(1, 1, 1)
	mapClutterToggle.TextScaled = true
	mapClutterToggle.Font = Enum.Font.Gotham
	mapClutterToggle.Parent = mapSection
	
	-- Webhook Section
	local webhookSection = Instance.new("Frame")
	webhookSection.Size = UDim2.new(1, 0, 0, 100)
	webhookSection.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	webhookSection.BorderSizePixel = 0
	webhookSection.Parent = scrollFrame
	
	local webhookTitle = Instance.new("TextLabel")
	webhookTitle.Size = UDim2.new(1, 0, 0, 25)
	webhookTitle.BackgroundTransparency = 1
	webhookTitle.Text = "Webhooks"
	webhookTitle.TextColor3 = Color3.new(1, 1, 1)
	webhookTitle.TextScaled = true
	webhookTitle.Font = Enum.Font.GothamBold
	webhookTitle.Parent = webhookSection
	
	local deathWebhookToggle = Instance.new("TextButton")
	deathWebhookToggle.Size = UDim2.new(0.45, 0, 0, 30)
	deathWebhookToggle.Position = UDim2.new(0.025, 0, 0, 30)
	deathWebhookToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	deathWebhookToggle.BorderSizePixel = 0
	deathWebhookToggle.Text = "Death Webhook"
	deathWebhookToggle.TextColor3 = Color3.new(1, 1, 1)
	deathWebhookToggle.TextScaled = true
	deathWebhookToggle.Font = Enum.Font.Gotham
	deathWebhookToggle.Parent = webhookSection
	
	local panicWebhookToggle = Instance.new("TextButton")
	panicWebhookToggle.Size = UDim2.new(0.45, 0, 0, 30)
	panicWebhookToggle.Position = UDim2.new(0.525, 0, 0, 30)
	panicWebhookToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	panicWebhookToggle.BorderSizePixel = 0
	panicWebhookToggle.Text = "Panic Webhook"
	panicWebhookToggle.TextColor3 = Color3.new(1, 1, 1)
	panicWebhookToggle.TextScaled = true
	panicWebhookToggle.Font = Enum.Font.Gotham
	panicWebhookToggle.Parent = webhookSection
	
	local statWebhookToggle = Instance.new("TextButton")
	statWebhookToggle.Size = UDim2.new(0.45, 0, 0, 30)
	statWebhookToggle.Position = UDim2.new(0.025, 0, 0, 65)
	statWebhookToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	statWebhookToggle.BorderSizePixel = 0
	statWebhookToggle.Text = "Stat Webhook"
	statWebhookToggle.TextColor3 = Color3.new(1, 1, 1)
	statWebhookToggle.TextScaled = true
	statWebhookToggle.Font = Enum.Font.Gotham
	statWebhookToggle.Parent = webhookSection
	
	-- Toggle functionality
	playerESPToggle.MouseButton1Click:Connect(function()
		config.PlayerESP = not config.PlayerESP
		if config.PlayerESP then
			playerESPToggle.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
			TogglePlayerESP(true)
		else
			playerESPToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
			TogglePlayerESP(false)
		end
		saveConfig()
	end)
	
	mobESPToggle.MouseButton1Click:Connect(function()
		config.MobESP = not config.MobESP
		if config.MobESP then
			mobESPToggle.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
			ToggleMobESP(true)
		else
			mobESPToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
			ToggleMobESP(false)
		end
		saveConfig()
	end)
	
	noclipToggle.MouseButton1Click:Connect(function()
		config.NoClip = not config.NoClip
		if config.NoClip then
			noclipToggle.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
			ToggleNoClip(true)
		else
			noclipToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
			ToggleNoClip(false)
		end
		saveConfig()
	end)
	
	graphicsToggle.MouseButton1Click:Connect(function()
		config.GraphicsOptimization = not config.GraphicsOptimization
		if config.GraphicsOptimization then
			graphicsToggle.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
			ToggleGraphicsOptimization(true)
		else
			graphicsToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
			ToggleGraphicsOptimization(false)
		end
		saveConfig()
	end)
	
	advancedGraphicsToggle.MouseButton1Click:Connect(function()
		config.GraphicsOptimizationAdvanced = not config.GraphicsOptimizationAdvanced
		if config.GraphicsOptimizationAdvanced then
			advancedGraphicsToggle.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
			ToggleAdvancedGraphicsOptimization(true)
		else
			advancedGraphicsToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
			ToggleAdvancedGraphicsOptimization(false)
		end
		saveConfig()
	end)
	
	ultimateAFKToggle.MouseButton1Click:Connect(function()
		config.UltimateAFKOptimization = not config.UltimateAFKOptimization
		if config.UltimateAFKOptimization then
			ultimateAFKToggle.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
			ToggleUltimateAFKOptimization(true)
		else
			ultimateAFKToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
			ToggleUltimateAFKOptimization(false)
		end
		saveConfig()
	end)
	
	mapClutterToggle.MouseButton1Click:Connect(function()
		config.RemoveMapClutter = not config.RemoveMapClutter
		if config.RemoveMapClutter then
			mapClutterToggle.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
			ToggleRemoveMapClutter(true)
		else
			mapClutterToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
			ToggleRemoveMapClutter(false)
		end
		saveConfig()
	end)
	
	deathWebhookToggle.MouseButton1Click:Connect(function()
		config.DeathWebhook = not config.DeathWebhook
		deathWebhookToggle.BackgroundColor3 = config.DeathWebhook and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(60, 60, 60)
		saveConfig()
	end)
	
	panicWebhookToggle.MouseButton1Click:Connect(function()
		config.PanicWebhook = not config.PanicWebhook
		panicWebhookToggle.BackgroundColor3 = config.PanicWebhook and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(60, 60, 60)
		saveConfig()
	end)
	
	statWebhookToggle.MouseButton1Click:Connect(function()
		config.StatWebhook = not config.StatWebhook
		if config.StatWebhook then
			statWebhookToggle.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
			getgenv().StatWebhook = true
			startStatWebhook()
		else
			statWebhookToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
			getgenv().StatWebhook = false
			stopStatWebhook()
		end
		saveConfig()
	end)
	
	-- Update toggle states
	if config.PlayerESP then
		playerESPToggle.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
	end
	if config.MobESP then
		mobESPToggle.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
	end
	if config.NoClip then
		noclipToggle.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
	end
	if config.GraphicsOptimization then
		graphicsToggle.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
	end
	if config.GraphicsOptimizationAdvanced then
		advancedGraphicsToggle.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
	end
	if config.UltimateAFKOptimization then
		ultimateAFKToggle.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
	end
	if config.RemoveMapClutter then
		mapClutterToggle.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
	end
	if config.DeathWebhook then
		deathWebhookToggle.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
	end
	if config.PanicWebhook then
		panicWebhookToggle.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
	end
	if config.StatWebhook then
		statWebhookToggle.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
	end
end

print("Utility tab created")

print("Creating settings tab...")
-- Settings Tab
local function createSettingsTab()
	local scrollFrame = Instance.new("ScrollingFrame")
	scrollFrame.Size = UDim2.new(1, 0, 1, 0)
	scrollFrame.BackgroundTransparency = 1
	scrollFrame.ScrollBarThickness = 6
	scrollFrame.Parent = TabContent
	
	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 5)
	layout.Parent = scrollFrame
	
	-- Cooldown Settings
	local cooldownSection = Instance.new("Frame")
	cooldownSection.Size = UDim2.new(1, 0, 0, 120)
	cooldownSection.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	cooldownSection.BorderSizePixel = 0
	cooldownSection.Parent = scrollFrame
	
	local cooldownTitle = Instance.new("TextLabel")
	cooldownTitle.Size = UDim2.new(1, 0, 0, 25)
	cooldownTitle.BackgroundTransparency = 1
	cooldownTitle.Text = "Cooldown Settings"
	cooldownTitle.TextColor3 = Color3.new(1, 1, 1)
	cooldownTitle.TextScaled = true
	cooldownTitle.Font = Enum.Font.GothamBold
	cooldownTitle.Parent = cooldownSection
	
	local fireballCooldownSlider = Instance.new("TextButton")
	fireballCooldownSlider.Size = UDim2.new(0.45, 0, 0, 25)
	fireballCooldownSlider.Position = UDim2.new(0.025, 0, 0, 30)
	fireballCooldownSlider.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	fireballCooldownSlider.BorderSizePixel = 0
	fireballCooldownSlider.Text = "Fireball: " .. config.fireballCooldown
	fireballCooldownSlider.TextColor3 = Color3.new(1, 1, 1)
	fireballCooldownSlider.TextScaled = true
	fireballCooldownSlider.Font = Enum.Font.Gotham
	fireballCooldownSlider.Parent = cooldownSection
	
	local cityCooldownSlider = Instance.new("TextButton")
	cityCooldownSlider.Size = UDim2.new(0.45, 0, 0, 25)
	cityCooldownSlider.Position = UDim2.new(0.525, 0, 0, 30)
	cityCooldownSlider.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	cityCooldownSlider.BorderSizePixel = 0
	cityCooldownSlider.Text = "City: " .. config.cityFireballCooldown
	cityCooldownSlider.TextColor3 = Color3.new(1, 1, 1)
	cityCooldownSlider.TextScaled = true
	cityCooldownSlider.Font = Enum.Font.Gotham
	cityCooldownSlider.Parent = cooldownSection
	
	local universalCooldownSlider = Instance.new("TextButton")
	universalCooldownSlider.Size = UDim2.new(0.45, 0, 0, 25)
	universalCooldownSlider.Position = UDim2.new(0.025, 0, 0, 65)
	universalCooldownSlider.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	universalCooldownSlider.BorderSizePixel = 0
	universalCooldownSlider.Text = "Universal: " .. config.universalFireballInterval
	universalCooldownSlider.TextColor3 = Color3.new(1, 1, 1)
	universalCooldownSlider.TextScaled = true
	universalCooldownSlider.Font = Enum.Font.Gotham
	universalCooldownSlider.Parent = cooldownSection
	
	-- Slider functionality
	fireballCooldownSlider.MouseButton1Click:Connect(function()
		local newValue = config.fireballCooldown + 0.05
		if newValue > 1.0 then newValue = 0.05 end
		config.fireballCooldown = newValue
		fireballCooldownSlider.Text = "Fireball: " .. newValue
		saveConfig()
	end)
	
	cityCooldownSlider.MouseButton1Click:Connect(function()
		local newValue = config.cityFireballCooldown + 0.1
		if newValue > 2.0 then newValue = 0.1 end
		config.cityFireballCooldown = newValue
		cityCooldownSlider.Text = "City: " .. newValue
		saveConfig()
	end)
	
	universalCooldownSlider.MouseButton1Click:Connect(function()
		local newValue = config.universalFireballInterval + 0.1
		if newValue > 3.0 then newValue = 0.1 end
		config.universalFireballInterval = newValue
		universalCooldownSlider.Text = "Universal: " .. newValue
		saveConfig()
	end)
	
	-- Hide GUI Key
	local keySection = Instance.new("Frame")
	keySection.Size = UDim2.new(1, 0, 0, 60)
	keySection.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	keySection.BorderSizePixel = 0
	keySection.Parent = scrollFrame
	
	local keyTitle = Instance.new("TextLabel")
	keyTitle.Size = UDim2.new(1, 0, 0, 25)
	keyTitle.BackgroundTransparency = 1
	keyTitle.Text = "Hide GUI Key: " .. config.HideGUIKey
	keyTitle.TextColor3 = Color3.new(1, 1, 1)
	keyTitle.TextScaled = true
	keyTitle.Font = Enum.Font.GothamBold
	keyTitle.Parent = keySection
	
	local keyButton = Instance.new("TextButton")
	keyButton.Size = UDim2.new(0.45, 0, 0, 30)
	keyButton.Position = UDim2.new(0.025, 0, 0, 30)
	keyButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	keyButton.BorderSizePixel = 0
	keyButton.Text = "Change Key"
	keyButton.TextColor3 = Color3.new(1, 1, 1)
	keyButton.TextScaled = true
	keyButton.Font = Enum.Font.Gotham
	keyButton.Parent = keySection
	
	keyButton.MouseButton1Click:Connect(function()
		keyButton.Text = "Press any key..."
		local connection
		connection = UIS.InputBegan:Connect(function(input)
			if input.KeyCode ~= Enum.KeyCode.Unknown then
				config.HideGUIKey = input.KeyCode.Name
				keyTitle.Text = "Hide GUI Key: " .. config.HideGUIKey
				keyButton.Text = "Change Key"
				saveConfig()
				connection:Disconnect()
			end
		end)
	end)
	
	-- Save/Load Config
	local configSection = Instance.new("Frame")
	configSection.Size = UDim2.new(1, 0, 0, 80)
	configSection.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	configSection.BorderSizePixel = 0
	configSection.Parent = scrollFrame
	
	local configTitle = Instance.new("TextLabel")
	configTitle.Size = UDim2.new(1, 0, 0, 25)
	configTitle.BackgroundTransparency = 1
	configTitle.Text = "Configuration"
	configTitle.TextColor3 = Color3.new(1, 1, 1)
	configTitle.TextScaled = true
	configTitle.Font = Enum.Font.GothamBold
	configTitle.Parent = configSection
	
	local saveButton = Instance.new("TextButton")
	saveButton.Size = UDim2.new(0.45, 0, 0, 30)
	saveButton.Position = UDim2.new(0.025, 0, 0, 30)
	saveButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	saveButton.BorderSizePixel = 0
	saveButton.Text = "Save Config"
	saveButton.TextColor3 = Color3.new(1, 1, 1)
	saveButton.TextScaled = true
	saveButton.Font = Enum.Font.Gotham
	saveButton.Parent = configSection
	
	local loadButton = Instance.new("TextButton")
	loadButton.Size = UDim2.new(0.45, 0, 0, 30)
	loadButton.Position = UDim2.new(0.525, 0, 0, 30)
	loadButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	loadButton.BorderSizePixel = 0
	loadButton.Text = "Load Config"
	loadButton.TextColor3 = Color3.new(1, 1, 1)
	loadButton.TextScaled = true
	loadButton.Font = Enum.Font.Gotham
	loadButton.Parent = configSection
	
	saveButton.MouseButton1Click:Connect(function()
		if saveConfig() then
			saveButton.Text = "Saved!"
			task.wait(1)
			saveButton.Text = "Save Config"
		else
			saveButton.Text = "Failed!"
			task.wait(1)
			saveButton.Text = "Save Config"
		end
	end)
	
	loadButton.MouseButton1Click:Connect(function()
		if loadConfig() then
			loadButton.Text = "Loaded!"
			task.wait(1)
			loadButton.Text = "Load Config"
		else
			loadButton.Text = "Failed!"
			task.wait(1)
			loadButton.Text = "Load Config"
		end
	end)
end

print("Settings tab created")

print("Setting up GUI functionality...")
-- Create all tabs
for _, tabName in ipairs(tabs) do
	createTabButton(tabName)
end

-- Show initial tab
updateTabContent()

-- Hide GUI functionality
UIS.InputBegan:Connect(function(input)
	if input.KeyCode == Enum.KeyCode[config.HideGUIKey] then
		MainFrame.Visible = not MainFrame.Visible
	end
end)

-- Make GUI draggable
local dragging = false
local dragStart = nil
local startPos = nil

TitleBar.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = input.Position
		startPos = MainFrame.Position
	end
end)

UIS.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement then
		if dragging then
			local delta = input.Position - dragStart
			MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end
end)

UIS.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = false
	end
end)

print("GUI functionality set up")

print("Initializing systems...")
-- Initialize systems
initializeDeathAndPanicWatchers()

print("=== SCRIPT COMPLETED SUCCESSFULLY ===")
print("GUI should now be visible and functional")
