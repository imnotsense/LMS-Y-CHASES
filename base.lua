-- ============================================================================
-- SISTEMA DE WHITELIST Y NOTIFICACIÓN INICIAL
-- ============================================================================
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")
local StarterGui = game:GetService("StarterGui")

-- Notificación al ejecutar
pcall(function()
    StarterGui:SetCore("SendNotification", {
        Title = "Frostter UI",
        Text = "Este scrpt esta echo para no dar ventajas injustas a los usuarios",
        Duration = 10
    })
end)

local WhitelistUsuarios = {
    ["TicoNutria"]=true, ["Metalix_24"]=true, ["periquitoRolox"]=true, ["  "]=true, ["  "]=true, ["  "]=true, ["  "]=true, ["  "]=true, ["  "]=true, ["  "]=true, ["  "]=true, ["  "]=true, ["  "]=true, ["  "]=true, ["  "]=true, ["  "]=true, ["  "]=true, ["  "]=true, ["  "]=true, ["  "]=true, ["  "]=true, ["  "]=true, ["  "]=true, ["  "]=true, ["  "]=true, ["  "]=true, ["  "]=true, ["  "]=true, 
    ["  "]=true, ["  "]=true, ["  "]=true, ["  "]=true, ["  "]=true, ["  "]=true, ["  "]=true, ["  "]=true, ["  "]=true, ["  "]=true, ["  "]=true, ["  "]=true, ["  "]=true, ["  "]=true, ["  "]=true, ["  "]=true, ["  "]=true, ["  "]=true, ["  "]=true, ["  "]=true, ["  "]=true, ["  "]=true, ["  "]=true, ["  "]=true, ["  "]=true, ["  "]=true, ["  "]=true, ["  "]=true, ["  "]=true, ["  "]=true, ["  "]=true, ["  "]=true, ["  "]=true, ["  "]=true, ["  "]=true, ["  "]=true, ["  "]=true, ["  "]=true, ["  "]=true, ["  "]=true, ["  "]=true, ["  "]=true, ["  "]=true, ["  "]=true, ["  "]=true, ["  "]=true, ["  "]=true, ["  "]=true, ["  "]=true, ["  "]=true, ["  "]=true, ["  "]=true, ["  "]=true, ["  "]=true, ["  "]=true, ["  "]=true, ["  "]=true, ["  "]=true, ["  "]=true, ["  "]=true, ["  "]=true, ["  "]=true, ["  "]=true, ["  "]=true, ["  "]=true, ["  "]=true, ["  "]=true, ["  "]=true, ["  "]=true, ["  "]=true, ["  "]=true, ["  "]=true, ["  "]=true, ["  "]=true, ["  "]=true, ["  "]=true, ["  "]=true, ["  "]=true, ["  "]=true, ["  "]=true, ["  "]=true, ["  "]=true, ["  "]=true, ["  "]=true, ["  "]=true, ["  "]=true, ["  "]=true, ["  "]=true, ["  "]=true, ["  "]=true, ["  "]=true, ["  "]=true, ["  "]=true, ["  "]=true, ["  "]=true, ["  "]=true, ["  "]=true, ["  "]=true, ["  "]=true, ["  "]=true, ["  "]=true, ["  "]=true, ["  "]=true, ["  "]=true, ["  "]=true
} 
local UsuariosBaneados = {["UsuarioMalo1"]=true, ["UsuarioMalo2"]=true} 
local miNombre = LocalPlayer.Name

if UsuariosBaneados[miNombre] then return end
if not WhitelistUsuarios[miNombre] then
    local sg = Instance.new("ScreenGui")
    sg.Name = "BloqueoAcceso"
    sg.IgnoreGuiInset = true
    pcall(function() sg.Parent = CoreGui end)
    if not sg.Parent then sg.Parent = LocalPlayer:WaitForChild("PlayerGui") end 
    local bg = Instance.new("Frame", sg)
    bg.Size = UDim2.new(1, 0, 1, 0)    
    bg.BackgroundColor3 = Color3.new(0, 0, 0)     
    bg.BorderSizePixel = 0        
    local txt = Instance.new("TextLabel", bg)
    txt.Size = UDim2.new(1, 0, 1, 0)
    txt.BackgroundTransparency = 1
    txt.TextColor3 = Color3.fromRGB(255, 50, 50)
    txt.TextScaled = true
    txt.Font = Enum.Font.GothamBlack
    txt.Text = "NO AUTORIZADO\n\nESTÚPIDO ESTÚPIDO ESTÚPIDO"        
    local wlSound = Instance.new("Sound", bg)
    wlSound.SoundId = "rbxassetid://2496367477"     
    wlSound.Looped = true
    wlSound.Volume = 10
    wlSound:Play()
    return
end

-- ============================================================================
-- SERVICIOS Y REQUISITOS GENERALES
-- ============================================================================
local SoundService = game:GetService("SoundService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")

local UsuariosDEV = {"TicoNutria", "Metalix_24", "periquitoRolox"} 
local EsDesarrollador = table.find(UsuariosDEV, LocalPlayer.Name) ~= nil
local Atmosfera_Quitada = false
local Chase_Activo = true
local Fleetway_LMS_Activo = false
local LMS_Estados = {} 
local SoloTheme_Volume_Multiplier = 2
local Voices_Volume_Multiplier = 2 
local lmsOriginalIds = {}
local chaseObjects = setmetatable({}, {__mode = "k"}) 
local nuevosTemasGlobal = {}
local togglesLMSUI = {} 
local atmosphereStorage = Instance.new("Folder")
atmosphereStorage.Name = "AtmosphereStorage_Custom"
atmosphereStorage.Parent = ReplicatedStorage
if not isfolder("MusicCache") then makefolder("MusicCache") end

local forkliftTemplate = nil
for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
    if obj.Name == "Forklift" and (obj:IsA("Model") or obj:IsA("BasePart")) then    
        forkliftTemplate = obj        
        break    
    end
end

-- ============================================================================
-- BASE DE DATOS DE EMOTES
-- ============================================================================
local EmotesDatabase = {
    ["2011x"] = {
        {Name = "Maria Carey", IsLoop = true, TraversalSpeed = 3, MusicId = "rbxassetid://112568013507036", AnimationId = "rbxassetid://92888638699962"},
        {Name = "Hype", IsLoop = true, TraversalSpeed = 3, MusicId = "rbxassetid://126067106312692", AnimationId = "rbxassetid://78545771079470"},
        {Name = "Low Cortisol", IsLoop = true, TraversalSpeed = 0, MusicId = "rbxassetid://140078004639253", AnimationId = "rbxassetid://114520618733897"},
        {Name = "Jersey Hog", IsLoop = true, TraversalSpeed = 2, MusicId = "rbxassetid://112812055823784", AnimationId = "rbxassetid://127191399093079"}
    },
    ["Kolossos"] = {
        {Name = "MISSME", IsLoop = true, TraversalSpeed = 3, MusicId = "rbxassetid://135366495265781", AnimationId = "rbxassetid://81730809348394"},
        {Name = "POINT", IsLoop = false, TraversalSpeed = 3, MusicId = "rbxassetid://0", AnimationId = "rbxassetid://140180851930686"},
        {Name = "METROMAN", IsLoop = true, TraversalSpeed = 3, MusicId = "rbxassetid://99258536244671", AnimationId = "rbxassetid://107195453398060"},
        {Name = "Laugh", IsLoop = false, TraversalSpeed = 0, MusicId = "rbxassetid://84405830596541", AnimationId = "rbxassetid://102779996718354"}
    },
    ["Fleetway"] = {
        {Name = "EVERYBEAT2", IsLoop = true, TraversalSpeed = 3, MusicId = "rbxassetid://120207366318005", AnimationId = "rbxassetid://99056305997710"},
        {Name = "JEVILHOP2", IsLoop = true, TraversalSpeed = 2, MusicId = "rbxassetid://127548237541414", AnimationId = "rbxassetid://92404765326260"},
        {Name = "YOUAJERK", IsLoop = true, TraversalSpeed = 3, MusicId = "rbxassetid://106119520633962", AnimationId = "rbxassetid://106340447585086"} 
    },
    ["Tailsdoll"] = {
        {Name = "TRIPWIRETIME", IsLoop = true, TraversalSpeed = 3, MusicId = "rbxassetid://116253727062662", AnimationId = "rbxassetid://112656139256072"},
        {Name = "tripwiresit", IsLoop = true, TraversalSpeed = 0.001, MusicId = "rbxassetid://0", AnimationId = "rbxassetid://92259033776440"},
        {Name = "ImposterSyndrome", IsLoop = true, TraversalSpeed = 0, MusicId = "rbxassetid://104146703087176", AnimationId = "rbxassetid://100732265533480"},
        {Name = "caramelldance", IsLoop = true, TraversalSpeed = 0, MusicId = "rbxassetid://110105399048016", AnimationId = "rbxassetid://81240310070946"}   
    },
    ["Tails"] = {
        {Name = "Rat Dance", IsLoop = true, TraversalSpeed = 0, MusicId = "rbxassetid://105826132589844", AnimationId = "rbxassetid://73313302543888"},
        {Name = "SitTails", IsLoop = true, TraversalSpeed = 0, MusicId = "rbxassetid://139085759707240", AnimationId = "rbxassetid://132926716277265"},
        {Name = "Cory", IsLoop = true, TraversalSpeed = 0, MusicId = "rbxassetid://128210514182301", AnimationId = "rbxassetid://118810363050448"},
        {Name = "Pipebomb", IsLoop = true, TraversalSpeed = 0, MusicId = "rbxassetid://119640578709774", AnimationId = "rbxassetid://137946742808216"},    
        {Name = "Helicopter", IsLoop = false, TraversalSpeed = 0, MusicId = "rbxassetid://137931208091292", AnimationId = "rbxassetid://89515158858178"},
        {Name = "Who", IsLoop = false, TraversalSpeed = 0, MusicId = "rbxassetid://83086967155682", AnimationId = "rbxassetid://84541229170186"},
        {Name = "horse", IsLoop = true, TraversalSpeed = 5, MusicId = "rbxassetid://1842306536", AnimationId = "rbxassetid://93036777474390"},
        {Name = "GoodbyeForever2", IsLoop = true, TraversalSpeed = 5, MusicId = "rbxassetid://83964029063021", AnimationId = "rbxassetid://96963375850749"},
        {Name = "horse2", IsLoop = false, TraversalSpeed = 80, MusicId = "rbxassetid://138614007074047", AnimationId = "rbxassetid://93428801145717",
            OnUse = function(p1) pcall(function() if p1.Parent:FindFirstChild(p1.Name .. "horse") then p1.Parent[p1.Name .. "horse"]:Destroy() end local v1 = script.Horse:Clone() v1.Parent = p1.Parent v1.Name = p1.Name .. "horse" v1:PivotTo(p1:GetPivot()) local Weld = Instance.new("Weld") Weld.Parent = p1.HumanoidRootPart Weld.C0 = CFrame.new(Vector3.new(-0.001, 3.607, -0.017)) Weld.Part0 = p1.HumanoidRootPart Weld.Part1 = v1.Body if p1:FindFirstChild("cam") and p1.cam:FindFirstChild("lock") then p1.cam.lock.Value = v1.Sphere end game:GetService("CollectionService"):AddTag(p1, "IFrame") end) end,
            OnLeave = function(p1) p1:RemoveTag("IFrame") if workspace:FindFirstChild(p1.Name .. "horse") then workspace:FindFirstChild(p1.Name .. "horse"):Destroy() end if p1:FindFirstChild("cam") and p1.cam:FindFirstChild("lock") then p1.cam.lock.Value = nil end end
        }
    },
    ["Silver"] = {
        {Name = "ReleaseTheGhouls", IsLoop = true, TraversalSpeed = 0, MusicId = "rbxassetid://126064088265111", AnimationId = "rbxassetid://76998542362740"},
        {Name = "LevitateRest", IsLoop = true, TraversalSpeed = 0, MusicId = "rbxassetid://114355770737315", AnimationId = "rbxassetid://127010236869854"}
    },
    ["Blaze"] = {
        {Name = "ReleaseTheGhouls", IsLoop = true, TraversalSpeed = 0, MusicId = "rbxassetid://126064088265111", AnimationId = "rbxassetid://104705063785739"},
        {Name = "ChineseCat", IsLoop = true, TraversalSpeed = 0, MusicId = "rbxassetid://86638249245610", AnimationId = "rbxassetid://129541820196808"},
        {Name = "Skachacha", IsLoop = true, TraversalSpeed = 0, MusicId = "rbxassetid://81579040406533", AnimationId = "rbxassetid://128435480269503"}
    },
    ["Sonic"] = {
        {Name = "babydance", IsLoop = true, TraversalSpeed = 0, MusicId = "rbxassetid://90901236525070", AnimationId = "rbxassetid://79203936383675"},
        {Name = "RelaxingSonic", IsLoop = true, TraversalSpeed = 0, MusicId = "rbxassetid://96306683591059", AnimationId = "rbxassetid://104062552147146"},
        {Name = "Waiting", IsLoop = true, TraversalSpeed = 0, MusicId = "rbxassetid://129956345965154", AnimationId = "rbxassetid://132709141019647"},
        {Name = "shonic", IsLoop = true, TraversalSpeed = 0, MusicId = "rbxassetid://119556420416832", AnimationId = "rbxassetid://124702409687881"},
        {Name = "Medicine", IsLoop = true, TraversalSpeed = 0, MusicId = "rbxassetid://81957643358938", AnimationId = "rbxassetid://86397585701161"},
        {Name = "Paced", IsLoop = true, TraversalSpeed = 0, MusicId = "rbxassetid://78655470001151", AnimationId = "rbxassetid://117900173410005"},
        {Name = "Do It", IsLoop = true, TraversalSpeed = 0, MusicId = "rbxassetid://138820000124792", AnimationId = "rbxassetid://115044322367992"},
        {Name = "INPATIENCE", IsLoop = true, TraversalSpeed = 0, MusicId = "rbxassetid://2111554497", AnimationId = "rbxassetid://87992356942409"},
        {Name = "TICKTOCK", IsLoop = true, TraversalSpeed = 0, MusicId = "rbxassetid://117144052716723", AnimationId = "rbxassetid://93800356049298"},
        {Name = "PEANUTBUTTERJELLY", IsLoop = true, TraversalSpeed = 0, MusicId = "rbxassetid://119249777974685", AnimationId = "rbxassetid://113910526539334"},
        {Name = "RingWalk", IsLoop = true, TraversalSpeed = 5, MusicId = "rbxassetid://83964029063021", AnimationId = "rbxassetid://123377580352862"}, 
        {Name = "pipebomb2", IsLoop = true, TraversalSpeed = 5, MusicId = "rbxassetid://119640578709774", AnimationId = "rbxassetid://130034868708651"},
        {Name = "TickTock", IsLoop = true, TraversalSpeed = 0, MusicId = "rbxassetid://73526950119661", AnimationId = "rbxassetid://95107785706455"},
        {Name = "Diaries", IsLoop = true, TraversalSpeed = 0, MusicId = "rbxassetid://76173803344707", AnimationId = "rbxassetid://92897830029002",
            OnUse = function(p1) if p1:FindFirstChild("Book") or p1:FindFirstChild("Feather") then return end if not script:FindFirstChild("Feather") or not script:FindFirstChild("Book") then return end local v1 = script.Feather:Clone(); v1.Parent = p1; v1:PivotTo(p1.HumanoidRootPart.CFrame * CFrame.Angles(0, 0, -1.5707963267948966)); v1.Root.CFrame = p1.HumanoidRootPart.CFrame * CFrame.Angles(0, 0, -1.5707963267948966); local Motor6D = Instance.new("Motor6D"); Motor6D.Name = v1.Feather.Name; Motor6D.Part0 = p1.HumanoidRootPart; Motor6D.Part1 = v1.Feather; Motor6D.C0 = p1.HumanoidRootPart.CFrame:toObjectSpace(v1.Feather.CFrame); Motor6D.Parent = v1.Feather; local v3 = script.Book:Clone(); v3.Parent = p1; v3:PivotTo(p1.HumanoidRootPart.CFrame); local Motor6D2 = Instance.new("Motor6D"); Motor6D2.Name = v3.PrimaryPart.Name; Motor6D2.Part0 = p1.HumanoidRootPart; Motor6D2.Part1 = v3.PrimaryPart; Motor6D2.C0 = p1.HumanoidRootPart.CFrame:toObjectSpace(v3.PrimaryPart.CFrame); Motor6D2.Parent = v3.PrimaryPart end,
            OnLeave = function(p1) if p1:FindFirstChild("Feather") then p1.Feather:Destroy() end if p1:FindFirstChild("Book") then p1.Book:Destroy() end end
        }
    },
    ["Metalsonic"] = {
        {Name = "Egg Rolled2", IsLoop = true, TraversalSpeed = 0, MusicId = "rbxassetid://103896803231829", AnimationId = "rbxassetid://128123227077719"},
        {Name = "fancystyle", IsLoop = true, TraversalSpeed = 0, MusicId = "rbxassetid://103189160690380", AnimationId = "rbxassetid://124654816579604"},
        {Name = "Lonely", IsLoop = true, TraversalSpeed = 0, MusicId = "rbxassetid://77269072383403", AnimationId = "rbxassetid://116357078780443"},
        {Name = "Thinking", IsLoop = true, TraversalSpeed = 0, MusicId = "rbxassetid://9043366464", AnimationId = "rbxassetid://116585917682409"},
        {Name = "ComeCloser", IsLoop = true, TraversalSpeed = 0, MusicId = "rbxassetid://131169447699141", AnimationId = "rbxassetid://76249045959187"}
    },
    ["Cream"] = {
        {Name = "Overdrive", IsLoop = true, TraversalSpeed = 0, MusicId = "rbxassetid://78649217959001", AnimationId = "rbxassetid://126157584199051"},
        {Name = "CatSwing", IsLoop = true, TraversalSpeed = 0, MusicId = "rbxassetid://97335273261339", AnimationId = "rbxassetid://119996423025347"},
        {Name = "JEVILHOP", IsLoop = true, TraversalSpeed = 0, MusicId = "rbxassetid://110723101893449", AnimationId = "rbxassetid://137069582420732"},
        {Name = "Penguindance", IsLoop = true, TraversalSpeed = 0, MusicId = "rbxassetid://76378854930188", AnimationId = "rbxassetid://136126837988845"},
        {Name = "Waving", IsLoop = false, TraversalSpeed = 0, MusicId = "rbxassetid://88033678198864", AnimationId = "rbxassetid://101475077691415"},
        {Name = "griddy", IsLoop = true, TraversalSpeed = 5, MusicId = "rbxassetid://77501488098123", AnimationId = "rbxassetid://88275250559180"} 
    },
    ["Amy"] = {
        {Name = "Surprised", IsLoop = true, TraversalSpeed = 0, MusicId = "rbxassetid://128251124090446", AnimationId = "rbxassetid://95622465731556"},
        {Name = "Headbang", IsLoop = true, TraversalSpeed = 0, MusicId = "rbxassetid://135336648388670", AnimationId = "rbxassetid://113537674050921"},
        {Name = "DanceOfJustice", IsLoop = true, TraversalSpeed = 0, MusicId = "rbxassetid://71722262464105", AnimationId = "rbxassetid://97841662978305"},
        {Name = "Smiley", IsLoop = true, TraversalSpeed = 0, MusicId = "rbxassetid://114050562679490", AnimationId = "rbxassetid://83086430858295"}   
    },
    ["Eggman"] = {
        {Name = "Egg Rolled", IsLoop = true, TraversalSpeed = 3, MusicId = "rbxassetid://77202079956843", AnimationId = "rbxassetid://109633747241470"},
        {Name = "Sturdy", IsLoop = true, TraversalSpeed = 0, MusicId = "rbxassetid://78459140178909", AnimationId = "rbxassetid://123633884307468"},
        {Name = "Boohoo", IsLoop = true, TraversalSpeed = 0, MusicId = "rbxassetid://0", AnimationId = "rbxassetid://118361359360130"},
        {Name = "Master Plan", IsLoop = true, TraversalSpeed = 0, MusicId = "rbxassetid://81715060320729", AnimationId = "rbxassetid://135726076356843"},   
        {Name = "whydidyoupost", IsLoop = true, TraversalSpeed = 0, MusicId = "rbxassetid://81715060320729", AnimationId = "rbxassetid://75695304745148"},
        {Name = "EGGLY", IsLoop = true, TraversalSpeed = 0, MusicId = "rbxassetid://104056772578784", AnimationId = "rbxassetid://125599236186100"},
        {Name = "Bird Word", IsLoop = true, TraversalSpeed = 0, MusicId = "rbxassetid://75327454531443", AnimationId = "rbxassetid://126886074967700"}
    },
    ["Knuckles"] = {
        {Name = "Stephanie", IsLoop = true, TraversalSpeed = 0, MusicId = "rbxassetid://91940041220689", AnimationId = "rbxassetid://140682945610579"},    
        {Name = "ChillOut", IsLoop = true, TraversalSpeed = 0, MusicId = "rbxassetid://89185337796161", AnimationId = "rbxassetid://96036373262427"},
        {Name = "Aura", IsLoop = true, TraversalSpeed = 0, MusicId = "rbxassetid://89185337796161", AnimationId = "97453636614232"},
        {Name = "Sitting", IsLoop = true, TraversalSpeed = 0, MusicId = "rbxassetid://0", AnimationId = "rbxassetid://79209172925447"},
        {Name = "Dothatthing", IsLoop = true, TraversalSpeed = 0, MusicId = "rbxassetid://112624207180199", AnimationId = "rbxassetid://78791270212133"},
        {Name = "HITEVERYBEAT", IsLoop = true, TraversalSpeed = 0, MusicId = "rbxassetid://120207366318005", AnimationId = "rbxassetid://80597715589852"}
    },
    ["Shadow"] = {
        {Name = "babydance", IsLoop = true, TraversalSpeed = 0, MusicId = "rbxassetid://90901236525070", AnimationId = "rbxassetid://79203936383675"},
    }
} 
local currentAnimTrack = nil
local currentEmoteSound = nil
local activeEmoteData = nil
local lastSelectedEmote = nil
local globalEmoteVolume = 1

