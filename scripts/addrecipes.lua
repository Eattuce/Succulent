GLOBAL.setmetatable(env, { __index = function(t, k) return GLOBAL.rawget(GLOBAL, k) end })
local impath = "images/inventoryimages/"

-- 增加建造站 crafting_station
local PrototyperDef =
{
    totem_real = {
        icon_atlas = "images/ui/totem_ui.xml",
        icon_image = "totem_ui.tex",
        is_crafting_station = true,
        action_str = "TOTEM",
        filter_text = STRINGS.UI.CRAFTING_STATION_FILTERS.OASISTOTEM
    },
}
for filter_name, data in pairs(PrototyperDef) do
    AddPrototyperDef(filter_name, data)
end


-- ======= --
-- 空中建筑 --
-- ======= --
-- 记空中建造模式为 3   constants.lua: BUILDMODE = { NONE = 0, LAND = 1, WATER = 2 }
local BUILDMODE_AIR = 3
-- 记水陆两用模式为 4
local BUILDMODE_LAND_WATER = 4
-- 正常检测附近的物品时,不考虑 DEPLOY_IGNORE_TAGS 里的标签,不进入判断,因此那里什么都可以建
-- 但是我们空中物品有加"NOBLOCK"标签,需要判断,因此 DEPLOY_IGNORE_TAGS 里不可以有"NOBLOCK"
local DEPLOY_IGNORE_TAGS = { "player", "FX", "INLIMBO", "DECOR", "WALKABLEPLATFORM" }
local function IsNearOther(other, pt, min_spacing_sq)
    return (other:GetDistanceSqToPoint(pt.x, 0, pt.z) < (other.deploy_extra_spacing ~= nil and math.max(other.deploy_extra_spacing * other.deploy_extra_spacing, min_spacing_sq) or min_spacing_sq)) and other:HasTag("hangingobject")
end

-- 改自 "map" IsDeployPointClear
local function IsAirClean(pt, inst, min_spacing, min_spacing_sq_fn, near_other_fn, custom_ignore_tags)
    local min_spacing_sq = min_spacing ~= nil and min_spacing * min_spacing or nil
    near_other_fn = near_other_fn or IsNearOther
    for i, v in ipairs(TheSim:FindEntities(pt.x, 0, pt.z, math.max(0, min_spacing), nil, custom_ignore_tags ~= nil and custom_ignore_tags or DEPLOY_IGNORE_TAGS)) do
        if v ~= inst and
            v.entity:IsVisible() and
            v.components.placer == nil and
            v.entity:GetParent() == nil and
            near_other_fn(v, pt, min_spacing_sq_fn ~= nil and min_spacing_sq_fn(v) or min_spacing_sq) then
            return false
        end
    end
    return true
end

-- components/map
AddSimPostInit(function ()
    local _CanDeployRecipeAtPoint = Map.CanDeployRecipeAtPoint
    function Map:CanDeployRecipeAtPoint(pt, recipe, rot)
        local is_valid_ground = false
        if recipe.build_mode == BUILDMODE_AIR then
            return (recipe.testfn == nil or recipe.testfn(pt, rot))
                and IsAirClean(pt, nil, recipe.min_spacing or 3.2 )
                and self:IsPassableAtPoint(pt.x,pt.y,pt.z, true, false)
        elseif recipe.build_mode == BUILDMODE_LAND_WATER then
            is_valid_ground = self:IsOceanAtPoint(pt.x, pt.y, pt.z, true) and (recipe.testfn == nil or recipe.testfn(pt, rot)) and self:IsDeployPointClear(pt, nil, recipe.min_spacing or 3.2)
            return is_valid_ground or (recipe.testfn == nil or recipe.testfn(pt, rot)) and self:IsDeployPointClear(pt, nil, recipe.min_spacing or 3.2)
        end
        return _CanDeployRecipeAtPoint(self, pt, recipe, rot)
    end
end)

