-- ==========================================
-- CONFIGURACIÓN GENERAL: FEELS THE RABBIT
-- ==========================================
local MODEL_ID = 79152723176216

-- MAPA DE ANIMACIONES
local ANIMATION_MAP = {
    -- == ESTADO NORMAL ==
    [120091415341260] = 120091415341260, -- Idle
    [118996575101255] = 118996575101255, -- Walk
    [18564900441] = 18564900441,         -- Run
    [18543033295] = 18543033295,         -- Jump
    [18541933800] = 18541933800,         -- Fall
    [139392352153071] = 139392352153071, -- Hit
    [107357342747541] = 107357342747541, -- Charge
    -- == ESTADO INVISIBLE ==
    [104846083821321] = 104846083821321, -- Invisible Idle
    [9506715752629] = 9506715752629,     -- Invisible Walk/Run
    -- == ESTADO RAGE ==
    [124319832318419] = 124319832318419, -- Rage Idle
    [118996575101255] = 118996575101255, -- Rage Walk
    [9506715752629] = 9506715752629,     -- Rage Run
    -- == ESTADOS DE STUN ==
    [125835684800394] = 125835684800394, -- Stunloop
    [119975552824132] = 119975552824132, -- Stun  
    [92536334472918] = 92536334472918    -- StunEnd
}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- ==========================================
-- [NUEVO] INTERCEPTOR DE CHASE THEMES (ESTILO FROSTTER UI)
-- ==========================================
local VOLUME_MULTIPLIER = 1.5
local CacheFolder = "MusicCache/"
if not isfolder(CacheFolder) then makefolder(CacheFolder) end

-- Grupo de sonido para silenciar los originales
local silentGroup = SoundService:FindFirstChild("MuteHolder_Feels") or Instance.new("SoundGroup")
silentGroup.Name = "MuteHolder_Feels"
silentGroup.Volume = 0
silentGroup.Parent = SoundService

local soundMap = {}

local function loadCustomAsset(url, filename)
    local fullPath = CacheFolder .. filename
    if not isfile(fullPath) then
        local success, content = pcall(function() return game:HttpGet(url) end)
        if success and content then 
            writefile(fullPath, content) 
        end
    end
    return getcustomasset(fullPath)
end

local function registrarIdOriginal(pathTable, url, filename)
    local current = ReplicatedStorage:WaitForChild("ClientAssets"):WaitForChild("Sounds"):WaitForChild("mus"):WaitForChild("Game"):WaitForChild("Round"):WaitForChild("ChaseThemes")
    for _, name in ipairs(pathTable) do
        current = current:WaitForChild(name, 5)
        if not current then return end
    end
    
    if current:IsA("Sound") then
        local customAsset = loadCustomAsset(url, filename)
        current:SetAttribute("FeelsAssetPath", customAsset)
        
        -- Mapeo secundario por ID en caso de que el objeto ingame pierda la ruta
        local id = string.match(current.SoundId, "%d+") or current.SoundId
        if id and id ~= "" then
            soundMap[id] = customAsset
        end
    end
end

-- Pre-carga asíncrona de las rutas (Reemplazando a 2011x Default)
task.spawn(function()
    registrarIdOriginal({"2011x", "Default", "NormalChase"}, "https://raw.githubusercontent.com/imnotsense/LMS-Y-CHASES/main/feelsnormal.mp3", "feelsnormal.mp3")
    registrarIdOriginal({"2011x", "Default", "LastLifeChase"}, "https://raw.githubusercontent.com/imnotsense/LMS-Y-CHASES/main/feelslastlife.mp3", "feelslastlife.mp3")
    registrarIdOriginal({"2011x", "Default", "Rage"}, "https://raw.githubusercontent.com/imnotsense/LMS-Y-CHASES/main/feelsrage.mp3", "feelsrage.mp3")
end)

local function interceptarSonidoDelJuego(sound)
    if sound.ClassName ~= "Sound" then return end
    if sound.Name ~= "NormalChase" and sound.Name ~= "LastLifeChase" and sound.Name ~= "Rage" then return end
    if sound:GetAttribute("FeelsInterceptado") or string.find(sound.Name, "_CustomFeels") then return end

    local customAsset = sound:GetAttribute("FeelsAssetPath")
    
    -- Respaldo: Si el atributo no pasó, lo buscamos por su ID original
    if not customAsset then
        local intentos = 0
        while sound.SoundId == "" and intentos < 10 do 
            task.wait(0.05)
            intentos = intentos + 1 
        end
        local id = string.match(sound.SoundId, "%d+") or sound.SoundId
        customAsset = soundMap[id]
    end

    if not customAsset then return end
    sound:SetAttribute("FeelsInterceptado", true)

    -- Muteamos el original
    sound.SoundGroup = silentGroup

    -- Creamos el clon modificado
    local customSound = Instance.new("Sound")
    customSound.Name = sound.Name .. "_CustomFeels"
    customSound.SoundId = customAsset
    customSound.Looped = sound.Looped
    customSound.RollOffMaxDistance = sound.RollOffMaxDistance
    customSound.RollOffMinDistance = sound.RollOffMinDistance
    customSound.RollOffMode = sound.RollOffMode
    customSound.Parent = sound.Parent
    customSound.Playing = sound.Playing
    customSound.Volume = sound.Volume * VOLUME_MULTIPLIER

    -- Sincronización en tiempo real
    local playingConn = sound:GetPropertyChangedSignal("Playing"):Connect(function()
        customSound.Playing = sound.Playing
    end)
    local volumeConn = sound:GetPropertyChangedSignal("Volume"):Connect(function()
        customSound.Volume = sound.Volume * VOLUME_MULTIPLIER
    end)

    -- Limpieza automática
    local destroyConn
    destroyConn = sound.AncestryChanged:Connect(function(_, parent)
        if not parent then
            playingConn:Disconnect()
            volumeConn:Disconnect()
            destroyConn:Disconnect()
            if customSound then customSound:Destroy() end
        end
    end)
