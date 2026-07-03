-- Aguarda o jogo carregar o básico para evitar que o script trave no início
if not game:IsLoaded() then
	game.Loaded:Wait()
end

-------------------------------------------------
-- NOTIFICAÇÃO DE CRÉDITOS (ATUALIZADA)
-------------------------------------------------
pcall(function()
	game:GetService("StarterGui"):SetCore("SendNotification", {
		Title = "Script Ativado",
		Text = "Feito por Pedro_pvp o goat",
		Duration = 5
	})
end)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VoteRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Voted")
local Players = game:GetService("Players")

local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")

-- Lista de personagens
local characters = {"Sonic", "Amy", "Eggman", "Cream", "Tails", "Knuckles", "MetalSonic", "Blaze", "Silver"}

-------------------------------------------------
-- CONFIGURAÇÃO DE IMAGENS (FORMATO DE MINIATURA SEGURO)
-------------------------------------------------
local characterImages = {
	["Sonic"]      = "rbxthumb://type=Asset&id=90698485266685&w=150&h=150",
	["Amy"]        = "rbxthumb://type=Asset&id=139906522593901&w=150&h=150",
	["MetalSonic"] = "rbxthumb://type=Asset&id=125424559322589&w=150&h=150",
	["Eggman"]     = "rbxthumb://type=Asset&id=129053897954881&w=150&h=150",
	["Knuckles"]   = "rbxthumb://type=Asset&id=99077689372417&w=150&h=150",
	["Tails"]      = "rbxthumb://type=Asset&id=77385974180985&w=150&h=150",
	["Cream"]      = "rbxthumb://type=Asset&id=74140125964289&w=150&h=150",
	["Blaze"]      = "rbxthumb://type=Asset&id=139583952022775&w=150&h=150",
	["Silver"]     = "rbxthumb://type=Asset&id=90790764418649&w=150&h=150"
}

local currentIndex = 0
local selectedCharacter = nil
local autoPickEnabled = false

-- GUI (Protegida)
local gui = Instance.new("ScreenGui")
gui.Name = "VoteMenuByPedro"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true 

local success = pcall(function()
	gui.Parent = game:GetService("CoreGui")
end)
if not success or not gui.Parent then
	gui.Parent = playerGui
end

-------------------------------------------------
-- BOTÃO "PANEL"
-------------------------------------------------
local panelBtn = Instance.new("TextButton")
panelBtn.Parent = gui
panelBtn.Size = UDim2.new(0, 75, 0, 32) 
panelBtn.Position = UDim2.new(0, 220, 0, 4) 
panelBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 15) 
panelBtn.BorderSizePixel = 0
panelBtn.Text = "Panel"
panelBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
panelBtn.TextSize = 13 
panelBtn.Font = Enum.Font.GothamBold 
panelBtn.ZIndex = 5 

local panelCorner = Instance.new("UICorner")
panelCorner.CornerRadius = UDim.new(0, 8)
panelCorner.Parent = panelBtn

-------------------------------------------------
-- CAIXINHA DE OPÇÕES
-------------------------------------------------
local optionsContainer = Instance.new("Frame")
optionsContainer.Parent = gui
optionsContainer.Size = UDim2.new(0, 165, 0, 95) 
optionsContainer.Position = UDim2.new(0, 220, 0, 42) 
optionsContainer.BackgroundColor3 = Color3.fromRGB(15, 15, 15) 
optionsContainer.BorderSizePixel = 0
optionsContainer.Visible = false 
optionsContainer.ZIndex = 5

local containerCorner = Instance.new("UICorner")
containerCorner.CornerRadius = UDim.new(0, 8)
containerCorner.Parent = optionsContainer

-- Botão de Selecionar Personagem (Fundo Branco)
local selectBtn = Instance.new("TextButton")
selectBtn.Parent = optionsContainer
selectBtn.Size = UDim2.new(1, -16, 0, 34)
selectBtn.Position = UDim2.new(0, 8, 0, 10)
selectBtn.Text = "" 
selectBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255) 
selectBtn.BorderSizePixel = 0
selectBtn.ZIndex = 6

local btnCorner1 = Instance.new("UICorner")
btnCorner1.CornerRadius = UDim.new(0, 6)
btnCorner1.Parent = selectBtn

-- CONTAINER INTERNO
local contentFrame = Instance.new("Frame")
contentFrame.Parent = selectBtn
contentFrame.Size = UDim2.new(1, 0, 1, 0)
contentFrame.BackgroundTransparency = 1
contentFrame.ZIndex = 7

