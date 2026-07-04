print("[Cream x TailsDoll] Now loading... Made by lil2kki <3 | Optimized Build")

local RepStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")

local tar = RepStorage:FindFirstChild("Characters", true)
tar = tar and tar:FindFirstChild("TailsDoll", true)
tar = tar and tar:FindFirstChild("Skins", true)

local OLD_THERE_ALR = tar and tar:FindFirstChild("_OLD", true)
if OLD_THERE_ALR then
    warn("[Cream x TailsDoll] Restoring original skin")
    local def = tar:FindFirstChild("Default", true)
    if def then def:Destroy() end
    OLD_THERE_ALR.Name = "Default"
end

tar = tar and tar:FindFirstChild("Default", true)

local src = RepStorage:FindFirstChild("Characters", true)
src = src and src:FindFirstChild("Cream", true)
src = src and src:FindFirstChild("Skins", true)
src = src and src:FindFirstChild("Default", true)

if not tar or not src then warn("[Cream x TailsDoll] Models not found!") return end

-- clonar cream
local model = src:Clone()
model.Name = tar.Name
model.Parent = tar.Parent
tar.Name = "_OLD"

for _, v in ipairs(model:GetDescendants()) do
    if v:IsA("BasePart") then
        v.Material = Enum.Material.Slate
    end
end

local function find(name)
    return model:FindFirstChild(name, true)
end

-- ojos rojos
local thatslikeevilandscary = game:GetObjects("rbxassetid://120086931957772")[1]
local eyeNames = {{"Eye1","eye1"}, {"Eye2","eye2"}}
for _, pair in ipairs(eyeNames) do
    local srcPart = thatslikeevilandscary:FindFirstChild(pair[1], true)
    local dstPart = model:FindFirstChild(pair[2], true)
    if srcPart and dstPart then
        dstPart.Material = Enum.Material.Neon
        dstPart.Color = Color3.fromRGB(0,0,0)
        dstPart.Transparency = 1
        dstPart.Size = dstPart.Size / 3
        for _, child in ipairs(srcPart:GetChildren()) do
            if child:IsA("ParticleEmitter") or child:IsA("Attachment") then
                child.Parent = dstPart
                if child.Name == "YiSang" then child:Destroy() end
            end
        end
        for _, child in ipairs(dstPart:GetDescendants()) do
            if child:IsA("ParticleEmitter") then
                child.LockedToPart = true
                if child.Name == "bubble" then 
                    child.LightEmission = 0.1
                    child.LightInfluence = 0.1
                end
            end
        end
    end
end
thatslikeevilandscary:Destroy()

-- ojos base
local eyes = find("eyes")
if eyes and eyes:IsA("BasePart") then
    eyes.Material = Enum.Material.Neon
    eyes.Color = Color3.new(0, 0, 0)
end

-- Sistema de renombrado optimizado O(1) por iteración
local renameMap = {
    ["waist"] = "Waist", ["Body"] = "MainBody",
    ["eye1"] = "REye", ["eye2"] = "LEye",
    ["Right Sleeve"] = "RArm1", ["Cylinder.013"] = "RArm2", ["Cylinder.014"] = "RArm3", ["Cylinder.017"] = "RArm4", ["Right Hand"] = "RHand",
    ["Left Sleeve"] = "LArm1", ["Cylinder.023"] = "LArm2", ["Cylinder.022"] = "LArm3", ["Left Hand"] = "LHand",
    ["Right Leg"] = "RLeg1", ["Cylinder.001"] = "RLeg2", ["Cylinder"] = "RLeg3", ["Right Shoe"] = "RShoe",
    ["Left Leg"] = "LLeg1", ["Cylinder.034"] = "LLeg2", ["Cylinder.035"] = "LLeg3", ["Left Shoe"] = "LShoe",
    ["tail"] = "RTail"
}

for _, obj in ipairs(model:GetDescendants()) do
    if renameMap[obj.Name] then
        obj.Name = renameMap[obj.Name]
    end
end

-- Sangre
local muzzle = model:FindFirstChild("muzzle", true)
local drip = game:GetObjects("rbxassetid://84762690015926")[1]
drip.Parent = muzzle
drip.UVScale = Vector2.new(1.5, 1)

