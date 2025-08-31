if not game:IsLoaded() then game.Loaded:Wait() end
local P=game:GetService('Players');while not P.LocalPlayer or not workspace.CurrentCamera do task.wait() end
local U=game:GetService('UserInputService');local R=game:GetService('RunService');local H=game:GetService('HttpService')
local L=game:GetService('Lighting');local RS=game:GetService('ReplicatedStorage')
local LP=P.LocalPlayer;local Cam=workspace.CurrentCamera

local WURL=(getgenv and getgenv().Webhook)or'';local WID=(getgenv and tostring(getgenv().UserID))or''
local function req()return(syn and syn.request)or(http and http.request)or(getgenv and getgenv().request)or http_request or(fluxus and fluxus.request)end
local function webhook(user,title,desc,ping)
	if WURL=='' then return end
	local r=req();if not r then return end
	local content,allowed;if ping and tostring(ping)~='' then content='<@'..tostring(ping)..'>';allowed={tostring(ping)} end
	local pl={username=user,content=content,embeds={{title=title,description=desc,color=16711680,footer={text='Roblox • '..os.date('%H:%M')}}},allowed_mentions={parse={},users=allowed or {}}}
	pcall(function()r({Url=WURL,Method='POST',Headers={['Content-Type']='application/json'},Body=H:JSONEncode(pl)})end)
end
local function deathWH(n,k)webhook('Death Bot','⚠️ Player Killed!',n..' was killed.',WID)end
local function panicWH(n)webhook('Panic Bot','Panic Activated',n..' Triggered Panic',WID)end

local cfg={
	FireBallAimbot=false,FireBallAimbotCity=false,UniversalFireBallAimbot=false,SmartPanic=false,
	DeathWebhook=true,PanicWebhook=false,GraphicsOptimization=false,GraphicsOptimizationAdvanced=false,
	UltimateAFKOptimization=false,NoClip=false,PlayerESP=false,MobESP=false,AutoWashDishes=false,
	AutoNinjaSideTask=false,AutoAnimatronicsSideTask=false,AutoMutantsSideTask=false,DualExoticShop=false,
	VendingPotionAutoBuy=false,RemoveMapClutter=false,StatWebhook15m=false,KillAura=false,StatGui=false,
	AutoInvisible=false,AutoResize=false,AutoFly=false,HealthExploit=false,GammaAimbot=false,InfiniteZoom=false,
	AutoConsumePower=false,AutoConsumeHealth=false,AutoConsumeDefense=false,AutoConsumePsychic=false,AutoConsumeMagic=false,AutoConsumeMobility=false,
	fireballCooldown=0.1,cityFireballCooldown=0.5,universalFireballInterval=1.0,HideGUIKey='RightControl',
}
local function save()pcall(function()writefile('SuperPowerLeague_Config.json',H:JSONEncode(cfg))end)end
local function load()pcall(function()if isfile('SuperPowerLeague_Config.json')then for k,v in pairs(H:JSONDecode(readfile('SuperPowerLeague_Config.json')))do cfg[k]=v end end end)end
load()

-- Teleport exotic stores to specific positions instantly
task.spawn(function()
	pcall(function()
		local exoticStore = workspace.Pads.ExoticStore["1"]
		local exoticStore2 = workspace.Pads.ExoticStore2["1"]

		-- Target positions
		local pos1 = Vector3.new(-167.33985900878906, 75.6653060913086, 156.6094207763672) -- ExoticStore
		local pos2 = Vector3.new(-180.12326049804688, 75.6653060913086, 134.66819763183594) -- ExoticStore2

		-- Move them by setting their CFrame
		exoticStore.CFrame = CFrame.new(pos1)
		exoticStore2.CFrame = CFrame.new(pos2)

		print("Teleported ExoticStore and ExoticStore2 to target positions")
	end)
end)

-- Train mobility script starts instantly
task.spawn(function()
	pcall(function()
		local args = {}
		while true do
			game:GetService("ReplicatedStorage"):WaitForChild("Events", 9e9):WaitForChild("Train", 9e9):WaitForChild("TrainMobility", 9e9):FireServer(unpack(args))
			task.wait(0.1) -- wait for 0.1 seconds before the next iteration
		end
	end)
end)

local function charHum()local c=LP.Character or LP.CharacterAdded:Wait();return c,c:FindFirstChildOfClass('Humanoid'),c:FindFirstChild('HumanoidRootPart')end
local function ev(...)local n=RS;for _,p in ipairs({...})do n=n:WaitForChild(p,9e9)end;return n end
local function disableAimbots()
	if getgenv().UniversalFireBallAimbot or getgenv().FireBallAimbot or getgenv().FireBallAimbotCity then
		getgenv().UniversalFireBallAimbot=false;getgenv().FireBallAimbot=false;getgenv().FireBallAimbotCity=false
		cfg.UniversalFireBallAimbot=false;cfg.FireBallAimbot=false;cfg.FireBallAimbotCity=false;save()
	end
end

local lastPanicSentAt,PANIC_THRESHOLD,PANIC_COOLDOWN,REARM=0,0.95,5,0.95
local function initDeathPanic()
	local function hook(c)
		local h=c:WaitForChild('Humanoid',10);if not h then return end
		local lastD,dsent,armed=nil,false,true
		local lastP,MIN=0,5
		h.Died:Connect(function()
			if cfg.DeathWebhook and not dsent then dsent=true;disableAimbots();deathWH(LP.Name,(lastD and lastD.Name)or'Unknown') else disableAimbots() end
			armed=true
		end)
		h.HealthChanged:Connect(function(hp)
			local m=h.MaxHealth;if not m or m<=0 then return end
			local r,now=hp/m,os.clock()
			if r<=PANIC_THRESHOLD and armed then
				if(now-lastP)<MIN then return end;lastP=now;armed=false;disableAimbots()
				if cfg.PanicWebhook and(now-lastPanicSentAt)>=PANIC_COOLDOWN then lastPanicSentAt=now;panicWH(LP.Name) end
			elseif r>=REARM then armed=true end
		end)
		task.defer(function()
			for _,p in ipairs(workspace:GetDescendants())do if p:IsA('BasePart')then p.Touched:Connect(function(hit)local pl=P:GetPlayerFromCharacter(hit.Parent);if pl then lastD=pl.Character end end)end end
		end)
	end
	if LP.Character then hook(LP.Character) end;LP.CharacterAdded:Connect(hook)
end
initDeathPanic()

getgenv().SmartPanic=cfg.SmartPanic and true or false
local TARGET_PLACE=79106917651793
local function fallbackCF()for _,d in ipairs(workspace:GetDescendants())do if d:IsA('SpawnLocation')then return d.CFrame end end local _,_,hrp=charHum();return hrp and(hrp.CFrame+Vector3.new(0,35,0)) or nil end
local function panicCF()
	if game.PlaceId==TARGET_PLACE then
		local l=workspace:FindFirstChild('Lobby');local e=l and l:FindFirstChild('Extras');local s=e and e:FindFirstChild('PvPSign')or nil
		if not s then for _,d in ipairs(workspace:GetDescendants())do if d.Name=='PvPSign'then s=d;break end end end
		if s then return s:IsA('Model') and s:GetPivot() or s.CFrame end
	else
		local ts=workspace:FindFirstChild('TopStat8');local d=ts and ts:FindFirstChild('Design');if d then local n=d:GetChildren()[30];if n then return n:IsA('Model')and n:GetPivot() or n.CFrame end end
	end
	return fallbackCF()
end
task.spawn(function()
	local last,armed=0,true
	while true do
		if getgenv().SmartPanic then
			local c,h=charHum();if h then local m=(h.MaxHealth and h.MaxHealth>0)and h.MaxHealth or 100;local now=os.clock()
				if armed and h.Health>0 and h.Health<=0.90*m and(now-last)>=1.5 then local cf=panicCF();if cf and LP.Character then pcall(function()LP.Character:PivotTo(cf)end)end last=now;armed=false
				elseif not armed and h.Health>=REARM*m then armed=true end
			end
		end
		task.wait(0.1)
	end
end)

local G=Instance.new('ScreenGui');G.Name='SuperPowerLeagueGUI';G.ZIndexBehavior=Enum.ZIndexBehavior.Global;G.IgnoreGuiInset=true;G.ResetOnSpawn=false;G.Enabled=false
local function parentGui(gui)local p=(gethui and gethui())or game:FindFirstChildOfClass('CoreGui')or LP:WaitForChild('PlayerGui');if syn and syn.protect_gui and p==game:GetService('CoreGui')then pcall(syn.protect_gui,gui)end gui.Parent=p end
parentGui(G)
local function mk(t,pr,par)local i=Instance.new(t);for k,v in pairs(pr or{})do i[k]=v end;if par then i.Parent=par end;return i end

local BG=mk('Frame',{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1},G)
local SD=mk('ImageLabel',{Size=UDim2.new(0,860,0,560),Position=UDim2.new(0.5,-430,0.5,-280),BackgroundTransparency=1,Image='rbxassetid://5107167611',ImageColor3=Color3.fromRGB(0,0,0),ImageTransparency=0.25,ScaleType=Enum.ScaleType.Slice,SliceCenter=Rect.new(10,10,118,118)},BG)
local MF=mk('Frame',{Name='MainFrame',Size=UDim2.new(0,840,0,540),Position=UDim2.new(0.5,-420,0.5,-270),BackgroundColor3=Color3.fromRGB(22,22,28),BorderSizePixel=0},BG)
mk('UICorner',{CornerRadius=UDim.new(0,14)},MF)
local TB=mk('Frame',{Name='TitleBar',Size=UDim2.new(1,0,0,48),BackgroundColor3=Color3.fromRGB(28,28,36),BorderSizePixel=0},MF)
mk('UICorner',{CornerRadius=UDim.new(0,14)},TB)
mk('UIGradient',{Color=ColorSequence.new{ColorSequenceKeypoint.new(0,Color3.fromRGB(40,40,54)),ColorSequenceKeypoint.new(1,Color3.fromRGB(28,28,36))}},TB)
mk('TextLabel',{Name='Title',Size=UDim2.new(1,-100,1,0),Position=UDim2.new(0,20,0,0),BackgroundTransparency=1,Text='Nedu Carti Hub',TextColor3=Color3.fromRGB(235,235,245),TextScaled=true,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Left},TB)
mk('Frame',{Size=UDim2.new(1,0,0,2),Position=UDim2.new(0,0,1,-2),BackgroundColor3=Color3.fromRGB(0,170,255),BorderSizePixel=0},TB)
local Tabs=mk('Frame',{Name='TabContainer',Size=UDim2.new(0,180,1,-58),Position=UDim2.new(0,12,0,54),BackgroundColor3=Color3.fromRGB(26,26,34),BorderSizePixel=0},MF)
mk('UICorner',{CornerRadius=UDim.new(0,10)},Tabs)
local CC=mk('Frame',{Name='ContentContainer',Size=UDim2.new(1,-208,1,-58),Position=UDim2.new(0,196,0,54),BackgroundColor3=Color3.fromRGB(18,18,24),BorderSizePixel=0},MF)
mk('UICorner',{CornerRadius=UDim.new(0,10)},CC)
mk('UIPadding',{PaddingTop=UDim.new(0,12),PaddingBottom=UDim.new(0,12),PaddingLeft=UDim.new(0,12),PaddingRight=UDim.new(0,12)},CC)
local CS=mk('ScrollingFrame',{Name='ContentScroll',Size=UDim2.new(1,-4,1,-4),Position=UDim2.new(0,2,0,2),BackgroundTransparency=1,ScrollBarThickness=6,CanvasSize=UDim2.new(0,0,0,0)},CC)
mk('UIListLayout',{Padding=UDim.new(0,12),SortOrder=Enum.SortOrder.LayoutOrder},CS)

