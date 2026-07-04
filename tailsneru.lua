--[[
	TAILS SCRIPT - OPTIMIZADO
	Se eliminaron fugas de memoria y escaneos de Heartbeat.
]]
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local ASSET_ID = 123314955660361
local isScriptActive = false
local currentMdl = nil
local syncConn = nil
local transparencyLoop = nil
local viewportConn = nil

local playersFolder = workspace:WaitForChild("Players")

local function loadAsset(id)
	local ok, objects = pcall(game.GetObjects, game, "rbxassetid://" .. id)
	if not ok or not objects or #objects == 0 then return nil end
	return objects[1]:Clone()
end

local function getPlayerModel()
	return playersFolder:FindFirstChild(player.Name)
end

local function isTails()
	local model = getPlayerModel()
	return model and model:GetAttribute("Character") == "Tails"
end

local function setupViewport()
	task.spawn(function()
		local viewportFrame = player.PlayerGui:WaitForChild("Round", 30)
		if not viewportFrame then return end
		local gameUi = viewportFrame:WaitForChild("Game", 30)
		if not gameUi then return end
		local viewportModel = gameUi:WaitForChild("SurvivorHP", 30):WaitForChild("ViewportFrame", 30):WaitForChild("WorldModel", 30):WaitForChild("Default", 30)
		if not viewportModel then return end

		local vpOverrideModel = nil

		local function replaceViewportModel()
			if vpOverrideModel and vpOverrideModel.Parent then return end
			local mdl = loadAsset(ASSET_ID)
			if not mdl then return end

			for _, part in ipairs(viewportModel:GetDescendants()) do
				if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
					part.Transparency = 1
				end
			end
			local newHum = mdl:FindFirstChildOfClass("Humanoid")
			if newHum then newHum:Destroy() end
			for _, v in ipairs(mdl:GetDescendants()) do
				if v:IsA("BasePart") then v.CanCollide = false end
			end

			vpOverrideModel = mdl
			mdl.Parent = viewportModel
			local viewportHRP = viewportModel:FindFirstChild("HumanoidRootPart")
			local primaryPart = mdl.PrimaryPart or mdl:FindFirstChildWhichIsA("BasePart")

			if viewportHRP and primaryPart then
				mdl:PivotTo(viewportHRP.CFrame)
				primaryPart.Transparency = 1
				local weld = Instance.new("WeldConstraint")
				weld.Part0 = viewportHRP
				weld.Part1 = primaryPart
				weld.Parent = viewportHRP
			end
		end

		replaceViewportModel()

		if viewportConn then viewportConn:Disconnect() end
		viewportConn = viewportModel.DescendantAdded:Connect(function()
			if not vpOverrideModel or not vpOverrideModel.Parent then
				task.wait(0.1)
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
	
	local function hideParts(model)
		for _, v in ipairs(model:GetDescendants()) do
			if v:IsA("BasePart") then v.Transparency = 1 end
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
			if v.Name == "HumanoidRootPart" or v.Name == "Waist" then
				v.Transparency = 1
			end
		elseif v:IsA("Trail") or v:IsA("Beam") then
			v.Enabled = false
		end
	end

	newHrp.CFrame = hrp.CFrame
	currentMdl = mdl

	syncConn = RunService.RenderStepped:Connect(function()
		if not char.Parent or not hrp.Parent or not newHrp.Parent then
			if syncConn then syncConn:Disconnect() syncConn = nil end
			return
		end
		newHrp.CFrame = hrp.CFrame
	end)

	if transparencyLoop then task.cancel(transparencyLoop) end
	transparencyLoop = task.spawn(function()
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
			task.wait(0.5) -- Aumentado para ahorrar recursos sin afectar la funcionalidad
		end
	end)
end

local function startScript()
	if isScriptActive then return end
	isScriptActive = true
	setupViewport()
	if player.Character then setupCharacter(player.Character) end
end

local function stopScript()
	if not isScriptActive then return end
	isScriptActive = false
	if syncConn then syncConn:Disconnect() syncConn = nil end
	if viewportConn then viewportConn:Disconnect() viewportConn = nil end
	if transparencyLoop then task.cancel(transparencyLoop) transparencyLoop = nil end
	if currentMdl and currentMdl.Parent then currentMdl:Destroy() currentMdl = nil end
	
	if player.Character then
		for _, v in ipairs(player.Character:GetDescendants()) do
			if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then v.Transparency = 0 end
		end
	end
end

player.CharacterAdded:Connect(function(newChar)
	if isScriptActive then
		task.wait(1)
		setupCharacter(newChar)
		setupViewport()
	end
end)

local function checkTailsStatus()
	local check = isTails()
	if check and not isScriptActive then startScript()
	elseif not check and isScriptActive then stopScript() end
end

playersFolder.ChildAdded:Connect(function(child)
	if child.Name == player.Name then
		checkTailsStatus()
		child:GetAttributeChangedSignal("Character"):Connect(checkTailsStatus)
	end
end)

local initialCheck = getPlayerModel()
if initialCheck then
	checkTailsStatus()
	initialCheck:GetAttributeChangedSignal("Character"):Connect(checkTailsStatus)
end
