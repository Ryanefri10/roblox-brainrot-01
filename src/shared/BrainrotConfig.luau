-- BrainrotConfig: one shared source of truth for Brainrot Bay.
-- The server (world, spawner, base, shop, wave) and the client (HUD and
-- shop UI) all read these values, so the screenshots, the HUD and the 3D
-- world always agree with each other. Keep every number a designer would
-- tune in this one file: prices, rates, the cast, the world layout.

local Config = {}

-- Palette: tropical night market. Warm stall lights over dark blue water,
-- neon rarity colours so a brainrot reads at a glance from across the bay.
Config.Palette = {
	WaterBlue = Color3.fromRGB(16, 80, 160),
	DeepWater = Color3.fromRGB(10, 50, 110),
	Sand = Color3.fromRGB(232, 203, 144),
	WoodDark = Color3.fromRGB(120, 82, 50),
	WoodLight = Color3.fromRGB(178, 128, 74),
	BeltDark = Color3.fromRGB(40, 44, 60),
	BeltStripe = Color3.fromRGB(255, 205, 41),
	PlotFloor = Color3.fromRGB(88, 160, 90),
	PlotOwn = Color3.fromRGB(46, 204, 113),
	PlotWall = Color3.fromRGB(70, 110, 140),
	StallRed = Color3.fromRGB(220, 70, 70),
	StallTeal = Color3.fromRGB(40, 180, 170),
	StallPurple = Color3.fromRGB(150, 90, 220),
	LampWarm = Color3.fromRGB(255, 190, 90),
	MoonPale = Color3.fromRGB(240, 235, 200),
	WaveBlue = Color3.fromRGB(40, 140, 255),
	HudDark = Color3.fromRGB(20, 24, 40),
	HudWhite = Color3.fromRGB(255, 255, 255),
	TitleYellow = Color3.fromRGB(255, 214, 64),
	MoneyGreen = Color3.fromRGB(80, 220, 120),
	DangerRed = Color3.fromRGB(255, 70, 70),
}

-- Rarity ladder, in climb order, with the colour every label uses.
Config.Rarities = {
	{ Name = "Common", Color = Color3.fromRGB(180, 180, 180) },
	{ Name = "Rare", Color = Color3.fromRGB(60, 170, 255) },
	{ Name = "Epic", Color = Color3.fromRGB(175, 85, 255) },
	{ Name = "Legendary", Color = Color3.fromRGB(255, 200, 0) },
	{ Name = "Mythic", Color = Color3.fromRGB(255, 60, 120) },
	{ Name = "Secret", Color = Color3.fromRGB(0, 255, 200) },
}

function Config.rarityColor(rarityName)
	for _, rarity in ipairs(Config.Rarities) do
		if rarity.Name == rarityName then
			return rarity.Color
		end
	end
	return Color3.fromRGB(255, 255, 255)
end

