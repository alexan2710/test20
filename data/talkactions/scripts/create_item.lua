local invalidIds = {
	1, 2, 3, 4, 5, 6, 7, 10, 11, 13, 14, 15, 19, 21, 26, 27, 28, 35, 43
}

function onSay(player, words, param)
	if not player:getGroup():getAccess() then
		return true
	end

	if player:getAccountType() < ACCOUNT_TYPE_GOD then
		return false
	end

	local split = param:splitTrimmed(",")
	if not split[1] then
		player:sendCancelMessage("Você precisa especificar o nome ou ID do item.")
		return false
	end

	local itemType = ItemType(split[1])
	if not itemType or itemType:getId() == 0 then
		local itemId = tonumber(split[1])
		if itemId then
			itemType = ItemType(itemId)
		end

		if not itemType or itemType:getId() == 0 or itemType:getId() == 8893 then
			player:sendCancelMessage("Não existe um item com esse nome ou ID.")
			return false
		end
	end

	if table.contains(invalidIds, itemType:getId()) then
		player:sendCancelMessage("Esse item não pode ser criado.")
		return false
	end

	local count = tonumber(split[2])
	if count then
		if itemType:isStackable() then
			count = math.min(10000, math.max(1, count))
		elseif not itemType:isFluidContainer() then
			count = math.min(100, math.max(1, count))
		else
			count = math.max(0, count)
		end
	else
		count = itemType:isFluidContainer() and 0 or 1
	end

	local result = player:addItem(itemType:getId(), count)
	if result then
		if not itemType:isStackable() then
			if type(result) == "table" then
				for _, item in ipairs(result) do
					item:decay()
				end
			else
				result:decay()
			end
		end
		player:getPosition():sendMagicEffect(CONST_ME_MAGIC_GREEN)
	else
		player:sendCancelMessage("Erro ao adicionar o item.")
	end

	return false
end
