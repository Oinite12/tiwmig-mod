local simple_event = F_TWMG.add_simple_event

----------------------
-- Generic Brand Joker
----------------------
SMODS.Joker { key = "generic_brand",
    config = {
        extra = {
            discount = 3,
        },
    },

    loc_vars = function(self, info_queue, card)
        local key = nil
        if card.ability.extra.discount < 0 then key = "j_tiwmig_generic_brand_gouged" end
        -- "All shop prices are #1#% off (rounded up)"
        return {
            key = key,
            vars = {
                card.ability.extra.discount
            }
        }
    end,

    atlas = "jokers",
    pos = {x=0, y=0},

    rarity = 2,
    cost = 4,
    unlocked = true,
    discovered = true,

    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,

    add_to_deck = function(self, card, from_debuff)
        F_TWMG.set_generic_discount()
    end,

    remove_from_deck = function(self, card, from_debuff)
        F_TWMG.set_generic_discount()
    end,

    calculate = function(self, card, context)
        if context.beat_boss then
            card.ability.extra.discount = card.ability.extra.discount - 1
            simple_event(nil, nil, function ()
                card:juice_up()
                play_sound('generic1', 1, 0.75)
            end)
        end
    end
    -- Additional functionality in calc_on_mod
}

---------------
-- Bag of Chips
---------------
SMODS.Joker { key = "bag_of_chips",
    config = {
        extra = {
            multiplier = 2,
        },
    },


    atlas = "jokers",
    pos = {x=1, y=0},

    rarity = 2,
    cost = 5,
    unlocked = true,
    discovered = true,

    blueprint_compat = true,
    eternal_compat = false,
    perishable_compat = true,

    calculate = function(self, card, context)
        -- G.STATE of 1 is SELECTING_HAND, i.e. when you're selecting a hand
        if context.selling_self and G.STATE == 1 then
            play_sound('highlight2', 1 + math.random()*0.1, 0.7)
            card:juice_up()
            ease_chips(card.ability.extra.multiplier*G.GAME.chips)
            simple_event(nil, nil, function ()
                play_sound('chips2')
                if (G.GAME.chips >= G.GAME.blind.chips) then
                    G.STATE = G.STATES.HAND_PLAYED
                    G.STATE_COMPLETE = true
                    end_round()
                end
            end)
        end
    end,
}

-- Supplementary function:

-- A shorthand for poutine components counting down or getting eaten.
---@param card Card
---@param colour table
---@return table
local function poutine_component_countdown(card, colour)
    local eaten = card.ability.extra.countdown - 1 <= 0
    if eaten then
        F_TWMG.food_eat(card) -- Function to apply eaten effect (includes self-deletion)
    else
        card.ability.extra.countdown = card.ability.extra.countdown - 1
    end
    return {
        message = localize(eaten and 'k_tiwmig_poutine_eaten' or 'k_tiwmig_poutine_eating'),
        colour = colour
    }
end

---------------
-- French Fries
---------------
SMODS.Joker { key = "french_fries",
    config = {
        extra = {
            chips = 50,
            countdown = 5, -- hands
        },
    },

    loc_vars = function(self, info_queue, card)
        -- "+#1# Chips for the next #2# hands; combines with #3# or #4#"
        return {vars = {
            card.ability.extra.chips,
            card.ability.extra.countdown,
            localize { type = 'name_text', key = 'j_tiwmig_gravy', set = 'Joker' },
            localize { type = 'name_text', key = 'j_tiwmig_cheese_curds', set = 'Joker' },
        }}
    end,

    atlas = "jokers",
    pos = {x=0, y=1},

    rarity = 1,
    cost = 4,
    unlocked = true,
    discovered = true,

    blueprint_compat = true,
    eternal_compat = false,
    perishable_compat = false,

    in_pool = function(self, args)
        return not F_TWMG.has_cards({
            "j_tiwmig_french_fries",
            "j_tiwmig_frite_sauce",
            "j_tiwmig_chips_n_cheese",
            "j_tiwmig_poutine"
        }, true)
    end,


    add_to_deck = function(self, card, from_debuff)
        F_TWMG.define_poutine_fusions(card, {
            {"j_tiwmig_gravy", "j_tiwmig_frite_sauce"},
            {"j_tiwmig_cheese_curds", "j_tiwmig_chips_n_cheese"},
            {"j_tiwmig_cheesy_gravy", "j_tiwmig_poutine"}
        })
    end,

    calculate = function(self, card, context)
        if context.joker_main then
            return {
                chips = card.ability.extra.chips,
            }
        end

        if context.after then
            poutine_component_countdown(card, G.C.CHIPS)
        end
    end,
}