local waitingKey,SetHideBtn=false,nil
U.InputBegan:Connect(function(i,gp)
	if gp then return end
	if waitingKey and i.UserInputType==Enum.UserInputType.Keyboard then cfg.HideGUIKey=i.KeyCode.Name;save();waitingKey=false;if SetHideBtn then SetHideBtn.Text="Set Hide Key ("..(cfg.HideGUIKey or'RightControl')..")"end;return end
	if i.UserInputType==Enum.UserInputType.Keyboard and i.KeyCode.Name==(cfg.HideGUIKey or'RightControl') then G.Enabled=not G.Enabled end
end)

local function TabBtn(p,t,ic)
	local b=mk('TextButton',{Size=UDim2.new(1,-16,0,40),Position=UDim2.new(0,8,0,0),BackgroundColor3=Color3.fromRGB(30,30,40),Text=ic..'  '..t,TextColor3=Color3.fromRGB(210,210,220),TextScaled=true,Font=Enum.Font.Gotham,BorderSizePixel=0},p)
	mk('UICorner',{CornerRadius=UDim.new(0,8)},b)
	local a=mk('Frame',{Size=UDim2.new(0,3,1,0),Position=UDim2.new(0,0,0,0),BackgroundColor3=Color3.fromRGB(0,170,255),Visible=false},b)
	return b,a
end
local function Tab(name,icon)
	local c=0;for _,x in ipairs(Tabs:GetChildren())do if x:IsA('TextButton')then c+=1 end end
	local b,a=TabBtn(Tabs,name,icon);b.Position=UDim2.new(0,8,0,c*46+8)
	local t=mk('Frame',{Name=name..'Content',Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Visible=false},CS)
	mk('UIListLayout',{Padding=UDim.new(0,10),SortOrder=Enum.SortOrder.LayoutOrder},t);mk('UIPadding',{PaddingLeft=UDim.new(0,4),PaddingRight=UDim.new(0,4)},t)
	b.MouseButton1Click:Connect(function()
		for _,ch in ipairs(CS:GetChildren())do if ch:IsA('Frame')and ch.Name:find('Content')then ch.Visible=false end end
		for _,bb in ipairs(Tabs:GetChildren())do if bb:IsA('TextButton')then bb.BackgroundColor3=Color3.fromRGB(30,30,40);bb.TextColor3=Color3.fromRGB(210,210,220);local aa=bb:FindFirstChildOfClass('Frame');if aa then aa.Visible=false end end end
		t.Visible=true;b.BackgroundColor3=Color3.fromRGB(45,45,60);b.TextColor3=Color3.fromRGB(240,240,250);a.Visible=true
	end)
	return t
end
local function Section(p,title)
	local s=mk('Frame',{Name=title..'Section',Size=UDim2.new(1,-8,0,0),BackgroundColor3=Color3.fromRGB(24,24,32),BorderSizePixel=0,AutomaticSize=Enum.AutomaticSize.Y},p)
	mk('UICorner',{CornerRadius=UDim.new(0,10)},s)
	mk('TextLabel',{Name='Title',Size=UDim2.new(1,-12,0,28),Position=UDim2.new(0,12,0,8),BackgroundTransparency=1,Text=title,TextColor3=Color3.fromRGB(235,235,245),TextScaled=true,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Left},s)
	local c=mk('Frame',{Name='Content',Size=UDim2.new(1,-24,0,0),Position=UDim2.new(0,12,0,44),BackgroundTransparency=1,AutomaticSize=Enum.AutomaticSize.Y},s)
	mk('UIListLayout',{Padding=UDim.new(0,8),SortOrder=Enum.SortOrder.LayoutOrder},c)
	return c
end
local function Toggle(p,name,key,cb)
	local r=mk('Frame',{Name=name..'Toggle',Size=UDim2.new(1,0,0,32),BackgroundTransparency=1},p)
	local bg=mk('Frame',{Size=UDim2.new(1,0,1,0),BackgroundColor3=Color3.fromRGB(28,28,38),BorderSizePixel=0},r)
	mk('UICorner',{CornerRadius=UDim.new(0,8)},bg)
	mk('TextLabel',{Size=UDim2.new(1,-72,1,0),Position=UDim2.new(0,12,0,0),BackgroundTransparency=1,Text=name,TextColor3=Color3.fromRGB(230,230,240),TextScaled=true,Font=Enum.Font.Gotham,TextXAlignment=Enum.TextXAlignment.Left},bg)
	local b=mk('TextButton',{Size=UDim2.new(0,52,0,24),Position=UDim2.new(1,-64,0.5,-12),BackgroundColor3=Color3.fromRGB(60,60,70),Text='',BorderSizePixel=0},bg)
	mk('UICorner',{CornerRadius=UDim.new(1,0)},b)
	local k=mk('Frame',{Size=UDim2.new(0,20,0,20),Position=UDim2.new(0,2,0.5,-10),BackgroundColor3=Color3.fromRGB(200,200,205),BorderSizePixel=0},b)
	mk('UICorner',{CornerRadius=UDim.new(1,0)},k)
	local function vis()local on=cfg[key];b.BackgroundColor3=on and Color3.fromRGB(0,170,255)or Color3.fromRGB(60,60,70);k:TweenPosition(on and UDim2.new(1,-22,0.5,-10)or UDim2.new(0,2,0.5,-10),'Out','Quad',0.15,true)end
	b.MouseButton1Click:Connect(function()cfg[key]=not cfg[key];vis();if cb then cb(cfg[key])end;save()end)
	vis();task.defer(function()if cb then cb(cfg[key])end end)
	return r
end
local function Slider(p,name,key,min,max,def,cb)
	local f=mk('Frame',{Name=name..'Slider',Size=UDim2.new(1,0,0,48),BackgroundTransparency=1},p)
	local bg=mk('Frame',{Size=UDim2.new(1,0,1,0),BackgroundColor3=Color3.fromRGB(28,28,38),BorderSizePixel=0},f)
	mk('UICorner',{CornerRadius=UDim.new(0,8)},bg)
	local lbl=mk('TextLabel',{Size=UDim2.new(1,-12,0,20),Position=UDim2.new(0,12,0,6),BackgroundTransparency=1,Text=name..': '..(cfg[key]or def),TextColor3=Color3.fromRGB(230,230,240),TextScaled=true,Font=Enum.Font.Gotham,TextXAlignment=Enum.TextXAlignment.Left},bg)
	local bar=mk('Frame',{Size=UDim2.new(1,-24,0,6),Position=UDim2.new(0,12,1,-14),BackgroundColor3=Color3.fromRGB(55,55,65),BorderSizePixel=0},bg)
	mk('UICorner',{CornerRadius=UDim.new(0,3)},bar)
	local fill=mk('Frame',{Size=UDim2.new(0,0,1,0),BackgroundColor3=Color3.fromRGB(0,170,255),BorderSizePixel=0},bar);mk('UICorner',{CornerRadius=UDim.new(0,3)},fill)
	local knob=mk('Frame',{Size=UDim2.new(0,14,0,14),Position=UDim2.new(0,-7,0.5,-7),BackgroundColor3=Color3.fromRGB(235,235,245),BorderSizePixel=0},bar);mk('UICorner',{CornerRadius=UDim.new(1,0)},knob)
	local drag=false
	local function apply(v)local s=0.01;v=math.floor((v/s)+0.5)*s;v=math.clamp(v,min,max);local pct=(v-min)/(max-min);fill.Size=UDim2.new(pct,0,1,0);knob.Position=UDim2.new(pct,-7,0.5,-7);lbl.Text=name..': '..string.format('%.2f',v);cfg[key]=v;if cb then cb(v)end;save()end
	apply(cfg[key]or def)
	bar.InputBegan:Connect(function(i)if i.UserInputType==Enum.UserInputType.MouseButton1 then drag=true end end)
	U.InputEnded:Connect(function(i)if i.UserInputType==Enum.UserInputType.MouseButton1 then drag=false end end)
	U.InputChanged:Connect(function(i)if drag and i.UserInputType==Enum.UserInputType.MouseMovement then local m=U:GetMouseLocation();local p=bar.AbsolutePosition;local s=bar.AbsoluteSize;local pct=math.clamp((m.X-p.X)/s.X,0,1);apply(min+(max-min)*pct)end end)
	return f
end
local function Btn(p,n,cb)local b=mk('TextButton',{Name=n..'Button',Size=UDim2.new(0,260,0,32),BackgroundColor3=Color3.fromRGB(36,36,48),BorderSizePixel=0,Text=n,TextColor3=Color3.fromRGB(235,235,245),TextScaled=true,Font=Enum.Font.Gotham},p)mk('UICorner',{CornerRadius=UDim.new(0,8)},b)b.MouseButton1Click:Connect(function()if cb then pcall(cb)end end)return b end
local function title(p,t)mk('TextLabel',{Size=UDim2.new(1,0,0,26),BackgroundTransparency=1,Text=t,TextColor3=Color3.fromRGB(235,235,245),TextXAlignment=Enum.TextXAlignment.Left,TextScaled=true,Font=Enum.Font.GothamBold},p)end

local drag,dragIn,dragStart,startPos
local function upd(i)local d=i.Position-dragStart;MF.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+d.X,startPos.Y.Scale,startPos.Y.Offset+d.Y);SD.Position=UDim2.new(0,MF.Position.X.Offset-10,0,MF.Position.Y.Offset-10)end
TB.InputBegan:Connect(function(i)if i.UserInputType==Enum.UserInputType.MouseButton1 then drag=true;dragStart=i.Position;startPos=MF.Position;i.Changed:Connect(function()if i.UserInputState==Enum.UserInputState.End then drag=false end end)end end)
TB.InputChanged:Connect(function(i)if i.UserInputType==Enum.UserInputType.MouseMovement then dragIn=i end end)
U.InputChanged:Connect(function(i)if i==dragIn and drag then upd(i)end end)

local Combat=Tab('Combat','⚔️');local Move=Tab('Movement','🏃');local Util=Tab('Utility','🔧');local Visual=Tab('Visual','👁️');local Quests=Tab('Quests','📋');local Shops=Tab('Shops','🛒');local Tele=Tab('Teleport','🧭');local HealthT=Tab('Health','❤️');local Potions=Tab('Potions','🧪');local Conf=Tab('Config','⚙️')

local CScroll=mk('ScrollingFrame',{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,ScrollBarThickness=6,CanvasSize=UDim2.new(0,0,0,0)},Combat)
local CLayout=mk('UIListLayout',{Padding=UDim.new(0,10),SortOrder=Enum.SortOrder.LayoutOrder},CScroll)
CLayout:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()CScroll.CanvasSize=UDim2.new(0,0,0,CLayout.AbsoluteContentSize.Y+12)end)
local UScroll=mk('ScrollingFrame',{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,ScrollBarThickness=6,CanvasSize=UDim2.new(0,0,0,0)},Util)
local ULayout=mk('UIListLayout',{Padding=UDim.new(0,10),SortOrder=Enum.SortOrder.LayoutOrder},UScroll)
ULayout:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()UScroll.CanvasSize=UDim2.new(0,0,0,ULayout.AbsoluteContentSize.Y+12)end)

local TR=mk('Frame',{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1},Tele)
local LC=mk('ScrollingFrame',{Name='LeftCol',Size=UDim2.new(0.55,-8,1,0),BackgroundTransparency=1,ScrollBarThickness=6,CanvasSize=UDim2.new(0,0,0,0)},TR)
local LL=mk('UIListLayout',{Padding=UDim.new(0,8),SortOrder=Enum.SortOrder.LayoutOrder},LC)
LL:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()LC.CanvasSize=UDim2.new(0,0,0,LL.AbsoluteContentSize.Y+20)end)
local RC=mk('ScrollingFrame',{Name='RightCol',Size=UDim2.new(0.45,0,1,0),Position=UDim2.new(0.55,8,0,0),BackgroundTransparency=1,ScrollBarThickness=6,CanvasSize=UDim2.new(0,0,0,0)},TR)
local RL=mk('UIListLayout',{Padding=UDim.new(0,8),SortOrder=Enum.SortOrder.LayoutOrder},RC)
RL:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()RC.CanvasSize=UDim2.new(0,0,0,RL.AbsoluteContentSize.Y+20)end)

