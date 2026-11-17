-- BrainrotWave: the tsunami. Every 90 seconds the bay warns for 10
-- seconds, then a great blue wall sweeps from the dock to the south end
-- over 8 seconds. Your own green base is the safe zone: caught outside
-- while carrying a brainrot, you drop it and it walks back to the belt;
-- caught outside empty-handed, you are only knocked gently back toward
-- home. Nobody dies, nothing is lost, and the warning is impossible to miss.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("BrainrotConfig"))
local Remotes = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("BrainrotRemotes"))
local State = require(script.Parent:WaitForChild("BrainrotState"))

local remotes = Remotes.getRemotes()
local waveAlert = remotes:WaitForChild("WaveAlert")

local WaveFolder = Instance.new("Folder")
WaveFolder.Name = "TsunamiWave"
WaveFolder.Parent = Workspace

-- Build the wave wall: a tall translucent blue slab spanning the bay.
local function buildWaveWall()
	local wall = Instance.new("Part")
	wall.Name = "WaveWall"
	wall.Size = Vector3.new(200, Config.Wave.WallHeight, Config.Wave.WallThickness)
	wall.Color = Config.Palette.WaveBlue
	wall.Material = Enum.Material.Neon
	wall.Transparency = 0.35
	wall.Anchored = true
	wall.CanCollide = false
	wall.CFrame = CFrame.new(0, Config.Wave.WallHeight / 2, -95)
	wall.Parent = WaveFolder
	local crest = Instance.new("Part")
	crest.Name = "WaveCrest"
	crest.Size = Vector3.new(200, 2, Config.Wave.WallThickness + 2)
	crest.Color = Color3.fromRGB(255, 255, 255)
	crest.Material = Enum.Material.Neon
	crest.Transparency = 0.2
	crest.Anchored = true
	crest.CanCollide = false
	crest.CFrame = CFrame.new(0, Config.Wave.WallHeight, -95)
	crest.Parent = WaveFolder
	return wall, crest
end

-- Sweep one player with the wave: drop a carried brainrot, or knock an
-- empty-handed player gently back toward their own base. No damage, no
-- lost progress, ever.
local function sweepPlayer(player, playerState)
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if not root then
		return
	end
	-- Safe on your own green base: the wave passes you by.
	if playerState.PlotIndex ~= 0 and Config.pointInPlot(root.Position, playerState.PlotIndex) then
		return
	end
	if playerState.CarryingId then
		local record = playerState.Brainrots[playerState.CarryingId]
		if record then
			playerState.Brainrots[record.Id] = nil
			State.clearCarrying(playerState, record.Id)
			State.returnBrainrotToBelt(record)
		end
	else
		-- A gentle shove home: 12 studs toward your plot, no damage.
		local center = playerState.PlotIndex ~= 0 and Config.plotCenter(playerState.PlotIndex) or Vector3.new(0, 0, 68)
		local direction = Vector3.new(center.X - root.Position.X, 0, center.Z - root.Position.Z)
		if direction.Magnitude > 1 then
			direction = direction / direction.Magnitude
			root.CFrame = root.CFrame + direction * 12
		end
	end
end

-- One full wave cycle: warn, then sweep, then rest until the next one.
local function runWaveCycle()
	State.NextWaveAt = os.clock() + Config.Wave.CycleSeconds
	while true do
		task.wait(Config.Wave.CycleSeconds - Config.Wave.WarningSeconds)
		-- Ten seconds of warning: banner and timer on every client.
		waveAlert:FireAllClients("warning", Config.Wave.WarningSeconds)
		task.wait(Config.Wave.WarningSeconds)
		-- The wave itself: the wall sweeps the bay from north to south.
		waveAlert:FireAllClients("wave", Config.Wave.SweepSeconds)
		local wall, crest = buildWaveWall()
		local steps = 40
		local stepTime = Config.Wave.SweepSeconds / steps
		for step = 1, steps do
			local z = -95 + (190 * step / steps)
			wall.CFrame = CFrame.new(0, Config.Wave.WallHeight / 2, z)
			crest.CFrame = CFrame.new(0, Config.Wave.WallHeight, z)
			-- Anyone the wall has passed who is still outside is swept.
			for _, player in ipairs(Players:GetPlayers()) do
				local playerState = State.Players[player]
				local character = player.Character
				local root = character and character:FindFirstChild("HumanoidRootPart")
				if playerState and root and root.Position.Z < z then
					sweepPlayer(player, playerState)
				end
			end
			task.wait(stepTime)
		end
		wall:Destroy()
		crest:Destroy()
		State.NextWaveAt = os.clock() + Config.Wave.CycleSeconds
	end
end

task.spawn(runWaveCycle)
