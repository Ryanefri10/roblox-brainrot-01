-- BrainrotState: the one place the server keeps game state. Every server
-- script requires this module instead of keeping its own copy of a
-- player's cash, brainrots or base, so the belt, the base, the shop and
-- the wave can never disagree about who owns what.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("BrainrotConfig"))

local State = {}

State.Players = {} -- [Player] = player state table
State.Belt = {} -- [brainrotId] = belt brainrot record
State.NextBrainrotId = 1
State.TakenPlots = {} -- [plotIndex] = Player
State.NextPlot = 1

State.NextWaveAt = 0 -- os.clock() time of the next tsunami, set by the wave script

-- v7 Golden Rush clock, owned by the spawner: NextGoldenRushAt is the
-- os.clock() time the next rush starts, GoldenRushUntil the time the
-- running rush ends (0 when no rush is live).
State.NextGoldenRushAt = os.clock() + Config.GoldenRush.CycleSeconds
State.GoldenRushUntil = 0

function State.isGoldenRush()
	return os.clock() < State.GoldenRushUntil
end

function State.goldenSecondsLeft()
	return math.max(0, State.GoldenRushUntil - os.clock())
end

-- v7 leaderboard: the top 5 earners in the server by TotalEarned, so
-- every client can show the same ranking without its own bookkeeping.
function State.topEarners()
	local ranked = {}
	for _, playerState in pairs(State.Players) do
		if playerState.Player and playerState.Player.Parent then
			table.insert(ranked, {
				Name = playerState.Player.DisplayName,
				Earned = math.floor(playerState.TotalEarned),
			})
		end
	end
	table.sort(ranked, function(a, b)
		return a.Earned > b.Earned
	end)
	local top = {}
	for i = 1, math.min(5, #ranked) do
		top[i] = ranked[i]
	end
	return top
end

-- A player's rank (1-based) in the top earners, or 0 when unranked.
function State.playerRank(playerState)
	for i, entry in ipairs(State.topEarners()) do
		if entry.Name == playerState.Player.DisplayName then
			return i
		end
	end
	return 0
end

function State.newPlayerState(player)
	return {
		Player = player,
		Cash = Config.StartCash,
		TotalEarned = 0,
		Rebirths = 0,
		Multiplier = 1,
		BaseTier = 1,
		PlotIndex = 0,
		CarryingId = nil, -- brainrot id following this player, or nil
		LockUntil = 0,
		LockCooldownUntil = 0,
		Brainrots = {}, -- [brainrotId] = brainrot record this player owns
		MissionIndex = 1, -- next mission in Config.Missions (past the end = all done)
		Won = false,
		MissionNotice = nil, -- set by checkMissions, consumed by the next sync
	}
end

function State.missionProgress(playerState, mission)
	if mission.Kind == "bought" then
		local count = 0
		for _ in pairs(playerState.Brainrots) do
			count += 1
		end
		return count
	elseif mission.Kind == "based" then
		return State.slotsUsed(playerState)
	elseif mission.Kind == "earned" then
		return math.floor(playerState.TotalEarned)
	elseif mission.Kind == "golden" then
		-- Golden brainrots standing on the base: the v7 mission, only
		-- completable by catching one during a Golden Rush or a lucky
		-- random Gold roll and walking it home.
		local count = 0
		for _, record in pairs(playerState.Brainrots) do
			if record.Place == "based" and record.Mutation and record.Mutation.Name == "Gold" then
				count += 1
			end
		end
		return count
	end
	return 0
end

-- Grants each newly completed mission's cash reward in order, and sets
-- MissionNotice for the next sync. Completing the last mission wins.
function State.checkMissions(playerState)
	while playerState.MissionIndex <= #Config.Missions do
		local mission = Config.Missions[playerState.MissionIndex]
		if State.missionProgress(playerState, mission) < mission.Target then
			break
		end
		playerState.Cash += mission.Reward
		playerState.MissionIndex += 1
		if playerState.MissionIndex > #Config.Missions then
			playerState.Won = true
			playerState.MissionNotice = "🏆 YOU WIN! You are the Brainrot King! +$" .. tostring(mission.Reward)
		else
			playerState.MissionNotice = "✅ Mission done: " .. mission.Text .. "! +$" .. tostring(mission.Reward)
		end
	end
end

function State.getPlayerState(player)
	local state = State.Players[player]
	if not state then
		state = State.newPlayerState(player)
		State.Players[player] = state
	end
	return state
end

function State.assignPlot(player)
	local state = State.getPlayerState(player)
	if state.PlotIndex ~= 0 then
		return state.PlotIndex
	end
	for _ = 1, Config.Plots.Count do
		local index = State.NextPlot
		State.NextPlot = State.NextPlot % Config.Plots.Count + 1
		if not State.TakenPlots[index] then
			State.TakenPlots[index] = player
			state.PlotIndex = index
			return index
		end
	end
	return 0
end

function State.removePlayer(player)
	local state = State.Players[player]
	if state then
		if state.PlotIndex ~= 0 then
			State.TakenPlots[state.PlotIndex] = nil
		end
		State.Players[player] = nil
	end
end

function State.nextBrainrotId()
	local id = State.NextBrainrotId
	State.NextBrainrotId += 1
	return id
end

function State.newBrainrotRecord(character, mutation, model)
	return {
		Id = State.nextBrainrotId(),
		Character = character,
		Mutation = mutation,
		Model = model,
		Place = "belt",
		Owner = nil, -- Player once bought or stolen
		Slot = 0, -- base slot number once it stands on a base
		BornAt = os.clock(),
	}
end

function State.brainrotIncome(record, playerState)
	return Config.brainrotIncome(record.Character, record.Mutation, playerState.Multiplier)
end

function State.recomputeIncome(playerState)
	local income = 0
	for _, record in pairs(playerState.Brainrots) do
		if record.Place == "based" then
			income += State.brainrotIncome(record, playerState)
		end
	end
	playerState.IncomePerSec = income
	return income
end

function State.slotsUsed(playerState)
	local used = 0
	for _, record in pairs(playerState.Brainrots) do
		if record.Place == "based" then
			used += 1
		end
	end
	return used
end

function State.nextFreeSlot(playerState)
	local taken = {}
	for _, record in pairs(playerState.Brainrots) do
		if record.Place == "based" then
			taken[record.Slot] = true
		end
	end
	for slot = 1, Config.BaseSlots do
		if not taken[slot] then
			return slot
		end
	end
	return 0
end

function State.isBaseLocked(playerState)
	return os.clock() < playerState.LockUntil
end

function State.lockSecondsLeft(playerState)
	return math.max(0, playerState.LockUntil - os.clock())
end

function State.lockCooldownLeft(playerState)
	return math.max(0, playerState.LockCooldownUntil - os.clock())
end

function State.lockBase(playerState)
	if State.lockCooldownLeft(playerState) > 0 then
		return false
	end
	local now = os.clock()
	playerState.LockUntil = now + Config.Lock.DurationSeconds
	playerState.LockCooldownUntil = now + Config.Lock.CooldownSeconds
	return true
end

function State.applyRebirth(playerState)
	if playerState.TotalEarned < Config.RebirthRequiredTotalEarned then
		return false
	end
	for _, record in pairs(playerState.Brainrots) do
		if record.Model then
			record.Model:Destroy()
		end
	end
	playerState.Brainrots = {}
	playerState.CarryingId = nil
	playerState.Cash = Config.RebirthCashAfter
	playerState.Rebirths += 1
	playerState.Multiplier = 1 + playerState.Rebirths * Config.RebirthMultiplierPerRebirth
	playerState.BaseTier += 1
	playerState.IncomePerSec = 0
	return true
end

function State.returnBrainrotToBelt(record)
	if record.Model then
		record.Model:Destroy()
	end
	State.Belt[record.Id] = nil
end

function State.buyBrainrot(player, brainrotId)
	local playerState = State.getPlayerState(player)
	local record = nil
	if type(brainrotId) == "string" then
		for _, beltRecord in pairs(State.Belt) do
			if beltRecord.Character.Id == brainrotId then
				record = beltRecord
				break
			end
		end
	else
		record = State.Belt[brainrotId]
	end
	if not record or record.Place ~= "belt" then
		return false, "That brainrot is not on the belt right now."
	end
	if playerState.CarryingId then
		return false, "Take your brainrot home first!"
	end
	if State.slotsUsed(playerState) >= Config.BaseSlots then
		return false, "Your base is full!"
	end
	if playerState.Cash < record.Character.Price then
		return false, "Not enough Cash!"
	end
	if playerState.PlotIndex == 0 then
		return false, "You have no base yet."
	end
	playerState.Cash -= record.Character.Price
	State.Belt[record.Id] = nil
	record.Place = "following"
	record.Owner = player
	playerState.Brainrots[record.Id] = record
	playerState.CarryingId = record.Id
	State.checkMissions(playerState)
	if record.Model then
		local click = record.Model.PrimaryPart:FindFirstChild("BuyClick")
		if click then
			click:Destroy()
		end
	end
	return true, record.Character.Name
end

function State.clearCarrying(playerState, brainrotId)
	if playerState.CarryingId == brainrotId then
		playerState.CarryingId = nil
	end
end

State.PendingSteals = {} -- [brainrotId] = { Thief = Player, EndsAt = number }

local function findBasedBrainrot(brainrotId)
	for _, ownerState in pairs(State.Players) do
		local record = ownerState.Brainrots[brainrotId]
		if record and record.Place == "based" then
			return ownerState, record
		end
	end
	return nil, nil
end

function State.stealBrainrot(player, brainrotId)
	local thiefState = State.getPlayerState(player)
	local victimState, record = findBasedBrainrot(brainrotId)
	if not record then
		return false, "That brainrot is not on a base."
	end
	if victimState.Player == player then
		return false, "That is your own brainrot!"
	end
	if State.isBaseLocked(victimState) then
		return false, "That base is locked!"
	end
	if thiefState.CarryingId then
		return false, "Take your brainrot home first!"
	end
	if State.slotsUsed(thiefState) >= Config.BaseSlots then
		return false, "Your base is full!"
	end
	if State.PendingSteals[brainrotId] then
		return false, "Someone is already stealing it!"
	end
	State.PendingSteals[brainrotId] = { Thief = player, EndsAt = os.clock() + Config.Steal.ChannelSeconds }
	task.delay(Config.Steal.ChannelSeconds, function()
		State.finishSteal(brainrotId)
	end)
	return true, record.Character.Name
end

function State.finishSteal(brainrotId)
	local pending = State.PendingSteals[brainrotId]
	State.PendingSteals[brainrotId] = nil
	if not pending then
		return
	end
	local thief = pending.Thief
	local thiefState = State.Players[thief]
	local victimState, record = findBasedBrainrot(brainrotId)
	if not record or not thiefState then
		return
	end
	if State.isBaseLocked(victimState) then
		return
	end
	if thiefState.CarryingId then
		return
	end
	victimState.Brainrots[brainrotId] = nil
	State.recomputeIncome(victimState)
	record.Place = "following"
	record.Owner = thief
	record.Slot = 0
	if record.Model then
		local stealClick = record.Model.PrimaryPart:FindFirstChild("StealClick")
		if stealClick then
			stealClick:Destroy()
		end
	end
	thiefState.Brainrots[brainrotId] = record
	thiefState.CarryingId = brainrotId
end

function State.requestRebirth(player)
	local playerState = State.getPlayerState(player)
	if playerState.CarryingId then
		return false, "Take your brainrot home first!"
	end
	if State.applyRebirth(playerState) then
		return true, playerState.Rebirths
	end
	return false, "Earn $" .. tostring(Config.RebirthRequiredTotalEarned) .. " first!"
end

function State.requestLock(player)
	local playerState = State.getPlayerState(player)
	if State.lockBase(playerState) then
		return true, Config.Lock.DurationSeconds
	end
	return false, "Lock is cooling down: " .. tostring(State.lockCooldownLeft(playerState)) .. "s left."
end

-- The victim's side of a steal: if someone is channelling a steal on
-- one of this player's based brainrots, how many seconds are left and
-- which brainrot is being taken, so the client can warn the victim.
-- Locking the base mid-channel cancels the steal in finishSteal, so
-- the warning is the counterplay.
function State.stealThreat(playerState)
	for brainrotId, pending in pairs(State.PendingSteals) do
		local record = playerState.Brainrots[brainrotId]
		if record and record.Place == "based" then
			return math.max(0, pending.EndsAt - os.clock()), record.Character.Name
		end
	end
	return 0, nil
end

function State.syncSnapshot(playerState)
	local missions = {}
	for i, mission in ipairs(Config.Missions) do
		missions[i] = {
			Text = mission.Text,
			Reward = mission.Reward,
			Target = mission.Target,
			Progress = State.missionProgress(playerState, mission),
			Done = i < playerState.MissionIndex,
			Current = i == playerState.MissionIndex,
		}
	end
	local notice = playerState.MissionNotice
	playerState.MissionNotice = nil
	local threatLeft, threatName = State.stealThreat(playerState)
	return {
		Cash = math.floor(playerState.Cash),
		IncomePerSec = math.floor(playerState.IncomePerSec or 0),
		TotalEarned = math.floor(playerState.TotalEarned),
		Rebirths = playerState.Rebirths,
		Multiplier = playerState.Multiplier,
		BaseTier = playerState.BaseTier,
		PlotIndex = playerState.PlotIndex,
		SlotsUsed = State.slotsUsed(playerState),
		SlotsTotal = Config.BaseSlots,
		Carrying = playerState.CarryingId ~= nil,
		LockLeft = math.floor(State.lockSecondsLeft(playerState)),
		LockCooldownLeft = math.floor(State.lockCooldownLeft(playerState)),
		BeingStolen = math.floor(threatLeft),
		BeingStolenName = threatName,
		RebirthReady = playerState.TotalEarned >= Config.RebirthRequiredTotalEarned,
		RebirthNeed = Config.RebirthRequiredTotalEarned,
		WaveIn = math.floor(math.max(0, (State.NextWaveAt or 0) - os.clock())),
		GoldenLeft = math.floor(State.goldenSecondsLeft()),
		GoldenNextIn = math.floor(math.max(0, (State.NextGoldenRushAt or 0) - os.clock())),
		Leaderboard = State.topEarners(),
		Rank = State.playerRank(playerState),
		Missions = missions,
		Won = playerState.Won,
		Notice = notice,
	}
end

function State.stealSecondsLeft(player)
	for _, pending in pairs(State.PendingSteals) do
		if pending.Thief == player then
			return math.max(0, pending.EndsAt - os.clock())
		end
	end
	return 0
end

return State
