local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local ASSET_ID = 116294572328094
local LMS_ASSET_ID = 70498798267097
local isScriptActive = false
local currentMdl = nil
local syncConn = nil
local currentLMSMdl = nil
local isInLMS = false
local lmsMonitorActive = false

-- Colores del spindash
local SPINDASH_BALL_COLOR = Color3.fromRGB(17, 203, 29)       -- verde
local SPINDASH_TRAIL_COLOR = Color3.fromRGB(39, 245, 115)    -- verde claro

local function loadAsset(id)
	local ok, objects = pcall(game.GetObjects, game, "rbxassetid://" .. id)
	if not ok or not objects or #objects == 0 then return nil end
	return objects[1]:Clone()
end

local function getPlayerModel()
	local playersFolder = workspace:FindFirstChild("Players")
	return playersFolder and playersFolder:FindFirstChild(player.Name)
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
			local newModel = loadAsset(70498798267097)
			if not newModel then return end
			if vpOverrideModel and vpOverrideModel.Parent then
				vpOverrideModel:Destroy()
				vpOverrideModel = nil
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

	for _, v in ipairs(char:GetDescendants()) do
		if v:IsA("BasePart") then v.Transparency = 1 end
	end

	local oldVisual = getPlayerModel()
	if oldVisual then
		for _, v in ipairs(oldVisual:GetDescendants()) do
			if v:IsA("BasePart") then v.Transparency = 1 end
		end
	end

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
			if v.Name == "HumanoidRootPart" or v.Name == "Waist" then
				v.Transparency = 1
			end
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
		
		-- Ocultar partes del modelo base de forma nativa sin bucles extra
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

	local existingCharTrails = {}
	for _, d in ipairs(char:GetDescendants()) do
		if d:IsA("Trail") or d:IsA("Beam") then
			d.Enabled = false
			existingCharTrails[d] = true
		end
	end
	
	char.DescendantAdded:Connect(function(d)
		if d:IsA("Trail") or d:IsA("Beam") then
			task.wait()
			if not existingCharTrails[d] then
				d.Enabled = true
				d.Color = ColorSequence.new(SPINDASH_TRAIL_COLOR)
			end
		end
	end)

	-- Bucle pasivo para forzar estados de Spindash y cabeza LMS
	task.spawn(function()
		while char and char.Parent and isScriptActive do
			if oldVisual and oldVisual.Parent then
				for _, d in ipairs(oldVisual:GetDescendants()) do
					if d:IsA("Trail") or d:IsA("Beam") then
						if d.Enabled then d.Enabled = false end
					elseif d:IsA("BasePart") and d.Name == "Spindash" then
						if d.Color ~= SPINDASH_BALL_COLOR then d.Color = SPINDASH_BALL_COLOR end
						if d.Material ~= Enum.Material.SmoothPlastic then d.Material = Enum.Material.SmoothPlastic end
					end
				end
			end

			local HEAD_FORCE_TRANSPARENT = { Head = true, angry = true }
			for _, d in ipairs(char:GetDescendants()) do
				if d:IsA("BasePart") and HEAD_FORCE_TRANSPARENT[d.Name] and d.Transparency ~= 1 then
					d.Transparency = 1
				end
			end
			
			local spindashFolder = char:FindFirstChild("Spindash")
			if spindashFolder then
				for _, d in ipairs(spindashFolder:GetDescendants()) do
					if d:IsA("BasePart") then
						if d.Color ~= SPINDASH_BALL_COLOR then d.Color = SPINDASH_BALL_COLOR end
						if d.Material ~= Enum.Material.SmoothPlastic then d.Material = Enum.Material.SmoothPlastic end
					elseif d:IsA("Trail") or d:IsA("Beam") then
						if not d.Enabled then d.Enabled = true end
						d.Color = ColorSequence.new(SPINDASH_TRAIL_COLOR)
					end
				end
			end
			task.wait(0.25)
		end
	end)
end

-- ==================== LMS MODEL SWITCHER ====================
local function switchToLMSModel()
	if isInLMS or not character then return end
	isInLMS = true

	if currentMdl then
		for _, v in ipairs(currentMdl:GetDescendants()) do
			if v:IsA("BasePart") then v.Transparency = 1 end
		end
	end

	if currentLMSMdl then currentLMSMdl:Destroy() currentLMSMdl = nil end

	local lmsMdl = loadAsset(LMS_ASSET_ID)
	if not lmsMdl then
		isInLMS = false
		return
	end
	lmsMdl.Name = "LMS_Model"

	local oldVisual = getPlayerModel()
	if oldVisual then lmsMdl.Parent = oldVisual else lmsMdl.Parent = character end

	local hrp = character:FindFirstChild("HumanoidRootPart")
	local newHrp = lmsMdl:FindFirstChild("HumanoidRootPart") or lmsMdl:FindFirstChildWhichIsA("BasePart")

	if hrp and newHrp then
		newHrp.Anchored = true
		newHrp.Transparency = 1

		local hum = lmsMdl:FindFirstChildOfClass("Humanoid")
		if hum then hum:Destroy() end
		local anim = lmsMdl:FindFirstChildOfClass("Animator")
		if anim then anim:Destroy() end

		local lmsForceTransparent = {
			HumanoidRootPart = true, Waist = true, LFoot = true, RFoot = true,
			angry = true, ["Sphere.003"] = true, ["Sphere.006"] = true,
			["Sphere.007"] = true, ["Sphere.010"] = true,
		}
		for _, v in ipairs(lmsMdl:GetDescendants()) do
			if v:IsA("BasePart") then
				v.CanCollide = false
				v.Transparency = lmsForceTransparent[v.Name] and 1 or 0
			elseif v:IsA("Trail") or v:IsA("Beam") then
				v.Enabled = false
			end
		end

		task.spawn(function()
			while isInLMS and lmsMdl.Parent and hrp.Parent and character.Parent do
				newHrp.CFrame = hrp.CFrame
				task.wait()
			end
		end)
	end
	currentLMSMdl = lmsMdl