-- The cast: absurd, meme-born, each its own. Id is the key the shop, the
-- belt and the base all use. Weight is the spawn chance on the belt.
-- Price is what the player pays; Income is the dollars per second it
-- earns once it stands on a base. Scale grows the boss.
Config.Characters = {
	{
		Id = "sir-quacksalot", Name = "Sir Quacksalot", Rarity = "Common",
		Price = 50, Income = 2, Weight = 20, Scale = 1,
		Body = Color3.fromRGB(255, 220, 60), Head = Color3.fromRGB(255, 220, 60),
		Blurb = "A duck knight. Quacks. Jousts. Pays rent.",
		Extras = {
			{ Name = "Beak", Size = Vector3.new(1.2, 0.5, 0.8), Offset = Vector3.new(0, 0.1, 1.1), Color = Color3.fromRGB(255, 140, 0) },
			{ Name = "Helmet", Size = Vector3.new(2.2, 0.8, 2.2), Offset = Vector3.new(0, 1.5, 0), Color = Color3.fromRGB(150, 150, 160) },
			{ Name = "Plume", Size = Vector3.new(0.4, 1.0, 0.4), Offset = Vector3.new(0, 2.3, 0), Color = Color3.fromRGB(220, 40, 40) },
			{ Name = "Sword", Size = Vector3.new(0.3, 2.2, 0.3), Offset = Vector3.new(1.4, 0.4, 0.4), Color = Color3.fromRGB(200, 200, 210) },
			{ Name = "Shield", Size = Vector3.new(0.3, 1.6, 1.2), Offset = Vector3.new(-1.3, 0.2, 0.3), Color = Color3.fromRGB(90, 110, 200) },
		},
	},
	{
		Id = "noodle-ninja", Name = "Noodle Ninja", Rarity = "Common",
		Price = 120, Income = 5, Weight = 16, Scale = 1,
		Body = Color3.fromRGB(245, 235, 210), Head = Color3.fromRGB(245, 235, 210),
		Blurb = "Silent. Slippery. Extra chilli.",
		Extras = {
			{ Name = "Headband", Size = Vector3.new(2.2, 0.4, 2.2), Offset = Vector3.new(0, 1.2, 0), Color = Color3.fromRGB(220, 40, 40) },
			{ Name = "HeadbandTail", Size = Vector3.new(0.4, 1.2, 0.3), Offset = Vector3.new(0.9, 0.8, -1.0), Color = Color3.fromRGB(220, 40, 40) },
			{ Name = "Noodle1", Size = Vector3.new(0.3, 1.4, 0.3), Offset = Vector3.new(-0.6, 0.2, 1.0), Color = Color3.fromRGB(255, 215, 90) },
			{ Name = "Noodle2", Size = Vector3.new(0.3, 1.1, 0.3), Offset = Vector3.new(0.5, 0.3, 1.0), Color = Color3.fromRGB(255, 215, 90) },
			{ Name = "Belt", Size = Vector3.new(1.8, 0.4, 1.8), Offset = Vector3.new(0, -0.6, 0), Color = Color3.fromRGB(30, 30, 30) },
		},
	},
	{
		Id = "dj-pickle", Name = "DJ Pickle", Rarity = "Rare",
		Price = 400, Income = 12, Weight = 14, Scale = 1,
		Body = Color3.fromRGB(90, 200, 60), Head = Color3.fromRGB(110, 220, 70),
		Blurb = "Drops beats. Drops brine. Never drops the bass.",
		Extras = {
			{ Name = "HeadphoneL", Size = Vector3.new(0.5, 1.0, 1.0), Offset = Vector3.new(-1.2, 1.0, 0), Color = Color3.fromRGB(25, 25, 30) },
			{ Name = "HeadphoneR", Size = Vector3.new(0.5, 1.0, 1.0), Offset = Vector3.new(1.2, 1.0, 0), Color = Color3.fromRGB(25, 25, 30) },
			{ Name = "HeadphoneBand", Size = Vector3.new(2.6, 0.4, 0.6), Offset = Vector3.new(0, 1.9, 0), Color = Color3.fromRGB(25, 25, 30) },
			{ Name = "Shades", Size = Vector3.new(1.8, 0.4, 0.3), Offset = Vector3.new(0, 1.1, 1.0), Color = Color3.fromRGB(15, 15, 15) },
			{ Name = "Turntable", Size = Vector3.new(2.0, 0.5, 1.4), Offset = Vector3.new(0, -1.6, 1.2), Color = Color3.fromRGB(25, 25, 30) },
		},
	},
	{
		Id = "madame-boba", Name = "Madame Boba", Rarity = "Rare",
		Price = 800, Income = 22, Weight = 12, Scale = 1,
		Body = Color3.fromRGB(210, 140, 180), Head = Color3.fromRGB(230, 180, 200),
		Blurb = "Reads your pearls. Charges by the sip.",
		Extras = {
			{ Name = "BobaCup", Size = Vector3.new(1.4, 1.2, 1.4), Offset = Vector3.new(0, 2.0, 0), Color = Color3.fromRGB(240, 220, 200) },
			{ Name = "Straw", Size = Vector3.new(0.25, 1.4, 0.25), Offset = Vector3.new(0.4, 2.6, 0.2), Color = Color3.fromRGB(255, 80, 120) },
			{ Name = "Pearl1", Size = Vector3.new(0.4, 0.4, 0.4), Offset = Vector3.new(-0.6, 0.6, 1.0), Color = Color3.fromRGB(40, 25, 20) },
			{ Name = "Pearl2", Size = Vector3.new(0.4, 0.4, 0.4), Offset = Vector3.new(0.6, 0.6, 1.0), Color = Color3.fromRGB(40, 25, 20) },
			{ Name = "Pearl3", Size = Vector3.new(0.4, 0.4, 0.4), Offset = Vector3.new(0, 0.2, 1.0), Color = Color3.fromRGB(40, 25, 20) },
			{ Name = "Hat", Size = Vector3.new(2.6, 0.3, 2.6), Offset = Vector3.new(0, 1.5, 0), Color = Color3.fromRGB(150, 60, 120) },
		},
	},
	{
		Id = "captain-croissant", Name = "Captain Croissant", Rarity = "Epic",
		Price = 2000, Income = 50, Weight = 11, Scale = 1,
		Body = Color3.fromRGB(220, 160, 60), Head = Color3.fromRGB(235, 180, 80),
		Blurb = "Sails the butter seas. Flaky, but loyal.",
		Extras = {
			{ Name = "CaptainHat", Size = Vector3.new(2.4, 0.5, 2.4), Offset = Vector3.new(0, 1.8, 0), Color = Color3.fromRGB(245, 245, 240) },
			{ Name = "HatBrim", Size = Vector3.new(2.8, 0.25, 2.8), Offset = Vector3.new(0, 1.55, 0), Color = Color3.fromRGB(245, 245, 240) },
			{ Name = "CroissantL", Size = Vector3.new(1.2, 0.8, 0.8), Offset = Vector3.new(-1.3, 0.6, 0), Color = Color3.fromRGB(200, 140, 50) },
			{ Name = "CroissantR", Size = Vector3.new(1.2, 0.8, 0.8), Offset = Vector3.new(1.3, 0.6, 0), Color = Color3.fromRGB(200, 140, 50) },
			{ Name = "EpauletteL", Size = Vector3.new(0.7, 0.3, 0.7), Offset = Vector3.new(-1.1, 1.2, 0), Color = Color3.fromRGB(255, 215, 0) },
			{ Name = "EpauletteR", Size = Vector3.new(0.7, 0.3, 0.7), Offset = Vector3.new(1.1, 1.2, 0), Color = Color3.fromRGB(255, 215, 0) },
		},
	},
	{
		Id = "turbo-tofu", Name = "Turbo Tofu", Rarity = "Epic",
		Price = 4500, Income = 100, Weight = 10, Scale = 1,
		Body = Color3.fromRGB(245, 245, 235), Head = Color3.fromRGB(250, 250, 245),
		Blurb = "Zero to sixty in one wobble.",
		Extras = {
			{ Name = "Headband", Size = Vector3.new(2.2, 0.4, 2.2), Offset = Vector3.new(0, 1.3, 0), Color = Color3.fromRGB(40, 120, 255) },
			{ Name = "Bolt", Size = Vector3.new(0.5, 1.6, 0.3), Offset = Vector3.new(0, 0.2, 1.05), Color = Color3.fromRGB(255, 60, 60), Material = "Neon" },
			{ Name = "BoltTop", Size = Vector3.new(0.9, 0.5, 0.3), Offset = Vector3.new(0, 0.9, 1.05), Color = Color3.fromRGB(255, 60, 60), Material = "Neon" },
			{ Name = "ShoeL", Size = Vector3.new(0.9, 0.5, 1.4), Offset = Vector3.new(-0.6, -1.9, 0.3), Color = Color3.fromRGB(255, 60, 60) },
			{ Name = "ShoeR", Size = Vector3.new(0.9, 0.5, 1.4), Offset = Vector3.new(0.6, -1.9, 0.3), Color = Color3.fromRGB(255, 60, 60) },
		},
	},
	{
		Id = "bubblegum-bandit", Name = "Bubblegum Bandit", Rarity = "Legendary",
		Price = 12000, Income = 250, Weight = 7, Scale = 1,
		Body = Color3.fromRGB(255, 120, 180), Head = Color3.fromRGB(255, 150, 200),
		Blurb = "Steals the scene. Blows a bubble. Vanishes.",
		Extras = {
			{ Name = "Bubble", Size = Vector3.new(1.6, 1.6, 1.6), Offset = Vector3.new(0, 0.6, 1.2), Color = Color3.fromRGB(255, 140, 200), Shape = "Ball", Material = "Neon" },
			{ Name = "Mask", Size = Vector3.new(1.9, 0.5, 0.3), Offset = Vector3.new(0, 1.2, 1.0), Color = Color3.fromRGB(20, 20, 20) },
			{ Name = "Bandana", Size = Vector3.new(2.2, 0.5, 2.2), Offset = Vector3.new(0, 1.7, 0), Color = Color3.fromRGB(20, 20, 20) },
			{ Name = "MoneyBag", Size = Vector3.new(1.2, 1.4, 1.0), Offset = Vector3.new(-1.4, -0.8, 0.6), Color = Color3.fromRGB(210, 180, 120) },
			{ Name = "BagTie", Size = Vector3.new(0.5, 0.5, 0.5), Offset = Vector3.new(-1.4, 0.1, 0.6), Color = Color3.fromRGB(255, 215, 0) },
		},
	},
	{
		Id = "professor-poutine", Name = "Professor Poutine", Rarity = "Legendary",
		Price = 25000, Income = 500, Weight = 6, Scale = 1,
		Body = Color3.fromRGB(150, 100, 50), Head = Color3.fromRGB(170, 120, 60),
		Blurb = "PhD in gravy. Lectures in cheese curds.",
		Extras = {
			{ Name = "GradCap", Size = Vector3.new(2.6, 0.3, 2.6), Offset = Vector3.new(0, 1.9, 0), Color = Color3.fromRGB(20, 20, 20) },
			{ Name = "GradTop", Size = Vector3.new(1.4, 0.3, 1.4), Offset = Vector3.new(0, 2.1, 0), Color = Color3.fromRGB(20, 20, 20) },
			{ Name = "Tassel", Size = Vector3.new(0.2, 1.0, 0.2), Offset = Vector3.new(1.2, 1.6, 0.6), Color = Color3.fromRGB(255, 215, 0) },
			{ Name = "Curd1", Size = Vector3.new(0.5, 0.5, 0.5), Offset = Vector3.new(-0.7, 0.5, 1.0), Color = Color3.fromRGB(255, 230, 120) },
			{ Name = "Curd2", Size = Vector3.new(0.5, 0.5, 0.5), Offset = Vector3.new(0.7, 0.3, 1.0), Color = Color3.fromRGB(255, 230, 120) },
			{ Name = "Book", Size = Vector3.new(1.4, 0.3, 1.0), Offset = Vector3.new(1.3, -0.4, 0.6), Color = Color3.fromRGB(120, 40, 40) },
		},
	},
	{
		Id = "mecha-mango", Name = "Mecha Mango", Rarity = "Mythic",
		Price = 60000, Income = 1200, Weight = 3, Scale = 1.1,
		Body = Color3.fromRGB(255, 150, 40), Head = Color3.fromRGB(255, 170, 60),
		Blurb = "Half fruit. Half machine. All juice.",
		Extras = {
			{ Name = "ArmorL", Size = Vector3.new(0.6, 1.2, 1.4), Offset = Vector3.new(-1.3, 0.8, 0), Color = Color3.fromRGB(160, 165, 175) },
			{ Name = "ArmorR", Size = Vector3.new(0.6, 1.2, 1.4), Offset = Vector3.new(1.3, 0.8, 0), Color = Color3.fromRGB(160, 165, 175) },
			{ Name = "Core", Size = Vector3.new(0.9, 0.9, 0.3), Offset = Vector3.new(0, 0.4, 1.05), Color = Color3.fromRGB(80, 220, 255), Shape = "Ball", Material = "Neon" },
			{ Name = "Antenna", Size = Vector3.new(0.2, 1.4, 0.2), Offset = Vector3.new(0, 2.4, 0), Color = Color3.fromRGB(160, 165, 175) },
			{ Name = "AntennaTip", Size = Vector3.new(0.5, 0.5, 0.5), Offset = Vector3.new(0, 3.1, 0), Color = Color3.fromRGB(255, 60, 60), Shape = "Ball", Material = "Neon" },
			{ Name = "Visor", Size = Vector3.new(1.8, 0.5, 0.3), Offset = Vector3.new(0, 1.2, 1.0), Color = Color3.fromRGB(80, 220, 255), Material = "Neon" },
		},
	},
	{
		Id = "sultan-samosa", Name = "Sultan Samosa", Rarity = "Mythic",
		Price = 120000, Income = 2500, Weight = 2.5, Scale = 1.1,
		Body = Color3.fromRGB(230, 180, 60), Head = Color3.fromRGB(240, 200, 90),
		Blurb = "Rules the snack court. Crispy decrees only.",
		Extras = {
			{ Name = "Turban", Size = Vector3.new(2.3, 0.9, 2.3), Offset = Vector3.new(0, 1.7, 0), Color = Color3.fromRGB(255, 215, 0) },
			{ Name = "Jewel", Size = Vector3.new(0.6, 0.6, 0.3), Offset = Vector3.new(0, 1.7, 1.15), Color = Color3.fromRGB(255, 60, 120), Shape = "Ball", Material = "Neon" },
			{ Name = "Cape", Size = Vector3.new(2.0, 2.6, 0.3), Offset = Vector3.new(0, 0.2, -1.1), Color = Color3.fromRGB(180, 30, 60) },
			{ Name = "Sash", Size = Vector3.new(2.1, 0.4, 0.1), Offset = Vector3.new(0, 0.2, 1.05), Color = Color3.fromRGB(255, 60, 60) },
			{ Name = "Scepter", Size = Vector3.new(0.3, 2.4, 0.3), Offset = Vector3.new(1.5, 0.2, 0.4), Color = Color3.fromRGB(255, 215, 0) },
			{ Name = "ScepterTop", Size = Vector3.new(0.7, 0.7, 0.7), Offset = Vector3.new(1.5, 1.5, 0.4), Color = Color3.fromRGB(255, 215, 0), Shape = "Ball" },
		},
	},
	{
		Id = "king-kebab", Name = "King Kebab", Rarity = "Secret",
		Price = 300000, Income = 8000, Weight = 0.5, Scale = 1.45,
		Body = Color3.fromRGB(140, 70, 40), Head = Color3.fromRGB(160, 90, 50),
		Blurb = "The boss of the bay. One skewer to rule them all.",
		Extras = {
			{ Name = "CrownBase", Size = Vector3.new(2.4, 0.5, 2.4), Offset = Vector3.new(0, 1.8, 0), Color = Color3.fromRGB(255, 215, 0) },
			{ Name = "CrownSpike1", Size = Vector3.new(0.4, 1.0, 0.4), Offset = Vector3.new(-0.9, 2.4, 0), Color = Color3.fromRGB(255, 215, 0) },
			{ Name = "CrownSpike2", Size = Vector3.new(0.4, 1.2, 0.4), Offset = Vector3.new(0, 2.5, 0), Color = Color3.fromRGB(255, 215, 0) },
			{ Name = "CrownSpike3", Size = Vector3.new(0.4, 1.0, 0.4), Offset = Vector3.new(0.9, 2.4, 0), Color = Color3.fromRGB(255, 215, 0) },
			{ Name = "Skewer", Size = Vector3.new(0.25, 0.25, 5.0), Offset = Vector3.new(0, 0.4, 0), Color = Color3.fromRGB(200, 200, 210) },
			{ Name = "Cape", Size = Vector3.new(2.4, 3.0, 0.3), Offset = Vector3.new(0, 0.2, -1.2), Color = Color3.fromRGB(120, 0, 30) },
			{ Name = "Gem", Size = Vector3.new(0.8, 0.8, 0.3), Offset = Vector3.new(0, 0.6, 1.1), Color = Color3.fromRGB(0, 255, 200), Shape = "Ball", Material = "Neon" },
		},
	},
}