-- Vestido
local dress = model:FindFirstChild("dress", true)
if dress then dress.Material = Enum.Material.Sandstone end

print("[Cream x TailsDoll] Model setup done...")

-- Reemplazo de personaje
local function updatePlayerModel(playerName)
	local plrModel = workspace.Players:FindFirstChild(playerName)
	if not plrModel then return end
	if plrModel:GetAttribute("Character") ~= "TailsDoll" then return end

    print("[Cream x TailsDoll] Updating model for " .. plrModel.Name .. "...")
    
	local hrp = plrModel:FindFirstChild("HumanoidRootPart", true)
	if not hrp then return end

	local ogHead = plrModel:FindFirstChildOfClass("Motor6D", true)

    for _, v in ipairs(plrModel:GetDescendants()) do
        if v:IsA("Motor6D") and v.Name == "Head" then ogHead = v end
        if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then
            if string.find(v.Name, "Claw") then v:Destroy() end
            v.Transparency = 1
            v.LocalTransparencyModifier = 1
        end
        if v:IsA("ParticleEmitter") or v:IsA("PointLight") then v:Destroy() end
    end
    
    local defaultMdl = RepStorage:FindFirstChild("Characters", true)
    defaultMdl = defaultMdl and defaultMdl:FindFirstChild("TailsDoll", true)
    defaultMdl = defaultMdl and defaultMdl:FindFirstChild("Skins", true)
    defaultMdl = defaultMdl and defaultMdl:FindFirstChild("Default", true)
    
    if not defaultMdl then return end
    local mdl = defaultMdl:Clone()
	mdl.Parent = plrModel

	local newHrp = mdl:FindFirstChild("HumanoidRootPart", true)
	if not newHrp then mdl:Destroy() return end

	local myHead = mdl:FindFirstChildOfClass("Motor6D", true)

	for _, v in ipairs(mdl:GetDescendants()) do
        if v:IsA("Motor6D") and v.Name == "Head" then myHead = v end
		if v:IsA("Humanoid") or v:IsA("Animator") then v:Destroy() end
        if v:IsA("BasePart") then v.CanCollide = false end
	end

	local hrpOffset = Vector3.new(0, -1, 0)

    if _G.CreamOnTailsDollSkinUpdateConnection then
        _G.CreamOnTailsDollSkinUpdateConnection:Disconnect()
        _G.CreamOnTailsDollSkinUpdateConnection = nil
    end
    
    _G.CreamOnTailsDollSkinUpdateConnection = RunService.Heartbeat:Connect(function()
		if not mdl or not mdl.Parent then
			_G.CreamOnTailsDollSkinUpdateConnection:Disconnect()
        	_G.CreamOnTailsDollSkinUpdateConnection = nil
			updatePlayerModel(playerName)
			return
		end
		
		if plrModel:GetAttribute("Character") ~= "TailsDoll" then
			_G.CreamOnTailsDollSkinUpdateConnection:Disconnect()
        	_G.CreamOnTailsDollSkinUpdateConnection = nil
			mdl:Destroy()
			return
		end
		
		newHrp.CFrame = hrp.CFrame + hrpOffset
        if myHead and ogHead then myHead.C0 = ogHead.C0 end
	end)

    return plrModel
end

local function tryUpdatePlayerModel(m)
    if m:GetAttribute("Character") ~= "TailsDoll" then return end
    _G.TailsDollModel = m
    updatePlayerModel(m.Name)
end

local function walkPlayers()
    _G.TailsDollModel = nil
    task.wait(1)
    for _, m in ipairs(workspace.Players:GetChildren()) do
    	if not m:IsA("Model") or m.Name == game.Players.LocalPlayer.Name then continue end
        tryUpdatePlayerModel(m)
    end
end

if _G.CreamOnTailsDollSkinGameStateConn then
    _G.CreamOnTailsDollSkinGameStateConn:Disconnect()
end
local gameProps = workspace:WaitForChild("GameProperties", 10)
if gameProps then
    _G.CreamOnTailsDollSkinGameStateConn = gameProps:WaitForChild("State").Changed:Connect(function(newState)
        if newState == "ING" then walkPlayers() end
    end)
