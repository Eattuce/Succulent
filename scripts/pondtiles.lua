
local function IsNotPondTile(tile)
    return tile ~= WORLD_TILES.LILYPOND
end



local function GetWaveBearing(map, ex, ey, ez)
	local radius = 3.5
	local tx, tz = ex % TILE_SCALE, ez % TILE_SCALE
	local left = tx - radius < 0
	local right = tx + radius > TILE_SCALE
	local up = tz - radius < 0
	local down = tz + radius > TILE_SCALE


	local offs_1 =
	{
		{-1,-1, left and up},   {0,-1, up},   {1,-1, right and up},
		{-1, 0, left},		    			  {1, 0, right},
		{-1, 1, left and down}, {0, 1, down}, {1, 1, right and down},
	}

	local width, height = map:GetSize()
	local halfw, halfh = 0.5 * width, 0.5 * height
	local x, y = map:GetTileXYAtPoint(ex, ey, ez)
	local xtotal, ztotal, n = 0, 0, 0

	local is_nearby_land_tile = false

	for i = 1, #offs_1, 1 do
		local curoff = offs_1[i]
		local offx, offy = curoff[1], curoff[2]

		local ground = map:GetTile(x + offx, y + offy)
		if IsNotPondTile(ground) then
			if curoff[3] then
				return false
			else
				is_nearby_land_tile = true
			end
			xtotal = xtotal + ((x + offx - halfw) * TILE_SCALE)
			ztotal = ztotal + ((y + offy - halfh) * TILE_SCALE)
			n = n + 1
		end
	end

	radius = 4.5
	local minoffx, maxoffx, minoffy, maxoffy
	if not is_nearby_land_tile then
		minoffx = math.floor((tx - radius) / TILE_SCALE)
		maxoffx = math.floor((tx + radius) / TILE_SCALE)
		minoffy = math.floor((tz - radius) / TILE_SCALE)
		maxoffy = math.floor((tz + radius) / TILE_SCALE)
	end

	local offs_2 =
	{
		{-2,-2}, {-1,-2}, {0,-2}, {1,-2}, {2,-2},
		{-2,-1}, 						  {2,-1},
		{-2, 0}, 						  {2, 0},
		{-2, 1}, 						  {2, 1},
		{-2, 2}, {-1, 2}, {0, 2}, {1, 2}, {2, 2}
	}
	for i = 1, #offs_2, 1 do
		local curoff = offs_2[i]
		local offx, offy = curoff[1], curoff[2]

		local ground = map:GetTile(x + offx, y + offy)
		if IsNotPondTile(ground) then
			if not is_nearby_land_tile then
				is_nearby_land_tile = offx >= minoffx and offx <= maxoffx and offy >= minoffy and offy <= maxoffy
			end
			xtotal = xtotal + ((x + offx - halfw) * TILE_SCALE)
			ztotal = ztotal + ((y + offy - halfh) * TILE_SCALE)
			n = n + 1
		end
	end

	if n == 0 then return true end
	if not is_nearby_land_tile then return false end
	return -math.atan2(ztotal/n - ez, xtotal/n - ex)/DEGREES - 90
end

local function SpawnWavesOrShore(self, map, x, y, z)
	local bearing = GetWaveBearing(map, x, y, z)
	if bearing == false then return end

	if bearing == true then
		SpawnPrefab("wave_shimmer").Transform:SetPosition(x, y, z)
	else
		local wave = SpawnPrefab("wave_shore")
		wave.Transform:SetPosition( x, y, z )
		wave.Transform:SetRotation(bearing)
		wave:SetAnim()
	end
end


-- 增加地皮
local SHORE_OCEAN_COLOR =
{
    primary_color =        {220, 240, 255, 60},
    secondary_color =      {21,  96,  110, 140},
    secondary_color_dusk = {0,   0,   0,   50},
    minimap_color =        {23,  51,  62,  102},
}

