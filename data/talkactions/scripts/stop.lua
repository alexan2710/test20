local storageStop = 1000 -- Storage para controlar o estado de parado
local stopDuration = 30 -- Duração em segundos que o pokémon ficará parado

function onSay(player, words, param)
    if not player:getGroup():getAccess() then
        return true
    end

    local ball = player:getUsingBall()
    if not ball or not ball:isPokeball() then
        player:sendCancelMessage("Você não possui um Pokémon ativo.")
        return false
    end

    local summons = player:getSummons()
    if #summons == 0 then
        player:sendCancelMessage("Você não tem nenhum Pokémon ativo.")
        return false
    end

    local summon = summons[1]
    if not summon or not summon:isCreature() then
        return false
    end

    -- Verifica se o pokémon já está parado através da condição
    if summon:getCondition(CONDITION_PARALYZE) then
        player:sendCancelMessage("Seu Pokémon já está parado.")
        return false
    end

    -- Aplica uma condição de paralisia temporária mais forte
    local condition = Condition(CONDITION_PARALYZE)
    condition:setParameter(CONDITION_PARAM_TICKS, stopDuration * 1000)
    condition:setParameter(CONDITION_PARAM_SPEED, -1000) -- Reduz a velocidade ao máximo
    summon:addCondition(condition)

    -- Aplica uma condição de silêncio para evitar que o Pokémon use habilidades
    local silenceCondition = Condition(CONDITION_SILENCE)
    silenceCondition:setParameter(CONDITION_PARAM_TICKS, stopDuration * 1000)
    summon:addCondition(silenceCondition)

    -- Envia mensagem para o pokémon ficar parado
    summon:say("Fique parado!", TALKTYPE_MONSTER_SAY)

    -- Remove as condições após o tempo determinado
    addEvent(function()
        if summon and summon:isCreature() then
            summon:removeCondition(CONDITION_PARALYZE)
            summon:removeCondition(CONDITION_SILENCE)
            player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Seu Pokémon pode se mover novamente.")
        end
    end, stopDuration * 1000)

    player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Seu Pokémon ficará parado por " .. stopDuration .. " segundos.")
    return false
end 