function canJoin(player)
	return player:getVocation():getId() == VOCATION_NONE or player:getVocation():getId() == 1 or player:getVocation():getId() == 2 or player:getVocation():getId() == 3 or player:getVocation():getId() == 4 or player:getVocation():getId() == 5 or player:getVocation():getId() == 6 or player:getAccountType() >= ACCOUNT_TYPE_SENIORTUTOR
end

local CHANNEL_ADVERTISING_ROOK = 6

local muted = Condition(CONDITION_CHANNELMUTEDTICKS, CONDITIONID_DEFAULT)
muted:setParameter(CONDITION_PARAM_SUBID, CHANNEL_ADVERTISING_ROOK)
muted:setParameter(CONDITION_PARAM_TICKS, 120000)

function onSpeak(player, type, message)
	if player:getAccountType() >= ACCOUNT_TYPE_GAMEMASTER then
		if type == TALKTYPE_CHANNEL_Y then
			return TALKTYPE_CHANNEL_O
		end
		return true
	end

	if player:getLevel() == 1 then
		player:sendCancelMessage("You may not speak into channels as long as you are on level 1.")
		return false
	end

	if player:getCondition(CONDITION_CHANNELMUTEDTICKS, CONDITIONID_DEFAULT, CHANNEL_ADVERTISING_ROOK) then
		player:sendCancelMessage("You may only place one offer in two minutes.")
		return false
	end
	player:addCondition(muted)

	if type == TALKTYPE_CHANNEL_O then
		if player:getAccountType() < ACCOUNT_TYPE_GAMEMASTER then
			type = TALKTYPE_CHANNEL_Y
		end
	elseif type == TALKTYPE_CHANNEL_R1 then
		if not player:hasFlag(PlayerFlag_CanTalkRedChannel) then
			type = TALKTYPE_CHANNEL_Y
		end
	end
	return type
end
