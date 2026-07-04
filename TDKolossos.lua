--[[
	KOLOSSOS SCRIPT - OPTIMIZADO
	Se gestionaron las conexiones de eventos para evitar fugas masivas de RAM con el audio y las decals.
]]
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local ASSET_ID = 96487206239737
local isScriptActive = false
local currentMdl = nil
local syncConn = nil
local sfxConnected = false
local eventConnections = {} -- Almacena conexiones para limpiarlas y evitar lag

local playersFolder = workspace:WaitForChild("Players")

local function loadCustomAsset(url, filename)
	if not isfile(filename) then writefile(filename, game:HttpGet(url)) end
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

local function getKolossosFolder()
	return playersFolder:FindFirstChild(player.Name)
end

local function applyKolossosSFX(folder)
	if not folder or sfxConnected then return end
	sfxConnected = true

	local conn = folder.DescendantAdded:Connect(function(d)
		if not d:IsA("Sound") then return end
		task.defer(function()
			if not d or not d.Parent then return end
			if SFX_MAP[d.Name] then
				d.SoundId = SFX_MAP[d.Name]
				d.Volume = d.Volume * 2
			elseif HURT_ORIGINAL_IDS[d.SoundId] then
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
	table.insert(eventConnections, conn)
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

		if not normalChase or not lastLifeChase then
			local rs = game:GetService("ReplicatedStorage")
			local default = rs:FindFirstChild("ClientAssets") and rs.ClientAssets:FindFirstChild("Sounds") and rs.ClientAssets.Sounds:FindFirstChild("mus") and rs.ClientAssets.Sounds.mus:FindFirstChild("Game") and rs.ClientAssets.Sounds.mus.Game:FindFirstChild("Round") and rs.ClientAssets.Sounds.mus.Game.Round:FindFirstChild("ChaseThemes") and rs.ClientAssets.Sounds.mus.Game.Round.ChaseThemes:FindFirstChild("Kolossos") and rs.ClientAssets.Sounds.mus.Game.Round.ChaseThemes.Kolossos:FindFirstChild("Default")
			if default then
				normalChase   = normalChase   or default:FindFirstChild("NormalChase")
				lastLifeChase = lastLifeChase or default:FindFirstChild("LastLifeChase")
			end
		end

		if not normalChase or not lastLifeChase then return end

		normalChase.SoundId   = CHASE_CUSTOM
		lastLifeChase.SoundId = LASTLIFE_CUSTOM

		for i = 1, 60 do
			normalChase.Volume   = 3.5
			lastLifeChase.Volume = 3.5
			task.wait()
		end
	end)
end

local function cleanKolossosDecals()
	local folder = getKolossosFolder()
	if not folder then return end

	for _, v in ipairs(folder:GetDescendants()) do
		if v:IsA("Decal") then pcall(function() v:Destroy() end) end
	end

	local conn = folder.DescendantAdded:Connect(function(d)
		if d:IsA("Decal") then pcall(function() d:Destroy() end) end
	end)
	table.insert(eventConnections, conn)
end

local function loadAsset(id)
	local ok, objects = pcall(game.GetObjects, game, "rbxassetid://" .. id)
	if not ok or not objects or #objects == 0 then return nil end
	return objects[1]:Clone()
end

local function buildMotorMap(char, mdl)
	local motorMap = {}
	for _, oldMotor in ipairs(char:GetDescendants()) do
		if oldMotor:IsA("Motor6D") then
			local newMotor = nil
			if oldMotor.Parent then
				local mdlParent = mdl:FindFirstChild(oldMotor.Parent.Name, true)
				if mdlParent then newMotor = mdlParent:FindFirstChild(oldMotor.Name) end
			end
			if not newMotor then newMotor = mdl:FindFirstChild(oldMotor.Name, true) end
			if newMotor and newMotor:IsA("Motor6D") then motorMap[oldMotor] = newMotor end
		end
	end
	return motorMap
end

local function setupCharacter(char)
	if not isScriptActive then return end
	if syncConn then syncConn:Disconnect() syncConn = nil end
	if currentMdl and currentMdl.Parent then currentMdl:Destroy() currentMdl = nil end

	local oldVisual = getKolossosFolder()

	local function hideParts(model)
		for _, v in ipairs(model:GetDescendants()) do
			if v:IsA("BasePart") then
				v.Transparency = 1
				if v.Name ~= "HumanoidRootPart" then v.CanCollide = false end
			end
		end
	end

	hideParts(char)
	if oldVisual then hideParts(oldVisual) end

	local mdl = loadAsset(ASSET_ID)
	if not mdl then return end

	mdl.Parent = oldVisual or char

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

	local motorMap = buildMotorMap(char, mdl)

	syncConn = RunService.RenderStepped:Connect(function()
		if not char.Parent or not hrp.Parent or not newHrp.Parent then
			if syncConn then syncConn:Disconnect() syncConn = nil end
			return
		end
		newHrp.CFrame = hrp.CFrame
		for oldMotor, newMotor in pairs(motorMap) do
			if oldMotor.Parent and newMotor.Parent then
				newMotor.Transform = oldMotor.Transform
			end
		end
	end)

	local transparencyLoop = task.spawn(function()
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
			task.wait(0.5)
		end
	end)
	table.insert(eventConnections, transparencyLoop)
	applyKolossosSFX(oldVisual)
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
		table.insert(eventConnections, {Disconnect = destroyResPreview})

		local function spawnResPreview(originalMdl)
			if resPreview and resPreview.Parent then return end
			if not originalMdl or not originalMdl.Parent then return end

			for _, v in ipairs(originalMdl:GetDescendants()) do
				if v:IsA("ParticleEmitter") or v:IsA("Decal") then pcall(function() v:Destroy() end)
				elseif v:IsA("BasePart") then v.Transparency = 1 end
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
			if originalHrp and newHrp then newHrp.CFrame = originalHrp.CFrame end

			if resSyncConn then resSyncConn:Disconnect() end
			resSyncConn = RunService.RenderStepped:Connect(function()
				if not originalMdl.Parent then destroyResPreview() return end
				if newHrp and originalHrp then newHrp.CFrame = originalHrp.CFrame end
			end)
		end

		local function isPlayerModel(mdl)
			return mdl:IsA("Model") and mdl:FindFirstChildOfClass("Humanoid") ~= nil
		end

		for _, v in ipairs(resScreen:GetChildren()) do
			if isPlayerModel(v) then task.defer(spawnResPreview, v) break end
		end

		local connAdd = resScreen.ChildAdded:Connect(function(child)
			if isPlayerModel(child) then task.wait(0.2) spawnResPreview(child) end
		end)
		local connRem = resScreen.ChildRemoved:Connect(function(child)
			if isPlayerModel(child) then destroyResPreview() end
		end)
		
		table.insert(eventConnections, connAdd)
		table.insert(eventConnections, connRem)
	end)
