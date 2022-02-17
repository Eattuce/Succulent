GLOBAL.setmetatable(env, { __index = function(t, k) return GLOBAL.rawget(GLOBAL, k) end })
local _G = GLOBAL
STRINGS = _G.STRINGS
RECIPETABS = _G.RECIPETABS
Recipe = _G.Recipe
Ingredient = _G.Ingredient
TECH = _G.TECH
--------------------
local impath = "images/inventoryimages/"
local L = locale ~= "zh" and locale ~= "zhr" --true-英文; false-中文

PrefabFiles =
{
    "dewdrop",
    "succulent_pots",
    "succulent_farm",
    "preparedfoods_succulent",
    "buffs_succulent",
    "emeraldgem",
    "essence",
    "emeraldstaff",
    "succulentflowers",
    "emeraldamulet",
    "succulent_plant_fx",
    "totem",
    "thistle_seed",
    "thistle_bush",
    "python_fountain",
    "tent_oasis",
    "totem_spawner",
    "vegrack",
    "veggie_crisps",
    "oasismanager",

    "skins",
}

Assets =
{
    Asset("IMAGE", "minimap/mini.tex" ),
    Asset("ATLAS", "minimap/mini.xml" ),
    Asset("IMAGE", impath.."craft.tex"),
    Asset("ATLAS", impath.."craft.xml"),
    Asset("ATLAS", impath.."dewdrop.xml"),
    Asset("IMAGE", impath.."dewdrop.tex"),
    Asset("IMAGE", impath.."succulent_medpot.tex"),
    Asset("ATLAS", impath.."succulent_medpot.xml"),
    Asset("IMAGE", impath.."vegrack.tex"),
    Asset("ATLAS", impath.."vegrack.xml"),
    -- Asset("SOUNDPACKAGE", "sound/whispers.fev"),
    -- Asset("SOUND", "sound/whispers.fsb"),
    Asset("IMAGE", impath.."totem_tech_icon.tex"),
    Asset("ATLAS", impath.."totem_tech_icon.xml"),
    Asset("IMAGE", impath.."medpot_spa.tex"),
    Asset("ATLAS", impath.."medpot_spa.xml"),
    Asset("IMAGE", impath.."succulent_largepot.tex"),
    Asset("ATLAS", impath.."succulent_largepot.xml"),
    Asset("IMAGE", impath.."largepot_forma.tex"),
    Asset("ATLAS", impath.."largepot_forma.xml"),
    Asset("IMAGE", impath.."largepot_formb.tex"),
    Asset("ATLAS", impath.."largepot_formb.xml"),
    Asset("IMAGE", impath.."largepot_formc.tex"),
    Asset("ATLAS", impath.."largepot_formc.xml"),
    -- anim
    Asset("ANIM", "anim/emeraldgem.zip"),
    Asset("ANIM", "anim/medpot_spa.zip"),


}

--------------------------------------------------------------------------
-- 定义常量
local seg_time = 30
local total_day_time = seg_time*16
local OASIS = AddRecipeTab("OASIS", 100, impath.."totem_tech_icon.xml", "totem_tech_icon.tex", nil, true)
-- local myth = KnownModIndex:IsModEnabled("workshop-1991746508") -- or KnownModIndex:IsModEnabled("workshop-1699194522")
TUNING.ESSENCE_FUEL = 18 * total_day_time -- 最大值
TUNING.THISTLE_BUSH_GROW =
{
    WITHER_ONE = total_day_time ,
    ONE_TWO = 3*total_day_time ,
    TWO_THREE = 5*total_day_time ,
    VAR = 2*seg_time,
}

--------------------------------------------------------------------------
-- 注册小地图标
local minimapatlas = {"mini", "fountain_minimapicon", "totem_minimap_icon",}

for _,name in pairs(minimapatlas) do
    AddMinimapAtlas("minimap/"..name..".xml")
end

--------------------------------------------------------------------------
-- 根据语言设置选择STRINGS文件
local language = GetModConfigData("Language")
local chinese = "scripts/languages/strings_ch.lua"
local english = "scripts/languages/strings_en.lua"
if language == "auto" then
    modimport(L and english or chinese)
elseif language == "chinese" then
    modimport(chinese) --中文
elseif language == "english" then
    modimport(english) --英语
end

--------------------------------------------------------------------------
-- 注册物品图标
local items =
{
    "succulent_largepot",
    "emeraldamulet",
    "emeraldstaff",
    "emeraldgem",
    "thistle_seed",
    "python_fountain_item",
    "totem_item",
    "tent_leaves_item",
    "veggie_crisps",
    "vegrack",
    "vegrack_item",
    -- skins
    "medpot_spa",
    "largepot_forma",
    "largepot_formb",
    "largepot_formc",
}
for _,item in pairs(items) do
    RegisterInventoryItemAtlas(impath..item..".xml", item..".tex")
