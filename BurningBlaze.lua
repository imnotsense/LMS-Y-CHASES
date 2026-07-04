local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local ASSET_ID = 75175137287879
local ICON_ID = "rbxassetid://78720790829181"
local isScriptActive = false
local currentMdl = nil
local syncConn = nil
local vpConn = nil

-- ==========================================
-- SISTEMA DE CACHÉ (AQUÍ ESTÁ LA MAGIA)
-- ==========================================
local modelCache = {}

local function getCachedAsset(id)
	-- Si no está en el caché, lo descargamos UNA sola vez
	if not modelCache[id] then
		local ok, objects = pcall(game.GetObjects, game, "rbxassetid://" .. id)
		if ok and objects and #objects > 0 then
			modelCache[id] = objects[1]
		else
			return nil
		end
	end
	-- Clonamos el modelo guardado en memoria (muy rápido y consume menos RAM)
	return modelCache[id]:Clone()
end

-- ==========================================
-- FUNCIONES PRINCIPALES
-- ==========================================
local function getPlayerModel()
	local playersFolder = workspace:FindFirstChild("Players")
	return playersFolder and playersFolder:FindFirstChild(player.Name)
end

local function isBlaze()
	local model = getPlayerModel()
	return model and model:GetAttribute("Character") == "Blaze"
end

local function replacePlayerFrame()
	local pg = player.PlayerGui
	local teamsGui = pg:FindFirstChild("Round") and pg.Round:FindFirstChild("Game") and pg.Round.Game:FindFirstChild("Teams")
	if not teamsGui then return end
	local playerFrame = nil
	
	for _ = 1, 20 do
		playerFrame = teamsGui:FindFirstChild(player.Name)
		if playerFrame then break end
		task.wait(0.25)
	end
	
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
			-- Usamos el caché en lugar de volver a descargar
			local newModel = getCachedAsset(ASSET_ID)
			if not newModel then return end

			if vpOverrideModel and vpOverrideModel.Parent then
				vpOverrideModel:Destroy()
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

		if vpConn then vpConn:Disconnect() end
		
		-- Sistema de Anti-Spam (Debounce) para evitar lag al cargar piezas
		local isReplacing = false 
		vpConn = viewportModel.DescendantAdded:Connect(function()
			if isReplacing or not isScriptActive then return end
			isReplacing = true
			task.wait(0.1)
			if isScriptActive and (not vpOverrideModel or not vpOverrideModel.Parent) then
				vpOverrideModel = nil
				replaceViewportModel()
			end
			isReplacing = false
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

	local playersFolder = workspace:FindFirstChild("Players")
	local oldVisual = playersFolder and playersFolder:FindFirstChild(player.Name)
	if oldVisual then
		for _, v in ipairs(oldVisual:GetDescendants()) do
			if v:IsA("BasePart") then v.Transparency = 1 end
		end
	end

	-- Usamos el caché aquí también
	local mdl = getCachedAsset(ASSET_ID)
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
			task.wait(0.5) -- Relajado de 0.1 a 0.5 para ahorrar rendimiento
		end
	end)

	-- Icono
	task.spawn(function()
		task.wait(1)
		replacePlayerFrame()
		while isScriptActive do
			local playersF = workspace:FindFirstChild("Players")
			local playerF = playersF and playersF:FindFirstChild(player.Name)
			while playerF and playerF:FindFirstChild("Dodges") do task.wait(0.5) end
			while playerF and not playerF:FindFirstChild("Dodges") do task.wait(0.25) end
			task.wait(2)
			replacePlayerFrame()
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
	if vpConn then vpConn:Disconnect() vpConn = nil end
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
		setupViewport()
	end
end)

local isCurrentlyBlaze = false

-- Optimizado: En vez de un Heartbeat que se ejecuta 60 veces por segundo, chequea cada medio segundo
task.spawn(function()
	while task.wait(0.5) do
		local check = isBlaze()
		if check ~= isCurrentlyBlaze then
			isCurrentlyBlaze = check
			if isCurrentlyBlaze then startScript() else stopScript() end
		end
	end
end)

if isBlaze() then
	isCurrentlyBlaze = true
	startScript()
end
