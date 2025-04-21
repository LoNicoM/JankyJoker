function changeEnhancement(_card, enhancement)
    if enhancement == "lucky" then
        _card["ability"]["set"] = "Enhanced"
        _card["ability"]["name"] = "Lucky Card"
        _card["ability"]["mult"] = 20
        _card["ability"]["effect"] = "Lucky Card"
        _card["ability"]["p_dollars"] = 20
        _card["save_fields"]["center"] = "m_lucky"
    end
end

function addSeal(_card, seal)
    _card["seal"] = seal
end

function changeEdition(_card, edition)
    if edition == "polychrome" then
        _card["edition"] = {
            ["x_mult"] = 1.5,
            ["polychrome"] = true,
            ["type"] = "polychrome"
        }
        _card.extra_cost = 5
    elseif edition == "foil" then
        _card["edition"] = {
            ["type"] = "foil",
            ["foil"] = true,
            ["chips"] = 50
        }
        _card.extra_cost = 2
    elseif edition == "holo" then
        _card["edition"] = {
            ["type"] = "holo",
            ["holo"] = true,
            ["mult"] = 10
        }
        _card.extra_cost = 3
    -- No checks performed to prevent negative being applied to regular deck card. card_limit needs to be increased also which could prove difficult.
    -- An overall deck count / health check will need to be performed at the end of modifications to ensure slots are valid.
    elseif edition == "negative" then
        _card["edition"] = {
            ["type"] = "negative",
            ["negative"] = true,
        }
        _card.extra_cost = 5
    elseif edition == 'base' then
        _card["edition"] = nil
    end
end

function modifyDeckCard(_card, suit, value)

    local cardTable = {
        Ace = {
            id = 14,
            val = 11
        },
        King = {
            id = 13,
            val = 10
        },
        Queen = {
            id = 12,
            val = 10
        },
        Jack = {
            id = 11,
            val = 10
        }
    }

    _card["base"]["value"] = value
    _card["base"]["suit"] = suit
    _card["base"]["nominal"] = cardTable[value].val or tonumber(value)
    _card["base"]["original_value"] = cardTable[value].val or tonumber(value)
    _card["base"]["id"] = cardTable[value].id or tonumber(value)
    _card["base"]["name"] = value .. " of " .. suit
    _card["save_fields"]["card"] = string.sub(suit, 1, 1) .. "_" .. string.gsub(string.sub(value, 1, 1), "1", "T")
end

function removeCardDebuff(_card)
    _card["debuff"] = false
end

function removeSeededFlag(_saveData)
    _saveData['GAME']['seeded'] = nil
end

function modifyDollars(_saveData, ammount)
    _saveData.GAME.dollars = ammount
end

function changeBossBlind(_saveData, boss)

    local most_played = _saveData.GAME.current_round.most_played_poker_hand

    _saveData.BLIND.config_blind = boss
    _saveData.BLIND.name = BLINDS[boss].name
    _saveData.BLIND.debuff = BLINDS[boss].debuff
    _saveData.BLIND.mult = BLINDS[boss].mult
    _saveData.BLIND.pos = BLINDS[boss].pos
    _saveData.BLIND.dollars = BLINDS[boss].dollars
    _saveData.GAME.round_resets.blind = BLINDS[boss]
end

function removeEternal(_card)
    _card.ability.eternal = false
end

function loopCardAreas(_saveData, cardArea)
    -- prints("Fixing Deck")
    for _, card in pairs(_saveData["cardAreas"][cardArea]["cards"]) do

        if cardArea == "deck" then
            -- modifyDeckCard(card, "Spades", "King")
            -- changeEdition(card, "polychrome")
            -- changeEnhancement(card, "lucky")
            -- addSeal(card, "Red")
            -- removeCardDebuff(card)

        elseif cardArea == "jokers" then
            removeEternal(card)
        end
    end
end

function listCardAreas(_saveData, cardArea)
    printTable(_saveData["cardAreas"][cardArea], 0)
end

function alterJoker(_card, joker)

    jokerData = JOKERS[joker]

    _card.ability = {
        name = jokerData.name,
        effect = jokerData.effect,
        set = jokerData.set,
        mult = jokerData.config.mult or 0,
        h_mult = jokerData.config.h_mult or 0,
        h_x_mult = jokerData.config.h_x_mult or 0,
        h_dollars = jokerData.config.h_dollars or 0,
        p_dollars = jokerData.config.p_dollars or 0,
        t_mult = jokerData.config.t_mult or 0,
        t_chips = jokerData.config.t_chips or 0,
        x_mult = jokerData.config.Xmult or 1,
        h_size = jokerData.config.h_size or 0,
        d_size = jokerData.config.d_size or 0,
        extra = copy_table(jokerData.config.extra) or nil,
        extra_value = 0,
        type = jokerData.config.type or '',
        order = jokerData.order or nil,
        bonus = jokerData.config.bonus or 0
    }

    _card.save_fields.center = joker
    _card.base_cost = jokerData.cost
    _card.sell_cost = math.max(1, math.floor(_card.cost / 2)) + (_card.ability.extra_value or 0)
    _card.label = jokerData.name

end