-- ============================================================================
-- CREACIÓN DE LA INTERFAZ GRÁFICA (UI) PREMIUM (REWORK)
-- ============================================================================
local ScreenGui = Instance.new("ScreenGui")
local exitoGui, _ = pcall(function() ScreenGui.Parent = CoreGui end)
if not exitoGui then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end
ScreenGui.Name = "Frostter UI V3.0"
ScreenGui.ResetOnSpawn = false
local ColorAcento1 = Color3.fromRGB(0, 255, 204)
local ColorAcento2 = Color3.fromRGB(204, 0, 255)
local TransicionRapida = TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
local TransicionSuave = TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
local ArcoirisActivo = true
local UIGradientColorDefault = ColorSequence.new{
    ColorSequenceKeypoint.new(0.00, Color3.fromRGB(18, 14, 28)),
    ColorSequenceKeypoint.new(0.50, Color3.fromRGB(25, 18, 38)),
    ColorSequenceKeypoint.new(1.00, Color3.fromRGB(12, 10, 20))
}

local QuickEmoteBtn = Instance.new("TextButton")
QuickEmoteBtn.Size = UDim2.new(0, 50, 0, 50)
QuickEmoteBtn.Position = UDim2.new(0, 80, 1, -80)
QuickEmoteBtn.BackgroundColor3 = Color3.fromRGB(20, 15, 30)
QuickEmoteBtn.BackgroundTransparency = 0.1
QuickEmoteBtn.Text = "🕺"
QuickEmoteBtn.TextSize = 24
QuickEmoteBtn.Visible = UserInputService.TouchEnabled
QuickEmoteBtn.Parent = ScreenGui
Instance.new("UICorner", QuickEmoteBtn).CornerRadius = UDim.new(1, 0)
local QuickEmoteStroke = Instance.new("UIStroke", QuickEmoteBtn)
QuickEmoteStroke.Thickness = 3
QuickEmoteStroke.Color = ColorAcento1
local StrokeAnim = TweenService:Create(QuickEmoteStroke, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {Color = ColorAcento2})

task.spawn(function()
    while true do     
        if not activeEmoteData and QuickEmoteBtn.Visible then
            if StrokeAnim.PlaybackState ~= Enum.PlaybackState.Playing then StrokeAnim:Play() end
        else
            if StrokeAnim.PlaybackState == Enum.PlaybackState.Playing then StrokeAnim:Cancel() end
            QuickEmoteStroke.Color = ColorAcento1
        end
        task.wait(1)
    end
end)

local BetaWatermark = Instance.new("TextLabel")
BetaWatermark.Size = UDim2.new(0, 100, 0, 15)
BetaWatermark.Position = UDim2.new(0, 10, 0.5, 0)
BetaWatermark.BackgroundTransparency = 1
BetaWatermark.Text = "Frostter UI V3.0"
BetaWatermark.TextColor3 = ColorAcento1
BetaWatermark.TextTransparency = 0.2
BetaWatermark.Font = Enum.Font.GothamBlack
BetaWatermark.TextScaled = true 
local WatermarkConstraint = Instance.new("UITextSizeConstraint", BetaWatermark)
WatermarkConstraint.MaxTextSize = 12
BetaWatermark.TextXAlignment = Enum.TextXAlignment.Left
BetaWatermark.Parent = ScreenGui

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 450, 0, 550)
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 12, 22)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Active = true
MainFrame.Parent = ScreenGui

local UIGradient = Instance.new("UIGradient")
UIGradient.Color = UIGradientColorDefault
UIGradient.Rotation = 0
UIGradient.Parent = MainFrame
TweenService:Create(UIGradient, TweenInfo.new(5, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1), {Rotation = 360}):Play()

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = MainFrame
local UIStroke = Instance.new("UIStroke")
UIStroke.Thickness = 2
UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
UIStroke.Parent = MainFrame

task.spawn(function()
    while true do       
        task.wait(0.05)
        if ArcoirisActivo then UIStroke.Color = Color3.fromHSV(tick() / 5 % 1, 0.7, 1) end
    end
end)

local UIScale = Instance.new("UIScale")
UIScale.Scale = 0
UIScale.Parent = MainFrame

local function obtenerEscalaResponsiva()
    local viewportSize = workspace.CurrentCamera.ViewportSize
    local escalaX = viewportSize.X / 480
    local escalaY = viewportSize.Y / 580
    return math.min(escalaX, escalaY, 1)
end
workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
    if UIScale.Scale > 0 then UIScale.Scale = obtenerEscalaResponsiva() end
end)

local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 60)
TitleBar.BackgroundTransparency = 1
TitleBar.Parent = MainFrame
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -70, 1, 0)
Title.Position = UDim2.new(0, 20, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "FROSTTER UI V3.0 (Abrir con K)"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBlack
Title.TextSize = 16
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TitleBar

local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 36, 0, 36)
CloseButton.Position = UDim2.new(1, -48, 0, 12)
CloseButton.BackgroundColor3 = Color3.fromRGB(255, 50, 80)
CloseButton.Text = "✕"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.Font = Enum.Font.GothamBlack
CloseButton.TextSize = 18
CloseButton.AutoButtonColor = false
CloseButton.Parent = TitleBar
Instance.new("UICorner", CloseButton).CornerRadius = UDim.new(0, 12)

CloseButton.MouseEnter:Connect(function() TweenService:Create(CloseButton, TransicionRapida, {BackgroundColor3 = Color3.fromRGB(255, 100, 120)}):Play() end)
CloseButton.MouseLeave:Connect(function() TweenService:Create(CloseButton, TransicionRapida, {BackgroundColor3 = Color3.fromRGB(255, 50, 80)}):Play() end)

local function CreateScroll()
    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, -20, 1, -125)     
    scroll.Position = UDim2.new(0, 10, 0, 110)
    scroll.BackgroundTransparency = 1
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scroll.ScrollBarThickness = 4
    scroll.ScrollBarImageColor3 = ColorAcento1
    scroll.BorderSizePixel = 0
    return scroll
end

local SettingsFrame = CreateScroll()
SettingsFrame.Parent = MainFrame
local SettingsListLayout = Instance.new("UIListLayout")
SettingsListLayout.SortOrder = Enum.SortOrder.LayoutOrder
SettingsListLayout.Padding = UDim.new(0, 12)
SettingsListLayout.Parent = SettingsFrame

local EmotesFrame = Instance.new("Frame")
EmotesFrame.Size = UDim2.new(1, -20, 1, -125)
EmotesFrame.Position = UDim2.new(0, 10, 0, 110)
EmotesFrame.BackgroundTransparency = 1
EmotesFrame.Visible = false
EmotesFrame.Parent = MainFrame