end

local function isKolossos()
	local model = getKolossosFolder()
	return model and model:GetAttribute("Character") == "Kolossos"
end

local function startScript()
	if isScriptActive then return end
	isScriptActive = true
	if player.Character then setupCharacter(player.Character) end
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

	-- Limpieza estricta de memoria
	for _, item in ipairs(eventConnections) do
		if typeof(item) == "thread" then task.cancel(item)
		elseif typeof(item) == "RBXScriptConnection" then item:Disconnect()
		elseif type(item) == "table" and item.Disconnect then item:Disconnect() end
	end
	table.clear(eventConnections)

	if player.Character then
		for _, v in ipairs(player.Character:GetDescendants()) do
			if v:IsA("BasePart") then v.Transparency = 0 end
		end
	end
end

player.CharacterAdded:Connect(function(newChar)
	if isScriptActive then
		task.wait(1)
		setupCharacter(newChar)
	end
end)

local function checkKolossosStatus()
	local check = isKolossos()
	if check and not isScriptActive then startScript()
	elseif not check and isScriptActive then stopScript() end
end

playersFolder.ChildAdded:Connect(function(child)
	if child.Name == player.Name then
		checkKolossosStatus()
		child:GetAttributeChangedSignal("Character"):Connect(checkKolossosStatus)
	end
end)

local initialCheck = getKolossosFolder()
if initialCheck then
	checkKolossosStatus()
	initialCheck:GetAttributeChangedSignal("Character"):Connect(checkKolossosStatus)
end
