local CUSTOM_SPINDASH_ID = nil
local ASSET_ID = 113356537887561

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

-- Variables de estado
local currentSpindashModel = nil
local spindashSpinConnection = nil
local customCharacterModel = nil
local customCharacterActive = false
local charConnections = {}

-- ==========================================
-- SISTEMA DE DETECCIÓN DE PERSONAJE
-- ==========================================
local function checkIfKolossos()
	local playersFolder = workspace:FindFirstChild("Players")
	local playerFolder = playersFolder and playersFolder:FindFirstChild(player.Name)
	
	if not playerFolder then return false end
	
	-- Método 1: Atributos del jugador (Común en Outcome Memories)
	local charAttr = playerFolder:GetAttribute("Character") or playerFolder:GetAttribute("CharacterName")
	if charAttr and string.find(string.lower(tostring(charAttr)), "kolossos") then
		return true
	end
	
	-- Método 2: Valores StringValue en la carpeta
	for _, child in ipairs(playerFolder:GetChildren()) do
		if child:IsA("StringValue") and string.find(string.lower(child.Value), "kolossos") then
			return true
		end
	end
	
	-- Método 3: Nombre del modelo original en la carpeta Default
	local defaultFolder = playerFolder:FindFirstChild("Default")
	if defaultFolder then
		for _, child in ipairs(defaultFolder:GetChildren()) do
			if child:IsA("Model") and string.find(string.lower(child.Name), "kolossos") then
				return true
			end
		end
	end
	
	return false
end

-- ==========================================
-- LÓGICA DEL SPINDASH
-- ==========================================
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
		for _, effect in ipairs(originalPart:GetDescendants()) do
			if effect:IsA("BasePart") then effect.Transparency = 0
			elseif effect:IsA("PointLight") or effect:IsA("SpotLight") or effect:IsA("SurfaceLight") then effect.Enabled = true
			elseif effect:IsA("ParticleEmitter") or effect:IsA("Trail") or effect:IsA("Beam") then effect.Enabled = true
			end
		end
	end
end

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
	if not CUSTOM_SPINDASH_ID then return end -- Evitar error si no hay ID
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
				if effect:IsA("BasePart") then effect.Transparency = 1
				elseif effect:IsA("PointLight") or effect:IsA("SpotLight") or effect:IsA("SurfaceLight") then effect.Enabled = false
				elseif effect:IsA("ParticleEmitter") or effect:IsA("Trail") or effect:IsA("Beam") then effect.Enabled = false
				end
			end
			
			startSpindashFollow(originalPart)
		end
	end
end

RunService.Heartbeat:Connect(function()
	local isKolossos = checkIfKolossos()
	local playersFolder = workspace:FindFirstChild("Players")
	local playerFolder = playersFolder and playersFolder:FindFirstChild(player.Name)
	local spindashFolder = playerFolder and playerFolder:FindFirstChild("Spindash")
	
	if isKolossos and spindashFolder and spindashFolder:FindFirstChild("Spindash") then
		if not currentSpindashModel then
			replaceSpindashMesh()
		end
	else
		if currentSpindashModel then
			stopSpindashFollow()
		end
	end
end)

-- ==========================================
-- LÓGICA DEL PERSONAJE PRINCIPAL
-- ==========================================
local function loadAsset(id)
	local ok, objects = pcall(game.GetObjects, game, "rbxassetid://" .. id)
	if not ok or not objects or #objects == 0 then return nil end
	return objects[1]:Clone()
end

local function getPlayerModel()
	local playersFolder = workspace:FindFirstChild("Players")
	return playersFolder and playersFolder:FindFirstChild(player.Name)
end

local function isLastLife()
	local model = getPlayerModel()
	return model and model:GetAttribute("LastLife") == true
end

