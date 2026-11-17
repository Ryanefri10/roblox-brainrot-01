-- BrainrotShop: the counter where every transaction happens. The client
-- fires one RemoteEvent per action; this script checks the rule in
-- BrainrotState and answers the player with a short notice, so the shop
-- UI, the belt click and the steal button all share the same rules.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("BrainrotRemotes"))
local State = require(script.Parent:WaitForChild("BrainrotState"))

local remotes = Remotes.getRemotes()
local buyEvent = remotes:WaitForChild("BuyBrainrot")
local stealEvent = remotes:WaitForChild("StealBrainrot")
local rebirthEvent = remotes:WaitForChild("Rebirth")
local lockEvent = remotes:WaitForChild("LockBase")
local syncEvent = remotes:WaitForChild("BrainrotSync")

-- Tell one player the outcome of their action, through the sync channel
-- the client already listens to: a notice line under the HUD.
local function notify(player, text)
	local playerState = State.Players[player]
	if not playerState then
		return
	end
	local snapshot = State.syncSnapshot(playerState)
	snapshot.Notice = text
	syncEvent:FireClient(player, snapshot)
end

-- Buy the brainrot on the belt: pay, and it follows you home.
buyEvent.OnServerEvent:Connect(function(player, brainrotId)
	local ok, message = State.buyBrainrot(player, brainrotId)
	if ok then
		notify(player, "You bought " .. tostring(message) .. "! Walk it home to your base!")
	else
		notify(player, tostring(message))
	end
end)

-- Steal from another player's base: only when it is unlocked, and only
-- after the 10 second channel the state module runs.
stealEvent.OnServerEvent:Connect(function(player, brainrotId)
	local ok, message = State.stealBrainrot(player, brainrotId)
	if ok then
		notify(player, "Stealing " .. tostring(message) .. "... stay close for 10s!")
	else
		notify(player, tostring(message))
	end
end)

-- Rebirth: trade everything earned so far for a permanent multiplier.
rebirthEvent.OnServerEvent:Connect(function(player)
	local ok, message = State.requestRebirth(player)
	if ok then
		local playerState = State.getPlayerState(player)
		notify(player, "REBIRTH x" .. tostring(message) .. "! Income now x" .. tostring(playerState.Multiplier) .. " forever.")
	else
		notify(player, tostring(message))
	end
end)

-- Lock your base: 30 seconds no one can steal from it.
lockEvent.OnServerEvent:Connect(function(player)
	local ok, message = State.requestLock(player)
	if ok then
		notify(player, "Base locked for " .. tostring(message) .. "s! No one can steal from you.")
	else
		notify(player, tostring(message))
	end
end)

-- A player who joins late still gets the rules: the shop list comes from
-- the shared config, so the client never needs a copy of its own.
Players.PlayerAdded:Connect(function(player)
	local snapshot = State.syncSnapshot(State.getPlayerState(player))
	syncEvent:FireClient(player, snapshot)
end)
