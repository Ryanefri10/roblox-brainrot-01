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
local State = require(script.Parent:WaitForChild("BrainrotState"))

local BeltFolder = Instance.new("Folder")
BeltFolder.Name = "BeltBrainrots"
BeltFolder.Parent = Workspace

-- Where a brainrot stands on its owner's base: slot pads are two rows of
-- four, four studs apart, centred on the plot.
local function slotPosition(plotIndex, slot)
	local center = Config.plotCenter(plotIndex)
	local row = math.floor((slot - 1) / 4)
	local col = (slot - 1) % 4
	return Vector3.new(center.X + (col - 1.5) * 4, Config.Plots.FloorTopY + 0.5, center.Z + (row - 0.5) * 4)
end

-- Put a model's feet at a ground point, facing a direction. A model's
-- pivot is its torso, which sits 2.2 studs above its feet (times scale).
local function placeModel(model, groundPosition, facing, scale)
	local pivotY = groundPosition.Y + 2.2 * (scale or 1)
	model:PivotTo(CFrame.new(groundPosition.X, pivotY, groundPosition.Z) * CFrame.Angles(0, facing, 0))
end

-- The click detector a belt brainrot carries, so a player can click it to
-- buy it. The buy itself lives in BrainrotState, next to every other rule.
local function attachBuyClick(record)
	local click = Instance.new("ClickDetector")
	click.Name = "BuyClick"
	click.MaxActivationDistance = 32
	click.Parent = record.Model.PrimaryPart
	click.MouseClick:Connect(function(player)
		State.buyBrainrot(player, record.Id)
	end)
end

-- Spawn one brainrot at the dock and set it walking down the belt.
local function spawnBrainrotOnBelt()
	local character = Config.rollCharacter()
	local mutation = Config.rollMutation()
	local model = Models.buildBrainrot(character, mutation)
	model.Parent = BeltFolder
	local record = State.newBrainrotRecord(character, mutation, model)
	record.Place = "belt"
	State.Belt[record.Id] = record
	placeModel(model, Vector3.new(0, Config.Belt.TopY, Config.Belt.StartZ + 2), 0, character.Scale)
	attachBuyClick(record)
	return record
end

-- Send a brainrot back to the belt (dropped by a wave, or a steal that
-- fell through): it walks the belt again from the dock with fresh time.
-- The state module calls this hook; the spawner owns the belt, so the
-- spawner defines what "back to the belt" means.
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

-- The click detector a based brainrot carries, so another player can
-- click it to start stealing it. The steal itself lives in BrainrotState.
local function attachStealClick(record)
	local click = Instance.new("ClickDetector")
	click.Name = "StealClick"
	click.MaxActivationDistance = 32
	click.Parent = record.Model.PrimaryPart
	click.MouseClick:Connect(function(player)
		State.stealBrainrot(player, record.Id)
	end)
end

-- Where a based brainrot's pivot sits: its slot pad, plus a gentle bob.
local function basedPivot(record, playerState, now)
	local base = slotPosition(playerState.PlotIndex, record.Slot)
	local bob = math.sin(now * 2 + record.Id) * 0.15
	local pivotY = base.Y + 2.2 * (record.Character.Scale or 1) + bob
	return Vector3.new(base.X, pivotY, base.Z)
end

-- Move every brainrot one step. Belt ones walk toward +Z and despawn at
-- the end; following ones hurry after their owner; based ones bob gently
-- on their slot pad, earning.
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
				-- Home: stepping onto your own plot plants the brainrot.
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

-- A new brainrot rides in every few seconds, for as long as the server runs.
task.spawn(function()
	while true do
		task.wait(Config.Belt.SpawnIntervalSeconds)
		local ok, err = pcall(spawnBrainrotOnBelt)
		if not ok then
			warn("BrainrotSpawner: spawn failed: " .. tostring(err))
		end
	end
end)

-- The first three brainrots arrive at once, so the belt is never empty
-- when a player joins: one of them is always the cheap first buy.
for _ = 1, 3 do
	spawnBrainrotOnBelt()
end

-- Keep the belt tidy when a player leaves mid-carry: their following
-- brainrot walks back to the belt instead of vanishing.
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
