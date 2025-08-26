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
	AutoInvisible=false,AutoResize=false,AutoFly=false,HealthExploit=false,GammaAimbot=false,
	fireballCooldown=0.1,cityFireballCooldown=0.5,universalFireballInterval=1.0,HideGUIKey='RightControl',
}
local function save()pcall(function()writefile('SuperPowerLeague_Config.json',H:JSONEncode(cfg))end)end
local function load()pcall(function()if isfile('SuperPowerLeague_Config.json')then for k,v in pairs(H:JSONDecode(readfile('SuperPowerLeague_Config.json')))do cfg[k]=v end end end)end
load()

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

local G=Instance.new('ScreenGui');G.Name='SuperPowerLeagueGUI';G.ZIndexBehavior=Enum.ZIndexBehavior.Global;G.IgnoreGuiInset=true;G.ResetOnSpawn=false;G.Enabled=true
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
mk('UIPadding',{PaddingTop=UDim2.new(0,12),PaddingBottom=UDim2.new(0,12),PaddingLeft=UDim2.new(0,12),PaddingRight=UDim2.new(0,12)},CC)
local CS=mk('ScrollingFrame',{Name='ContentScroll',Size=UDim2.new(1,-4,1,-4),Position=UDim2.new(0,2,0,2),BackgroundTransparency=1,ScrollBarThickness=6,CanvasSize=UDim2.new(0,0,0,0)},CC)
mk('UIListLayout',{Padding=UDim2.new(0,12),SortOrder=Enum.SortOrder.LayoutOrder},CS)

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
	mk('UIListLayout',{Padding=UDim2.new(0,10),SortOrder=Enum.SortOrder.LayoutOrder},t);mk('UIPadding',{PaddingLeft=UDim2.new(0,4),PaddingRight=UDim2.new(0,4)},t)
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
	mk('UIListLayout',{Padding=UDim2.new(0,8),SortOrder=Enum.SortOrder.LayoutOrder},c)
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

local Combat=Tab('Combat','⚔️');local Move=Tab('Movement','');local Util=Tab('Utility','');local Visual=Tab('Visual','👁️');local Quests=Tab('Quests','📋');local Shops=Tab('Shops','');local Tele=Tab('Teleport','🧭');local HealthT=Tab('Health','❤️');local Conf=Tab('Config','⚙️')

local CScroll=mk('ScrollingFrame',{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,ScrollBarThickness=6,CanvasSize=UDim2.new(0,0,0,0)},Combat)
local CLayout=mk('UIListLayout',{Padding=UDim2.new(0,10),SortOrder=Enum.SortOrder.LayoutOrder},CScroll)
CLayout:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()CScroll.CanvasSize=UDim2.new(0,0,0,CLayout.AbsoluteContentSize.Y+12)end)
local UScroll=mk('ScrollingFrame',{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,ScrollBarThickness=6,CanvasSize=UDim2.new(0,0,0,0)},Util)
local ULayout=mk('UIListLayout',{Padding=UDim2.new(0,10),SortOrder=Enum.SortOrder.LayoutOrder},UScroll)
ULayout:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()UScroll.CanvasSize=UDim2.new(0,0,0,ULayout.AbsoluteContentSize.Y+12)end)

local TR=mk('Frame',{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1},Tele)
local LC=mk('ScrollingFrame',{Name='LeftCol',Size=UDim2.new(0.55,-8,1,0),BackgroundTransparency=1,ScrollBarThickness=6,CanvasSize=UDim2.new(0,0,0,0)},TR)
local LL=mk('UIListLayout',{Padding=UDim2.new(0,8),SortOrder=Enum.SortOrder.LayoutOrder},LC)
LL:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()LC.CanvasSize=UDim2.new(0,0,0,LL.AbsoluteContentSize.Y+20)end)
local RC=mk('ScrollingFrame',{Name='RightCol',Size=UDim2.new(0.45,0,1,0),Position=UDim2.new(0.55,8,0,0),BackgroundTransparency=1,ScrollBarThickness=6,CanvasSize=UDim2.new(0,0,0,0)},TR)
local RL=mk('UIListLayout',{Padding=UDim2.new(0,8),SortOrder=Enum.SortOrder.LayoutOrder},RC)
RL:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()RC.CanvasSize=UDim2.new(0,0,0,RL.AbsoluteContentSize.Y+12)end)

