-- ============================================================================
--  SCRIPT FROSTTER
-- ============================================================================
local SoundService = game:GetService("SoundService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- Crear la carpeta de caché principal si no existe
if not isfolder("MusicCache") then
    makefolder("MusicCache")
end

-- ============================================================================
-- SCRIPT 1: PARCHE UNIVERSAL PARA TEMAS DEL LMS (SOLO THEMES)
-- ============================================================================
task.spawn(function()
    local soloThemeFolder = ReplicatedStorage:WaitForChild("ClientAssets"):WaitForChild("Sounds"):WaitForChild("mus"):WaitForChild("Game"):WaitForChild("Round"):WaitForChild("SoloTheme")

    local nuevosTemas = {
        ["TailsSolo"] = "https://raw.githubusercontent.com/imnotsense/LMS-Y-CHASES/main/tails.mp3",
        ["CreamSolo"] = "https://raw.githubusercontent.com/imnotsense/LMS-Y-CHASES/main/cream.mp3",
        ["EggmanSolo"] = "https://raw.githubusercontent.com/imnotsense/LMS-Y-CHASES/main/eggman.mp3",
        ["KnucklesSolo"] = "https://raw.githubusercontent.com/imnotsense/LMS-Y-CHASES/main/knuckles.mp3",
        ["MetalSonicSolo"] = "https://raw.githubusercontent.com/imnotsense/LMS-Y-CHASES/main/metalsonic.mp3",
        ["SonicSolo"] = "https://raw.githubusercontent.com/imnotsense/LMS-Y-CHASES/main/sonic.mp3",
        ["AmySolo"] = "https://raw.githubusercontent.com/imnotsense/LMS-Y-CHASES/main/amy.mp3",
        ["SilverSolo"] = "https://raw.githubusercontent.com/imnotsense/LMS-Y-CHASES/main/silver.mp3",
        ["BlazeSolo"] = "https://raw.githubusercontent.com/imnotsense/LMS-Y-CHASES/main/blaze.mp3",
        ["ShadowSolo"] = "https://raw.githubusercontent.com/imnotsense/LMS-Y-CHASES/main/shadow.mp3"
    }

    -- Función pura de Roblox para detectar cuándo el juego intenta apagar la música
    local function aplicarDetectorDeApagado(objetoSonido)
        if not objetoSonido:IsA("Sound") then return end

        objetoSonido.Looped = false
        local ultimaPosicion = 0

        objetoSonido:GetPropertyChangedSignal("TimePosition"):Connect(function()
            local posicionActual = objetoSonido.TimePosition

            -- Si la canción estaba avanzada (más de 1 segundo) y de golpe cae a 0 mientras sigue activa...
            if posicionActual == 0 and ultimaPosicion > 1 and objetoSonido.Playing then
                -- ...significa que el juego intentó mandarla al final para apagarla. La frenamos por completo.
                objetoSonido:Stop()
            end

            ultimaPosicion = posicionActual
        end)
        
        -- Evitar también que el juego reactive el 'Looped' por código interno
        objetoSonido:GetPropertyChangedSignal("Looped"):Connect(function()
            if objetoSonido.Looped then
                objetoSonido.Looped = false
            end
        end)
    end

    print("[LMS] Cargando música de personajes, porfavor espere un momento.")
    for personaje, url in pairs(nuevosTemas) do
        local objetoSonido = soloThemeFolder:FindFirstChild(personaje)

        if objetoSonido and objetoSonido:IsA("Sound") then
            local ruta = "MusicCache/" .. personaje .. ".mp3"

            local exito, contenido = pcall(function()
                return game:HttpGet(url)
            end)

            if exito and contenido then
                writefile(ruta, contenido)

                objetoSonido:Stop()
                objetoSonido.SoundId = ""
                task.wait(0.1)

                objetoSonido.SoundId = getcustomasset(ruta)
                
                -- Activamos el detector compatible en este sonido
                aplicarDetectorDeApagado(objetoSonido)
                print("[LMS] Música personalizada aplicada con éxito de:", personaje)
            else
                warn("[LMS] No se pudo descargar la música de:", personaje)
            end
        else
            warn("[LMS] No se encontró el objeto de sonido para:", personaje)
        end
    end

    -- Asegurar el resto de sonidos de la carpeta por si acaso
    for _, sonido in pairs(soloThemeFolder:GetChildren()) do
        aplicarDetectorDeApagado(sonido)
    end
    print("[LMS] aplicando fix.")
end)

-- ============================================================================
-- SCRIPT 2: FILTRO INTERCEPTOR INTELIGENTE (CHASE THEMES)
-- ============================================================================
task.spawn(function()
    -- 1. Crear el canal de audio secreto totalmente muteado
    local silentGroup = SoundService:FindFirstChild("MuteHolder_Custom")
    if not silentGroup then
        silentGroup = Instance.new("SoundGroup")
        silentGroup.Name = "MuteHolder_Custom"
        silentGroup.Volume = 0
        silentGroup.Parent = SoundService
    end

    -- Función para cargar assets de GitHub
    local function loadCustomAsset(url, filename)
        if not isfile(filename) then
            writefile(filename, game:HttpGet(url, true))
        end
        return getcustomasset(filename)
    end

    local soundMap = {}

    local function normalizeId(id)
        return string.match(id, "%d+") or id
    end

    -- Registrar los IDs originales de ReplicatedStorage e inyectar etiquetas inteligentes
    local function registrarIdOriginal(pathTable, url, filename, multiplicadorVolumen)
        local current = ReplicatedStorage:WaitForChild("ClientAssets"):WaitForChild("Sounds"):WaitForChild("mus"):WaitForChild("Game"):WaitForChild("Round"):WaitForChild("ChaseThemes"):WaitForChild("2011x")
        for _, name in ipairs(pathTable) do
            current = current:WaitForChild(name, 5)
            if not current then return end
        end
        if current:IsA("Sound") and current.SoundId ~= "" then
            local customAsset = loadCustomAsset(url, filename)
            
            -- Le pegamos una etiqueta al archivo original.
            current:SetAttribute("CustomAssetPath", customAsset)
            current:SetAttribute("CustomVolumeMult", multiplicadorVolumen)
            
            local idNormalizado = normalizeId(current.SoundId)
            soundMap[idNormalizado] = {asset = customAsset, mult = multiplicadorVolumen}
        end
    end

    print("[CHASE] iniciando remplazo de chase")

    -- Variantes DEFAULT
    registrarIdOriginal({"Default", "NormalChase"}, "https://github.com/imnotsense/LMS-Y-CHASES/raw/refs/heads/main/2011x%20normal.mp3", "2011NormalChase_v2.mp3", 2)
    registrarIdOriginal({"Default", "LastLifeChase"}, "https://github.com/imnotsense/LMS-Y-CHASES/raw/refs/heads/main/2011x%20lastlife.mp3", "2011LastLifeChase_v2.mp3", 2)

    -- Variantes RETRO
    registrarIdOriginal({"RETRO", "NormalChase"}, "https://github.com/imnotsense/LMS-Y-CHASES/raw/refs/heads/main/CLASSICO%202011X%20CHASETHEME.mp3", "NormalChase_v2.mp3", 2)
    registrarIdOriginal({"RETRO", "LastLifeChase"}, "https://github.com/imnotsense/LMS-Y-CHASES/raw/refs/heads/main/lastlife%20classic%202011x.mp3", "lastlifeClassic_v2.mp3", 2)

    -- Variantes RAGE
    registrarIdOriginal({"Default", "Rage"}, "https://github.com/imnotsense/LMS-Y-CHASES/raw/refs/heads/main/2011X%20RAGE.mp3", "NormalRage.mp3", 1.2)
    registrarIdOriginal({"RETRO", "Rage"}, "https://raw.githubusercontent.com/IceKnight125/OutcomeMemories1227/main/ClassicRage.mp3", "ClassicRage.mp3", 1.2)
    registrarIdOriginal({"miku", "Rage"}, "https://raw.githubusercontent.com/IceKnight125/OutcomeMemories1227/main/MikuRage.mp3", "MikuRage.mp3", 1.2)

    -- INTERCEPTOR EVOLUCIONADO CON LECTURA DE ATRIBUTOS
    local function interceptarSonidoDelJuego(sound)
        if not sound:IsA("Sound") then return end
        if sound.Name ~= "NormalChase" and sound.Name ~= "LastLifeChase" and sound.Name ~= "Rage" then return end
        if sound:GetAttribute("Interceptado") or string.find(sound.Name, "_Custom") then return end
        
        -- Prioridad 1: Leer directamente la etiqueta inteligente clonada
        local customAsset = sound:GetAttribute("CustomAssetPath")
        local volumeMult = sound:GetAttribute("CustomVolumeMult")
        
        -- Prioridad 2: Si el clon no tiene etiquetas (Plan B), buscar por mapa de IDs
        if not customAsset then
            local intentos = 0
            while sound.SoundId == "" and intentos < 15 do
                task.wait(0.05)
                intentos = intentos + 1
            end
            local idNorm = normalizeId(sound.SoundId)
            local datosCustom = soundMap[idNorm]
            if datosCustom then
                customAsset = datosCustom.asset
                volumeMult = datosCustom.mult
            end
        end
        
        -- Si no es ninguno de nuestros audios mapeados, ignorar
        if not customAsset then return end
        
        sound:SetAttribute("Interceptado", true)
        
        -- Mutear el audio original enviándolo al canal silencioso
        sound.SoundGroup = silentGroup
        
        -- Crear clon musical personalizado
        local customSound = Instance.new("Sound")
        customSound.Name = sound.Name .. "_Custom"
        customSound.SoundId = customAsset
        customSound.Looped = sound.Looped
        customSound.RollOffMaxDistance = sound.RollOffMaxDistance
        customSound.RollOffMinDistance = sound.RollOffMinDistance
        customSound.RollOffMode = sound.RollOffMode
        customSound.Parent = sound.Parent
        
        -- Bucle de sincronización en tiempo real
        local heartbeatConn
        heartbeatConn = RunService.Heartbeat:Connect(function()
            if not sound or not sound.Parent then
                if customSound then customSound:Stop(); customSound:Destroy() end
                if heartbeatConn then heartbeatConn:Disconnect() end
                return
            end
            
            customSound.Playing = sound.Playing
            customSound.Volume = sound.Volume * (volumeMult or 1)
            
            if math.abs(customSound.TimePosition - sound.TimePosition) > 0.3 then
                customSound.TimePosition = sound.TimePosition
            end
        end)
    end

    -- Monitorear zonas activas
    workspace.DescendantAdded:Connect(interceptarSonidoDelJuego)
    SoundService.DescendantAdded:Connect(interceptarSonidoDelJuego)
    Players.LocalPlayer.DescendantAdded:Connect(interceptarSonidoDelJuego)

    -- Escaneo de seguridad inicial
    for _, desc in ipairs(workspace:GetDescendants()) do interceptarSonidoDelJuego(desc) end
    for _, desc in ipairs(SoundService:GetDescendants()) do interceptarSonidoDelJuego(desc) end
    for _, desc in ipairs(Players.LocalPlayer:GetDescendants()) do interceptarSonidoDelJuego(desc) end

    print("[CHASE] usica chase remplazada correctamente.")
end)

print("====================================================================")
print("script Frostter aplicado correctamente puedes disfrutar sin errores.")
print("====================================================================")
