local config = {
	days = 30,
	maxDays = 45,
	price = 200000
}

function onSay(player, words, param)
	if configManager.getBoolean(configKeys.FREE_PREMIUM) then
		return true
	end

	if player:getPremiumDays() + config.days <= config.maxDays then
		if player:removeTotalMoney(config.price) then
			player:addPremiumDays(config.days)
			player:sendTextMessage(MESSAGE_INFO_DESCR, "You have bought " .. config.days .." days of premium account.")
		else
			player:sendCancelMessage("You don't have enough money, " .. config.days .. " days premium account costs " .. config.price .. " gold coins.")
			player:getPosition():sendMagicEffect(CONST_ME_POFF)
		end
	else
		player:sendCancelMessage("You can not have more than " .. config.maxDays .. " days of premium account.")
		player:getPosition():sendMagicEffect(CONST_ME_POFF)
	end
	return false
end
