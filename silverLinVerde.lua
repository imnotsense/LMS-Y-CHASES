local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local ASSET_ID = 75490718071537
local isScriptActive = false
local currentMdl = nil
local syncConn = nil
local bloodConn = nil
local rockholdConn = nil

local GREEN_CS = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(29,  75,  46)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(58, 140, 85)),
})

local function loadAsset(id)
	local ok, objects = pcall(game.GetObjects, game, "rbxassetid://" .. id)
	if not ok or not objects or #objects == 0 then return nil end
	return objects[1]:Clone()
end

local function getPlayerModel()
	local playersFolder = workspace:FindFirstChild("Players")
	return playersFolder and playersFolder:FindFirstChild(player.Name)
end

local cachedVisualModel = nil
local function getCachedVisualModel()
	if cachedVisualModel and cachedVisualModel.Parent then return cachedVisualModel end
	cachedVisualModel = getPlayerModel()
	return cachedVisualModel
end

local function paintTrailGreen(oldVisual)
	if not oldVisual then return end
	local hrp = oldVisual:FindFirstChild("HumanoidRootPart")
	if not hrp then return end
	local trail = hrp:FindFirstChildOfClass("Trail")
	if trail then trail.Color = GREEN_CS end
end

local function paintRockholdParticles(attachment)
	for _, v in ipairs(attachment:GetChildren()) do
		if v:IsA("ParticleEmitter") then v.Color = GREEN_CS end
	end
end

local function setupRockholdWatcher(oldVisual)
	if rockholdConn then rockholdConn:Disconnect() rockholdConn = nil end
	if not oldVisual then return end

	local hrp = oldVisual:FindFirstChild("HumanoidRootPart")
	local function watchAttachment(att)
		paintRockholdParticles(att)
		att.ChildAdded:Connect(function(child)
			if child:IsA("ParticleEmitter") then child.Color = GREEN_CS end
		end)
	end

	if hrp then
		local existing = hrp:FindFirstChild("rockhold")
		if existing and existing:IsA("Attachment") then watchAttachment(existing) end
		rockholdConn = hrp.ChildAdded:Connect(function(child)
			if child.Name == "rockhold" and child:IsA("Attachment") then watchAttachment(child) end
		end)
	else
		task.spawn(function()
			local h = oldVisual:WaitForChild("HumanoidRootPart", 30)
			if not h then return end
			local existing = h:FindFirstChild("rockhold")
			if existing and existing:IsA("Attachment") then watchAttachment(existing) end
			rockholdConn = h.ChildAdded:Connect(function(child)
				if child.Name == "rockhold" and child:IsA("Attachment") then watchAttachment(child) end
			end)
		end)
	end
end

local function removeWhiteFades(oldVisual)
	if not oldVisual then return end
	for _, desc in ipairs(oldVisual:GetDescendants()) do
		if (desc:IsA("Decal") or desc:IsA("Texture")) and desc.Name == "White fade" then desc:Destroy() end
	end
end

local function cleanupOriginalEffects(oldVisual)
	if not oldVisual then return end
	local particleCount, lightCount = 0, 0
	for _, v in ipairs(oldVisual:GetDescendants()) do
		if particleCount < 2 and v:IsA("ParticleEmitter") then
			v:Destroy()
			particleCount += 1
		elseif lightCount < 2 and v:IsA("PointLight") then
			v:Destroy()
			lightCount += 1
		end
		if particleCount >= 2 and lightCount >= 2 then break end
	end
end

local function setupBloodRemoval(oldVisual)
	if bloodConn then bloodConn:Disconnect() bloodConn = nil end
	if not oldVisual then return end
	for _, v in ipairs(oldVisual:GetDescendants()) do
		if v:IsA("Decal") and v.Name == "_BLOOD" then v:Destroy() end
	end
	bloodConn = oldVisual.DescendantAdded:Connect(function(descendant)
		if descendant:IsA("Decal") and descendant.Name == "_BLOOD" then descendant:Destroy() end
	end)
end

