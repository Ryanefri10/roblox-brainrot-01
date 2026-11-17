-- BrainrotModels: builds every brainrot as a blocky Part model, no decals,
-- no images. One builder for the whole cast: a chunky body, a head, arms
-- and legs, then the character's own Extras from BrainrotConfig, then a
-- name plate above the head and a coloured glow when it carries a
-- mutation. The screenshots render these same models.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("BrainrotConfig"))

local Models = {}

-- Make one Part of the model, scaled with the character.
local function makePart(name, size, offset, color, parent, shape, material)
	local part = Instance.new("Part")
	part.Name = name
	part.Size = size
	part.CFrame = CFrame.new(offset)
	part.Color = color
	part.Material = material or Enum.Material.SmoothPlastic
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	if shape == "Ball" then
		part.Shape = Enum.PartType.Ball
	elseif shape == "Cylinder" then
		part.Shape = Enum.PartType.Cylinder
	end
	part.Parent = parent
	return part
end

-- Build a brainrot Model at the origin, feet on Y = 0, facing +Z.
-- `mutation` is a BrainrotConfig.Mutations entry or nil.
function Models.buildBrainrot(character, mutation)
	local scale = character.Scale or 1
	local model = Instance.new("Model")
	model.Name = character.Name

	local function scaled(vector)
		return vector * scale
	end

	-- Chunky body: torso, head, two arms, two legs. Every part is a box
	-- (or a ball where the config says so), so the cast reads as Roblox.
	local torso = makePart("Torso", scaled(Vector3.new(2, 2, 1.4)), scaled(Vector3.new(0, 0.4, 0)), character.Body, model)
	torso.CanQuery = true -- the torso carries the ClickDetector: buy on the belt, steal on a base
	makePart("Head", scaled(Vector3.new(1.8, 1.6, 1.6)), scaled(Vector3.new(0, 1.9, 0)), character.Head, model)
	makePart("ArmL", scaled(Vector3.new(0.7, 1.8, 0.7)), scaled(Vector3.new(-1.4, 0.4, 0)), character.Body, model)
	makePart("ArmR", scaled(Vector3.new(0.7, 1.8, 0.7)), scaled(Vector3.new(1.4, 0.4, 0)), character.Body, model)
	makePart("LegL", scaled(Vector3.new(0.8, 1.2, 0.8)), scaled(Vector3.new(-0.55, -1.2, 0)), character.Body, model)
	makePart("LegR", scaled(Vector3.new(0.8, 1.2, 0.8)), scaled(Vector3.new(0.55, -1.2, 0)), character.Body, model)

	-- Eyes: two dark boxes on the face, so every brainrot has a face.
	makePart("EyeL", scaled(Vector3.new(0.35, 0.45, 0.15)), scaled(Vector3.new(-0.45, 2.0, 0.85)), Color3.fromRGB(20, 20, 20), model)
	makePart("EyeR", scaled(Vector3.new(0.35, 0.45, 0.15)), scaled(Vector3.new(0.45, 2.0, 0.85)), Color3.fromRGB(20, 20, 20), model)

	-- The character's own accessories, straight from the config.
	for _, extra in ipairs(character.Extras) do
		makePart(extra.Name, scaled(extra.Size), scaled(extra.Offset), extra.Color, model, extra.Shape, extra.Material)
	end

	-- Mutation: a coloured glow and a neon trim ring at the feet, so a
	-- mutated brainrot is obvious from across the bay.
	if mutation then
		local glow = Instance.new("PointLight")
		glow.Name = "MutationGlow"
		glow.Color = mutation.Color
		glow.Brightness = 2
		glow.Range = 12
		glow.Parent = torso
		makePart(
			"MutationRing",
			scaled(Vector3.new(2.6, 0.25, 2.6)),
			scaled(Vector3.new(0, -1.7, 0)),
			mutation.Color,
			model,
			nil,
			"Neon"
		)
	end

	-- Name plate: name, rarity and dollars per second, readable in a
	-- screenshot and in play. The mutation, when there is one, joins it.
	local plate = Instance.new("BillboardGui")
	plate.Name = "NamePlate"
	plate.Size = UDim2.fromOffset(220, 64)
	plate.StudsOffset = Vector3.new(0, 4.4 * scale, 0)
	plate.AlwaysOnTop = true
	plate.Parent = model

	local nameLabel = Instance.new("TextLabel")
	nameLabel.Name = "Name"
	nameLabel.Size = UDim2.fromScale(1, 0.5)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text = character.Name
	nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	nameLabel.TextStrokeTransparency = 0.2
	nameLabel.TextScaled = true
	nameLabel.Font = Enum.Font.GothamBold
	nameLabel.Parent = plate

	local rateLabel = Instance.new("TextLabel")
	rateLabel.Name = "Rate"
	rateLabel.Position = UDim2.fromScale(0, 0.5)
	rateLabel.Size = UDim2.fromScale(1, 0.5)
	rateLabel.BackgroundTransparency = 1
	rateLabel.Text = Models.rateText(character, mutation)
	rateLabel.TextColor3 = Config.rarityColor(character.Rarity)
	rateLabel.TextStrokeTransparency = 0.2
	rateLabel.TextScaled = true
	rateLabel.Font = Enum.Font.GothamBold
	rateLabel.Parent = plate

	model.PrimaryPart = torso
	return model
end

-- "$50  •  $2/s" or, mutated, "GOLD $50  •  $4/s": the plate's second line.
function Models.rateText(character, mutation)
	local income = character.Income
	local prefix = ""
	if mutation then
		income *= mutation.Multiplier
		prefix = string.upper(mutation.Name) .. " "
	end
	return string.format("%s$%d  •  $%d/s", prefix, character.Price, income)
end

-- A short price tag for the belt: "$50" in the rarity colour.
function Models.priceText(character)
	return string.format("$%d", character.Price)
end

return Models