local function instAt(parts)local cur=workspace;for _,n in ipairs(parts)do if not cur or not cur.FindFirstChild then return nil end;cur=cur:FindFirstChild(n)end;return cur end
local function tpTo(t)local c,_,hrp=charHum();if not(c and hrp and t)then return end;local cf=t:IsA('BasePart')and t.CFrame or(t:IsA('Model')and t:GetPivot()or nil);if not cf then return end;local d=CFrame.new(cf.Position+cf.LookVector*4+Vector3.new(0,3,0),cf.Position+cf.LookVector*5);c:PivotTo(d)end
local function addTp(p,parts,label)Btn(p,label,function()local i=instAt(parts);if i then tpTo(i)end end)end

title(RC,'Players')
local PL=mk('Frame',{Size=UDim2.new(1,0,0,0),BackgroundTransparency=1},RC)
local PLL=mk('UIListLayout',{Padding=UDim.new(0,8),SortOrder=Enum.SortOrder.LayoutOrder},PL)
PLL:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()PL.Size=UDim2.new(1,0,0,PLL.AbsoluteContentSize.Y)end)
local pbtn={}
local function mkPB(plr)return Btn(PL,plr.Name,function()local c=plr.Character;local hrp=c and c:FindFirstChild('HumanoidRootPart');if hrp then local cf=CFrame.new(hrp.Position+Vector3.new(0,3,0),hrp.Position+hrp.CFrame.LookVector*2);local mc=LP.Character;if mc then pcall(function()mc:PivotTo(cf)end)end end end)end
local function refresh()for pl,b in pairs(pbtn)do pcall(function()b:Destroy()end);pbtn[pl]=nil end;for _,pl in ipairs(P:GetPlayers())do if pl~=LP then pbtn[pl]=mkPB(pl)end end end
refresh()
P.PlayerAdded:Connect(function(pl)if pl~=LP then pbtn[pl]=mkPB(pl)end end)
P.PlayerRemoving:Connect(function(pl)if pbtn[pl]then pcall(function()pbtn[pl]:Destroy()end);pbtn[pl]=nil end end)
title(RC,'Saved Position')
local row=mk('Frame',{Size=UDim2.new(1,0,0,0),BackgroundTransparency=1},RC)
local rowL=mk('UIListLayout',{Padding=UDim.new(0,6),SortOrder=Enum.SortOrder.LayoutOrder},row)
Btn(row,'Save Place',function()local _,_,hrp=charHum();if hrp then _G.__SavedCFrame=hrp.CFrame end end)
Btn(row,'Teleport To Save',function()local cf=_G.__SavedCFrame;local c=LP.Character;if cf and c then pcall(function()c:PivotTo(cf)end)end end)
rowL:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()row.Size=UDim2.new(1,0,0,rowL.AbsoluteContentSize.Y)end)

title(LC,'Stores')
addTp(LC,{'Pads','ExoticStore','1'},'Exotic Store');addTp(LC,{'Pads','ExoticStore2','1'},'Dark Exotic Store')
addTp(LC,{'Pads','Store','1'},'Starter Store');addTp(LC,{'Pads','Store','2'},'Supermarket');addTp(LC,{'Pads','Store','3'},'Gym Store')
addTp(LC,{'Pads','Store','4'},'Necklace Store');addTp(LC,{'Pads','Store','5'},'Melee Store');addTp(LC,{'Pads','Store','6'},'Premium Shop')
addTp(LC,{'Pads','Store','7'},'Armour Shop 1');addTp(LC,{'Pads','Store','8'},'Armour Shop 2');addTp(LC,{'Pads','Store','9'},'Tower Store')
title(LC,'Wand Stores')
addTp(LC,{'Pads','Wands','1'},'Wand Store 1');addTp(LC,{'Pads','Wands','2'},'Wand Store 2')
title(LC,'Weight Stores')
for i=1,5 do addTp(LC,{'Pads','Weight',tostring(i)},'Weight Store '..i)end
title(LC,'Stand Stores')
addTp(LC,{'Pads','StandIndex','1'},'Stand Store 1');addTp(LC,{'Pads','StandIndex','2'},'Greater Stands');addTp(LC,{'Pads','StandIndex','3'},'Demonic Stands')
title(LC,'Deluxo Upgrades')
addTp(LC,{'Pads','DeluxoUpgrade','Credits'},'Deluxo Upgrade')
title(LC,'Questlines')
addTp(LC,{'Pads','MainTasks','MainTask'},'Main Questline');addTp(LC,{'Pads','MainTasks','AQuest'},'Extra Questline')
addTp(LC,{'Pads','MainTasks','LucaTask'},'Luca Questline');addTp(LC,{'Pads','MainTasks','ReaperTask'},'Reaper Questline')
addTp(LC,{'Pads','MainTasks','GladiatorTask'},'Gladiator Questline');addTp(LC,{'Pads','MainTasks','TowerFacility'},'Tower Questline')
addTp(LC,{'Pads','MainTasks','AncientQuests'},'Ancient Questline');addTp(LC,{'Pads','MainTasks','TankQuests'},'Defence Questline')
addTp(LC,{'Pads','MainTasks','PowerQuests'},'Power Questline');addTp(LC,{'Pads','MainTasks','MagicQuests'},'Magic Questline')
addTp(LC,{'Pads','MainTasks','MobilityQuests'},'Mobility Questline')
title(LC,'Side Tasks')
addTp(LC,{'Pads','SideTasks','1'},'Dishes Side Task');addTp(LC,{'Pads','SideTasks','2'},'Spawn Mob Task')
addTp(LC,{'Pads','SideTasks','3'},'City Mob Tasks 1');addTp(LC,{'Pads','SideTasks','4'},'City Mob Tasks 2')
addTp(LC,{'Pads','SideTasks','5'},'Ninja Mob Tasks');addTp(LC,{'Pads','SideTasks','7'},'Arena Mob Tasks')
title(LC,'Experiments')
addTp(LC,{'Experiment','FloorHitbox'},'Mobility Experiment');addTp(LC,{'Experiment','SurvivalHitbox'},'Health Experiment')
addTp(LC,{'Pads','Telekinesis','Telekinesis'},'Psychic Experiment');addTp(LC,{'WallGame','WallHitbox'},'Power Experiment')
addTp(LC,{'Experiment','Energy','15','Part'},'Magic Experiment')

local NC={conn=nil,char=nil,desc=nil,orig={}}
local function ncRec(p)if not NC.orig[p]then NC.orig[p]=p.CanCollide end end
local function ncPart(p)if p:IsA('BasePart')then ncRec(p);p.CanCollide=false end end
local function ncAll()local c=LP.Character;if not c then return end;for _,p in ipairs(c:GetDescendants())do ncPart(p)end end
local function ncRestore()for p,w in pairs(NC.orig)do if p and p.Parent then pcall(function()p.CanCollide=w end)end end;table.clear(NC.orig)end
local function TNoClip(on)
	getgenv().NoClip=on
	if on then
		if NC.conn then NC.conn:Disconnect()end;if NC.char then NC.char:Disconnect()end;if NC.desc then NC.desc:Disconnect()end
		ncAll();NC.conn=R.Stepped:Connect(function()if getgenv().NoClip then ncAll()end end)
		NC.char=LP.CharacterAdded:Connect(function(c)if getgenv().NoClip then table.clear(NC.orig);task.wait(0.1);ncAll();if NC.desc then NC.desc:Disconnect()end;NC.desc=c.DescendantAdded:Connect(function(i)if getgenv().NoClip then ncPart(i)end end)end end)
		local c=LP.Character;if c then if NC.desc then NC.desc:Disconnect()end;NC.desc=c.DescendantAdded:Connect(function(i)if getgenv().NoClip then ncPart(i)end end)end
	else
		if NC.conn then NC.conn:Disconnect()NC.conn=nil end;if NC.char then NC.char:Disconnect()NC.char=nil end;if NC.desc then NC.desc:Disconnect()NC.desc=nil end;ncRestore()
	end
end

local function TAFK(on)getgenv().GraphicsOptimization=on;pcall(function()settings().Rendering.QualityLevel=on and 1 or 21;settings().Physics.PhysicsSendRate=on and 1 or 60 end)end

local Adv={lighting={},terrain={},conns={}}
local function TGfxAdv(on)
	getgenv().GraphicsOptimizationAdvanced=on
	local Ter=workspace:FindFirstChildOfClass('Terrain')
	local function set(b,i,p,v)if Adv[b][i]==nil then Adv[b][i]={}end;if Adv[b][i][p]==nil then local ok,old=pcall(function()return i[p]end);if ok then Adv[b][i][p]=old end end;pcall(function()i[p]=v end)end
	local function restore()for t,insts in pairs(Adv)do if t~='conns'then for i,props in pairs(insts)do for pr,ov in pairs(props)do pcall(function()i[pr]=ov end)end end Adv[t]={}end end;for _,c in ipairs(Adv.conns)do pcall(function()c:Disconnect()end)end Adv.conns={} end
	if not on then restore();return end
	set('lighting',L,'Brightness',2);set('lighting',L,'ClockTime',14);set('lighting',L,'GlobalShadows',false);set('lighting',L,'ShadowSoftness',0);set('lighting',L,'EnvironmentDiffuseScale',0);set('lighting',L,'EnvironmentSpecularScale',0)
	for _,o in ipairs(L:GetChildren())do local c=o.ClassName
		if c=='BloomEffect'or c=='DepthOfFieldEffect'or c=='ColorCorrectionEffect'or c=='SunRaysEffect'or c=='BlurEffect'then set('lighting',o,'Enabled',false)
		elseif c=='Atmosphere'then set('lighting',o,'Density',0);set('lighting',o,'Haze',0);set('lighting',o,'Glare',0)
		elseif c=='Clouds'then set('lighting',o,'Coverage',0);set('lighting',o,'Density',0)end
	end
	if Ter then set('terrain',Ter,'Decoration',false);set('terrain',Ter,'WaterReflectance',0);set('terrain',Ter,'WaterTransparency',1);set('terrain',Ter,'WaterWaveSize',0);set('terrain',Ter,'WaterWaveSpeed',0)end
	local function simple(i)local c=i.ClassName
		if c=='ParticleEmitter'or c=='Trail'or c=='Beam'or c=='Smoke'or c=='Fire'or c=='Sparkles'then pcall(function()i.Enabled=false end)
		elseif c=='PointLight'or c=='SpotLight'or c=='SurfaceLight'then if i.Enabled~=nil then pcall(function()i.Enabled=false end)else pcall(function()i.Brightness=0 end)end
		elseif c=='Decal'or c=='Texture'then pcall(function()i.Transparency=1 end)
		elseif c=='MeshPart'then pcall(function()i.RenderFidelity=Enum.RenderFidelity.Performance end)end
	end
	for _,d in ipairs(workspace:GetDescendants())do simple(d)end
	table.insert(Adv.conns,workspace.DescendantAdded:Connect(simple))
end

