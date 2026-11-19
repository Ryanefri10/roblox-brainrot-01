-- BrainrotConfig: one shared source of truth for Brainrot Bay.
-- The server (world, spawner, base, shop, wave) and the client (HUD and
-- shop UI) all read these values, so the screenshots, the HUD and the 3D
-- world always agree. Colours are "RRGGBB" strings and extras are
-- positional { name, size, offset, colour, shape?, material? } so the
-- whole cast stays small enough for the dossier to show it whole.

local Config = {}

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

Config.Characters = {
	{ Id = "sir-quacksalot", Name = "Sir Quacksalot", Rarity = "Common",
		Price = 50, Income = 2, Weight = 20, Scale = 1, Body = "FFDC3C", Head = "FFDC3C",
		Blurb = "A duck knight. Quacks. Jousts. Pays rent.",
		Extras = {
			{ "Beak", { 1.2, 0.5, 0.8 }, { 0, 0.1, 1.1 }, "FF8C00" },
			{ "Helmet", { 2.2, 0.8, 2.2 }, { 0, 1.5, 0 }, "9696A0" },
			{ "Plume", { 0.4, 1.0, 0.4 }, { 0, 2.3, 0 }, "DC2828" },
			{ "Sword", { 0.3, 2.2, 0.3 }, { 1.4, 0.4, 0.4 }, "C8C8D2" },
			{ "Shield", { 0.3, 1.6, 1.2 }, { -1.3, 0.2, 0.3 }, "5A6EC8" },
		} },
	{ Id = "noodle-ninja", Name = "Noodle Ninja", Rarity = "Common",
		Price = 120, Income = 5, Weight = 16, Scale = 1, Body = "F5EBD2", Head = "F5EBD2",
		Blurb = "Silent. Slippery. Extra chilli.",
		Extras = {
			{ "Headband", { 2.2, 0.4, 2.2 }, { 0, 1.2, 0 }, "DC2828" },
			{ "HeadbandTail", { 0.4, 1.2, 0.3 }, { 0.9, 0.8, -1.0 }, "DC2828" },
			{ "Noodle1", { 0.3, 1.4, 0.3 }, { -0.6, 0.2, 1.0 }, "FFD75A" },
			{ "Noodle2", { 0.3, 1.1, 0.3 }, { 0.5, 0.3, 1.0 }, "FFD75A" },
			{ "Belt", { 1.8, 0.4, 1.8 }, { 0, -0.6, 0 }, "1E1E1E" },
		} },
	{ Id = "dj-pickle", Name = "DJ Pickle", Rarity = "Rare",
		Price = 400, Income = 12, Weight = 14, Scale = 1, Body = "5AC83C", Head = "6EDC46",
		Blurb = "Drops beats. Drops brine. Never drops the bass.",
		Extras = {
			{ "HeadphoneL", { 0.5, 1.0, 1.0 }, { -1.2, 1.0, 0 }, "19191E" },
			{ "HeadphoneR", { 0.5, 1.0, 1.0 }, { 1.2, 1.0, 0 }, "19191E" },
			{ "HeadphoneBand", { 2.6, 0.4, 0.6 }, { 0, 1.9, 0 }, "19191E" },
			{ "Shades", { 1.8, 0.4, 0.3 }, { 0, 1.1, 1.0 }, "0F0F0F" },
			{ "Turntable", { 2.0, 0.5, 1.4 }, { 0, -1.6, 1.2 }, "19191E" },
		} },
	{ Id = "madame-boba", Name = "Madame Boba", Rarity = "Rare",
		Price = 800, Income = 22, Weight = 12, Scale = 1, Body = "D28CB4", Head = "E6B4C8",
		Blurb = "Reads your pearls. Charges by the sip.",
		Extras = {
			{ "BobaCup", { 1.4, 1.2, 1.4 }, { 0, 2.0, 0 }, "F0DCC8" },
			{ "Straw", { 0.25, 1.4, 0.25 }, { 0.4, 2.6, 0.2 }, "FF5078" },
			{ "Pearl1", { 0.4, 0.4, 0.4 }, { -0.6, 0.6, 1.0 }, "281914" },
			{ "Pearl2", { 0.4, 0.4, 0.4 }, { 0.6, 0.6, 1.0 }, "281914" },
			{ "Pearl3", { 0.4, 0.4, 0.4 }, { 0, 0.2, 1.0 }, "281914" },
			{ "Hat", { 2.6, 0.3, 2.6 }, { 0, 1.5, 0 }, "963C78" },
		} },
	{ Id = "captain-croissant", Name = "Captain Croissant", Rarity = "Epic",
		Price = 2000, Income = 50, Weight = 11, Scale = 1, Body = "DCA03C", Head = "EBB450",
		Blurb = "Sails the butter seas. Flaky, but loyal.",
		Extras = {
			{ "CaptainHat", { 2.4, 0.5, 2.4 }, { 0, 1.8, 0 }, "F5F5F0" },
			{ "HatBrim", { 2.8, 0.25, 2.8 }, { 0, 1.55, 0 }, "F5F5F0" },
			{ "CroissantL", { 1.2, 0.8, 0.8 }, { -1.3, 0.6, 0 }, "C88C32" },
			{ "CroissantR", { 1.2, 0.8, 0.8 }, { 1.3, 0.6, 0 }, "C88C32" },
			{ "EpauletteL", { 0.7, 0.3, 0.7 }, { -1.1, 1.2, 0 }, "FFD700" },
			{ "EpauletteR", { 0.7, 0.3, 0.7 }, { 1.1, 1.2, 0 }, "FFD700" },
		} },
	{ Id = "turbo-tofu", Name = "Turbo Tofu", Rarity = "Epic",
		Price = 4500, Income = 100, Weight = 10, Scale = 1, Body = "F5F5EB", Head = "FAFAF5",
		Blurb = "Zero to sixty in one wobble.",
		Extras = {
			{ "Headband", { 2.2, 0.4, 2.2 }, { 0, 1.3, 0 }, "2878FF" },
			{ "Bolt", { 0.5, 1.6, 0.3 }, { 0, 0.2, 1.05 }, "FF3C3C", nil, "Neon" },
			{ "BoltTop", { 0.9, 0.5, 0.3 }, { 0, 0.9, 1.05 }, "FF3C3C", nil, "Neon" },
			{ "ShoeL", { 0.9, 0.5, 1.4 }, { -0.6, -1.9, 0.3 }, "FF3C3C" },
			{ "ShoeR", { 0.9, 0.5, 1.4 }, { 0.6, -1.9, 0.3 }, "FF3C3C" },
		} },
	{ Id = "bubblegum-bandit", Name = "Bubblegum Bandit", Rarity = "Legendary",
		Price = 12000, Income = 250, Weight = 7, Scale = 1, Body = "FF78B4", Head = "FF96C8",
		Blurb = "Steals the scene. Blows a bubble. Vanishes.",
		Extras = {
			{ "Bubble", { 1.6, 1.6, 1.6 }, { 0, 0.6, 1.2 }, "FF8CC8", "Ball", "Neon" },
			{ "Mask", { 1.9, 0.5, 0.3 }, { 0, 1.2, 1.0 }, "141414" },
			{ "Bandana", { 2.2, 0.5, 2.2 }, { 0, 1.7, 0 }, "141414" },
			{ "MoneyBag", { 1.2, 1.4, 1.0 }, { -1.4, -0.8, 0.6 }, "D2B478" },
			{ "BagTie", { 0.5, 0.5, 0.5 }, { -1.4, 0.1, 0.6 }, "FFD700" },
		} },
	{ Id = "professor-poutine", Name = "Professor Poutine", Rarity = "Legendary",
		Price = 25000, Income = 500, Weight = 6, Scale = 1, Body = "966432", Head = "AA783C",
		Blurb = "PhD in gravy. Lectures in cheese curds.",
		Extras = {
			{ "GradCap", { 2.6, 0.3, 2.6 }, { 0, 1.9, 0 }, "141414" },
			{ "GradTop", { 1.4, 0.3, 1.4 }, { 0, 2.1, 0 }, "141414" },
			{ "Tassel", { 0.2, 1.0, 0.2 }, { 1.2, 1.6, 0.6 }, "FFD700" },
			{ "Curd1", { 0.5, 0.5, 0.5 }, { -0.7, 0.5, 1.0 }, "FFE678" },
			{ "Curd2", { 0.5, 0.5, 0.5 }, { 0.7, 0.3, 1.0 }, "FFE678" },
			{ "Book", { 1.4, 0.3, 1.0 }, { 1.3, -0.4, 0.6 }, "782828" },
		} },
	{ Id = "mecha-mango", Name = "Mecha Mango", Rarity = "Mythic",
		Price = 60000, Income = 1200, Weight = 3, Scale = 1.1, Body = "FF9628", Head = "FFAA3C",
		Blurb = "Half fruit. Half machine. All juice.",
		Extras = {
			{ "ArmorL", { 0.6, 1.2, 1.4 }, { -1.3, 0.8, 0 }, "A0A5AF" },
			{ "ArmorR", { 0.6, 1.2, 1.4 }, { 1.3, 0.8, 0 }, "A0A5AF" },
			{ "Core", { 0.9, 0.9, 0.3 }, { 0, 0.4, 1.05 }, "50DCFF", "Ball", "Neon" },
			{ "Antenna", { 0.2, 1.4, 0.2 }, { 0, 2.4, 0 }, "A0A5AF" },
			{ "AntennaTip", { 0.5, 0.5, 0.5 }, { 0, 3.1, 0 }, "FF3C3C", "Ball", "Neon" },
			{ "Visor", { 1.8, 0.5, 0.3 }, { 0, 1.2, 1.0 }, "50DCFF", nil, "Neon" },
		} },
	{ Id = "sultan-samosa", Name = "Sultan Samosa", Rarity = "Mythic",
		Price = 120000, Income = 2500, Weight = 2.5, Scale = 1.1, Body = "E6B43C", Head = "F0C85A",
		Blurb = "Rules the snack court. Crispy decrees only.",
		Extras = {
			{ "Turban", { 2.3, 0.9, 2.3 }, { 0, 1.7, 0 }, "FFD700" },
			{ "Jewel", { 0.6, 0.6, 0.3 }, { 0, 1.7, 1.15 }, "FF3C78", "Ball", "Neon" },
			{ "Cape", { 2.0, 2.6, 0.3 }, { 0, 0.2, -1.1 }, "B41E3C" },
			{ "Sash", { 2.1, 0.4, 0.1 }, { 0, 0.2, 1.05 }, "FF3C3C" },
			{ "Scepter", { 0.3, 2.4, 0.3 }, { 1.5, 0.2, 0.4 }, "FFD700" },
			{ "ScepterTop", { 0.7, 0.7, 0.7 }, { 1.5, 1.5, 0.4 }, "FFD700", "Ball" },
		} },
	{ Id = "tung-tung-sahur", Name = "Tung Tung Sahur", Rarity = "Mythic",
		Price = 180000, Income = 4000, Weight = 1.2, Scale = 1.25, Body = "8C5A28", Head = "A06A32",
		Blurb = "Three knocks. One log. Zero mercy.",
		Extras = {
			{ "Bat", { 0.4, 3.0, 0.4 }, { 1.6, 0.6, 0.3 }, "D8C8A0" },
			{ "Cap", { 2.2, 0.5, 2.2 }, { 0, 1.7, 0 }, "2E4A2E" },
			{ "CapBrim", { 2.2, 0.3, 1.0 }, { 0, 1.5, 1.0 }, "2E4A2E" },
			{ "Belt", { 2.0, 0.4, 2.0 }, { 0, -0.6, 0 }, "1E1E1E" },
			{ "ShoeL", { 0.9, 0.5, 1.4 }, { -0.6, -1.9, 0.3 }, "3C2A1A" },
			{ "ShoeR", { 0.9, 0.5, 1.4 }, { 0.6, -1.9, 0.3 }, "3C2A1A" },
		} },
	{ Id = "king-kebab", Name = "King Kebab", Rarity = "Secret",
		Price = 300000, Income = 8000, Weight = 0.5, Scale = 1.45, Body = "8C4628", Head = "A05A32",
		Blurb = "The boss of the bay. One skewer to rule them all.",
		Extras = {
			{ "CrownBase", { 2.4, 0.5, 2.4 }, { 0, 1.8, 0 }, "FFD700" },
			{ "CrownSpike1", { 0.4, 1.0, 0.4 }, { -0.9, 2.4, 0 }, "FFD700" },
			{ "CrownSpike2", { 0.4, 1.2, 0.4 }, { 0, 2.5, 0 }, "FFD700" },
			{ "CrownSpike3", { 0.4, 1.0, 0.4 }, { 0.9, 2.4, 0 }, "FFD700" },
			{ "Skewer", { 0.25, 0.25, 5.0 }, { 0, 0.4, 0 }, "C8C8D2" },
			{ "Cape", { 2.4, 3.0, 0.3 }, { 0, 0.2, -1.2 }, "78001E" },
			{ "Gem", { 0.8, 0.8, 0.3 }, { 0, 0.6, 1.1 }, "00FFC8", "Ball", "Neon" },
		} },
}

