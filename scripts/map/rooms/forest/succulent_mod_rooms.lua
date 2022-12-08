AddRoom("TechandBush", -- Room 的名字，在worldgenmain里用到
{
	colour = {r=0,g=0,b=0,a=0},
	value = WORLD_TILES.DIRT_NOISE,	-- 沙漠区域地皮
	tags = {"RoadPoison", "sandstorm"},-- 加上才有沙尘暴
	contents =
	{
		-- countprefabs = {
		-- 	wormhole_MARKER = 1,
		-- },
        countstaticlayouts = -- Static layout
        {
            ["totem_tech"] = 1,-- 名称放在modworldgenmain了
        },
		-- distributepercent = 0.06,
		-- distributeprefabs =
		-- {
		-- 	succulent_plant = 0.08,
		-- }
}
})



AddRoom("WormholeToRelic", {
	colour={r=1,g=0,b=0,a=0.3},
	value = WORLD_TILES.DIRT_NOISE,
	contents =  {
					countprefabs = {
						wormhole_MARKER = 1,
					},
				}
})




-- test
AddRoom("Pick some cactus flowers",
{
	colour = {r=0,g=0,b=0,a=0},
	value = WORLD_TILES.DIRT_NOISE,	-- 沙漠区域地皮
	tags = {"RoadPoison", "sandstorm"},
	contents =
	{
		countprefabs =
		{
			thistle_bush = function () return 3 + math.random(3) end,
		},
		distributepercent = 0.08,	-- 密集程度
		distributeprefabs =	-- 以百分比平均分布
        {
            flower_evil = 0.15,
            -- oasis_cactus = 0.02,
        }
}
})

