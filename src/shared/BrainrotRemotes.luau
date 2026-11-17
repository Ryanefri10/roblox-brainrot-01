-- BrainrotRemotes: the RemoteEvents the client and the server talk through.
-- One folder in ReplicatedStorage, created once by whichever server script
-- asks first, so no script depends on another script having run already.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = {}

local EVENT_NAMES = {
	"BuyBrainrot", -- client -> server, brainrot id on the belt
	"StealBrainrot", -- client -> server, brainrot id on another base
	"Rebirth", -- client -> server, no argument
	"LockBase", -- client -> server, no argument
	"BrainrotSync", -- server -> client, one state table per player
	"WaveAlert", -- server -> client, ("warning", seconds) or ("wave", seconds)
}

-- Return the folder of RemoteEvents, creating it (and any event missing
-- from it) on first use. Safe to call from every server script.
function Remotes.getRemotes()
	local folder = ReplicatedStorage:FindFirstChild("BrainrotRemotes")
	if not folder then
		folder = Instance.new("Folder")
		folder.Name = "BrainrotRemotes"
		folder.Parent = ReplicatedStorage
	end
	for _, name in ipairs(EVENT_NAMES) do
		if not folder:FindFirstChild(name) then
			local event = Instance.new("RemoteEvent")
			event.Name = name
			event.Parent = folder
		end
	end
	return folder
end

-- Fetch one RemoteEvent by name, waiting for the folder when the client
-- asks before the server has made it.
function Remotes.waitForEvent(name)
	local folder = ReplicatedStorage:WaitForChild("BrainrotRemotes", 10)
	if not folder then
		return nil
	end
	return folder:WaitForChild(name, 10)
end

return Remotes