-- Look a character up by its Id; nil when the Id is unknown.
function Config.findCharacter(id)
	for _, character in ipairs(Config.Characters) do
		if character.Id == id then
			return character
		end
	end
	return nil
end

-- Pick a character for the belt by spawn weight. King Kebab stays very rare.
function Config.rollCharacter()
	local total = 0
	for _, character in ipairs(Config.Characters) do
		total += character.Weight
	end
	local roll = math.random() * total
	for _, character in ipairs(Config.Characters) do
		roll -= character.Weight
		if roll <= 0 then
			return character
		end
	end
	return Config.Characters[1]
end

-- Mutations: rolled on spawn, multiply income, shown as a coloured glow.
-- Chances sum to 12.3%: most brainrots spawn plain.
Config.Mutations = {
	{ Name = "Gold", Chance = 0.08, Multiplier = 2, Color = Color3.fromRGB(255, 215, 0) },
	{ Name = "Diamond", Chance = 0.03, Multiplier = 5, Color = Color3.fromRGB(120, 220, 255) },
	{ Name = "Rainbow", Chance = 0.01, Multiplier = 10, Color = Color3.fromRGB(255, 80, 200) },
	{ Name = "Lava", Chance = 0.003, Multiplier = 25, Color = Color3.fromRGB(255, 80, 0) },
}

