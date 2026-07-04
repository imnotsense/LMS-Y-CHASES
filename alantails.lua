local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local ASSET_ID = 92307522741961
local ICON_ID = "rbxassetid://107983795941234"

local isScriptActive = false
local currentMdl = nil
local syncConn = nil
local attributeConn = nil
local visualConn = nil

local function loadAsset(id)
	local ok, objects = pcall(game.GetObjects, game, "rbxassetid://" .. id)
	if not ok or not objects or #objects == 0 then return nil end
	return objects[1]:Clone()
end

local function getPlayerModel()
	local playersFolder = workspace:FindFirstChild("Players")
	return playersFolder and playersFolder:FindFirstChild(player.Name)
end

local function isBlaze()
	local model = getPlayerModel()
	return model and model:GetAttribute("Character") == "Tails"
end

local function replacePlayerFrame()
	local pg = player.PlayerGui
	local teamsGui = pg:FindFirstChild("Round") and pg.Round:FindFirstChild("Game") and pg.Round.Game:FindFirstChild("Teams")
	if not teamsGui then return end
	
	local playerFrame = teamsGui:FindFirstChild(player.Name)
	if not playerFrame then return end
	
	local frame = playerFrame:FindFirstChild("Frame")
	if not frame then return end
	
	local cc = frame:FindFirstChild("Character")
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
			local mdl = loadAsset(ASSET_ID)
			if not mdl then return end
			
			if vpOverrideModel and vpOverrideModel.Parent then
				vpOverrideModel:Destroy()
			end
			
			vpOverrideModel = mdl
			for _, part in ipairs(viewportModel:GetDescendants()) do
				if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
					part.Transparency = 1
				end
			end
			
			local newHum = vpOverrideModel:FindFirstChildOfClass("Humanoid")
			if newHum then newHum:Destroy() end
			
			for _, v in ipairs(vpOverrideModel:GetDescendants()) do
				if v:IsA("BasePart") then v.CanCollide = false end
			end
			
			vpOverrideModel.Parent = viewportModel
			local viewportHRP = viewportModel:FindFirstChild("HumanoidRootPart")
			local primaryPart = vpOverrideModel.PrimaryPart or vpOverrideModel:FindFirstChildWhichIsA("BasePart")
			
			if viewportHRP and primaryPart then
				vpOverrideModel:PivotTo(viewportHRP.CFrame)
				primaryPart.Transparency = 1
				local weld = Instance.new("WeldConstraint")
				weld.Part0 = viewportHRP
				weld.Part1 = primaryPart
				weld.Parent = viewportHRP
			end
		end

		replaceViewportModel()

		-- Optimizamos el DescendantAdded
		local debouncing = false
		viewportModel.DescendantAdded:Connect(function()
			if debouncing then return end
			debouncing = true
			task.wait(0.1)
			if not vpOverrideModel or not vpOverrideModel.Parent then
				vpOverrideModel = nil
				replaceViewportModel()
			end
			debouncing = false
		end)
	end)
end

local function setupCharacter(char)
	if not isScriptActive then return end
	if syncConn then syncConn:Disconnect() syncConn = nil end
	if visualConn then visualConn:Disconnect() visualConn = nil end
	if currentMdl and currentMdl.Parent then currentMdl:Destroy() currentMdl = nil end

	local function hideParts(target)
		for _, v in ipairs(target:GetDescendants()) do
			if v:IsA("BasePart") then v.Transparency = 1 end
		end
	end

	hideParts(char)
	
	local oldVisual = getPlayerModel()
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

	syncConn = RunService.Stepped:Connect(function()
		if not char.Parent or not hrp.Parent or not newHrp.Parent then
			if syncConn then syncConn:Disconnect() syncConn = nil end
			return
		end
		newHrp.CFrame = hrp.CFrame
	end)

	-- Evento en lugar de bucle while para esconder partes nuevas
	if oldVisual then
		visualConn = oldVisual.DescendantAdded:Connect(function(desc)
			if desc:IsA("BasePart") and desc.Name == "Waist" or desc.Name == "HumanoidRootPart" then
				desc.Transparency = 1
			end
		end)
	end

	-- Bucle Icono optimizado
	task.spawn(function()
		task.wait(1)
		replacePlayerFrame()
		while isScriptActive do
			local playerF = getPlayerModel()
			if playerF then
				if playerF:FindFirstChild("Dodges") then
					playerF.ChildRemoved:Wait() -- Espera activa sin sobrecargar CPU
				else
					playerF.ChildAdded:Wait()
				end
			end
			task.wait(0.5)
			replacePlayerFrame()
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
	if visualConn then visualConn:Disconnect() visualConn = nil end
	if currentMdl and currentMdl.Parent then currentMdl:Destroy() currentMdl = nil end
	if character then
		for _, v in ipairs(character:GetDescendants()) do
			if v:IsA("BasePart") then v.Transparency = 0 end
		end
	end
end

-- Gestión orientada a eventos para el modelo
local function monitorModel()
	if attributeConn then attributeConn:Disconnect() attributeConn = nil end
	local model = getPlayerModel()
	if not model then return end
	
	attributeConn = model:GetAttributeChangedSignal("Character"):Connect(function()
		if isBlaze() then startScript() else stopScript() end
	end)
	
	if isBlaze() then startScript() end
end

workspace:WaitForChild("Players").ChildAdded:Connect(function(child)
	if child.Name == player.Name then
		task.wait(0.5)
		monitorModel()
	end
end)

player.CharacterAdded:Connect(function(newChar)
	character = newChar
	if isScriptActive then
		task.wait(1)
		setupCharacter(newChar)
		setupViewport()
	end
end)

monitorModel()