--------
-- Gravy
--------
SMODS.Joker { key = "gravy",
    config = {
        extra = {
            mult = 8,
            countdown = 5 -- hands
        }
    },

    loc_vars = function(self, info_queue, card)
        -- "+#1# Mult for the next #2# hands; combines with #3# or #4#"
        return {vars = {
            card.ability.extra.mult,
            card.ability.extra.countdown,
            localize { type = 'name_text', key = 'j_tiwmig_cheese_curds', set = 'Joker' },
            localize { type = 'name_text', key = 'j_tiwmig_french_fries', set = 'Joker' },
        }}
    end,

    atlas = "jokers",
    pos = {x=1, y=1},

    rarity = 1,
    cost = 4,
    unlocked = true,
    discovered = true,

    blueprint_compat = true,
    eternal_compat = false,
    perishable_compat = false,

    in_pool = function(self, args)
        return not F_TWMG.has_cards({
            "j_tiwmig_gravy",
            "j_tiwmig_cheesy_gravy",
            "j_tiwmig_frite_sauce",
            "j_tiwmig_poutine"
        }, true)
    end,

    add_to_deck = function(self, card, from_debuff)
        F_TWMG.define_poutine_fusions(card, {
            {"j_tiwmig_cheese_curds", "j_tiwmig_cheesy_gravy"},
            {"j_tiwmig_french_fries", "j_tiwmig_frite_sauce"},
            {"j_tiwmig_chips_n_cheese", "j_tiwmig_poutine"}
        })
    end,

    calculate = function(self, card, context)
        if context.joker_main then
            return {
                mult = card.ability.extra.mult,
            }
        end

        if context.after then
            poutine_component_countdown(card, G.C.MULT)
        end
    end,
}

---------------
-- Cheese Curds
---------------
SMODS.Joker { key = "cheese_curds",
    config = {
        extra = {
            cash = 2,
            countdown = 5, -- hands
        },
    },

    loc_vars = function(self, info_queue, card)
        -- "+$#1# for the next #2# hands; combines with #3# or #4#"
        return {vars = {
            card.ability.extra.cash,
            card.ability.extra.countdown,
            localize { type = 'name_text', key = 'j_tiwmig_french_fries', set = 'Joker' },
            localize { type = 'name_text', key = 'j_tiwmig_gravy', set = 'Joker' },
        }}
    end,

    atlas = "jokers",
    pos = {x=2, y=1},

    rarity = 1,
    cost = 4,
    unlocked = true,
    discovered = true,

    blueprint_compat = true,
    eternal_compat = false,
    perishable_compat = false,

    in_pool = function(self, args)
        return not F_TWMG.has_cards({
            "j_tiwmig_cheese_curds",
            "j_tiwmig_chips_n_cheese",
            "j_tiwmig_cheesy_gravy",
            "j_tiwmig_poutine"
        }, true)
    end,

    add_to_deck = function(self, card, from_debuff)
        F_TWMG.define_poutine_fusions(card, {
            {"j_tiwmig_french_fries", "j_tiwmig_chips_n_cheese"},
            {"j_tiwmig_gravy", "j_tiwmig_cheesy_gravy"},
            {"j_tiwmig_frite_sauce", "j_tiwmig_poutine"}
        })
    end,

    calculate = function(self, card, context)
        if context.joker_main then
            -- Taken from To Do List source
            return {
                dollars = card.ability.extra.cash,
            }
        end

        if context.after then
            poutine_component_countdown(card, G.C.MONEY)
        end
    end,
}

