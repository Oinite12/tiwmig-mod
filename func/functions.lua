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

F_TWMG.set_generic_discount = function ()
    local function discount_group(group)
        if group and group.cards then for _,shop_card in pairs(group.cards) do
            -- Reset cost to normal value (including discount vouchers) to start proper discounting
            shop_card:set_cost()

            -- THEN apply discounts
            local generics = SMODS.find_card("j_tiwmig_generic_brand")
            for _,generic in pairs(generics) do
                shop_card.cost = shop_card.cost*(1 - generic.ability.extra.discount)
            end

            -- Finally do floor
            shop_card.cost = math.ceil(shop_card.cost)
        end end
    end

    simple_event(nil, nil, function ()
        discount_group(G.shop_jokers)
        discount_group(G.shop_booster)
        discount_group(G.shop_vouchers)
    end)
end



------------------------
---- POUTINE FUSION ----
------------------------

local function determine_poutine_fusion_edition(card, target)
    local card_edition   = card.edition and card.edition.key
    local target_edition = target.edition and target.edition.key

    if not card_edition then return target_edition end -- This returns nil if not target_edition
    if not target_edition then return card_edition end

    local card_edition_obj = G.P_CENTERS[card_edition]
    local target_edition_obj = G.P_CENTERS[target_edition]

    --[[
    Edition priority: Editions further down the Collection are prioritized,
    but editions that increase card limit are further prioritized
    The bigger the card limit the higher the priority
    ]]
    local card_priority = 0
    local card_priority_ohm = 0 -- ohm > all numbers
    local target_priority = 0
    local target_priority_ohm = 0

    -- Determine standard priority
    for i,edition in ipairs(G.P_CENTER_POOLS.Edition) do
        if edition == card_edition_obj then
            card_priority = i
        end
        if edition == target_edition_obj then
            target_priority = i
        end
        if card_priority > 0 and target_priority > 0 then
            break
        end
    end

    -- Determine omega priority
    if card_edition_obj.config and card_edition_obj.config.card_limit then
        card_priority_ohm = card_edition_obj.config.card_limit
    end
    if target_edition_obj.config and target_edition_obj.config.card_limit then
        target_priority_ohm = target_edition_obj.config.card_limit
    end

    -- Compare
    if card_priority_ohm > target_priority_ohm then
        return card_edition
    end
    if target_priority_ohm > card_priority_ohm then
        return target_edition
    end
    if card_priority >= target_priority then -- also if card edition == target edition
        return card_edition
    end
    if target_priority > card_priority then -- useless conditional but better for readibility
        return target_edition
    end
end

-- Fuse two cards into a new product.
---@param card Card
---@param target Card
---@param sum string
---@return nil
F_TWMG.poutine_fusion = function(card, target, sum)
    -- Pause before doing the fusion for extra oompf
    simple_event('after', 1, function ()
        F_TWMG.food_eat(card) -- Using food_eat for convenience
        F_TWMG.food_eat(target)
        SMODS.add_card{
            key = sum,
            edition = determine_poutine_fusion_edition(card, target),
            no_edition = true
        }
    end)
end

-- Checks to see if a card can be fused with any other card.
---@param card Card
---@return nil
F_TWMG.start_poutine_fusion = function(card)
    -- This system grants higher priority to items of lower index
    simple_event('after', 0.25, function ()
        for __, recipe in ipairs(card.config.center.poutine_fusion) do
            local other_card_id  = recipe[1]
            local result_card_id = recipe[2]
            local _,other_card = next(SMODS.find_card(other_card_id))

            if other_card and not (
                card.debuff
                or other_card.debuff
                or card.ability.being_fused
                or other_card.ability.being_fused
            ) then
                card.ability.being_fused = true
                other_card.ability.being_fused = true
                F_TWMG.poutine_fusion(card, other_card, result_card_id)
                return
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