-- 在树荫下
local SHADECANOPY_MUST_TAGS = {"shadecanopy"}
local SHADECANOPY_SMALL_MUST_TAGS = {"shadecanopysmall"}
local function IsUnderShade(pt, rot)
    local x,y,z = pt:Get()
    local sheltered = false
    local canopy = TheSim:FindEntities(x,y,z, TUNING.SHADE_CANOPY_RANGE, SHADECANOPY_MUST_TAGS)
    local canopy_small = TheSim:FindEntities(x,y,z, TUNING.SHADE_CANOPY_RANGE_SMALL, SHADECANOPY_SMALL_MUST_TAGS)
    if #canopy > 0 or #canopy_small > 0 then
        sheltered = true
    end
    return sheltered
end

-- 头顶有东西，洞穴，树荫
local function HasCeilling(pt, rot)
    if TheWorld:HasTag("cave") then
        return true
    end
    return IsUnderShade(pt, rot)
end

-- 如果放置点在水上,让玩家远距离放置
require 'util'
-- local _Extra_Arrive_Dist = ACTIONS.BUILD.extra_arrive_dist
local function ExtraBuildDist(doer, dest, bufferedaction) -- doer, mouse?, bufferedaction
    if dest ~= nil then
        local target_x, target_y, target_z = dest:GetPoint()

        local is_on_water = TheWorld.Map:IsOceanTileAtPoint(target_x, 0, target_z) and not TheWorld.Map:IsPassableAtPoint(target_x, 0, target_z)
        if is_on_water then
            return 3 -- 1.75
        end
    end
    return 0
end
ACTIONS.BUILD.extra_arrive_dist = ExtraBuildDist



------------------------------------------------------------------------
------------------------------------------------------------------------
local farm_deco = GetModConfigData("farm_deco")
local function addFarm()
    AddRecipe2("succulent_farm",                {Ingredient("cutstone", 4), Ingredient("guano", 3), Ingredient("livinglog", 1) },                                       TECH.SCIENCE_ONE,       {placer = "succulent_farm_placer", min_spacing = 2, atlas = impath.."craft.xml", image = "craft.tex", build_mode = BUILDMODE_LAND_WATER})
    AddRecipeToFilter("succulent_farm",         "GARDENING")
end
local function addPot()
    AddRecipe2("succulent_largepot",            {Ingredient("cutstone", 2), Ingredient("succulent_picked", 6) },                                                        TECH.SCIENCE_ONE,       {placer = "succulent_largepot_placer", atlas = impath.."succulent_largepot.xml", image = "succulent_largepot.tex", build_mode = BUILDMODE_LAND_WATER})
    AddRecipeToFilter("succulent_largepot",     "DECOR")
end
local function addFarmDeconstruct()
    AddDeconstructRecipe("succulent_farm", {Ingredient("cutstone", 4), Ingredient("guano", 3), Ingredient("livinglog", 1) })
end
local function addPotDeconstruct()
    AddDeconstructRecipe("succulent_largepot",{Ingredient("cutstone", 2), Ingredient("succulent_picked", 6) })
end

if farm_deco == "both" then
    addFarm()
    addPot()
elseif farm_deco == "farm" then
    addFarm()
    addPotDeconstruct()
elseif farm_deco == "deco" then
    addPot()
    addFarmDeconstruct()
end

AddRecipe2("essence",                       {Ingredient("emeraldgem", 1, impath.."emeraldgem.xml"), Ingredient("dewdrop", 1, impath.."dewdrop.xml")},               TECH.MAGIC_THREE,       {atlas = impath.."essence_inactive.xml", image = "essence_inactive.tex"})
AddRecipeToFilter("essence",                "MAGIC")
AddRecipeToFilter("essence",                "COOKING")

