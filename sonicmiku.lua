local CUSTOM_SPINDASH_ID = 98739426366715
local ASSET_ID = 109931499014905
local TARGET_CHARACTER_NAME = "Sonic" 

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

local currentSpindashModel = nil
local spindashSpinConnection = nil
local currentCustomModel = nil 

local function getPlayerModel()
	local playersFolder = workspace:FindFirstChild("Players")
	if playersFolder then
		return playersFolder:FindFirstChild(player.Name)
	end
	return nil
end

local function isPlayingAsSonic()
	local model = getPlayerModel()
	if model then
		if model:GetAttribute("Character") == TARGET_CHARACTER_NAME then return true end
		if model.Name == TARGET_CHARACTER_NAME then return true end
		if model:FindFirstChild(TARGET_CHARACTER_NAME) then return true end
	end
	if player:GetAttribute("Character") == TARGET_CHARACTER_NAME then return true end
	local charString = player:FindFirstChild("Character")
	if charString and charString:IsA("StringValue") and charString.Value == TARGET_CHARACTER_NAME then return true end
	
	local char = player.Character
	if char and char.Name == TARGET_CHARACTER_NAME then return true end
	
	return false
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
	
	local playersFolder = workspace:FindFirstChild("Players")
	local playerFolder = playersFolder and playersFolder:FindFirstChild(player.Name)
	local spindashFolder = playerFolder and playerFolder:FindFirstChild("Spindash")
	local originalPart = spindashFolder and spindashFolder:FindFirstChild("Spindash")
	
	if originalPart then
		originalPart.Transparency = 0
	end
end

-- Este Heartbeat se mantiene porque el movimiento del spindash DEBE ser fluido a 60 FPS
local function startSpindashFollow(spindashPart)
	if spindashSpinConnection then spindashSpinConnection:Disconnect() end
	
	spindashSpinConnection = RunService.Heartbeat:Connect(function()
		if not currentSpindashModel or not spindashPart or not spindashPart.Parent then
			stopSpindashFollow()
			return
		end
		
		local targetCFrame = spindashPart.CFrame
		if currentSpindashModel:IsA("BasePart") then
			currentSpindashModel.CFrame = targetCFrame
		else
			currentSpindashModel:PivotTo(targetCFrame)
		end
	end)
end

local function replaceSpindashMesh()
	local playersFolder = workspace:FindFirstChild("Players")
	if not playersFolder then return end
	local playerFolder = playersFolder:FindFirstChild(player.Name)
	if not playerFolder then return end
	local spindashFolder = playerFolder:FindFirstChild("Spindash")
	if not spindashFolder then return end
	
	local originalPart = spindashFolder:FindFirstChild("Spindash")
	if originalPart and originalPart:IsA("BasePart") and not currentSpindashModel then
		
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
					effect.Transparency = 1
				elseif effect:IsA("PointLight") or effect:IsA("SpotLight") or effect:IsA("SurfaceLight") then
					effect.Enabled = false
				elseif effect:IsA("ParticleEmitter") or effect:IsA("Trail") or effect:IsA("Beam") then
					effect.Enabled = false
				end
			end
			
			startSpindashFollow(originalPart)
		end
	end
end

-- Optimizado: Bucle pasivo en lugar de comprobar Spindash 60 veces por segundo
task.spawn(function()
	while task.wait(0.5) do
		if not isPlayingAsSonic() then
			if currentSpindashModel then stopSpindashFollow() end
			continue
		end

		local playersFolder = workspace:FindFirstChild("Players")
		local playerFolder = playersFolder and playersFolder:FindFirstChild(player.Name)
		local spindashFolder = playerFolder and playerFolder:FindFirstChild("Spindash")
		
		if spindashFolder and spindashFolder:FindFirstChild("Spindash") then
			if not currentSpindashModel then
				replaceSpindashMesh()
			end
		else
			if currentSpindashModel then
				stopSpindashFollow()
			end
		end
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
	if not isPlayingAsSonic() then return end

	local playersFolder = workspace:FindFirstChild("Players")
	local oldVisual = playersFolder and playersFolder:FindFirstChild(player.Name)
	
	local mdl = loadAsset(ASSET_ID)
	if not mdl then return end
	
	currentCustomModel = mdl 
	
	if oldVisual then mdl.Parent = oldVisual else mdl.Parent = char end

	task.wait(0.5)

	local hrp = char:FindFirstChild("HumanoidRootPart")
	local newHrp = mdl:FindFirstChild("HumanoidRootPart")
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
	task.wait(0.1)
	newHrp.Transparency = 1
	
	local syncConn
	syncConn = RunService.Stepped:Connect(function()
		if not char.Parent or not hrp.Parent or not newHrp.Parent then
			if syncConn then syncConn:Disconnect() end
			return
		end
		newHrp.CFrame = hrp.CFrame
	end)
	
	local function monitorLastLife()
		while char and char.Parent do
			if not isPlayingAsSonic() then break end 

			local lastLifeActive = isLastLife()
			local brokenFolder = mdl:FindFirstChild("Broken")
			local circularFolder = mdl:FindFirstChild("Circular")

			if lastLifeActive then
				if brokenFolder then
					for _, part in ipairs(brokenFolder:GetDescendants()) do
						if part:IsA("BasePart") then part.Transparency = 0 end
					end
				end
				if circularFolder then
					for _, part in ipairs(circularFolder:GetDescendants()) do
						if part:IsA("BasePart") then part.Transparency = 1 end
					end
				end
			else
				if brokenFolder then
					for _, part in ipairs(brokenFolder:GetDescendants()) do
						if part:IsA("BasePart") then part.Transparency = 1 end
					end
				end
				if circularFolder then
					for _, part in ipairs(circularFolder:GetDescendants()) do
						if part:IsA("BasePart") then part.Transparency = 0 end
					end
				end
			end
			task.wait(0.5)
		end
	end

	task.spawn(monitorLastLife)
end

-- Optimizado: Bucle de 0.5s en lugar de 0.1s para reducir la carga de procesador al iterar descendientes
task.spawn(function()
	while task.wait(0.5) do
		if isPlayingAsSonic() then
			
			if character then
				for _, v in ipairs(character:GetDescendants()) do
					if (v:IsA("BasePart") or v:IsA("Decal")) and v.Transparency ~= 1 then
						if currentCustomModel and (v == currentCustomModel or v:IsDescendantOf(currentCustomModel)) then continue end
						v.Transparency = 1
					end
				end
			end
			
			local playersFolder = workspace:FindFirstChild("Players")
			local visualFolder = playersFolder and playersFolder:FindFirstChild(player.Name)
			
			if visualFolder then
				for _, v in ipairs(visualFolder:GetDescendants()) do
					if (v:IsA("BasePart") or v:IsA("MeshPart") or v:IsA("Decal")) and v.Transparency ~= 1 then
						if currentCustomModel and (v == currentCustomModel or v:IsDescendantOf(currentCustomModel)) then continue end
						if currentSpindashModel and (v == currentSpindashModel or v:IsDescendantOf(currentSpindashModel)) then continue end
						v.Transparency = 1
					end
				end
			end
			
		end
	end
end)

if character then
	setupCharacter(character)
end

player.CharacterAdded:Connect(function(newChar)
	character = newChar
	setupCharacter(newChar)
end)