local UOpt={applied=false,changed={},conn=nil}
local function TUltimate(on)cfg.UltimateAFKOptimization=on;save()
	local S=UOpt
	local function rest()for i=#S.changed,1,-1 do local r=S.changed[i];if r.inst and r.inst.Parent~=nil then pcall(function()r.inst[r.prop]=r.old end)end S.changed[i]=nil end;if S.conn then pcall(function()S.conn:Disconnect()end)S.conn=nil end;S.applied=false end
	if not on then rest();pcall(function()settings().Rendering.QualityLevel=21;settings().Physics.PhysicsSendRate=60 end);return end
	if S.applied then return end
	local function set(i,p,v)pcall(function()local ok,old=pcall(function()return i[p]end);if ok then table.insert(S.changed,{inst=i,prop=p,old=old})end;i[p]=v end)end
	pcall(function()settings().Rendering.QualityLevel=1;settings().Physics.PhysicsSendRate=1 end)
	set(L,'Brightness',2);set(L,'ClockTime',14);set(L,'GlobalShadows',false);set(L,'ShadowSoftness',0);set(L,'EnvironmentDiffuseScale',0);set(L,'EnvironmentSpecularScale',0)
	for _,o in ipairs(L:GetChildren())do local c=o.ClassName;if c=='BloomEffect'or c=='DepthOfFieldEffect'or c=='ColorCorrectionEffect'or c=='SunRaysEffect'or c=='BlurEffect'then set(o,'Enabled',false)
		elseif c=='Atmosphere'then set(o,'Density',0);set(o,'Haze',0);set(o,'Glare',0)
		elseif c=='Clouds'then set(o,'Coverage',0);set(o,'Density',0)end end
	local t=workspace:FindFirstChildOfClass('Terrain');if t then set(t,'Decoration',false);set(t,'WaterReflectance',0);set(t,'WaterTransparency',1);set(t,'WaterWaveSize',0);set(t,'WaterWaveSpeed',0)end
	local function simple(i)local c=i.ClassName
		if c=='ParticleEmitter'or c=='Trail'or c=='Beam'or c=='Smoke'or c=='Fire'or c=='Sparkles'then if pcall(function()return i.Enabled end)then set(i,'Enabled',false)end
		elseif c=='PointLight'or c=='SpotLight'or c=='SurfaceLight'then if pcall(function()return i.Enabled end)then set(i,'Enabled',false)else set(i,'Brightness',0)end
		elseif c=='Decal'or c=='Texture'then set(i,'Transparency',1)
		elseif c=='MeshPart'then set(i,'RenderFidelity',Enum.RenderFidelity.Performance)end
	end
	for _,d in ipairs(workspace:GetDescendants())do simple(d)end
	S.conn=workspace.DescendantAdded:Connect(simple);S.applied=true
end

local function TPlayerESP(on)
	getgenv().PlayerESP=on;if not Drawing then return end
	if getgenv().__PESP then getgenv().__PESP:Disconnect();getgenv().__PESP=nil end
	local boxes={}
	
	local function formatNumber(num)
		local absNum = math.abs(num)
		if absNum == 0 then
			return "Concealed"
		elseif absNum >= 1e18 then
			return string.format("%.2fQn", num/1e18)
		elseif absNum >= 1e15 then
			return string.format("%.2fQd", num/1e15)
		elseif absNum >= 1e12 then
			return string.format("%.2fT", num/1e12)
		elseif absNum >= 1e9 then
			return string.format("%.2fB", num/1e9)
		elseif absNum >= 1e6 then
			return string.format("%.2fM", num/1e6)
		elseif absNum >= 1e3 then
			return string.format("%.2fK", num/1e3)
		else
			return tostring(num)
		end
	end
	
	local function getPlayerStats(player)
		local success, statsFolder = pcall(function()
			return game:GetService("ReplicatedStorage").Data[player.Name].Stats
		end)
		
		if success and statsFolder then
			local defense = statsFolder:FindFirstChild('Defense')
			local power = statsFolder:FindFirstChild('Power')
			local magic = statsFolder:FindFirstChild('Magic')
			local reputation = statsFolder:FindFirstChild('Reputation')
			
			local defenseValue = defense and defense.Value or 0
			local powerValue = power and power.Value or 0
			local magicValue = magic and magic.Value or 0
			local repValue = reputation and reputation.Value or 0
			
			return defenseValue, powerValue, magicValue, repValue
		end
		return 0, 0, 0, 0
	end
	
	local function getPlayerHealth(player)
		local char = player.Character
		local humanoid = char and char:FindFirstChild("Humanoid")
		if humanoid then
			return humanoid.Health, humanoid.MaxHealth
		end
		return 0, 0
	end
	
	local function getRepColor(repValue)
		if repValue <= -25000 then
			return Color3.fromRGB(0, 0, 0) -- Black
		elseif repValue <= -10000 then
			return Color3.fromRGB(139, 0, 0) -- Dark red
		elseif repValue <= -4000 then
			return Color3.fromRGB(128, 0, 128) -- Purple
		elseif repValue <= -1 then
			return Color3.fromRGB(255, 100, 100) -- Light red
		elseif repValue == 0 then
			return Color3.fromRGB(255, 255, 255) -- White
		elseif repValue >= 1 and repValue < 4000 then
			return Color3.fromRGB(0, 255, 0) -- Green
		elseif repValue >= 4000 and repValue < 10000 then
			return Color3.fromRGB(64, 224, 208) -- Turquoise blue
		elseif repValue >= 10000 and repValue < 25000 then
			return Color3.fromRGB(173, 216, 230) -- Baby blue
		else
			return Color3.fromRGB(255, 255, 0) -- Yellow
		end
	end
	
	local function mkb(p)
		local b=Drawing.new('Square');b.Filled=false;b.Thickness=2;b.Visible=false
		local t=Drawing.new('Text');t.Size=24;t.Center=true;t.Outline=true;t.OutlineColor=Color3.new(0,0,0);t.Visible=false
		local healthText=Drawing.new('Text');healthText.Size=22;healthText.Center=true;healthText.Outline=true;healthText.OutlineColor=Color3.new(0,0,0);healthText.Color=Color3.fromRGB(100,255,100);healthText.Visible=false
		local defenseText=Drawing.new('Text');defenseText.Size=20;defenseText.Center=true;defenseText.Outline=true;defenseText.OutlineColor=Color3.new(0,0,0);defenseText.Color=Color3.fromRGB(0,150,255);defenseText.Visible=false
		local powerText=Drawing.new('Text');powerText.Size=20;powerText.Center=true;powerText.Outline=true;powerText.OutlineColor=Color3.new(0,0,0);powerText.Color=Color3.fromRGB(255,50,50);powerText.Visible=false
		local magicText=Drawing.new('Text');magicText.Size=20;magicText.Center=true;magicText.Outline=true;magicText.OutlineColor=Color3.new(0,0,0);magicText.Color=Color3.fromRGB(255,100,255);magicText.Visible=false
		local repText=Drawing.new('Text');repText.Size=20;repText.Center=true;repText.Outline=true;repText.OutlineColor=Color3.new(0,0,0);repText.Color=Color3.fromRGB(255,255,255);repText.Visible=false
		boxes[p]={b=b,t=t,health=healthText,defense=defenseText,power=powerText,magic=magicText,rep=repText}
	end
	local function rm(p)
		local e=boxes[p];if not e then return end
		pcall(function()e.b:Remove()e.t:Remove()e.health:Remove()e.defense:Remove()e.power:Remove()e.magic:Remove()e.rep:Remove()end);boxes[p]=nil
	end
	if on then
		getgenv().__PESP=game:GetService('RunService').RenderStepped:Connect(function()
			if not getgenv().PlayerESP then for p in pairs(boxes)do rm(p)end return end
			for _,p in ipairs(game:GetService('Players'):GetPlayers())do
				if p~=LP and p.Character and p.Character:FindFirstChild('Head')then
					if not boxes[p]then mkb(p)end
					local e=boxes[p];local head=p.Character.Head
					local pos,vis=Cam:WorldToViewportPoint(head.Position)
					if not vis then e.b.Visible=false;e.t.Visible=false;e.health.Visible=false;e.defense.Visible=false;e.power.Visible=false;e.magic.Visible=false;e.rep.Visible=false else
						local d=(Cam.CFrame.Position-head.Position).Magnitude
						local sz=math.clamp((100/math.max(d,1))*100,20,80)
						local col=Color3.fromHSV((tick()*0.2)%1,1,1)
						local boxPos=Vector2.new(pos.X-sz/2,pos.Y-sz/2)

						e.b.Position=boxPos;e.b.Size=Vector2.new(sz,sz);e.b.Color=col;e.b.Visible=true

						e.t.Text=p.Name;e.t.Position=Vector2.new(pos.X,pos.Y-sz/2-18);e.t.Color=col;e.t.Visible=true

						-- Get player health and display as current/max
						local currentHealth, maxHealth = getPlayerHealth(p)
						e.health.Text = formatNumber(currentHealth) .. "/" .. formatNumber(maxHealth)
						e.health.Position = Vector2.new(pos.X,boxPos.Y+sz/2+16)
						e.health.Visible = true
						
						-- Get player stats and display all three
						local defenseValue, powerValue, magicValue, repValue = getPlayerStats(p)
						
						-- Defense - Blue
						e.defense.Text = formatNumber(defenseValue)
						e.defense.Position = Vector2.new(pos.X, boxPos.Y+sz/2+38)
						e.defense.Visible = true
						
						-- Power - Red
						e.power.Text = formatNumber(powerValue)
						e.power.Position = Vector2.new(pos.X, boxPos.Y+sz/2+60)
						e.power.Visible = true
						
						-- Magic - Pink
						e.magic.Text = formatNumber(magicValue)
						e.magic.Position = Vector2.new(pos.X, boxPos.Y+sz/2+82)
						e.magic.Visible = true
						
						-- Reputation - Color coded based on value
						e.rep.Text = formatNumber(repValue)
						e.rep.Color = getRepColor(repValue)
						e.rep.Position = Vector2.new(pos.X, boxPos.Y+sz/2+104)
						e.rep.Visible = true
					end
				end
			end
			for p in pairs(boxes)do if (not p) or (not p.Character) or (not p.Character:FindFirstChild('Head')) then rm(p)end end
		end)
	else
		for p in pairs(boxes)do rm(p)end
	end
end