end
walkPlayers()

if _G.CreamOnTailsDollSkinCharacterConn then
    _G.CreamOnTailsDollSkinCharacterConn:Disconnect()
end
_G.CreamOnTailsDollSkinCharacterConn = game.Players.LocalPlayer.CharacterAdded:Connect(function(character)
    if character:GetAttribute("Character") ~= "TailsDoll" then return end
    local healthxd = Instance.new("NumberValue")
    healthxd.Name = "Health"
    healthxd.Parent = character
    task.wait(3)
    healthxd.Value = 0
    tryUpdatePlayerModel(character)
end)
if game.Players.LocalPlayer.Character then
    tryUpdatePlayerModel(game.Players.LocalPlayer.Character)
end

print("[Cream x TailsDoll] Players scanned, game state and your char being listened.")

-- Sonidos
print("[Cream x TailsDoll] Loading custom sounds...")
local function myAsset(fileName)
    local cachePath = "cache/cream-on-doll/" .. fileName
    if isfile(cachePath) then return getcustomasset(cachePath) end
    local success, result = pcall(function()
        return game:HttpGet("https://github.com/thaLILNIKKI/Cream.LMS-for-TailsDoll-Outcome-Memories/releases/download/assets/" .. fileName)
    end)
    if success and result then
        if not isfolder("cache/cream-on-doll") then makefolder("cache/cream-on-doll") end
        writefile(cachePath, result)
        return getcustomasset(cachePath)
    else
        warn("[Cream x TailsDoll] failed to load " .. fileName)
        return nil
    end
end

local assigns = {
    [80901931085615] = myAsset("NormalChaseFix.mp3"),
    [129416111545242] = myAsset("TerrorRadius.mp3"),
    [112879248941055] = myAsset("LastLifeChase3.mp3"),
    [112976135484851] = myAsset("Unleashed1.mp3"),
    [106071428647005] = myAsset("Unleashed2.mp3"),
    [87302988643016] = myAsset("Unleashed3.mp3"),
    [131820864449998] = myAsset("Retract.mp3"),
	[97101227703333] = "rbxassetid://139116822099909", 
	[93465914238963] = "rbxassetid://88164444698409",
	[113251186335660] = "rbxassetid://5507830073",
    [73636680793269] = "rbxassetid://77110140707717",
    [108753423324802] = "rbxassetid://77110140707717",
    [134998846301914] = "rbxassetid://77110140707717",
}

local StunSounds, DownedSounds, AttackSounds = {}, {}, {}
for i = 1, 28 do table.insert(StunSounds, myAsset("Stun" .. i .. ".mp3")) end
for i = 1, 14 do table.insert(DownedSounds, myAsset("Down" .. i .. ".mp3")) end
for i = 1, 8 do table.insert(AttackSounds, myAsset("Attack" .. i .. ".mp3")) end

local KillLines = {
    ["Sonic"] = { myAsset("Sonic.mp3"), myAsset("Sonic2.mp3") },
    ["Tails"] = { myAsset("Tails.mp3"), myAsset("Tails2.mp3"), myAsset("Tails3.mp3") },
    ["MetalSonic"] = { myAsset("MetalSonic.mp3"), myAsset("MetalSonic2.mp3") },
    ["Amy"] = { myAsset("Amy.mp3"), myAsset("Amy2.mp3"), myAsset("Amy3.mp3"), myAsset("Amy4.mp3") },
    ["Silver"] = { myAsset("Silver.mp3") },
    ["Blaze"] = { myAsset("Blaze.mp3") },
    ["Eggman"] = { myAsset("Eggman.mp3") },
    ["Cream"] = { myAsset("Cream.mp3"), myAsset("Cream2.mp3") },
    ["Knuckles"] = { myAsset("Knuckles.mp3") }
}

-- Global DescendantAdded Optimizado
if _G.CreamOnTailsDollSkinDescendantAddedConnection then
	_G.CreamOnTailsDollSkinDescendantAddedConnection:Disconnect()
end