local function instAt(parts)local cur=workspace;for _,n in ipairs(parts)do if not cur or not cur.FindFirstChild then return nil end;cur=cur:FindFirstChild(n)end;return cur end
local function tpTo(t)local c,_,hrp=charHum();if not(c and hrp and t)then return end;local cf=t:IsA('BasePart')and t.CFrame or(t:IsA('Model')and t:GetPivot()or nil);if not cf then return end;local d=CFrame.new(cf.Position+cf.LookVector*4+Vector3.new(0,3,0),cf.Position+cf.LookVector*5);c:PivotTo(d)end
local function addTp(p,parts,label)Btn(p,label,function()local i=instAt(parts);if i then tpTo(i)end end)end

title(RC,'Players')
local PL=mk('Frame',{Size=UDim2.new(1,0,0,0),BackgroundTransparency=1},RC)
local PLL=mk('UIListLayout',{Padding=UDim2.new(0,8),SortOrder=Enum.SortOrder.LayoutOrder},PL)
PLL:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()PL.Size=UDim2.new(1,0,0,PLL.AbsoluteContentSize.Y)end)
local pbtn={}
local function mkPB(plr)return Btn(PL,plr.Name,function()local c=plr.Character;local hrp=c and c:FindFirstChild('HumanoidRootPart');if hrp then local cf=CFrame.new(hrp.Position+Vector3.new(0,3,0),hrp.Position+hrp.CFrame.LookVector*2);local mc=LP.Character;if mc then pcall(function()mc:PivotTo(cf)end)end end end)end
local function refresh()for pl,b in pairs(pbtn)do pcall(function()b:Destroy()end);pbtn[pl]=nil end;for _,pl in ipairs(P:GetPlayers())do if pl~=LP then pbtn[pl]=mkPB(pl)end end end
refresh()
P.PlayerAdded:Connect(function(pl)if pl~=LP then pbtn[pl]=mkPB(pl)end end)
P.PlayerRemoving:Connect(function(pl)if pbtn[pl]then pcall(function()pbtn[pl]:Destroy()end);pbtn[pl]=nil end end)
title(RC,'Saved Position')
local row=mk('Frame',{Size=UDim2.new(1,0,0,0),BackgroundTransparency=1},RC)
local rowL=mk('UIListLayout',{Padding=UDim2.new(0,6),SortOrder=Enum.SortOrder.LayoutOrder},row)
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
	local function mkb(p)local b=Drawing.new('Square');b.Filled=false;b.Thickness=2;b.Visible=false;local t=Drawing.new('Text');t.Size=24;t.Center=true;t.Outline=true;t.Visible=false;boxes[p]={b=b,t=t}end
	local function updateESP()
		for p,esp in pairs(boxes)do
			if not p or not p.Character or not p.Character:FindFirstChild('HumanoidRootPart')or not p.Character:FindFirstChild('Humanoid')or p.Character.Humanoid.Health<=0 then
				esp.b.Visible=false;esp.t.Visible=false
			else
				local hrp=p.Character.HumanoidRootPart;local head=p.Character:FindFirstChild('Head')
				if hrp and head then
					local pos,onScreen=Cam:WorldToViewportPoint(hrp.Position)
					if onScreen and pos.Z>0 then
						local size=Vector2.new(2000/pos.Z,2500/pos.Z)
						esp.b.Size=size;esp.b.Position=Vector2.new(pos.X-size.X/2,pos.Y-size.Y/2)
						esp.b.Color=Color3.fromRGB(0,255,0);esp.b.Visible=true
						esp.t.Position=Vector2.new(pos.X,pos.Y-size.Y/2-30);esp.t.Text=p.Name;esp.t.Color=Color3.fromRGB(255,255,255);esp.t.Visible=true
					else
						esp.b.Visible=false;esp.t.Visible=false
					end
				end
			end
		end
	end
	if on then
		for _,p in ipairs(P:GetPlayers())do if p~=LP then mkb(p)end end
		getgenv().__PESP=R.RenderStepped:Connect(updateESP)
		P.PlayerAdded:Connect(function(p)if p~=LP then mkb(p)end end)
		P.PlayerRemoving:Connect(function(p)if boxes[p]then boxes[p].b:Remove();boxes[p].t:Remove();boxes[p]=nil end end)
	else
		for _,esp in pairs(boxes)do esp.b:Remove();esp.t:Remove()end;boxes={}
	end
end

