local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

local ASSET_ID = 86271409527517
local SPINDASH_ID = 107406580831332
local ICON_ID = "rbxassetid://97774287604330"
local IDLE_ANIM_ID = "rbxassetid://86229317461320"
local IDLE_LOWHP_ANIM_ID = "rbxassetid://102209996601966"
local LOW_HP_THRESHOLD = 150

local isScriptActive = false
local currentMdl = nil
local syncConn = nil
local idleTrack = nil
local idleConn = nil

-- === SISTEMA DE CACHÉ PARA AHORRAR RAM ===
local assetCache = {}

local function getCachedAsset(id)
	if assetCache[id] then
		return assetCache[id]:Clone()
	end
	
	local ok, objects = pcall(game.GetObjects, game, "rbxassetid://" .. id)
	if ok and objects and #objects > 0 then
		assetCache[id] = objects[1]
		return assetCache[id]:Clone()
	else
		warn("[FLEETWAY] Falló la carga del asset:", id)
		return nil
	end
end
-- =========================================

local function getPlayerModel()
	local playersFolder = workspace:FindFirstChild("Players")
	return playersFolder and playersFolder:FindFirstChild(player.Name)
end

local function isFleetway()
	local model = getPlayerModel()
	return model and model:GetAttribute("Character") == "Fleetway"
end

local function replacePlayerFrame()
	local pg = player:WaitForChild("PlayerGui", 5)
	if not pg then return end
	
	local teamsGui = pg:FindFirstChild("Round") and pg.Round:FindFirstChild("Game") and pg.Round.Game:FindFirstChild("Teams")
	if not teamsGui then return end
	
	local playerFrame = nil
	for _ = 1, 20 do
		playerFrame = teamsGui:FindFirstChild(player.Name)
		if playerFrame then break end
		task.wait(0.25)
	end
	
	if not playerFrame then return end
	local frame = playerFrame:FindFirstChild("Frame")
	local cc = frame and frame:FindFirstChild("Character")
	if not cc then return end
	
	cc:ClearAllChildren()
	local lbl = Instance.new("ImageLabel")
	lbl.Image = ICON_ID
	lbl.Size = UDim2.new(0.76, 0, 0.76, 0)
	lbl.Position = UDim2.new(0.42, 0, 0.39, 0)
	lbl.AnchorPoint = Vector2.new(0.5, 0.5)
	lbl.BackgroundTransparency = 1
	lbl.ScaleType = Enum.ScaleType.Fit
	lbl.Parent = cc
	
	if cc:IsA("GuiObject") then cc.BackgroundTransparency = 1 end
end

local function setupViewport()
	task.spawn(function()
		local viewportFrame = player.PlayerGui
			:WaitForChild("Round", 30)
			:WaitForChild("Game", 30)
			:WaitForChild("SurvivorHP", 30)
			:WaitForChild("ViewportFrame", 30)
		
		if not viewportFrame then return end
		
		local viewportModel = viewportFrame
			:WaitForChild("WorldModel", 30)
			:WaitForChild("Default", 30)
			
		if not viewportModel then return end
		local vpOverrideModel = nil

		local function replaceViewportModel()
			local newModel = getCachedAsset(ASSET_ID)
			if not newModel then return end

			if vpOverrideModel and vpOverrideModel.Parent then
				vpOverrideModel:Destroy()
			end
			
			vpOverrideModel = newModel
			for _, part in ipairs(viewportModel:GetDescendants()) do
				if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
					part.Transparency = 1
				end
			end
			
			local newHum = newModel:FindFirstChildOfClass("Humanoid")
			if newHum then newHum:Destroy() end
			
			for _, v in ipairs(newModel:GetDescendants()) do
				if v:IsA("BasePart") then v.CanCollide = false end
			end
			
			newModel.Parent = viewportModel
			local viewportHRP = viewportModel:FindFirstChild("HumanoidRootPart")
			local primaryPart = newModel.PrimaryPart or newModel:FindFirstChildWhichIsA("BasePart")
			
			if viewportHRP and primaryPart then
				newModel:PivotTo(viewportHRP.CFrame)
				primaryPart.Transparency = 1
				local weld = Instance.new("WeldConstraint")
				weld.Part0 = viewportHRP
				weld.Part1 = primaryPart
				weld.Parent = viewportHRP
			end
		end
		
		replaceViewportModel()
		
		viewportModel.DescendantAdded:Connect(function()
			task.wait(0.1)
			if not vpOverrideModel or not vpOverrideModel.Parent then
				vpOverrideModel = nil
				replaceViewportModel()
			end
		end)
	end)