local CustomFrame = CreateScroll()
CustomFrame.Visible = false
CustomFrame.Parent = MainFrame
local CustomListLayout = Instance.new("UIListLayout")
CustomListLayout.SortOrder = Enum.SortOrder.LayoutOrder
CustomListLayout.Padding = UDim.new(0, 12)
CustomListLayout.Parent = CustomFrame

-- ============================================================================
-- NUEVA PESTAÑA: CRÉDITOS
-- ============================================================================
local CreditosFrame = CreateScroll()
CreditosFrame.Visible = false
CreditosFrame.Parent = MainFrame

local CajaCreditos = Instance.new("TextBox")
CajaCreditos.Size = UDim2.new(1, 0, 0, 200)
CajaCreditos.BackgroundColor3 = Color3.fromRGB(25, 20, 35)
CajaCreditos.Text = "Diseñado por:\nFrostter_uwu\n\n(Puedes modificar este texto)"
CajaCreditos.TextColor3 = Color3.new(1, 1, 1)
CajaCreditos.Font = Enum.Font.GothamBlack
CajaCreditos.TextSize = 16
CajaCreditos.TextScaled = false
CajaCreditos.ClearTextOnFocus = false
CajaCreditos.TextWrapped = true
CajaCreditos.Parent = CreditosFrame
Instance.new("UICorner", CajaCreditos).CornerRadius = UDim.new(0, 8)

-- Bucle optimizado para el efecto RGB en el texto de los créditos
task.spawn(function()
    while true do
        task.wait(0.05)
        if CreditosFrame.Visible then
            CajaCreditos.TextColor3 = Color3.fromHSV(tick() / 5 % 1, 0.8, 1)
        end
    end
end)

local DevFrame, DevListLayout
if EsDesarrollador then
    DevFrame = CreateScroll()
    DevFrame.Visible = false
    DevFrame.Parent = MainFrame
    DevListLayout = Instance.new("UIListLayout")
    DevListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    DevListLayout.Padding = UDim.new(0, 12)
    DevListLayout.Parent = DevFrame
end

local function updateTabs(activeFrame)
    SettingsFrame.Visible = activeFrame == "Ajustes"
    EmotesFrame.Visible = activeFrame == "Emotes"
    CustomFrame.Visible = activeFrame == "Personalizar"
    CreditosFrame.Visible = activeFrame == "Creditos"
    if EsDesarrollador then DevFrame.Visible = activeFrame == "Dev" end
end

-- ============================================================================
-- SISTEMA DE PESTAÑAS
-- ============================================================================
local TabDropdownBtn = Instance.new("TextButton")
TabDropdownBtn.Size = UDim2.new(1, -40, 0, 36)
TabDropdownBtn.Position = UDim2.new(0, 20, 0, 60)
TabDropdownBtn.BackgroundColor3 = Color3.fromRGB(20, 15, 25)
TabDropdownBtn.Text = "Pestaña: Ajustes ▼"
TabDropdownBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
TabDropdownBtn.Font = Enum.Font.GothamBold
TabDropdownBtn.TextSize = 12
TabDropdownBtn.AutoButtonColor = false
TabDropdownBtn.Parent = MainFrame
TabDropdownBtn.ZIndex = 15
Instance.new("UICorner", TabDropdownBtn).CornerRadius = UDim.new(0, 8)
Instance.new("UIStroke", TabDropdownBtn).Color = ColorAcento2

local TabDropdownList = Instance.new("ScrollingFrame")
TabDropdownList.Size = UDim2.new(1, -40, 0, 120)
TabDropdownList.Position = UDim2.new(0, 20, 0, 100)
TabDropdownList.BackgroundColor3 = Color3.fromRGB(20, 15, 25)
TabDropdownList.BorderSizePixel = 0
TabDropdownList.ZIndex = 20
TabDropdownList.Visible = false
TabDropdownList.CanvasSize = UDim2.new(0, 0, 0, 0)
TabDropdownList.AutomaticCanvasSize = Enum.AutomaticSize.Y
TabDropdownList.ScrollBarThickness = 4
TabDropdownList.ScrollBarImageColor3 = ColorAcento1
TabDropdownList.Parent = MainFrame
Instance.new("UICorner", TabDropdownList).CornerRadius = UDim.new(0, 8)
Instance.new("UIStroke", TabDropdownList).Color = ColorAcento2
local TabLayout = Instance.new("UIListLayout")
TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabLayout.Parent = TabDropdownList

-- Se agregó "Creditos" a la lista
local listaPestanas = {"Ajustes", "Emotes", "Personalizar", "Creditos"}
if EsDesarrollador then table.insert(listaPestanas, "Dev") end

for i, tabName in ipairs(listaPestanas) do  
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 35)
    btn.BackgroundColor3 = Color3.fromRGB(20, 15, 25)
    btn.Text = tabName
    btn.TextColor3 = Color3.fromRGB(150, 140, 160)
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 12
    btn.ZIndex = 20
    btn.AutoButtonColor = false
    btn.Parent = TabDropdownList
    btn.LayoutOrder = i
    
    btn.MouseEnter:Connect(function() TweenService:Create(btn, TransicionRapida, {BackgroundColor3 = Color3.fromRGB(40, 30, 50)}):Play() end)
    btn.MouseLeave:Connect(function() TweenService:Create(btn, TransicionRapida, {BackgroundColor3 = Color3.fromRGB(20, 15, 25)}):Play() end)
    
    btn.MouseButton1Click:Connect(function()
        updateTabs(tabName)
        TabDropdownBtn.Text = "Pestaña: " .. tabName .. " ▼"
        TabDropdownList.Visible = false
        for _, child in ipairs(TabDropdownList:GetChildren()) do
            if child:IsA("TextButton") then
                child.TextColor3 = Color3.fromRGB(150, 140, 160)
                child.Font = Enum.Font.GothamMedium 
            end
        end
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Font = Enum.Font.GothamBold
    end)
end

TabDropdownBtn.MouseButton1Click:Connect(function()
    TabDropdownList.Visible = not TabDropdownList.Visible
end)
updateTabs("Ajustes")
if TabDropdownList:FindFirstChildWhichIsA("TextButton") then
    local primerBtn = TabDropdownList:FindFirstChildWhichIsA("TextButton")
    primerBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    primerBtn.Font = Enum.Font.GothamBold
end

local EmoteHeader = Instance.new("Frame")
EmoteHeader.Size = UDim2.new(1, 0, 0, 45)
EmoteHeader.BackgroundTransparency = 1
EmoteHeader.Parent = EmotesFrame
local SelectedEmoteLabel = Instance.new("TextLabel")
SelectedEmoteLabel.Size = UDim2.new(1, 0, 0, 20)
SelectedEmoteLabel.BackgroundTransparency = 1
SelectedEmoteLabel.Text = "Ningún Emote Seleccionado"
SelectedEmoteLabel.TextColor3 = ColorAcento1
SelectedEmoteLabel.Font = Enum.Font.GothamBold
SelectedEmoteLabel.TextSize = 12
SelectedEmoteLabel.TextXAlignment = Enum.TextXAlignment.Center
SelectedEmoteLabel.Parent = EmoteHeader

local VolumeContainer = Instance.new("Frame")
VolumeContainer.Size = UDim2.new(1, -20, 0, 20)
VolumeContainer.Position = UDim2.new(0, 10, 0, 25)
VolumeContainer.BackgroundTransparency = 1
VolumeContainer.Parent = EmoteHeader
local VolumeIcon = Instance.new("TextLabel")
VolumeIcon.Size = UDim2.new(0, 20, 1, 0)
VolumeIcon.BackgroundTransparency = 1
VolumeIcon.Text = "🔊"
VolumeIcon.TextSize = 12
VolumeIcon.Parent = VolumeContainer
local VolTrack = Instance.new("Frame")
VolTrack.Size = UDim2.new(1, -30, 0, 6)
VolTrack.Position = UDim2.new(0, 30, 0.5, -3)
VolTrack.BackgroundColor3 = Color3.fromRGB(30, 25, 40)
VolTrack.Parent = VolumeContainer
Instance.new("UICorner", VolTrack).CornerRadius = UDim.new(1, 0)
local VolFill = Instance.new("Frame")
VolFill.Size = UDim2.new(1, 0, 1, 0)
VolFill.BackgroundColor3 = ColorAcento2
VolFill.Parent = VolTrack
Instance.new("UICorner", VolFill).CornerRadius = UDim.new(1, 0)
local VolKnob = Instance.new("TextButton")
VolKnob.Size = UDim2.new(0, 14, 0, 14)
VolKnob.Position = UDim2.new(1, -7, 0.5, -7)
VolKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
VolKnob.Text = ""
VolKnob.Parent = VolTrack
Instance.new("UICorner", VolKnob).CornerRadius = UDim.new(1, 0)

local draggingVol = false
VolKnob.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then draggingVol = true end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then draggingVol = false end
end)
UserInputService.InputChanged:Connect(function(input)
    if draggingVol and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local relX = math.clamp((input.Position.X - VolTrack.AbsolutePosition.X) / VolTrack.AbsoluteSize.X, 0, 1)
        VolKnob.Position = UDim2.new(relX, -7, 0.5, -7)
        VolFill.Size = UDim2.new(relX, 0, 1, 0)
        globalEmoteVolume = relX
        if currentEmoteSound then currentEmoteSound.Volume = globalEmoteVolume end
    end
end)

local DropdownBtn = Instance.new("TextButton")
DropdownBtn.Size = UDim2.new(1, -20, 0, 42)
DropdownBtn.Position = UDim2.new(0, 10, 0, 55)
DropdownBtn.BackgroundColor3 = Color3.fromRGB(40, 30, 55)
DropdownBtn.Text = "Seleccionar Personaje ▼"
DropdownBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
DropdownBtn.Font = Enum.Font.GothamBlack
DropdownBtn.TextSize = 12
DropdownBtn.AutoButtonColor = false
DropdownBtn.Parent = EmotesFrame
Instance.new("UICorner", DropdownBtn).CornerRadius = UDim.new(0, 10)
local DropUIStroke = Instance.new("UIStroke", DropdownBtn)
DropUIStroke.Color = ColorAcento2
DropUIStroke.Thickness = 1

local EmoteListFrame = Instance.new("ScrollingFrame")
EmoteListFrame.Size = UDim2.new(1, -20, 1, -110) 
EmoteListFrame.Position = UDim2.new(0, 10, 0, 110)
EmoteListFrame.BackgroundTransparency = 1
EmoteListFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
EmoteListFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
EmoteListFrame.ScrollBarThickness = 4
EmoteListFrame.ScrollBarImageColor3 = ColorAcento2
EmoteListFrame.BorderSizePixel = 0
EmoteListFrame.Parent = EmotesFrame
local EmoteListLayout = Instance.new("UIListLayout")
EmoteListLayout.SortOrder = Enum.SortOrder.LayoutOrder
EmoteListLayout.Padding = UDim.new(0, 10)
EmoteListLayout.Parent = EmoteListFrame

local DropdownList = Instance.new("ScrollingFrame")
DropdownList.Size = UDim2.new(1, -20, 0, 160)
DropdownList.Position = UDim2.new(0, 10, 0, 102)
DropdownList.BackgroundColor3 = Color3.fromRGB(20, 15, 25)
DropdownList.BorderSizePixel = 0
DropdownList.ZIndex = 10
DropdownList.Visible = false
DropdownList.CanvasSize = UDim2.new(0, 0, 0, 0)
DropdownList.AutomaticCanvasSize = Enum.AutomaticSize.Y
DropdownList.ScrollBarThickness = 4
DropdownList.ScrollBarImageColor3 = ColorAcento1
DropdownList.Parent = EmotesFrame
Instance.new("UICorner", DropdownList).CornerRadius = UDim.new(0, 10)
Instance.new("UIStroke", DropdownList).Color = ColorAcento2
local DropdownLayout = Instance.new("UIListLayout")
DropdownLayout.SortOrder = Enum.SortOrder.Name
DropdownLayout.Parent = DropdownList

local function stopCurrentEmote()
    local char = LocalPlayer.Character
    if activeEmoteData and activeEmoteData.OnLeave and char then activeEmoteData.OnLeave(char) end        
    if currentAnimTrack then     
        currentAnimTrack:Stop()        
        currentAnimTrack:Destroy()         
        currentAnimTrack = nil     
    end        
    if currentEmoteSound then         
        currentEmoteSound:Stop()         
        currentEmoteSound:Destroy()        
        currentEmoteSound = nil     
    end        
    if char and char:FindFirstChild("Humanoid") then         
        local wsGuardado = char.Humanoid:GetAttribute("Frostter_OrigWS")     
        if wsGuardado then             
            char.Humanoid.WalkSpeed = wsGuardado            
            char.Humanoid:SetAttribute("Frostter_OrigWS", nil)        
        end    
    end    
    activeEmoteData = nil    
    QuickEmoteBtn.Text = "🕺"    
    QuickEmoteStroke.Color = ColorAcento1
end

local function playEmote(emote)
    stopCurrentEmote()
    local char = LocalPlayer.Character
    if not char then return end        
    local humanoid = char:FindFirstChild("Humanoid")    
    local rootPart = char:FindFirstChild("HumanoidRootPart")    
    if not humanoid or not rootPart then return end    
    activeEmoteData = emote    
    QuickEmoteBtn.Text = "⏹️"    
    QuickEmoteStroke.Color = Color3.fromRGB(255, 50, 50)        
    if emote.OnUse then task.spawn(function() emote.OnUse(char) end) end    
    
    local animator = humanoid:FindFirstChild("Animator") or Instance.new("Animator", humanoid)    
    local animation = Instance.new("Animation")    
    animation.AnimationId = emote.AnimationId    
    currentAnimTrack = animator:LoadAnimation(animation)    
    currentAnimTrack.Looped = emote.IsLoop    
    currentAnimTrack:Play()    
    
    if emote.MusicId and emote.MusicId ~= "" and emote.MusicId ~= "rbxassetid://0" and emote.MusicId ~= "rbxassetid://00000000000" then        
        currentEmoteSound = Instance.new("Sound")        
        local soundId = emote.MusicId                
        if string.find(soundId, "http") then            
            local cacheName = "MusicCache/WebEmote_" .. emote.Name .. ".mp3"            
            if not isfile(cacheName) then                
                local s, data = pcall(function() return game:HttpGet(soundId) end)                
                if s and data then writefile(cacheName, data) end            
            end            
            if isfile(cacheName) then soundId = getcustomasset(cacheName) else soundId = "" end        
        elseif not string.match(soundId, "^rbxassetid://") then            
            if isfile and getcustomasset and isfile(soundId) then soundId = getcustomasset(soundId) else soundId = "" end  
        end            
        
        if soundId ~= "" then            
            currentEmoteSound.SoundId = soundId            
            currentEmoteSound.Looped = (emote.MusicLooped ~= nil) and emote.MusicLooped or emote.IsLoop            
            currentEmoteSound.Volume = globalEmoteVolume            
            currentEmoteSound.Parent = rootPart            
            currentEmoteSound:Play()    
        end    
    end    
    
    if humanoid:GetAttribute("Frostter_OrigWS") == nil then        
        humanoid:SetAttribute("Frostter_OrigWS", humanoid.WalkSpeed)    
    end    
    humanoid.WalkSpeed = emote.TraversalSpeed or 0
