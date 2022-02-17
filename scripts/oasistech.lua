-- 代码作者：ti_Tout

local _G = GLOBAL

--------------------------------------------------------------------------
--[[ 修改默认的科技树生成方式 ]]
--------------------------------------------------------------------------

local TechTree = require("techtree")

table.insert(TechTree.AVAILABLE_TECH, "OASISTECH")	--其实就是加个自己的科技树名称

TechTree.Create = function(t)
	t = t or {}
	for i, v in ipairs(TechTree.AVAILABLE_TECH) do
	    t[v] = t[v] or 0
	end
	return t
end

--------------------------------------------------------------------------
--[[ 制作等级中加入自己的部分 ]]
--------------------------------------------------------------------------

_G.TECH.NONE.OASISTECH = 0
_G.TECH.OASISTECH_ONE = { OASISTECH = 1 }
_G.TECH.OASISTECH_TWO = { OASISTECH = 2 }
_G.TECH.OASISTECH_THREE = { OASISTECH = 3 }

--------------------------------------------------------------------------
--[[ 解锁等级中加入自己的部分 ]]
--------------------------------------------------------------------------

for k,v in pairs(TUNING.PROTOTYPER_TREES) do
    v.OASISTECH = 0
end

--OASISTECH_ONE可以改成任意的名字，这里和TECH.OASISTECH_ONE名字相同只是懒得改了
TUNING.PROTOTYPER_TREES.OASISTECH_ONE = TechTree.Create({
    OASISTECH = 1,
})
TUNING.PROTOTYPER_TREES.OASISTECH_TWO = TechTree.Create({
    OASISTECH = 2,
})
TUNING.PROTOTYPER_TREES.OASISTECH_THREE = TechTree.Create({
    OASISTECH = 3,
})

--------------------------------------------------------------------------
--[[ 修改全部制作配方，对缺失的值进行补充 ]]
--------------------------------------------------------------------------

for i, v in pairs(AllRecipes) do
	if v.level.OASISTECH == nil then
		v.level.OASISTECH = 0
	end
end