--------------
-- Frite Sauce
--------------
SMODS.Joker { key = "frite_sauce",
    config = {
        extra = {
            chips = 75,
            mult = 12,
            countdown = 8, -- hands
        },
    },

    loc_vars = function(self, info_queue, card)
        -- "+#1# Chips and +#2# Mult for the next #3# hands; combines with #4#"
        return {vars = {
            card.ability.extra.chips,
            card.ability.extra.mult,
            card.ability.extra.countdown,
            localize { type = 'name_text', key = 'j_tiwmig_cheese_curds', set = 'Joker' },
        }}
    end,

    atlas = "jokers",
    pos = {x=0, y=2},

    rarity = 2,
    cost = 4,
    unlocked = true,
    discovered = true,

    blueprint_compat = true,
    eternal_compat = false,
    perishable_compat = false,

    in_pool = function(self, args)
        return false
    end,

    add_to_deck = function(self, card, from_debuff)
        F_TWMG.define_poutine_fusions(card, {
            {"j_tiwmig_cheese_curds", "j_tiwmig_poutine"}
        })
    end,

    calculate = function(self, card, context)
        if context.joker_main then
            return {
                chips = card.ability.extra.chips,
                mult = card.ability.extra.mult,
            }
        end

        if context.after then
            poutine_component_countdown(card, G.C.CHIPS)
        end
    end,
}

---------------
-- Cheesy Gravy
---------------
SMODS.Joker { key = "cheesy_gravy",
    config = {
        extra = {
            mult = 12,
            cash = 3,
            countdown = 8, -- hands
        },
    },

    loc_vars = function(self, info_queue, card)
        -- "+#1# Mult and earn $#2# for the next #3# hands; combines with #4#"
        return {vars = {
            card.ability.extra.mult,
            card.ability.extra.cash,
            card.ability.extra.countdown,
            localize { type = 'name_text', key = 'j_tiwmig_french_fries', set = 'Joker' },
        }}
    end,

    atlas = "jokers",
    pos = {x=1, y=2},

    rarity = 2,
    cost = 4,
    unlocked = true,
    discovered = true,

    blueprint_compat = true,
    eternal_compat = false,
    perishable_compat = false,

    in_pool = function(self, args)
        return false
    end,

    add_to_deck = function(self, card, from_debuff)
        F_TWMG.define_poutine_fusions(card, {
            {"j_tiwmig_french_fries", "j_tiwmig_poutine"}
        })
    end,

    calculate = function(self, card, context)
        if context.joker_main then
            return {
                mult = card.ability.extra.mult,
                dollars = card.ability.extra.cash,
            }
        end

        if context.after then
            poutine_component_countdown(card, G.C.MULT)
        end
    end,
}

------------------
-- Chips n' Cheese
------------------
SMODS.Joker { key = "chips_n_cheese",
    config = {
        extra = {
            cash = 3,
            chips = 75,
            countdown = 8, -- hands
        },
    },

    loc_vars = function(self, info_queue, card)
        -- "Earn $#1# and +#2# Chips for the next #3# hands; combines with #4#"
        return {vars = {
            card.ability.extra.cash,
            card.ability.extra.chips,
            card.ability.extra.countdown,
            localize { type = 'name_text', key = 'j_tiwmig_gravy', set = 'Joker' },
        }}
    end,

    atlas = "jokers",
    pos = {x=2, y=2},

    rarity = 2,
    cost = 4,
    unlocked = true,
    discovered = true,

    blueprint_compat = true,
    eternal_compat = false,
    perishable_compat = false,

    in_pool = function(self, args)
        return false
    end,

    add_to_deck = function(self, card, from_debuff)
        F_TWMG.define_poutine_fusions(card, {
            {"j_tiwmig_gravy", "j_tiwmig_poutine"}
        })
    end,

    calculate = function(self, card, context)
        if context.joker_main then
            -- Taken from To Do List source
            return {
                dollars = card.ability.extra.cash,
                chips = card.ability.extra.chips,
            }
        end

        if context.after then
            poutine_component_countdown(card, G.C.MONEY)
        end
    end,
}

----------
-- Poutine
----------
SMODS.Joker { key = "poutine",
    config = {
        extra = {
            chips = 100,
            mult = 16,
            cash = 4,
            countdown = 10, -- hands
        },
    },

    loc_vars = function(self, info_queue, card)
        -- "+#1# Chips, +#2# Mult, and earn $#3# for the next #4# hands"
        return {vars = {
            card.ability.extra.chips,
            card.ability.extra.mult,
            card.ability.extra.cash,
            card.ability.extra.countdown,
        }}
    end,

    atlas = "jokers",
    pos = {x=2, y=0},

    rarity = 3,
    cost = 4,
    unlocked = true,
    discovered = true,

    blueprint_compat = true,
    eternal_compat = false,
    perishable_compat = false,

    in_pool = function(self, args)
        return false
    end,

    calculate = function(self, card, context)
        if context.joker_main then
            -- Taken from To Do List source
            return {
                chips = card.ability.extra.chips,
                mult = card.ability.extra.mult,
                dollars = card.ability.extra.cash
            }
        end

        if context.after then
            poutine_component_countdown(card, G.C.PURPLE)
        end
    end,
}