end

local function setupCharacter(char)
	if not isScriptActive then return end
	if syncConn then syncConn:Disconnect() syncConn = nil end
	if currentMdl and currentMdl.Parent then currentMdl:Destroy() currentMdl = nil end

	local oldVisual = getPlayerModel()

	local function hideParts(modelToHide, exceptionModel)
		for _, v in ipairs(modelToHide:GetDescendants()) do
			if v:IsA("BasePart") then
				if not exceptionModel or not v:IsDescendantOf(exceptionModel) then
					v.Transparency = 1
					if v.Name ~= "HumanoidRootPart" then v.CanCollide = false end
				end
			elseif v:IsA("Decal") or v:IsA("Texture") or v:IsA("SurfaceAppearance") then
				pcall(function() v:Destroy() end)
			end
		end
	end

	hideParts(char, currentMdl)
	
	char.DescendantAdded:Connect(function(d)
		if d:IsA("BasePart") and (not currentMdl or not d:IsDescendantOf(currentMdl)) then
			d.Transparency = 1
			if d.Name ~= "HumanoidRootPart" then d.CanCollide = false end
		end
	end)

	if oldVisual then
		hideParts(oldVisual, currentMdl)
		oldVisual.DescendantAdded:Connect(function(d)
			if d:IsA("BasePart") and currentMdl and not d:IsDescendantOf(currentMdl) then
				d.Transparency = 1
			end
		end)
		
		-- Hide default waist/hrp initially
		local defaultFolder = oldVisual:FindFirstChild("Default")
		if defaultFolder then
			local waist = defaultFolder:FindFirstChild("Waist")
			local hrpDef = defaultFolder:FindFirstChild("HumanoidRootPart")
			if waist and waist:IsA("BasePart") then waist.Transparency = 1 end
			if hrpDef and hrpDef:IsA("BasePart") then hrpDef.Transparency = 1 end
		end
	end

	local mdl = getCachedAsset(ASSET_ID)
	if not mdl then return end

	mdl.Parent = oldVisual or char

	local hrp = char:WaitForChild("HumanoidRootPart", 5)
	local newHrp = mdl:FindFirstChild("HumanoidRootPart")
	if not hrp or not newHrp then
		mdl:Destroy()
		return
	end

	newHrp.Anchored = true
	newHrp.Transparency = 1

	local mdlHum = mdl:FindFirstChildOfClass("Humanoid")
	if mdlHum then mdlHum:Destroy() end
	local mdlAnim = mdl:FindFirstChildOfClass("Animator")
	if mdlAnim then mdlAnim:Destroy() end

	for _, v in ipairs(mdl:GetDescendants()) do
		if v:IsA("BasePart") then
			v.CanCollide = false
			if v.Name == "HumanoidRootPart" or v.Name == "Waist" then
				v.Transparency = 1
			end
		elseif v:IsA("Trail") or v:IsA("Beam") then
			v.Enabled = false
		end
	end

	newHrp.CFrame = hrp.CFrame
	currentMdl = mdl

	local spindashMdl = nil
	local function replaceSpindash(spindashPart)
		if spindashMdl and spindashMdl.Parent then return end
		if not spindashPart or not spindashPart.Parent then return end
		
		local newSpin = getCachedAsset(SPINDASH_ID)
		if not newSpin then return end
		
		spindashPart.Transparency = 1
		spindashMdl = newSpin
		local primaryPart = spindashMdl.PrimaryPart or spindashMdl:FindFirstChildWhichIsA("BasePart")
		
		if primaryPart then
			for _, v in ipairs(spindashMdl:GetDescendants()) do
				if v:IsA("BasePart") then
					v.Transparency = 0
					v.CanCollide = false
					v.Anchored = true
				end
			end
			spindashMdl:PivotTo(spindashPart.CFrame)
			spindashMdl.Parent = workspace
			
			local spinConn
			spinConn = RunService.Stepped:Connect(function()
				if not spindashPart or not spindashPart.Parent then
					if spinConn then spinConn:Disconnect() end
					return
				end
				spindashMdl:PivotTo(spindashPart.CFrame)
			end)
			
			spindashPart.AncestryChanged:Connect(function()
				if not spindashPart.Parent then
					if spindashMdl and spindashMdl.Parent then spindashMdl:Destroy() end
					spindashMdl = nil
				end
			end)
		end
	end

	if oldVisual then
		oldVisual.ChildAdded:Connect(function(child)
			if child.Name == "Spindash" and child:IsA("BasePart") then
				spindashMdl = nil
				replaceSpindash(child)
			end
		end)
	end

	syncConn = RunService.Stepped:Connect(function()
		if not char.Parent or not hrp.Parent or not newHrp.Parent then
			if syncConn then syncConn:Disconnect() end
			return
		end
		newHrp.CFrame = hrp.CFrame
	end)