-- Función para limpiar y restaurar al personaje original
local function removeCustomModel()
	customCharacterActive = false
	
	-- Limpiar conexiones (Heartbeat, loops)
	for _, conn in ipairs(charConnections) do
		if typeof(conn) == "RBXScriptConnection" then conn:Disconnect() end
	end
	table.clear(charConnections)
	
	-- Destruir modelo custom
	if customCharacterModel then
		customCharacterModel:Destroy()
		customCharacterModel = nil
	end
	
	-- Restaurar visibilidad original
	if character then
		for _, v in ipairs(character:GetDescendants()) do
			if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then v.Transparency = 0 end
		end
	end
	
	local oldVisual = getPlayerModel()
	if oldVisual then
		for _, v in ipairs(oldVisual:GetDescendants()) do
			if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then v.Transparency = 0 end
		end
	end
end

-- Función para aplicar el modelo de Kolossos
local function applyCustomModel(char)
	if customCharacterActive then return end
	customCharacterActive = true
	
	local oldVisual = getPlayerModel()
	
	-- Ocultar partes originales
	for _, v in ipairs(char:GetDescendants()) do
		if v:IsA("BasePart") then v.Transparency = 1 end
	end
	if oldVisual then
		for _, v in ipairs(oldVisual:GetDescendants()) do
			if v:IsA("BasePart") then v.Transparency = 1 end
		end
	end
	
	local mdl = loadAsset(ASSET_ID)
	if not mdl then customCharacterActive = false return end
	
	mdl.Parent = oldVisual or char
	customCharacterModel = mdl

	local hrp = char:FindFirstChild("HumanoidRootPart")
	local newHrp = mdl:FindFirstChild("HumanoidRootPart")
	if not hrp or not newHrp then 
		removeCustomModel() 
		return 
	end
	
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
	
	-- Sincronización de movimiento
	local syncConn = RunService.Stepped:Connect(function()
		if not char.Parent or not hrp.Parent or not newHrp.Parent then return end
		newHrp.CFrame = hrp.CFrame
	end)
	table.insert(charConnections, syncConn)
	
	-- Loop de LastLife
	local isMonitoring = true
	task.spawn(function()
		while isMonitoring and customCharacterActive do
			local lastLifeActive = isLastLife()
			local brokenFolder = mdl:FindFirstChild("Broken")
			local circularFolder = mdl:FindFirstChild("Circular")

			if brokenFolder then
				for _, part in ipairs(brokenFolder:GetDescendants()) do
					if part:IsA("BasePart") then part.Transparency = lastLifeActive and 0 or 1 end
				end
			end
			if circularFolder then
				for _, part in ipairs(circularFolder:GetDescendants()) do
					if part:IsA("BasePart") then part.Transparency = lastLifeActive and 1 or 0 end
				end
			end
			task.wait(0.5)
		end
	end)
	
	-- Guardamos una pseudo-conexión para detener el loop de LastLife al limpiar
	table.insert(charConnections, {
		Disconnect = function() isMonitoring = false end
	})
end

-- ==========================================
-- BUCLE PRINCIPAL DE ESTADO
-- ==========================================
task.spawn(function()
	while true do
		local isKolossos = checkIfKolossos()
		
		if isKolossos then
			if not customCharacterActive and character then
				applyCustomModel(character)
			end
			
			-- Mantener partes originales ocultas por si el juego intenta forzarlas a ser visibles
			local playerFolder = getPlayerModel()
			if playerFolder then
				local defaultFolder = playerFolder:FindFirstChild("Default")
				if defaultFolder then
					local waist = defaultFolder:FindFirstChild("Waist")
					local hrpDefault = defaultFolder:FindFirstChild("HumanoidRootPart")
					if waist and waist:IsA("BasePart") then waist.Transparency = 1 end
					if hrpDefault and hrpDefault:IsA("BasePart") then hrpDefault.Transparency = 1 end
				end
			end
		else
			-- Si dejamos de usar a Kolossos y el modelo custom está activo, lo removemos
			if customCharacterActive then
				removeCustomModel()
			end
		end
		
		task.wait(0.1)
	end
end)

player.CharacterAdded:Connect(function(newChar)
	character = newChar
	-- No llamamos applyCustomModel directamente aquí, el bucle principal se encargará de evaluarlo.
end)

