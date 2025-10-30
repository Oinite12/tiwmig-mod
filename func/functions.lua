local simple_event = F_TWMG.add_simple_event

-- 1. MISCELLANEOUS
-- 2. POUTINE FUSION
-- 3. INFINITE JOKER ITERATOR

-----------------------
---- MISCELLANEOUS ----
-----------------------

-- The standard name of extra card layers in func/multi-layer cards.lua.
---@param type string
---@param id string|number
---@return string
F_TWMG.layer_name = function(type, id)
    return "tiwmig_" .. type .. "_layer_" .. tostring(id)
end

-- Shorthand (and readable function) for pinch-effect card destruction.
---@param card Card
---@return nil
F_TWMG.food_eat = function(card)
    SMODS.destroy_cards(card, nil, nil, true)
end

-- Checks if the player is holding any of the listed cards.
---@param keys string[]
---@param count_debuffed boolean
---@return boolean
F_TWMG.has_cards = function (keys, count_debuffed)
    -- Taken from SMODS code
    if not G.jokers or not G.jokers.cards then return false end

    local key_set = {}
    for _,key in ipairs(keys) do key_set[key] = true end

    for _, area in ipairs(SMODS.get_card_areas('jokers')) do
        if area.cards then
            for _,card in pairs(area.cards) do
                if (
                    card
                    and type(card) == 'table'
                    and key_set[card.config.center.key]
                    and (count_debuffed or not card.debuff)
                ) then return true end
            end
        end
    end
    return false
end



------------------------
---- POUTINE FUSION ----
------------------------

-- Fuse two cards into a new product.
---@param card Card
---@param target Card
---@param sum string
---@return nil
F_TWMG.poutine_fusion = function(card, target, sum)
    local card_edition   = card.edition and card.edition.type
    local target_edition = target.edition and target.edition.type
    local sum_edition = {}

    --[[
    Edition priority:
    - Negative, if either card or target are
    - Polychrome, if either card or target are
    - Holo, if either card or target are
    - Foil, if either card or target are
    - Target's edition
    - Card's edition
    For modded edition support
    ]]
    if card_edition == "negative" or target_edition == "negative" then
        sum_edition.negative = true
    elseif card_edition == "polychrome" or target_edition == "polychrome" then
        sum_edition.polychrome = true
    elseif card_edition == "holo" or target_edition == "holo" then
        sum_edition.holo = true
    elseif card_edition == "foil" or target_edition == "foil" then
        sum_edition.foil = true
    elseif target_edition ~= nil then sum_edition[target_edition] = true
    elseif card_edition ~= nil then sum_edition[card_edition] = true
    end

    -- Pause before doing the fusion for extra oompf
    simple_event('after', 1, function ()
        F_TWMG.food_eat(card) -- Using food_eat for convenience
        F_TWMG.food_eat(target)
        SMODS.add_card{
            key = sum,
            edition = sum_edition,
            no_edition = true
        }
    end)
end

-- Checks to see if a card can be fused with any other card.
---@param card Card
---@param recipe_table ([string, string])[]
---@return nil
F_TWMG.define_poutine_fusions = function(card, recipe_table)
    -- This system grants higher priority to items of lower index
    simple_event('after', 0.25, function ()
        for __,recipe in ipairs(recipe_table) do
            local other_card_id  = recipe[1]
            local result_card_id = recipe[2]
            if next(SMODS.find_card(other_card_id)) then
                local other_card = next(SMODS.find_card(other_card_id)) --[[@as Card]]
                if not (
                    card.debuff
                    or other_card.debuff
                    or card.ability.being_fused
                    or other_card.ability.being_fused
                ) then
                    card.ability.being_fused = true
                    other_card.ability.being_fused = true
                    F_TWMG.poutine_fusion(card, other_card, result_card_id)
                end
            end
        end
    end)
end



---------------------------------
---- INFINITE JOKER ITERATOR ----
---------------------------------

-- All functions in this table must take i, the Joker index
G_TWMG.infinite_joker_iterator.funcs = {
    tiwmig = function(i)
        local joker_c = G.jokers.cards

        if i > 1 and joker_c[i-1].config.center.key == "j_tiwmig_commenting_out" and not joker_c[i-1].debuff then
            SMODS.debuff_card(G.jokers.cards[i], true, "tiwmig_commenting_out")
        else
            SMODS.debuff_card(G.jokers.cards[i], false, "tiwmig_commenting_out")
        end
    end,
}