
local mType = Game.createMonsterType("Clefairy")
local pokemon = {}
pokemon.eventFile = false -- will try to load the file example.lua in data/scripts/pokemons/events
pokemon.eventFile = "default" -- will try to load the file test.lua in data/scripts/pokemons/events
pokemon.description = "a Clefairy"
pokemon.experience = 625
pokemon.outfit = {
    lookType = 35
}

pokemon.health = 2897
pokemon.maxHealth = pokemon.health
pokemon.race = "fairy"
pokemon.race2 = "none"
pokemon.corpse = 26896
pokemon.speed = 180
pokemon.maxSummons = 0

pokemon.changeTarget = {
    interval = 4*1000,
    chance = 20
}
pokemon.wild = {
    health = pokemon.health * 1.8,
    maxHealth = pokemon.health * 1.8,
    speed = 220
}

pokemon.flags = {
    minimumLevel = 40,
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
    moveMagicAttackBase = 65,
    moveMagicDefenseBase = 55,
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
{id = "rubber ball", chance = 8000000, maxCount = 13},
{id = "comb", chance = 1950000, maxCount = 1},
{id = "heart stone", chance = 150000, maxCount = 1},
}

pokemon.moves = {
	{name = "melee", power = 3, interval = 2000},
    {name = "Double Slap", power = 7, interval = 5000},
    {name = "Body Slam", power = 9, interval = 30000},
    {name = "Sing", power = 0, interval = 70000},
    {name = "Multi-Slap", power = 7, interval = 20000},
    {name = "Great Love", power = 15, interval = 60000},
    {name = "Healarea", power = 7, interval = 80000},
    {name = "Metronome", power = 15, interval = 40000},
    {name = "Defense Curl", power = 0, interval = 60000},
}



pokemon.attacks = {
	{name = "melee", power = 3, interval = 2000, chance = 100},
    {name = "Double Slap", power = 7, interval = 5000, chance = 100},
    {name = "Body Slam", power = 9, interval = 30000, chance = 100},
    {name = "Sing", power = 0, interval = 70000, chance = 100},
    {name = "Multi-Slap", power = 7, interval = 20000, chance = 100},
    {name = "Great Love", power = 15, interval = 60000, chance = 100},
    {name = "Healarea", power = 7, interval = 80000, chance = 100},
    {name = "Metronome", power = 15, interval = 40000, chance = 100},
    {name = "Defense Curl", power = 0, interval = 60000, chance = 100},
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
