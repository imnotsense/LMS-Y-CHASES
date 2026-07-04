
local UserInputService = game:GetService("UserInputService")
local SoundService = game:GetService("SoundService")
local Players = game:GetService("Players")
local LogService = game:GetService("LogService")
local Debris = game:GetService("Debris") -- Usado para limpieza de memoria
local localPlayer = Players.LocalPlayer

math.randomseed(os.time())

---------------------------------------------------------
-- 1. CONFIGURACIÓN DE PERSONAJES Y HABILIDADES
---------------------------------------------------------
local PERSONAJES_CONFIG = {
    -- ================= SILVER =================
    Silver = {
        Levitacion = {
            AnimId = "82159522474011",
            Tecla = Enum.KeyCode.E,
            Audios = {
                "https://raw.githubusercontent.com/imnotsense/LMS-Y-CHASES/main/Dialogos/Silver/levitacion/catch.mp3",
                "https://raw.githubusercontent.com/imnotsense/LMS-Y-CHASES/main/Dialogos/Silver/levitacion/easy.mp3",
                "https://raw.githubusercontent.com/imnotsense/LMS-Y-CHASES/main/Dialogos/Silver/levitacion/haha-i-catch-you.mp3",
                "https://raw.githubusercontent.com/imnotsense/LMS-Y-CHASES/main/Dialogos/Silver/levitacion/itsnotuse.mp3",
                "https://raw.githubusercontent.com/imnotsense/LMS-Y-CHASES/main/Dialogos/Silver/levitacion/noscape.mp3",
                "https://raw.githubusercontent.com/imnotsense/LMS-Y-CHASES/main/Dialogos/Silver/levitacion/i-catch-you.mp3",
                "https://raw.githubusercontent.com/imnotsense/LMS-Y-CHASES/main/Dialogos/Silver/levitacion/stop-now.mp3"
            }
        },
        Rocas = {
            AnimId = "138214151277474",
            Tecla = Enum.KeyCode.Q,
            Audios = {
                "https://raw.githubusercontent.com/imnotsense/LMS-Y-CHASES/main/Dialogos/Silver/rocas/dodge-this.mp3",
                "https://raw.githubusercontent.com/imnotsense/LMS-Y-CHASES/main/Dialogos/Silver/rocas/don-t.mp3",
                "https://raw.githubusercontent.com/imnotsense/LMS-Y-CHASES/main/Dialogos/Silver/rocas/get-2.mp3",
                "https://raw.githubusercontent.com/imnotsense/LMS-Y-CHASES/main/Dialogos/Silver/rocas/get.mp3",
                "https://raw.githubusercontent.com/imnotsense/LMS-Y-CHASES/main/Dialogos/Silver/rocas/monster.mp3",
                "https://raw.githubusercontent.com/imnotsense/LMS-Y-CHASES/main/Dialogos/Silver/rocas/stop.mp3"
            }
        }
    },
    -- ================= BLAZE =================
    Blaze = {
        Habilidad1_Patada = {
            AnimId = "119187043145187", 
            Audios = {
                "https://raw.githubusercontent.com/imnotsense/LMS-Y-CHASES/main/Dialogos/Blaze/patada/ataque.mp3",
                "https://raw.githubusercontent.com/imnotsense/LMS-Y-CHASES/main/Dialogos/Blaze/patada/ataque1.mp3",
                "https://raw.githubusercontent.com/imnotsense/LMS-Y-CHASES/main/Dialogos/Blaze/patada/ataque2.mp3",
                "https://raw.githubusercontent.com/imnotsense/LMS-Y-CHASES/main/Dialogos/Blaze/patada/ataque3.mp3",
                "https://raw.githubusercontent.com/imnotsense/LMS-Y-CHASES/main/Dialogos/Blaze/patada/ataque4.mp3",
                "https://raw.githubusercontent.com/imnotsense/LMS-Y-CHASES/main/Dialogos/Blaze/patada/ataque5.mp3",
            }
        },
        Habilidad1_Patada2 = {
            AnimId = "122240466520535", 
            Audios = {
                "https://raw.githubusercontent.com/imnotsense/LMS-Y-CHASES/main/Dialogos/Blaze/patada/ataque.mp3",
                "https://raw.githubusercontent.com/imnotsense/LMS-Y-CHASES/main/Dialogos/Blaze/patada/ataque1.mp3",
                "https://raw.githubusercontent.com/imnotsense/LMS-Y-CHASES/main/Dialogos/Blaze/patada/ataque2.mp3",
                "https://raw.githubusercontent.com/imnotsense/LMS-Y-CHASES/main/Dialogos/Blaze/patada/ataque3.mp3",
                "https://raw.githubusercontent.com/imnotsense/LMS-Y-CHASES/main/Dialogos/Blaze/patada/ataque4.mp3",
                "https://raw.githubusercontent.com/imnotsense/LMS-Y-CHASES/main/Dialogos/Blaze/patada/ataque5.mp3",
            }
        },
        Habilidad2_Solflame= {
            AnimId = "133708999826570", 
            Audios = {
                "https://raw.githubusercontent.com/imnotsense/LMS-Y-CHASES/main/Dialogos/Blaze/impulso/xd.mp3"
            }
        },
        Habilidad3_lanza = {
            AnimId = "116847882712823", 
            Audios = {
                "https://raw.githubusercontent.com/imnotsense/LMS-Y-CHASES/main/Dialogos/Blaze/lanza/1.mp3",
                "https://raw.githubusercontent.com/imnotsense/LMS-Y-CHASES/main/Dialogos/Blaze/lanza/2.mp3",
                "https://raw.githubusercontent.com/imnotsense/LMS-Y-CHASES/main/Dialogos/Blaze/lanza/3.mp3",
                "https://raw.githubusercontent.com/imnotsense/LMS-Y-CHASES/main/Dialogos/Blaze/lanza/4.mp3",
                "https://raw.githubusercontent.com/imnotsense/LMS-Y-CHASES/main/Dialogos/Blaze/lanza/5.mp3",
                "https://raw.githubusercontent.com/imnotsense/LMS-Y-CHASES/main/Dialogos/Blaze/lanza/6.mp3",
                "https://raw.githubusercontent.com/imnotsense/LMS-Y-CHASES/main/Dialogos/Blaze/lanza/7.mp3"
            }
        }
    },
    -- ================= SONIC =================
    Sonic = {
        Habilidad_spindash = {
            AnimId = "90142463830046",
            Audios = {
                "https://raw.githubusercontent.com/imnotsense/LMS-Y-CHASES/main/Dialogos/Sonic/spindash/break.mp3",
				"https://raw.githubusercontent.com/imnotsense/LMS-Y-CHASES/main/Dialogos/Sonic/spindash/cant-stop.mp3",
				"https://raw.githubusercontent.com/imnotsense/LMS-Y-CHASES/main/Dialogos/Sonic/spindash/come.mp3",
				"https://raw.githubusercontent.com/imnotsense/LMS-Y-CHASES/main/Dialogos/Sonic/spindash/ha-ha.mp3",
				"https://raw.githubusercontent.com/imnotsense/LMS-Y-CHASES/main/Dialogos/Sonic/spindash/i-m-good.mp3",
				"https://raw.githubusercontent.com/imnotsense/LMS-Y-CHASES/main/Dialogos/Sonic/spindash/let-s-go.mp3",
				"https://raw.githubusercontent.com/imnotsense/LMS-Y-CHASES/main/Dialogos/Sonic/spindash/moving.mp3",
				"https://raw.githubusercontent.com/imnotsense/LMS-Y-CHASES/main/Dialogos/Sonic/spindash/too-easy-piece-of-cake.mp3",
				"https://raw.githubusercontent.com/imnotsense/LMS-Y-CHASES/main/Dialogos/Sonic/spindash/tooslow.mp3"
            }
        },
        Habilidad_peelout = {
            AnimId = "122414915357020",
			DelayAudio = 3,
            Audios = {
                "https://raw.githubusercontent.com/imnotsense/LMS-Y-CHASES/main/Dialogos/Sonic/peelout/careful-buddy.mp3",
				"https://raw.githubusercontent.com/imnotsense/LMS-Y-CHASES/main/Dialogos/Sonic/peelout/don-t-worry-about-it.mp3",
				"https://raw.githubusercontent.com/imnotsense/LMS-Y-CHASES/main/Dialogos/Sonic/peelout/no-problem.mp3",
				"https://raw.githubusercontent.com/imnotsense/LMS-Y-CHASES/main/Dialogos/Sonic/peelout/see.mp3",
				"https://raw.githubusercontent.com/imnotsense/LMS-Y-CHASES/main/Dialogos/Sonic/peelout/sonic-s-my-name-speed-s-my-game.mp3",
				"https://raw.githubusercontent.com/imnotsense/LMS-Y-CHASES/main/Dialogos/Sonic/peelout/time.mp3",
				"https://raw.githubusercontent.com/imnotsense/LMS-Y-CHASES/main/Dialogos/Sonic/peelout/too-easy.mp3",
				"https://raw.githubusercontent.com/imnotsense/LMS-Y-CHASES/main/Dialogos/Sonic/peelout/where-d-you-go.mp3",
				"https://raw.githubusercontent.com/imnotsense/LMS-Y-CHASES/main/Dialogos/Sonic/peelout/woohoo-2.mp3",
				"https://raw.githubusercontent.com/imnotsense/LMS-Y-CHASES/main/Dialogos/Sonic/peelout/yahoo.mp3"
            }
        }
    },
    -- ================= METAL SONIC =================
    MetalSonic = {
        Habilidad_charge = {
            AnimId = "105904515272751",
            Audios = {
                "https://raw.githubusercontent.com/imnotsense/LMS-Y-CHASES/main/Dialogos/metalSonic/crush.mp3",
				"https://raw.githubusercontent.com/imnotsense/LMS-Y-CHASES/main/Dialogos/metalSonic/laughing.mp3",
				"https://raw.githubusercontent.com/imnotsense/LMS-Y-CHASES/main/Dialogos/metalSonic/metalstop.mp3",
				"https://raw.githubusercontent.com/imnotsense/LMS-Y-CHASES/main/Dialogos/metalSonic/real-sonic.mp3",
				"https://raw.githubusercontent.com/imnotsense/LMS-Y-CHASES/main/Dialogos/metalSonic/take-this.mp3"
            }
        }
    },
    -- ================= CREAM =================
    Cream = {
        Habilidad_curacion = {
            AnimId = "135664457733929",
            Audios = {
                "https://raw.githubusercontent.com/imnotsense/LMS-Y-CHASES//main/Dialogos/Cream/be-very-careful.mp3",
				"https://raw.githubusercontent.com/imnotsense/LMS-Y-CHASES//main/Dialogos/Cream/care.mp3",
				"https://raw.githubusercontent.com/imnotsense/LMS-Y-CHASES//main/Dialogos/Cream/great-job",
				"https://raw.githubusercontent.com/imnotsense/LMS-Y-CHASES//main/Dialogos/Cream/i-m-getting-tired.mp3",
				"https://raw.githubusercontent.com/imnotsense/LMS-Y-CHASES//main/Dialogos/Cream/i-m-kind-of-scared.mp3",
				"https://raw.githubusercontent.com/imnotsense/LMS-Y-CHASES//main/Dialogos/Cream/laughing.mp3",
				"https://raw.githubusercontent.com/imnotsense/LMS-Y-CHASES//main/Dialogos/Cream/this-is-making-my-head-spin.mp3",
				"https://raw.githubusercontent.com/imnotsense/LMS-Y-CHASES//main/Dialogos/Cream/what-are-we-gonna-do.mp3",
				"https://raw.githubusercontent.com/imnotsense/LMS-Y-CHASES//main/Dialogos/Cream/youcount.mp3",
            }
        }
    },
    -- ================= KNUCKLES =================
    Knuckles = {
        Habilidad_golpe = {
            AnimId = "81392931271245",
            Audios = {
                "https://raw.githubusercontent.com/imnotsense/LMS-Y-CHASES/main/Dialogos/Knuckles/Golpe/alright.mp3",
				"https://raw.githubusercontent.com/imnotsense/LMS-Y-CHASES/main/Dialogos/Knuckles/Golpe/can-t-deal.mp3",
				"https://raw.githubusercontent.com/imnotsense/LMS-Y-CHASES/main/Dialogos/Knuckles/Golpe/don-t-make.mp3",
				"https://raw.githubusercontent.com/imnotsense/LMS-Y-CHASES/main/Dialogos/Knuckles/Golpe/fight.mp3",
				"https://raw.githubusercontent.com/imnotsense/LMS-Y-CHASES/main/Dialogos/Knuckles/Golpe/finally.mp3",
				"https://raw.githubusercontent.com/imnotsense/LMS-Y-CHASES/main/Dialogos/Knuckles/Golpe/given-up.mp3",
				"https://raw.githubusercontent.com/imnotsense/LMS-Y-CHASES/main/Dialogos/Knuckles/Golpe/no-joke.mp3"
            }
        },
        Habilidad_counter = {
            AnimId = "110853733886406",
            Audios = {
                "https://raw.githubusercontent.com/imnotsense/LMS-Y-CHASES/main/Dialogos/Knuckles/counter/doing.mp3",
				"https://raw.githubusercontent.com/imnotsense/LMS-Y-CHASES/main/Dialogos/Knuckles/counter/not-strong.mp3",
				"https://raw.githubusercontent.com/imnotsense/LMS-Y-CHASES/main/Dialogos/Knuckles/counter/practice.mp3",
				"https://raw.githubusercontent.com/imnotsense/LMS-Y-CHASES/main/Dialogos/Knuckles/counter/see-ya.mp3",
				"https://raw.githubusercontent.com/imnotsense/LMS-Y-CHASES/main/Dialogos/Knuckles/counter/serious.mp3",
				"https://raw.githubusercontent.com/imnotsense/LMS-Y-CHASES/main/Dialogos/Knuckles/counter/waste.mp3",
				"https://raw.githubusercontent.com/imnotsense/LMS-Y-CHASES/main/Dialogos/Knuckles/counter/what-the.mp3"
            }
        }
    }
}

