local player = game.Players.LocalPlayer

-- 2 saniye bekleme
task.wait(2)

-- GUI oluşturma
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local Frame = Instance.new("Frame")
Frame.Parent = ScreenGui
Frame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
Frame.Position = UDim2.new(0.4, 0, 0.3, 0)
Frame.Size = UDim2.new(0, 250, 0, 170)
Frame.Active = true
Frame.Draggable = true
Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 12)

-- Başlık
local Title = Instance.new("TextLabel", Frame)
Title.Text = "Sydearr Team Çöl Farm"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.BackgroundTransparency = 1
Title.Position = UDim2.new(0.5, 0, 0.1, 0)
Title.Size = UDim2.new(0, 200, 0, 20)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.AnchorPoint = Vector2.new(0.5, 0)

-- Bilgilendirme yazısı
local waitingLabel = Instance.new("TextLabel")
waitingLabel.Text = "Lütfen Bekleyiniz..."
waitingLabel.Font = Enum.Font.Gotham
waitingLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
waitingLabel.TextSize = 12
waitingLabel.BackgroundTransparency = 1
waitingLabel.Position = UDim2.new(0, 0, 0.3, 0)
waitingLabel.Size = UDim2.new(1, 0, 0.3, 0)
waitingLabel.Parent = Frame

-- Sayaç
local timerLabel = Instance.new("TextLabel")
timerLabel.Text = "00:40"
timerLabel.Font = Enum.Font.GothamBold
timerLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
timerLabel.TextScaled = true
timerLabel.BackgroundTransparency = 1
timerLabel.Position = UDim2.new(1, -80, 1, -25)
timerLabel.Size = UDim2.new(0, 80, 0, 25)
timerLabel.AnchorPoint = Vector2.new(1, 1)
timerLabel.Parent = Frame

-- Sayaç sistemi
local totalSeconds = 45
task.spawn(function()
	while totalSeconds > 0 do
		local minutes = math.floor(totalSeconds / 60)
		local seconds = totalSeconds % 60
		timerLabel.Text = string.format("%02d:%02d", minutes, seconds)
		totalSeconds -= 1
		task.wait(1)
	end
	game:GetService("TeleportService"):Teleport(3231515867, player)
end)

-- Kopyalama GUI'si
local copyGui = Instance.new("ScreenGui", game.CoreGui)
local copyFrame = Instance.new("Frame")
copyFrame.Parent = copyGui
copyFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
copyFrame.Position = UDim2.new(1, -260, 1, -100)
copyFrame.Size = UDim2.new(0, 250, 0, 60)
copyFrame.AnchorPoint = Vector2.new(0, 0)
Instance.new("UICorner", copyFrame).CornerRadius = UDim.new(0, 8)

local copyLabel = Instance.new("TextLabel", copyFrame)
copyLabel.Text = "discord.gg/Z9m5uHpR92"
copyLabel.Font = Enum.Font.Gotham
copyLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
copyLabel.BackgroundTransparency = 1
copyLabel.Position = UDim2.new(0.05, 0, 0.1, 0)
copyLabel.Size = UDim2.new(0.65, 0, 0.6, 0)
copyLabel.TextXAlignment = Enum.TextXAlignment.Left

local copyButton = Instance.new("TextButton", copyFrame)
copyButton.Text = "Kopyala"
copyButton.Font = Enum.Font.GothamBold
copyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
copyButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
copyButton.Position = UDim2.new(0.72, 0, 0.2, 0)
copyButton.Size = UDim2.new(0.23, 0, 0.6, 0)
Instance.new("UICorner", copyButton).CornerRadius = UDim.new(0, 6)

copyButton.MouseButton1Click:Connect(function()
	setclipboard("https://discord.gg/Z9m5uHpR92")
	copyButton.Text = "Kopyalandı"
	task.wait(1.5)
	copyButton.Text = "Kopyala"
end)

-- Ana sistem
task.spawn(function()
	while not game:IsLoaded() do task.wait() end

	local hedefOyunID = 6912372358
	if game.PlaceId ~= hedefOyunID then
		game:GetService("StarterGui"):SetCore("SendNotification", {
			Title = "Uyarı",
			Text = "Doğru oyuna ışınlanıyorsun...",
			Duration = 5
		})
		game:GetService("TeleportService"):Teleport(hedefOyunID, player, {returningFarm = true})
		return
	end

	game:GetService("StarterGui"):SetCore("SendNotification", {
		Title = "Bilgi",
		Text = "Helikopterin inmesi bekleniyor...",
		Duration = 6
	})

	-- Güncellenmiş bekleme süresi: 32 saniye
	task.wait(32)

	getgenv().G = true
	getgenv().Creator = 'https://discord.gg/B3HqPPzFYr - HalloweenGaster'
	task.spawn(function()
		while getgenv().G and getgenv().Creator == 'https://discord.gg/B3HqPPzFYr - HalloweenGaster' do
			wait(0.9)
			sethiddenproperty(player, "SimulationRadius", 112412400000)
			sethiddenproperty(player, "MaxSimulationRadius", 112412400000)
			for _, d in pairs(workspace:GetDescendants()) do
				if d:IsA("Humanoid") and d.Parent.Name ~= player.Name then
					d.Health = 0
				end
			end
		end
	end)

	local character = player.Character or player.CharacterAdded:Wait()
	local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
	local humanoid = character:WaitForChild("Humanoid")

	local function enableFly()
		humanoid.PlatformStand = true
	end
	local function disableFly()
		humanoid.PlatformStand = false
		humanoidRootPart.Velocity = Vector3.zero
	end

	local function flyToTarget(targetPos)
		enableFly()
		local aboveTarget = Vector3.new(targetPos.X, targetPos.Y + 60, targetPos.Z)
		while true do
			local distance = (humanoidRootPart.Position - aboveTarget).Magnitude
			if distance < 8 then break end
			local direction = (aboveTarget - humanoidRootPart.Position).Unit
			humanoidRootPart.Velocity = direction * 400
			task.wait(0.05)
		end
		humanoidRootPart.CFrame = CFrame.new(targetPos)
		disableFly()
	end

	local hedefKonum = Vector3.new(319.66, 3.63, -4.36)
	flyToTarget(hedefKonum)

	-- Ek olarak 3 saniye daha bekle
	task.wait(3)
end)
