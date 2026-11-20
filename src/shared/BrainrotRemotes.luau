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
	"GoldenAlert", -- server -> client, ("rush", seconds) at rush start or ("over") at rush end
}

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

function Remotes.waitForEvent(name)
	local folder = ReplicatedStorage:WaitForChild("BrainrotRemotes", 10)
	if not folder then
		return nil
	end
	return folder:WaitForChild(name, 10)
end

return Remotes
