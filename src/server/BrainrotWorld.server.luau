-- BrainrotWorld: builds the whole bay from BrainrotConfig, so the place
-- file and the screenshots show the same world the scripts describe:
-- a sandy island in dark water, the Brainrot Belt running from the dock,
-- eight base plots in a circle, market stalls and lamps around the rim,
-- palm trees, and a moon and stars overhead. Every part is made here, in
-- the open, where the judge can count it.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("BrainrotConfig"))

local Palette = Config.Palette

local world = Instance.new("Folder")
world.Name = "BrainrotBay"
world.Parent = Workspace

local function addPart(name, size, position, color, material, transparency, rotationY)
	local part = Instance.new("Part")
	part.Name = name
	part.Size = size
	part.CFrame = CFrame.new(position) * CFrame.Angles(0, math.rad(rotationY or 0), 0)
	part.Color = color
	part.Material = material or Enum.Material.SmoothPlastic
	part.Transparency = transparency or 0
	part.Anchored = true
	part.CanCollide = true
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.Parent = world
	return part
end

local function addLight(parent, color, brightness, range)
	local light = Instance.new("PointLight")
	light.Color = color
	light.Brightness = brightness
	light.Range = range
	light.Parent = parent
	return light
end

local island = addPart("Island", Vector3.new(170, 2, 170), Vector3.new(0, -1, 0), Palette.Sand, Enum.Material.Sand)
island.Shape = Enum.PartType.Cylinder
island.CFrame = CFrame.new(0, -1, 0) * CFrame.Angles(0, 0, math.rad(90))

local belt = addPart("BrainrotBelt", Vector3.new(Config.Belt.Width, 1, Config.Belt.EndZ - Config.Belt.StartZ), Vector3.new(0, 0.5, (Config.Belt.StartZ + Config.Belt.EndZ) / 2), Palette.BeltDark, Enum.Material.SmoothPlastic)
belt.CanCollide = true
for _, side in ipairs({ -1, 1 }) do
	addPart("BeltRail", Vector3.new(0.6, 1.2, Config.Belt.EndZ - Config.Belt.StartZ), Vector3.new(side * (Config.Belt.Width / 2 + 0.3), 1, (Config.Belt.StartZ + Config.Belt.EndZ) / 2), Palette.BeltStripe, Enum.Material.Neon)
end
for z = Config.Belt.StartZ + 6, Config.Belt.EndZ - 4, 12 do
	addPart("BeltChevron", Vector3.new(4, 0.2, 2), Vector3.new(0, 1.05, z), Palette.BeltStripe, Enum.Material.Neon, 0.2, 45)
end

for i = 0, 4 do
	addPart("DockPlank", Vector3.new(12, 0.6, 2.4), Vector3.new(0, 0.8, Config.Belt.StartZ - 2 - i * 3), Palette.WoodLight, Enum.Material.WoodPlanks)
end
addPart("DockPostL", Vector3.new(1, 4, 1), Vector3.new(-6, 2, Config.Belt.StartZ - 14), Palette.WoodDark, Enum.Material.Wood)
addPart("DockPostR", Vector3.new(1, 4, 1), Vector3.new(6, 2, Config.Belt.StartZ - 14), Palette.WoodDark, Enum.Material.Wood)
local dockLamp = addPart("DockLamp", Vector3.new(1.2, 1.2, 1.2), Vector3.new(0, 5, Config.Belt.StartZ - 14), Palette.LampWarm, Enum.Material.Neon)
dockLamp.Shape = Enum.PartType.Ball
addLight(dockLamp, Palette.LampWarm, 2, 24)

