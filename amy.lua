local SoundService = game:GetService("SoundService")
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")

local AMY_SOUNDS = {
    "rbxassetid://140001780364761",
    "rbxassetid://102039585700078",
    "rbxassetid://94286709781934",
    "rbxassetid://131050409007398",
    "rbxassetid://109414274716312",
    "rbxassetid://138002390180472",
}

local sfxGroup = game.ReplicatedStorage.ClientAssets.Sounds.sfx

local function iAmAmy()
    local playersFolder = workspace:FindFirstChild("Players")
    if not playersFolder then return false end
    local me = playersFolder:FindFirstChild(Players.LocalPlayer.Name)
    if not me then return false end
    return me:GetAttribute("Character") == "Amy"
end

local function findMyRoot()
    local playersFolder = workspace:FindFirstChild("Players")
    if not playersFolder then return nil end
    local me = playersFolder:FindFirstChild(Players.LocalPlayer.Name)
    if not me then return nil end
    return me:FindFirstChild("HumanoidRootPart") or me
end

local function playAmy()
    local parent = findMyRoot() or workspace
    local sound = Instance.new("Sound")
    sound.SoundId = AMY_SOUNDS[math.random(1, #AMY_SOUNDS)]
    sound.Volume = 1
    sound.RollOffMaxDistance = 255
    sound.RollOffMinDistance = 67
    sound.SoundGroup = sfxGroup
    sound.Parent = parent
    sound:Play()
    Debris:AddItem(sound, 10)
end

local Remotes = game:GetService("ReplicatedStorage"):WaitForChild("Remotes")
Remotes:WaitForChild("ScoreEvent").OnClientEvent:Connect(function(action, ...)
    if action ~= "Stuns" then return end
    if not iAmAmy() then return end
    playAmy()
end)

      print("voces de amy cargadas")