local tile_data = { ground_name = "Lilypond"}
local ground_tile_def =
{
    name = "water_medium",
    -- atlas = "",
    noise_texture = "lilypond",
    runsound = "dontstarve/movement/run_marsh",
    walksound = "dontstarve/movement/walk_marsh",
    -- snowsound = "run_snow",
    -- mudsound = "run_mud",
    -- flashpoint_modifier = 0,
    flooring = false,
    hard = false,
    cannotbedug = false,
    ocean_depth = "SHALLOW",
    colors = SHORE_OCEAN_COLOR,
    wavetint = {0.8,   0.9,    1},

}
local minimap_tile_def = nil
-- {
--     name = "",
--     atlas = "",
--     noise_texture = "",
-- }
local turf_def = nil
AddTile("LILYPOND", "OCEAN", tile_data, ground_tile_def, minimap_tile_def, turf_def)                 -- tilemanager.lua

TileGroups.Lilypond = TileGroupManager:AddTileGroup()                                               -- tilegroups.lua
TileGroupManager:AddValidTile(TileGroups.Lilypond, WORLD_TILES.LILYPOND)
-- TileGroupManager:AddInvalidTile(TileGroups.LandTiles, WORLD_TILES.LILYPOND)                      -- Invalid LandTiles makes drownable work
-- TileGroupManager:AddValidTile(TileGroups.OceanTiles, WORLD_TILES.LILYPOND)                       -- Valid OceanTiles makes boss turn around

-- 产生波纹
AddComponentPostInit("wavemanager", function (self) -- wavemanager.lua
    local shimmer = self.shimmer
    local TrySpawnWavesOrShore = shimmer[WORLD_TILES.OCEAN_COASTAL].tryspawn                        -- 就和一般海洋类似
    shimmer[WORLD_TILES.LILYPOND] = {per_sec = 80, spawn_rate = 0, tryspawn = SpawnWavesOrShore}
end)

-- 把地皮在TransparentOceanTiles里设置为不可用, 使其不透明, 看起来像陆地但实际是海
TileGroupManager:AddInvalidTile(TileGroups.TransparentOceanTiles, WORLD_TILES.LILYPOND)
TileGroupManager:SetIsTransparentOceanTileGroup(TileGroups.TransparentOceanTiles)                   -- tiles that get the special see through property.
------------------------------------------------------------------------

local function addcollision(world)                                                                  -- world.lua (forest.lua) <tile_physics_init>
    local _tile_physics_init = world.tile_physics_init
    world.tile_physics_init = function (inst)
        inst.Map:AddTileCollisionSet(
            COLLISION.LAND_OCEAN_LIMITS,
            TileGroups.OceanTiles, true,
            TileGroups.OceanTiles, false,
            0.25, 64
        ) -- 应该是和LandTiles一样吧, 这样就不会阻拦玩家进入池塘
        inst.Map:AddTileCollisionSet(
            COLLISION.GROUND,
            TileGroups.ImpassableTiles, true,
            TileGroups.ImpassableTiles, false,
            0.25, 128
        )
        -- return _tile_physics_init(inst)
    end
end
-- AddPrefabPostInit("world", addcollision)

-- 降低地皮优先度 (先定义的优先度低)
ChangeTileRenderOrder(WORLD_TILES.LILYPOND, WORLD_TILES.OCEAN_HAZARDOUS, true)                   	-- tiledefs.lua

AddComponentPostInit("floater", function (self)                                                     -- floater.lua <inventoryitem>
    local _ShouldShowEffect = self.ShouldShowEffect

    function self:ShouldShowEffect()
        local pos_x, pos_y, pos_z = self.inst.Transform:GetWorldPosition()
        local tile = TheWorld.Map:GetTileAtPoint(pos_x, pos_y, pos_z)
        if tile == TileGroups.Lilypond then
            return true
        end
        return _ShouldShowEffect(self)
    end
end)

AddComponentPostInit("drownable", function (self)
	local _IsOverWater = self.IsOverWater

	function self:IsOverWater()
		local x, y, z = self.inst.Transform:GetWorldPosition()
		return TheWorld.Map:GetTileAtPoint(x, y, z) == TileGroups.Lilypond and _IsOverWater(self)
	end
end)



