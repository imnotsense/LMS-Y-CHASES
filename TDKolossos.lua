local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local ASSET_ID = 96487206239737
local isScriptActive = false
local currentMdl = nil
local syncConn = nil

local function loadCustomAsset(url, filename)
	if not isfile(filename) then
		writefile(filename, game:HttpGet(url))
	end
	return getcustomasset(filename)
end

local BASE = "https://github.com/monicagalindo-wq/RECUP/raw/refs/heads/main/"

local SFX_MAP = {
	["kolossos grab start"] = loadCustomAsset(BASE .. "TDLOSSOS-grabs.mp3",   "td_grabs.mp3"),
	["charge sound"]        = loadCustomAsset(BASE .. "TDLOSSOS-charge.mp3", "td_charge.mp3"),
}

local HURT_ORIGINAL_IDS = {
	["rbxassetid://133980738807891"] = true,
	["rbxassetid://124193050572686"] = true,
	["rbxassetid://97829534039918"]  = true,
}
local HURT_REPLACEMENTS = {
	loadCustomAsset(BASE .. "TDLOSSOS-hurts1.mp3", "td_hurt1.mp3"),
	loadCustomAsset(BASE .. "TDLOSSOS-hurts2.mp3", "td_hurt2.mp3"),
	loadCustomAsset(BASE .. "TDLOSSOS-hurts3.mp3", "td_hurt3.mp3"),
}

local CHASE_CUSTOM    = loadCustomAsset(BASE .. "TDLOSSOS-CHASE.mp3",    "td_chase.mp3")
local LASTLIFE_CUSTOM = loadCustomAsset(BASE .. "TDLOSSOS-LASTLIFE.mp3", "td_lastlife.mp3")

local sfxConnected = false

