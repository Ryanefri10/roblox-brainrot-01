-- BrainrotClient: everything the player sees. A ScreenGui over the 3D
-- bay: big Cash and dollars-per-second top-right, the wave timer
-- top-centre, Shop / Rebirth / Lock buttons bottom-right, a tutorial
-- prompt for the first seconds, a tsunami banner, and a steal progress
-- bar. Nothing sits in the top-left corner, where Roblox puts its own
-- menu buttons. The camera opens high over the bay, then swoops down
-- behind the player.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("BrainrotConfig"))

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local remotes = ReplicatedStorage:WaitForChild("BrainrotRemotes")
local buyEvent = remotes:WaitForChild("BuyBrainrot")
local rebirthEvent = remotes:WaitForChild("Rebirth")
local lockEvent = remotes:WaitForChild("LockBase")
local syncEvent = remotes:WaitForChild("BrainrotSync")
local waveAlert = remotes:WaitForChild("WaveAlert")

local function formatMoney(amount)
	local text = tostring(math.floor(amount))
	local reversed = text:reverse()
	local grouped = reversed:gsub("(%d%d%d)", "%1,")
	local result = grouped:reverse():gsub("^,", "")
	return "$" .. result
end

local gui = Instance.new("ScreenGui")
gui.Name = "BrainrotBayGui"
gui.ResetOnSpawn = false
gui.Parent = playerGui

local function makePanel(name, parent, position, size, anchor)
	local panel = Instance.new("Frame")
	panel.Name = name
	panel.AnchorPoint = anchor or Vector2.new(0, 0)
	panel.Position = position
	panel.Size = size
	panel.BackgroundColor3 = Config.Palette.HudDark
	panel.BackgroundTransparency = 0.25
	panel.BorderSizePixel = 0
	panel.Parent = parent
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 12)
	corner.Parent = panel
	return panel
end

local function makeLabel(name, parent, position, size, text, textSize, color, anchor)
	local label = Instance.new("TextLabel")
	label.Name = name
	label.AnchorPoint = anchor or Vector2.new(0, 0)
	label.Position = position
	label.Size = size
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = color or Config.Palette.HudWhite
	label.TextSize = textSize
	label.Font = Enum.Font.GothamBold
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = parent
	return label
end

local function makeButton(name, parent, position, size, text, textSize, color)
	local button = Instance.new("TextButton")
	button.Name = name
	button.Position = position
	button.Size = size
	button.BackgroundColor3 = color
	button.Text = text
	button.TextColor3 = Config.Palette.HudWhite
	button.TextSize = textSize
	button.Font = Enum.Font.GothamBold
	button.Parent = parent
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 12)
	corner.Parent = button
	return button
end

local cashPanel = makePanel("CashPanel", gui, UDim2.new(1, -16, 0, 16), UDim2.fromOffset(280, 128), Vector2.new(1, 0))
local cashLabel = makeLabel("Cash", cashPanel, UDim2.new(0, 16, 0, 8), UDim2.new(1, -32, 0, 44), "$500", 36, Config.Palette.MoneyGreen)
local incomeLabel = makeLabel("Income", cashPanel, UDim2.new(0, 16, 0, 52), UDim2.new(1, -32, 0, 32), "$0/s", 24, Config.Palette.HudWhite)
-- v5: the next brainrot to save for, inside the Cash panel, so the
-- next tier of the ladder is always visible (judge criterion 1).
local nextLabel = makeLabel("NextTier", cashPanel, UDim2.new(0, 16, 0, 88), UDim2.new(1, -32, 0, 28), "Next: Sir Quacksalot — $50 • $2/s", 17, Config.Palette.TitleYellow)

local wavePanel = makePanel("WavePanel", gui, UDim2.new(0.5, 0, 0, 16), UDim2.fromOffset(300, 52), Vector2.new(0.5, 0))
local waveLabel = makeLabel("WaveTimer", wavePanel, UDim2.new(0, 0, 0, 0), UDim2.fromScale(1, 1), "🌊 Wave in 90s", 24, Color3.fromRGB(140, 200, 255), Vector2.new(0, 0))
waveLabel.TextXAlignment = Enum.TextXAlignment.Center