end

local function setupIdleAnimation(char)
	local hum = char:WaitForChild("Humanoid", 5)
	if not hum then return end
	
	local animator = hum:FindFirstChildOfClass("Animator")
	if not animator then
		animator = Instance.new("Animator")
		animator.Parent = hum
	end

	if idleTrack then idleTrack:Stop() idleTrack = nil end
	if idleConn then idleConn:Disconnect() idleConn = nil end

	local animNormal = Instance.new("Animation")
	animNormal.AnimationId = IDLE_ANIM_ID
	local trackNormal = animator:LoadAnimation(animNormal)
	trackNormal.Looped = true

	local animLowHp = Instance.new("Animation")
	animLowHp.AnimationId = IDLE_LOWHP_ANIM_ID
	local trackLowHp = animator:LoadAnimation(animLowHp)
	trackLowHp.Looped = true

	local currentIdleTrack = nil
	local lastWasLowHp = nil
	
	-- Cache the health object to avoid searching every frame
	local healthObj = nil
	local function getCachedHp()
		if not healthObj or not healthObj.Parent then
			local model = getPlayerModel()
			healthObj = model and model:FindFirstChild("Health")
		end
		return healthObj and healthObj.Value or math.huge
	end

	local function switchIdle(useLowHp)
		local target = useLowHp and trackLowHp or trackNormal
		if currentIdleTrack == target then return end
		if currentIdleTrack and currentIdleTrack.IsPlaying then
			currentIdleTrack:Stop()
		end
		currentIdleTrack = target
		currentIdleTrack:Play()
		lastWasLowHp = useLowHp
	end

	idleConn = RunService.Heartbeat:Connect(function()
		if not hum or not hum.Parent then
			if idleConn then idleConn:Disconnect() idleConn = nil end
			return
		end
		
		local state = hum:GetState()
		local moving = hum.MoveDirection.Magnitude > 0.1
		local inAir = state == Enum.HumanoidStateType.Jumping or state == Enum.HumanoidStateType.Freefall

		if moving or inAir then
			if currentIdleTrack and currentIdleTrack.IsPlaying then
				currentIdleTrack:Stop()
			end
			currentIdleTrack = nil
			lastWasLowHp = nil
		else
			local isLowHp = getCachedHp() <= LOW_HP_THRESHOLD
			switchIdle(isLowHp)
		end
	end)
end

local function startScript()
	if isScriptActive then return end
	task.wait(3)
	isScriptActive = true
	setupViewport()
	task.wait(4)
	if character then
		setupCharacter(character)
		task.spawn(function() setupIdleAnimation(character) end)
	end
	task.spawn(replacePlayerFrame)
end

local function stopScript()
	if not isScriptActive then return end
	isScriptActive = false
	if idleTrack then idleTrack:Stop() idleTrack = nil end
	if idleConn then idleConn:Disconnect() idleConn = nil end
	if syncConn then syncConn:Disconnect() syncConn = nil end
	if currentMdl and currentMdl.Parent then currentMdl:Destroy() currentMdl = nil end
	if character then
		for _, v in ipairs(character:GetDescendants()) do
			if v:IsA("BasePart") then v.Transparency = 0 end
		end
	end
end

player.CharacterAdded:Connect(function(newChar)
	character = newChar
	if isScriptActive then
		task.wait(1)
		setupCharacter(newChar)
		task.spawn(function() setupIdleAnimation(newChar) end)
		setupViewport()
		task.spawn(replacePlayerFrame)
	end
end)

-- Sustituimos el Heartbeat intensivo por un ciclo ligero cada 0.5s para ahorrar CPU
local isCurrentlyFleetway = false
task.spawn(function()
	while true do
		local check = isFleetway()
		if check ~= isCurrentlyFleetway then
			isCurrentlyFleetway = check
			if isCurrentlyFleetway then startScript() else stopScript() end
		end
		task.wait(0.5)
	end
end)

if isFleetway() then
	isCurrentlyFleetway = true
	startScript()
end
