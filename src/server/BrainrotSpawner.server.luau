-- BrainrotSpawner: the Brainrot Belt itself. Every few seconds a new
-- brainrot arrives at the dock and walks slowly down the belt; bought
-- ones follow their owner home, and unbought ones sail off the end and
-- despawn. One loop moves every brainrot, so the belt, the walk home and
-- the base all stay in step.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("BrainrotConfig"))
local Models = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("BrainrotModels"))
local Remotes = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("BrainrotRemotes"))
local State = require(script.Parent:WaitForChild("BrainrotState"))

local remotes = Remotes.getRemotes()
local goldenAlert = remotes:WaitForChild("GoldenAlert")

local BeltFolder = Instance.new("Folder")
BeltFolder.Name = "BeltBrainrots"
BeltFolder.Parent = Workspace

local function slotPosition(plotIndex, slot)
	local center = Config.plotCenter(plotIndex)
	local row = math.floor((slot - 1) / 4)
	local col = (slot - 1) % 4
	return Vector3.new(center.X + (col - 1.5) * 4, Config.Plots.FloorTopY + 0.5, center.Z + (row - 0.5) * 4)
end

local function placeModel(model, groundPosition, facing, scale)
	local pivotY = groundPosition.Y + 2.2 * (scale or 1)
	model:PivotTo(CFrame.new(groundPosition.X, pivotY, groundPosition.Z) * CFrame.Angles(0, facing, 0))
end

local function attachBuyClick(record)
	local click = Instance.new("ClickDetector")
	click.Name = "BuyClick"
	click.MaxActivationDistance = 32
	click.Parent = record.Model.PrimaryPart
	click.MouseClick:Connect(function(player)
		State.buyBrainrot(player, record.Id)
	end)
end

local function spawnBrainrotOnBelt()
	local character = Config.rollCharacter()
	-- v7 Golden Rush: while a rush is live every spawn is guaranteed
	-- Golden (2x income), so the whole belt turns gold at once; the
	-- random Gold mutation still rolls as usual outside a rush.
	local mutation
	if State.isGoldenRush() then
		for _, candidate in ipairs(Config.Mutations) do
			if candidate.Name == "Gold" then
				mutation = candidate
				break
			end
		end
	else
		mutation = Config.rollMutation()
	end
	local model = Models.buildBrainrot(character, mutation)
	model.Parent = BeltFolder
	local record = State.newBrainrotRecord(character, mutation, model)
	record.Place = "belt"
	State.Belt[record.Id] = record
	placeModel(model, Vector3.new(0, Config.Belt.TopY, Config.Belt.StartZ + 2), 0, character.Scale)
	attachBuyClick(record)
	return record
end

function State.returnBrainrotToBelt(record)
	record.Place = "belt"
	record.Owner = nil
	record.Slot = 0
	record.BornAt = os.clock()
	if record.Model then
		local stealClick = record.Model.PrimaryPart:FindFirstChild("StealClick")
		if stealClick then
			stealClick:Destroy()
		end
		record.Model.Parent = BeltFolder
		placeModel(record.Model, Vector3.new(0, Config.Belt.TopY, Config.Belt.StartZ + 2), 0, record.Character.Scale)
		attachBuyClick(record)
	end
	State.Belt[record.Id] = record
end

local function attachStealClick(record)
	local click = Instance.new("ClickDetector")
	click.Name = "StealClick"
	click.MaxActivationDistance = 32
	click.Parent = record.Model.PrimaryPart
	click.MouseClick:Connect(function(player)
		State.stealBrainrot(player, record.Id)
	end)
end

local function basedPivot(record, playerState, now)
	local base = slotPosition(playerState.PlotIndex, record.Slot)
	local bob = math.sin(now * 2 + record.Id) * 0.15
	local pivotY = base.Y + 2.2 * (record.Character.Scale or 1) + bob
	return Vector3.new(base.X, pivotY, base.Z)
end

local function moveBrainrots(dt)
	local now = os.clock()
	for id, record in pairs(State.Belt) do
		local model = record.Model
		if not model or not model.Parent then
			State.Belt[id] = nil
		elseif record.Place == "belt" then
			local pivot = model:GetPivot()
			local nextZ = pivot.Position.Z + Config.Belt.Speed * dt
			if nextZ >= Config.Belt.EndZ or now - record.BornAt > Config.Belt.DespawnAfterSeconds then
				model:Destroy()
				State.Belt[id] = nil
			else
				model:PivotTo(CFrame.new(pivot.Position.X, pivot.Position.Y, nextZ))
			end
		end
	end
	for _, playerState in pairs(State.Players) do
		local player = playerState.Player
		local character = player.Character
		local root = character and character:FindFirstChild("HumanoidRootPart")
		for _, record in pairs(playerState.Brainrots) do
			local model = record.Model
			if not model or not model.Parent then
				continue
			end
			if record.Place == "following" and root then
				local target = root.Position
				local pivot = model:GetPivot()
				local toOwner = Vector3.new(target.X - pivot.Position.X, 0, target.Z - pivot.Position.Z)
				local distance = toOwner.Magnitude
				if distance > 4 then
					local step = math.min(distance - 3, 18 * dt)
					local direction = toOwner / distance
					local next = pivot.Position + direction * step
					local facing = math.atan2(-direction.X, -direction.Z)
					model:PivotTo(CFrame.new(next.X, pivot.Position.Y, next.Z) * CFrame.Angles(0, facing, 0))
				end
				if playerState.PlotIndex ~= 0 and Config.pointInPlot(root.Position, playerState.PlotIndex) then
					local slot = State.nextFreeSlot(playerState)
					if slot ~= 0 then
						record.Place = "based"
						record.Slot = slot
						State.clearCarrying(playerState, record.Id)
						model:PivotTo(CFrame.new(basedPivot(record, playerState, now)))
						attachStealClick(record)
						State.recomputeIncome(playerState)
					end
				end
			elseif record.Place == "based" then
				model:PivotTo(CFrame.new(basedPivot(record, playerState, now)))
			end
		end
	end
end

RunService.Heartbeat:Connect(moveBrainrots)

task.spawn(function()
	while true do
		task.wait(Config.Belt.SpawnIntervalSeconds)
		local ok, err = pcall(spawnBrainrotOnBelt)
		if not ok then
			warn("BrainrotSpawner: spawn failed: " .. tostring(err))
		end
	end
end)

-- v7 Golden Rush cycle: every CycleSeconds a rush opens for
-- DurationSeconds. The start and the end are announced to every client
-- (the client shows a gold banner with the countdown), and the clock
-- lives in BrainrotState so the spawner, the world beacon and the HUD
-- all read the same window.
task.spawn(function()
	while true do
		local waitFor = math.max(0, State.NextGoldenRushAt - os.clock())
		task.wait(waitFor)
		State.GoldenRushUntil = os.clock() + Config.GoldenRush.DurationSeconds
		goldenAlert:FireAllClients("rush", Config.GoldenRush.DurationSeconds)
		task.wait(Config.GoldenRush.DurationSeconds)
		State.GoldenRushUntil = 0
		State.NextGoldenRushAt = os.clock() + Config.GoldenRush.CycleSeconds
		goldenAlert:FireAllClients("over")
	end
end)

for _ = 1, 3 do
	spawnBrainrotOnBelt()
end

Players.PlayerRemoving:Connect(function(player)
	local playerState = State.Players[player]
	if not playerState then
		return
	end
	for _, record in pairs(playerState.Brainrots) do
		if record.Place == "following" then
			State.returnBrainrotToBelt(record)
			playerState.Brainrots[record.Id] = nil
		end
	end
end)
