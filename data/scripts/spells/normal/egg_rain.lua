local SHOT_COUNT = 25
local SHOT_DELAY = 50
local MISSILE_EFFECT = 13

local AREA_WIND = {
    {1, 1, 1, 1, 1, 1, 1},
    {1, 1, 1, 1, 1, 1, 1},
    {1, 1, 1, 1, 1, 1, 1},
    {1, 1, 1, 3, 1, 1, 1},
    {1, 1, 1, 1, 1, 1, 1},
    {1, 1, 1, 1, 1, 1, 1},
    {1, 1, 1, 1, 1, 1, 1}
}

local combat = createCombatObject()
combat:setParameter(COMBAT_PARAM_TYPE, COMBAT_NORMALDAMAGE)
combat:setStringParameter(COMBAT_PARAM_STRING_SPELLNAME, "Egg Rain")
combat:setArea(createCombatArea(AREA_WIND))

local spell = Spell(SPELL_INSTANT)

local function applyDamageInArea(creature_id)
    local creature = Creature(creature_id)
    if creature then
        local creaturePos = creature:getPosition()
        combat:execute(creature, Variant(creaturePos))
    end
end

local function doShotDownEffect(toPos)
    toPos:sendMagicEffect(383)
end

local function doShotUp(fromPos, toPos, effect, nextToPosition)
    doSendDistanceShoot(fromPos, toPos, effect)
    addEvent(doSendDistanceShoot, 75, toPos, nextToPosition, effect)
    addEvent(doShotDownEffect, 400, nextToPosition)
end

local function doShot(count, creature_id)
    if count <= 0 then return end

    local creature = Creature(creature_id)
    if not creature then return end

    for i = 1, SHOT_COUNT do
        addEvent(function()
            local creature = Creature(creature_id)
            if not creature then return end

            local creaturePos = creature:getPosition()
            local randomOffsetX = math.random(-3, 3)
            local randomOffsetY = math.random(-3, 3)
            local targetPos = creaturePos + Position(randomOffsetX, randomOffsetY, 0)
            local upwardPos = targetPos - Position(9 + math.random(-2, 2), 9 + math.random(-2, 2), 0)
            
            doShotUp(creaturePos, upwardPos, MISSILE_EFFECT, targetPos)
        end, i * SHOT_DELAY)
    end

    -- Verificando se a criatura ainda existe antes de agendar o evento de aplicar dano
    addEvent(function()
        if Creature(creature_id) then
            applyDamageInArea(creature_id)
        end
    end, SHOT_COUNT * SHOT_DELAY)
end

function spell.onCastSpell(creature, variant)
    doShot(SHOT_COUNT, creature:getId())
    return true
end

spell:name("Egg Rain")
spell:words("#Egg Rain#")
spell:isAggressive(true)
spell:needLearn(false)
spell:register()
