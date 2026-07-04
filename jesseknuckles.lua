local CUSTOM_SPINDASH_ID = nil -- Ajusta esto a tu ID
local ASSET_ID = 107292863484385

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

local playersFolder = workspace:WaitForChild("Players")
local currentSpindashModel = nil
local spindashSpinConnection = nil

local function getPlayerModel()
	return playersFolder:FindFirstChild(player.Name)
end

local function stopSpindashFollow()
	if spindashSpinConnection then
		spindashSpinConnection:Disconnect()
		spindashSpinConnection = nil
	end
	if currentSpindashModel then
		currentSpindashModel:Destroy()
		currentSpindashModel = nil
	end
	
	local playerFolder = getPlayerModel()
	local spindashFolder = playerFolder and playerFolder:FindFirstChild("Spindash")
	local originalPart = spindashFolder and spindashFolder:FindFirstChild("Spindash")
	
	if originalPart then originalPart.Transparency = 0 end
end

local function startSpindashFollow(spindashPart)
	if spindashSpinConnection then spindashSpinConnection:Disconnect() end
	
	spindashSpinConnection = RunService.Heartbeat:Connect(function()
		if not currentSpindashModel or not spindashPart or not spindashPart.Parent then
			stopSpindashFollow()
			return
		end
		
		if currentSpindashModel:IsA("BasePart") then
			currentSpindashModel.CFrame = spindashPart.CFrame
		else
			currentSpindashModel:PivotTo(spindashPart.CFrame)
		end
	end)
end

local function replaceSpindashMesh()
	if currentSpindashModel or not CUSTOM_SPINDASH_ID then return end
	
	local playerFolder = getPlayerModel()
	if not playerFolder then return end
	local spindashFolder = playerFolder:FindFirstChild("Spindash")
	if not spindashFolder then return end
	
	local originalPart = spindashFolder:FindFirstChild("Spindash")
	if originalPart and originalPart:IsA("BasePart") then
		
		local ok, objects = pcall(game.GetObjects, game, "rbxassetid://" .. CUSTOM_SPINDASH_ID)
		if ok and objects and #objects > 0 then
			local newMesh = objects[1]:Clone()
			
			for _, part in ipairs(newMesh:GetDescendants()) do
				if part:IsA("BasePart") then
					part.CanCollide = false
					part.Anchored = false
					part.Massless = true
				end
			end
			
			newMesh.Parent = originalPart.Parent
			currentSpindashModel = newMesh
			
			originalPart.Transparency = 1
			for _, effect in ipairs(originalPart:GetDescendants()) do
				if effect:IsA("BasePart") then
					effect.Transparency = (effect.Name == "default") and 0.5 or 1
				elseif effect:IsA("Light") or effect:IsA("ParticleEmitter") or effect:IsA("Trail") or effect:IsA("Beam") then
					effect.Enabled = false
				end
			end
			
			startSpindashFollow(originalPart)
		end
	end
end

-- Monitoreo de Spindash optimizado (sin Heartbeat para buscar carpetas)
task.spawn(function()
	while true do
		local playerFolder = getPlayerModel()
		local spindashFolder = playerFolder and playerFolder:FindFirstChild("Spindash")
		
		if spindashFolder and spindashFolder:FindFirstChild("Spindash") then
			replaceSpindashMesh()
		else
			if currentSpindashModel then stopSpindashFollow() end
		end
		task.wait(0.1) -- 10 veces por segundo es más que suficiente y ahorra muchísima memoria
	end
end)

local function loadAsset(id)
	local ok, objects = pcall(game.GetObjects, game, "rbxassetid://" .. id)
	if not ok or not objects or #objects == 0 then return nil end
	return objects[1]:Clone()
end

local function isLastLife()
	local model = getPlayerModel()
	return model and model:GetAttribute("LastLife") == true
end

local function setupCharacter(char)
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
	mdl.Parent = oldVisual or char

	local hrp = char:WaitForChild("HumanoidRootPart", 5)
	local newHrp = mdl:WaitForChild("HumanoidRootPart", 5)
	if not hrp or not newHrp then mdl:Destroy() return end
	
	newHrp.Anchored = true
	newHrp.Transparency = 1
	
	local existingHum = mdl:FindFirstChildOfClass("Humanoid")
	if existingHum then existingHum:Destroy() end
	local existingAnim = mdl:FindFirstChildOfClass("Animator")
	if existingAnim then existingAnim:Destroy() end
	
	for _, v in ipairs(mdl:GetDescendants()) do
		if v:IsA("BasePart") then v.CanCollide = false end
	end
	
	newHrp.CFrame = hrp.CFrame
	
	local syncConn
	syncConn = RunService.Stepped:Connect(function()
		if not char.Parent or not hrp.Parent or not newHrp.Parent then
			if syncConn then syncConn:Disconnect() end
			return
		end
		newHrp.CFrame = hrp.CFrame
		
		-- Ocultado constante de piezas de manera integrada (ahorra bucles)
		if oldVisual then
			local defaultFolder = oldVisual:FindFirstChild("Default")
			if defaultFolder then
				local waist = defaultFolder:FindFirstChild("Waist")
				local hrpDefault = defaultFolder:FindFirstChild("HumanoidRootPart")
				if waist and waist.Transparency ~= 1 then waist.Transparency = 1 end
				if hrpDefault and hrpDefault.Transparency ~= 1 then hrpDefault.Transparency = 1 end
			end
		end
	end)
	
	-- Monitoreo de última vida inteligente (Solo actualiza si el estado cambia)
	task.spawn(function()
		local previousLifeState = nil
		while char and char.Parent do
			local currentLifeState = isLastLife()
			
			if currentLifeState ~= previousLifeState then
				previousLifeState = currentLifeState
				local brokenFolder = mdl:FindFirstChild("Broken")
				local circularFolder = mdl:FindFirstChild("Circular")

				if currentLifeState then
					if brokenFolder then for _, p in ipairs(brokenFolder:GetDescendants()) do if p:IsA("BasePart") then p.Transparency = 0 end end end
					if circularFolder then for _, p in ipairs(circularFolder:GetDescendants()) do if p:IsA("BasePart") then p.Transparency = 1 end end end
				else
					if brokenFolder then for _, p in ipairs(brokenFolder:GetDescendants()) do if p:IsA("BasePart") then p.Transparency = 1 end end end
					if circularFolder then for _, p in ipairs(circularFolder:GetDescendants()) do if p:IsA("BasePart") then p.Transparency = 0 end end end
				end
			end
			task.wait(0.5)
		end
	end)
end

if character then setupCharacter(character) end

player.CharacterAdded:Connect(function(newChar)
	character = newChar
	setupCharacter(newChar)
end)

-- ==================== LMS MUSIC ====================
local function loadCustomAsset(url, filename)
	if not isfile(filename) then writefile(filename, game:HttpGet(url)) end
	return getcustomasset(filename)
end

local CUSTOM_MUSIC = loadCustomAsset("", ".mp3")

task.spawn(function()
	local theme = game:GetService("ReplicatedStorage"):FindFirstChild("ClientAssets")
	if not theme then return end
	theme = theme:FindFirstChild("Sounds")
	if not theme then return end
	theme = theme:FindFirstChild("mus") and theme.mus:FindFirstChild("Game") and theme.mus.Game:FindFirstChild("Round") and theme.mus.Game.Round:FindFirstChild("SoloTheme") and theme.mus.Game.Round.SoloTheme:FindFirstChild("SonicSolo")
	
	if theme then
		theme.SoundId = CUSTOM_MUSIC
		theme.Volume = 2
		theme.Looped = true
	end
end)