end

local function toggleUltimoEmote()
    if activeEmoteData then stopCurrentEmote() elseif lastSelectedEmote then playEmote(lastSelectedEmote) end
end

UserInputService.InputBegan:Connect(function(input, chat)
    if chat then return end
    if input.KeyCode == Enum.KeyCode.R then toggleUltimoEmote() end
    if input.KeyCode == Enum.KeyCode.X then stopCurrentEmote() end
end)

QuickEmoteBtn.MouseButton1Click:Connect(function()
    TweenService:Create(QuickEmoteBtn, TweenInfo.new(0.1, Enum.EasingStyle.Quint), {Size = UDim2.new(0, 45, 0, 45)}):Play()
    task.wait(0.1)    
    TweenService:Create(QuickEmoteBtn, TweenInfo.new(0.1, Enum.EasingStyle.Quint), {Size = UDim2.new(0, 50, 0, 50)}):Play()
    toggleUltimoEmote()
end)

local function cargarEmotesPersonaje(nombrePersonaje)
    for _, child in ipairs(EmoteListFrame:GetChildren()) do
        if child:IsA("TextButton") or child:IsA("TextLabel") then child:Destroy() end
    end        
    
    local emotes = EmotesDatabase[nombrePersonaje]
    if emotes and #emotes > 0 then
        for _, emoteData in ipairs(emotes) do
            local btn = Instance.new("TextButton")          
            btn.Size = UDim2.new(1, 0, 0, 42)            
            btn.BackgroundColor3 = Color3.fromRGB(30, 25, 40)            
            btn.Text = "  ✨ " .. emoteData.Name            
            btn.TextColor3 = Color3.fromRGB(240, 230, 255)            
            btn.Font = Enum.Font.GothamMedium            
            btn.TextSize = 12            
            btn.TextXAlignment = Enum.TextXAlignment.Left            
            btn.AutoButtonColor = false            
            btn.Parent = EmoteListFrame                    
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)                        
            
            btn.MouseEnter:Connect(function() TweenService:Create(btn, TransicionRapida, {BackgroundColor3 = ColorAcento2, TextColor3 = Color3.new(1,1,1)}):Play() end)            
            btn.MouseLeave:Connect(function() TweenService:Create(btn, TransicionRapida, {BackgroundColor3 = Color3.fromRGB(30, 25, 40), TextColor3 = Color3.fromRGB(240, 230, 255)}):Play() end)                       
            
            btn.MouseButton1Click:Connect(function()                 
                lastSelectedEmote = emoteData                
                SelectedEmoteLabel.Text = emoteData.Name .. " (Presiona R)"                
                QuickEmoteBtn.Text = "▶️"        
                QuickEmoteStroke.Color = Color3.fromRGB(100, 255, 100)                                
                TweenService:Create(btn, TransicionRapida, {Size = UDim2.new(1, -15, 0, 42)}):Play()                
                task.wait(0.1)                
                TweenService:Create(btn, TransicionRapida, {Size = UDim2.new(1, 0, 0, 42)}):Play()          
            end)        
        end    
    else        
        local lbl = Instance.new("TextLabel")        
        lbl.Size = UDim2.new(1, 0, 0, 40)        
        lbl.BackgroundTransparency = 1        
        lbl.Text = "🛠️ Sin Emotes (Aún)"        
        lbl.TextColor3 = Color3.fromRGB(150, 140, 160)        
        lbl.Font = Enum.Font.GothamMedium        
        lbl.TextSize = 12       
        lbl.Parent = EmoteListFrame    
    end
end

for charName, _ in pairs(EmotesDatabase) do
    local btn = Instance.new("TextButton")
    btn.Name = charName
    btn.Size = UDim2.new(1, 0, 0, 36)
    btn.BackgroundColor3 = Color3.fromRGB(20, 15, 25)
    btn.Text = charName
    btn.TextColor3 = Color3.fromRGB(220, 210, 230)
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 12
    btn.ZIndex = 11
    btn.AutoButtonColor = false
    btn.Parent = DropdownList        
    
    btn.MouseEnter:Connect(function() TweenService:Create(btn, TransicionRapida, {BackgroundColor3 = Color3.fromRGB(60, 40, 80)}):Play() end)    
    btn.MouseLeave:Connect(function() TweenService:Create(btn, TransicionRapida, {BackgroundColor3 = Color3.fromRGB(20, 15, 25)}):Play() end)        
    
    btn.MouseButton1Click:Connect(function()        
        DropdownBtn.Text = charName .. " ▼"        
        DropdownList.Visible = false        
        cargarEmotesPersonaje(charName)    
    end)
end

DropdownBtn.MouseButton1Click:Connect(function() DropdownList.Visible = not DropdownList.Visible end)

local CreditsLabel = Instance.new("TextLabel")
CreditsLabel.Size = UDim2.new(1, -40, 0, 25)
CreditsLabel.Position = UDim2.new(0, 20, 1, -30)
CreditsLabel.BackgroundTransparency = 1
CreditsLabel.Text = "hecho por Frostter_uwu"
CreditsLabel.TextColor3 = ColorAcento1
CreditsLabel.TextTransparency = 0.5
CreditsLabel.Font = Enum.Font.GothamMedium
CreditsLabel.TextSize = 11
CreditsLabel.TextXAlignment = Enum.TextXAlignment.Right
CreditsLabel.Parent = MainFrame

local BotonesBloqueados = false
if UserInputService.TouchEnabled then  
    local LockBtn = Instance.new("TextButton")    
    LockBtn.Size = UDim2.new(0, 90, 0, 25)    
    LockBtn.Position = UDim2.new(0, 20, 1, -30)     
    LockBtn.BackgroundColor3 = Color3.fromRGB(40, 30, 50)    
    LockBtn.Text = "🔓 Mover UI"    
    LockBtn.TextColor3 = Color3.new(1, 1, 1)    
    LockBtn.Font = Enum.Font.GothamMedium    
    LockBtn.TextSize = 11    
    LockBtn.Parent = MainFrame    
    Instance.new("UICorner", LockBtn).CornerRadius = UDim.new(0, 6)        
    
    LockBtn.MouseButton1Click:Connect(function()        
        BotonesBloqueados = not BotonesBloqueados       
        if BotonesBloqueados then            
            LockBtn.Text = "🔒 UI Fija"            
            LockBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 80)        
        else            
            LockBtn.Text = "🔓 Mover UI"            
            LockBtn.BackgroundColor3 = Color3.fromRGB(40, 30, 50)        
        end    
    end)
end

local panelAbierto = false
local function alternarPanel(forzarEstado)    
    if forzarEstado ~= nil then panelAbierto = forzarEstado else panelAbierto = not panelAbierto end    
    if panelAbierto then         
        MainFrame.Visible = true         
        local targetScale = obtenerEscalaResponsiva()        
        TweenService:Create(UIScale, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = targetScale}):Play()    
    else         
        local tweenCierre = TweenService:Create(UIScale, TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {Scale = 0})        
        tweenCierre:Play()        
        tweenCierre.Completed:Connect(function() if not panelAbierto then MainFrame.Visible = false end end) 
    end
end
alternarPanel(true)
CloseButton.MouseButton1Click:Connect(function() alternarPanel(false) end)
UserInputService.InputBegan:Connect(function(input, chat)    
    if chat then return end    
    if input.KeyCode == Enum.KeyCode.K then alternarPanel() end 
end)

local FloatingMenuBtn = Instance.new("TextButton")
FloatingMenuBtn.Size = UDim2.new(0, 45, 0, 45)
FloatingMenuBtn.Position = UDim2.new(0, 20, 1, -80)
FloatingMenuBtn.BackgroundColor3 = Color3.fromRGB(20, 15, 30)
FloatingMenuBtn.Text = "⚙️"
FloatingMenuBtn.TextSize = 20
FloatingMenuBtn.Visible = UserInputService.TouchEnabled
FloatingMenuBtn.Parent = ScreenGui
Instance.new("UICorner", FloatingMenuBtn).CornerRadius = UDim.new(1, 0)
Instance.new("UIStroke", FloatingMenuBtn).Color = ColorAcento1

local arrastreGlobal = {activo = false, gui = nil, inicioUI = nil, inicioRaton = nil, escala = 1}
local floatTouchStartPos = nil

local function iniciarArrastre(gui, input, usarEscala)    
    if BotonesBloqueados then return end    
    arrastreGlobal.activo = true    
    arrastreGlobal.gui = gui    
    arrastreGlobal.inicioUI = gui.Position    
    arrastreGlobal.inicioRaton = input.Position    
    arrastreGlobal.escala = usarEscala and ((UIScale.Scale > 0) and UIScale.Scale or 1) or 1
end

UserInputService.InputEnded:Connect(function(input)    
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then        
        arrastreGlobal.activo = false        
        arrastreGlobal.gui = nil    
    end
end)

RunService.Heartbeat:Connect(function()    
    if not arrastreGlobal.activo or not arrastreGlobal.gui or BotonesBloqueados then return end    
    local posActual = UserInputService:GetMouseLocation()    
    local deltaX = posActual.X - arrastreGlobal.inicioRaton.X    
    local deltaY = (posActual.Y - 36) - arrastreGlobal.inicioRaton.Y         
    arrastreGlobal.gui.Position = UDim2.new(        
        arrastreGlobal.inicioUI.X.Scale, arrastreGlobal.inicioUI.X.Offset + (deltaX / arrastreGlobal.escala),         
        arrastreGlobal.inicioUI.Y.Scale, arrastreGlobal.inicioUI.Y.Offset + (deltaY / arrastreGlobal.escala)    
    )
end)

QuickEmoteBtn.InputBegan:Connect(function(input)    
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then        
        iniciarArrastre(QuickEmoteBtn, input, false)    
    end
end)
FloatingMenuBtn.InputBegan:Connect(function(input)    
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then        
        floatTouchStartPos = input.Position    
        iniciarArrastre(FloatingMenuBtn, input, false)    
    end
end)
FloatingMenuBtn.InputEnded:Connect(function(input)    
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then        
        if floatTouchStartPos and (input.Position - floatTouchStartPos).Magnitude < 5 then            
            alternarPanel()        
        end        
        floatTouchStartPos = nil    
    end
end)
MainFrame.InputBegan:Connect(function(input)    
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then        
        iniciarArrastre(MainFrame, input, true)    
    end
end)

local function crearCategoria(parent, titulo, colorSeccion)    
    local HeaderFrame = Instance.new("Frame")    
    HeaderFrame.Size = UDim2.new(1, 0, 0, 24)    
    HeaderFrame.BackgroundTransparency = 1    
    HeaderFrame.Parent = parent    
    local LineaIzquierda = Instance.new("Frame")    
    LineaIzquierda.Size = UDim2.new(0, 4, 1, 0)    
    LineaIzquierda.BackgroundColor3 = colorSeccion    
    LineaIzquierda.BorderSizePixel = 0    
    LineaIzquierda.Parent = HeaderFrame    
    Instance.new("UICorner", LineaIzquierda).CornerRadius = UDim.new(1, 0)    
    local Header = Instance.new("TextLabel")    
    Header.Size = UDim2.new(1, -15, 1, 0)    
    Header.Position = UDim2.new(0, 15, 0, 0)   
    Header.BackgroundTransparency = 1    
    Header.Text = string.upper(titulo)    
    Header.TextColor3 = colorSeccion    
    Header.Font = Enum.Font.GothamBlack    
    Header.TextSize = 12    
    Header.TextXAlignment = Enum.TextXAlignment.Left    
    Header.Parent = HeaderFrame
end

local function crearToggle(parent, texto, estadoInicial, colorCheck, callback)    
    local Container = Instance.new("Frame")    
    Container.Size = UDim2.new(1, 0, 0, 45)    
    Container.BackgroundColor3 = Color3.fromRGB(20, 15, 25)    
    Container.Parent = parent    
    Instance.new("UICorner", Container).CornerRadius = UDim.new(0, 10)    
    local Label = Instance.new("TextLabel")    
    Label.Size = UDim2.new(0.7, 0, 1, 0) 
    Label.Position = UDim2.new(0, 15, 0, 0)    
    Label.BackgroundTransparency = 1    
    Label.Text = texto    
    Label.TextColor3 = Color3.fromRGB(235, 230, 240)    
    Label.Font = Enum.Font.GothamMedium    
    Label.TextSize = 11    
    Label.TextXAlignment = Enum.TextXAlignment.Left    
    Label.Parent = Container    
    local Track = Instance.new("TextButton")    
    Track.Size = UDim2.new(0, 44, 0, 24)    
    Track.Position = UDim2.new(1, -55, 0.5, -12)    
    Track.BackgroundColor3 = estadoInicial and colorCheck or Color3.fromRGB(40, 35, 50)    
    Track.Text = ""    
    Track.AutoButtonColor = false    
    Track.Parent = Container    
    Instance.new("UICorner", Track).CornerRadius = UDim.new(1, 0)    
    local Ball = Instance.new("Frame")    
    Ball.Size = UDim2.new(0, 18, 0, 18)    
    Ball.Position = estadoInicial and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)    
    Ball.BackgroundColor3 = Color3.fromRGB(255, 255, 255)    
    Ball.Parent = Track    
    Instance.new("UICorner", Ball).CornerRadius = UDim.new(1, 0)    
    
    local estado = estadoInicial    
    local function actualizarVisuales(nuevoEstado)        
        estado = nuevoEstado        
        local targetPos = estado and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)        
        local targetColor = estado and colorCheck or Color3.fromRGB(40, 35, 50)        
        TweenService:Create(Ball, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = targetPos}):Play()        
        TweenService:Create(Track, TransicionRapida, {BackgroundColor3 = targetColor}):Play()    
    end    
    
    Track.MouseButton1Click:Connect(function()        
        estado = not estado        
        actualizarVisuales(estado)        
        callback(estado)    
    end)     
    
    Container.MouseEnter:Connect(function() TweenService:Create(Container, TransicionRapida, {BackgroundColor3 = Color3.fromRGB(30, 25, 40)}):Play() end)    
    Container.MouseLeave:Connect(function() TweenService:Create(Container, TransicionRapida, {BackgroundColor3 = Color3.fromRGB(20, 15, 25)}):Play() end)    
    return {        
        Update = function(nuevoEstado, ignorarCallback)            
            if estado == nuevoEstado then return end            
            actualizarVisuales(nuevoEstado)            
            if not ignorarCallback then callback(nuevoEstado) end        
        end    
    }
