local REVIVE_COUNT = 6

function processPokemonRevive(ball, player)
    local summonName = ball:getSpecialAttribute("pokeName")
    local pokeLevel = ball:getSpecialAttribute("pokeLevel")
    local pokeCard = ball:getSpecialAttribute("pokeCard") or 0

    local status_poke = statusGainFormula(pokeLevel)
    local bonus = (pokeCard ~= 0) and (status_poke * cardsInfo[pokeCard] / 100) or 0
    local total = status_poke + bonus

    ball:setSpecialAttribute("pokeHealth", MonsterType(summonName):getHealth() * total * 103)
    ball:setSpecialAttribute("isBeingUsed", 0) -- Define como não usado

    local ballKey = getBallKey(ball:getId())
    ball:transform(balls[ballKey].usedOff) -- Transforma para o estado não usado
    
    -- Resetar todos os cooldowns das skills
    for i = 1, 12 do
        ball:setSpecialAttribute("cd" .. i, 0)
    end
    
    -- Atualizar a interface do pokébar
    doSendPokeTeamByClient(player:getId())
end

function summonPokemon(player, ball)
    local pokeName = ball:getSpecialAttribute("pokeName")
    if not pokeName then return end

    local summon = Game.createMonster(pokeName, player:getPosition(), false, true)
    if summon then
        summon:setMaster(player)
        ball:setSpecialAttribute("isBeingUsed", 1) -- Define como usado
        local ballKey = getBallKey(ball:getId())
        ball:transform(balls[ballKey].usedOn) -- Transforma para o estado usado
    end
end

function onUse(player, item, fromPosition, target, toPosition, isHotkey)
    if not target then return false end

    -- Usar o revive em si mesmo
    if target == player then
        local ball = player:getUsingBall()
        if not ball or not ball:isPokeball() then
            return player:sendCancelMessage("Você não possui um Pokémon ativo.")
        end

        -- Recolhe o Pokémon
        local summons = player:getSummons()
        for _, summon in ipairs(summons) do
            if summon:getMaster() == player then
                summon:remove()
            end
        end

        -- Revive e reseta
        processPokemonRevive(ball, player)
        item:remove(1)

        -- Solta novamente após 300ms
        addEvent(function()
            summonPokemon(player, ball)
        end, 300)

        player:getPosition():sendMagicEffect(CONST_ME_MAGIC_GREEN)
        doSendPokeTeamByClient(player:getId())
        return true
    end

    -- Usar diretamente em uma pokebola
    if target:isItem() and target:isPokeball() then
        local usingBall = player:getUsingBall()
        if usingBall and usingBall == target and #player:getSummons() > 0 then
            return player:sendCancelMessage("Você não pode usar revive na sua pokébola ativa.")
        end

        processPokemonRevive(target, player)
        item:remove(1)
        player:getPosition():sendMagicEffect(CONST_ME_MAGIC_GREEN)
        doSendPokeTeamByClient(player:getId())
        return true
    end

    player:sendCancelMessage("Você só pode usar o revive em si mesmo ou em uma pokébola.")
    return false
end