---------------------------------------------------------
-- 2. DESCARGA SEGURA Y MAPEO DE AUDIOS
---------------------------------------------------------
if not isfolder("MusicCache") then makefolder("MusicCache") end

local function descargarAudioSeguro(fileName, url)
    local ruta = "MusicCache/" .. fileName
    
    -- Verificar que el archivo existe y no está corrupto/vacío
    if isfile(ruta) and #readfile(ruta) > 500 then 
        return getcustomasset(ruta) 
    end

    local exito, resultado
    local intentos = 0
    
    -- Intenta descargarlo hasta 3 veces
    while intentos < 3 do
        exito, resultado = pcall(function()
            return game:HttpGet(url)
        end)
        
        if exito and resultado and #resultado > 500 then
            writefile(ruta, resultado)
            return getcustomasset(ruta)
        end
        intentos = intentos + 1
        task.wait(0.5) -- Espera antes del reintento para evitar bloqueos
    end
    
    warn("No se pudo descargar el audio: " .. url)
    return nil
end

local AUDIOS_CARGADOS = {}
local contadorArchivos = 1

-- Corrutina para no congelar el juego mientras descarga los 80 audios
task.spawn(function()
    for nombrePersonaje, habilidades in pairs(PERSONAJES_CONFIG) do
        for nombreHabilidad, datos in pairs(habilidades) do
            AUDIOS_CARGADOS[nombreHabilidad] = {} 
            
            for _, url in ipairs(datos.Audios) do
                local fileName = "voice_cache_" .. contadorArchivos .. ".mp3"
                local assetCargado = descargarAudioSeguro(fileName, url)
                
                if assetCargado then
                    table.insert(AUDIOS_CARGADOS[nombreHabilidad], assetCargado)
                end
                
                contadorArchivos = contadorArchivos + 1
                task.wait(0.05) -- Pausa mínima para no saturar los Rate Limits de GitHub
            end
        end
    end
    print("¡Todos los audios han sido cargados correctamente!")
end)

