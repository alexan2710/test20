local combat = Combat()

combat:setParameter(COMBAT_PARAM_TYPE, COMBAT_BUGDAMAGE)
combat:setParameter(COMBAT_PARAM_EFFECT, 20)
combat:setStringParameter(COMBAT_PARAM_STRING_SPELLNAME, "Bug Buzz")

local spell = Spell(SPELL_INSTANT)

function spell.onCastSpell(creature, variant)
	for _, target in ipairs(combat:getTargets(creature, variant)) do
		local targetPosition = target:getPosition()
		targetPosition:sendMagicEffect(CONST_ME_HITBYPOISON)
	end
	return true	
end

spell:name("Bug Buzz")
spell:words("###Bug Buzz###")
spell:isAggressive(true)
spell:needLearn(false)
spell:range(6)
spell:needTarget(true)
spell:register()