local function setupViewport()
	task.spawn(function()
		local viewportFrame = player.PlayerGui
			:WaitForChild("Round", 30):WaitForChild("Game", 30)
			:WaitForChild("SurvivorHP", 30):WaitForChild("ViewportFrame", 30)
		if not viewportFrame then return end
		local viewportModel = viewportFrame
			:WaitForChild("WorldModel", 30):WaitForChild("Default", 30)
		if not viewportModel then return end

		local vpOverrideModel = nil
		local function replaceViewportModel()
			local newModel = loadAsset(75490718071537)
			if not newModel then return end
			if vpOverrideModel and vpOverrideModel.Parent then
				vpOverrideModel:Destroy()
				vpOverrideModel = nil
			end
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
	if rockholdConn then rockholdConn:Disconnect() rockholdConn = nil end
	if currentMdl and currentMdl.Parent then currentMdl:Destroy() currentMdl = nil end

	for _, v in ipairs(char:GetDescendants()) do
		if v:IsA("BasePart") then v.Transparency = 1 end
	end

	local oldVisual = getCachedVisualModel()
	if oldVisual then
		for _, v in ipairs(oldVisual:GetDescendants()) do
			if v:IsA("BasePart") then v.Transparency = 1 end
		end
	end

	cleanupOriginalEffects(oldVisual)
	setupBloodRemoval(oldVisual)
	removeWhiteFades(oldVisual)
	paintTrailGreen(oldVisual)
	setupRockholdWatcher(oldVisual)

	local mdl = loadAsset(ASSET_ID)
	if not mdl then return end

	if oldVisual then mdl.Parent = oldVisual else mdl.Parent = char end

	local hrp = char:FindFirstChild("HumanoidRootPart")
	local newHrp = mdl:FindFirstChild("HumanoidRootPart")
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

	syncConn = RunService.Stepped:Connect(function()
		if not char.Parent or not hrp.Parent or not newHrp.Parent then
			if syncConn then syncConn:Disconnect() end
			return
		end
		newHrp.CFrame = hrp.CFrame
		
		-- Ocultar partes nativas directamente en el ciclo de actualización
		if oldVisual and oldVisual.Parent then
			local defaultFolder = oldVisual:FindFirstChild("Default")
			if defaultFolder then
				local waist = defaultFolder:FindFirstChild("Waist")
				local hrpDef = defaultFolder:FindFirstChild("HumanoidRootPart")
				if waist and waist:IsA("BasePart") and waist.Transparency ~= 1 then waist.Transparency = 1 end
				if hrpDef and hrpDef:IsA("BasePart") and hrpDef.Transparency ~= 1 then hrpDef.Transparency = 1 end
			end
		end
	end)
end

local function startScript()
	if isScriptActive then return end
	task.wait(3)
	isScriptActive = true
	setupViewport()
	if character then setupCharacter(character) end
end

local function stopScript()
	if not isScriptActive then return end
	isScriptActive = false
	if syncConn then syncConn:Disconnect() syncConn = nil end
	if bloodConn then bloodConn:Disconnect() bloodConn = nil end
	if rockholdConn then rockholdConn:Disconnect() rockholdConn = nil end
	if currentMdl and currentMdl.Parent then currentMdl:Destroy() currentMdl = nil end
	if character then
		for _, v in ipairs(character:GetDescendants()) do
			if v:IsA("BasePart") then v.Transparency = 0 end
		end
	end
end

player.CharacterAdded:Connect(function(newChar)
	character = newChar
	cachedVisualModel = nil
	if isScriptActive then
		task.wait(1)
		setupCharacter(newChar)
		setupViewport()
	end
end)

-- Optimizado: Verificación basada en atributos sin sobrecargar el procesador
local isCurrentlySilver = false
task.spawn(function()
	while true do
		local model = getCachedVisualModel()
		if model then
			local check = (model:GetAttribute("Character") == "Silver")
			if check ~= isCurrentlySilver then
				isCurrentlySilver = check
				if isCurrentlySilver then startScript() else stopScript() end
			end
			model:GetAttributeChangedSignal("Character"):Wait()
		else
			task.wait(1)
		end
	end
end)

local function loadCustomAsset(url, filename)
	if not isfile(filename) then writefile(filename, game:HttpGet(url)) end
	return getcustomasset(filename)
end

local CUSTOM_MUSIC = loadCustomAsset("https://github.com/monicagalindo-wq/RECUP/raw/refs/heads/main/Attack.mp3", "Attack.mp3")

task.spawn(function()
	local theme = game:GetService("ReplicatedStorage"):FindFirstChild("ClientAssets")
	if theme then 
		theme = theme:FindFirstChild("Sounds") and theme.Sounds:FindFirstChild("mus")
			and theme.Sounds.mus:FindFirstChild("Game") and theme.Sounds.mus.Game:FindFirstChild("Round")
			and theme.Sounds.mus.Game.Round:FindFirstChild("SoloTheme")
			and theme.Sounds.mus.Game.Round.SoloTheme:FindFirstChild("SuperSonicSolo")
	end
	if not theme then return end
	theme.SoundId = CUSTOM_MUSIC
	theme.Volume = 1.5
	theme.Looped = true
end)