local function TMobESP(on)
	getgenv().MobESP=on;if not Drawing then return end
	if getgenv().__MESP then getgenv().__MESP:Disconnect();getgenv().__MESP=nil end
	local boxes={}
	local function mkb(mob)local b=Drawing.new('Square');b.Filled=false;b.Thickness=2;b.Visible=false;local t=Drawing.new('Text');t.Size=20;t.Center=true;t.Outline=true;t.Visible=false;boxes[mob]={b=b,t=t}end
	local function updateESP()
		for mob,esp in pairs(boxes)do
			if not mob or not mob.Parent or not mob:FindFirstChild('HumanoidRootPart')or not mob:FindFirstChild('Humanoid')or mob.Humanoid.Health<=0 then
				esp.b.Visible=false;esp.t.Visible=false
			else
				local hrp=mob.HumanoidRootPart;local head=mob:FindFirstChild('Head')
				if hrp and head then
					local pos,onScreen=Cam:WorldToViewportPoint(hrp.Position)
					if onScreen and pos.Z>0 then
						local size=Vector2.new(2000/pos.Z,2500/pos.Z)
						esp.b.Size=size;esp.b.Position=Vector2.new(pos.X-size.X/2,pos.Y-size.Y/2)
						esp.b.Color=Color3.fromRGB(255,0,0);esp.b.Visible=true
						esp.t.Position=Vector2.new(pos.X,pos.Y-size.Y/2-25);esp.t.Text=mob.Name;esp.t.Color=Color3.fromRGB(255,255,255);esp.t.Visible=true
					else
						esp.b.Visible=false;esp.t.Visible=false
					end
				end
			end
		end
	end
	if on then
		local function scanMobs()for _,mob in ipairs(workspace:GetChildren())do if mob:FindFirstChild('Humanoid')and mob:FindFirstChild('HumanoidRootPart')and not P:GetPlayerFromCharacter(mob)then mkb(mob)end end end
		scanMobs();getgenv().__MESP=R.RenderStepped:Connect(updateESP)
		workspace.ChildAdded:Connect(function(mob)if mob:FindFirstChild('Humanoid')and mob:FindFirstChild('HumanoidRootPart')and not P:GetPlayerFromCharacter(mob)then mkb(mob)end end)
	else
		for _,esp in pairs(boxes)do esp.b:Remove();esp.t:Remove()end;boxes={}
	end
end

local function TRemoveMapClutter(on)
	if on then
		for _,d in ipairs(workspace:GetDescendants())do
			if d:IsA('Decal')or d:IsA('Texture')or d:IsA('ParticleEmitter')or d:IsA('Trail')or d:IsA('Beam')or d:IsA('Smoke')or d:IsA('Fire')or d:IsA('Sparkles')then
				pcall(function()d.Enabled=false end)
			elseif d:IsA('PointLight')or d:IsA('SpotLight')or d:IsA('SurfaceLight')then
				if d.Enabled~=nil then pcall(function()d.Enabled=false end)else pcall(function()d.Brightness=0 end)end
			end
		end
	else
		for _,d in ipairs(workspace:GetDescendants())do
			if d:IsA('Decal')or d:IsA('Texture')then pcall(function()d.Transparency=0 end)
			elseif d:IsA('ParticleEmitter')or d:IsA('Trail')or d:IsA('Beam')or d:IsA('Smoke')or d:IsA('Fire')or d:IsA('Sparkles')then pcall(function()d.Enabled=true end)
			elseif d:IsA('PointLight')or d:IsA('SpotLight')or d:IsA('SurfaceLight')then if d.Enabled~=nil then pcall(function()d.Enabled=true end)else pcall(function()d.Brightness=1 end)end end
		end
	end
end

local function TStatWebhook(on)
	cfg.StatWebhook15m=on;save()
	if on then
		task.spawn(function()
			while cfg.StatWebhook15m do
				task.wait(900)
				if cfg.StatWebhook15m then
					local c,h=charHum()
					if h and h.Health>0 then
						local stats={}
						for _,v in ipairs(c:GetChildren())do
							if v:IsA('NumberValue')and v.Name:find('Stat')then
								table.insert(stats,v.Name..': '..tostring(v.Value))
							end
						end
						local statText=#stats>0 and table.concat(stats,'\n')or'No stats found'
						webhook('Stat Bot','   15m Stats Update',LP.Name..'\n\n'..statText)
					end
				end
			end
		end)
	end
end