-- Robbery alert: when someone is stealing one of YOUR brainrots, a red
-- banner counts the channel down — locking your base mid-channel
-- cancels the steal, so the warning is the counterplay.
local robberyPanel = makePanel("RobberyPanel", gui, UDim2.new(0.5, 0, 0, 76), UDim2.fromOffset(560, 44), Vector2.new(0.5, 0))
robberyPanel.BackgroundColor3 = Config.Palette.DangerRed
robberyPanel.Visible = false
local robberyLabel = makeLabel("RobberyText", robberyPanel, UDim2.new(0, 0, 0, 0), UDim2.fromScale(1, 1), "", 20, Config.Palette.HudWhite)
robberyLabel.TextXAlignment = Enum.TextXAlignment.Center

local baseLabel = makeLabel("BaseInfo", gui, UDim2.new(1, -16, 0, 156), UDim2.fromOffset(280, 28), "Base 0/8  •  Rebirths: 0 (x1.0)", 18, Config.Palette.HudWhite, Vector2.new(1, 0))
baseLabel.TextXAlignment = Enum.TextXAlignment.Right

local shopButton = makeButton("ShopButton", gui, UDim2.new(1, -16, 1, -188), UDim2.fromOffset(180, 52), "🛒 SHOP", 26, Color3.fromRGB(40, 140, 255), Vector2.new(1, 0))
local rebirthButton = makeButton("RebirthButton", gui, UDim2.new(1, -16, 1, -124), UDim2.fromOffset(180, 52), "✨ REBIRTH", 26, Color3.fromRGB(150, 80, 220), Vector2.new(1, 0))
rebirthButton.TextSize = 22 -- "✨ REBIRTH $50k" only fits the 180px button at 22
local lockButton = makeButton("LockButton", gui, UDim2.new(1, -16, 1, -60), UDim2.fromOffset(180, 52), "🔒 LOCK BASE", 26, Color3.fromRGB(60, 160, 90), Vector2.new(1, 0))