-- Roll a mutation, or nil for a plain brainrot.
function Config.rollMutation()
	local roll = math.random()
	local running = 0
	for _, mutation in ipairs(Config.Mutations) do
		running += mutation.Chance
		if roll <= running then
			return mutation
		end
	end
	return nil
end

-- Income of one brainrot, mutation and rebirth multiplier applied.
function Config.brainrotIncome(character, mutation, rebirthMultiplier)
	local income = character.Income
	if mutation then
		income *= mutation.Multiplier
	end
	return income * (rebirthMultiplier or 1)
end

-- Economy: generous on purpose, so a first-time player finishes a full
-- loop (buy, earn, rebirth) in minutes, not hours.
Config.StartCash = 500
Config.BaseSlots = 8
Config.RebirthRequiredTotalEarned = 50000
Config.RebirthCashAfter = 500
Config.RebirthMultiplierPerRebirth = 0.5

-- The Brainrot Belt: brainrots ride it from the dock, slow enough to read
-- and to click, and linger long enough that nobody misses a good one.
-- A spawn every 4 seconds and weights that favour the climb keep the
-- whole loop (buy, earn, rebirth) inside a few minutes of play; the
-- despawn outlasts the 73 second ride down the belt.
Config.Belt = {
	StartZ = -58,
	EndZ = 52,
	Width = 10,
	TopY = 1,
	Speed = 1.5,
	SpawnIntervalSeconds = 4,
	DespawnAfterSeconds = 75,
}