end

local function crearSlider(parent, texto, minVal, maxVal, defaultVal, color, callback)    
    local Container = Instance.new("Frame")    
    Container.Size = UDim2.new(1, 0, 0, 60)    
    Container.BackgroundColor3 = Color3.fromRGB(20, 15, 25)    
    Container.Parent = parent    
    Instance.new("UICorner", Container).CornerRadius = UDim.new(0, 10)    
    local Label = Instance.new("TextLabel")    
    Label.Size = UDim2.new(1, -30, 0, 20)    
    Label.Position = UDim2.new(0, 15, 0, 10)    
    Label.BackgroundTransparency = 1    
    Label.Text = texto .. ": " .. tostring(defaultVal)    
    Label.TextColor3 = Color3.fromRGB(235, 230, 240)    
    Label.Font = Enum.Font.GothamMedium    
    Label.TextSize = 11    
    Label.TextXAlignment = Enum.TextXAlignment.Left    
    Label.Parent = Container    
    local STrack = Instance.new("Frame")    
    STrack.Size = UDim2.new(1, -30, 0, 6)    
    STrack.Position = UDim2.new(0, 15, 0, 40)    
    STrack.BackgroundColor3 = Color3.fromRGB(40, 35, 50)    
    STrack.Parent = Container    
    Instance.new("UICorner", STrack).CornerRadius = UDim.new(1, 0)    
    local startRel = (defaultVal - minVal) / (maxVal - minVal)    
    local SFill = Instance.new("Frame")    
    SFill.Size = UDim2.new(startRel, 0, 1, 0)    
    SFill.BackgroundColor3 = color    
    SFill.Parent = STrack    
    Instance.new("UICorner", SFill).CornerRadius = UDim.new(1, 0)    
    local SKnob = Instance.new("TextButton")    
    SKnob.Size = UDim2.new(0, 16, 0, 16)    
    SKnob.Position = UDim2.new(startRel, -8, 0.5, -8)    
    SKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)    
    SKnob.Text = ""    
    SKnob.Parent = STrack    
    Instance.new("UICorner", SKnob).CornerRadius = UDim.new(1, 0)    
    
    local draggingS = false    
    SKnob.InputBegan:Connect(function(input)        
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then draggingS = true end  
    end)    
    UserInputService.InputEnded:Connect(function(input)        
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then draggingS = false end    
    end)    
    UserInputService.InputChanged:Connect(function(input)        
        if draggingS and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then            
            local relX = math.clamp((input.Position.X - STrack.AbsolutePosition.X) / STrack.AbsoluteSize.X, 0, 1)            
            SKnob.Position = UDim2.new(relX, -8, 0.5, -8)          
            SFill.Size = UDim2.new(relX, 0, 1, 0)            
            local currentVal = math.floor(minVal + (maxVal - minVal) * relX)            
            Label.Text = texto .. ": " .. tostring(currentVal)            
            callback(currentVal)        
        end    
    end)
end

local function crearBotonAccion(parent, texto, colorBtn, callback)    
    local btn = Instance.new("TextButton")    
    btn.Size = UDim2.new(1, 0, 0, 35)    
    btn.BackgroundColor3 = colorBtn  
    btn.Text = texto    
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)    
    btn.Font = Enum.Font.GothamBold    
    btn.TextSize = 12    
    btn.AutoButtonColor = false    
    btn.Parent = parent    
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)        
    
    local originalColor = colorBtn    
    local hoverColor = Color3.new(originalColor.R * 1.2, originalColor.G * 1.2, originalColor.B * 1.2)    
    btn.MouseEnter:Connect(function() TweenService:Create(btn, TransicionRapida, {BackgroundColor3 = hoverColor}):Play() end)    
    btn.MouseLeave:Connect(function() TweenService:Create(btn, TransicionRapida, {BackgroundColor3 = originalColor}):Play() end)    
    btn.MouseButton1Click:Connect(callback)      
    return btn
end

local colorPaletaFondo = Color3.fromRGB(255, 100, 200)
crearCategoria(CustomFrame, "Estilo del Panel", colorPaletaFondo)
crearToggle(CustomFrame, "Panel Transparente", false, colorPaletaFondo, function(valor)    
    if valor then        
        TweenService:Create(MainFrame, TransicionSuave, {BackgroundTransparency = 0.5}):Play()        
        UIGradient.Enabled = false    
    else        
        TweenService:Create(MainFrame, TransicionSuave, {BackgroundTransparency = 0}):Play()        
        UIGradient.Enabled = true    
    end
end)
crearBotonAccion(CustomFrame, "Restablecer Fondo Original", Color3.fromRGB(40, 30, 50), function()    
    UIGradient.Enabled = true    
    UIGradient.Color = UIGradientColorDefault
end)

local function crearGridColores(parent, titulo, callback)  
    crearCategoria(parent, titulo, Color3.fromRGB(200, 200, 200))    
    local ColorContainer = Instance.new("Frame", parent)    
    ColorContainer.Size = UDim2.new(1, 0, 0, 100)    
    ColorContainer.BackgroundTransparency = 1        
    local Grid = Instance.new("UIGridLayout", ColorContainer)    
    Grid.CellSize = UDim2.new(0, 35, 0, 35)    
    Grid.CellPadding = UDim2.new(0, 8, 0, 8)    
    Grid.SortOrder = Enum.SortOrder.LayoutOrder    
    local paleta20 = {        
        Color3.fromRGB(200, 80, 80), Color3.fromRGB(200, 130, 80), Color3.fromRGB(200, 180, 80), Color3.fromRGB(180, 200, 80),        
        Color3.fromRGB(130, 200, 80), Color3.fromRGB(80, 200, 80), Color3.fromRGB(80, 200, 130), Color3.fromRGB(80, 200, 180),        
        Color3.fromRGB(80, 180, 200), Color3.fromRGB(80, 130, 200), Color3.fromRGB(80, 80, 200), Color3.fromRGB(130, 80, 200),        
        Color3.fromRGB(180, 80, 200), Color3.fromRGB(200, 80, 180), Color3.fromRGB(200, 80, 130), Color3.fromRGB(150, 150, 150),        
        Color3.fromRGB(90, 90, 90), Color3.fromRGB(140, 100, 80), Color3.fromRGB(130, 170, 130), Color3.fromRGB(130, 130, 170)    
    }    
    for _, col in ipairs(paleta20) do        
        local cBtn = Instance.new("TextButton", ColorContainer)        
        cBtn.BackgroundColor3 = col        
        cBtn.Text = ""        
        Instance.new("UICorner", cBtn).CornerRadius = UDim.new(0, 6)        
        cBtn.MouseButton1Click:Connect(function() callback(col) end)    
    end
end

crearGridColores(CustomFrame, "Seleccionar Color de Fondo", function(col)    
    UIGradient.Enabled = false    
    MainFrame.BackgroundColor3 = col
end)
crearGridColores(CustomFrame, "Seleccionar Color de Contorno", function(col)    
    ArcoirisActivo = false    
    UIStroke.Color = col
end)
crearToggle(CustomFrame, "Contorno Arcoíris Dinámico", true, Color3.fromRGB(100, 200, 255), function(valor) ArcoirisActivo = valor end)

local colorVioleta = Color3.fromRGB(180, 100, 255)
local colorRojo = Color3.fromRGB(255, 80, 100)
local colorVerde = ColorAcento1
local colorSkins = Color3.fromRGB(255, 160, 80)
local colorCian = Color3.fromRGB(100, 240, 255)

local function manejarAtmosfera(valor)    
    Atmosfera_Quitada = valor    
    if Atmosfera_Quitada then        
        for _, obj in ipairs(Lighting:GetChildren()) do            
            if obj:IsA("Atmosphere") or obj:IsA("PostEffect") or obj:IsA("Sky") or obj:IsA("Clouds") then obj.Parent = atmosphereStorage end        
        end    
    else        
        for _, obj in ipairs(atmosphereStorage:GetChildren()) do obj.Parent = Lighting end    
    end
end
Lighting.ChildAdded:Connect(function(child)    
    if Atmosfera_Quitada and (child:IsA("Atmosphere") or child:IsA("PostEffect") or child:IsA("Sky") or child:IsA("Clouds")) then task.defer(function() child.Parent = atmosphereStorage end) end
end)

local function manejarCambioLMSIndividual(personaje, valor)    
    LMS_Estados[personaje] = valor    
    local soloThemeFolder = ReplicatedStorage:WaitForChild("ClientAssets"):WaitForChild("Sounds"):WaitForChild("mus"):WaitForChild("Game"):WaitForChild("Round"):WaitForChild("SoloTheme")    
    local objetoSonido = soloThemeFolder:FindFirstChild(personaje)    
    if objetoSonido and objetoSonido:IsA("Sound") then        
        if valor then            
            local ruta = "MusicCache/" .. personaje .. ".mp3"            
            if isfile(ruta) then objetoSonido.SoundId = getcustomasset(ruta) end        
        else   
            objetoSonido.SoundId = lmsOriginalIds[personaje] or ""            
            objetoSonido:Stop()        
        end    
    end
end

local silentGroupGlobal = nil
local function manejarChases(valor)    
    Chase_Activo = valor    
    for originalSound, data in pairs(chaseObjects) do        
        if originalSound and originalSound.Parent and data.customSound and data.customSound.Parent then            
            if Chase_Activo then             
                originalSound.SoundGroup = silentGroupGlobal                
                if originalSound.Playing then data.customSound.Playing = true end            
            else                
                originalSound.SoundGroup = data.originalGroup                
                data.customSound:Stop()            
            end        
        end    
    end
end

-- ==========================================
-- SISTEMA DE ILUMINACIÓN DEFINITIVA
-- ==========================================
local MaterialService = game:GetService("MaterialService")
local Terrain = workspace:FindFirstChildOfClass("Terrain")
local efectosActivos = false
local instanciasEsteticas = {}

local function asegurarEfectosHD()    
    if not instanciasEsteticas.atmosfera or instanciasEsteticas.atmosfera.Parent ~= Lighting then        
        local atmos = Lighting:FindFirstChildOfClass("Atmosphere") or Instance.new("Atmosphere")        
        atmos.Parent = Lighting        
        instanciasEsteticas.atmosfera = atmos    
    end    
    instanciasEsteticas.atmosfera.Density = 0.28    
    instanciasEsteticas.atmosfera.Offset = 0.2    
    instanciasEsteticas.atmosfera.Color = Color3.fromRGB(205, 175, 150)     
    instanciasEsteticas.atmosfera.Decay = Color3.fromRGB(150, 110, 90)     
    instanciasEsteticas.atmosfera.Glare = 0.15     
    instanciasEsteticas.atmosfera.Haze = 1.5    
    if not instanciasEsteticas.sun or instanciasEsteticas.sun.Parent ~= Lighting then        
        local sun = Instance.new("SunRaysEffect")        
        sun.Parent = Lighting        
        instanciasEsteticas.sun = sun    
    end    
    instanciasEsteticas.sun.Intensity = 0.22     
    instanciasEsteticas.sun.Spread = 0.85     
    if not instanciasEsteticas.cc or instanciasEsteticas.cc.Parent ~= Lighting then        
        local cc = Instance.new("ColorCorrectionEffect")        
        cc.Parent = Lighting        
        instanciasEsteticas.cc = cc    
    end    
    instanciasEsteticas.cc.Brightness = 0.02    
    instanciasEsteticas.cc.Contrast = 0.18     
    instanciasEsteticas.cc.Saturation = 0.45     
    instanciasEsteticas.cc.TintColor = Color3.fromRGB(255, 240, 225)     
    if not instanciasEsteticas.bloom or instanciasEsteticas.bloom.Parent ~= Lighting then        
        local bloom = Instance.new("BloomEffect")        
        bloom.Parent = Lighting        
        instanciasEsteticas.bloom = bloom    
    end    
    instanciasEsteticas.bloom.Intensity = 0.12    
    instanciasEsteticas.bloom.Size = 18    
    instanciasEsteticas.bloom.Threshold = 2.4     
    if not instanciasEsteticas.dof or instanciasEsteticas.dof.Parent ~= Lighting then        
        local dof = Instance.new("DepthOfFieldEffect")        
        dof.Parent = Lighting        
        instanciasEsteticas.dof = dof    
    end    
    instanciasEsteticas.dof.FarIntensity = 0.06    
    instanciasEsteticas.dof.FocusDistance = 45    
    instanciasEsteticas.dof.InFocusRadius = 60    
    instanciasEsteticas.dof.NearIntensity = 0
end

local function forzarIluminacionHD()    
    Lighting.GlobalShadows = true    
    Lighting.ShadowSoftness = 0.12     
    Lighting.Ambient = Color3.fromRGB(65, 55, 50)     
    Lighting.OutdoorAmbient = Color3.fromRGB(130, 115, 105)     
    Lighting.ColorShift_Top = Color3.fromRGB(255, 220, 180)     
    Lighting.ColorShift_Bottom = Color3.fromRGB(150, 130, 110)    
    Lighting.EnvironmentDiffuseScale = 1    
    Lighting.EnvironmentSpecularScale = 1     
    pcall(function() MaterialService.Use2022Materials = true end)        
    if Terrain then        
        pcall(function()            
            Terrain.WaterColor = Color3.fromRGB(20, 90, 100)            
            Terrain.WaterReflectance = 0.95  
            Terrain.WaterTransparency = 0.95             
            Terrain.WaterWaveSize = 0.05             
            Terrain.WaterWaveSpeed = 6        
        end)    
    end
end

local function manejarCalidadEstetica(valor)    
    efectosActivos = valor    
    if valor then        
        task.spawn(function()            
            while efectosActivos do         
                asegurarEfectosHD()                
                forzarIluminacionHD()                
                task.wait(2)            
            end        
        end)    
    else        
        for _, efecto in pairs(instanciasEsteticas) do            
            if efecto and efecto.Parent then efecto:Destroy() end      
        end        
        instanciasEsteticas = {}    
    end