AddRecipe2("succulent_medpot",              {Ingredient("cutstone", 1), Ingredient("succulent_picked", 4)},                                                         TECH.SCIENCE_ONE,       {placer = "succulent_medpot_placer", min_spacing = 1, atlas = impath.."succulent_medpot.xml", image = "succulent_medpot.tex", build_mode = BUILDMODE_LAND_WATER})
AddRecipeToFilter("succulent_medpot",       "DECOR")

AddRecipe2("emeraldamulet",                 {Ingredient("goldnugget", 3), Ingredient("nightmarefuel", 3), Ingredient("emeraldgem", 1, impath.."emeraldgem.xml")},   TECH.MAGIC_THREE,       {atlas = impath.."emeraldamulet.xml", image = "emeraldamulet.tex"})
AddRecipeToFilter("emeraldamulet",          "MAGIC")
AddRecipeToFilter("emeraldamulet",          "RESTORATION")

AddRecipe2("emeraldstaff",                  {Ingredient("nightmarefuel", 4), Ingredient("livinglog", 2), Ingredient("emeraldgem", 1, impath.."emeraldgem.xml") },   TECH.MAGIC_THREE,       {atlas = impath.."emeraldstaff.xml", image = "emeraldstaff.tex"})
AddRecipeToFilter("emeraldstaff",           "MAGIC")
AddRecipeToFilter("emeraldstaff",           "GARDENING")


-- 沙漠遗迹科技，制作站
-- OASIS
AddRecipe2("totem_item",                    { Ingredient("cutstone", 3), Ingredient("townportaltalisman", 4) },                                                     TECH.OASISTECH_TWO,     {nounlock = true, atlas = impath.."totem_item.xml", image = "totem_item.tex"})
AddRecipeToFilter("totem_item", "CRAFTING_STATION")

AddRecipe2("python_fountain_item",          { Ingredient("cutstone", 6), Ingredient("ice", 10) },                                                                   TECH.OASISTECH_TWO,     {nounlock = true, atlas = impath.."python_fountain_item.xml",image = "python_fountain_item.tex"})
AddRecipeToFilter("python_fountain_item", "CRAFTING_STATION")

AddRecipe2("tent_leaves_item",              { Ingredient("bedroll_straw", 1), Ingredient("cactus_flower", 6), Ingredient("cutreeds", 6) },                          TECH.OASISTECH_TWO,     {nounlock = true, atlas = impath.."tent_leaves_item.xml", image= "tent_leaves_item.tex"})
AddRecipeToFilter("tent_leaves_item", "CRAFTING_STATION")

AddRecipe2("vegrack_item",                  { Ingredient("cutstone", 4), Ingredient("townportaltalisman", 4) },                                                     TECH.OASISTECH_TWO,     {nounlock = true, atlas = impath.."vegrack.xml", image = "vegrack.tex"})
AddRecipeToFilter("vegrack_item", "CRAFTING_STATION")

AddRecipe2("treasurechest_succulent_item",  { Ingredient("cutstone", 10), Ingredient("townportaltalisman", 10) },                                                   TECH.OASISTECH_TWO,     {nounlock = true, atlas = impath.."treasurechest_succulent.xml", image = "treasurechest_succulent.tex"--[[ , placer="treasurechest_succulent_placer", min_spacing=1.5 ]]})
AddRecipeToFilter("treasurechest_succulent_item", "CRAFTING_STATION")



-- 空中悬挂物品
AddRecipe2("chandelier_rock",              { Ingredient("rope", 2), Ingredient("townportaltalisman", 3), Ingredient("succulent_picked", 4), Ingredient("lightcrab", 3)}, TECH.SCIENCE_TWO,       {placer = "chandelier_rock_placer", min_spacing = 3, atlas = impath.."chandelier_rock.xml", image="chandelier_rock.tex", testfn = HasCeilling, build_mode = BUILDMODE_AIR})
AddRecipeToFilter("chandelier_rock", "LIGHT")
AddRecipeToFilter("chandelier_rock", "STRUCTURES")


