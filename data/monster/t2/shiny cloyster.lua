
local mType = Game.createMonsterType("Cloyster")
local pokemon = {}
pokemon.eventFile = false -- will try to load the file example.lua in data/scripts/pokemons/events
pokemon.eventFile = "default" -- will try to load the file test.lua in data/scripts/pokemons/events
pokemon.description = "a Cloyster"
pokemon.experience = 6752
pokemon.outfit = {
    lookType = 309
}

pokemon.health = 16156
pokemon.maxHealth = pokemon.health
pokemon.race = "water"
pokemon.race2 = "ice"
pokemon.corpse = 27579
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
    minimumLevel = 100,
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
    moveMagicAttackBase = 50,
    moveMagicDefenseBase = 15,
    catchChance = 150,
    canControlMind = 0,
    canLevitate = 0,
    canLight = 0,
    canCut = 0,
    canSmash = 0,
    canDig = 0,
    canTeleport = 0,
    canBlink = 1,
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
{id = "ice stone", chance = 150000, maxCount = 1},
{id = "water gem", chance = 8000000, maxCount = 13},
{id = "water pendant", chance = 3250000, maxCount = 1},
{id = "water stone", chance = 150000, maxCount = 1},
}

pokemon.moves = {
    {name = "Lick", power = 5, interval = 30000},
    {name = "Super Sonic", power = 5, interval = 35000},
    {name = "Clamp", power = 5, interval = 10000},
    {name = "Bubbles", power = 5, interval = 10000},
    {name = "Ice Beam", power = 5, interval = 20000},
    {name = "Aurora Beam", power = 15, interval = 60000},
    {name = "Blizzard", power = 20, interval = 90000},
    {name = "Harden", power = 5, interval = 30000},
}



pokemon.attacks = {
    {name = "Lick", power = 5, interval = 30000, chance = 100},
    {name = "Super Sonic", power = 5, interval = 35000, chance = 100},
    {name = "Clamp", power = 5, interval = 10000, chance = 100},
    {name = "Bubbles", power = 5, interval = 10000, chance = 100},
    {name = "Ice Beam", power = 5, interval = 20000, chance = 100},
    {name = "Aurora Beam", power = 15, interval = 60000, chance = 100},
    {name = "Blizzard", power = 20, interval = 90000, chance = 100},
    {name = "Harden", power = 5, interval = 30000, chance = 100},
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
