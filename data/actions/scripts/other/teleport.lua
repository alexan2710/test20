local upFloorIds = {1386, 3678, 5543, 27640, 39299}
function onUse(player, item, fromPosition, target, toPosition, isHotkey)
	if table.contains(upFloorIds, item.itemid) then
		fromPosition:moveUpstairs()
	else
		fromPosition.z = fromPosition.z + 1
	end
	if player:isPzLocked() and Tile(fromPosition):hasFlag(TILESTATE_PROTECTIONZONE) then
		player:sendTextMessage(MESSAGE_STATUS_SMALL, Game.getReturnMessage(RETURNVALUE_PLAYERISPZLOCKED))
		return true
	end
	player:teleportTo(fromPosition, false)
	return true
end
