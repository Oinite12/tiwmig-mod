--[[ ==  MULTI-LAYER SYSTEM
    In pos, add key "layers", which contains a table that contains sprite coordinate tables {x=0,y=0}
    These tables are ordered from bottom-most layer to top-most layer
    pos={x=0,y=0,layers={
        {x=1,y=0},
        {x=2,y=0}
    }}
    These layers are subject to edition shaders
    
    The same principle applies to soul_pos
    
    (Most code inspired/taken from Cryptid mod, which only supports an additional 2 layers per card;
    this system supports any number of layers.
    Regardless, many thanks to them for the inspiration)
]]

-- Layer count needs to be specified because keys are specifically targetted, not dynamically adjustable to each card
local max_layers = G_TWMG.max_card_layers

-- Make sprite layers all wibbly wobbly
SMODS.DrawStep({
    key = "tiwmig_main_layers",
    order = 59,
    func = function(self)
        if (
            self.config.center.pos and
            self.config.center.pos.layers and
            (self.config.center.discovered or self.bypass_discovery_center)
        ) then
            for i = 1, self.children[F_TWMG.layer_name("main",1)].layercount do
                local layer = self.children[F_TWMG.layer_name("main",i)]
                -- incorporate i to offset layers a bit so it's not all static
                local scale_mod = 0.03 + (i/100)/2 + 0.02*math.sin(1.8*G.TIMERS.REAL)
                local rotate_mod = 0.02*math.sin(1.219*G.TIMERS.REAL + (i-1)/2)
                layer:draw_shader(
                    "dissolve",
                    0,
                    nil,
                    nil,
                    self.children.center,
                    scale_mod,
                    rotate_mod,
                    nil,
                    0.1 + 0.03*math.sin(1.8*G.TIMERS.REAL),
                    nil,
                    0.6
                )
                layer:draw_shader(
                    "dissolve",
                    nil,
                    nil,
                    nil,
                    self.children.center,
                    scale_mod,
                    rotate_mod
                )
                if self.edition then for k, v in pairs(G.P_CENTER_POOLS.Edition) do
                    if self.edition[v.key:sub(3)] then
                        layer:draw_shader(v.shader, nil, nil, nil, self.children.center, scale_mod, rotate_mod)
                    end
                end end
            end
        end
    end,
	conditions = { vortex = false, facing = "front" },
})

SMODS.DrawStep({
    key = "tiwmig_soul_layers",
    order = 61,
    func = function(self)
        if (
            self.config.center.soul_pos and
            self.config.center.soul_pos.layers and
            (self.config.center.discovered or self.bypass_discovery_center)
        ) then
            for i = 1, self.children[F_TWMG.layer_name("soul",1)].layercount do
                local layer = self.children[F_TWMG.layer_name("soul",i)]
                -- incorporate i to offset layers a bit so it's not all static
                local scale_mod = 0.07 + (i/100)/2 + 0.02*math.sin(1.8*G.TIMERS.REAL)
                local rotate_mod = 0.05*math.sin(1.219*G.TIMERS.REAL + (i-1)/2)
                layer:draw_shader(
                    "dissolve",
                    0,
                    nil,
                    nil,
                    self.children.center,
                    scale_mod,
                    rotate_mod,
                    nil,
                    0.1 + 0.03*math.sin(1.8*G.TIMERS.REAL),
                    nil,
                    0.6
                )
                layer:draw_shader(
                    "dissolve",
                    nil,
                    nil,
                    nil,
                    self.children.center,
                    scale_mod,
                    rotate_mod
                )
                if self.edition then for k, v in pairs(G.P_CENTER_POOLS.Edition) do
                    if v.apply_to_float then if self.edition[v.key:sub(3)] then
                        layer:draw_shader(v.shader, nil, nil, nil, self.children.center, scale_mod, rotate_mod)
                    end end
                end end
            end
        end
    end,
	conditions = { vortex = false, facing = "front" },
})

-- This targets the keys of *children*
-- Only 25 layers are properly supported (configured at top). Without the cap, sprites won't properly stick to the main card
-- Layer count needs to be specified because keys are specifically targetted, not dynamically adjustable to each card
for i = 1,max_layers do
    SMODS.draw_ignore_keys[F_TWMG.layer_name("main",i)] = true
    SMODS.draw_ignore_keys[F_TWMG.layer_name("soul",i)] = true
end

-- Appending to Card:set_sprites so multi-layers are detected
local set_spr_func = Card.set_sprites
function Card:set_sprites(_center, _front)
    set_spr_func(self, _center, _front)

    -- Main layers - AFFECTED by edition
    if _center and _center.pos and _center.pos.layers then
        for i,coords in pairs(_center.pos.layers) do if i <= max_layers then
            self.children[F_TWMG.layer_name("main",i)] = Sprite(
                self.T.x,
                self.T.y,
                self.T.w,
                self.T.h,
                G.ASSET_ATLAS[_center.atlas or _center.set],
                coords
            )
            self.children[F_TWMG.layer_name("main",i)].role.draw_major = self
            self.children[F_TWMG.layer_name("main",i)].states.hover.can = false
            self.children[F_TWMG.layer_name("main",i)].states.click.can = false
        end end
        -- First layer stores info on how many layers actually present
        self.children[F_TWMG.layer_name("main",1)].layercount = #_center.pos.layers
    end

    -- Soul layers - NOT affected by edition
    if _center and _center.soul_pos and _center.soul_pos.layers then
        for i,coords in pairs(_center.soul_pos.layers) do if i <= max_layers then
            self.children[F_TWMG.layer_name("soul",i)] = Sprite(
                self.T.x,
                self.T.y,
                self.T.w,
                self.T.h,
                G.ASSET_ATLAS[_center.atlas or _center.set],
                coords
            )
            self.children[F_TWMG.layer_name("soul",i)].role.draw_major = self
            self.children[F_TWMG.layer_name("soul",i)].states.hover.can = false
            self.children[F_TWMG.layer_name("soul",i)].states.click.can = false
        end end
        -- First layer stores info on how many layers actually present
        self.children[F_TWMG.layer_name("soul",1)].layercount = #_center.soul_pos.layers
    end
end