-- BrainrotBase: base plots, the income tick, and the base lock. When a
-- player joins they get the next free plot, its floor turns their green
-- and its sign takes their name; every second each brainrot standing on
-- a base pays its dollars per second, and the client HUD is synced with
-- the new totals. The lock is the defence against stealing.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("BrainrotConfig"))
local Remotes = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("BrainrotRemotes"))
local State = require(script.Parent:WaitForChild("BrainrotState"))

local remotes = Remotes.getRemotes()
local syncEvent = remotes:WaitForChild("BrainrotSync")

local function paintPlotFloor(plotIndex, owned)
	local bay = Workspace:WaitForChild("BrainrotBay")
	local plot = bay:FindFirstChild("BasePlot" .. plotIndex)
	if not plot then
		return
	end
	local floor = plot:FindFirstChild("PlotFloor")
	if floor then
		floor.Color = owned and Config.Palette.PlotOwn or Config.Palette.PlotFloor
	end
end

local function namePlotSign(plotIndex, ownerName)
	local bay = Workspace:WaitForChild("BrainrotBay")
	local plot = bay:FindFirstChild("BasePlot" .. plotIndex)
	if not plot then
		return
	end
	local signPart = plot:FindFirstChild("SignAnchor")
	local sign = signPart and signPart:FindFirstChild("PlotSign")
	local label = sign and sign:FindFirstChild("PlotName")
	if label then
		label.Text = "BASE " .. plotIndex .. "\n" .. ownerName
	end
end

local function setupPlayer(player)
	local playerState = State.getPlayerState(player)
	local plotIndex = State.assignPlot(player)
	if plotIndex ~= 0 then
		paintPlotFloor(plotIndex, true)
		namePlotSign(plotIndex, player.DisplayName)
	end

	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player
	local cash = Instance.new("IntValue")
	cash.Name = "Cash"
	cash.Value = playerState.Cash
	cash.Parent = leaderstats
	local earned = Instance.new("IntValue")
	earned.Name = "Earned"
	earned.Value = 0
	earned.Parent = leaderstats

	syncEvent:FireClient(player, State.syncSnapshot(playerState))
end

Players.PlayerAdded:Connect(setupPlayer)
for _, player in ipairs(Players:GetPlayers()) do
	setupPlayer(player)
end

Players.PlayerRemoving:Connect(function(player)
	local playerState = State.Players[player]
	if playerState and playerState.PlotIndex ~= 0 then
		paintPlotFloor(playerState.PlotIndex, false)
		namePlotSign(playerState.PlotIndex, "")
	end
	State.removePlayer(player)
end)

task.spawn(function()
	while true do
		task.wait(1)
		for _, player in ipairs(Players:GetPlayers()) do
			local playerState = State.Players[player]
			if playerState then
				local income = State.recomputeIncome(playerState)
				if income > 0 then
					playerState.Cash += income
					playerState.TotalEarned += income
					local leaderstats = player:FindFirstChild("leaderstats")
					if leaderstats then
						local cash = leaderstats:FindFirstChild("Cash")
						if cash then
							cash.Value = math.floor(playerState.Cash)
						end
						local earned = leaderstats:FindFirstChild("Earned")
						if earned then
							earned.Value = math.floor(playerState.TotalEarned)
						end
					end
				end
				local snapshot = State.syncSnapshot(playerState)
				snapshot.StealLeft = State.stealSecondsLeft(player)
				syncEvent:FireClient(player, snapshot)
			end
		end
	end
end)