end

--------------------------------------------------------------------------
-- import
local mainfiles =
{
    "modtownportal",
    "modtownportaltalisman",
    "modantlion",
    "modmushroomfarm",
    "emeraldmooneye",
    "modcrabking",
    "oasistech",
    -- "growmoretrees",
    "vegrack",
    "saplingspostinits",

    "skins",
}
for _,file in pairs(mainfiles) do
    modimport("scripts/"..file..".lua")
end
--------------------------------------------------------------------------
--添加制作方法
AddRecipe("essence",
    { Ingredient("emeraldgem", 1, impath.."emeraldgem.xml"), Ingredient("dewdrop", 1, impath.."dewdrop.xml")},
    RECIPETABS.MAGIC, TECH.MAGIC_THREE, nil,nil,nil,nil,nil,
    impath.."essence_inactive.xml", "essence_inactive.tex")

    _G.AllRecipes["essence"]["sortkey"] = _G.AllRecipes["amulet"]["sortkey"] - 1

AddRecipe("succulent_medpot",
    { Ingredient("cutstone", 1), Ingredient("succulent_picked", 6), },
    RECIPETABS.TOWN, TECH.SCIENCE_ONE, "succulent_medpot_placer", 0.9,nil,nil,nil, -- placer,minispacing,nounlock,numtogive,buildertag
    impath.."succulent_medpot.xml", "succulent_medpot.tex")

    _G.AllRecipes["succulent_medpot"]["sortkey"] = _G.AllRecipes["succulent_potted"]["sortkey"] - 1
--
AddRecipe("emeraldamulet",
    { Ingredient("goldnugget", 3), Ingredient("nightmarefuel", 3), Ingredient("emeraldgem", 1, impath.."emeraldgem.xml")},
    RECIPETABS.MAGIC, TECH.MAGIC_THREE, nil,nil,nil,nil,nil,
    impath.."emeraldamulet.xml", "emeraldamulet.tex")

    _G.AllRecipes["emeraldamulet"]["sortkey"] = _G.AllRecipes["amulet"]["sortkey"] - 1
--
AddRecipe("emeraldstaff",
    { Ingredient("nightmarefuel", 4), Ingredient("livinglog", 2), Ingredient("emeraldgem", 1, impath.."emeraldgem.xml") },
    RECIPETABS.MAGIC, TECH.MAGIC_THREE, nil,nil,nil,nil,nil,
    impath.."emeraldstaff.xml", "emeraldstaff.tex")

    _G.AllRecipes["emeraldstaff"]["sortkey"] = _G.AllRecipes["firestaff"]["sortkey"] - 1
--
AddRecipe("succulent_farm",
    { Ingredient("cutstone", 4), Ingredient("guano", 2), Ingredient("livinglog", 1) },
    RECIPETABS.FARM, TECH.SCIENCE_ONE, "succulent_farm_placer", 2,nil,nil,nil,
    impath.."craft.xml", "craft.tex")

    _G.AllRecipes["succulent_farm"]["sortkey"] = _G.AllRecipes["mushroom_farm"]["sortkey"] - 1
--
AddRecipe("succulent_largepot",
    { Ingredient("cutstone", 2), Ingredient("succulent_picked", 6) },
    RECIPETABS.TOWN, TECH.SCIENCE_ONE, "succulent_largepot_placer", 2,nil,nil,nil,
    impath.."succulent_largepot.xml", "succulent_largepot.tex")

    _G.AllRecipes["succulent_largepot"]["sortkey"] = _G.AllRecipes["succulent_potted"]["sortkey"] - 1
--
------------------------------------------------------------------------
-- OASIS
AddRecipe("totem_item",
    { Ingredient("cutstone", 3), Ingredient("townportaltalisman", 4) },
    OASIS, TECH.OASISTECH_TWO, nil,nil, true, nil,nil,
    impath.."totem_item.xml", "totem_item.tex")

AddRecipe("python_fountain_item",
    { Ingredient("cutstone", 6), Ingredient("ice", 10) },
    OASIS,
    TECH.OASISTECH_TWO, nil,nil, true, nil,nil,
    impath.."python_fountain_item.xml","python_fountain_item.tex")

AddRecipe("tent_leaves_item",
    { Ingredient("bedroll_straw", 1), Ingredient("cactus_flower", 6), Ingredient("cutreeds", 6) },
    OASIS,TECH.OASISTECH_TWO, nil,nil, true, nil,nil,
    impath.."tent_leaves_item.xml","tent_leaves_item.tex")

AddRecipe("vegrack_item",
    { Ingredient("cutstone", 4), Ingredient("townportaltalisman", 4) },
    OASIS, TECH.OASISTECH_TWO, nil,nil, true, nil,nil, impath.."vegrack.xml","vegrack.tex")

