print("[Cream x TailsDoll] Now loading... Made by lil2kki <3")

local tar = game:GetService("ReplicatedStorage")
tar = tar:FindFirstChild("Characters", true)
tar = tar:FindFirstChild("TailsDoll", true)
tar = tar:FindFirstChild("Skins", true)

local OLD_THERE_ALR = tar:FindFirstChild("_OLD", true)
if OLD_THERE_ALR then
    warn("[Cream x TailsDoll] Restoring original skin")
    tar:FindFirstChild("Default", true):Destroy()
    OLD_THERE_ALR.Name = "Default"
end

tar = tar:FindFirstChild("Default", true)

local src = game:GetService("ReplicatedStorage")
src = src:FindFirstChild("Characters", true)
src = src:FindFirstChild("Cream", true)
src = src:FindFirstChild("Skins", true)
src = src:FindFirstChild("Default", true)

if not tar or not src then warn("[Cream x TailsDoll] Models not found!") return end

-- clone cream
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

-- red dots :3
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

-- eyes
local eyes = find("eyes")
if eyes and eyes:IsA("BasePart") then
    eyes.Material = Enum.Material.Neon
    eyes.Color = Color3.new(0, 0, 0)
end

-- rename parts
local function rename(oldName, newName)
	local obj = find(oldName)
	while obj do
		-- print("renaming: "..obj.Name.." -> "..newName.." //"..obj.ClassName)
		obj.Name = newName
		obj = find(oldName)
	end 
end

    rename("waist", "Waist")
    rename("Body", "MainBody")

    rename("eye1", "REye")
    rename("eye2", "LEye")

    rename("Right Sleeve", "RArm1")
    rename("Cylinder.013", "RArm2")
    rename("Cylinder.014", "RArm3")
    rename("Cylinder.017", "RArm4")
    rename("Right Hand", "RHand")

    rename("Left Sleeve", "LArm1")
    rename("Cylinder.023", "LArm2")
    rename("Cylinder.022", "LArm3")
    rename("Left Hand", "LHand")

    rename("Right Leg", "RLeg1")
    rename("Cylinder.001", "RLeg2")
    rename("Cylinder", "RLeg3")
    rename("Right Shoe", "RShoe")

    rename("Left Leg", "LLeg1")
    rename("Cylinder.034", "LLeg2")
    rename("Cylinder.035", "LLeg3")
    rename("Left Shoe", "LShoe")

    rename("tail", "RTail")
--

-- blood on muzzle :3
local muzzle = model:FindFirstChild("muzzle", true)
local drip = game:GetObjects("rbxassetid://84762690015926")[1]
drip.Parent = muzzle
drip.UVScale = Vector2.new(1.5, 1)

-- dress..
local dress = model:FindFirstChild("dress", true)
dress.Material = Enum.Material.Sandstone

print("[Cream x TailsDoll] Model setup done...")

--- FUCKING SERVER SIDED PLAYER BUILD HOLY HELL

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
        if v:IsA("ParticleEmitter") then v:Destroy() end -- soul diamond
        if v:IsA("PointLight") then v:Destroy() end -- soul diamond
    end
    
    local src = game:GetService("ReplicatedStorage")
    src = src:FindFirstChild("Characters", true)
    src = src:FindFirstChild("TailsDoll", true)
    src = src:FindFirstChild("Skins", true)
    src = src:FindFirstChild("Default", true)

    local mdl = src:Clone()
	mdl.Parent = plrModel

	local newHrp = mdl:FindFirstChild("HumanoidRootPart", true)
	if not newHrp then mdl:Destroy() return end

	local myHead = mdl:FindFirstChildOfClass("Motor6D", true)

	for _, v in ipairs(mdl:GetDescendants()) do
        if v:IsA("Motor6D") and v.Name == "Head" then myHead = v end
		if v:IsA("Humanoid") then v:Destroy() end
		if v:IsA("Animator") then v:Destroy() end
        if v:IsA("BasePart") then
            v.CanCollide = false
        end
	end

	local hrpOffset = Vector3.new(0, -1, 0)

    --print(ogHead:GetFullName())
    --print(myHead:GetFullName())

	_G.CreamOnTailsDollSkinUpdateConnection = _G.CreamOnTailsDollSkinUpdateConnection or nil
    if _G.CreamOnTailsDollSkinUpdateConnection then
        _G.CreamOnTailsDollSkinUpdateConnection:Disconnect()
        _G.CreamOnTailsDollSkinUpdateConnection = nil
        print("[Cream x TailsDoll] Previous update connection destroyed")
    end
    _G.CreamOnTailsDollSkinUpdateConnection = game:GetService("RunService").Heartbeat:Connect(function()
		if not mdl or not mdl.Parent then
			warn("[Cream x TailsDoll] Model destroyed, restarting overlay")
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
        myHead.C0 = ogHead.C0
	end)

    return plrModel