local function TKA(on)
	cfg.KillAura=on;save()
	if on then
		task.spawn(function()
			while cfg.KillAura do
				task.wait(0.1)
				local c,h,hrp=charHum()
				if not c or not h or h.Health<=0 then continue end
				for _,enemy in ipairs(workspace.Enemies:GetChildren())do
					if enemy:IsA('Model')and enemy:FindFirstChild('HumanoidRootPart')and enemy:FindFirstChild('Humanoid')then
						local dead=enemy:FindFirstChild('Dead')
						if not dead or dead.Value~=true then
							local distance=(hrp.Position-enemy.HumanoidRootPart.Position).Magnitude
							if distance<=500 then
								local args={[1]='KillAura',[2]=enemy.HumanoidRootPart.Position}
								pcall(function()ev('Events','Other','Ability'):InvokeServer(unpack(args))end)
							end
						end
					end
				end
			end
		end)
	end
end

local function nearestNonSafePlayer()
	local _,_,hrp=charHum();if not hrp then return nil end
	local best,bestD=nil,math.huge
	for _,p in ipairs(P:GetPlayers())do
		if p~=LP and p.Character and p.Character:FindFirstChild('HumanoidRootPart')then
			local tv=p:FindFirstChild('TempValues');local sz=tv and tv:FindFirstChild('SafeZone')
			if not sz or sz.Value~=1 then
				if p.Name~="1nedu" then
					local d=(hrp.Position-p.Character.HumanoidRootPart.Position).Magnitude
					if d<bestD then best,bestD=p,d end
				end
			end
		end
	end
	return best
end

local function TGammaAimbot(on)
	cfg.GammaAimbot=on;save()
	if on then
		U.InputBegan:Connect(function(i,gp)
			if gp then return end
			if i.KeyCode==Enum.KeyCode.G then
				local target=nearestNonSafePlayer()
				if target and target.Character and target.Character:FindFirstChild('HumanoidRootPart')then
					local targetPos=target.Character.HumanoidRootPart.Position
					local ability=RS:WaitForChild('Events'):WaitForChild('Other'):WaitForChild('Ability')
					pcall(function()ability:InvokeServer('Gamma Ray',targetPos)end)
				end
			end
		end)
	end
end

local function TStatGui(on)
	cfg.StatGui=on;save()
	if on then
		local sg=Instance.new('ScreenGui');sg.Name='StatGui';sg.Parent=game:GetService('CoreGui')
		local frame=mk('Frame',{Size=UDim2.new(0,200,0,100),Position=UDim2.new(1,-220,0,20),BackgroundColor3=Color3.fromRGB(0,0,0),BackgroundTransparency=0.5,BorderSizePixel=0},sg)
		mk('UICorner',{CornerRadius=UDim2.new(0,8)},frame)
		local title=mk('TextLabel',{Size=UDim2.new(1,0,0,20),Position=UDim2.new(0,0,0,0),BackgroundTransparency=1,Text='Stats',TextColor3=Color3.fromRGB(255,255,255),TextScaled=true,Font=Enum.Font.GothamBold},frame)
		local stats=mk('TextLabel',{Size=UDim2.new(1,0,1,0),Position=UDim2.new(0,0,0,20),BackgroundTransparency=1,Text='',TextColor3=Color3.fromRGB(255,255,255),TextScaled=true,Font=Enum.Font.Gotham,TextXAlignment=Enum.TextXAlignment.Left},frame)
		local function updateStats()
			local c=LP.Character
			if c then
				local statText=''
				for _,v in ipairs(c:GetChildren())do
					if v:IsA('NumberValue')and v.Name:find('Stat')then
						statText=statText..v.Name..': '..tostring(v.Value)..'\n'
					end
				end
				stats.Text=statText
			end
		end
		R.Heartbeat:Connect(updateStats)
	else
		local sg=game:GetService('CoreGui'):FindFirstChild('StatGui')
		if sg then sg:Destroy()end
	end
end

local function TAutoInvisible(on)
	cfg.AutoInvisible=on;save()
	if on then
		task.spawn(function()
			while cfg.AutoInvisible do
				task.wait(0.5)
				local c=LP.Character
				if c then
					local tv=c:FindFirstChild('TempValues')
					local inv=tv and tv:FindFirstChild('IsInvisible')
					if not inv or inv.Value~=true then
						local args={[1]='Invisibility',[2]=Vector3.new(1936.171142578125,56.015625,-1960.4375)}
						pcall(function()ev('Events','Other','Ability'):InvokeServer(unpack(args))end)
					end
				end
			end
		end)
	end
end