end

-- ============================================================================
-- SELECCIÓN DE PERSONAJE AUTOMÁTICA (AUTO PICK)
-- ============================================================================
local colorAutoSelect = Color3.fromRGB(200, 140, 0)
crearCategoria(SettingsFrame, "Selección de Personaje Automática", colorAutoSelect)
local VoteRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Voted")
local listaAutoPick = {"Sonic", "Amy", "Eggman", "Cream", "Tails", "Knuckles", "MetalSonic", "Blaze", "Silver"}
local personajeAutoPick = listaAutoPick[1]
local autoPickActivo = false

local DropdownContainer = Instance.new("Frame")
DropdownContainer.Name = "DropdownContainer"
DropdownContainer.Size = UDim2.new(1, 0, 0, 35)
DropdownContainer.BackgroundTransparency = 1
DropdownContainer.Parent = SettingsFrame
local AutoDropLayout = Instance.new("UIListLayout")
AutoDropLayout.SortOrder = Enum.SortOrder.LayoutOrder
AutoDropLayout.Padding = UDim.new(0, 5)
AutoDropLayout.Parent = DropdownContainer

local BtnPrincipal = Instance.new("TextButton")
BtnPrincipal.Size = UDim2.new(1, 0, 0, 35)
BtnPrincipal.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
BtnPrincipal.TextColor3 = colorAutoSelect
BtnPrincipal.Font = Enum.Font.GothamBold
BtnPrincipal.TextSize = 14
BtnPrincipal.Text = "Personaje: " .. string.upper(personajeAutoPick) .. " ▼"
BtnPrincipal.Parent = DropdownContainer
local UICornerBtn = Instance.new("UICorner")
UICornerBtn.CornerRadius = UDim.new(0, 6)
UICornerBtn.Parent = BtnPrincipal

local ListaFrame = Instance.new("Frame")
ListaFrame.Size = UDim2.new(1, 0, 0, 0)
ListaFrame.AutomaticSize = Enum.AutomaticSize.Y
ListaFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
ListaFrame.Visible = false
ListaFrame.ClipsDescendants = true
ListaFrame.Parent = DropdownContainer
local UICornerLista = Instance.new("UICorner")
UICornerLista.CornerRadius = UDim.new(0, 6)
UICornerLista.Parent = ListaFrame
local ListaLayout = Instance.new("UIListLayout")
ListaLayout.SortOrder = Enum.SortOrder.LayoutOrder
ListaLayout.Padding = UDim.new(0, 2)
ListaLayout.Parent = ListaFrame
local ListaPadding = Instance.new("UIPadding")
ListaPadding.PaddingTop = UDim.new(0, 5)
ListaPadding.PaddingBottom = UDim.new(0, 5)
ListaPadding.Parent = ListaFrame

local isDropdownOpen = false
BtnPrincipal.MouseButton1Click:Connect(function()    
    isDropdownOpen = not isDropdownOpen    
    ListaFrame.Visible = isDropdownOpen    
    BtnPrincipal.Text = "Personaje: " .. string.upper(personajeAutoPick) .. (isDropdownOpen and " ▲" or " ▼")        
    if isDropdownOpen then        
        DropdownContainer.AutomaticSize = Enum.AutomaticSize.Y    
    else        
        DropdownContainer.AutomaticSize = Enum.AutomaticSize.None        
        DropdownContainer.Size = UDim2.new(1, 0, 0, 35)    
    end
end)

for _, personaje in ipairs(listaAutoPick) do   
    local OpcionBtn = Instance.new("TextButton")    
    OpcionBtn.Size = UDim2.new(1, 0, 0, 30)    
    OpcionBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)    
    OpcionBtn.BackgroundTransparency = 1    
    OpcionBtn.TextColor3 = Color3.fromRGB(210, 210, 210)    
    OpcionBtn.Font = Enum.Font.GothamSemibold    
    OpcionBtn.TextSize = 13    
    OpcionBtn.Text = string.upper(personaje)    
    OpcionBtn.Parent = ListaFrame    
    OpcionBtn.MouseEnter:Connect(function() OpcionBtn.BackgroundTransparency = 0.5 end)    
    OpcionBtn.MouseLeave:Connect(function() OpcionBtn.BackgroundTransparency = 1 end)    
    OpcionBtn.MouseButton1Click:Connect(function()        
        personajeAutoPick = personaje        
        isDropdownOpen = false 
        ListaFrame.Visible = false        
        BtnPrincipal.Text = "Personaje: " .. string.upper(personajeAutoPick) .. " ▼"        
        DropdownContainer.AutomaticSize = Enum.AutomaticSize.None        
        DropdownContainer.Size = UDim2.new(1, 0, 0, 35)    
    end)
end

crearToggle(SettingsFrame, "Activar Auto Selección", false, colorAutoSelect, function(valor)    
    autoPickActivo = valor
end)

task.spawn(function()    
    local playerGui = LocalPlayer:WaitForChild("PlayerGui")    
    while true do        
        task.wait(0.05)                
        if autoPickActivo and personajeAutoPick then            
            local gameUI = playerGui:FindFirstChild("GameUI")            
            local charSelect = gameUI and gameUI:FindFirstChild("CharSelect")                        
            if charSelect and charSelect.Visible == true then                
                pcall(function() VoteRemote:FireServer(personajeAutoPick) end)     
                repeat task.wait(0.5)                    
                    local checkUI = playerGui:FindFirstChild("GameUI")                    
                    charSelect = checkUI and checkUI:FindFirstChild("CharSelect")                
                until not charSelect or charSelect.Visible == false or not autoPickActivo            
            end        
        end    
    end
end)