function Config.findCharacter(id)
	for _, character in ipairs(Config.Characters) do
		if character.Id == id then
			return character
		end
	end
	return nil
end

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

Config.Mutations = {
	{ Name = "Gold", Chance = 0.08, Multiplier = 2, Color = Color3.fromRGB(255, 215, 0) },
	{ Name = "Diamond", Chance = 0.03, Multiplier = 5, Color = Color3.fromRGB(120, 220, 255) },
	{ Name = "Rainbow", Chance = 0.01, Multiplier = 10, Color = Color3.fromRGB(255, 80, 200) },
	{ Name = "Lava", Chance = 0.003, Multiplier = 25, Color = Color3.fromRGB(255, 80, 0) },
}

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

function Config.brainrotIncome(character, mutation, rebirthMultiplier)
	local income = character.Income
	if mutation then
		income *= mutation.Multiplier
	end
	return income * (rebirthMultiplier or 1)
end

Config.StartCash = 500
Config.BaseSlots = 8
Config.RebirthRequiredTotalEarned = 50000
Config.RebirthCashAfter = 500
Config.RebirthMultiplierPerRebirth = 0.5

-- Missions: the game's goal, shown as a checklist on the left of the
-- screen. Finish all 5 and you WIN — the game has a clear ending.
-- Kinds: "bought" = brainrots owned (anywhere), "based" = brainrots
-- standing on your base, "earned" = TotalEarned dollars.
Config.Missions = {
	{ Id = "buy-first", Kind = "bought", Target = 1, Reward = 250, Text = "Buy your first brainrot" },
	{ Id = "earn-1000", Kind = "earned", Target = 1000, Reward = 500, Text = "Earn $1,000 in total" },
	{ Id = "own-four", Kind = "based", Target = 4, Reward = 1000, Text = "Put 4 brainrots on your base" },
	{ Id = "earn-5000", Kind = "earned", Target = 5000, Reward = 2000, Text = "Earn $5,000 in total" },
	{ Id = "fill-base", Kind = "based", Target = 8, Reward = 5000, Text = "Fill your base: 8/8 brainrots" },
}