local function TAutoResize(on)
	cfg.AutoResize=on;save()
	if on then
		task.spawn(function()
			while cfg.AutoResize do
				task.wait(0.5)
				local c=LP.Character
				if c then
					local tv=c:FindFirstChild('TempValues')
					local res=tv and tv:FindFirstChild('IsResized')
					if not res or res.Value~=true then
						local args={[1]='Resize',[2]=Vector3.new(1936.959228515625,56.015625,-1974.80908203125)}
						pcall(function()ev('Events','Other','Ability'):InvokeServer(unpack(args))end)
					end
				end
			end
		end)
	end
end

local function TAutoFly(on)
	cfg.AutoFly=on;save()
	if on then
		task.spawn(function()
			while cfg.AutoFly do
				task.wait(0.5)
				local c=LP.Character
				if c then
					local tv=c:FindFirstChild('TempValues')
					local fly=tv and tv:FindFirstChild('IsFlying')
					if not fly or fly.Value~=true then
						local args={[1]='Fly',[2]=Vector3.new(1932.461181640625,56.015625,-1965.3206787109375)}
						pcall(function()ev('Events','Other','Ability'):InvokeServer(unpack(args))end)
					end
				end
			end
		end)
	end
end

local function THealthExploit(on)
	cfg.HealthExploit=on;save()
	if on then
		task.spawn(function()
			while cfg.HealthExploit do
				task.wait(0.1)
				local c,h=charHum()
				if h and h.Health>0 then
					local healthPercent=h.Health/h.MaxHealth
					if healthPercent<=0.15 then
						local target=loadstring('return '..(getgenv().HealthPart15Path or 'workspace.CatacombsCity:GetChildren()[2145]'))()
						if target then tpTo(target)end
					elseif healthPercent>=0.95 then
						local target=loadstring('return '..(getgenv().HealthPart95Path or 'workspace.CatacombsCity:GetChildren()[2389]'))()
						if target then tpTo(target)end
					end
				end
			end
		end)
	end
end

local function TFireBallAimbot(on)
	cfg.FireBallAimbot=on;save();getgenv().FireBallAimbot=on
	if not on then return end
	task.spawn(function()
		while getgenv().FireBallAimbot do
			pcall(function()
				local _,h,hrp=charHum();if not hrp or(h and h.Health<=0)then return end
				local mp,bestD,best=hrp.Position,math.huge,nil
				for _,mob in ipairs(workspace.Enemies:GetChildren())do
					if mob:IsA('Model')and mob:FindFirstChild('HumanoidRootPart')then
						local dead=mob:FindFirstChild('Dead')
						if not dead or dead.Value~=true then
							local d=(mp-mob.HumanoidRootPart.Position).Magnitude
							if d<bestD and d<=500 then best,bestD=mob,d end
						end
					end
				end
				if best then
					local args={[1]='FireBall',[2]=best.HumanoidRootPart.Position}
					pcall(function()ev('Events','Other','Ability'):InvokeServer(unpack(args))end)
				end
			end)
			task.wait(cfg.fireballCooldown)
		end
	end)
end

local function TFireBallAimbotCity(on)
	cfg.FireBallAimbotCity=on;save();getgenv().FireBallAimbotCity=on
	if not on then return end
	task.spawn(function()
		while getgenv().FireBallAimbotCity do
			pcall(function()
				local _,h,hrp=charHum();if not hrp or(h and h.Health<=0)then return end
				local mp,bestD,best=hrp.Position,math.huge,nil
				for _,mob in ipairs(workspace.CityMobs:GetChildren())do
					if mob:IsA('Model')and mob:FindFirstChild('HumanoidRootPart')then
						local dead=mob:FindFirstChild('Dead')
						if not dead or dead.Value~=true then
							local d=(mp-mob.HumanoidRootPart.Position).Magnitude
							if d<bestD and d<=500 then best,bestD=mob,d end
						end
					end
				end
				if best then
					local args={[1]='FireBall',[2]=best.HumanoidRootPart.Position}
					pcall(function()ev('Events','Other','Ability'):InvokeServer(unpack(args))end)
				end
			end)
			task.wait(cfg.cityFireballCooldown)
		end
	end)
end