------------------------------------------------------------------------

--this is so you can use deconstruction staff on the deployed item
-- AddRecipe("tent_leaves",  {Ingredient("bedroll_straw", 1), Ingredient("cactus_flower", 6), Ingredient("cutreeds", 6)}, nil, TECH.LOST, nil, nil, true)
-- AddRecipe("totem", {Ingredient("cutstone", 3),Ingredient("townportaltalisman", 4)}, nil, TECH.LOST, nil, nil, true)
-- AddRecipe("python_fountain",  {Ingredient("cutstone", 6), Ingredient("ice", 10)}, nil, TECH.LOST, nil, nil, true)
-- AddRecipe("vegrack",  {Ingredient("cutstone", 4), Ingredient("townportaltalisman", 4)}, nil, TECH.LOST, nil, nil, true)

-- -- Whitney
-- AddRecipe("tent_leaves_item",  {Ingredient("bedroll_straw", 1), Ingredient("cactus_flower", 6), Ingredient("cutreeds", 6)}, OASIS, TECH.NONE, nil, nil, nil, nil, "whitney_recipes")
-- AddRecipe("totem_item", {Ingredient("cutstone", 3),Ingredient("townportaltalisman", 4)}, OASIS, TECH.NONE, nil, nil, nil, nil, "whitney_recipes")
-- AddRecipe("python_fountain_item",  {Ingredient("cutstone", 6), Ingredient("ice", 10)}, OASIS, TECH.NONE, nil, nil, nil, nil, "whitney_recipes")
-- AddRecipe("vegrack_item",  {Ingredient("cutstone", 4), Ingredient("townportaltalisman", 4)}, OASIS, TECH.NONE, nil, nil, nil, nil, "whitney_recipes")

------------------------------------------------------------------------


local function gemtorecipe()
    AddRecipe("emeraldgem",
    { Ingredient("bluegem", 1), Ingredient("redgem", 1), Ingredient("dewdrop", 1, impath.."dewdrop.xml") },
        RECIPETABS.REFINE, TECH.MAGIC_THREE, nil,nil,nil,nil,nil,
        impath.."emeraldgem.xml", "emeraldgem.tex")

    _G.AllRecipes["emeraldgem"]["sortkey"] = _G.AllRecipes["moonrockcrater"]["sortkey"] - 1
end

if GetModConfigData("mythpot") then
    AddSimPostInit(function()
        if TUNING.MYTH_PILL_RECIPES then
            TUNING.MYTH_PILL_RECIPES.emeraldgem = {
                time = 60,
                recipe = {dewdrop = 1, redgem = 1, bluegem = 1, nightmarefuel = 1},
                overridebuild = "emeraldgem",
                overridesymbolname = "emeraldgem"
            }
        else
            gemtorecipe()
        end
    end)
else
    gemtorecipe()
end





------------------------------------------------------------------------


local gels = {"glommerfuel", "slurtleslime", "phlegm"}
AddIngredientValues(gels, {special=1}, false, false)--格罗姆黏液 蜗牛黏液 钢羊浓鼻涕
AddIngredientValues({"succulent_picked"}, {veggie=.5}, false, false)    --多肉植物 --cancook --candry
AddIngredientValues({"townportaltalisman"},{rock=1, inedible=1}, false, false)  --沙之石
AddIngredientValues({"saltrock"},{salt=1}, false, false)  --盐晶
--正常食谱
for k, recipe in pairs(require("preparedfoods_plants")) do
    table.insert(Assets, Asset("ATLAS", "images/cookbookimages/"..recipe.name..".xml"))
    table.insert(Assets, Asset("IMAGE", "images/cookbookimages/"..recipe.name..".tex"))

    AddCookerRecipe("cookpot", recipe)
    AddCookerRecipe("portablecookpot", recipe)
    AddCookerRecipe("archive_cookpot", recipe)
    RegisterInventoryItemAtlas("images/cookbookimages/"..recipe.name..".xml", recipe.name..".tex")
end
--加料
for k, recipe in pairs(require("preparedfoods_spiced")) do
    AddCookerRecipe("portablespicer", recipe)
end
--物品食谱
for k, recipe in pairs(require("preparednonplants")) do
    table.insert(Assets, Asset("ATLAS", "images/cookbookimages/"..recipe.name..".xml"))
    table.insert(Assets, Asset("IMAGE", "images/cookbookimages/"..recipe.name..".tex"))
    RegisterInventoryItemAtlas("images/cookbookimages/"..recipe.name..".xml", recipe.name..".tex")
    AddCookerRecipe("cookpot", recipe)
    AddCookerRecipe("portablecookpot", recipe)
    AddCookerRecipe("archive_cookpot", recipe)
end