-- 为了建造法杖分解
-- AddDeconstructRecipe("treasurechest_succulent", {Ingredient("cutstone", 10), Ingredient("townportaltalisman", 10) })

-- 人物
-- 惠特尼
AddCharacterRecipe("tent_leaves",               {Ingredient("bedroll_straw", 1), Ingredient("cactus_flower", 6), Ingredient("cutreeds", 6)},                        TECH.NONE,          {builder_tag = "oasisenvoy",      min_spacing = 1,      placer = "tent_leaves_item_placer",  atlas = impath.."tent_leaves_item.xml", image = "tent_leaves_item.tex"})
AddCharacterRecipe("totem",                     {Ingredient("cutstone", 3),Ingredient("townportaltalisman", 4)},                                                    TECH.NONE,          {builder_tag = "oasisenvoy",      min_spacing = 1,      placer = "totem_item_placer",  atlas = impath.."totem_item.xml", image = "totem_item.tex"})
AddCharacterRecipe("python_fountain",           {Ingredient("cutstone", 6), Ingredient("ice", 10), Ingredient("townportaltalisman", 4)},                            TECH.NONE,          {builder_tag = "oasisenvoy",      min_spacing = 1,      placer = "python_fountain_item_placer",  atlas = impath.."python_fountain_item.xml",image = "python_fountain_item.tex"})
AddCharacterRecipe("vegrack",                   {Ingredient("cutstone", 4), Ingredient("townportaltalisman", 4)},                                                   TECH.NONE,          {builder_tag = "oasisenvoy",      min_spacing = 1,      placer = "vegrack_item_placer", atlas = impath.."vegrack.xml", image = "vegrack.tex"})
AddCharacterRecipe("succulent_picked",          {Ingredient(CHARACTER_INGREDIENT.SANITY, 5), Ingredient("spoiled_food", 3)},                                        TECH.NONE,          {builder_tag = "oasisenvoy",      min_spacing = 1,      numtogive = 3--[[ ,sg_state = "summon_abigail" ]]--[[ "formsucculent" ]]})
AddCharacterRecipe("treasurechest_succulent",   {Ingredient("cutstone", 10), Ingredient("townportaltalisman", 10)},                                                 TECH.NONE,          {builder_tag = "oasisenvoy",      min_spacing = 1,      placer="treasurechest_succulent_item_placer",  atlas = impath.."treasurechest_succulent.xml", image = "treasurechest_succulent.tex"})


-- Construction Plans
CONSTRUCTION_PLANS["totem"] = { Ingredient("twigs", 1)--[[ , Ingredient("cutgrass", 1), Ingredient("fig", 1), Ingredient("flint", 1), Ingredient("guano", 1) ]] }
CONSTRUCTION_PLANS["totem_construction1"] = { Ingredient("twigs", 1)--[[ , Ingredient("cutgrass", 1), Ingredient("fig", 1), Ingredient("flint", 1), Ingredient("guano", 1) ]] }
CONSTRUCTION_PLANS["totem_construction2"] = { Ingredient("twigs", 1)--[[ , Ingredient("cutgrass", 1), Ingredient("fig", 1), Ingredient("flint", 1), Ingredient("guano", 1) ]] }
CONSTRUCTION_PLANS["totem_construction3"] = { Ingredient("twigs", 1)--[[ , Ingredient("cutgrass", 1), Ingredient("fig", 1), Ingredient("flint", 1), Ingredient("guano", 1) ]] }
CONSTRUCTION_PLANS["totem_construction4"] = { Ingredient("twigs", 1)--[[ , Ingredient("cutgrass", 1), Ingredient("fig", 1), Ingredient("flint", 1), Ingredient("guano", 1) ]] }
CONSTRUCTION_PLANS["totem_construction5"] = { Ingredient("twigs", 1)--[[ , Ingredient("cutgrass", 1), Ingredient("fig", 1), Ingredient("flint", 1), Ingredient("guano", 1) ]] }
CONSTRUCTION_PLANS["totem_construction6"] = { Ingredient("twigs", 1)--[[ , Ingredient("cutgrass", 1), Ingredient("fig", 1), Ingredient("flint", 1), Ingredient("guano", 1) ]] }
CONSTRUCTION_PLANS["totem_construction7"] = { Ingredient("twigs", 1)--[[ , Ingredient("cutgrass", 1), Ingredient("fig", 1), Ingredient("flint", 1), Ingredient("guano", 1) ]] }







