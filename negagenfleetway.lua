local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

local ASSET_ID = 120141346934653
local ICON_ID = "rbxassetid://73770596724384"
local IDLE_ANIM_ID        = "rbxassetid://74438386263701"
local IDLE_LOWHP_ANIM_ID  = "rbxassetid://74438386263701"
local LOW_HP_THRESHOLD    = 150

local isScriptActive = false
local currentMdl = nil
local syncConn = nil
local idleTrack = nil
local idleLoopActive = false
local playersFolder = workspace:WaitForChild("Players")

local function loadAsset(id)
	local ok, objects = pcall(game.GetObjects, game, "rbxassetid://" .. id)
	if not ok or not objects or #objects == 0 then return nil end
	return objects[1]:Clone()
end

local function getPlayerModel()
	return playersFolder:FindFirstChild(player.Name)
end

local function replacePlayerFrame()
	local pg = player.PlayerGui
	local teamsGui = pg:WaitForChild("Round", 5)
	if teamsGui then teamsGui = teamsGui:WaitForChild("Game", 5) end
	if teamsGui then teamsGui = teamsGui:WaitForChild("Teams", 5) end
	if not teamsGui then return end
	
	local playerFrame = teamsGui:WaitForChild(player.Name, 5)
	if not playerFrame then return end
	
	local frame = playerFrame:WaitForChild("Frame", 2)
	local cc = frame and frame:WaitForChild("Character", 2)
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
		local viewportFrame = player.PlayerGui:WaitForChild("Round", 10)
		if not viewportFrame then return end
		viewportFrame = viewportFrame:WaitForChild("Game", 10):WaitForChild("SurvivorHP", 10):WaitForChild("ViewportFrame", 10)
		if not viewportFrame then return end
		
		local viewportModel = viewportFrame:WaitForChild("WorldModel", 10):WaitForChild("Default", 10)
		if not viewportModel then return end
		
		local vpOverrideModel = nil
		local function replaceViewportModel()
			if vpOverrideModel and vpOverrideModel.Parent then return end
			local newModel = loadAsset(ASSET_ID)
			if not newModel then return end
			
			vpOverrideModel = newModel
			for _, part in ipairs(viewportModel:GetDescendants()) do
				if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then part.Transparency = 1 end
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

	for _, v in ipairs(char:GetDescendants()) do
		if v:IsA("BasePart") then
			v.Transparency = 1
			if v.Name ~= "HumanoidRootPart" then v.CanCollide = false end
		elseif v:IsA("Decal") or v:IsA("Texture") or v:IsA("SurfaceAppearance") then
			pcall(function() v:Destroy() end)
		end
	end

	if oldVisual then
		for _, v in ipairs(oldVisual:GetDescendants()) do
			if v:IsA("BasePart") then v.Transparency = 1 end
			if v:IsA("Decal") or v:IsA("Texture") or v:IsA("SurfaceAppearance") then
				pcall(function() v:Destroy() end)
			end
		end
	end

	local mdl = loadAsset(ASSET_ID)
	if not mdl then return end
	mdl.Parent = oldVisual or char

	local hrp = char:WaitForChild("HumanoidRootPart", 5)
	local newHrp = mdl:WaitForChild("HumanoidRootPart", 5)
	if not hrp or not newHrp then mdl:Destroy() return end

	newHrp.Anchored = true
	newHrp.Transparency = 1

	local mdlHum = mdl:FindFirstChildOfClass("Humanoid")
	if mdlHum then mdlHum:Destroy() end
	local mdlAnim = mdl:FindFirstChildOfClass("Animator")
	if mdlAnim then mdlAnim:Destroy() end

	for _, v in ipairs(mdl:GetDescendants()) do
		if v:IsA("BasePart") then
			v.CanCollide = false
			if v.Name == "HumanoidRootPart" or v.Name == "Waist" then v.Transparency = 1 end
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
		local newSpindash = loadAsset(76689349321089)
		if not newSpindash then return end
		
		spindashPart.Transparency = 1
		spindashMdl = newSpindash
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

	local playerF = getPlayerModel()
	if playerF then
		playerF.ChildAdded:Connect(function(child)
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
		
		-- Ocultado agresivo del modelo predeterminado para evitar superposiciones
		if oldVisual and oldVisual.Parent then
			local defaultFolder = oldVisual:FindFirstChild("Default")
			if defaultFolder then
				for _, v in ipairs(defaultFolder:GetDescendants()) do
					if v:IsA("BasePart") and v.Transparency ~= 1 then
						v.Transparency = 1
					elseif (v:IsA("Decal") or v:IsA("Texture") or v:IsA("SurfaceAppearance")) and v.Transparency ~= 1 then
						v.Transparency = 1
					end
				end
			end
		end
	end)
