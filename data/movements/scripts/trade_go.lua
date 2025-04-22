function onStepIn(creature, item, position, fromPosition)
    if not creature:isPlayer() then
        return true
    end

    local player = creature:getPlayer()
    local summons = player:getSummons()
    local teleportPosition = Position(1695, 2747, 11) -- Coordenadas do PvP
    local cityConfig = {
        [1650] = 1111, -- cerulean
        [1651] = 2222, -- saffron
        [1652] = 3333, -- celadon
        [1653] = 4444, -- Vermilion
        [1654] = 5555, -- Lavender
        [1655] = 6666, -- Fuchsia
        [1656] = 7777, -- Pewter
        [1657] = 8881, -- Viridian
        [1658] = 9991, -- Cinnabar
        [1660] = 9992 -- Mandarin
    }

    local storageValue = cityConfig[item.actionid]
    if storageValue then
        -- Teleportar summon se existir
        if #summons > 0 then
            for _, summon in ipairs(summons) do
                summon:teleportTo(teleportPosition)
            end
        end
        -- Teleportar jogador
        player:teleportTo(teleportPosition)
        player:setStorageValue(storageValue, 4)
		teleportPosition:sendMagicEffect(212)
    end
    return true
end
