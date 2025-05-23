
local mType = Game.createMonsterType("Raichu")
local pokemon = {}
pokemon.eventFile = false -- will try to load the file example.lua in data/scripts/pokemons/events
pokemon.eventFile = "default" -- will try to load the file test.lua in data/scripts/pokemons/events
pokemon.description = "a Raichu"
pokemon.experience = 4583
pokemon.outfit = {
    lookType = 26
}

pokemon.health = 14796
pokemon.maxHealth = pokemon.health
pokemon.race = "electric"
pokemon.race2 = "none"
pokemon.corpse = 26887
pokemon.speed = 350
pokemon.maxSummons = 0

pokemon.changeTarget = {
    interval = 4*1000,
    chance = 20
}
pokemon.wild = {
    health = pokemon.health * 1.8,
    maxHealth = pokemon.health * 1.8,
    speed = 450
}

pokemon.flags = {
    minimumLevel = 80,
    attackable = true,
    summonable = true,
    passive = false,
    hostile = true,
    convinceable = true,
    illusionable = true,
    canPushItems = false,
    canPushCreatures = false,
    targetDistance = 1,
    staticAttackChance = 97,
    pokemonRank = "",
    hasShiny = 1,
    hasMega = 0,
    moveMagicAttackBase = 165,
    moveMagicDefenseBase = 115,
    catchChance = 250,
    canControlMind = 0,
    canLevitate = 0,
    canLight = 0,
    canCut = 0,
    canSmash = 0,
    canDig = 0,
    canTeleport = 0,
    canBlink = 0,
    isSurfable = 0,
    isRideable = 0,
    isFlyable = 0,
}

pokemon.events = {
    "MonsterHealthChange"
}
pokemon.summons = {}

pokemon.voices = {
    interval = 5000,
    chance = 65,
    {text = "ABUUUH!", yell = FALSE},
}

pokemon.loot = {
{id = "screw", chance = 8000000, maxCount = 13},
{id = "electric box", chance = 3250000, maxCount = 1},
{id = "thunder stone", chance = 150000, maxCount = 1}
}

pokemon.moves = {
	{name = "melee", power = 2, interval = 2000, chance = 100},
    {name = "Swift", power = 9, interval = 15000, chance = 100},
    {name = "Thunder Shock", power = 9, interval = 10000, chance = 100},
    {name = "Thunderbolt", power = 12, interval = 25000, chance = 100},
    {name = "Volt Tackle", power = 15, interval = 40000, chance = 100},
    {name = "Wild Charge", power = 20, interval = 50000, chance = 100},
    {name = "Thunder Wrath", power = 25, interval = 35000, chance = 100},
    {name = "Electric Storm", power = 30, interval = 60000, chance = 100},
    {name = "Flash", power = 0, interval = 40000, chance = 100},
}



pokemon.attacks = {
	{name = "melee", power = 2, interval = 2000, chance = 100},
    {name = "Swift", power = 9, interval = 15000, chance = 100},
    {name = "Thunder Shock", power = 9, interval = 10000, chance = 100},
    {name = "Thunderbolt", power = 12, interval = 25000, chance = 100},
    {name = "Volt Tackle", power = 15, interval = 40000, chance = 100},
    {name = "Wild Charge", power = 15, interval = 50000, chance = 100},
    {name = "Thunder Wrath", power = 25, interval = 35000, chance = 100},
    {name = "Electric Storm", power = 30, interval = 60000, chance = 100},
    {name = "Flash", power = 0, interval = 40000, chance = 100},
}



pokemon.defenses = {}

pokemon.elements = {}

pokemon.immunities = {}

mType.onThink = function(pokemon, interval)
end

mType.onAppear = function(pokemon, creature)
end

mType.onDisappear = function(pokemon, creature)
end

mType.onMove = function(pokemon, creature, fromPosition, toPosition)
end

mType.onSay = function(pokemon, creature, type, message)
end

mType:register(pokemon)