local function TUniversalFireBallAimbot(on)
	cfg.UniversalFireBallAimbot=on;save();getgenv().UniversalFireBallAimbot=on
	if not on then return end
	task.spawn(function()
		while getgenv().UniversalFireBallAimbot do
			pcall(function()
				local _,h,hrp=charHum();if not hrp or(h and h.Health<=0)then return end
				local mp,bestD,best=hrp.Position,math.huge,nil
				for _,mob in ipairs(workspace:GetDescendants())do
					if mob:IsA('Model')and mob:FindFirstChild('HumanoidRootPart')and mob:FindFirstChild('Humanoid')and not P:GetPlayerFromCharacter(mob)then
						local dead=mob:FindFirstChild('Dead')
						if not dead or dead.Value~=true then
							local d=(mp-mob.HumanoidRootPart.Position).Magnitude
							if d<bestD and d<=500 then best,bestD=mob,d end
						end
					end
				end
				if best then
					local args={[1]='FireBall',[2]=best.HumanoidRootPart.Position}
					pcall(function()ev('Events','Other','Ability'):InvokeServer(unpack(args))end)
				end
			end)
			task.wait(cfg.universalFireballInterval)
		end
	end)
end

local function TDualExotic(on)
	cfg.DualExoticShop=on;save();getgenv().DualExoticShop=on
	if not on then return end
	task.spawn(function()
		local function base(p)if not p then return nil end;if p:IsA('BasePart')then return p end;if p:IsA('Model')then return p:FindFirstChildWhichIsA('BasePart')end end
		task.wait(10)
		while getgenv().DualExoticShop do
			pcall(function()
				local _,h,hrp=charHum();if not hrp or(h and h.Health<=0)then return end
				local sp=RS:WaitForChild('Events'):WaitForChild('Spent');local r1=sp:WaitForChild('BuyExotic');local r2=sp:WaitForChild('BuyExotic2')
				local guiFolder=LP.PlayerGui:WaitForChild('Frames');local gui1=guiFolder:WaitForChild('ExoticStore');local gui2=guiFolder:WaitForChild('ExoticStore2')
				local pad1=base(workspace.Pads.ExoticStore['1']);local pad2=base(workspace.Pads.ExoticStore2['1'])
				if not pad1 or not pad2 then return end
				local orig=hrp.CFrame
				hrp.CFrame=pad1.CFrame+Vector3.new(0,3,0);task.wait(2)
				for _,v in pairs(gui1.Content.ExoticList:GetChildren())do
					if v:FindFirstChild('Info')and v.Info:FindFirstChild('Info')and v.Info.Info.Text=='POTION'then
						local num=tonumber(string.match(v.Name,'%d+'));if num then r1:FireServer(num)end
					end
				end
				hrp.CFrame=orig;task.wait(2)
				hrp.CFrame=pad2.CFrame+Vector3.new(0,3,0);task.wait(2)
				for _,v in pairs(gui2.Content.ExoticList:GetChildren())do
					if v:FindFirstChild('Info')and v.Info:FindFirstChild('Info')and v.Info.Info.Text=='POTION'then
						local num=tonumber(string.match(v.Name,'%d+'));if num then r2:FireServer(num)end
					end
				end
				hrp.CFrame=orig;task.wait(600)
			end)
		end
	end)
end

local function TVendingPotionAutoBuy(on)
	cfg.VendingPotionAutoBuy=on;save();getgenv().VendingPotionAutoBuy=on
	if not on then return end
	task.spawn(function()
		while getgenv().VendingPotionAutoBuy do
			pcall(function()
				local _,h,hrp=charHum();if not hrp or(h and h.Health<=0)then return end
				for _,v in ipairs(workspace:GetDescendants())do
					if v:IsA('Model')and v.Name=='VendingMachine'then
						local button=v:FindFirstChild('Button')
						if button and button:FindFirstChild('ClickDetector')then
							local d=(hrp.Position-button.Position).Magnitude
							if d<=10 then
								button.ClickDetector:FireServer()
								break
							end
						end
					end
				end
			end)
			task.wait(1)
		end
	end)
end

local function TAutoWashDishes(on)
	cfg.AutoWashDishes=on;save();getgenv().AutoWashDishes=on
	if not on then return end
	task.spawn(function()
		while getgenv().AutoWashDishes do
			pcall(function()
				local _,h,hrp=charHum();if not hrp or(h and h.Health<=0)then return end
				for _,dish in ipairs(workspace:GetDescendants())do
					if dish:IsA('Model')and dish.Name=='Dish'then
						local d=(hrp.Position-dish:GetPivot().Position).Magnitude
						if d<=10 then
							local args={[1]='WashDish',[2]=dish}
							pcall(function()ev('Events','Other','Ability'):InvokeServer(unpack(args))end)
							break
						end
					end
				end
			end)
			task.wait(1)
		end
	end)
end