end

local function tryUpdatePlayerModel(model)
    if model:GetAttribute("Character") ~= "TailsDoll" then return end
    _G.TailsDollModel = model
    updatePlayerModel(model.Name)
end

local function walkPlayers()
    _G.TailsDollModel = nil
    task.wait(1)
    for _, model in ipairs(workspace.Players:GetChildren()) do
    	if not model:IsA("Model") then continue end
    	if model.Name == game.Players.LocalPlayer.Name then continue end
        tryUpdatePlayerModel(model)
    end
end
    _G.CreamOnTailsDollSkinGameStateConn = _G.CreamOnTailsDollSkinGameStateConn or nil
    if _G.CreamOnTailsDollSkinGameStateConn then
        _G.CreamOnTailsDollSkinGameStateConn:Disconnect()
        _G.CreamOnTailsDollSkinGameStateConn = nil
        print("[Cream x TailsDoll] Previous game state connection destroyed")
    end
    _G.CreamOnTailsDollSkinGameStateConn = workspace:WaitForChild("GameProperties"):WaitForChild("State").Changed:Connect(function(newState)
        if newState ~= "ING" then return end
        walkPlayers()
    end)
    walkPlayers()
--

-- CharacterConn
    _G.CreamOnTailsDollSkinCharacterConn = _G.CreamOnTailsDollSkinCharacterConn or nil
    if _G.CreamOnTailsDollSkinCharacterConn then
        _G.CreamOnTailsDollSkinCharacterConn:Disconnect()
        _G.CreamOnTailsDollSkinCharacterConn = nil
        print("[Cream x TailsDoll] Previous game сharacter added connection destroyed")
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
    tryUpdatePlayerModel(game.Players.LocalPlayer.Character)
--

print("[Cream x TailsDoll] Players scanned, game state and your char being listened.")

-- custom sounds..
print("[Cream x TailsDoll] Loading custom sounds...")
local function myAsset(fileName)
    local cachePath = "cache/cream-on-doll/" .. fileName
    if isfile(cachePath) then return getcustomasset(cachePath) end
    local success, result = pcall(
        function()
            return game:HttpGet(
                "https://github.com/thaLILNIKKI/Cream.LMS-for-TailsDoll-Outcome-Memories/releases/download/"
                .. "assets/" .. fileName
            )
        end
    )
    if success and result then
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
    [106071428647005]  = myAsset("Unleashed2.mp3"),
    [87302988643016]  = myAsset("Unleashed3.mp3"),
    [131820864449998] = myAsset("Retract.mp3"), -- giggle or smth here ~

	[97101227703333] = "rbxassetid://139116822099909",  -- .Hit1]  2011x Hit2
	[93465914238963] = "rbxassetid://88164444698409",  -- Lilith.Hit2] 
	[113251186335660] = "rbxassetid://5507830073",  -- Lilith.Hit3] 
	
    [73636680793269] = "rbxassetid://77110140707717",  -- basic Swing
    [108753423324802] = "rbxassetid://77110140707717",  -- basic Swing
    [134998846301914] = "rbxassetid://77110140707717",  -- basic Swing
}

local StunSounds = {}
for i = 1, 28 do table.insert(StunSounds, myAsset("Stun" .. i .. ".mp3")) end

local DownedSounds = {}
for i = 1, 14 do table.insert(DownedSounds, myAsset("Down" .. i .. ".mp3")) end

local AttackSounds = {}
for i = 1, 8 do table.insert(AttackSounds, myAsset("Attack" .. i .. ".mp3")) end

