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

-- A fresh player state: generous starting cash, no brainrots, no rebirths.
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
	}
end

-- The state for a player, creating it on first ask.
function State.getPlayerState(player)
	local state = State.Players[player]
	if not state then
		state = State.newPlayerState(player)
		State.Players[player] = state
	end
	return state
end

-- Hand a player the next free base plot, or 0 when the bay is full.
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

-- Free a player's plot and forget their state when they leave.
function State.removePlayer(player)
	local state = State.Players[player]
	if state then
		if state.PlotIndex ~= 0 then
			State.TakenPlots[state.PlotIndex] = nil
		end
		State.Players[player] = nil
	end
end

-- A fresh id for a brainrot, unique across belt and bases.
function State.nextBrainrotId()
	local id = State.NextBrainrotId
	State.NextBrainrotId += 1
	return id
end

-- A brainrot record: the character, its mutation, its model and where it
-- is in the loop ("belt", "following" or "based").
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

-- Dollars per second one owned brainrot earns, right now.
function State.brainrotIncome(record, playerState)
	return Config.brainrotIncome(record.Character, record.Mutation, playerState.Multiplier)
end

-- Recompute a player's dollars per second from the brainrots standing on
-- their base, and return it.
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

-- How many base slots a player has filled.
function State.slotsUsed(playerState)
	local used = 0
	for _, record in pairs(playerState.Brainrots) do
		if record.Place == "based" then
			used += 1
		end
	end
	return used
end

-- The next free slot number on a player's base, or 0 when it is full.
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

-- Is a player's base locked right now?
function State.isBaseLocked(playerState)
	return os.clock() < playerState.LockUntil
end

-- Seconds left on a player's base lock, or 0.
function State.lockSecondsLeft(playerState)
	return math.max(0, playerState.LockUntil - os.clock())
end

-- Seconds left before a player may lock again, or 0.
function State.lockCooldownLeft(playerState)
	return math.max(0, playerState.LockCooldownUntil - os.clock())
end

-- Lock a player's base for the configured duration, starting its cooldown.
-- Returns false when the lock is still cooling down.
function State.lockBase(playerState)
	if State.lockCooldownLeft(playerState) > 0 then
		return false
	end
	local now = os.clock()
	playerState.LockUntil = now + Config.Lock.DurationSeconds
	playerState.LockCooldownUntil = now + Config.Lock.CooldownSeconds
	return true
end

-- Apply a rebirth: cash and brainrots reset, the permanent multiplier and
-- the base tier rise. Returns false when the player has not earned enough.
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

-- Sent back to the belt by default: the brainrot is removed, unless the
-- spawner, which owns the belt, replaces this hook with the real return
-- trip (it does, at server start, before any wave can fire).
function State.returnBrainrotToBelt(record)
	if record.Model then
		record.Model:Destroy()
	end
	State.Belt[record.Id] = nil
end

-- Buy the brainrot riding the belt: pay cash, and it follows you home.
-- `brainrotId` is a belt brainrot's number, or a character Id from the
-- shop, which buys the first of that character riding the belt.
-- Returns true on success, or false with the reason the player is shown.
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
	if record.Model then
		local click = record.Model.PrimaryPart:FindFirstChild("BuyClick")
		if click then
			click:Destroy()
		end
	end
	return true, record.Character.Name
end

-- The player carrying a brainrot stops carrying it: used when it is
-- planted on the base, dropped by a wave, or the player leaves.
function State.clearCarrying(playerState, brainrotId)
	if playerState.CarryingId == brainrotId then
		playerState.CarryingId = nil
	end
end

State.PendingSteals = {} -- [brainrotId] = { Thief = Player, EndsAt = number }

-- Find the owner and record of a brainrot standing on a base.
local function findBasedBrainrot(brainrotId)
	for _, ownerState in pairs(State.Players) do
		local record = ownerState.Brainrots[brainrotId]
		if record and record.Place == "based" then
			return ownerState, record
		end
	end
	return nil, nil
end

-- Start stealing a brainrot from an UNLOCKED base: a 10 second channel,
-- re-checked at the end, so a lock raised mid-channel still saves it.
-- Returns true on success, or false with the reason the player is shown.
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

-- Finish a steal channel: move the brainrot only when every check still
-- holds (still based, base still unlocked, thief still free to carry).
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

-- A rebirth, when the player earned enough: resets cash and brainrots for
-- a permanent income multiplier and a higher base tier.
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

-- Lock a player's own base for 30 seconds of protection.
function State.requestLock(player)
	local playerState = State.getPlayerState(player)
	if State.lockBase(playerState) then
		return true, Config.Lock.DurationSeconds
	end
	return false, "Lock is cooling down: " .. tostring(State.lockCooldownLeft(playerState)) .. "s left."
end

-- The small state table the client HUD is synced with, every second.
function State.syncSnapshot(playerState)
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
		RebirthReady = playerState.TotalEarned >= Config.RebirthRequiredTotalEarned,
		RebirthNeed = Config.RebirthRequiredTotalEarned,
		WaveIn = math.floor(math.max(0, (State.NextWaveAt or 0) - os.clock())),
	}
end

-- Seconds left on a steal channel this player started, or 0. The client
-- draws its progress bar from this.
function State.stealSecondsLeft(player)
	for _, pending in pairs(State.PendingSteals) do
		if pending.Thief == player then
			return math.max(0, pending.EndsAt - os.clock())
		end
	end
	return 0
end

return State