crearCategoria(SettingsFrame, "Visual", colorVioleta)
crearToggle(SettingsFrame, "Quitar Atmósfera (Anti-Lag)", false, colorVioleta, manejarAtmosfera)
crearToggle(SettingsFrame, "Modo Patata (+FPS)", false, colorVioleta, function(valor)    
    if valor then pcall(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/imnotsense/LMS-Y-CHASES/main/modopatata.lua"))() end) end
end)
crearToggle(SettingsFrame, "Mejor Calidad Estética (Cinemática)", false, colorVioleta, manejarCalidadEstetica)

crearCategoria(SettingsFrame, "Exe's", colorRojo)
crearToggle(SettingsFrame, "Killers: Chases Custom Habilitados", true, colorRojo, manejarChases)
crearToggle(SettingsFrame, "Fleetway LMS (Baja Vida)", false, colorRojo, function(valor) Fleetway_LMS_Activo = valor end)

crearCategoria(SettingsFrame, "Supervivientes", colorVerde)
crearToggle(SettingsFrame, "ACTIVAR TODOS LOS LMS", true, colorVerde, function(valor)    
    for personaje, uiToggle in pairs(togglesLMSUI) do uiToggle.Update(valor, false) end
end)

local listaPersonajes = {"SonicSolo", "TailsSolo", "KnucklesSolo", "AmySolo", "CreamSolo", "ShadowSolo", "SilverSolo", "BlazeSolo", "EggmanSolo", "MetalSonicSolo"}
for _, personaje in ipairs(listaPersonajes) do    
    LMS_Estados[personaje] = true    
    togglesLMSUI[personaje] = crearToggle(SettingsFrame, "Tema: " .. string.gsub(personaje, "Solo", ""), true, colorVerde, function(valor)        
        manejarCambioLMSIndividual(personaje, valor)    
    end)
end

crearCategoria(SettingsFrame, "Skins (no activar varias del mismo personaje)", colorSkins)
local function manejarSkin(valor, url)    
    if valor then         
        pcall(function() loadstring(game:HttpGet(url))() end)     
    else         
        local char = LocalPlayer.Character        
        if char and char:FindFirstChild("Humanoid") then            
            char.Humanoid.Health = 0        
        end 
    end
end

crearToggle(SettingsFrame, "negagen fleetway", false, colorSkins, function(v) manejarSkin(v, "https://raw.githubusercontent.com/imnotsense/LMS-Y-CHASES/main/negagenfleetway.lua") end)
crearToggle(SettingsFrame, "Fleetway-SuperScourge", false, colorSkins, function(v) manejarSkin(v, "https://raw.githubusercontent.com/imnotsense/LMS-Y-CHASES/main/superscourge.lua") end)
crearToggle(SettingsFrame, "Cream.exe (TailsDoll)", false, colorSkins, function(v) manejarSkin(v, "https://raw.githubusercontent.com/thaLILNIKKI/Cream.LMS-Outcome-Memories/HEAD/doll.lua") end)
crearToggle(SettingsFrame, "Glorbwire (TailsDoll)", false, colorSkins, function(v) manejarSkin(v, "https://raw.githubusercontent.com/imnotsense/LMS-Y-CHASES/main/glorbwire.lua") end)
crearToggle(SettingsFrame, "TD Kolossos", false, colorSkins, function(v) manejarSkin(v, "https://raw.githubusercontent.com/imnotsense/LMS-Y-CHASES/main/TDKolossos.lua") end)
crearToggle(SettingsFrame, "Neru Tails", false, colorSkins, function(v) manejarSkin(v, "https://raw.githubusercontent.com/imnotsense/LMS-Y-CHASES/main/tailsneru.lua") end)
crearToggle(SettingsFrame, "Tails-Megaman", false, colorSkins, function(v) manejarSkin(v, "https://raw.githubusercontent.com/imnotsense/LMS-Y-CHASES/main/Tailsmega.lua") end)
crearToggle(SettingsFrame, "Alan (tails)", false, colorSkins, function(v) manejarSkin(v, "https://raw.githubusercontent.com/imnotsense/LMS-Y-CHASES/main/alantails.lua") end)
crearToggle(SettingsFrame, "Sonic Miku", false, colorSkins, function(v) manejarSkin(v, "https://raw.githubusercontent.com/imnotsense/LMS-Y-CHASES/main/sonicmiku.lua") end)
crearToggle(SettingsFrame, "Sonic-Scourge", false, colorSkins, function(v) manejarSkin(v, "https://raw.githubusercontent.com/imnotsense/LMS-Y-CHASES/main/scourgenormal") end)
crearToggle(SettingsFrame, "Silver-LinternaVerde", false, colorSkins, function(v) manejarSkin(v, "https://raw.githubusercontent.com/imnotsense/LMS-Y-CHASES/main/silverLinVerde.lua") end)
crearToggle(SettingsFrame, "BurningBlaze", false, colorSkins, function(v) manejarSkin(v, "https://raw.githubusercontent.com/imnotsense/LMS-Y-CHASES/main/BurningBlaze.lua") end)
crearToggle(SettingsFrame, "Jesse (knuckles)", false, colorSkins, function(v) manejarSkin(v, "https://raw.githubusercontent.com/imnotsense/LMS-Y-CHASES/main/jesseknuckles.lua") end)

crearCategoria(SettingsFrame, "Misc", colorCian)
local function aplicarVolumen(obj)    
    if obj:IsA("Sound") then        
        local n = string.lower(obj.Name)        
        if string.find(n, "voice") or string.find(n, "laugh") or string.find(n, "scream") or string.find(n, "taunt") then            
            obj.Volume = Voices_Volume_Multiplier        
        end    
    end
end
crearToggle(SettingsFrame, "Musica de lobby Y Mapas", false, colorCian, function(valor)     
    if valor then pcall(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/imnotsense/LMS-Y-CHASES/main/ambiente/musica.lua"))() end) end 
end)
crearToggle(SettingsFrame, "Voces Personajes (no activar mas de una vez)", false, colorCian, function(valor)     
    if valor then pcall(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/imnotsense/LMS-Y-CHASES/main/VocesPersonajes.lua"))() end) end 
end)
crearToggle(SettingsFrame, "Voz amy", false, colorCian, function(valor)     
    if valor then pcall(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/imnotsense/LMS-Y-CHASES/main/amy.lua"))() end) end 
end)

local function getActiveCharacterModel()    
    local char = LocalPlayer.Character    
    local customFolder = workspace:FindFirstChild("Players")    
    local customModel = customFolder and customFolder:FindFirstChild(LocalPlayer.Name)    
    return customModel or char
end

if EsDesarrollador then    
    local colorDev = Color3.fromRGB(255, 80, 120)    
    crearCategoria(DevFrame, "Teletransporte de Jugadores", colorDev)        
    
    local TPStatusLabel = Instance.new("TextLabel", DevFrame)    
    TPStatusLabel.Size = UDim2.new(1, 0, 0, 20)    
    TPStatusLabel.BackgroundTransparency = 1   
    TPStatusLabel.Text = "Seleccionado: NINGUNO"    
    TPStatusLabel.TextColor3 = Color3.new(1,1,1)    
    TPStatusLabel.Font = Enum.Font.GothamBold    
    TPStatusLabel.TextSize = 12    
    local tpCurrentTarget = nil    
    local btnIrTP = crearBotonAccion(DevFrame, "Ir a: NINGUNO", colorDev, function()        
        if tpCurrentTarget then            
            local targetPlayer = Players:FindFirstChild(tpCurrentTarget)            
            if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then                
                local myModel = getActiveCharacterModel()                
                if myModel and myModel:FindFirstChild("HumanoidRootPart") then                    
                    myModel.HumanoidRootPart.CFrame = targetPlayer.Character.HumanoidRootPart.CFrame                
                end            
            end         
        end    
    end)    
    
    local PlayerListContainer = Instance.new("Frame", DevFrame)    
    PlayerListContainer.Size = UDim2.new(1, 0, 0, 120)    
    PlayerListContainer.BackgroundColor3 = Color3.fromRGB(20, 15, 25)    
    Instance.new("UICorner", PlayerListContainer).CornerRadius = UDim.new(0, 8)    
    
    local PlayerScroll = Instance.new("ScrollingFrame", PlayerListContainer)    
    PlayerScroll.Size = UDim2.new(1, -10, 1, -10)    
    PlayerScroll.Position = UDim2.new(0, 5, 0, 5)    
    PlayerScroll.BackgroundTransparency = 1    
    PlayerScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y    
    PlayerScroll.CanvasSize = UDim2.new(0,0,0,0)    
    PlayerScroll.ScrollBarThickness = 4    
    PlayerScroll.BorderSizePixel = 0    
    local pLayout = Instance.new("UIListLayout", PlayerScroll)    
    pLayout.Padding = UDim.new(0, 5)    
    
    local function refrescarListaTP()    
        for _, child in pairs(PlayerScroll:GetChildren()) do if child:IsA("TextButton") then child:Destroy() end end        
        for _, p in pairs(Players:GetPlayers()) do            
            if p ~= LocalPlayer then                
                local btn = Instance.new("TextButton", PlayerScroll)                
                btn.Size = UDim2.new(1, 0, 0, 25)               
                btn.BackgroundColor3 = Color3.fromRGB(30, 25, 40)                
                btn.Text = p.Name                
                btn.TextColor3 = Color3.new(1,1,1)                
                btn.Font = Enum.Font.GothamMedium                
                btn.TextSize = 11                
                btn.AutoButtonColor = false     
                Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)                         
                
                btn.MouseEnter:Connect(function() btn.BackgroundColor3 = Color3.fromRGB(50, 40, 60) end)                
                btn.MouseLeave:Connect(function() btn.BackgroundColor3 = Color3.fromRGB(30, 25, 40) end)                                
                btn.MouseButton1Click:Connect(function()                    
                    tpCurrentTarget = p.Name                    
                    TPStatusLabel.Text = "Seleccionado: " .. tpCurrentTarget                    
                    btnIrTP.Text = "Ir a: " .. tpCurrentTarget                
                end)           
            end        
        end    
    end    
    crearBotonAccion(DevFrame, "Refrescar Lista", Color3.fromRGB(50, 150, 255), refrescarListaTP)    
    refrescarListaTP()    
    
    crearCategoria(DevFrame, "Herramientas de Desarrollador", colorDev)    
    
    local noJumpCooldownActivo = false    
    crearToggle(DevFrame, "No Jump Cooldown", false, colorDev, function(valor)        
        noJumpCooldownActivo = valor    
    end)
    
    -- Evento nativo de salto optimizado y aplicado a los Custom Models (Fix Aplicado)
    UserInputService.JumpRequest:Connect(function()
        if noJumpCooldownActivo then
            local model = getActiveCharacterModel()
            if model then
                local hum = model:FindFirstChildOfClass("Humanoid")
                if hum and hum:GetState() ~= Enum.HumanoidStateType.Freefall then
                    hum:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end
        end
    end)
    
    crearBotonAccion(DevFrame, "Imprimir Rutas de Chases (F9)", Color3.fromRGB(120, 50, 180), function()        
        local function printPaths(folder, currentPath)          
            for _, child in ipairs(folder:GetChildren()) do                
                local newPath = currentPath .. '", "' .. child.Name                
                if child:IsA("Sound") then                    
                    print('RUTA ENCONTRADA: {"' .. newPath .. '"}')                
                elseif child:IsA("Folder") then       
                    printPaths(child, newPath)                
                end            
            end        
        end            
        local base = ReplicatedStorage:FindFirstChild("ClientAssets")        
        if base then base = base:FindFirstChild("Sounds") end        
        if base then base = base:FindFirstChild("mus") end       
        if base then base = base:FindFirstChild("Game") end        
        if base then base = base:FindFirstChild("Round") end        
        if base then base = base:FindFirstChild("ChaseThemes") end                
        if base then            
            print("=== RUTAS DE CHASE THEMES DISPONIBLES ===")            
            for _, exe in ipairs(base:GetChildren()) do            
                if exe:IsA("Folder") then printPaths(exe, exe.Name) end            
            end            
            print("===========================================")        
        else print("No se encontró la carpeta ChaseThemes.") end    
    end)    
    
    local devWalkSpeed = 16    
    local devFlySpeed = 50    
    local isFlying = false    
    local noclipActivo = false    
    local forceWalkspeedActive = false    
    local isFullBright = false      
    local noclipConnection = nil    
    
    crearToggle(DevFrame, "Noclip", false, colorDev, function(valor)        
        noclipActivo = valor        
        if noclipActivo then            
            noclipConnection = RunService.Stepped:Connect(function()                
                local model = getActiveCharacterModel()                
                if model then for _, v in pairs(model:GetDescendants()) do if v:IsA("BasePart") and v.CanCollide then v.CanCollide = false end end end            
            end)        
        else            
            if noclipConnection then noclipConnection:Disconnect(); noclipConnection = nil end            
            local model = getActiveCharacterModel()            
            if model then for _, v in pairs(model:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide = true end end end        
        end    
    end)    
    
    crearSlider(DevFrame, "Velocidad Caminar", 16, 200, 16, colorDev, function(val)        
        devWalkSpeed = val        
        forceWalkspeedActive = (val ~= 16)    
    end)    
    
    local flyBodyVelocity = nil    
    local flyBodyGyro = nil    
    crearToggle(DevFrame, "Modo Vuelo", false, colorDev, function(valor)        
        isFlying = valor        
        local char = getActiveCharacterModel()        
        if not char then return end        
        local hrp = char:FindFirstChild("HumanoidRootPart")        
        if not hrp then return end        
        local hum = char:FindFirstChild("Humanoid")        
        if isFlying then  
            flyBodyVelocity = Instance.new("BodyVelocity")            
            flyBodyVelocity.Velocity = Vector3.new(0, 0, 0)            
            flyBodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)            
            flyBodyVelocity.Parent = hrp            
            flyBodyGyro = Instance.new("BodyGyro")            
            flyBodyGyro.P = 9e4            
            flyBodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)            
            flyBodyGyro.CFrame = hrp.CFrame            
            flyBodyGyro.Parent = hrp            
            if hum then hum.PlatformStand = true end        
        else            
            if flyBodyVelocity then flyBodyVelocity:Destroy() end            
            if flyBodyGyro then flyBodyGyro:Destroy() end            
            if hum then hum.PlatformStand = false end        
        end    
    end)    
    
    RunService.RenderStepped:Connect(function()        
        if isFlying and flyBodyVelocity and flyBodyGyro then            
            local model = getActiveCharacterModel()            
            if model and model:FindFirstChild("HumanoidRootPart") then                
                local cam = workspace.CurrentCamera              
                local moveDir = Vector3.new(0,0,0)                            
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + cam.CFrame.LookVector end                
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - cam.CFrame.LookVector end                
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - cam.CFrame.RightVector end           
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + cam.CFrame.RightVector end                
                if moveDir.Magnitude > 0 then moveDir = moveDir.Unit end                            
                flyBodyVelocity.Velocity = moveDir * devFlySpeed                
                flyBodyGyro.CFrame = cam.CFrame            
            end 
        end                
        
        if forceWalkspeedActive then            
            local charNormal = LocalPlayer.Character            
            if charNormal and charNormal:FindFirstChild("Humanoid") then                
                charNormal.Humanoid.WalkSpeed = devWalkSpeed            
            end              
            local customFolder = workspace:FindFirstChild("Players")            
            local customModel = customFolder and customFolder:FindFirstChild(LocalPlayer.Name)            
            if customModel and customModel:FindFirstChild("Humanoid") then                
                customModel.Humanoid.WalkSpeed = devWalkSpeed            
            end        
        end        
    end)    
    
    crearSlider(DevFrame, "Velocidad Vuelo", 20, 300, 50, colorDev, function(val) devFlySpeed = val end)    
    
    local oldBrightness, oldShadows, oldAmbient    
    crearToggle(DevFrame, "Full Bright", false, colorDev, function(valor)  
        isFullBright = valor        
        if isFullBright then            
            oldBrightness = Lighting.Brightness; oldShadows = Lighting.GlobalShadows; oldAmbient = Lighting.Ambient            
            Lighting.Brightness = 2; Lighting.GlobalShadows = false; Lighting.Ambient = Color3.fromRGB(255,255,255)        
        else            
            Lighting.Brightness = oldBrightness or 1; Lighting.GlobalShadows = oldShadows or true; Lighting.Ambient = oldAmbient or Color3.fromRGB(128,128,128)        
        end    
    end)    

    -- ==========================================    
    -- SISTEMA DE ESP OPTIMIZADO    
    -- ==========================================    
    local espActivo = false    
    local espHighlights = {}    
    local espFolder = Instance.new("Folder")    
    espFolder.Name = "FrostterESP_Dev"        
    pcall(function() espFolder.Parent = CoreGui end)    
    if not espFolder.Parent then espFolder.Parent = LocalPlayer:WaitForChild("PlayerGui") end    
    
    crearToggle(DevFrame, "ESP Jugadores (Cian=Surv | Rojo=Killer)", false, colorDev, function(valor)        
        espActivo = valor        
        if not espActivo then            
            for _, hl in pairs(espHighlights) do hl:Destroy() end            
            espHighlights = {}        
        end    
    end)    
    
    task.spawn(function()        
        while true do            
            task.wait(0.5)       
            if espActivo then                
                for _, p in ipairs(Players:GetPlayers()) do                    
                    if p ~= LocalPlayer then                        
                        local customFolder = workspace:FindFirstChild("Players")                    
                        local customChar = customFolder and customFolder:FindFirstChild(p.Name)                        
                        local targetChar = customChar or p.Character                        
                        if targetChar and targetChar:FindFirstChild("HumanoidRootPart") then                            
                            local hl = espHighlights[p.Name]   
                            if not hl then                                
                                hl = Instance.new("Highlight")                                
                                hl.Name = p.Name    
                                hl.FillTransparency = 1                                
                                hl.OutlineTransparency = 0                                
                                hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop  
                                hl.Parent = espFolder                                
                                espHighlights[p.Name] = hl                            
                            end      
                            if hl.Adornee ~= targetChar then hl.Adornee = targetChar end                            
                            
                            local esKiller = false                            
                            if p.Team and (string.find(string.lower(p.Team.Name), "killer") or string.find(string.lower(p.Team.Name), "exe")) then                 
                                esKiller = true                             
                            end                                                     
                            local charName = targetChar:GetAttribute("Character") or ""                            
                            local killerNames = {"2011x", "fleetway", "tailsdoll", "kolossos", "lordx", "majin", "exe"}                                                       
                            for _, kn in ipairs(killerNames) do                                
                                if string.find(string.lower(charName), kn) then                                     
                                    esKiller = true                    
                                    break                                 
                                end                            
                            end                      
                            hl.OutlineColor = esKiller and Color3.fromRGB(255, 50, 50) or Color3.fromRGB(50, 255, 255)                        
                        else                            
                            if espHighlights[p.Name] then  
                                espHighlights[p.Name]:Destroy()                                 
                                espHighlights[p.Name] = nil                             
                            end     
                        end                    
                    end                
                end            
            end        
        end    
    end)
end

-- ============================================================================
-- EJECUCIÓN DEL SCRIPT 1: LMS THEMES 
-- ============================================================================
task.spawn(function()    
    local soloThemeFolder = ReplicatedStorage:WaitForChild("ClientAssets"):WaitForChild("Sounds"):WaitForChild("mus"):WaitForChild("Game"):WaitForChild("Round"):WaitForChild("SoloTheme")     
    nuevosTemasGlobal = {        
        ["TailsSolo"]      = {url = "https://raw.githubusercontent.com/imnotsense/LMS-Y-CHASES/main/tails.mp3", mult = 6},        
        ["CreamSolo"]      = {url = "https://raw.githubusercontent.com/imnotsense/LMS-Y-CHASES/main/cream.mp3", mult = 6},        
        ["EggmanSolo"]     = {url = "https://raw.githubusercontent.com/imnotsense/LMS-Y-CHASES/main/eggman.mp3", mult = 6},        
        ["KnucklesSolo"]   = {url = "https://raw.githubusercontent.com/imnotsense/LMS-Y-CHASES/main/knuckles.mp3", mult = 6},        
        ["MetalSonicSolo"] = {url = "https://raw.githubusercontent.com/imnotsense/LMS-Y-CHASES/main/metalsonic.mp3", mult = 6},    
        ["SonicSolo"]      = {url = "https://raw.githubusercontent.com/imnotsense/LMS-Y-CHASES/main/sonic.mp3", mult = 6},        
        ["AmySolo"]        = {url = "https://raw.githubusercontent.com/imnotsense/LMS-Y-CHASES/main/amy.mp3", mult = 6},        
        ["SilverSolo"]     = {url = "https://raw.githubusercontent.com/imnotsense/LMS-Y-CHASES/main/silver.mp3", mult = 6},        
        ["BlazeSolo"]      = {url = "https://raw.githubusercontent.com/imnotsense/LMS-Y-CHASES/main/blaze.mp3", mult = 6},        
        ["ShadowSolo"]     = {url = "https://raw.githubusercontent.com/imnotsense/LMS-Y-CHASES/main/shadow.mp3", mult = 6}    
    }    
    
    local function aplicarDetectorDeApagado(objetoSonido, multiplicadorVolumen)        
        if not objetoSonido:IsA("Sound") or objetoSonido:GetAttribute("DetectorAplicado") then return end        
        objetoSonido:SetAttribute("DetectorAplicado", true)                
        local volumenFinal = multiplicadorVolumen or SoloTheme_Volume_Multiplier or 1                
        objetoSonido.Looped = false        
        objetoSonido.Ended:Connect(function() objetoSonido:Stop() end)        
        objetoSonido.DidLoop:Connect(function() objetoSonido:Stop() end)        
        
        objetoSonido:GetPropertyChangedSignal("Volume"):Connect(function()            
            local nombre = objetoSonido.Name            
            if objetoSonido.Playing and LMS_Estados[nombre] then                
                if math.abs(objetoSonido.Volume - volumenFinal) > 0.1 then                     
                    objetoSonido.Volume = volumenFinal                
                end            
            end        
        end)        
        
        objetoSonido:GetPropertyChangedSignal("Playing"):Connect(function()            
            local nombre = objetoSonido.Name            
            if objetoSonido.Playing and LMS_Estados[nombre] then                
                objetoSonido.Volume = volumenFinal                
                if objetoSonido:GetAttribute("LoopActivo") then return end  
                objetoSonido:SetAttribute("LoopActivo", true)                
                task.spawn(function()                    
                    local ultimaPosicion = objetoSonido.TimePosition                    
                    while objetoSonido.Playing and objetoSonido.Parent and LMS_Estados[nombre] do                    
                        task.wait(1)                         
                        local posicionActual = objetoSonido.TimePosition                        
                        if posicionActual < ultimaPosicion and objetoSonido.Playing then                             
                            objetoSonido:Stop()         
                            break                         
                        end                        
                        ultimaPosicion = posicionActual                    
                    end          
                    objetoSonido:SetAttribute("LoopActivo", false)                
                end)            
            end        
        end)    
    end    
    
    for personaje, data in pairs(nuevosTemasGlobal) do        
        local objetoSonido = soloThemeFolder:FindFirstChild(personaje)        
        if objetoSonido and objetoSonido:IsA("Sound") then            
            lmsOriginalIds[personaje] = objetoSonido.SoundId   
            local ruta = "MusicCache/" .. personaje .. ".mp3"                        
            local exito, contenido = pcall(function() return game:HttpGet(data.url) end)            
            if exito and contenido then                
                writefile(ruta, contenido)                
                objetoSonido:Stop()    
                objetoSonido.SoundId = ""                 
                task.wait(0.02)                                
                if LMS_Estados[personaje] then                     
                    objetoSonido.SoundId = getcustomasset(ruta)            
                end                
                aplicarDetectorDeApagado(objetoSonido, data.mult)            
            end        
        end    
    end        
    for _, sonido in pairs(soloThemeFolder:GetChildren()) do         
        if not nuevosTemasGlobal[sonido.Name] then            
            aplicarDetectorDeApagado(sonido, SoloTheme_Volume_Multiplier or 2)        
        end    
    end
end)

-- ============================================================================
-- EJECUCIÓN DEL SCRIPT 2: CHASE THEMES INTERCEPTOR
-- ============================================================================
task.spawn(function()    
    local silentGroup = SoundService:FindFirstChild("MuteHolder_Custom") or Instance.new("SoundGroup")    
    silentGroup.Name = "MuteHolder_Custom"    
    silentGroup.Volume = 0    
    silentGroup.Parent = SoundService    
    silentGroupGlobal = silentGroup    
    
    local function loadCustomAsset(url, filename)        
        if not isfile(filename) then writefile(filename, game:HttpGet(url, true)) end        
        return getcustomasset(filename)    
    end    
    local soundMap = {}    
    local function normalizeId(id) return string.match(id, "%d+") or id end    
    
    local function registrarIdOriginal(pathTable, url, filename, multiplicadorVolumen)        
        local current = ReplicatedStorage:WaitForChild("ClientAssets"):WaitForChild("Sounds"):WaitForChild("mus"):WaitForChild("Game"):WaitForChild("Round"):WaitForChild("ChaseThemes")        
        for _, name in ipairs(pathTable) do            
            current = current:WaitForChild(name, 5)            
            if not current then return end        
        end        
        if current:IsA("Sound") and current.SoundId ~= "" then            
            local customAsset = loadCustomAsset(url, filename)  
            current:SetAttribute("CustomAssetPath", customAsset)            
            current:SetAttribute("CustomVolumeMult", multiplicadorVolumen)            
            soundMap[normalizeId(current.SoundId)] = {asset = customAsset, mult = multiplicadorVolumen}        
        end    
    end    
    
    pcall(function()        
        registrarIdOriginal({"2011x", "Default", "NormalChase"}, "https://github.com/imnotsense/LMS-Y-CHASES/raw/refs/heads/main/2011x%20normal.mp3", "2011NormalChase_v2.mp3", 0.5)        
        registrarIdOriginal({"2011x", "Default", "LastLifeChase"}, "https://github.com/imnotsense/LMS-Y-CHASES/raw/refs/heads/main/2011x%20lastlife.mp3", "2011LastLifeChase_v2.mp3", 0.5)        
        registrarIdOriginal({"2011x", "RETRO", "NormalChase"}, "https://github.com/imnotsense/LMS-Y-CHASES/raw/refs/heads/main/CLASSICO%202011X%20CHASETHEME.mp3", "NormalChase_v2.mp3", 0.5)  
        registrarIdOriginal({"2011x", "RETRO", "LastLifeChase"}, "https://github.com/imnotsense/LMS-Y-CHASES/raw/refs/heads/main/lastlife%20classic%202011x.mp3", "lastlifeClassic_v2.mp3", 0.5)        
        registrarIdOriginal({"2011x", "Default", "Rage"}, "https://github.com/imnotsense/LMS-Y-CHASES/raw/refs/heads/main/2011X%20RAGE.mp3", "NormalRage.mp3", 0.3)        
        registrarIdOriginal({"2011x", "RETRO", "Rage"}, "https://raw.githubusercontent.com/IceKnight125/OutcomeMemories1227/main/ClassicRage.mp3", "ClassicRage.mp3", 0.3)        
        registrarIdOriginal({"2011x", "miku", "Rage"}, "https://raw.githubusercontent.com/IceKnight125/OutcomeMemories1227/main/MikuRage.mp3", "MikuRage.mp3", 0.3)        
        registrarIdOriginal({"TailsDoll", "Default", "NormalChase"}, "https://raw.githubusercontent.com/imnotsense/LMS-Y-CHASES/main/tailsdoll-normal.mp3", "TailsDollNormal.mp3", 0.5)        
        registrarIdOriginal({"TailsDoll", "Default", "LastLifeChase"}, "https://raw.githubusercontent.com/imnotsense/LMS-Y-CHASES/main/tailsdoll-lastlife.mp3", "TailsDollLast.mp3", 0.5)        
        registrarIdOriginal({"TailsDoll", "Default", "TerrorRadius"}, "https://raw.githubusercontent.com/imnotsense/LMS-Y-CHASES/main/terrorradiusTailsdoll.mp3", "TailsDollTerror.mp3", 3)        
        registrarIdOriginal({"Kolossos", "Default", "NormalChase"}, "https://raw.githubusercontent.com/imnotsense/LMS-Y-CHASES/main/Kolossos-normal.mp3", "KolossosNormal.mp3", 0.5)        
        registrarIdOriginal({"Kolossos", "Default", "LastLifeChase"}, "https://raw.githubusercontent.com/imnotsense/LMS-Y-CHASES/main/Kolossos-lastlife.mp3", "KolossosLast.mp3", 0.5)        
        registrarIdOriginal({"Kolossos", "Forest", "NormalChase"}, "https://raw.githubusercontent.com/imnotsense/LMS-Y-CHASES/main/ForestKolossos-normal.mp3", "KolossosVarNormal.mp3", 0.5)        
        registrarIdOriginal({"Kolossos", "Forest", "LastLifeChase"}, "https://raw.githubusercontent.com/imnotsense/LMS-Y-CHASES/main/ForestKolossos-lastlife.mp3", "KolossosVarLast.mp3", 0.5)        
        registrarIdOriginal({"Fleetway", "Default", "NormalChase"}, "https://raw.githubusercontent.com/imnotsense/LMS-Y-CHASES/main/Fleetway-normal.mp3", "FleetwayNormal.mp3", 0.5)        
        registrarIdOriginal({"Fleetway", "Default", "LastLifeChase"}, "https://raw.githubusercontent.com/imnotsense/LMS-Y-CHASES/main/Fleetway-lastlife.mp3", "FleetwayLast.mp3", 0.5)    
    end)    
    
    local function interceptarSonidoDelJuego(sound)        
        if sound.ClassName ~= "Sound" then return end        
        if sound.Name ~= "NormalChase" and sound.Name ~= "LastLifeChase" and sound.Name ~= "Rage" and sound.Name ~= "TerrorRadius" then return end        
        if sound:GetAttribute("Interceptado") or string.find(sound.Name, "_Custom") then return end                
        
        local customAsset = sound:GetAttribute("CustomAssetPath")        
        local volumeMult = sound:GetAttribute("CustomVolumeMult")                
        
        if not customAsset then            
            local intentos = 0    
            while sound.SoundId == "" and intentos < 10 do task.wait(0.05); intentos = intentos + 1 end            
            local datosCustom = soundMap[normalizeId(sound.SoundId)]            
            if datosCustom then customAsset = datosCustom.asset; volumeMult = datosCustom.mult end        
        end                
        
        if not customAsset then return end        
        sound:SetAttribute("Interceptado", true)                
        
        local originalGroup = sound.SoundGroup        
        if Chase_Activo then sound.SoundGroup = silentGroup end                
        
        local customSound = Instance.new("Sound")       
        customSound.Name = sound.Name .. "_Custom"        
        customSound.SoundId = customAsset        
        customSound.Looped = sound.Looped        
        customSound.RollOffMaxDistance = sound.RollOffMaxDistance        
        customSound.RollOffMinDistance = sound.RollOffMinDistance        
        customSound.RollOffMode = sound.RollOffMode        
        customSound.Parent = sound.Parent         
        customSound.Playing = (Chase_Activo and sound.Playing)        
        customSound.Volume = sound.Volume * (volumeMult or 1)        
        
        local playingConn = sound:GetPropertyChangedSignal("Playing"):Connect(function()            
            if Chase_Activo then customSound.Playing = sound.Playing else customSound.Playing = false end        
        end)        
        local volumeConn = sound:GetPropertyChangedSignal("Volume"):Connect(function()            
            if Chase_Activo then customSound.Volume = sound.Volume * (volumeMult or 1) end        
        end)            
        
        local destroyConn        
        destroyConn = sound.AncestryChanged:Connect(function(_, parent)  
            if not parent then                 
                playingConn:Disconnect()                
                volumeConn:Disconnect()                
                destroyConn:Disconnect()                
                if customSound then customSound:Destroy() end                
                chaseObjects[sound] = nil            
            end        
        end)        
        chaseObjects[sound] = {            
            customSound = customSound,             
            originalGroup = originalGroup,             
            volumeMult = volumeMult        
        }    
    end    
    
    local function checkAndApplySound(desc)        
        if desc:IsA("Sound") then            
            task.defer(function()                
                aplicarVolumen(desc)                
                interceptarSonidoDelJuego(desc)            
            end)        
        end    
    end        
    workspace.DescendantAdded:Connect(checkAndApplySound)  
    SoundService.DescendantAdded:Connect(checkAndApplySound)        
    for _, desc in ipairs(workspace:GetDescendants()) do checkAndApplySound(desc) end    
    for _, desc in ipairs(SoundService:GetDescendants()) do checkAndApplySound(desc) end
end)

-- ============================================================================
-- EJECUCIÓN DEL SCRIPT 3: FLEETWAY ORIGINAL LOW HP LMS 
-- ============================================================================
task.spawn(function()    
    local LOW_HP_THRESHOLD = 150    
    local TENSION_VOLUME = 0.8    
    local PLAY_DELAY = 0.5    
    local FREEZE_TIME_REQUIRED = 3    
    
    local function loadCustomAssetFleetway(url, filename)        
        local fullPath = "MusicCache/" .. filename        
        if not isfile(fullPath) then 
            local success, content = pcall(function() return game:HttpGet(url) end)            
            if success and content then writefile(fullPath, content) end        
        end        
        return getcustomasset(fullPath)    
    end    
    
    local MUSIC_ID = loadCustomAssetFleetway("https://github.com/imnotsense/LMS-Y-CHASES/raw/refs/heads/main/fleetway.mp3", "fleetway.mp3")    
    local tensionMusic = Instance.new("Sound")    
    tensionMusic.Name = "FleetwayLowHP"    
    tensionMusic.SoundId = MUSIC_ID    
    tensionMusic.Looped = true    
    tensionMusic.Volume = 0   
    tensionMusic.Parent = SoundService    
    
    local mutedSounds = {}    
    local triggeredThisRound = false    
    local lastTimerValue = nil    
    local freezeStartTime = nil    
    
    local function getTimer()        
        local gp = workspace:FindFirstChild("GameProperties")        
        return gp and gp:FindFirstChild("Time")    
    end    
    
    local function muteSpecificSongs()        
        mutedSounds = {}        
        local soloFolder = game:GetService("ReplicatedStorage"):FindFirstChild("ClientAssets")        
        if soloFolder then soloFolder = soloFolder:FindFirstChild("Sounds") end        
        if soloFolder then soloFolder = soloFolder:FindFirstChild("mus") end        
        if soloFolder then soloFolder = soloFolder:FindFirstChild("Game") end        
        if soloFolder then soloFolder = soloFolder:FindFirstChild("Round") end        
        if soloFolder then soloFolder = soloFolder:FindFirstChild("SoloTheme") end        
        if soloFolder then            
            for _, sound in ipairs(soloFolder:GetDescendants()) do             
                if sound:IsA("Sound") then mutedSounds[sound] = sound.Volume; sound.Volume = 0 end            
            end        
        end        
        local workspaceSongs = workspace:FindFirstChild("Assets")        
        if workspaceSongs then workspaceSongs = workspaceSongs:FindFirstChild("Songs") end        
        if workspaceSongs then            
            for _, sound in ipairs(workspaceSongs:GetDescendants()) do                
                if sound:IsA("Sound") then mutedSounds[sound] = sound.Volume; sound.Volume = 0 end            
            end        
        end    
    end    
    
    local function restoreSounds()        
        for sound, volume in pairs(mutedSounds) do if sound and sound.Parent then sound.Volume = volume end end        
        mutedSounds = {}    
    end    
    
    local function stopMusic()        
        if tensionMusic.IsPlaying or tensionMusic.Volume > 0 then          
            tensionMusic:Stop(); tensionMusic.Volume = 0; restoreSounds()        
        end        
        triggeredThisRound = false    
    end    
    
    task.spawn(function()        
        while true do            
            task.wait(0.3)            
            if not Fleetway_LMS_Activo then stopMusic(); lastTimerValue = nil; freezeStartTime = nil; continue end            
            local model = getActiveCharacterModel()       
            local timer = getTimer()            
            if not model or not timer then stopMusic(); lastTimerValue = nil; freezeStartTime = nil; continue end            
            local health = model:FindFirstChild("Health")            
            local isFleetway = model:GetAttribute("Character") == "Fleetway"            
            local currentTimer = timer.Value            
            
            if not health or not isFleetway or currentTimer <= 0 then stopMusic(); lastTimerValue = nil; freezeStartTime = nil; continue end            
            
            if lastTimerValue == nil then                
                lastTimerValue = currentTimer            
            else                
                if currentTimer == lastTimerValue then                    
                    if not freezeStartTime then freezeStartTime = tick()                    
                    elseif tick() - freezeStartTime >= FREEZE_TIME_REQUIRED then stopMusic(); continue end                
                else lastTimerValue = currentTimer; freezeStartTime = nil end            
            end            
            
            local hp = health.Value            
            if hp > 0 and hp <= LOW_HP_THRESHOLD and not triggeredThisRound then                
                triggeredThisRound = true; muteSpecificSongs(); task.wait(PLAY_DELAY)                
                if timer and timer.Value > 0 and Fleetway_LMS_Activo then                    
                    if not tensionMusic.IsPlaying then tensionMusic:Play() end                    
                    tensionMusic.Volume = TENSION_VOLUME                
                end            
            end        
        end    
    end)
end)
