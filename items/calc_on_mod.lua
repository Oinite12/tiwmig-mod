SMODS.current_mod.calculate = function (self, context)
    if (
        context.reroll_shop or
        context.starting_shop or
        (context.buying_card and context.card.ability.set == "Voucher") -- Discount vouchers
    ) then
        F_TWMG.set_generic_discount()
    end
end