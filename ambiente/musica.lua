-- ==========================================
-- CONFIGURACIÓN DE RUTAS Y CACHÉ
-- ==========================================
local CacheFolder = "cache/mis-musicas-directas/"

if not isfolder("cache") then makefolder("cache") end
if not isfolder(CacheFolder) then makefolder(CacheFolder) end

print("[Mod de Música] Cargando assets desde URLs directas...")

-- ==========================================
-- LÓGICA DE DESCARGA DESDE URL DIRECTA
-- ==========================================
local function getAssetFromURL(url)
    -- Extraemos el nombre del archivo automáticamente del final de la URL (ej: "cancion.mp3")
    local fileName = url:match("([^/]+)$")
    if fileName then fileName = fileName:gsub("%?.*", "") end -- Limpia parámetros si la URL los tiene
    if not fileName or fileName == "" then fileName = tostring(math.random(10000, 99999)) .. ".mp3" end
    
    local cachePath = CacheFolder .. fileName
    
    -- Si ya descargó este enlace antes, carga el archivo local
    if isfile(cachePath) then 
        return getcustomasset(cachePath) 
    end
    
    local requestFunc = request or http_request or (http and http.request) or (syn and syn.request)
    local fileData = nil
    
    if requestFunc then
        local response = requestFunc({ Url = url, Method = "GET" })
        if response.StatusCode == 200 then
            fileData = response.Body
        else
            warn("[Mod de Música] Error al descargar de URL: " .. url)
            return nil
        end
    else
        warn("[Mod de Música] Ejecutor sin soporte avanzado. Intentando HttpGet...")
        local success, result = pcall(function() return game:HttpGet(url) end)
        if success then fileData = result end
    end
    
    if fileData then
        writefile(cachePath, fileData)
        return getcustomasset(cachePath)
    end
    
    return nil
end

-- ==========================================
-- TUS ENLACES DIRECTOS (MAPEO)
-- ==========================================
-- Simplemente pon el ID original y pégale el enlace directo a tu canción (ejemplo de Discord, GitHub raw, etc.)
local urlsDirectas = {
    [107720742914927] = "https://raw.githubusercontent.com/imnotsense/LMS-Y-CHASES/main/ambiente/lobby.mp3",
    [119969978733663] = "https://raw.githubusercontent.com/imnotsense/LMS-Y-CHASES/main/ambiente/greenhill.mp3",
	[106923842104274] = "https://raw.githubusercontent.com/imnotsense/LMS-Y-CHASES/main/ambiente/castillox.mp3",
	[102103667512970] = "https://raw.githubusercontent.com/imnotsense/LMS-Y-CHASES/main/ambiente/notperfectv1.mp3",
	[104635517725559] = "https://raw.githubusercontent.com/imnotsense/LMS-Y-CHASES/main/ambiente/ycr.mp3"
}

-- Procesamos las URLs ANTES de buscar los sonidos para no causar lag en el juego
local assetsProcesados = {}
for id, url in pairs(urlsDirectas) do
    assetsProcesados[id] = getAssetFromURL(url)
end

-- ==========================================
-- INTERCEPCIÓN E INYECCIÓN
-- ==========================================
if _G.CustomMusicConnection then
	_G.CustomMusicConnection:Disconnect()
	_G.CustomMusicConnection = nil
end

local function applyReplacement(instance)
    if not instance:IsA("Sound") then return end

    local id = tonumber(instance.SoundId:match("rbxassetid://(%d+)"))
    
    -- Aplicamos el asset que ya fue procesado y descargado
    if id and assetsProcesados[id] then 
        instance.SoundId = assetsProcesados[id] 
    end
end

for _, obj in ipairs(game:GetDescendants()) do
    applyReplacement(obj)
end

_G.CustomMusicConnection = game.DescendantAdded:Connect(applyReplacement)

print("[Mod de Música] Script inyectado con enlaces directos.")
