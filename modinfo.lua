
local L = locale ~= "zh" and locale ~= "zhr" --true-英文; false-中文
local date = "2022/12/1"

name = L and "Succulent plant" or "多肉植物!"
author = "码：生菜  画：灰色代表作"
version = "4.7.4"
description =
    L
    and version.."   "..date.."\n  - Replaced the animations of Rock Chest with low quality animations for now\n"
    or version.."   "..date.."\n  - 暂时用比较生草的动画替代了沙石箱子的动画以避免和樱花林产生的动画错误，有时间会修复\n"

forumthread = nil

--lua版本，单机写6，联机写10
api_version = 10

--mod加载的优先级，不写就默认为0，越大越优先加载
-- ShowMe(Origin) Workshop ID - 666155465 (0.00666155465) Needs to be larger than it
priority = 0.02441790846

-- Compatible with Don't Starve Together
dst_compatible = true
dont_starve_compatible = false
reign_of_giants_compatible = false
shipwrecked_compatible = false

--These let clients know if they need to get the mod from the Steam Workshop to join the game, Character mods need this set to true
all_clients_require_mod = true

--This determines whether it causes a server to be marked as modded (and shows in the mod list)
client_only_mod = false

--mod的图标
icon_atlas = "modicon.xml"
icon = "modicon.tex"

-- The mod's tags displayed on the server list
server_filter_tags = nil

--mod设置

local function Title(title)
    return {
        name=title,
        hover = "",
        options={{description = "", data = 0}},
        default = 0,
        }
end

configuration_options =
{
------------------------------------------------------------------------
------------------------------------------------------------------------
    Title(L and "Language" or "语言"),
    L and {
        name = "Language",
        label = "Set Language",
        hover = "Choose your language", -- hover是鼠标指向选项时会显示更详细的信息
        options =
        {
            -- {description = "Auto(Default)", data = "auto"},
            {description = "English(Default)", data = "english"},
            {description = "中文", data = "chinese"},
        },
        default = "english",
    } or {
        name = "Language",
        label = "设置语言",
        hover = "设置mod语言",
        options =
        {
            -- {description = "自动(默认)", data = "auto"},
            {description = "English", data = "english"},
            {description = "中文(默认)", data = "chinese"},
        },
        default = "chinese",
    },

    Title(""),
    Title(L and "Using Alchemy Furnace" or "使用炼丹炉(仅在开启神话时有效)"),
    L and {
        name = "mythpot",
        label = "Enable",
        hover = "Using alchemy furnace to abtain emeraldgems",
        options =
        {
            {description = "Yes(Default)", data = true, hover = "Obtain emeraldgems through alchemy furnace"},
            {description = "No", data = false, hover = "Craft emeraldgems"},
        },
        default = true,
    } or {
        name = "mythpot",
        label = "开启",
        hover = "仅使用炼丹炉炼宝石",
        options =
        {
            {description = "开启(默认)", data = true, hover = "只能使用炼丹炉炼出宝石"},
            {description = "关闭", data = false, hover = "只能在制造栏造宝石"},
        },
        default = true,
    },

    Title(""),
    Title(L and "Succulent planter or" or "建造多肉农场/大型多肉盆栽"),
    Title(L and "Potted Succulent(Large)" or ""),
    L and {
        name = "farm_deco",
        label = "Succulent planter/Potted Succulent(Large)",
        hover = "Succulent planter and Potted Succulent(Large) looks the same, to identify between they two",
        options =
        {
            {description = "Both", data = "both"},
            {description = "Planter(Default)", data = "farm"},
            {description = "Deco", data = "deco"},
        },
        default = "farm",
    } or {
        name = "farm_deco",
        label = "多肉农场/大型多肉盆栽",
        hover = "它们看起来一样, 为了方便区分, 选择一个加入建造栏",
        options =
        {
            {description = "都要", data = "both"},
            {description = "农场(默认)", data = "farm"},
            {description = "盆栽", data = "deco"},
        },
        default = "farm",
    },
    Title(""),
    Title(L and "Emerald staff settings" or "翠榴法杖设置"),
    L and {
        name = "staff",
        label = "Product",
        hover = "What makes Emerald Staff creats different flowers",
        options =
        {
            {description = "Season", data = false},
            {description = "Day(Default)", data = true},
        },
        default = true,
    } or {
        name = "staff",
        label = "产生的植物",
        hover = "什么条件决定产出",
        options =
        {
            {description = "季节", data = false},
            {description = "一天里的时间(默认)", data = true},
        },
        default = true,
    },
}


------------------------------------------------------------------------
------------------------------------------------------------------------
-- Title(""),
-- Title(L and "Pumpkin Lantern" or "南瓜灯"),
-- L and {
--     name = "waxablepklantern",
--     label = "Waxable Pumpkin Lantern",
--     hover = "Pumpkin lanterns won't rot if waxed",
--     options =
--     {
--         {description = "Enable(Default)", data = true},
--         {description = "Disable", data = false},
--     },
--     default = true,
-- } or {
--     name = "waxablepklantern",
--     label = "可以打蜡的南瓜灯",
--     hover = "打过蜡的南瓜灯不会腐烂",
--     options =
--     {
--         {description = "开启(默认)", data = true},
--         {description = "关闭", data = false},
--     },
--     default = true,
-- },
------------------------------------------------------------------------
------------------------------------------------------------------------

