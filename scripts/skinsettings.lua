--[[data:
-- base
    base_prefab = ""

    base_atlas = "",
    base_image = "",
    base_bank = "",
    base_build = "",
    base_anim = "idle",
    -- base_loop = "",

    -- skin
    altas = "",
    image = "",
    bank = "",
    build = "",
    anim = "",
    namestring = STRINGS.SKIN_NAMES.name,
    -- loop = "",

-- optional
    rarity  -- "loyal"
    type    -- "item"
    custom_init_fn
    custom_clear_fn

-- Default
    skin_tags
    build_name_override
    bigportrait
    rarity_modifier
    skins
    skin_sound
    is_restricted
    granted_items
    marketable
    release_group
    linked_beard
    share_bigportrait_name
]]
--[[
    instance =
    {
        base_prefab = "instance",

        base_atlas = "images/inventoryimages/base.xml",
        base_image = "base",
        base_bank = "base",
        base_build = "base",
        base_anim = "idle",

        altas = "images/inventoryimages/skin.xml",
        image = "skin",
        bank = "skin",
        build = "skin",
        anim = "idle",
        namestring = STRINGS.SKIN_NAMES.INSTANCE
    },
]]
local p = "images/inventoryimages/"
return {
    medpot_spa =
    {
        -- base
        base_prefab = "succulent_medpot",
        base_atlas = p.."succulent_medpot.xml",
        base_image = "succulent_medpot",
        base_bank = "succulent_medpot",
        base_build = "succulent_medpot",
        base_anim = "idle",
        -- base_loop = "idle",
        -- rarity = "Elegant",

        -- skin
        altas = p.."medpot_spa.xml",
        image = "medpot_spa",
        bank = "medpot_spa",
        build = "medpot_spa",
        anim = "idle",
        namestring = STRINGS.SKIN_NAMES.MEDPOT_SPA
        -- loop = "",

        -- custom_init_fn = "",
        -- custom_clear_fn = "",
    },
    largepot_forma =
    {
        base_prefab = "succulent_largepot",

        base_atlas = p.."succulent_largepot.xml",
        base_image = "succulent_largepot",
        base_bank = "succulent_farm",
        base_build = "succulent_farm",
        base_anim = "plant_4_idle",

        -- altas = p.."largepot_forma.xml",
        image = "largepot_forma",
        bank = "succulent_farm",
        build = "succulent_farm",
        anim = "plant_1",
        push = "plant_1_idle",
        namestring = STRINGS.SKIN_NAMES.LARGEPOT_FORMA
    },
    largepot_formb =
    {
        base_prefab = "succulent_largepot",

        base_atlas = p.."succulent_largepot.xml",
        base_image = "succulent_largepot",
        base_bank = "succulent_farm",
        base_build = "succulent_farm",
        base_anim = "plant_4_idle",

        -- altas = p.."largepot_formb.xml",
        image = "largepot_formb",
        bank = "succulent_farm",
        build = "succulent_farm",
        anim = "plant_2",
        push = "plant_2_idle",
        namestring = STRINGS.SKIN_NAMES.LARGEPOT_FORMB,
    },
    largepot_formc =
    {
        base_prefab = "succulent_largepot",

        base_atlas = p.."succulent_largepot.xml",
        base_image = "succulent_largepot",
        base_bank = "succulent_farm",
        base_build = "succulent_farm",
        base_anim = "plant_4_idle",

        -- altas = p.."largepot_formc.xml",
        image = "largepot_formc",
        bank = "succulent_farm",
        build = "succulent_farm",
        anim = "plant_3",
        push = "plant_3_idle",
        namestring = STRINGS.SKIN_NAMES.LARGEPOT_FORMC,
    },

    -- instance =
    -- {
    --     base_prefab = "instance",

    --     base_atlas = p.."base.xml",
    --     base_image = "base",
    --     base_bank = "base",
    --     base_build = "base",
    --     base_anim = "idle",

    --     altas = p.."skin.xml",
    --     image = "skin",
    --     bank = "skin",
    --     build = "skin",
    --     anim = "idle",
    --     namestring = STRINGS.SKIN_NAMES.INSTANCE
    -- },

}