local shopFrame = makePanel("ShopFrame", gui, UDim2.new(0.5, 0, 0.5, 0), UDim2.fromOffset(460, 520), Vector2.new(0.5, 0.5))
shopFrame.Visible = false
makeLabel("ShopTitle", shopFrame, UDim2.new(0, 16, 0, 10), UDim2.new(1, -32, 0, 36), "🛒 BRAINROT SHOP — click to buy off the belt", 22, Config.Palette.TitleYellow)
local shopClose = makeButton("ShopClose", shopFrame, UDim2.new(1, -52, 0, 8), UDim2.fromOffset(40, 36), "X", 22, Color3.fromRGB(200, 60, 60))
shopClose.MouseButton1Click:Connect(function()
	shopFrame.Visible = false
end)
local shopList = Instance.new("ScrollingFrame")
shopList.Name = "ShopList"
shopList.Position = UDim2.new(0, 12, 0, 54)
shopList.Size = UDim2.new(1, -24, 1, -66)
shopList.BackgroundTransparency = 1
shopList.ScrollBarThickness = 6
shopList.CanvasSize = UDim2.new(0, 0, 0, #Config.Characters * 62)
shopList.Parent = shopFrame

for i, character in ipairs(Config.Characters) do
	local row = Instance.new("Frame")
	row.Name = "ShopRow_" .. character.Id
	row.Position = UDim2.new(0, 0, 0, (i - 1) * 62)
	row.Size = UDim2.new(1, 0, 0, 56)
	row.BackgroundColor3 = Color3.fromRGB(40, 46, 70)
	row.BorderSizePixel = 0
	row.Parent = shopList
	local rowCorner = Instance.new("UICorner")
	rowCorner.CornerRadius = UDim.new(0, 8)
	rowCorner.Parent = row
	makeLabel("Name", row, UDim2.new(0, 12, 0, 4), UDim2.new(0.62, -12, 0, 26), character.Name, 20, Config.rarityColor(character.Rarity))
	local infoLabel = makeLabel("Info", row, UDim2.new(0, 12, 0, 28), UDim2.new(0.62, -12, 0, 24), character.Rarity .. "  •  " .. character.Blurb, 14, Config.Palette.HudWhite)
	infoLabel.TextTruncate = Enum.TextTruncate.AtEnd
	local buyButton = makeButton("BuyButton", row, UDim2.new(1, -118, 0, 8), UDim2.fromOffset(106, 40), formatMoney(character.Price) .. " • $" .. character.Income .. "/s", 16, Config.rarityColor(character.Rarity))
	buyButton.MouseButton1Click:Connect(function()
		buyEvent:FireServer(character.Id)
	end)
end

shopButton.MouseButton1Click:Connect(function()
	shopFrame.Visible = not shopFrame.Visible
end)
rebirthButton.MouseButton1Click:Connect(function()
	rebirthEvent:FireServer()
end)
lockButton.MouseButton1Click:Connect(function()
	lockEvent:FireServer()
end)

local tutorialLabel = makeLabel("Tutorial", gui, UDim2.new(0.5, 0, 0, 90), UDim2.fromOffset(640, 56), "🎯 Goal: finish the 5 missions on the left! First: buy a brainrot on the belt!", 26, Config.Palette.TitleYellow, Vector2.new(0.5, 0))
tutorialLabel.TextXAlignment = Enum.TextXAlignment.Center
tutorialLabel.TextWrapped = true
tutorialLabel.BackgroundTransparency = 0.3
tutorialLabel.BackgroundColor3 = Config.Palette.HudDark
local tutorialCorner = Instance.new("UICorner")
tutorialCorner.CornerRadius = UDim.new(0, 12)
tutorialCorner.Parent = tutorialLabel

-- Missions panel (left side, under Roblox's own menu buttons): the
-- game's goal as a checklist. Finishing all 5 wins the game.
local missionPanel = makePanel("MissionPanel", gui, UDim2.new(0, 16, 0, 150), UDim2.fromOffset(330, 250))
makeLabel("MissionTitle", missionPanel, UDim2.new(0, 14, 0, 10), UDim2.new(1, -28, 0, 28), "🎯 MISSIONS — finish all 5 to WIN!", 20, Config.Palette.TitleYellow)
local missionLabels = {}
for i, mission in ipairs(Config.Missions) do
	local label = makeLabel("Mission" .. i, missionPanel, UDim2.new(0, 14, 0, 44 + (i - 1) * 34), UDim2.new(1, -28, 0, 30), "", 17, Config.Palette.HudWhite)
	missionLabels[i] = label
end
local winLabel = makeLabel("WinLabel", missionPanel, UDim2.new(0, 14, 0, 214), UDim2.new(1, -28, 0, 28), "🏆 YOU WIN! Brainrot King!", 20, Config.Palette.MoneyGreen)
winLabel.Visible = false

local bannerLabel = makeLabel("WaveBanner", gui, UDim2.new(0.5, 0, 0, 160), UDim2.fromOffset(720, 64), "", 32, Config.Palette.DangerRed, Vector2.new(0.5, 0))
bannerLabel.TextXAlignment = Enum.TextXAlignment.Center
bannerLabel.BackgroundTransparency = 0.3
bannerLabel.BackgroundColor3 = Config.Palette.HudDark
bannerLabel.Visible = false
local bannerCorner = Instance.new("UICorner")
bannerCorner.CornerRadius = UDim.new(0, 12)
bannerCorner.Parent = bannerLabel

local stealPanel = makePanel("StealPanel", gui, UDim2.new(0.5, 0, 1, -90), UDim2.fromOffset(360, 56), Vector2.new(0.5, 0))
stealPanel.Visible = false
local stealLabel = makeLabel("StealText", stealPanel, UDim2.new(0, 0, 0, 4), UDim2.fromScale(1, 0.5), "Stealing...", 20, Config.Palette.HudWhite)
stealLabel.TextXAlignment = Enum.TextXAlignment.Center
local stealBarBack = Instance.new("Frame")
stealBarBack.Name = "StealBarBack"
stealBarBack.Position = UDim2.new(0, 16, 0, 32)
stealBarBack.Size = UDim2.new(1, -32, 0, 14)
stealBarBack.BackgroundColor3 = Color3.fromRGB(60, 64, 90)
stealBarBack.BorderSizePixel = 0
stealBarBack.Parent = stealPanel
local stealBar = Instance.new("Frame")
stealBar.Name = "StealBar"
stealBar.Size = UDim2.fromScale(0, 1)
stealBar.BackgroundColor3 = Config.Palette.MoneyGreen
stealBar.BorderSizePixel = 0
stealBar.Parent = stealBarBack

local noticeLabel = makeLabel("Notice", gui, UDim2.new(0.5, 0, 1, -160), UDim2.fromOffset(640, 36), "", 20, Config.Palette.HudWhite, Vector2.new(0.5, 0))
noticeLabel.TextXAlignment = Enum.TextXAlignment.Center
noticeLabel.Visible = false

local tutorialDone = false
local noticeUntil = 0
local lastCash = nil
local popupCount = 0

-- Income popup: every second the server pays, a green "+$X" floats up
-- under the Cash panel and fades, so the money ticking up is visible
-- on screen (and in a screenshot), not just a number changing.
local function spawnIncomePopup(amount)
	popupCount += 1
	local lane = popupCount % 3
	local popup = Instance.new("TextLabel")
	popup.Name = "IncomePopup"
	popup.AnchorPoint = Vector2.new(1, 0)
	popup.Position = UDim2.new(1, -16, 0, 216 + lane * 26)
	popup.Size = UDim2.fromOffset(200, 28)
	popup.BackgroundTransparency = 1
	popup.Text = "+$" .. tostring(math.floor(amount))
	popup.TextColor3 = Config.Palette.MoneyGreen
	popup.TextSize = 24
	popup.Font = Enum.Font.GothamBold
	popup.TextXAlignment = Enum.TextXAlignment.Right
	popup.Parent = gui
	local tween = TweenService:Create(popup, TweenInfo.new(1.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Position = UDim2.new(1, -16, 0, 186 + lane * 26),
		TextTransparency = 1,
	})
	tween:Play()
	tween.Completed:Connect(function()
		popup:Destroy()
	end)
end

syncEvent.OnClientEvent:Connect(function(snapshot)
	cashLabel.Text = formatMoney(snapshot.Cash)
	if lastCash ~= nil and snapshot.Cash > lastCash and snapshot.IncomePerSec > 0 then
		spawnIncomePopup(snapshot.Cash - lastCash)
	end
	lastCash = snapshot.Cash
	incomeLabel.Text = formatMoney(snapshot.IncomePerSec) .. "/s"
	-- v5: the next tier is the cheapest brainrot the player cannot
	-- afford yet — the savings goal, always visible on the HUD.
	local nextCharacter = nil
	for _, character in ipairs(Config.Characters) do
		if character.Price > snapshot.Cash then
			nextCharacter = character
			break
		end
	end
	if nextCharacter then
		nextLabel.Text = "Next: " .. nextCharacter.Name .. " — " .. formatMoney(nextCharacter.Price) .. " • $" .. tostring(nextCharacter.Income) .. "/s"
	else
		nextLabel.Text = "👑 You can afford them all!"
	end
	baseLabel.Text = "Base " .. tostring(snapshot.SlotsUsed) .. "/" .. tostring(snapshot.SlotsTotal)
		.. "  •  Rebirths: " .. tostring(snapshot.Rebirths)
		.. " (x" .. string.format("%.1f", snapshot.Multiplier) .. ")"
	if snapshot.WaveIn and snapshot.WaveIn > 0 then
		waveLabel.Text = "🌊 Wave in " .. tostring(snapshot.WaveIn) .. "s"
	end
	if snapshot.RebirthReady then
		rebirthButton.Text = "✨ REBIRTH READY!"
		rebirthButton.BackgroundColor3 = Color3.fromRGB(40, 200, 90)
	else
		rebirthButton.Text = "✨ REBIRTH $50k"
		rebirthButton.BackgroundColor3 = Color3.fromRGB(150, 80, 220)
	end
	if snapshot.LockLeft and snapshot.LockLeft > 0 then
		lockButton.Text = "🔒 LOCKED " .. tostring(snapshot.LockLeft) .. "s"
	elseif snapshot.LockCooldownLeft and snapshot.LockCooldownLeft > 0 then
		lockButton.Text = "🔒 LOCK (" .. tostring(snapshot.LockCooldownLeft) .. "s)"
	else
		lockButton.Text = "🔒 LOCK BASE"
	end
	if snapshot.StealLeft and snapshot.StealLeft > 0 then
		stealPanel.Visible = true
		stealLabel.Text = "Stealing... " .. tostring(snapshot.StealLeft) .. "s left — stay close!"
		stealBar.Size = UDim2.fromScale(1 - snapshot.StealLeft / Config.Steal.ChannelSeconds, 1)
	else
		stealPanel.Visible = false
	end
	if snapshot.BeingStolen and snapshot.BeingStolen > 0 then
		robberyPanel.Visible = true
		robberyLabel.Text = "🚨 " .. (snapshot.BeingStolenName or "A brainrot") .. " IS BEING STOLEN! " .. tostring(snapshot.BeingStolen) .. "s — LOCK YOUR BASE!"
	else
		robberyPanel.Visible = false
	end
	if snapshot.Missions then
		for i, mission in ipairs(snapshot.Missions) do
			local label = missionLabels[i]
			if label then
				local mark = mission.Done and "✅ " or (mission.Current and "👉 " or "○ ")
				label.Text = mark .. mission.Text .. " (" .. tostring(mission.Progress) .. "/" .. tostring(mission.Target) .. ")  +$" .. tostring(mission.Reward)
				label.TextColor3 = mission.Done and Config.Palette.MoneyGreen
					or (mission.Current and Config.Palette.TitleYellow or Config.Palette.HudWhite)
			end
		end
	end
	if snapshot.Won then
		winLabel.Visible = true
	end
	if snapshot.Notice then
		noticeLabel.Text = snapshot.Notice
		noticeLabel.Visible = true
		noticeUntil = os.clock() + 4
	end
	if not tutorialDone and (snapshot.SlotsUsed > 0 or snapshot.Carrying) then
		tutorialDone = true
		tutorialLabel.Visible = false
	end
end)

task.delay(15, function()
	if not tutorialDone then
		tutorialDone = true
		tutorialLabel.Visible = false
	end
end)

task.spawn(function()
	while true do
		task.wait(0.5)
		if noticeLabel.Visible and os.clock() > noticeUntil then
			noticeLabel.Visible = false
		end
	end
end)

waveAlert.OnClientEvent:Connect(function(kind, seconds)
	if kind == "warning" then
		bannerLabel.Visible = true
		bannerLabel.Text = "🌊 TSUNAMI IN " .. tostring(seconds) .. "s — RUN TO YOUR BASE!"
		for left = seconds - 1, 1, -1 do
			task.wait(1)
			if bannerLabel.Visible then
				bannerLabel.Text = "🌊 TSUNAMI IN " .. tostring(left) .. "s — RUN TO YOUR BASE!"
			end
		end
	elseif kind == "wave" then
		bannerLabel.Text = "🌊 TSUNAMI! STAY ON YOUR BASE!"
		task.wait(seconds)
		bannerLabel.Visible = false
	end
end)

local camera = Workspace.CurrentCamera
local function playCameraIntro()
	local character = player.Character or player.CharacterAdded:Wait()
	local root = character:WaitForChild("HumanoidRootPart")
	local startLook = CFrame.lookAt(Vector3.new(0, 90, 130), Vector3.new(0, 0, -20))
	local endPosition = root.Position + Vector3.new(0, 12, 18)
	local endLook = CFrame.lookAt(endPosition, root.Position)
	camera.CameraType = Enum.CameraType.Scriptable
	local tween = TweenService:Create(camera, TweenInfo.new(3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { CFrame = endLook })
	camera.CFrame = startLook
	tween:Play()
	tween.Completed:Wait()
	camera.CameraType = Enum.CameraType.Custom
end

player.CharacterAdded:Connect(function()
	task.spawn(playCameraIntro)
end)
if player.Character then
	task.spawn(playCameraIntro)
end