-- Title(""),
-- Title(L and "Succulent Farm" or "多肉农场"),
--     Title(L and "Crafting" or "建造"),
-- 	L and{
--         name = "isfarm",
--         label = "What do you want it to be",
--         hover = "A farm or a decoration",
--         options =
-- 		{
--             {description = "Farm(Default)", data = true, hover = "FARM"},
--             {description = "Decoration", data = false, hover = "DECORATION"},
--         },
--         default = true,
--     } or {
-- 		name = "isfarm",
--         label = "功能性",
--         hover = "农场或是装饰物",
--         options =
-- 		{
--             {description = "农场(默认)", data = true, hover = "食物栏"},
--             {description = "装饰物", data = false, hover = "建筑栏"},
--         },
--         default = true,
--     },
-----
    -- L and {
    --     name = "mushfarm",
    --     label = "Plant cucculent in mushroom farms",
    --     hover = "",
    --     options =
    --     {
    --         {description = "Enable(Default)", data = true},
    --         {description = "Disable", data = false},
    --     },
    --     default = true,
    -- } or {
    --     name = "mushfarm",
    --     label = "蘑菇农场能种植多肉植物",
    --     hover = "",
    --     options =
    --     {
    --         {description = "开启(默认)", data = true},
    --         {description = "关闭", data = false},
    --     },
    --     default = true,
    -- },
------------------------------------------------------------------------
------------------------------------------------------------------------
-- Title(""),
-- Title(L and "Succulent recipes" or "多肉植物的新菜谱"), --新菜谱
--     L and {
--         name = "newrecipes",
--         label = "New Recipes",
--         hover = "Add new recipes about succulent plants",
--         options =
--         {
--             {description = "Yes(Default)", data = true},
--             {description = "NO", data = false},
--         },
--         default = true,
--     } or {
--         name = "newrecipes",
--         label = "新菜谱",
--         hover = "是否增加关于多肉植物的新菜谱",
--         options =
--         {
--             {description = "是(默认)", data = true},
--             {description = "否", data = false},
--         },
--         default = true,
--     },
------------------------------------------------------------------------
------------------------------------------------------------------------
-- Title(""),
-- Title(L and "Antlion and Desert Stone" or "蚁狮与沙之石"),
--     L and {
--         name = "morestone",
--         label = "More desert stone",
--         hover = "Antlion spit out more desert stone",
--         options =
--         {
--             {description = "Enable(Default)", data = true},
--             {description = "Disable", data = false},
--         },
--         default = true,
--     } or {
--         name = "morestone",
--         label = "更多沙之石",
--         hover = "通过交易蚁狮给的沙之石更多",
--         options =
--         {
--             {description = "开启(默认)", data = true},
--             {description = "关闭", data = false},
--         },
--         default = true,
--     },
-- -----
--     L and {
--         name = "stoneharm",
--         label = "Desert stone cuisine(special effect 1)",
--         hover = "Deal damage to creatures had eaten desert stone cuisine",
--         options =
--         {
--             {description = "Enable(Default)", data = true},
--             {description = "Disable", data = false},
--         },
--         default = true,
--     } or {
--         name = "stoneharm",
--         label = "沙之石料理的特殊伤害效果",
--         hover = "沙之石料理能给生物造成伤害",
--         options =
--         {
--             {description = "开启(默认)", data = true},
--             {description = "关闭", data = false},
--         },
--         default = true,
--     },
-- -----
--     L and {
--         name = "stonebuff",
--         label = "Desert stone cuisine(special effect 2)",
--         hover = "After having desert stone cuisine teleporting costs nothing",
--         options =
--         {
--             {description = "Enable(Default)", data = true},
--             {description = "Disable", data = false},
--         },
--         default = true,
--     } or {
--         name = "stonebuff",
--         label = "沙之石料理的特殊增益效果",
--         hover = "沙之石料理让食用者一天内不会在使用强征传送塔时消耗脑残",
--         options =
--         {
--             {description = "开启(默认)", data = true},
--             {description = "关闭", data = false},
--         },
--         default = true,
--     },
------------------------------------------------------------------------
------------------------------------------------------------------------
------------------------------------------------------------------------
------------------------------------------------------------------------
-- Title(""),
--     Title(L and "Dewdrop" or "玉露"),
--     L and {
--         name = "fuel_essence",
--         label = "Fuel Essence with Dewdrop",
--         hover = "You can fuel essence with dewdrop",
--         options =
--         {
--             {description = "Enable", data = true},
--             {description = "Disable(Default)", data = false},
--         },
--         default = false,
--     } or {
--         name = "fuel_essence",
--         label = "玉露精华可以添加燃料",
--         hover = "通过玉露给玉露精华回复耐久",
--         options =
--         {
--             {description = "开启", data = true},
--             {description = "关闭(默认)", data = false},
--         },
--         default = false,
--     },

--[[
Title(L and "en" or "ch"),
L and {
    name = "",
    label = "",
    hover = "",
    options =
    {
        {description = "Enable(Default)", data = true},
        {description = "Disable", data = false},
    },
    default = true,
} or {
    name = "",
    label = "",
    hover = "",
    options =
    {
        {description = "开启(默认)", data = true},
        {description = "关闭", data = false},
    },
    default = true,
},
]]--