local KillLines = {
    ["Sonic"] = { myAsset("Sonic.mp3"), myAsset("Sonic2.mp3") },
    ["Tails"] = { myAsset("Tails.mp3"),  myAsset("Tails2.mp3"),  myAsset("Tails3.mp3") },
    ["MetalSonic"] = { myAsset("MetalSonic.mp3"),  myAsset("MetalSonic2.mp3") },
    ["Amy"] = { myAsset("Amy.mp3"),  myAsset("Amy2.mp3"),  myAsset("Amy3.mp3"),  myAsset("Amy4.mp3") },
    ["Silver"] = { myAsset("Silver.mp3") },
    ["Blaze"] = { myAsset("Blaze.mp3") },
    ["Eggman"] = { myAsset("Eggman.mp3") },
    ["Cream"] = { myAsset("Cream.mp3"),  myAsset("Cream2.mp3") },
    ["Knuckles"] = { myAsset("Knuckles.mp3") }
}

print("[Cream x TailsDoll] Finished downloading custom sounds...")

_G.CreamOnTailsDollSkinDescendantAddedConnection = _G.CreamOnTailsDollSkinDescendantAddedConnection or nil
if _G.CreamOnTailsDollSkinDescendantAddedConnection then
	_G.CreamOnTailsDollSkinDescendantAddedConnection:Disconnect()
	_G.CreamOnTailsDollSkinDescendantAddedConnection = nil
	print("[Cream x TailsDoll] Previous DescendantAdded connection destroyed")
end
_G.CreamOnTailsDollSkinDescendantAddedConnection = game.DescendantAdded:Connect(function(desc)
    if desc:IsA("TextLabel") then
        local path = desc:GetFullName()
        if path:find("CoreGui.") or path:find("skibidi board") then return end
        task.wait(0.001)
        -- print(" '" .. desc.Text .. "' at " .. desc:GetFullName())
        local updating = false
        local function update()
            if updating then return end
            if desc.Text:find("TailsDoll2") then return end
            updating = true
            if desc.Text == "Tripwire" then desc.Text = " [CORRUPTED] " end
            if desc.Text == "TailsDoll" then desc.Text = "TailsDoll (2)" end
            if desc.Text == "Can you feel the sunshine?" then 
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
            updating = false
        end
        update()
        desc:GetPropertyChangedSignal("Text"):Connect(update)
    end
    if desc:IsA("Sound") then

        local id = tonumber(desc.SoundId:match("rbxassetid://(%d+)"))
        if id and assigns[id] then desc.SoundId = assigns[id] end

        local path = desc:GetFullName()

        -- if path:find("asd") or path:find("asd") then return end

        if path:find("HumanoidRootPart.") then
            -- print(path)
            if not _G.TailsDollModel then return end

            if (desc.Name:find("Retract") or desc.Name:find("Unleashed")) and _G.TailsDollModel.Waist:FindFirstChildOfClass("Sound") then
                desc.RollOffMaxDistance = desc.RollOffMaxDistance * 4
                desc.RollOffMinDistance = desc.RollOffMinDistance * 2
                desc.Volume = 1
                for _, child in ipairs(_G.TailsDollModel.Waist:GetChildren()) do
                    if child.Name:find("CreamSpeech") then 
                        desc.Volume = 0
                        desc:Stop()
                    end
                end
            end

            local player = desc.Parent.Parent
            if player:GetAttribute("Character") ~= "TailsDoll" then
                if path:find(".Blood Hit") then _G.LastHurtenPlayer = player end
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
                -- mute others to avoid word stack
                for _, child in ipairs(_G.TailsDollModel.Waist:GetChildren()) do
                    if child.Name:find("CreamSpeech") then child:Stop() end
                end
                -- kill lines
                if isDefLine and _G.LastHurtenPlayer then
                    local c = _G.LastHurtenPlayer:GetAttribute("Character")
                    if KillLines[c] then 
                        desc.SoundId = KillLines[c][math.random(1, #KillLines[c])]
                        _G.LastHurtenPlayer = nil
                    end
                end
                -- fuck that, i just recreate my sound ehhh
                local sound = Instance.new("Sound")
                sound.Name = "CreamSpeech - " .. desc.SoundId
                sound.SoundId = desc.SoundId
                sound.Volume = desc.Volume
                sound.RollOffMaxDistance = desc.RollOffMaxDistance
                sound.RollOffMinDistance = desc.RollOffMinDistance
                sound.SoundGroup = desc.SoundGroup
                sound.Parent = _G.TailsDollModel.Waist
                sound:Play()
                sound.Loaded:Wait()
                game:GetService("Debris"):AddItem(sound, sound.TimeLength + 0.5)
                -- die
                desc.Volume = 0
                desc:Stop()
            end
        end
    end
end)