Config.Belt = {
	StartZ = -58,
	EndZ = 52,
	Width = 10,
	TopY = 1,
	Speed = 1.5,
	SpawnIntervalSeconds = 4,
	DespawnAfterSeconds = 75,
}

Config.Plots = {
	Count = 8,
	Radius = 52,
	AngleOffsetDegrees = 22.5,
	Size = 18,
	FloorTopY = 1,
}

function Config.plotCenter(index)
	local angle = math.rad(Config.Plots.AngleOffsetDegrees + (index - 1) * (360 / Config.Plots.Count))
	return Vector3.new(math.cos(angle) * Config.Plots.Radius, 0, math.sin(angle) * Config.Plots.Radius)
end

function Config.pointInPlot(point, index)
	local center = Config.plotCenter(index)
	return math.abs(point.X - center.X) <= Config.Plots.Size / 2
		and math.abs(point.Z - center.Z) <= Config.Plots.Size / 2
end

Config.IslandRadius = 85
Config.SpawnPoint = Vector3.new(0, 2, 68)

Config.Wave = {
	CycleSeconds = 90,
	WarningSeconds = 10,
	SweepSeconds = 8,
	WallHeight = 26,
	WallThickness = 6,
}

Config.Lock = {
	DurationSeconds = 30,
	CooldownSeconds = 60,
}

Config.Steal = {
	ChannelSeconds = 10,
}

return Config
