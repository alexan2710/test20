
local mType = Game.createMonsterType("Alakazam")
local pokemon = {}
pokemon.eventFile = false -- will try to load the file example.lua in data/scripts/pokemons/events
pokemon.eventFile = "default" -- will try to load the file test.lua in data/scripts/pokemons/events
pokemon.description = "a Alakazam"
pokemon.experience = 6752
pokemon.outfit = {
    lookType = 65
}

pokemon.health = 16156
pokemon.maxHealth = pokemon.health
pokemon.race = "psychic"
pokemon.race2 = "none"
pokemon.corpse = 26926
pokemon.speed = 180
pokemon.maxSummons = 0

pokemon.changeTarget = {
    interval = 4*1000,
    chance = 20
}
pokemon.wild = {
    health = pokemon.health * 1.8,
    maxHealth = pokemon.health * 1.8,
    speed = 380  -- Pode ajustar a velocidade se necessario
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
    pokemonRank = "T2",
    funcao = "burstdmg",
    hasShiny = 1,
    hasMega = 0,
    moveMagicAttackBase = 160,
    moveMagicDefenseBase = 130,
    catchChance = 10,
    canControlMind = 0,
    canLevitate = 0,
    canLight = 0,
    canCut = 0,
    canSmash = 0,
    canDig = 0,
    canTeleport = 1,
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
{id = "seed", chance = 5000000, maxCount = 235,},
{id = "enchanted gem", chance = 8000000, maxCount = 13},
{id = "future orb", chance = 3250000, maxCount = 1},
{id = "enigma stone", chance = 8000000, maxCount = 1},
}

pokemon.moves = {
	{name = "melee", power = 3, interval = 2000},
    {name = "Calm Mind", power = 7, interval = 40000},
    {name = "Confusion", power = 7, interval = 12000},
    {name = "Psychic", power = 7, interval = 20000},
    {name = "Psybeam", power = 17, interval = 40000},
    {name = "Psycho Cut", power = 25, interval = 60000},
    {name = "Future Sight", power = 7, interval = 30000},
    {name = "Psyshock", power = 18, interval = 40000},
    {name = "Kinesis", power = 7, interval = 40000},
}

pokemon.attacks = {
	{name = "melee", power = 3, interval = 2000, chance = 100},
    {name = "Calm Mind", power = 7, interval = 40000, chance = 100},
    {name = "Confusion", power = 7, interval = 12000, chance = 100},
    {name = "Psychic", power = 7, interval = 20000, chance = 100},
    {name = "Psybeam", power = 17, interval = 40000, chance = 100},
    {name = "Psycho Cut", power = 25, interval = 60000, chance = 100},
    {name = "Future Sight", power = 7, interval = 30000, chance = 100},
    {name = "Psyshock", power = 18, interval = 40000, chance = 100},
    {name = "Kinesis", power = 7, interval = 40000, chance = 100},
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
