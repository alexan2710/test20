
local mType = Game.createMonsterType("Snorunt")
local pokemon = {}
pokemon.eventFile = false -- will try to load the file example.lua in data/scripts/pokemons/events
pokemon.eventFile = "default" -- will try to load the file test.lua in data/scripts/pokemons/events
pokemon.description = "a Snorunt"
pokemon.experience = 2988
pokemon.outfit = {
    lookType = 1609
}

pokemon.health = 1937
pokemon.maxHealth = pokemon.health
pokemon.race = "ice"
pokemon.race2 = "none"
pokemon.corpse = 27933
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
{id = "snowball", chance = 8000000, maxCount = 13},
{id = "ice orb", chance = 3250000, maxCount = 1},
}

pokemon.moves = {
	{name = "melee", power = 3, interval = 2000},
    {name = "Bite", power = 9, interval = 10000},
    {name = "Ice Shards", power = 7, interval = 10000},
    {name = "Ice Fang", power = 10, interval = 10000},
    {name = "Ice Wind", power = 7, interval = 25000},
    {name = "Ice Beam", power = 12, interval = 20000},
    {name = "Frost Power", power = 25, interval = 40000},
}



pokemon.attacks = {
	{name = "melee", power = 3, interval = 2000, chance = 100},
    {name = "Bite", power = 9, interval = 10000, chance = 100},
    {name = "Ice Shards", power = 7, interval = 10000, chance = 100},
    {name = "Ice Fang", power = 10, interval = 10000, chance = 100},
    {name = "Ice Wind", power = 7, interval = 25000, chance = 100},
    {name = "Ice Beam", power = 12, interval = 20000, chance = 100},
    {name = "Frost Power", power = 25, interval = 40000, chance = 100},
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