end

local function setupIdleAnimation(char)
	local hum = char:WaitForChild("Humanoid", 5)
	if not hum then return end
	local animator = hum:FindFirstChildOfClass("Animator") or Instance.new("Animator", hum)

	if idleTrack then idleTrack:Stop() idleTrack = nil end
	idleLoopActive = false 
	task.wait(0.1) 
	idleLoopActive = true

	local animNormal = Instance.new("Animation")
	animNormal.AnimationId = IDLE_ANIM_ID
	local trackNormal = animator:LoadAnimation(animNormal)
	trackNormal.Looped = true

	local animLowHp = Instance.new("Animation")
	animLowHp.AnimationId = IDLE_LOWHP_ANIM_ID
	local trackLowHp = animator:LoadAnimation(animLowHp)
	trackLowHp.Looped = true

	idleTrack = trackNormal
	local currentIdleTrack = nil
	local cachedHealthObj = nil

	local function getHp()
		if not cachedHealthObj or not cachedHealthObj.Parent then
			local model = getPlayerModel()
			cachedHealthObj = model and model:FindFirstChild("Health")
		end
		return cachedHealthObj and cachedHealthObj.Value or math.huge
	end

	local function switchIdle(useLowHp)
		local target = useLowHp and trackLowHp or trackNormal
		if currentIdleTrack == target then return end
		if currentIdleTrack and currentIdleTrack.IsPlaying then currentIdleTrack:Stop() end
		currentIdleTrack = target
		currentIdleTrack:Play()
	end

	task.spawn(function()
		while idleLoopActive and hum and hum.Parent do
			local state = hum:GetState()
			local moving = hum.MoveDirection.Magnitude > 0.1
			local inAir = state == Enum.HumanoidStateType.Jumping or state == Enum.HumanoidStateType.Freefall

			if moving or inAir then
				if currentIdleTrack and currentIdleTrack.IsPlaying then currentIdleTrack:Stop() end
				currentIdleTrack = nil
			else
				local isLowHp = getHp() <= LOW_HP_THRESHOLD
				switchIdle(isLowHp)
			end
			task.wait(0.1) 
		end
	end)
end

local function startScript()
	if isScriptActive then return end
	task.wait(1)
	isScriptActive = true
	setupViewport()
	task.wait(1)
	if character then
		setupCharacter(character)
		task.spawn(function() setupIdleAnimation(character) end)
	end
	task.spawn(replacePlayerFrame)
end

local function stopScript()
	if not isScriptActive then return end
	isScriptActive = false
	idleLoopActive = false
	if idleTrack then idleTrack:Stop() idleTrack = nil end
	if syncConn then syncConn:Disconnect() syncConn = nil end
	if currentMdl and currentMdl.Parent then currentMdl:Destroy() currentMdl = nil end
	
	-- Restaurar visuales si cambiaste de personaje
	if character then
		for _, v in ipairs(character:GetDescendants()) do
			if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then v.Transparency = 0 end
		end
	end
	local oldVisual = getPlayerModel()
	if oldVisual then
		local defaultFolder = oldVisual:FindFirstChild("Default")
		if defaultFolder then
			for _, v in ipairs(defaultFolder:GetDescendants()) do
				if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then v.Transparency = 0 end
				if v:IsA("Decal") or v:IsA("Texture") or v:IsA("SurfaceAppearance") then v.Transparency = 0 end
			end
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

local isCurrentlyFleetway = false
task.spawn(function()
	while true do
		local model = getPlayerModel()
		if model then
			local check = (model:GetAttribute("Character") == "Fleetway")
			if check ~= isCurrentlyFleetway then
				isCurrentlyFleetway = check
				if isCurrentlyFleetway then startScript() else stopScript() end
			end
			model:GetAttributeChangedSignal("Character"):Wait()
		else
			task.wait(1)
		end
	end
end)
