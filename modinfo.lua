
local L = locale ~= "zh" and locale ~= "zhr" --true-英文; false-中文

name = L and "Succulent plant" or "多肉植物!"
author = "码：生菜  画：灰色代表作"
version = "3.0"
description =
    L
    and version.."Local Tests"
    or version.."本地测试"
--个人网址
forumthread = nil

--lua版本，单机写6，联机写10
api_version = 10

--mod加载的优先级，不写就默认为0，越大越优先加载
priority = -1000

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
            {description = "Auto(Default)", data = "auto"},
            {description = "English", data = "english"},
            {description = "中文", data = "chinese"},
        },
        default = "auto",
    } or {
        name = "Language",
        label = "设置语言",
        hover = "设置mod语言",
        options =
        {
            {description = "自动(默认)", data = "auto"},
            {description = "English", data = "english"},
            {description = "中文", data = "chinese"},
        },
        default = "auto",
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
    Title(L and "Extensible Oasis Range" or "绿洲范围可扩大"),
    L and {
        name = "oasis",
        label = "Try it",
        hover = "Plant trees around oasis to extend the sandstorm-free zone",
        options =
        {
            {description = "True(Default)", data = true},
            {description = "False", data = false},
        },
        default = true,
    } or {
        name = "oasis",
        label = "尝试一下",
        hover = "在绿洲附近种树可以扩大不受夏天沙尘暴影响的范围",
        options =
        {
            {description = "开启(默认)", data = true},
            {description = "关闭", data = false},
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