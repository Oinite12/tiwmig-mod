local simple_event = F_TWMG.add_simple_event

-- Iterate through all Jokers in groups of G_TWMG.infinite_joker_iterator.group_size
local infinite_joker_iterator = function()
    -- G.STATE == 2 is the main scoring sequence
    if not (G and G.jokers and G.jokers.cards) or G.STATE == 2 then
        G_TWMG.infinite_joker_iterator.index = 0
        return
    end

    if #G.jokers.cards < 1 or (G_TWMG.infinite_joker_iterator.index*G_TWMG.infinite_joker_iterator.group_size + 1) > #G.jokers.cards then
        G_TWMG.infinite_joker_iterator.index = 0
        return
    end

    for offset = 1, G_TWMG.infinite_joker_iterator.group_size do
        local i = G_TWMG.infinite_joker_iterator.index*G_TWMG.infinite_joker_iterator.group_size + offset
        if i > #G.jokers.cards then
            G_TWMG.infinite_joker_iterator.index = 0
            return
        end

        -- G_TWMG.infinite_joker_iterator.funcs is where all the code for joker iteration takes place in
        for _,v in pairs(G_TWMG.infinite_joker_iterator.funcs) do v(i) end

    end

    G_TWMG.infinite_joker_iterator.index = G_TWMG.infinite_joker_iterator.index + 1
end

-- Iterate through all Collection Jokers
local infinite_collection_joker_iterator = function()
    if not (G and G.your_collection) then return end
    for _,row in ipairs(G.your_collection) do if row.cards then
        local joker_c = row.cards
        -- START
        for i=1,#joker_c do
            if i > 1 and joker_c[i-1].label == "j_tiwmig_commenting_out" and not joker_c[i-1].debuff then
                SMODS.debuff_card(joker_c[i], true, "tiwmig_commenting_out")
            else
                SMODS.debuff_card(joker_c[i], false, "tiwmig_commenting_out")
            end
        end
        -- END
    end end
end

local game_upd8_hook = Game.update
function Game:update(dt)
    game_upd8_hook(self, dt)

    infinite_collection_joker_iterator()
    infinite_joker_iterator()
end

-- Card:calculate_joker value interception (many thanks to Airtoum for the idea and code for this)
local card_calcj_hook = Card.calculate_joker -- preserving previous iteration of calculate_joker
function Card:calculate_joker(context) -- THIS is what will be called by various events instead
    local return_value = card_calcj_hook(self, context)

    if not return_value then
        -- Large-Small Boulder
            -- Rank-based Jokers should only trigger once per card;
            -- this conditional catches the lower-rank case, if the default-rank case does not result in anything
        if (context.other_card and 
            context.other_card.base and 
            context.other_card.base.id and 
            #SMODS.find_card("j_tiwmig_large_small_boulder") > 0
        ) then
            local oc = context.other_card
            oc.base.id = oc.base.id == 2 and 14 or math.max(oc.base.id - 1, 2)
            return_value = card_calcj_hook(self, context)
            oc.base.id = oc.base.id == 14 and 2 or math.min(oc.base.id + 1, 14)

        elseif (context.scoring_hand and
            #SMODS.find_card("j_tiwmig_large_small_boulder") > 0
        ) then
            for i = 1, #context.scoring_hand do
                local oc = context.scoring_hand[i]
                oc.base.id = oc.base.id == 2 and 14 or math.max(oc.base.id - 1, 2)
            end
            return_value = card_calcj_hook(self, context)
            for i = 1, #context.scoring_hand do
                local oc = context.scoring_hand[i]
                oc.base.id = oc.base.id == 14 and 2 or math.min(oc.base.id + 1, 14)
            end
        end
    end

    return return_value
end

local card_add_hook = Card.add_to_deck
function Card:add_to_deck(from_debuff)
    card_add_hook(self, from_debuff)
    if self.config.center.poutine_fusion then
        F_TWMG.start_poutine_fusion(self)
    end
end

local gf_checkbuyspace = G.FUNCS.check_for_buy_space
function G.FUNCS.check_for_buy_space(card)
    if card.config.center.poutine_fusion then
        local fusion_parts = {}
        for _,recipe in pairs(card.config.center.poutine_fusion) do
            fusion_parts[recipe[1]] = true
        end
        if F_TWMG.has_cards(fusion_parts, false, {keys_type = "set"}) then
            return true
        else
            return gf_checkbuyspace(card)
        end
    else
        return gf_checkbuyspace(card)
    end
end