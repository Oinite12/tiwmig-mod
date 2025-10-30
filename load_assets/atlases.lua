
local card_atlases = {
    "placeholders",
    "jokers",
    "characters"
}

---------------------
-- Card-sized sprites
---------------------
for _, key in ipairs(card_atlases) do
    SMODS.Atlas {
        key = key,
        path = key .. ".png",
        px = 71, py = 95
    }
end

G_TWMG.placeholder = {
    joker = {x=0, y=0}
}

-----------
-- Mod icon
-----------
SMODS.Atlas {
    key = "modicon",
    path = "modicon.png",
    px = 34, py = 34,
}