end

local function checkAndApplySound(desc)
    if desc:IsA("Sound") then
        task.defer(function()
            interceptarSonidoDelJuego(desc)
        end)
    end
end

workspace.DescendantAdded:Connect(checkAndApplySound)
SoundService.DescendantAdded:Connect(checkAndApplySound)
for _, desc in ipairs(workspace:GetDescendants()) do checkAndApplySound(desc) end
for _, desc in ipairs(SoundService:GetDescendants()) do checkAndApplySound(desc) end

-- ==========================================
-- 1. PRE-CARGA DEL MODELO
-- ==========================================
local success, template = pcall(function()
    return game:GetObjects("rbxassetid://" .. MODEL_ID)[1]
end)
if not success or not template then
    warn("[FeelsX] No se pudo cargar el modelo.")
    return
end
template.PrimaryPart = template:FindFirstChild("HumanoidRootPart", true) or template:FindFirstChildWhichIsA("BasePart")
for _, v in pairs(template:GetDescendants()) do
    if v:IsA("BasePart") then
        v.CanCollide = false
        v.Massless = true
        if v.Name:lower():find("root") or v.Name == "Hitbox" then  
            v.Transparency = 1 
        end
    end
end

-- ==========================================
-- 2. SISTEMA CORE: OVERRIDES, APLICAR Y REMOVER
-- ==========================================
local activeOverrides = {}

-- Función para verificar si es 2011X Default
local function isTargetVariant(char)
    -- NOTA: Ajusta "Character" y "Variant" según cómo los llame Outcome Memories exactamente
    local charName = char:GetAttribute("Character") or char.Name
    local variant = char:GetAttribute("Variant") or char:GetAttribute("Skin") or "Default"
    
    -- Si es 2011x y la variante es Default, o no hay variante definida (asumimos default)
    return (charName == "2011X" or charName == "2011x") and (variant == "Default" or variant == "default")
end

local function removeSkin(plrModel)
    local data = activeOverrides[plrModel]
    if not data then return end
    
    -- Desconectar eventos de animación
    for _, conn in ipairs(data.animConnections) do
        conn:Disconnect()
    end
    
    -- Detener animaciones custom
    for _, customTrack in pairs(data.trackMap) do
        customTrack:Stop(0.1)
    end
    
    -- Restaurar el modelo original
    for _, item in ipairs(data.partsToHide) do
        local v = item.part
        if v and v.Parent then
            if item.type == "BasePart" or item.type == "Decal" then  
                v.Transparency = item.origTrans -- Restaura la transparencia original
                if item.type == "BasePart" then
                    v.LocalTransparencyModifier = 0
                end
            elseif item.type == "Effect" then  
                v.Enabled = item.origState  
            end
        end
    end
    
    -- Destruir el modelo de Feels
    if data.model then data.model:Destroy() end
    activeOverrides[plrModel] = nil
end