local function TAutoNinjaSideTask(on)
	cfg.AutoNinjaSideTask=on;save();getgenv().AutoNinjaSideTask=on
	if not on then return end
	task.spawn(function()
		while getgenv().AutoNinjaSideTask do
			pcall(function()
				local _,h,hrp=charHum();if not hrp or(h and h.Health<=0)then return end
				for _,mob in ipairs(workspace:GetDescendants())do
					if mob:IsA('Model')and mob.Name=='Ninja'then
						local d=(hrp.Position-mob:GetPivot().Position).Magnitude
						if d<=20 then
							local args={[1]='KillNinja',[2]=mob}
							pcall(function()ev('Events','Other','Ability'):InvokeServer(unpack(args))end)
							break
						end
					end
				end
			end)
			task.wait(1)
		end
	end)
end

local function TAutoAnimatronicsSideTask(on)
	cfg.AutoAnimatronicsSideTask=on;save();getgenv().AutoAnimatronicsSideTask=on
	if not on then return end
	task.spawn(function()
		while getgenv().AutoAnimatronicsSideTask do
			pcall(function()
				local _,h,hrp=charHum();if not hrp or(h and h.Health<=0)then return end
				for _,mob in ipairs(workspace:GetDescendants())do
					if mob:IsA('Model')and mob.Name=='Animatronic'then
						local d=(hrp.Position-mob:GetPivot().Position).Magnitude
						if d<=20 then
							local args={[1]='KillAnimatronic',[2]=mob}
							pcall(function()ev('Events','Other','Ability'):InvokeServer(unpack(args))end)
							break
						end
					end
				end
			end)
			task.wait(1)
		end
	end)
end

local function TAutoMutantsSideTask(on)
	cfg.AutoMutantsSideTask=on;save();getgenv().AutoMutantsSideTask=on
	if not on then return end
	task.spawn(function()
		while getgenv().AutoMutantsSideTask do
			pcall(function()
				local _,h,hrp=charHum();if not hrp or(h and h.Health<=0)then return end
				for _,mob in ipairs(workspace:GetDescendants())do
					if mob:IsA('Model')and mob.Name=='Mutant'then
						local d=(hrp.Position-mob:GetPivot().Position).Magnitude
						if d<=20 then
							local args={[1]='KillMutant',[2]=mob}
							pcall(function()ev('Events','Other','Ability'):InvokeServer(unpack(args))end)
							break
						end
					end
				end
			end)
			task.wait(1)
		end
	end)
end

local function TAutoBuyPotions(on)
	cfg.AutoBuyPotions=on;save();getgenv().AutoBuyPotions=on
	if not on then return end
	task.spawn(function()
		while getgenv().AutoBuyPotions do
			pcall(function()
				local _,h,hrp=charHum();if not hrp or(h and h.Health<=0)then return end
				for _,store in ipairs(workspace:GetDescendants())do
					if store:IsA('Model')and store.Name=='Store'then
						local d=(hrp.Position-store:GetPivot().Position).Magnitude
						if d<=10 then
							local args={[1]='BuyPotion',[2]=store}
							pcall(function()ev('Events','Other','Ability'):InvokeServer(unpack(args))end)
							break
						end
					end
				end
			end)
			task.wait(1)
		end
	end)
end

local function findLowestPopulationServer()
	local placeId=game.PlaceId;local currentJob=game.JobId;local best=nil;local cursor=nil
	while true do
		local url=string.format('https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=100%s',placeId,cursor and('&cursor='..cursor)or'')
		local ok,body=pcall(function()return game:HttpGet(url)end);if not ok then break end
		local data=H:JSONDecode(body);if not data or not data.data then break end
		for _,srv in ipairs(data.data)do
			if srv.id~=currentJob and srv.playing<srv.maxPlayers then
				if(not best)or srv.playing<best.playing then
					best=srv;if best.playing<=1 then return best end
				end
			end
		end
		cursor=data.nextPageCursor;if not cursor then break end;task.wait(0.1)
	end
	return best
end

local function TServerHop(on)
	if on then
		local target=findLowestPopulationServer()
		if target then
			game:GetService('TeleportService'):TeleportToPlaceInstance(game.PlaceId,target.id,LP)
		else
			warn('No suitable server found to hop to.')
		end
	end
end