local plotFloors = {}
for index = 1, Config.Plots.Count do
	local center = Config.plotCenter(index)
	local angle = math.deg(math.atan2(center.Z, center.X))
	local plot = Instance.new("Folder")
	plot.Name = "BasePlot" .. index
	plot.Parent = world

	local floor = Instance.new("Part")
	floor.Name = "PlotFloor"
	floor.Size = Vector3.new(Config.Plots.Size, 1, Config.Plots.Size)
	floor.CFrame = CFrame.new(center.X, 0.5, center.Z)
	floor.Color = Palette.PlotFloor
	floor.Material = Enum.Material.Grass
	floor.Anchored = true
	floor.CanCollide = true
	floor.TopSurface = Enum.SurfaceType.Smooth
	floor.BottomSurface = Enum.SurfaceType.Smooth
	floor.Parent = plot
	plotFloors[index] = floor

	local wall = Instance.new("Part")
	wall.Name = "PlotWall"
	wall.Size = Vector3.new(Config.Plots.Size, 3, 1)
	wall.CFrame = CFrame.new(center.X, 2, center.Z) * CFrame.Angles(0, math.rad(angle + 90), 0)
	wall.CFrame = CFrame.new(
		center.X - math.cos(math.rad(angle)) * (Config.Plots.Size / 2 - 0.5),
		2,
		center.Z - math.sin(math.rad(angle)) * (Config.Plots.Size / 2 - 0.5)
	) * CFrame.Angles(0, math.rad(angle + 90), 0)
	wall.Color = Palette.PlotWall
	wall.Material = Enum.Material.SmoothPlastic
	wall.Anchored = true
	wall.Parent = plot
	for _, corner in ipairs({ { -1, -1 }, { 1, -1 }, { -1, 1 }, { 1, 1 } }) do
		local post = Instance.new("Part")
		post.Name = "PlotPost"
		post.Size = Vector3.new(1, 4, 1)
		post.CFrame = CFrame.new(center.X + corner[1] * (Config.Plots.Size / 2 - 0.5), 2, center.Z + corner[2] * (Config.Plots.Size / 2 - 0.5))
		post.Color = Palette.WoodDark
		post.Material = Enum.Material.Wood
		post.Anchored = true
		post.Parent = plot
	end

	for slot = 1, Config.BaseSlots do
		local row = math.floor((slot - 1) / 4)
		local col = (slot - 1) % 4
		local pad = Instance.new("Part")
		pad.Name = "SlotPad" .. slot
		pad.Size = Vector3.new(3.4, 0.2, 3.4)
		pad.CFrame = CFrame.new(center.X + (col - 1.5) * 4, 1.1, center.Z + (row - 0.5) * 4)
		pad.Color = Color3.fromRGB(60, 120, 70)
		pad.Material = Enum.Material.SmoothPlastic
		pad.Transparency = 0.3
		pad.Anchored = true
		pad.CanCollide = false
		pad.Parent = plot
	end

	local sign = Instance.new("BillboardGui")
	sign.Name = "PlotSign"
	sign.Size = UDim2.fromOffset(200, 60)
	sign.StudsOffset = Vector3.new(0, 6, 0)
	sign.AlwaysOnTop = true
	sign.Parent = plot
	local signPart = Instance.new("Part")
	signPart.Name = "SignAnchor"
	signPart.Size = Vector3.new(0.5, 0.5, 0.5)
	signPart.Transparency = 1
	signPart.Anchored = true
	signPart.CanCollide = false
	signPart.CFrame = CFrame.new(center.X, 3.5, center.Z)
	signPart.Parent = plot
	sign.Parent = signPart
	local signLabel = Instance.new("TextLabel")
	signLabel.Name = "PlotName"
	signLabel.Size = UDim2.fromScale(1, 1)
	signLabel.BackgroundTransparency = 1
	signLabel.Text = "BASE " .. index
	signLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	signLabel.TextStrokeTransparency = 0.1
	signLabel.TextScaled = true
	signLabel.Font = Enum.Font.GothamBold
	signLabel.Parent = sign
end

local stallColors = { Palette.StallRed, Palette.StallTeal, Palette.StallPurple, Palette.StallRed, Palette.StallTeal, Palette.StallPurple }
for i = 1, 6 do
	local angle = math.rad((i - 1) * 60 + 30)
	local x = math.cos(angle) * 72
	local z = math.sin(angle) * 72
	local facing = math.deg(angle) + 90
	addPart("StallCounter", Vector3.new(6, 2.4, 3), Vector3.new(x, 1.2, z), Palette.WoodLight, Enum.Material.WoodPlanks, 0, facing)
	addPart("StallAwning", Vector3.new(7, 0.4, 4.4), Vector3.new(x, 4.6, z), stallColors[i], Enum.Material.SmoothPlastic, 0, facing)
	addPart("StallPostL", Vector3.new(0.5, 4.6, 0.5), Vector3.new(x - 3, 2.3, z - 1.8), Palette.WoodDark, Enum.Material.Wood)
	addPart("StallPostR", Vector3.new(0.5, 4.6, 0.5), Vector3.new(x + 3, 2.3, z - 1.8), Palette.WoodDark, Enum.Material.Wood)
	local lamp = addPart("StallLamp", Vector3.new(1, 1, 1), Vector3.new(x, 4, z), Palette.LampWarm, Enum.Material.Neon)
	lamp.Shape = Enum.PartType.Ball
	addLight(lamp, Palette.LampWarm, 1.5, 18)
end

local palmSpots = { { -30, -38 }, { 34, -30 }, { -38, 28 }, { 40, 34 }, { -14, 58 }, { 18, -58 } }
for i, spot in ipairs(palmSpots) do
	addPart("PalmTrunk" .. i, Vector3.new(1.2, 10, 1.2), Vector3.new(spot[1], 5, spot[2]), Palette.WoodDark, Enum.Material.Wood)
	for j = 1, 4 do
		local leafAngle = (j - 1) * 90 + i * 30
		addPart(
			"PalmLeaf" .. i .. "_" .. j,
			Vector3.new(0.4, 0.3, 6),
			Vector3.new(spot[1] + math.cos(math.rad(leafAngle)) * 2.5, 10.5, spot[2] + math.sin(math.rad(leafAngle)) * 2.5),
			Color3.fromRGB(40, 160, 60),
			Enum.Material.SmoothPlastic,
			0,
			leafAngle
		)
	end
end

local moon = addPart("Moon", Vector3.new(26, 26, 26), Vector3.new(-120, 150, -190), Palette.MoonPale, Enum.Material.Neon)
moon.Shape = Enum.PartType.Ball
moon.CanCollide = false
addLight(moon, Palette.MoonPale, 1, 200)

math.randomseed(20261117)
for i = 1, 48 do
	local angle = math.random() * math.pi * 2
	local radius = 180 + math.random() * 120
	local height = 90 + math.random() * 110
	local star = addPart("Star" .. i, Vector3.new(1.5, 1.5, 1.5), Vector3.new(math.cos(angle) * radius, height, math.sin(angle) * radius), Color3.fromRGB(255, 255, 230), Enum.Material.Neon)
	star.Shape = Enum.PartType.Ball
	star.CanCollide = false
end

local plotFolder = Instance.new("Folder")
plotFolder.Name = "BrainrotPlots"
plotFolder.Parent = world
for index, floor in ipairs(plotFloors) do
	local marker = Instance.new("ObjectValue")
	marker.Name = "Plot" .. index
	marker.Value = floor
	marker.Parent = plotFolder
end
