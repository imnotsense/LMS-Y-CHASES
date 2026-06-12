local workspace = game:GetService("Workspace")
local terrain = workspace:WaitForChild("Terrain")

-- 1. Reducir la calidad visual del terreno de Roblox
terrain.WaterWaveSize = 0
terrain.WaterWaveSpeed = 0
terrain.WaterReflectance = 0
terrain.WaterTransparency = 0

-- 2. Función para simplificar cada objeto
local function optimizarObjeto(instancia)
    if instancia:IsA("BasePart") then
        -- Cambiar material a SmoothPlastic quita las texturas de relieve (bump maps)
        instancia.Material = Enum.Material.SmoothPlastic
        instancia.CastShadow = false
    elseif instancia:IsA("Decal") or instancia:IsA("Texture") then
        -- Eliminar texturas decorativas pegadas a los bloques
        instancia:Destroy()
    elseif instancia:IsA("ParticleEmitter") or instancia:IsA("Trail") or instancia:IsA("Beam") then
        -- Desactivar efectos de partículas y rayos que consumen mucho rendimiento
        instancia.Enabled = false
    end
end

-- 3. Aplicar la optimización a todo lo que ya está en el mapa
for _, objeto in pairs(workspace:GetDescendants()) do
    optimizarObjeto(objeto)
end

-- 4. Asegurarse de optimizar los objetos nuevos que el juego vaya cargando (StreamingEnabled)
workspace.DescendantAdded:Connect(optimizarObjeto)

print("Optimización de rendimiento aplicada exitosamente.")
