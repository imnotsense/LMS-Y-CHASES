local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local ASSET_ID = 75175137287879
local ICON_ID = "rbxassetid://78720790829181"

local isScriptActive = false
local currentMdl = nil
local syncConn = nil
local loopConn = nil

local playersFolder = workspace:WaitForChild("Players")

local function loadAsset(id)
	local ok, objects = pcall(game.GetObjects, game, "rbxassetid://" .. id)
	if not ok or not objects or #objects == 0 then return nil end
	return objects[1]:Clone()
end

local function getPlayerModel()
	return playersFolder:FindFirstChild(player.Name)
end

local function isBlaze()
	local model = getPlayerModel()
	return model and model:GetAttribute("Character") == "Blaze"
end

local function replacePlayerFrame()
	local pg = player.PlayerGui
	local round = pg:FindFirstChild("Round")
	local gameGui = round and round:FindFirstChild("Game")
	local teamsGui = gameGui and gameGui:FindFirstChild("Teams")
	if not teamsGui then return end
	
	local playerFrame = teamsGui:FindFirstChild(player.Name)
	if not playerFrame then return end
	
	local frame = playerFrame:FindFirstChild("Frame")
	local cc = frame and frame:FindFirstChild("Character")
	if not cc then return end
	
	cc:ClearAllChildren()
	local lbl = Instance.new("ImageLabel")
	lbl.Image = ICON_ID
	lbl.Size = UDim2.new(0.65, 0, 0.65, 0)
	lbl.Position = UDim2.new(0.5, 0, 0.35, 0)
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
		viewportFrame = viewportFrame:WaitForChild("Game", 10)
		if not viewportFrame then return end
		viewportFrame = viewportFrame:WaitForChild("SurvivorHP", 10)
		if not viewportFrame then return end
		viewportFrame = viewportFrame:WaitForChild("ViewportFrame", 10)
		if not viewportFrame then return end
		
		local viewportModel = viewportFrame:WaitForChild("WorldModel", 10)
		if not viewportModel then return end
		viewportModel = viewportModel:WaitForChild("Default", 10)
		if not viewportModel then return end

		local vpOverrideModel = nil
		local function replaceViewportModel()
			if vpOverrideModel and vpOverrideModel.Parent then return end
			local newModel = loadAsset(75175137287879)
			if not newModel then return end
			
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
			if syncConn then syncConn:Disconnect() syncConn = nil end
			return
		end
		newHrp.CFrame = hrp.CFrame
		
		-- Incorporamos la lógica de ocultado forzado de TODO el modelo Default
		if oldVisual and oldVisual.Parent then
			local defaultFolder = oldVisual:FindFirstChild("Default")
			if defaultFolder then
				for _, v in ipairs(defaultFolder:GetDescendants()) do
					if v:IsA("BasePart") and v.Transparency ~= 1 then
						v.Transparency = 1
					elseif (v:IsA("Decal") or v:IsA("Texture")) and v.Transparency ~= 1 then
						v.Transparency = 1
					end
				end
			end
		end
	end)

	-- Icono de estado (Dodges)
	task.spawn(function()
		replacePlayerFrame()
		while isScriptActive do
			local playerF = getPlayerModel()
			if playerF then
				local hasDodges = playerF:FindFirstChild("Dodges")
				if hasDodges then
					playerF.ChildRemoved:Wait()
				else
					playerF.ChildAdded:Wait()
				end
				replacePlayerFrame()
			else
				task.wait(1)
			end
		end
	end)
end

local function startScript()
	if isScriptActive then return end
	isScriptActive = true
	setupViewport()
	if character then setupCharacter(character) end
end

local function stopScript()
	if not isScriptActive then return end
	isScriptActive = false
	if syncConn then syncConn:Disconnect() syncConn = nil end
	if currentMdl then currentMdl:Destroy() currentMdl = nil end
	
	-- Restaurar visibilidad si el usuario cambia de personaje a otro que no sea Blaze
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
				if v:IsA("Decal") or v:IsA("Texture") then v.Transparency = 0 end
			end
		end
	end
end

player.CharacterAdded:Connect(function(newChar)
	character = newChar
	if isScriptActive then
		task.wait(0.5)
		setupCharacter(newChar)
		setupViewport()
	end
end)

-- Sistema de detección de Blaze 
local isCurrentlyBlaze = false
task.spawn(function()
	while true do
		local model = getPlayerModel()
		if model then
			local check = (model:GetAttribute("Character") == "Blaze")
			if check ~= isCurrentlyBlaze then
				isCurrentlyBlaze = check
				if isCurrentlyBlaze then startScript() else stopScript() end
			end
			model:GetAttributeChangedSignal("Character"):Wait()
		else
			task.wait(1)
		end
	end
end)
