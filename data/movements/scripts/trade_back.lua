function onStepIn(player, item, pos, lastPosition)
    -- Configurações
    local cidades = {
        [1111] = {coords = {x = 2592, y = 2350, z = 7}, storageValue = 0}, -- cerulean
        [2222] = {coords = {x = 2611, y = 2517, z = 7}, storageValue = 0}, -- saffron
        [3333] = {coords = {x = 2482, y = 2493, z = 6}, storageValue = 0}, -- celadon
        [4444] = {coords = {x = 2625, y = 2653, z = 7}, storageValue = 0}, -- Vermilion
        [5555] = {coords = {x = 2780, y = 2506, z = 7}, storageValue = 0}, -- Lavender
        [6666] = {coords = {x = 2685, y = 2814, z = 6}, storageValue = 0}, -- Fuchsia
        [7777] = {coords = {x = 2220, y = 2370, z = 6}, storageValue = 0}, -- Pewter
        [8881] = {coords = {x = 2221, y = 2580, z = 7}, storageValue = 0}, -- Viridian
        [9991] = {coords = {x = 2235, y = 2793, z = 6}, storageValue = 0}, -- Cinnabar
        [9992] = {coords = {x = 2521, y = 4967, z = 7}, storageValue = 0} -- Mandarin
    }

    -- Recupera o summon do jogador (se existir)
    local pk = player:getSummons()[1]

    -- Itera pelas cidades configuradas
    for storageKey, data in pairs(cidades) do
        if player:getStorageValue(storageKey) == 4 then
            -- Teleporta o summon e o jogador
            if pk then
                pk:teleportTo(data.coords)
            end
            player:teleportTo(data.coords)
			Position(data.coords):sendMagicEffect(212)

            -- Atualiza o valor de storage
            player:setStorageValue(storageKey, data.storageValue)
            break -- Sai do loop após encontrar e processar o armazenamento correto
        end
    end

    return true
end