-- Se limitó la comprobación de GetFullName() para evitar sobrecarga de RAM
_G.CreamOnTailsDollSkinDescendantAddedConnection = game.DescendantAdded:Connect(function(desc)
    if desc:IsA("TextLabel") then
        local txt = desc.Text
        if txt == "Tripwire" or txt == "TailsDoll" or txt == "Can you feel the sunshine?" then
            local path = desc:GetFullName()
            if path:find("CoreGui.") or path:find("skibidi board") then return end
            
            task.spawn(function()
                if txt == "Tripwire" then desc.Text = " [CORRUPTED] " end
                if txt == "TailsDoll" then desc.Text = "TailsDoll (2)" end
                if txt == "Can you feel the sunshine?" then 
                    desc.TextWrapped = false
                    desc.Font = Enum.Font.Code
                    desc.TextColor3 = Color3.new(0.98, 0.98, 0.98)
                    desc.TextXAlignment = Enum.TextXAlignment.Left
                    desc.Text = "[Info] Instance copied successfully.\n"
                              .."[WARN] ReplicatedStorage missmatch!\n"
                              .."[WARN] Unauthorized access!\n"
                              .."> dont worry, thats just a way i can play :>\n"
                              .."Syntax error."
                end
            end)
        end
    elseif desc:IsA("Sound") then
        local idStr = string.match(desc.SoundId, "rbxassetid://(%d+)")
        local id = idStr and tonumber(idStr)
        if id and assigns[id] then desc.SoundId = assigns[id] end

        local path = desc:GetFullName()
        if not path:find("HumanoidRootPart.") then return end
        if not _G.TailsDollModel then return end

        if (desc.Name:find("Retract") or desc.Name:find("Unleashed")) then
            local waistSound = _G.TailsDollModel:FindFirstChild("Waist")
            if waistSound and waistSound:FindFirstChildOfClass("Sound") then
                desc.RollOffMaxDistance = desc.RollOffMaxDistance * 4
                desc.RollOffMinDistance = desc.RollOffMinDistance * 2
                desc.Volume = 1
                for _, child in ipairs(waistSound:GetChildren()) do
                    if child.Name:find("CreamSpeech") then 
                        desc.Volume = 0
                        desc:Stop()
                    end
                end
            end
        end

        local pLayerChar = desc.Parent and desc.Parent.Parent
        if not pLayerChar or pLayerChar:GetAttribute("Character") ~= "TailsDoll" then
            if path:find(".Blood Hit") then _G.LastHurtenPlayer = pLayerChar end
            return 
        end

        if desc.SoundId == "rbxassetid://77110140707717" then
            local clone = desc:Clone()
            clone.SoundId = AttackSounds[math.random(1, #AttackSounds)]
            clone.Parent = desc.Parent
            clone:Play()
        end

        local isDefLine = (path:find("Line") and path:find(".Default"))
        if isDefLine or path:find(".Downed") then desc.SoundId = DownedSounds[math.random(1, #DownedSounds)] end
        if path:find(".Hurt") then desc.SoundId = StunSounds[math.random(1, #StunSounds)] end

        if isDefLine or path:find(".Downed") or path:find(".Hurt") then
            local waist = _G.TailsDollModel:FindFirstChild("Waist")
            if waist then
                for _, child in ipairs(waist:GetChildren()) do
                    if child.Name:find("CreamSpeech") then child:Stop() end
                end
            end
            
            if isDefLine and _G.LastHurtenPlayer then
                local c = _G.LastHurtenPlayer:GetAttribute("Character")
                if KillLines[c] then 
                    desc.SoundId = KillLines[c][math.random(1, #KillLines[c])]
                    _G.LastHurtenPlayer = nil
                end
            end
            
            local sound = Instance.new("Sound")
            sound.Name = "CreamSpeech - " .. desc.SoundId
            sound.SoundId = desc.SoundId
            sound.Volume = desc.Volume
            sound.RollOffMaxDistance = desc.RollOffMaxDistance
            sound.RollOffMinDistance = desc.RollOffMinDistance
            sound.SoundGroup = desc.SoundGroup
            if waist then sound.Parent = waist end
            sound:Play()
            
            Debris:AddItem(sound, 10) 
            desc.Volume = 0
            desc:Stop()
        end
    end
end)