end

local function revertToNormalModel()
	isInLMS = false
	if currentLMSMdl then currentLMSMdl:Destroy() currentLMSMdl = nil end
	if currentMdl then
		for _, v in ipairs(currentMdl:GetDescendants()) do
			if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" and v.Name ~= "Waist" then
				v.Transparency = 0
			end
		end
	end
end

-- Optimizado: Bucle de 0.5s en lugar de iterar a 60 FPS con Heartbeat
local function monitorLMS()
	if lmsMonitorActive then return end
	lmsMonitorActive = true
	task.spawn(function()
		while lmsMonitorActive and isScriptActive do
			local soloTheme = game:GetService("ReplicatedStorage"):FindFirstChild("ClientAssets")
			if soloTheme then 
				soloTheme = soloTheme:FindFirstChild("Sounds") and soloTheme.Sounds:FindFirstChild("mus")
					and soloTheme.Sounds.mus:FindFirstChild("Game") and soloTheme.Sounds.mus.Game:FindFirstChild("Round")
					and soloTheme.Sounds.mus.Game.Round:FindFirstChild("SoloTheme")
					and soloTheme.Sounds.mus.Game.Round.SoloTheme:FindFirstChild("SonicSolo")
			end

			local isSoloPlaying = soloTheme and soloTheme.IsPlaying
			local aliveCount = 0
			local playersFolder = workspace:FindFirstChild("Players")
			if playersFolder then
				for _, folder in ipairs(playersFolder:GetChildren()) do
					local hum = folder:FindFirstChild("Humanoid")
					if hum and hum.Health > 0 then aliveCount += 1 end
				end
			end

			local shouldBeInLMS = isSoloPlaying or (aliveCount <= 1)
			if shouldBeInLMS and not isInLMS then
				switchToLMSModel()
			elseif not shouldBeInLMS and isInLMS then
				revertToNormalModel()
			end
			task.wait(0.5)
		end
	end)
end

local function startScript()
	if isScriptActive then return end
	task.wait(3)
	isScriptActive = true
	setupViewport()
	if character then setupCharacter(character) end
	monitorLMS()
end

local function stopScript()
	if not isScriptActive then return end
	isScriptActive = false
	lmsMonitorActive = false
	if syncConn then syncConn:Disconnect() syncConn = nil end
	if currentLMSMdl and currentLMSMdl.Parent then currentLMSMdl:Destroy() currentLMSMdl = nil end
	isInLMS = false
	if currentMdl and currentMdl.Parent then currentMdl:Destroy() currentMdl = nil end
	if character then
		for _, v in ipairs(character:GetDescendants()) do
			if v:IsA("BasePart") then v.Transparency = 0 end
		end
	end
end

player.CharacterAdded:Connect(function(newChar)
	character = newChar
	isInLMS = false
	if currentLMSMdl then currentLMSMdl:Destroy() currentLMSMdl = nil end
	if isScriptActive then
		task.wait(1)
		setupCharacter(newChar)
		setupViewport()
	end
end)

-- Optimizado: Verificación basada en atributos sin sobrecargar el procesador
local isCurrentlySonic = false
task.spawn(function()
	while true do
		local model = getPlayerModel()
		if model then
			local check = (model:GetAttribute("Character") == "Sonic")
			if check ~= isCurrentlySonic then
				isCurrentlySonic = check
				if isCurrentlySonic then startScript() else stopScript() end
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

local CUSTOM_MUSIC = loadCustomAsset("https://github.com/monicagalindo-wq/RECUP/raw/refs/heads/main/FindYourFlame.mp3", "FindYourFlame.mp3")

task.spawn(function()
	local theme = game:GetService("ReplicatedStorage"):FindFirstChild("ClientAssets")
	if theme then 
		theme = theme:FindFirstChild("Sounds") and theme.Sounds:FindFirstChild("mus")
			and theme.Sounds.mus:FindFirstChild("Game") and theme.Sounds.mus.Game:FindFirstChild("Round")
			and theme.Sounds.mus.Game.Round:FindFirstChild("SoloTheme")
			and theme.Sounds.mus.Game.Round.SoloTheme:FindFirstChild("SonicSolo")
	end
	if not theme then return end
	theme.SoundId = CUSTOM_MUSIC
	theme.Volume = 1.5
	theme.Looped = true
end)