local function TMobESP(on)
    if on then
        -- Enemy ESP (boxes + correct names; Catacombs Guards share one color)
        -- Highlights all NPCs under workspace.Enemies["1".."n"] through walls.
        
        local Players = game:GetService("Players")
        local RunService = game:GetService("RunService")
        local LocalPlayer = Players.LocalPlayer
        
        -- Bucket -> Display Name
        local BUCKET_NAME = {
            ["1"]="Goblin", ["2"]="Thug", ["3"]="Gym Rat", ["4"]="Veteran", ["5"]="Yakuza",
            ["6"]="Mutant", ["7"]="Samurai", ["8"]="Ninja", ["9"]="Animatronic",
            ["10"]="Catacombs Guard", ["11"]="Catacombs Guard", ["12"]="Catacombs Guard",
            ["13"]="Demon", ["14"]="The Judger", ["15"]="Dominator", ["16"]="?", ["17"]="The Emperor",
            ["18"]="Ancient Gladiator", ["19"]="Old Knight",
        }
        
        -- Same color for all Catacombs Guards (10,11,12)
        local CATACOMBS_IDS = { ["10"]=true, ["11"]=true, ["12"]=true }
        local CATACOMBS_COLOR = Color3.fromRGB(0, 255, 140)
        
        getgenv().EnemyESP2 = getgenv().EnemyESP2 or {}
        local M = getgenv().EnemyESP2
        if M.enabled then return end
        M.enabled = false
        M._conns = {}
        M._records = {} -- rootModel -> {box, bill, billLabel, part, conns}
        
        local HOLDER = Instance.new("Folder")
        HOLDER.Name = "EnemyESP2_Holder"
        pcall(function() HOLDER.Parent = game:GetService("CoreGui") end)
        if not HOLDER.Parent then
            HOLDER.Parent = LocalPlayer:WaitForChild("PlayerGui")
        end
        
        local function enemiesRoot() return workspace:FindFirstChild("Enemies") end
        
        local function bucketOf(inst)
            local root = enemiesRoot()
            if not root then return nil end
            local node = inst
            while node and node ~= root do
                if node.Parent == root and tonumber(node.Name) ~= nil then
                    return node
                end
                node = node.Parent
            end
            return nil
        end
        
        local function colorForBucketName(id)
            id = tostring(id or "")
            if CATACOMBS_IDS[id] then
                return CATACOMBS_COLOR
            end
            local n = tonumber(id) or 0
            local hue = (n % 12) / 12
            return Color3.fromHSV(hue, 0.85, 1)
        end
        
        -- Avoid weapon/accessory parts
        local WEAPON_HINTS = {"weapon","sword","blade","gun","bow","staff","club","knife","axe","mace","spear"}
        local function looksLikeWeapon(name)
            name = string.lower(tostring(name or ""))
            for _, w in ipairs(WEAPON_HINTS) do
                if string.find(name, w, 1, true) then return true end
            end
            return false
        end
        local function isAccessoryPart(p)
            while p and p.Parent do
                if p:IsA("Accessory") then return true end
                p = p.Parent
            end
            return false
        end
        
        local function pickBodyPart(model)
            for _, n in ipairs({"HumanoidRootPart","UpperTorso","LowerTorso","Torso","Head"}) do
                local p = model:FindFirstChild(n)
                if p and p:IsA("BasePart") then return p end
            end
            if model.PrimaryPart and model.PrimaryPart:IsA("BasePart") then return model.PrimaryPart end
            local best, score = nil, -1
            for _, p in ipairs(model:GetDescendants()) do
                if p:IsA("BasePart") and p.Parent then
                    if not isAccessoryPart(p) and not looksLikeWeapon(p.Name) and p.Transparency < 1 then
                        local s = p.Size; local sc = s.X*s.Y*s.Z
                        if sc > score then best, score = p, sc end
                    end
                end
            end
            return best or model:FindFirstChildWhichIsA("BasePart", true)
        end
        
        local function getDisplayName(model)
            local b = bucketOf(model)
            local id = b and b.Name or nil
            if id and BUCKET_NAME[id] and BUCKET_NAME[id] ~= "" then
                return BUCKET_NAME[id]
            end
            local hum = model:FindFirstChildOfClass("Humanoid")
            if hum and hum.DisplayName and hum.DisplayName ~= "" then return hum.DisplayName end
            for _, a in ipairs({"EnemyName","DisplayName","NameOverride","MobType","Type"}) do
                local v = model:GetAttribute(a); if v and tostring(v) ~= "" then return tostring(v) end
            end
            return model.Name
        end
        
        local function makeBox(part, col)
            local box = Instance.new("BoxHandleAdornment")
            box.Name = "EnemyESP2_Box"
            box.ZIndex = 5
            box.Color3 = col
            box.AlwaysOnTop = true
            box.Adornee = part
            box.Transparency = 0.2
            box.Size = part.Size + Vector3.new(0.2,0.2,0.2)
            box.Parent = HOLDER
            return box
        end
        
        local function makeBill(part, text, col)
            local bill = Instance.new("BillboardGui")
            bill.Name = "EnemyESP2_Label"
            bill.Adornee = part
            bill.AlwaysOnTop = true
            bill.Size = UDim2.new(0, 170, 0, 22)
            bill.StudsOffset = Vector3.new(0, 3, 0)
            bill.MaxDistance = 1e6
            bill.Parent = HOLDER
            
            local tl = Instance.new("TextLabel")
            tl.BackgroundTransparency = 1
            tl.Size = UDim2.new(1, 0, 1, 0)
            tl.Font = Enum.Font.GothamBold
            tl.TextSize = 14
            tl.TextColor3 = col
            tl.TextStrokeTransparency = 0.3
            tl.Text = text
            tl.Parent = bill
            return bill, tl
        end
        
        local function clearRecord(model)
            local rec = M._records[model]
            if not rec then return end
            for _, c in ipairs(rec.conns or {}) do pcall(function() c:Disconnect() end) end
            if rec.box then rec.box:Destroy() end
            if rec.bill then rec.bill:Destroy() end
            M._records[model] = nil
        end
        
        local function attachToModel(model)
            if M._records[model] then return end
            -- Must be under a numeric bucket and not a player character
            if Players:GetPlayerFromCharacter(model) then return end
            if not bucketOf(model) then return end
            
            local part = pickBodyPart(model); if not part then return end
            local bucket = bucketOf(model)
            local id = bucket.Name
            local col = colorForBucketName(id)
            local label = getDisplayName(model)
            
            local box = makeBox(part, col)
            local bill, billLabel = makeBill(part, label, col)
            
            local rec = {box=box, bill=bill, billLabel=billLabel, part=part, conns={}}
            M._records[model] = rec
            
            table.insert(rec.conns, part:GetPropertyChangedSignal("Size"):Connect(function()
                if rec.box then rec.box.Size = part.Size + Vector3.new(0.2,0.2,0.2) end
            end))
            
            -- If a better body part appears later (e.g., HRP spawns), retarget once
            table.insert(rec.conns, model.DescendantAdded:Connect(function(inst)
                if inst:IsA("BasePart") then
                    local better = pickBodyPart(model)
                    if better and better ~= rec.part then
                        rec.part = better
                        if rec.box then rec.box.Adornee = better end
                        if rec.bill then rec.bill.Adornee = better end
                    end
                end
            end))
            
            -- Keep name in sync if attributes/humanoid change (optional)
            local function refreshName()
                if rec.billLabel then rec.billLabel.Text = getDisplayName(model) end
            end
            local hum = model:FindFirstChildOfClass("Humanoid")
            if hum then
                table.insert(rec.conns, hum:GetPropertyChangedSignal("DisplayName"):Connect(refreshName))
            end
            for _, a in ipairs({"EnemyName","DisplayName","NameOverride","MobType","Type"}) do
                table.insert(rec.conns, model:GetAttributeChangedSignal(a):Connect(refreshName))
            end
            
            table.insert(rec.conns, model.AncestryChanged:Connect(function(_, parent)
                if parent == nil then clearRecord(model) end
            end))
        end
        
        local function tryAttach(inst)
            local root = enemiesRoot(); if not root then return end
            local node = inst
            while node and node ~= root do
                if node:IsA("Model") and bucketOf(node) then
                    attachToModel(node); return
                end
                node = node.Parent
            end
        end
        
        local function fullScan()
            local root = enemiesRoot(); if not root then return end
            for _, bucket in ipairs(root:GetChildren()) do
                if tonumber(bucket.Name) ~= nil then
                    for _, inst in ipairs(bucket:GetDescendants()) do
                        if inst:IsA("BasePart") or inst:IsA("Model") then tryAttach(inst) end
                    end
                end
            end
        end
        
        function M.Disable()
            if not M.enabled then return end
            for _, c in ipairs(M._conns) do pcall(function() c:Disconnect() end) end
            M._conns = {}
            for m in pairs(M._records) do clearRecord(m) end
            HOLDER:ClearAllChildren()
            M.enabled = false
            print("[EnemyESP2] disabled")
        end
        
        function M.Enable()
            if M.enabled then return end
            M.enabled = true
            fullScan()
            local root = enemiesRoot()
            if root then
                table.insert(M._conns, root.DescendantAdded:Connect(function(inst)
                    task.defer(function() tryAttach(inst) end)
                end))
                table.insert(M._conns, root.DescendantRemoving:Connect(function(inst)
                    if inst:IsA("Model") then clearRecord(inst) end
                end))
            end
            -- periodic pass for streaming
            table.insert(M._conns, RunService.Heartbeat:Connect(function() fullScan() end))
            print("[EnemyESP2] enabled")
        end
        
        M.Enable()
    else
        -- Disable ESP when toggle is turned off
        if getgenv().EnemyESP2 and getgenv().EnemyESP2.Disable then
            getgenv().EnemyESP2:Disable()
        end
    end
end

local function RemoveClutter()
	for _,o in ipairs(L:GetChildren())do local c=o.ClassName
		if c=='BloomEffect'or c=='DepthOfFieldEffect'or c=='ColorCorrectionEffect'or c=='SunRaysEffect'or c=='BlurEffect'then pcall(function()o.Enabled=false end)
		elseif c=='Atmosphere'or o.Name=='Atmosphere'or o.Name=='SunRays'then pcall(function()o:Destroy()end)end
	end
	local function nuke(n)local f=workspace:FindFirstChild(n);if f then for _,ch in ipairs(f:GetChildren())do pcall(function()ch:Destroy()end)end end end
	for _,n in ipairs({'Trees','CityProps','Props','Decoration','Grass','VFX','Clouds'})do nuke(n)end
	for _,v in ipairs(workspace:GetDescendants())do pcall(function()
		if v:IsA('ParticleEmitter')or v:IsA('Trail')or v:IsA('Beam')or v:IsA('Smoke')or v:IsA('Fire')or v:IsA('Sparkles')then v.Enabled=false
		elseif v:IsA('Decal')or v:IsA('Texture')then v.Transparency=1
		elseif v:IsA('PointLight')or v:IsA('SpotLight')or v:IsA('SurfaceLight')then if v.Enabled~=nil then v.Enabled=false else v.Brightness=0 end
		elseif v:IsA('MeshPart')then v.RenderFidelity=Enum.RenderFidelity.Performance end
	end)end
end

local function fireAt(v3)local a=ev('Events','Other','Ability');pcall(function()a:InvokeServer('Fireball',v3)end)end
local function UFA(on)
	getgenv().UniversalFireBallAimbot=on;if not on then return end
	task.spawn(function()
		while getgenv().UniversalFireBallAimbot do
			pcall(function()
				local e=workspace:FindFirstChild('Enemies');if not e then return end
				local _,_,hrp=charHum();if not hrp then return end
				local mp,bestD,best=hrp.Position,math.huge,nil
				for _,b in ipairs(e:GetChildren())do
					for _,m in ipairs(b:GetChildren())do
						local p=m:FindFirstChild('HumanoidRootPart');local dtag=m:FindFirstChild('Dead')
						if p and (not dtag or dtag.Value~=true)then local d=(mp-p.Position).Magnitude;if d<bestD then bestD=d;best=p end end
					end
				end
				if best then fireAt(best.Position)end
			end)
			task.wait(math.max(0.01,tonumber(cfg.universalFireballInterval)or 1.0))
		end
	end)
end

local function CatAimbot(on)
	getgenv().FireBallAimbot=on;if not on then return end
	local order={15,14,12,17,13,10,4};local idx=1;local last=0
	task.spawn(function()
		while getgenv().FireBallAimbot do
			local pl=P.LocalPlayer;if pl and pl.Character and pl.Character:FindFirstChild('HumanoidRootPart')then
				local hum=pl.Character:FindFirstChild('Humanoid');if hum and hum.Health<=0 then getgenv().FireBallAimbot=false;cfg.FireBallAimbot=false;save();break end
				local now=tick();if(now-last)>=(cfg.cityFireballCooldown or 0.2)then
					local e=workspace:FindFirstChild('Enemies');if e then
						local folder=e:FindFirstChild(tostring(order[idx]))
						if folder and folder:IsA('Folder')then
							local pos=Vector3.new(order[idx]*20,5,order[idx]*10)
							for _,ch in pairs(folder:GetChildren())do if ch:IsA('Model')and ch:FindFirstChild('HumanoidRootPart')then pos=ch.HumanoidRootPart.Position;break elseif ch:IsA('BasePart')then pos=ch.Position;break end end
							local ok=pcall(function()fireAt(pos)end);last=now;idx=idx%#order+1;task.wait(ok and 0.3 or 0.1)
						else idx=idx%#order+1;task.wait(0.1)end
					else task.wait(0.5)end
				else task.wait(0.05)end
			else task.wait(0.1)end
		end
	end)