local function applySkin(plrModel)
    if activeOverrides[plrModel] then return end
    if not isTargetVariant(plrModel) then return end -- Bloqueo de seguridad para variantes
    
    local customModel = template:Clone()
    customModel.Parent = plrModel  
    
    local origHum = plrModel:FindFirstChildOfClass("Humanoid")
    local fakeHum = customModel:FindFirstChildOfClass("Humanoid")
    
    local origAnimator = origHum and (origHum:FindFirstChildOfClass("Animator") or origHum)
    local fakeAnimator = fakeHum and (fakeHum:FindFirstChildOfClass("Animator") or fakeHum)
    
    local overrideData = {
        model = customModel,
        hrp = plrModel:FindFirstChild("HumanoidRootPart"),
        trackMap = {},
        animConnections = {},
        partsToHide = {} 
    }
    
    -- Caché de partes originales (Guardando su estado original para poder revertirlo)
    for _, v in pairs(plrModel:GetDescendants()) do
        if not v:IsDescendantOf(customModel) then
            if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then
                table.insert(overrideData.partsToHide, {part = v, type = "BasePart", origTrans = v.Transparency})
            elseif v:IsA("Decal") then   
                table.insert(overrideData.partsToHide, {part = v, type = "Decal", origTrans = v.Transparency})
            elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then
                table.insert(overrideData.partsToHide, {part = v, type = "Effect", origState = v.Enabled})
            end
        end
    end
    
    if origAnimator and fakeAnimator then
        local function bindAnimation(origTrack)
            if not origTrack.Animation or overrideData.trackMap[origTrack] then return end
            
            local origIdStr = tostring(origTrack.Animation.AnimationId):match("%d+")
            local origId = tonumber(origIdStr)
            
            local targetId = ANIMATION_MAP[origId] or origId 
            
            local customAnim = Instance.new("Animation")
            customAnim.AnimationId = "rbxassetid://" .. targetId
            
            local customTrack = fakeAnimator:LoadAnimation(customAnim)
            customTrack.Priority = origTrack.Priority 
            customTrack:Play(0.1)
            customTrack.TimePosition = origTrack.TimePosition
            
            overrideData.trackMap[origTrack] = customTrack
            
            local stopConn
            stopConn = origTrack.Stopped:Connect(function()
                if overrideData.trackMap[origTrack] then
                    overrideData.trackMap[origTrack]:Stop(0.1)
                    overrideData.trackMap[origTrack] = nil
                end
                if stopConn then stopConn:Disconnect() end
            end)
        end
        
        for _, origTrack in ipairs(origAnimator:GetPlayingAnimationTracks()) do
            bindAnimation(origTrack)
        end
        
        local conn = origAnimator.AnimationPlayed:Connect(function(origTrack)
            bindAnimation(origTrack)
        end)
        
        table.insert(overrideData.animConnections, conn)
    end
    
    activeOverrides[plrModel] = overrideData
end

-- ==========================================
-- 3. BUCLE PRINCIPAL (OPTIMIZADO)
-- ==========================================
RunService.Heartbeat:Connect(function()
    for plrModel, data in pairs(activeOverrides) do
        
        -- Limpieza si muere
        if not plrModel.Parent or not plrModel:FindFirstChild("Humanoid") or plrModel:FindFirstChild("Humanoid").Health <= 0 then
            removeSkin(plrModel)
            continue
        end
        
        -- Monitoreo constante por si el jugador cambia a RETRO o Miku sin morir  
        if not isTargetVariant(plrModel) then
            removeSkin(plrModel)
            continue
        end
        
        -- Ocultar Originales
        for _, item in ipairs(data.partsToHide) do
            local v = item.part
            if v and v.Parent then 
                if item.type == "BasePart" then
                    v.Transparency = 1  
                    v.LocalTransparencyModifier = 1
                elseif item.type == "Decal" then  
                    v.Transparency = 1 
                elseif item.type == "Effect" then  
                    v.Enabled = false 
                end
            end
        end
        
        -- Actualizar Posición
        if data.model.PrimaryPart and data.hrp then
            data.model:PivotTo(data.hrp.CFrame)
        end
        
        -- Sincronización y FIX de Velocidad de Animaciones
        for origTrack, customTrack in pairs(data.trackMap) do
            if origTrack.IsPlaying then
                customTrack:AdjustWeight(origTrack.Weight)
                
                -- ARREGLO DE VELOCIDAD: Si es la animación de correr
                local currentAnimId = tostring(customTrack.Animation.AnimationId)
                if currentAnimId:find("18564900441") or currentAnimId:find("9506715752629") then  
                    
                    -- Calcula la velocidad de movimiento horizontal
                    local velocity = data.hrp.AssemblyLinearVelocity
                    local flatVelocity = Vector3.new(velocity.X, 0, velocity.Z)
                    local moveSpeed = flatVelocity.Magnitude 
                    
                    -- El 16 es la velocidad base estándar de Roblox.
                    local speedMultiplier = math.clamp(moveSpeed / 32, 0.1, 4) 
                    customTrack:AdjustSpeed(speedMultiplier)
                else
                    customTrack:AdjustSpeed(1) -- Animaciones normales a velocidad normal
                end
            else
                customTrack:Stop(0.1)
                data.trackMap[origTrack] = nil
            end
        end
    end
end)

-- ==========================================
-- 4. DETECCIÓN DEL JUGADOR DINÁMICA
-- ==========================================
-- Función para vigilar cuando los atributos del personaje cambian
local function monitorCharacter(char)
    -- Intenta aplicarlo inicialmente
    task.wait(0.5) 
    applySkin(char)
    
    -- Si los atributos cambian en tiempo real, verificamos
    char.AttributeChanged:Connect(function(attributeName)
        if attributeName == "Character" or attributeName == "Variant" or attributeName == "Skin" then
            if isTargetVariant(char) then
                applySkin(char)
            else
                removeSkin(char)
            end
        end
    end)
end

local localPlayer = Players.LocalPlayer
if localPlayer.Character then
    monitorCharacter(localPlayer.Character)
end
localPlayer.CharacterAdded:Connect(function(char)
    monitorCharacter(char)
end)

print("[FeelsX] Modelo, animaciones dinámicas y sistema de audios interceptados activado.")