local function applyKolossosSFX(folder)
	if not folder then return end
	if sfxConnected then return end
	sfxConnected = true

	folder.DescendantAdded:Connect(function(d)
		if not d:IsA("Sound") then return end
		task.defer(function()
			if not d or not d.Parent then return end
			if SFX_MAP[d.Name] then
				d.SoundId = SFX_MAP[d.Name]
				d.Volume = d.Volume * 2
			elseif HURT_ORIGINAL_IDS[d.SoundId] then
				-- Mutear original y reproducir uno de los tres de Kolossos
				d.Volume = 0
				local replacement = Instance.new("Sound")
				replacement.SoundId = HURT_REPLACEMENTS[math.random(1, #HURT_REPLACEMENTS)]
				replacement.Volume = 1.5
				replacement.Parent = d.Parent
				replacement:Play()
				game:GetService("Debris"):AddItem(replacement, 5)
			end
		end)
	end)

	print("[KOLOSSOS] SFX conectados para:", folder.Name)
end

local function startChaseMusic()
	task.spawn(function()
		local normalChase, lastLifeChase

		local assets = workspace:FindFirstChild("Assets")
		local songs = assets and assets:FindFirstChild("Songs")
		if songs then
			normalChase   = songs:FindFirstChild("NormalChase")
			lastLifeChase = songs:FindFirstChild("LastLifeChase")
		end

		-- Ruta alternativa en ReplicatedStorage para Kolossos
		if not normalChase or not lastLifeChase then
			local rs = game:GetService("ReplicatedStorage")
			local default = rs:FindFirstChild("ClientAssets")
				and rs.ClientAssets:FindFirstChild("Sounds")
				and rs.ClientAssets.Sounds:FindFirstChild("mus")
				and rs.ClientAssets.Sounds.mus:FindFirstChild("Game")
				and rs.ClientAssets.Sounds.mus.Game:FindFirstChild("Round")
				and rs.ClientAssets.Sounds.mus.Game.Round:FindFirstChild("ChaseThemes")
				and rs.ClientAssets.Sounds.mus.Game.Round.ChaseThemes:FindFirstChild("Kolossos")
				and rs.ClientAssets.Sounds.mus.Game.Round.ChaseThemes.Kolossos:FindFirstChild("Default")
			if default then
				normalChase   = normalChase   or default:FindFirstChild("NormalChase")
				lastLifeChase = lastLifeChase or default:FindFirstChild("LastLifeChase")
			end
		end

		if not normalChase or not lastLifeChase then
			warn("[KOLOSSOS] Chase Sounds no encontrados")
			return
		end

		normalChase.SoundId   = CHASE_CUSTOM
		lastLifeChase.SoundId = LASTLIFE_CUSTOM

		-- volumen de los primeros frames
		for i = 1, 60 do
			normalChase.Volume   = 3.5
			lastLifeChase.Volume = 3.5
			task.wait()
		end
	end)
end

local function cleanKolossosDecals()
	task.spawn(function()
		local pf = workspace:FindFirstChild("Players")
		if not pf then return end
		local kolossosFolder = nil
		for _, folder in ipairs(pf:GetChildren()) do
			if folder:GetAttribute("Character") == "Kolossos"
				and folder.Name == player.Name then
				kolossosFolder = folder
				break
			end
		end
		if not kolossosFolder then return end

		-- Sangre de mierda arruinas los modelos
		for _, v in ipairs(kolossosFolder:GetDescendants()) do
			if v:IsA("Decal") then
				pcall(function() v:Destroy() end)
			end
		end

		kolossosFolder.DescendantAdded:Connect(function(d)
			if d:IsA("Decal") then
				pcall(function() d:Destroy() end)
			end
		end)

		print("[KOLOSSOS] Decals limpiados")
	end)
end

local function loadAsset(id)
	local ok, objects = pcall(game.GetObjects, game, "rbxassetid://" .. id)
	if not ok or not objects or #objects == 0 then return nil end
	return objects[1]:Clone()
end

local function getKolossosFolder()
	local pf = workspace:FindFirstChild("Players")
	if not pf then return nil end
	for _, folder in ipairs(pf:GetChildren()) do
		if folder:GetAttribute("Character") == "Kolossos" then
			return folder
		end
	end
	return nil
end

local function buildMotorMap(char, mdl)
	local motorMap = {}
	for _, oldMotor in ipairs(char:GetDescendants()) do
		if oldMotor:IsA("Motor6D") then
			local newMotor = nil
			if oldMotor.Parent then
				local mdlParent = mdl:FindFirstChild(oldMotor.Parent.Name, true)
				if mdlParent then
					newMotor = mdlParent:FindFirstChild(oldMotor.Name)
					if not (newMotor and newMotor:IsA("Motor6D")) then newMotor = nil end
				end
			end
			if not newMotor then
				newMotor = mdl:FindFirstChild(oldMotor.Name, true)
				if not (newMotor and newMotor:IsA("Motor6D")) then newMotor = nil end
			end
			if newMotor then motorMap[oldMotor] = newMotor end
		end
	end
	return motorMap
end

local function setupCharacter(char)
	if not isScriptActive then return end
	if syncConn then syncConn:Disconnect() syncConn = nil end
	if currentMdl and currentMdl.Parent then currentMdl:Destroy() currentMdl = nil end

	local playersFolder = workspace:FindFirstChild("Players")
	local oldVisual = playersFolder and playersFolder:FindFirstChild(player.Name)

	for _, v in ipairs(char:GetDescendants()) do
		if v:IsA("BasePart") then
			v.Transparency = 1
			if v.Name ~= "HumanoidRootPart" then v.CanCollide = false end
		end
	end

	if oldVisual then
		for _, v in ipairs(oldVisual:GetDescendants()) do
			if v:IsA("BasePart") then v.Transparency = 1 end
		end
	end

	local mdl = loadAsset(ASSET_ID)
	if not mdl then warn("[KOLOSSOS] modelo no cargó") return end

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

	local motorMap = buildMotorMap(char, mdl)
	print("[KOLOSSOS] motorMap:", (function() local n=0 for _ in pairs(motorMap) do n+=1 end return n end)())

	syncConn = RunService.Stepped:Connect(function()
		if not char.Parent or not hrp.Parent or not newHrp.Parent then
			if syncConn then syncConn:Disconnect() end
			return
		end
		if not next(motorMap) then motorMap = buildMotorMap(char, mdl) end
		newHrp.CFrame = hrp.CFrame
		for oldMotor, newMotor in pairs(motorMap) do
			if oldMotor.Parent and newMotor.Parent then
				newMotor.Transform = oldMotor.Transform
			end
		end
	end)

	task.spawn(function()
		while char and char.Parent and isScriptActive do
			if oldVisual and oldVisual.Parent then
				local defaultFolder = oldVisual:FindFirstChild("Default")
				if defaultFolder then
					local waist = defaultFolder:FindFirstChild("Waist")
					local hrpDef = defaultFolder:FindFirstChild("HumanoidRootPart")
					if waist and waist:IsA("BasePart") then waist.Transparency = 1 end
					if hrpDef and hrpDef:IsA("BasePart") then hrpDef.Transparency = 1 end
				end
			end
			task.wait(0.1)
		end
	end)

	-- SFX
	local kolossosFolder = getKolossosFolder()
	if kolossosFolder then
		applyKolossosSFX(kolossosFolder)
	end
end

local function isKolossos()
	local model = getKolossosFolder()
	return model ~= nil and model.Name == player.Name
end

local character = player.Character or player.CharacterAdded:Wait()

local function cleanDefaultParts(mdl)
	for _, v in ipairs(mdl:GetDescendants()) do
		if v:IsA("ParticleEmitter") or v:IsA("Decal") then
			pcall(function() v:Destroy() end)
		end
	end
end

local function startResultPreview()
	task.spawn(function()
		local resScreen = workspace:WaitForChild("RES_Screen", 120)
		if not resScreen then return end

		local resPreview = nil
		local resSyncConn = nil

		local function destroyResPreview()
			if resSyncConn then resSyncConn:Disconnect() resSyncConn = nil end
			if resPreview and resPreview.Parent then resPreview:Destroy() end
			resPreview = nil
		end

		local function spawnResPreview(originalMdl)
			if resPreview and resPreview.Parent then return end
			if not originalMdl or not originalMdl.Parent then return end

			-- ocultar a la gran K
			cleanDefaultParts(originalMdl)
			for _, v in ipairs(originalMdl:GetDescendants()) do
				if v:IsA("BasePart") then v.Transparency = 1 end
			end

			local mdl = loadAsset(ASSET_ID)
			if not mdl then return end

			local mdlHum = mdl:FindFirstChildOfClass("Humanoid")
			if mdlHum then mdlHum:Destroy() end
			local mdlAnim = mdl:FindFirstChildOfClass("Animator")
			if mdlAnim then mdlAnim:Destroy() end

			local newHrp = mdl:FindFirstChild("HumanoidRootPart")
			if newHrp then
				newHrp.Anchored = true
				newHrp.Transparency = 1
			end
			for _, v in ipairs(mdl:GetDescendants()) do
				if v:IsA("BasePart") then
					v.CanCollide = false
					if v.Name == "Waist" then v.Transparency = 1 end
				end
			end

			mdl.Parent = originalMdl
			resPreview = mdl

			local originalHrp = originalMdl:FindFirstChild("HumanoidRootPart")
			if originalHrp and newHrp then
				newHrp.CFrame = originalHrp.CFrame
			end

			if resSyncConn then resSyncConn:Disconnect() end
			resSyncConn = RunService.Stepped:Connect(function()
				if not originalMdl.Parent then
					destroyResPreview()
					return
				end
				if newHrp and originalHrp then
					newHrp.CFrame = originalHrp.CFrame
				end
			end)

			print("[KOLOSSOS] result preview cargado")
		end

		-- a la grande le puse cuca
		local function isPlayerModel(mdl)
			return mdl:IsA("Model") and mdl:FindFirstChildOfClass("Humanoid") ~= nil
		end

		for _, v in ipairs(resScreen:GetChildren()) do
			if isPlayerModel(v) then
				task.wait(0.2)
				spawnResPreview(v)
				break
			end
		end
		resScreen.ChildAdded:Connect(function(child)
			if isPlayerModel(child) then
				task.wait(0.2)
				spawnResPreview(child)
			end
		end)
		resScreen.ChildRemoved:Connect(function(child)
			if isPlayerModel(child) then
				destroyResPreview()
			end
		end)
	end)
end

local function startScript()
	if isScriptActive then return end
	task.wait(1)
	isScriptActive = true
	if character then setupCharacter(character) end
	startChaseMusic()
	cleanKolossosDecals()
	startResultPreview()
end

local function stopScript()
	if not isScriptActive then return end
	isScriptActive = false
	sfxConnected = false
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
	end
end)

local isCurrentlyKolossos = false
RunService.Heartbeat:Connect(function()
	local check = isKolossos()
	if check ~= isCurrentlyKolossos then
		isCurrentlyKolossos = check
		if isCurrentlyKolossos then startScript() else stopScript() end
	end
end)

if isKolossos() then
	isCurrentlyKolossos = true
	startScript()
end
