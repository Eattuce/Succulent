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

local p = "images/inventoryimages/"

local function FarmInitfn(inst, skin)
    if inst.SetSkin ~= nil then
        inst:SetSkin()
    end
end

local function FarmClearfn(inst, skin)
    if inst.SetBasic ~= nil then
        inst:SetBasic()
    end
end


return {
    medpot_spa =
    {
        base_prefab = "succulent_medpot",
        basebank = "succulent_medpot",
        baseanim = "idle",
        bank = "medpot_sp",
        build = "medpot_sp",
        anim = "idle_a",
        rarity = "Rainbow",
        type = "item",
        name = STRINGS.SKIN_NAMES.MEDPOT_SPA,
        altas = p.."medpot_spa.xml",
        image = "medpot_spa",
    },
    medpot_spb =
    {
        base_prefab = "succulent_medpot",
        basebank = "succulent_medpot",
        baseanim = "idle",
        bank = "medpot_sp",
        build = "medpot_sp",
        anim = "idle_b",
        rarity = "Bottle",
        type = "item",
        name = STRINGS.SKIN_NAMES.MEDPOT_SPB,
        altas = p.."medpot_spb.xml",
        image = "medpot_spb",
    },
    medpot_spc =
    {
        base_prefab = "succulent_medpot",
        basebank = "succulent_medpot",
        baseanim = "idle",
        bank = "medpot_sp",
        build = "medpot_sp",
        anim = "idle_c",
        rarity = "Rose",
        type = "item",
        name = STRINGS.SKIN_NAMES.MEDPOT_SPC,
        altas = p.."medpot_spc.xml",
        image = "medpot_spc",
    },
    succulentfarm_sp =
    {
        base_prefab = "succulent_farm",
        basebank = "succulent_farm",
        baseanim = "idle",
        bank = "succulentfarm_sp",
        build = "succulentfarm_sp",
        anim = "idle",
        rarity = "Bottle",
        type = "item",
        name = STRINGS.SKIN_NAMES.SUCCULENTFARM_SP,
        altas = p.."succulentfarm_sp.xml",
        image = "succulentfarm_sp",
        init_fn = FarmInitfn,
        clear_fn = FarmClearfn,
    },
    succulent_largepot_sp =
    {
        base_prefab = "succulent_largepot",
        basebank = "succulent_farm",
        basebuild = "succulent_farm",
        baseanim = "plant_4_idle",
        bank = "succulentfarm_sp",
        build = "succulentfarm_sp",
        anim = "plant_4_idle",
        rarity = "Bottle",
        type = "item",
        name = STRINGS.SKIN_NAMES.SUCCULENTFARM_SP,
        altas = p.."succulent_largepot_sp.xml",
        image = "succulent_largepot_sp",
        init_fn = FarmInitfn,
        clear_fn = FarmClearfn,
    },

}
