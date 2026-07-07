-- ==========================================
-- CONFIGURACIÓN GENERAL
-- ==========================================
local MODEL_ID = 137849313997239
local VOLUME_MULTIPLIER = 1.5 -- Ajusta esto para aumentar el volumen (ej: 1.5 = 150% de volumen)

local urlsDirectas = {
    [80901931085615] = "https://raw.githubusercontent.com/imnotsense/LMS-Y-CHASES/main/chases/Glorbwire-normal.mp3",
    [112879248941055] = "https://raw.githubusercontent.com/imnotsense/LMS-Y-CHASES/main/chases/Glorbwire-Lastlife.mp3"
}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

-- ==========================================
-- 1. SISTEMA DE MÚSICA (OPTIMIZADO)
-- ==========================================
local CacheFolder = "cache/musicas-directas/"
if not isfolder("cache") then makefolder("cache") end
if not isfolder(CacheFolder) then makefolder(CacheFolder) end

local assetsProcesados = {}

local function applyReplacement(instance)
    if not instance:IsA("Sound") then return end
    local id = tonumber(instance.SoundId:match("rbxassetid://(%d+)"))
    if id and assetsProcesados[id] then 
        instance.SoundId = assetsProcesados[id]
        instance.Volume = instance.Volume * VOLUME_MULTIPLIER
    end
end

-- Pre-cargar assets
for id, url in pairs(urlsDirectas) do
    local fileName = url:match("([^/]+)$"):gsub("%?.*", "")
    local path = CacheFolder .. fileName
    if not isfile(path) then
        local response = (http_request or request)({Url = url, Method = "GET"})
        if response.StatusCode == 200 then writefile(path, response.Body) end
    end
    assetsProcesados[id] = getcustomasset(path)
end

game.DescendantAdded:Connect(applyReplacement)
for _, obj in ipairs(game:GetDescendants()) do applyReplacement(obj) end

-- ==========================================
-- 2. CARGAR MODELO Y GESTIÓN DE JUGADORES (OPTIMIZADA Y SIN LETRERO)
-- ==========================================
local template = game:GetObjects("rbxassetid://" .. MODEL_ID)[1]
template.PrimaryPart = template:FindFirstChild("HumanoidRootPart", true) or template:FindFirstChildWhichIsA("BasePart")

-- Filtrar y limpiar el modelo original
for _,v in pairs(template:GetDescendants()) do
    if v:IsA("BasePart") then
        v.CanCollide = false
        v.Massless = true
        v:SetAttribute("TransparenciaOriginal", (v.Name:lower():find("claw") or v.Name:lower():find("garra")) and 0 or v.Transparency)
        if v.Name:lower():find("root") or v.Name == "Hitbox" then v.Transparency = 1 end
    elseif v:IsA("BillboardGui") or v:IsA("SurfaceGui") then
        -- [NUEVO] Esto detecta y elimina el nombre "Glorbwire" que flota sobre el personaje
        v:Destroy()
    end
end

local activeOverrides = {}

local function applySkin(plrModel)
    if activeOverrides[plrModel] then return end
    local customModel = template:Clone()
    customModel.Parent = plrModel
    
    local origHum = plrModel:FindFirstChildOfClass("Humanoid")
    local fakeHum = customModel:FindFirstChildOfClass("Humanoid")
    
    local origAnimator = origHum and (origHum:FindFirstChildOfClass("Animator") or origHum)
    local fakeAnimator = fakeHum and (fakeHum:FindFirstChildOfClass("Animator") or fakeHum)
    
    local overrideData = {
        model = customModel,
        hrp = plrModel:FindFirstChild("HumanoidRootPart"),
        origHum = origHum,
        fakeHum = fakeHum,
        trackMap = {},
        animConnections = {}, 
        partsToHide = {}      
    }
    
    -- Pre-cachear las partes
    for _,v in pairs(plrModel:GetDescendants()) do
        if not v:IsDescendantOf(customModel) then
            if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then
                table.insert(overrideData.partsToHide, {part = v, type = "BasePart"})
            elseif v:IsA("Decal") then
                table.insert(overrideData.partsToHide, {part = v, type = "Decal"})
            elseif v:IsA("ParticleEmitter") then
                table.insert(overrideData.partsToHide, {part = v, type = "ParticleEmitter"})
            end
        end
    end

    if origAnimator and fakeAnimator then
        local function bindAnimation(origTrack)
            if not origTrack.Animation or overrideData.trackMap[origTrack] then return end
            
            local customTrack = fakeAnimator:LoadAnimation(origTrack.Animation)
            customTrack.Priority = origTrack.Priority
            customTrack:Play(0.1) 
            
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

RunService.Heartbeat:Connect(function()
    for plrModel, data in pairs(activeOverrides) do
        if not plrModel.Parent or plrModel:GetAttribute("Character") ~= "TailsDoll" then
            for _, conn in ipairs(data.animConnections) do
                conn:Disconnect()
            end
            data.model:Destroy()
            activeOverrides[plrModel] = nil
            continue
        end

        -- Ocultar original
        for _, item in ipairs(data.partsToHide) do
            local v = item.part
            if v and v.Parent then
                if item.type == "BasePart" then 
                    v.Transparency = 1 
                    v.LocalTransparencyModifier = 1
                elseif item.type == "Decal" then 
                    v.Transparency = 1
                elseif item.type == "ParticleEmitter" then 
                    v.Enabled = false 
                end
            end
        end

        -- Actualizar posición
        if data.model.PrimaryPart and data.hrp then
            data.model:PivotTo(data.hrp.CFrame)
        end
        
        -- Seguridad Anti-Stuck de Animaciones
        for origTrack, customTrack in pairs(data.trackMap) do
            if origTrack.IsPlaying then
                customTrack:AdjustWeight(origTrack.Weight)
            else
                customTrack:Stop(0.1)
                data.trackMap[origTrack] = nil
            end
        end
    end
end)

-- Detectores de eventos
workspace:WaitForChild("Players").ChildAdded:Connect(function() task.wait(1); for _,p in pairs(workspace.Players:GetChildren()) do if p:GetAttribute("Character")=="TailsDoll" then applySkin(p) end end end)
print("[Glorbwire] Optimización aplicada, animaciones corregidas y letrero eliminado.")