---------------------------------------------------------
-- 3. REPRODUCTOR DE AUDIO
---------------------------------------------------------
local function playSound(assetPath)
    local sound = Instance.new("Sound")
    sound.SoundId = assetPath
    sound.Volume = 1
    sound.Parent = SoundService 
    sound:Play()
    
    -- Se elimina cuando termina, o con Debris como respaldo seguro
    sound.Ended:Connect(function() sound:Destroy() end)
    Debris:AddItem(sound, 10) 
end

local function playRandomSound(assetTable)
    if not assetTable or #assetTable == 0 then return end 
    local selectedAsset = assetTable[math.random(1, #assetTable)]
    playSound(selectedAsset)
end

---------------------------------------------------------
-- 4. CAPTURAR LA INTENCIÓN DEL JUGADOR
---------------------------------------------------------
local ultimaHabilidadIntentada = nil

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    
    for _, habilidades in pairs(PERSONAJES_CONFIG) do
        for nombreHabilidad, datos in pairs(habilidades) do
            if datos.Tecla and (input.KeyCode == datos.Tecla or input.UserInputType == datos.Tecla) then
                ultimaHabilidadIntentada = nombreHabilidad
                
                task.delay(2, function()
                    if ultimaHabilidadIntentada == nombreHabilidad then
                        ultimaHabilidadIntentada = nil
                    end
                end)
            end
        end
    end
end)

LogService.MessageOut:Connect(function(message, messageType)
    local textoConsola = string.match(message, "%d+") 
    
    if textoConsola == "1" then
        ultimaHabilidadIntentada = "Levitacion"
    elseif textoConsola == "2" then
        ultimaHabilidadIntentada = "Rocas"
    end
    
    task.delay(2, function()
        ultimaHabilidadIntentada = nil
    end)
end)

---------------------------------------------------------
-- 5. DETECCIÓN EXACTA (ANIMACIONES) - ARREGLADO
---------------------------------------------------------
-- Extrae solo el ID numérico ignorando "rbxassetid://" o "http://"
local function extraerId(texto)
    return string.match(tostring(texto), "%d+")
end

local function setupCharacter(character)
    local humanoid = character:WaitForChild("Humanoid", 5)
    if not humanoid then return end
    
    local animator = humanoid:WaitForChild("Animator", 5)
    if not animator then return end

    animator.AnimationPlayed:Connect(function(animTrack)
        if not animTrack.Animation then return end
        
        -- Obtiene solo los números de la animación que se está reproduciendo
        local currentAnimId = extraerId(animTrack.Animation.AnimationId)
        if not currentAnimId then return end
        
        for _, habilidades in pairs(PERSONAJES_CONFIG) do
            for nombreHabilidad, datos in pairs(habilidades) do
                
                -- Compara los puros números en lugar del string completo
                if extraerId(datos.AnimId) == currentAnimId then
                    if datos.Tecla then
                        if ultimaHabilidadIntentada == nombreHabilidad then
                            playRandomSound(AUDIOS_CARGADOS[nombreHabilidad])
                            ultimaHabilidadIntentada = nil 
                            return
                        end
                    else
                        playRandomSound(AUDIOS_CARGADOS[nombreHabilidad])
                        return
                    end
                end
                
            end
        end
    end)
end

if localPlayer.Character then setupCharacter(localPlayer.Character) end
localPlayer.CharacterAdded:Connect(setupCharacter)