end

local function CityAimbot(on)
	getgenv().FireBallAimbotCity=on;if not on then return end
	local o={5,9,8,6,3};local idx,last=1,0
	task.spawn(function()
		while getgenv().FireBallAimbotCity do
			local c,h,hrp=charHum()
			if not hrp then task.wait(0.1) else
				if h and h.Health<=0 then getgenv().FireBallAimbotCity=false;cfg.FireBallAimbotCity=false;save();break end
				local now=tick();if(now-last)>=(cfg.cityFireballCooldown or 0.5)then
					local e=workspace:FindFirstChild('Enemies');if e then
						local folder=e:FindFirstChild(tostring(o[idx]))
						if folder and folder:IsA('Folder')then
							local pos=Vector3.new(o[idx]*20,5,o[idx]*10)
							for _,ch in ipairs(folder:GetChildren())do local p=ch:IsA('Model')and ch:FindFirstChild('HumanoidRootPart')or(ch:IsA('BasePart')and ch);if p then pos=p.Position;break end end
							fireAt(pos);last=now;idx=idx%#o+1;task.wait(0.3)
						else idx=idx%#o+1;task.wait(0.1)end
					else task.wait(0.5)end
				else task.wait(0.05)end
			end
		end
	end)
end

local function sideLoop(gk,ck,id)
	getgenv()[gk]=true
	task.spawn(function()
		while getgenv()[gk] do
			pcall(function()
				local _,h=charHum();if h and h.Health<=0 then getgenv()[gk]=false;cfg[ck]=false;save();return end
				local o=ev('Events','Other');o:WaitForChild('StartSideTask',9e9):FireServer(id);if id==1 then pcall(function()o:WaitForChild('CleanDishes',9e9):FireServer()end)end
				o:WaitForChild('ClaimSideTask',9e9):FireServer(id)
			end)
			task.wait(math.random(50,70))
		end
	end)
end
local function TWash(on)getgenv().AutoWashDishes=on;if on then sideLoop('AutoWashDishes','AutoWashDishes',1)end end
local function TNinja(on)cfg.AutoNinjaSideTask=on;save();if on then sideLoop('AutoNinjaSideTask','AutoNinjaSideTask',9)else getgenv().AutoNinjaSideTask=false end end
local function TAnim(on)cfg.AutoAnimatronicsSideTask=on;save();if on then sideLoop('AutoAnimatronicsSideTask','AutoAnimatronicsSideTask',10)else getgenv().AutoAnimatronicsSideTask=false end end
local function TMut(on)cfg.AutoMutantsSideTask=on;save();if on then sideLoop('AutoMutantsSideTask','AutoMutantsSideTask',7)else getgenv().AutoMutantsSideTask=false end end

local function TDualExotic(on)
	cfg.DualExoticShop=on;save();getgenv().DualExoticShop=on;if not on then return end
	task.spawn(function()
		local function base(p)if not p then return nil end;if p:IsA('BasePart')then return p end;if p:IsA('Model')then return p:FindFirstChildWhichIsA('BasePart')end end
		task.wait(10)
		while getgenv().DualExoticShop do
			pcall(function()
				local _,h,hrp=charHum();if not hrp or(h and h.Health<=0)then return end
				local spent=RS:WaitForChild('Events'):WaitForChild('Spent')
				local r1=spent:WaitForChild('BuyExotic')
				local r2=RS:WaitForChild('Events'):WaitForChild('GiveItemRequest2')
				local r2Old=spent:WaitForChild('BuyExotic2')
				local fr=LP.PlayerGui:WaitForChild('Frames')
				local g1=fr:WaitForChild('ExoticStore')
				local g2=fr:WaitForChild('ExoticStore2')
				local p1=base(workspace:WaitForChild('Pads'):WaitForChild('ExoticStore'):WaitForChild('1'))
				local p2=base(workspace:WaitForChild('Pads'):WaitForChild('ExoticStore2'):WaitForChild('1'))
				local function buy(ui,remote,isStore2)
					local list=ui and ui:FindFirstChild('Content')and ui.Content:FindFirstChild('ExoticList');if not list then return end
					for _,v in pairs(list:GetChildren())do
						local i=v:FindFirstChild('Info');local i2=i and i:FindFirstChild('Info')
						if i2 and i2.Text=='POTION' then
							local n=tonumber(v.Name:match('%d+'))
							if n then
								pcall(function()remote:FireServer(n)end)
								if isStore2 then pcall(function()r2Old:FireServer(n)end) end
								task.wait(0.1)
							end
						end
					end
				end
				local orig=hrp.CFrame
				if p1 then hrp.CFrame=p1.CFrame+Vector3.new(0,3,0);task.wait(2);buy(g1,r1,false);hrp.CFrame=orig;task.wait(2)end
				if p2 then hrp.CFrame=p2.CFrame+Vector3.new(0,3,0);task.wait(2);buy(g2,r2,true);hrp.CFrame=orig;task.wait(2)end
			end)
			for i=1,600 do if not getgenv().DualExoticShop then break end task.wait(1)end
		end
	end)
end

local function TVend(on)getgenv().VendingPotionAutoBuy=on;if on then task.spawn(function()local b=ev('Events','VendingMachine','BuyPotion');local a={{2,5000},{3,15000},{1,1500},{4,150000},{5,1500000}}
	while getgenv().VendingPotionAutoBuy do for _,x in ipairs(a)do if not getgenv().VendingPotionAutoBuy then break end pcall(function()b:FireServer(unpack(x))end)for i=1,60 do if not getgenv().VendingPotionAutoBuy then break end task.wait(1)end end end
end)end end

local function TStatWH(on)cfg.StatWebhook15m=on;save();getgenv().StatWebhook15m=on;if not on then return end
	task.spawn(function()
		local st=RS:WaitForChild('Data'):WaitForChild(LP.Name):WaitForChild('Stats')
		local op,od,oh,om,oy,omob=st.Power.Value,st.Defense.Value,st.Health.Value,st.Magic.Value,st.Psychics.Value,st.Mobility.Value
		local function fmt(n)n=tonumber(n)or 0;if n>=1e15 then return string.format('%.2f',n/1e15)..'qd' end;if n>=1e12 then return string.format('%.2f',n/1e12)..'t' end
			if n>=1e9 then return string.format('%.2f',n/1e9)..'b'end;if n>=1e6 then return string.format('%.2f',n/1e6)..'m'end;if n>=1e3 then return string.format('%.2f',n/1e3)..'k'end return tostring(n)end
		while getgenv().StatWebhook15m do for i=1,900 do if not getgenv().StatWebhook15m then break end task.wait(1)end;if not getgenv().StatWebhook15m then break end
			local np,nd,nh,nm,ny,nmob=st.Power.Value,st.Defense.Value,st.Health.Value,st.Magic.Value,st.Psychics.Value,st.Mobility.Value
			if np>op or nd>od or nh>oh or nm>om or ny>oy or nmob>omob then
				local t=LP.Name..' Stats Gained Last 15 Minutes'
				local d='**Power:** '..fmt(np-op)..'\n**Defense:** '..fmt(nd-od)..'\n**Health:** '..fmt(nh-oh)..'\n**Magic:** '..fmt(nm-om)..'\n**Psychics:** '..fmt(ny-oy)..'\n**Mobility:** '..fmt(nmob-omob)
				webhook('Stat Bot',t,d,nil);op,od,oh,om,oy,omob=np,nd,nh,nm,ny,nmob
			end
		end
	end)
end

local KA
local function TKA(on)cfg.KillAura=on;save();getgenv().KillAura=on;if KA then KA:Disconnect();KA=nil end;if not on then return end
	KA=R.Heartbeat:Connect(function()
		local _,_,hrp=charHum();if not hrp then return end
		local E=workspace:FindFirstChild('Enemies');if not E then return end
		for _,f in ipairs(E:GetChildren())do for _,e in ipairs(f:GetChildren())do if e:IsA('Model')then local p=e:FindFirstChild('HumanoidRootPart');local d=e:FindFirstChild('Dead')
			if p and(not d or d.Value~=true)then local dist=(hrp.Position-p.Position).Magnitude;if dist<=500 then pcall(function()RS.Events.Other.Ability:InvokeServer('Weapon')end)end end end end end
	end)
end