-- The bay: 8 base plots in a circle around the belt, offset by half a
-- step so no plot ever sits on the belt line itself.
Config.Plots = {
	Count = 8,
	Radius = 52,
	AngleOffsetDegrees = 22.5,
	Size = 18,
	FloorTopY = 1,
}

-- Centre of base plot `index` (1-based), on the ground plane.
function Config.plotCenter(index)
	local angle = math.rad(Config.Plots.AngleOffsetDegrees + (index - 1) * (360 / Config.Plots.Count))
	return Vector3.new(math.cos(angle) * Config.Plots.Radius, 0, math.sin(angle) * Config.Plots.Radius)
end

-- Is a ground point inside plot `index` (with a small margin)?
function Config.pointInPlot(point, index)
	local center = Config.plotCenter(index)
	return math.abs(point.X - center.X) <= Config.Plots.Size / 2
		and math.abs(point.Z - center.Z) <= Config.Plots.Size / 2
end

Config.IslandRadius = 85
Config.SpawnPoint = Vector3.new(0, 2, 68)

-- Tsunami: a slow, loudly announced wave. Ten seconds of warning, a slow
-- sweep, and a safe zone every player can see: their own green base.
-- Caught outside while carrying a brainrot, you drop it; caught outside
-- empty-handed, you are only knocked back. Nothing is ever lost.
Config.Wave = {
	CycleSeconds = 90,
	WarningSeconds = 10,
	SweepSeconds = 8,
	WallHeight = 26,
	WallThickness = 6,
}

-- Base Lock: 30 seconds of protection, then a 60 second cooldown.
Config.Lock = {
	DurationSeconds = 30,
	CooldownSeconds = 60,
}

-- Steal: only from an UNLOCKED base, a 10 second channel with a bar.
Config.Steal = {
	ChannelSeconds = 10,
}

return Config