local listLayout = Instance.new("UIListLayout")
listLayout.Parent = contentFrame
listLayout.FillDirection = Enum.FillDirection.Horizontal
listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center 
listLayout.VerticalAlignment = Enum.VerticalAlignment.Center
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Padding = UDim.new(0, 6) 

-- ÍCONE DO PERSONAGEM
local charIcon = Instance.new("ImageLabel")
charIcon.Parent = contentFrame
charIcon.Size = UDim2.new(0, 24, 0, 24)
charIcon.BackgroundTransparency = 1
charIcon.Image = "" 
charIcon.Visible = false
charIcon.LayoutOrder = 1
charIcon.ZIndex = 8

local iconCorner = Instance.new("UICorner")
iconCorner.CornerRadius = UDim.new(0, 4)
iconCorner.Parent = charIcon

-- TEXTO DO PERSONAGEM (Letras Pretas)
local charText = Instance.new("TextLabel")
charText.Parent = contentFrame
charText.Size = UDim2.new(0, 0, 1, 0)
charText.AutomaticSize = Enum.AutomaticSize.X 
charText.BackgroundTransparency = 1
charText.Text = "SELECIONAR"
charText.TextColor3 = Color3.fromRGB(0, 0, 0) 
charText.TextSize = 11
charText.Font = Enum.Font.GothamBold
charText.LayoutOrder = 2
charText.ZIndex = 8

-- Botão do Auto Pick
local autoBtn = Instance.new("TextButton")
autoBtn.Parent = optionsContainer
autoBtn.Size = UDim2.new(1, -16, 0, 34)
autoBtn.Position = UDim2.new(0, 8, 0, 50)
autoBtn.Text = "AUTO PICK: OFF"
autoBtn.BackgroundColor3 = Color3.fromRGB(140, 0, 0)
autoBtn.TextColor3 = Color3.new(1, 1, 1)
autoBtn.TextSize = 11
autoBtn.Font = Enum.Font.GothamBold
autoBtn.ZIndex = 6

local btnCorner2 = Instance.new("UICorner")
btnCorner2.CornerRadius = UDim.new(0, 6)
btnCorner2.Parent = autoBtn

-------------------------------------------------
-- INTERAÇÕES
-------------------------------------------------
panelBtn.MouseButton1Click:Connect(function()
	optionsContainer.Visible = not optionsContainer.Visible
end)

selectBtn.MouseButton1Click:Connect(function()
	currentIndex = (currentIndex % #characters) + 1
	selectedCharacter = characters[currentIndex]
	
	charText.Text = string.upper(selectedCharacter)
	
	local thumbUrl = characterImages[selectedCharacter]
	if thumbUrl and thumbUrl ~= "" then
		charIcon.Image = thumbUrl
		charIcon.Visible = true
	else
		charIcon.Image = ""
		charIcon.Visible = false
	end
end)

autoBtn.MouseButton1Click:Connect(function()
	autoPickEnabled = not autoPickEnabled
	if autoPickEnabled then
		autoBtn.Text = "AUTO PICK: ON"
		autoBtn.BackgroundColor3 = Color3.fromRGB(0, 140, 0)
	else
		autoBtn.Text = "AUTO PICK: OFF"
		autoBtn.BackgroundColor3 = Color3.fromRGB(140, 0, 0)
	end
end)

-------------------------------------------------
-- LOGICA DE AUTO PICK DE 4 SEGUNDOS
-------------------------------------------------
task.spawn(function()
	while true do
		task.wait(0.3)
		
		if autoPickEnabled and selectedCharacter then
			local gameUI = playerGui:FindFirstChild("GameUI")
			local charSelect = gameUI and gameUI:FindFirstChild("CharSelect")
			
			if charSelect and charSelect.Visible == true then
				task.wait(4)
				
				local freshUI = playerGui:FindFirstChild("GameUI")
				local freshSelect = freshUI and freshUI:FindFirstChild("CharSelect")
				
				if autoPickEnabled and selectedCharacter and freshSelect and freshSelect.Visible == true then
					pcall(function()
						VoteRemote:FireServer(selectedCharacter)
					end)
				end
				
				repeat 
					task.wait(0.5)
					local checkUI = playerGui:FindFirstChild("GameUI")
					charSelect = checkUI and checkUI:FindFirstChild("CharSelect")
				until not charSelect or charSelect.Visible == false or not autoPickEnabled
			end
		end
	end
end)