local CombatSection=Section(CScroll,'Mob FireBall Aimbot')
Toggle(CombatSection,'FireBall Aimbot','FireBallAimbot',TFireBallAimbot)
Toggle(CombatSection,'FireBall Aimbot City','FireBallAimbotCity',TFireBallAimbotCity)
Toggle(CombatSection,'Universal FireBall Aimbot','UniversalFireBallAimbot',TUniversalFireBallAimbot)
Slider(CombatSection,'FireBall Cooldown','fireballCooldown',0.1,2.0,0.1)
Slider(CombatSection,'City FireBall Cooldown','cityFireballCooldown',0.1,2.0,0.5)
Slider(CombatSection,'Universal FireBall Interval','universalFireballInterval',0.1,5.0,1.0)

local PvpSection=Section(CScroll,'Pvp')
Toggle(PvpSection,'Kill Aura','KillAura',TKA)
Toggle(PvpSection,'Gamma Ray Aimbot (g key)','GammaAimbot',TGammaAimbot)

local MovementSection=Section(Move,'Movement')
Toggle(MovementSection,'NoClip','NoClip',TNoClip)

local UtilitySection=Section(UScroll,'Graphics')
Toggle(UtilitySection,'Graphics Optimization','GraphicsOptimization',TAFK)
Toggle(UtilitySection,'Graphics Optimization Advanced','GraphicsOptimizationAdvanced',TGfxAdv)
Toggle(UtilitySection,'Ultimate AFK Optimization','UltimateAFKOptimization',TUltimate)

local AutoAbilitySection=Section(UScroll,'Auto Ability')
Toggle(AutoAbilitySection,'Auto Invisible','AutoInvisible',TAutoInvisible)
Toggle(AutoAbilitySection,'Auto Resize','AutoResize',TAutoResize)
Toggle(AutoAbilitySection,'Auto Fly','AutoFly',TAutoFly)

local WebhookSection=Section(UScroll,'Webhooks')
Toggle(WebhookSection,'Death Webhook','DeathWebhook')
Toggle(WebhookSection,'Panic Webhook','PanicWebhook')
Toggle(WebhookSection,'Stat Webhook (15m)','StatWebhook15m',TStatWebhook)

local ServerHopSection=Section(UScroll,'Server Hop')
Btn(ServerHopSection,'Find Low Server',TServerHop)

local VisualSection=Section(Visual,'Visual')
Toggle(VisualSection,'Player ESP','PlayerESP',TPlayerESP)
Toggle(VisualSection,'Mob ESP','MobESP',TMobESP)
Toggle(VisualSection,'Remove Map Clutter','RemoveMapClutter',TRemoveMapClutter)

local QuestsSection=Section(Quests,'Quests')
Toggle(QuestsSection,'Auto Wash Dishes','AutoWashDishes',TAutoWashDishes)
Toggle(QuestsSection,'Auto Ninja Side Task','AutoNinjaSideTask',TAutoNinjaSideTask)
Toggle(QuestsSection,'Auto Animatronics Side Task','AutoAnimatronicsSideTask',TAutoAnimatronicsSideTask)
Toggle(QuestsSection,'Auto Mutants Side Task','AutoMutantsSideTask',TAutoMutantsSideTask)

local ShopsSection=Section(Shops,'Shops')
Toggle(ShopsSection,'Dual Exotic Shop','DualExoticShop',TDualExotic)
Toggle(ShopsSection,'Vending Machine','VendingPotionAutoBuy',TVendingPotionAutoBuy)
Toggle(ShopsSection,'Auto Buy Potions','AutoBuyPotions',TAutoBuyPotions)

local HealthSection=Section(HealthT,'Health Exploit')
Toggle(HealthSection,'Health Exploit','HealthExploit',THealthExploit)

local ConfigSection=Section(Conf,'Config')
Toggle(ConfigSection,'Smart Panic','SmartPanic')
Btn(ConfigSection,'Set Hide Key ('..(cfg.HideGUIKey or'RightControl')..')',function()waitingKey=true;SetHideBtn=ConfigSection:FindFirstChild('Set Hide Key ('..(cfg.HideGUIKey or'RightControl')..')Button')end)

Combat.Visible=true
for _,tab in ipairs(Tabs:GetChildren())do if tab:IsA('TextButton')then tab.BackgroundColor3=Color3.fromRGB(30,30,40);tab.TextColor3=Color3.fromRGB(210,210,220);local aa=tab:FindFirstChildOfClass('Frame');if aa then aa.Visible=false end end end
local firstTab=Tabs:FindFirstChildOfClass('TextButton');if firstTab then firstTab.BackgroundColor3=Color3.fromRGB(45,45,60);firstTab.TextColor3=Color3.fromRGB(240,240,250);local aa=firstTab:FindFirstChildOfClass('Frame');if aa then aa.Visible=true end end