--[[
-- AddRecipe2(name, ingredients, tech, config, filters)
	{name = "FAVORITES",			atlas = GetCraftingMenuAtlas,	image = "filter_favorites.tex",		custom_pos = true},
	{name = "CRAFTING_STATION",		atlas = GetCraftingMenuAtlas,	image = "filter_none.tex",			custom_pos = true},
	{name = "SPECIAL_EVENT",		atlas = GetCraftingMenuAtlas,	image = "filter_events.tex",		custom_pos = true},
	{name = "MODS",					atlas = GetCraftingMenuAtlas,	image = "filter_modded.tex",		custom_pos = true, recipes = {}},

	{name = "CHARACTER",			atlas = GetCharacterAtlas,		image = GetCharacterImage,			image_size = 80},
	{name = "TOOLS",				atlas = GetCraftingMenuAtlas,	image = "filter_tool.tex",			},
	{name = "LIGHT",				atlas = GetCraftingMenuAtlas,	image = "filter_fire.tex",			},
	{name = "PROTOTYPERS",			atlas = GetCraftingMenuAtlas,	image = "filter_science.tex",		},
	{name = "REFINE",				atlas = GetCraftingMenuAtlas,	image = "filter_refine.tex",		},
	{name = "WEAPONS",				atlas = GetCraftingMenuAtlas,	image = "filter_weapon.tex",		},
	{name = "ARMOUR",				atlas = GetCraftingMenuAtlas,	image = "filter_armour.tex",		},
	{name = "CLOTHING",				atlas = GetCraftingMenuAtlas,	image = "filter_warable.tex",		},
	{name = "RESTORATION",			atlas = GetCraftingMenuAtlas,	image = "filter_health.tex",		},
	{name = "MAGIC",				atlas = GetCraftingMenuAtlas,	image = "filter_skull.tex",			},
	{name = "DECOR",				atlas = GetCraftingMenuAtlas,	image = "filter_cosmetic.tex",		},

	{name = "STRUCTURES",			atlas = GetCraftingMenuAtlas,	image = "filter_structure.tex",		},
	{name = "CONTAINERS",			atlas = GetCraftingMenuAtlas,	image = "filter_containers.tex",	},
	{name = "COOKING",				atlas = GetCraftingMenuAtlas,	image = "filter_cooking.tex",		},
	{name = "GARDENING",			atlas = GetCraftingMenuAtlas,	image = "filter_gardening.tex",		},
	{name = "FISHING",				atlas = GetCraftingMenuAtlas,	image = "filter_fishing.tex",		},
	{name = "SEAFARING",			atlas = GetCraftingMenuAtlas,	image = "filter_sailing.tex",		},
	{name = "RIDING",				atlas = GetCraftingMenuAtlas,	image = "filter_riding.tex",		},
	{name = "WINTER",				atlas = GetCraftingMenuAtlas,	image = "filter_winter.tex",		},
	{name = "SUMMER",				atlas = GetCraftingMenuAtlas,	image = "filter_summer.tex",		},
	{name = "RAIN",					atlas = GetCraftingMenuAtlas,	image = "filter_rain.tex",			},
	{name = "EVERYTHING",			atlas = GetCraftingMenuAtlas,	image = "filter_none.tex",			},
}]]