--------
-- "egg"
--------
SMODS.Joker { key = "egg",
    config = {
        extra = {
            chips = 9,
        },
    },

    loc_vars = function(self, info_queue, card)
        -- "+#1# Chips"
        return {vars = {
            card.ability.extra.chips,
        }}
    end,

    atlas = "jokers",
    pos = {x=3, y=0},

    rarity = 1,
    cost = 2,
    unlocked = true,
    discovered = true,

    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,

    calculate = function(self, card, context)
        if context.joker_main then return { chips = card.ability.extra.chips } end
    end,
}

----------
-- Shotgun
----------
SMODS.Joker { key = "shotgun",
    config = {
        extra = {
            xmult = 4,
            chamber = {},
            maxshells = 8,
            initialshells = {live=0,blank=0}
        }
    },

    loc_vars = function(self, info_queue, card)
        -- "2-#1# blank and live shells are loaded;"
        -- "Shoot on play; only live shells give X#2# Mult;"
        -- "#3# live round#4#. #5# blanks."
        -- "#6# shells remain"
        local key = nil
        if card.ability.extra.initialshells.blank ~= 1 then key = "j_tiwmig_shotgun_singular" end
        return {
            key = key,
            vars = {
                card.ability.extra.maxshells,
                card.ability.extra.xmult,
                card.ability.extra.initialshells.blank,
                card.ability.extra.initialshells.live,
                #card.ability.extra.chamber,
            }
        }
    end,

    atlas = "jokers",
    pos = {x=3,y=1},
    display_size = { w = 71*1.3, h = 95*1.3 },

    rarity = 2,
    cost = 8,
    unlocked = true,
    discovered = true,

    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,

    calculate = function(self, card, context)
        if context.setting_blind and #card.ability.extra.chamber < 1 then
            -- round(a) = floor(0.5 + a)
            -- number between 2 and shells = round(rng*(shells-2)) + 2
            local total_shells = math.floor(0.5 + pseudoseed('tiwmig_shotgun_shotgun')*(card.ability.extra.maxshells - 2)) + 2
            local shell_count = {
                live = math.ceil(total_shells/2),
                blank = math.floor(total_shells/2)
            }

            -- For the messages
            -- Debug note: shells go from 8, 7, 6... 3, 2, 1
            -- print(card.ability.extra.chamber)
            card.ability.extra.initialshells.live = shell_count.live
            card.ability.extra.initialshells.blank = shell_count.blank

            while shell_count.live + shell_count.blank > 0 do
                -- Note down which of live and blank is max, and which is min
                local max_shell = shell_count.live >= shell_count.blank and "live" or "blank"
                local min_shell = max_shell == "live" and "blank" or "live"
                local shell = ""

                -- Randomly pick between live and blank
                -- We do it this way so that if one of the shells is empty,
                -- we pick the shell that's not empty *always*
                if pseudoseed('tiwmig_shotgun_loading')*(shell_count.live + shell_count.blank) < shell_count[max_shell] then
                    shell = max_shell
                else
                    shell = min_shell
                end

                -- One shell is taken from either pile and loaded into the chamber
                shell_count[shell] = shell_count[shell] - 1
                card.ability.extra.chamber[#card.ability.extra.chamber+1] = shell == "live" and 1 or 0
            end

            -- "Load" each bullet into the shotgun
            G.E_MANAGER:add_event(Event({
                trigger = "after",
                blockable = false,
                func = function()
                    for _ = 1, total_shells do
                        simple_event('after', 0.35, function ()
                            card:juice_up()
                            play_sound('generic1', 1, 0.75)
                        end)
                    end
                    return true
                end
            }))

        elseif context.joker_main and #card.ability.extra.chamber > 0 then
            -- Going from max to 1 (backwards), stating here for debug's sake
            local shell = card.ability.extra.chamber[#card.ability.extra.chamber]
            card.ability.extra.chamber[#card.ability.extra.chamber] = nil

            if shell == 1 then
                return {
                    xmult = card.ability.extra.xmult
                }
            else
                return {
                    message = localize("k_tiwmig_shotgun_blank"),
                    colour = G.C.GREY
                }
            end
        end
    end,
}

--------------------------------------------
-- Large Boulder the Size of a Small Boulder
--------------------------------------------
SMODS.Joker { key = "large_small_boulder",
    atlas = "jokers",
    pos = {x=3,y=2},

    rarity = 3,
    cost = 6,
    unlocked = true,
    discovered = true,

    blueprint_compat = false,
    eternal_compat = true,
    perishable_compat = true,

    -- Main functionality is present in Card:calculate_joker interception
}

-----------------
-- Commenting Out
-----------------
SMODS.Joker { key = "commenting_out",
    atlas = "jokers",
    pos = {x=0, y=3},

    rarity = 2,
    cost = 4,
    unlocked = true,
    discovered = true,

    blueprint_compat = false,
    eternal_compat = true,
    perishable_compat = true,

    -- Main functionality is present in the infinite joker iterator
}

------------
-- Prototype
------------
SMODS.Joker { key = "prototype",
    config = {
        extra = {
            odds = 10
        },
    },

    loc_vars = function(self, info_queue, card)
        local numerator, denominator = SMODS.get_probability_vars(card, 1, card.ability.extra.odds, 'tiwmig_prototype')
        -- "Retriggers the rightmost Joker; 1 in 10 chance this card finalizes its design"
        return {vars = {
            numerator,
            denominator
        }}
    end,

    atlas = "jokers",
    pos={x=3,y=3},
    display_size = { w = 71*1.4, h = 95*1.4 },

    rarity = 3,
    cost = 10,
    unlocked = true,
    discovered = true,

    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,

    calculate = function(self, card, context) if not context.retrigger_joker then
        if context.retrigger_joker_check and context.other_card ~= card then
            if G.jokers.cards[#G.jokers.cards] == context.other_card then return {
                message = localize('k_again_ex'),
                repetitions = 1,
                card = card
            } end

        elseif context.end_of_round and context.cardarea == G.jokers then
            if SMODS.pseudorandom_probability(card, 'tiwmig_prototype', 1, card.ability.extra.odds) then
                simple_event('after', 1, function ()
                    play_sound('tarot1')
                    card.T.w = card.T.w/1.3
                    card.T.h = card.T.h/1.3
                    card:flip()
                    card:juice_up(0.3, 0.3)
                end)
                simple_event('after', 1.25, function ()
                    card:set_ability(G.P_CENTERS["j_tiwmig_spy_phone"])
                    card:flip()
                    card:juice_up(0.3, 0.3)
                    play_sound('tarot2')
                end)
            else return {message = localize('k_nope_ex')}
            end
        end
    end end,
}

------------
-- Spy Phone
------------
SMODS.Joker { key = "spy_phone",
    config = {
        extra = {
            side = "left"
        },
    },

    loc_vars = function(self, info_queue, card)
        local key = nil
        if card.ability.extra.side == "right" then key = "j_tiwmig_spy_phone_right" end
        -- "Retriggers the left Joker, side switches every round"
        return {
            key = key,
            vars = {
                card.ability.extra.side
            }
        }
    end,

    atlas = "jokers",
    pos={x=2,y=3},

    in_pool = function (self, args)
        return false
    end,
    rarity = 3,
    cost = 16,
    unlocked = true,
    discovered = true,

    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,

    calculate = function(self, card, context)
        if context.retrigger_joker_check and not context.retrigger_joker and context.other_card ~= self then
            local offset = card.ability.extra.side == "left" and -1 or 1
            if G.jokers.cards[card.rank + offset] == context.other_card then return {
                message = localize('k_again_ex'),
                repetitions = 1,
                card = card
            } end
        elseif context.end_of_round and context.cardarea == G.jokers then
            card.ability.extra.side = card.ability.extra.side == "left" and "right" or "left"
            return {
                message = localize('k_tiwmig_switch_side')
            }
        end
    end,
}

--[[ == JOKER: Ruler of Everything, j_tiwmig_ruler_of_everything
SMODS.Joker { key = "ruler_of_everything",
    config = {
        multiplier = 2
    },

    loc_txt = {
        name = "Ruler of Everything",
        text = {
            "#1#,",
            "effect changes {C:attention}every day{}"
        }
    },

    atlas = "jokers",
    pos = {x=0, y=0},

    rarity = 2,
    cost = 5,
    unlocked = true,
    discovered = true,

    blueprint_compat = true,
    eternal_compat = false,
    perishable_compat = true,
}
]]--