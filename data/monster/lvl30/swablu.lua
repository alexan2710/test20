
local mType = Game.createMonsterType("Swablu")
local pokemon = {}
pokemon.eventFile = false -- will try to load the file example.lua in data/scripts/pokemons/events
pokemon.eventFile = "default" -- will try to load the file test.lua in data/scripts/pokemons/events
pokemon.description = "a Swablu"
pokemon.experience = 4924
pokemon.outfit = {
    lookType = 1581
}

pokemon.health = 1937
pokemon.maxHealth = pokemon.health
pokemon.race = "normal"
pokemon.race2 = "flying"
pokemon.corpse = 27905
pokemon.speed = 180
pokemon.maxSummons = 0

pokemon.changeTarget = {
    interval = 4*1000,
    chance = 20
}
pokemon.wild = {
    health = pokemon.health * 1.4,
    maxHealth = pokemon.health * 1.4,
    speed = 220
}

pokemon.flags = {
    minimumLevel = 30,
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
    moveMagicAttackBase = 10,
    moveMagicDefenseBase = 15,
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
{id = "straw", chance = 8000000, maxCount = 4},
{id = "rubber ball", chance = 3250000, maxCount = 1},
{id = "rubber ball", chance = 8000000, maxCount = 13},
{id = "bitten apple", chance = 3250000, maxCount = 1},
}

pokemon.moves = {
	{name = "melee", power = 3, interval = 2000},
    {name = "Peck", power = 7, interval = 10000},
    {name = "Pluck", power = 12, interval = 10000},
    {name = "Sing", power = 0, interval = 70000},
    {name = "Dragon Breath", power = 15, interval = 25000},
    {name = "Dragon Mist", power = 15, interval = 40000},
    {name = "Roost", power = 20, interval = 80000},
    {name = "Tailwind", power = 7, interval = 30000},
    {name = "Safeguard", power = 7, interval = 40000},
}



pokemon.attacks = {
	{name = "melee", power = 3, interval = 2000, chance = 100},
    {name = "Peck", power = 7, interval = 10000, chance = 100},
    {name = "Pluck", power = 12, interval = 10000, chance = 100},
    {name = "Sing", power = 0, interval = 70000, chance = 100},
    {name = "Dragon Breath", power = 15, interval = 25000, chance = 100},
    {name = "Dragon Mist", power = 15, interval = 40000, chance = 100},
    {name = "Roost", power = 20, interval = 80000, chance = 100},
    {name = "Tailwind", power = 7, interval = 30000, chance = 100},
    {name = "Safeguard", power = 7, interval = 40000, chance = 100},
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
