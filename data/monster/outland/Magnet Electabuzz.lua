
local mType = Game.createMonsterType("Magnet Electabuzz")
local pokemon = {}
pokemon.eventFile = false -- will try to load the file example.lua in data/scripts/pokemons/events
pokemon.eventFile = "default" -- will try to load the file test.lua in data/scripts/pokemons/events
pokemon.description = "a Electabuzz"
pokemon.experience = 1
pokemon.outfit = {
    lookType = 125
}

pokemon.health = 18556
pokemon.maxHealth = pokemon.health
pokemon.race = "electric"
pokemon.race2 = "none"
pokemon.corpse = 0
pokemon.speed = 180
pokemon.maxSummons = 0

pokemon.changeTarget = {
    interval = 4*1000,
    chance = 20
}
pokemon.wild = {
    health = pokemon.health * 1.6,
    maxHealth = pokemon.health * 1.6,
    speed = 220
}

pokemon.flags = {
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
    moveMagicAttackBase = 140,
    moveMagicDefenseBase = 157,
    catchChance = 0,
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
}

pokemon.moves = {
	{name = "melee", power = 3, interval = 2000},
    {name = "Swift", power = 5, interval = 15000},
    {name = "Thunderbolt", power = 5, interval = 20000},
    {name = "Thunder Punch", power = 5, interval = 25000},
    {name = "Thunder Shock", power = 5, interval = 10000},
    {name = "Thunder Wrath", power = 5, interval = 30000},
    {name = "Electrify", power = 5, interval = 40000},
    {name = "Flame Charge", power = 12, interval = 50000},
    {name = "Mamaragan", power = 5, interval = 70000},
    {name = "Vital Spirit", power = 5, interval = 60000},
}



pokemon.attacks = {
	{name = "melee", power = 3, interval = 2000, chance = 100},
    {name = "Swift", power = 5, interval = 15000, chance = 100},
    {name = "Thunderbolt", power = 5, interval = 20000, chance = 100},
    {name = "Thunder Punch", power = 5, interval = 25000, chance = 100},
    {name = "Thunder Shock", power = 5, interval = 10000, chance = 100},
    {name = "Thunder Wrath", power = 5, interval = 30000, chance = 100},
    {name = "Electrify", power = 5, interval = 40000, chance = 100},
    {name = "Flame Charge", power = 12, interval = 50000, chance = 100},
    {name = "Mamaragan", power = 5, interval = 70000, chance = 100},
    {name = "Vital Spirit", power = 5, interval = 60000, chance = 100},
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