local SG={gui=nil,run=false}
local function TStatGui(on)cfg.StatGui=on;save();getgenv().StatGui=on;if not on then SG.run=false;if SG.gui then pcall(function()SG.gui:Destroy()end)SG.gui=nil end return end
	task.spawn(function()
		local function fmt(n)n=tonumber(n)or 0;if n>=1e18 then return string.format('%.3f',n/1e18)..'Qn'end;if n>=1e15 then return string.format('%.3f',n/1e15)..'Qd'end
			if n>=1e12 then return string.format('%.3f',n/1e12)..'T'end;if n>=1e9 then return string.format('%.3f',n/1e9)..'B'end
			if n>=1e6 then return string.format('%.3f',n/1e6)..'M'end;if n>=1e3 then return string.format('%.3f',n/1e3)..'K'end return tostring(n)end
		local function dark(c,a)return Color3.fromRGB(math.clamp(c.R*255-a,0,255),math.clamp(c.G*255-a,0,255),math.clamp(c.B*255-a,0,255))end
		local col={Power=Color3.fromRGB(220,60,60),Health=Color3.fromRGB(100,220,100),Defense=Color3.fromRGB(100,150,220),Psychic=Color3.fromRGB(140,50,180),Magic=Color3.fromRGB(210,140,255),Mobility=Color3.fromRGB(240,240,80)}
		local gui=Instance.new('ScreenGui');gui.Name='StatsGUI';gui.Parent=LP:WaitForChild('PlayerGui');SG.gui=gui
		local fr=Instance.new('Frame');fr.BackgroundColor3=Color3.fromRGB(20,20,20);fr.BorderSizePixel=1;fr.BorderColor3=Color3.fromRGB(50,50,50);fr.Position=UDim2.new(0.5,0,0.5,0);fr.Size=UDim2.new(0,500,0,350);fr.Parent=gui;fr.Active=true;fr.Draggable=true
		local st=Instance.new('UIStroke');st.Parent=fr;st.Thickness=2;st.Color=Color3.fromRGB(70,70,70);local c=Instance.new('UICorner');c.CornerRadius=UDim.new(0,12);c.Parent=fr
		local lay=Instance.new('UIListLayout');lay.Parent=fr;lay.SortOrder=Enum.SortOrder.LayoutOrder;lay.Padding=UDim.new(0,4);lay.HorizontalAlignment=Enum.HorizontalAlignment.Center;lay.FillDirection=Enum.FillDirection.Vertical;lay.VerticalAlignment=Enum.VerticalAlignment.Top
		local pad=Instance.new('UIPadding');pad.PaddingTop=UDim2.new().X;pad.PaddingBottom=UDim2.new().X;pad.PaddingLeft=UDim2.new().X;pad.PaddingRight=UDim2.new().X;pad.PaddingTop=UDim.new(0,10);pad.PaddingBottom=UDim.new(0,10);pad.PaddingLeft=UDim.new(0,10);pad.PaddingRight=UDim.new(0,10);pad.Parent=fr
		local cw,pw,bh,rp=280,160,55,5
		local function row(n,cl)
			local r=Instance.new('Frame');r.Size=UDim2.new(0,cw+pw+rp,0,bh);r.BackgroundTransparency=1;r.Parent=fr
			local rl=Instance.new('UIListLayout');rl.FillDirection=Enum.FillDirection.Horizontal;rl.HorizontalAlignment=Enum.HorizontalAlignment.Center;rl.SortOrder=Enum.SortOrder.LayoutOrder;rl.Padding=UDim.new(0,rp);rl.Parent=r
			local function box(w,cur)
				local b=Instance.new('Frame');b.Size=UDim2.new(0,w,1,0);b.BackgroundColor3=dark(cl,80)
				local ic=Instance.new('UICorner');ic.CornerRadius=UDim.new(0,8);ic.Parent=b
				local is=Instance.new('UIStroke');is.Parent=b;is.Color=Color3.fromRGB(60,60,60);is.Thickness=1
				local l=Instance.new('TextLabel');l.Size=UDim2.new(1,-12,1,0);l.Position=UDim2.new(0,6,0,0);l.BackgroundTransparency=1;l.TextColor3=cl;l.Font=Enum.Font.GothamBold;l.TextSize=28;l.Text=cur and(n..': 0')or'0/h';l.TextXAlignment=Enum.TextXAlignment.Left;l.TextYAlignment=Enum.TextYAlignment.Center;l.Parent=b
				b.Parent=r;return l
			end
			return box(cw,true),box(pw,false)
		end
		local pl,plh=row('Power',col.Power);local hl,hlh=row('Health',col.Health);local dl,dlh=row('Defense',col.Defense);local yl,ylh=row('Psychic',col.Psychic);local ml,mlh=row('Magic',col.Magic);local bl,blh=row('Mobility',col.Mobility)
		lay:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()local w=cw+pw+rp+20;local h=lay.AbsoluteContentSize.Y+20;fr.Size=UDim2.new(0,w,0,h);fr.Position=UDim2.new(0.5,-w/2,0.5,-h/2)end)
		local function stats()local s=RS:WaitForChild('Data'):WaitForChild(LP.Name):WaitForChild('Stats');return{Power=s.Power and s.Power.Value or 0,Health=s.Health and s.Health.Value or 0,Defense=s.Defense and s.Defense.Value or 0,Psychic=s.Psychics and s.Psychics.Value or 0,Magic=s.Magic and s.Magic.Value or 0,Mobility=s.Mobility and s.Mobility.Value or 0}end
		local hist,dur={},600;SG.run=true
		while SG.run and getgenv().StatGui and SG.gui do
			local now=os.clock();local s=stats();table.insert(hist,{time=now,stats=s});while #hist>0 and(now-hist[1].time>dur)do table.remove(hist,1)end
			local ph={};if #hist>1 then local first=hist[1];local el=now-first.time;for k,v in pairs(s)do local g=v-(first.stats[k]or 0);ph[k]=g*(3600/math.max(el,1))end end
			pl.Text='Power: '..fmt(s.Power);plh.Text=fmt(ph.Power or 0)..'/h';hl.Text='Health: '..fmt(s.Health);hlh.Text=fmt(ph.Health or 0)..'/h'
			dl.Text='Defense: '..fmt(s.Defense);dlh.Text=fmt(ph.Defense or 0)..'/h';yl.Text='Psychic: '..fmt(s.Psychic);ylh.Text=fmt(ph.Psychic or 0)..'/h'
			ml.Text='Magic: '..fmt(s.Magic);mlh.Text=fmt(ph.Magic or 0)..'/h';bl.Text='Mobility: '..fmt(s.Mobility);blh.Text=fmt(ph.Mobility or 0)..'/h'
			task.wait(0.5)
		end
		if SG.gui then pcall(function()SG.gui:Destroy()end)end;SG.gui=nil
	end)
end

local AA={inv=nil,res=nil,fly=nil}
local function TInv(on)cfg.AutoInvisible=on;save();getgenv().AutoInvisible=on;if AA.inv then AA.inv:Disconnect()AA.inv=nil end;if not on then return end
	local a=ev('Events','Other','Ability');local last=0
	AA.inv=R.Heartbeat:Connect(function()local n=os.clock();if n-last<0.5 then return end;last=n;local tv=LP:FindFirstChild('TempValues');local f=tv and tv:FindFirstChild('IsInvisible');if not(f and f.Value==true)then pcall(function()a:InvokeServer('Invisibility',Vector3.new(1936.171142578125,56.015625,-1960.4375))end)end end)
end
local function TResize(on)cfg.AutoResize=on;save();getgenv().AutoResize=on;if AA.res then AA.res:Disconnect()AA.res=nil end;if not on then return end
	local a=ev('Events','Other','Ability');local last=0
	AA.res=R.Heartbeat:Connect(function()local n=os.clock();if n-last<0.5 then return end;last=n;local tv=LP:FindFirstChild('TempValues');local f=tv and tv:FindFirstChild('IsResized');if not(f and f.Value==true)then pcall(function()a:InvokeServer('Resize',Vector3.new(1936.959228515625,56.015625,-1974.80908203125))end)end end)
end
local function TFly(on)cfg.AutoFly=on;save();getgenv().AutoFly=on;if AA.fly then AA.fly:Disconnect()AA.fly=nil end;if not on then return end
	local a=ev('Events','Other','Ability');local last=0
	AA.fly=R.Heartbeat:Connect(function()local n=os.clock();if n-last<0.5 then return end;last=n;local tv=LP:FindFirstChild('TempValues');local f=tv and tv:FindFirstChild('IsFlying');if not(f and f.Value==true)then pcall(function()a:InvokeServer('Fly',Vector3.new(1932.461181640625,56.015625,-1965.3206787109375))end)end end)
end

local HExp
local function resolvePart(which)
	local city=workspace:FindFirstChild('CatacombsCity');if not city then return nil end
	local kids=city:GetChildren()
	local path=which=='low'and(getgenv and getgenv().HealthPart15Path)or(getgenv and getgenv().HealthPart95Path)
	local idx=tonumber(type(path)=='string'and path:match('%[(%d+)%]')or nil);if not idx then idx=(which=='low')and 2145 or 2389 end
	return kids[idx]
end
local function THealthExploit(on)cfg.HealthExploit=on;save();getgenv().HealthExploit=on;if HExp then HExp:Disconnect()HExp=nil end;if not on then return end
	local last=0
	HExp=R.Heartbeat:Connect(function()local n=os.clock();if n-last<0.5 then return end;last=n;local c,h=charHum();if not(c and h and h.MaxHealth and h.MaxHealth>0 and h.Health>0)then return end
		local r=h.Health/h.MaxHealth;if r<=0.15 then local p=resolvePart('low');if p and p.CFrame then pcall(function()c:PivotTo(p.CFrame+Vector3.new(0,3,0))end)end
		elseif r>=0.95 then local p=resolvePart('high');if p and p.CFrame then pcall(function()c:PivotTo(p.CFrame+Vector3.new(0,3,0))end)end end
	end)
end

local function nearestNonSafePlayer()
	local _,_,hrp=charHum();if not hrp then return nil end
	local ignored={["1nedu"]=true,["209flaw"]=true}
	local best,bestD=nil,math.huge
	for _,p in ipairs(P:GetPlayers())do
		if p~=LP and not ignored[p.Name] and p.Character and p.Character:FindFirstChild('HumanoidRootPart')then
			local tv=p:FindFirstChild('TempValues');local sz=tv and tv:FindFirstChild('SafeZone')
			if not sz or sz.Value~=1 then
				local d=(hrp.Position-p.Character.HumanoidRootPart.Position).Magnitude
				if d<bestD then best,bestD=p,d end
			end
		end
	end
	return best
end
local function fireGammaAt(pos)local a=ev('Events','Other','Ability');pcall(function()a:InvokeServer('Gamma Ray',pos)end)end
local GConn
local function TGamma(on)cfg.GammaAimbot=on;save();getgenv().GammaAimbot=on
	if GConn then GConn:Disconnect()GConn=nil end
	if on then
		GConn=U.InputBegan:Connect(function(i,gp)
			if gp then return end
			if i.KeyCode==Enum.KeyCode.G then
				local t=nearestNonSafePlayer()
				if t and t.Character and t.Character:FindFirstChild('HumanoidRootPart')then
					fireGammaAt(t.Character.HumanoidRootPart.Position)
				end
			end
		end)
	end
end

-- ADD THE TInfiniteZoom FUNCTION HERE
local function TInfiniteZoom(on)
	cfg.InfiniteZoom=on;save();getgenv().InfiniteZoom=on
	if on then
		task.spawn(function()
			while getgenv().InfiniteZoom do
				pcall(function()
					LP.CameraMaxZoomDistance = math.huge
					LP.CameraMinZoomDistance = 0.5
					Cam.CameraType = Enum.CameraType.Custom
					pcall(function() LP.DevCameraOcclusionMode = Enum.DevCameraOcclusionMode.Invisicam end)
				end)
				task.wait(1)
			end
		end)
	end
end

-- Potion consumption functions
local function consumePotion(statType)
    local Players = game:GetService("Players")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local LocalPlayer = Players.LocalPlayer
    
    -- Paths
    local inventoryList = LocalPlayer.PlayerGui.Frames.Inventory.Content.Inventory.List.List
    local equipRemote = ReplicatedStorage:WaitForChild("Events"):WaitForChild("Inventory"):WaitForChild("EquipItem")
    
    -- List of valid potion names for each stat
    local potionLists = {
        Power = {
            ["Power Barrel"] = true,
            ["Power Bottle"] = true,
            ["Power Crate"] = true,
            ["Power Drink"] = true,
            ["Power Potion"] = true
        },
        Health = {
            ["Health Barrel"] = true,
            ["Health Bottle"] = true,
            ["Health Crate"] = true,
            ["Health Drink"] = true,
            ["Health Potion"] = true
        },
        Defense = {
            ["Defense Barrel"] = true,
            ["Defense Bottle"] = true,
            ["Defense Crate"] = true,
            ["Defense Drink"] = true,
            ["Defense Potion"] = true
        },
        Psychic = {
            ["Psychics Barrel"] = true,
            ["Psychics Bottle"] = true,
            ["Psychics Crate"] = true,
            ["Psychics Drink"] = true,
            ["Psychics Potion"] = true
        },
        Magic = {
            ["Magic Barrel"] = true,
            ["Magic Bottle"] = true,
            ["Magic Crate"] = true,
            ["Magic Drink"] = true,
            ["Magic Potion"] = true
        },
        Mobility = {
            ["Mobility Barrel"] = true,
            ["Mobility Bottle"] = true,
            ["Mobility Crate"] = true,
            ["Mobility Drink"] = true,
            ["Mobility Potion"] = true
        }
    }
    
    while getgenv()["AutoConsume" .. statType] do
        task.wait(0.1) -- check every second
        for _, item in pairs(inventoryList:GetChildren()) do
            if item:FindFirstChild("ItemName") and item:FindFirstChild("ID") then
                local itemName = item.ItemName.Text
                if potionLists[statType][itemName] then
                    local id = tonumber(item.ID.Value)
                    if id then
                        print("Using " .. statType .. " potion:", itemName, "ID:", id)
                        equipRemote:FireServer(id)
                        task.wait(0.1) -- wait 60s before using another potion
                    end
                end
            end
        end
    end
end

-- Toggle functions for each stat
local function TConsumePower(on)
    cfg.AutoConsumePower = on
    save()
    getgenv().AutoConsumePower = on
    if on then
        task.spawn(function() consumePotion("Power") end)
    end
end

local function TConsumeHealth(on)
    cfg.AutoConsumeHealth = on
    save()
    getgenv().AutoConsumeHealth = on
    if on then
        task.spawn(function() consumePotion("Health") end)
    end
end

local function TConsumeDefense(on)
    cfg.AutoConsumeDefense = on
    save()
    getgenv().AutoConsumeDefense = on
    if on then
        task.spawn(function() consumePotion("Defense") end)
    end
end

local function TConsumePsychic(on)
    cfg.AutoConsumePsychic = on
    save()
    getgenv().AutoConsumePsychic = on
    if on then
        task.spawn(function() consumePotion("Psychic") end)
    end
end

local function TConsumeMagic(on)
    cfg.AutoConsumeMagic = on
    save()
    getgenv().AutoConsumeMagic = on
    if on then
        task.spawn(function() consumePotion("Magic") end)
    end
end

local function TConsumeMobility(on)
    cfg.AutoConsumeMobility = on
    save()
    getgenv().AutoConsumeMobility = on
    if on then
        task.spawn(function() consumePotion("Mobility") end)
    end
end

local C1=Section(CScroll,'Mob FireBall Aimbot')
Toggle(C1,'Universal FireBall Aimbot','UniversalFireBallAimbot',UFA);Slider(C1,'Universal Fireball Cooldown','universalFireballInterval',0.05,1.0,1.0,function()end)
Toggle(C1,'FireBall Aimbot Catacombs Preset','FireBallAimbot',CatAimbot);Slider(C1,'Fireball Cooldown','fireballCooldown',0.05,1.0,0.1,function()end)
Toggle(C1,'FireBall Aimbot City Preset','FireBallAimbotCity',CityAimbot);Slider(C1,'City Fireball Cooldown','cityFireballCooldown',0.05,1.0,0.5,function()end)
mk('TextLabel',{Size=UDim2.new(1,-12,0,22),BackgroundTransparency=1,Text='Panic',TextColor3=Color3.fromRGB(235,235,245),TextXAlignment=Enum.TextXAlignment.Left,TextScaled=true,Font=Enum.Font.GothamBold},C1)
Toggle(C1,'Smart Panic','SmartPanic',function(on)cfg.SmartPanic=on;getgenv().SmartPanic=on;save()end)
mk('TextLabel',{Size=UDim2.new(1,-12,0,22),BackgroundTransparency=1,Text='Pvp',TextColor3=Color3.fromRGB(235,235,245),TextXAlignment=Enum.TextXAlignment.Left,TextScaled=true,Font=Enum.Font.GothamBold},C1)
Toggle(C1,'Kill Aura','KillAura',TKA)
Toggle(C1,'Gamma Ray Aimbot (g key)','GammaAimbot',TGamma)

local M1=Section(Move,'Movement Features')
Toggle(M1,'No Clip','NoClip',TNoClip)
Toggle(M1,'Infinite Zoom','InfiniteZoom',TInfiniteZoom)

local U1=Section(UScroll,'Utility Features')
mk('TextLabel',{Size=UDim2.new(1,-12,0,22),BackgroundTransparency=1,Text='Optimizations',TextColor3=Color3.fromRGB(235,235,245),TextXAlignment=Enum.TextXAlignment.Left,TextScaled=true,Font=Enum.Font.GothamBold},U1)
Toggle(U1,'Ultimate AFK Optimization','UltimateAFKOptimization',TUltimate)
Toggle(U1,'AFK Optimization','GraphicsOptimization',TAFK)
Toggle(U1,'Graphics Optimization','GraphicsOptimizationAdvanced',TGfxAdv)
Toggle(U1,'Remove Map Clutter','RemoveMapClutter',function(on)if on then RemoveClutter()end end)
mk('TextLabel',{Size=UDim2.new(1,-12,0,22),BackgroundTransparency=1,Text='Webhooks',TextColor3=Color3.fromRGB(235,235,245),TextXAlignment=Enum.TextXAlignment.Left,TextScaled=true,Font=Enum.Font.GothamBold},U1)
Toggle(U1,'Death Webhook','DeathWebhook',function(on)cfg.DeathWebhook=on;save()end)
Toggle(U1,'Panic Webhook','PanicWebhook',function(on)cfg.PanicWebhook=on;save()end)
Toggle(U1,'Stat Webhook (15m)','StatWebhook15m',TStatWH)
mk('TextLabel',{Size=UDim2.new(1,-12,0,22),BackgroundTransparency=1,Text='Server Hop',TextColor3=Color3.fromRGB(235,235,245),TextXAlignment=Enum.TextXAlignment.Left,TextScaled=true,Font=Enum.Font.GothamBold},U1)
Btn(U1,'Find Low Server',function()
	local TS=game:GetService('TeleportService');local function find()
		local place=game.PlaceId;local job=game.JobId;local best,c=nil,nil
		while true do
			local url=string.format('https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=100%s',place,c and('&cursor='..c)or'')
			local ok,body=pcall(function()return game:HttpGet(url)end);if not ok then break end
			local d=H:JSONDecode(body);if not d or not d.data then break end
			for _,s in ipairs(d.data)do if s.id~=job and s.playing<s.maxPlayers then if(not best)or s.playing<best.playing then best=s;if best.playing<=1 then return best end end end end
			c=d.nextPageCursor;if not c then break end;task.wait(0.1)
		end;return best
	end
	local t=find();if t then TS:TeleportToPlaceInstance(game.PlaceId,t.id,LP) end
end)
mk('TextLabel',{Size=UDim2.new(1,-12,0,22),BackgroundTransparency=1,Text='Auto Ability',TextColor3=Color3.fromRGB(235,235,245),TextXAlignment=Enum.TextXAlignment.Left,TextScaled=true,Font=Enum.Font.GothamBold},U1)
Toggle(U1,'Auto Invisible','AutoInvisible',TInv);Toggle(U1,'Auto Resize','AutoResize',TResize);Toggle(U1,'Auto Fly','AutoFly',TFly)
mk('TextLabel',{Size=UDim2.new(1,-12,0,22),BackgroundTransparency=1,Text='Stat Gui',TextColor3=Color3.fromRGB(235,235,245),TextXAlignment=Enum.TextXAlignment.Left,TextScaled=true,Font=Enum.Font.GothamBold},U1)
Toggle(U1,'Stat Gui','StatGui',TStatGui)

local V1=Section(Visual,'Visual Features')
Toggle(V1,'Player ESP','PlayerESP',TPlayerESP)
Toggle(V1,'Mob ESP','MobESP',TMobESP)

local Q1=Section(Quests,'Quest Automation')
Toggle(Q1,'Dishes Side Task','AutoWashDishes',TWash)
Toggle(Q1,'Ninja Side Task','AutoNinjaSideTask',TNinja)
Toggle(Q1,'Animatronics Side Task','AutoAnimatronicsSideTask',TAnim)
Toggle(Q1,'Mutants Side Task','AutoMutantsSideTask',TMut)

local S1=Section(Shops,'Shop Automation')
Toggle(S1,'Dual Exotic Shop','DualExoticShop',TDualExotic)
Toggle(S1,'Vending Machine','VendingPotionAutoBuy',TVend)

local H1=Section(HealthT,'Health Exploit')
mk('TextLabel',{Size=UDim2.new(1,-12,0,22),BackgroundTransparency=1,Text='Health Exploit',TextColor3=Color3.fromRGB(235,235,245),TextXAlignment=Enum.TextXAlignment.Left,TextScaled=true,Font=Enum.Font.GothamBold},H1)
Toggle(H1,'Health Exploit','HealthExploit',THealthExploit)

local P1=Section(Potions,'Auto Consume')
Toggle(P1,'Consume Power','AutoConsumePower',TConsumePower)
Toggle(P1,'Consume Health','AutoConsumeHealth',TConsumeHealth)
Toggle(P1,'Consume Defense','AutoConsumeDefense',TConsumeDefense)
Toggle(P1,'Consume Psychic','AutoConsumePsychic',TConsumePsychic)
Toggle(P1,'Consume Magic','AutoConsumeMagic',TConsumeMagic)
Toggle(P1,'Consume Mobility','AutoConsumeMobility',TConsumeMobility)

local Cfg=Section(Conf,'Configuration')
local SB=Btn(Cfg,'Save Config',function()save()end)
local LB=Btn(Cfg,'Load Config',function()
	if load()~=nil then
		local function ap(flag,get,tgl)if get()~=flag then tgl(flag)end end
		ap(cfg.NoClip,function()return getgenv().NoClip or false end,TNoClip)
		ap(cfg.GraphicsOptimization,function()return getgenv().GraphicsOptimization or false end,TAFK)
		ap(cfg.GraphicsOptimizationAdvanced,function()return getgenv().GraphicsOptimizationAdvanced or false end,TGfxAdv)
		ap(cfg.UltimateAFKOptimization,function()return cfg.UltimateAFKOptimization end,TUltimate)
		ap(cfg.PlayerESP,function()return getgenv().PlayerESP or false end,TPlayerESP)
		ap(cfg.UniversalFireBallAimbot,function()return getgenv().UniversalFireBallAimbot or false end,UFA)
		ap(cfg.FireBallAimbot,function()return getgenv().FireBallAimbot or false end,CatAimbot)
		ap(cfg.FireBallAimbotCity,function()return getgenv().FireBallAimbotCity or false end,CityAimbot)
		ap(cfg.AutoWashDishes,function()return getgenv().AutoWashDishes or false end,TWash)
		ap(cfg.AutoNinjaSideTask,function()return getgenv().AutoNinjaSideTask or false end,TNinja)
		ap(cfg.AutoAnimatronicsSideTask,function()return getgenv().AutoAnimatronicsSideTask or false end,TAnim)
		ap(cfg.AutoMutantsSideTask,function()return getgenv().AutoMutantsSideTask or false end,TMut)
		ap(cfg.DualExoticShop,function()return getgenv().DualExoticShop or false end,TDualExotic)
		ap(cfg.VendingPotionAutoBuy,function()return getgenv().VendingPotionAutoBuy or false end,TVend)
		ap(cfg.StatWebhook15m,function()return getgenv().StatWebhook15m or false end,TStatWH)
		ap(cfg.KillAura,function()return getgenv().KillAura or false end,TKA)
		ap(cfg.StatGui,function()return getgenv().StatGui or false end,TStatGui)
		ap(cfg.AutoInvisible,function()return getgenv().AutoInvisible or false end,TInv)
		ap(cfg.AutoResize,function()return getgenv().AutoResize or false end,TResize)
		ap(cfg.AutoFly,function()return getgenv().AutoFly or false end,TFly)
		ap(cfg.HealthExploit,function()return getgenv().HealthExploit or false end,THealthExploit)
		ap(cfg.GammaAimbot,function()return getgenv().GammaAimbot or false end,TGamma)
		ap(cfg.InfiniteZoom,function()return getgenv().InfiniteZoom or false end,TInfiniteZoom)  -- ADD THIS LINE
		ap(cfg.AutoConsumePower,function()return getgenv().AutoConsumePower or false end,TConsumePower)
		ap(cfg.AutoConsumeHealth,function()return getgenv().AutoConsumeHealth or false end,TConsumeHealth)
		ap(cfg.AutoConsumeDefense,function()return getgenv().AutoConsumeDefense or false end,TConsumeDefense)
		ap(cfg.AutoConsumePsychic,function()return getgenv().AutoConsumePsychic or false end,TConsumePsychic)
		ap(cfg.AutoConsumeMagic,function()return getgenv().AutoConsumeMagic or false end,TConsumeMagic)
		ap(cfg.AutoConsumeMobility,function()return getgenv().AutoConsumeMobility or false end,TConsumeMobility)
		getgenv().SmartPanic=cfg.SmartPanic and true or false
	end
end)
SB.Position=UDim2.new(0,0,0,0);LB.Position=UDim2.new(0,270,0,0)
local SHK=Btn(Cfg,"Set Hide Key ("..(cfg.HideGUIKey or'RightControl')..")",function()waitingKey=true;SHK.Text='Press any key...'end);SetHideBtn=SHK;SHK.Position=UDim2.new(0,540,0,0)
