GLOBAL.setmetatable(env, { __index = function(t, k) return GLOBAL.rawget(GLOBAL, k) end })


local BEST_TILES =
{
    -- WORLD_TILES.MONKEY_DOCK
    WORLD_TILES.GRASS,
    WORLD_TILES.FOREST,
    WORLD_TILES.DECIDUOUS,
    WORLD_TILES.MARSH,
    WORLD_TILES.FARMING_SOIL,
    WORLD_TILES.FUNGUS,             -- MUSHROOM
    WORLD_TILES.FUNGUSRED,
    WORLD_TILES.FUNGUSGREEN,
    WORLD_TILES.FUNGUSMOON,
    WORLD_TILES.SINKHOLE,           -- GRASS
}

local GOOD_TILES =
{
    WORLD_TILES.ROAD,
    WORLD_TILES.SHELLBEACH,
    WORLD_TILES.SCALE,
    WORLD_TILES.CHECKER,
    WORLD_TILES.ARCHIVE,
    WORLD_TILES.METEOR,

    WORLD_TILES.SAVANNA,
    WORLD_TILES.WOODFLOOR,
    WORLD_TILES.CARPET,
    WORLD_TILES.MUD,

}

local FINE_TILES =
{
    WORLD_TILES.PEBBLEBEACH,
    WORLD_TILES.UNDERROCK,
    WORLD_TILES.CAVE,

    -- WORLD_TILES.MONKEY_GROUND, -- Make things worse
}

local DESERT_TILES =
{
    WORLD_TILES.DIRT,
    WORLD_TILES.DESERT_DIRT,
    WORLD_TILES.DIRT_NOISE,
}

local tree_p = 1
local tall_p = 0.8
local short_p = 0.6


local SHADECANOPY_MUST_TAGS = {"shadecanopy"}
local SHADECANOPY_SMALL_MUST_TAGS = {"shadecanopysmall"}
local function IsUnderShade(x, y, z)
    local sheltered = false
    local canopy = TheSim:FindEntities(x,y,z, TUNING.SHADE_CANOPY_RANGE, SHADECANOPY_MUST_TAGS)
    local canopy_small = TheSim:FindEntities(x,y,z, TUNING.SHADE_CANOPY_RANGE_SMALL, SHADECANOPY_SMALL_MUST_TAGS)
    if #canopy > 0 or #canopy_small > 0 then
        sheltered = true
    end
    return sheltered
end



local RANGE = 8
local TREE_MUST_TAGS = { "shelter", "tree" }
local TALL_MUST_ONE_OF_TAGS = { "structure" }
local CANT_TAGS = { "FX", "NOCLICK", "DECOR", "INLIMBO", "burnt", "stump" }
local MUST_TAGS = nil

local SHORT_MUST_ONE_OF_TAGS = { "flower", "plant", "bush" }

AddComponentPostInit("sandstorms", function (self)
    self.Best_Tiles = BEST_TILES
    -- self.Good_Tiles = GOOD_TILES
    -- self.Fine_Tiles = FINE_TILES
    self.Desert_Tiles = DESERT_TILES

    local function LowerSandstormLevelDueToTile(tile)
        if table.contains(self.Desert_Tiles, tile) then
            return 0
        elseif table.contains(self.Best_Tiles, tile) then
            return 0.35
        elseif IsLandTile(tile) then
            return 0.2
        end
        return 0
    end

    local _GetSandstormLevel = self.GetSandstormLevel
    function self:GetSandstormLevel(ent)
        local _sandstormactive = self:IsSandstormActive()
        local _sandstormlevel = _GetSandstormLevel(self, ent)

        if _sandstormactive and _sandstormlevel > 0 and ent.components.areaaware ~= nil then
            local x,y,z = ent.Transform:GetWorldPosition()
            local best = ent.components.areaaware:_TestArea(x, z, true, 1)
            if best then
                local tile = best.tile_type
                local m = LowerSandstormLevelDueToTile(tile)
                _sandstormlevel = math.clamp(_sandstormlevel - m, 0, 1)
            end

            if _sandstormlevel > 0 then
                if IsUnderShade(x, y, z) then
                    _sandstormlevel = math.clamp(_sandstormlevel - 0.5, 0, 1)
                end
            end

            if _sandstormlevel > 0 then
                local tree = #TheSim:FindEntities(x, y, z, RANGE, TREE_MUST_TAGS, CANT_TAGS, nil) or 0
                local tall = #TheSim:FindEntities(x, y, z, RANGE, MUST_TAGS, CANT_TAGS, TALL_MUST_ONE_OF_TAGS) or 0
                local short = #TheSim:FindEntities(x, y, z, RANGE, MUST_TAGS, CANT_TAGS, SHORT_MUST_ONE_OF_TAGS) or 0
                local level = tree * tree_p + tall * tall_p + short * short_p
                local m = 0.06 * level
                _sandstormlevel = math.clamp(_sandstormlevel - m, 0, 1)
            end
        end
        return _sandstormlevel
    end
end)


AddPrefabPostInit("pond", function (inst)
    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("oasis")
    inst.components.oasis.radius = TUNING.SANDSTORM_OASIS_RADIUS
    TheWorld:PushEvent("ms_registeroasis", inst)

end)

AddPrefabPostInit("pond_mos", function (inst)
    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("oasis")
    inst.components.oasis.radius = TUNING.SANDSTORM_OASIS_RADIUS
    TheWorld:PushEvent("ms_registeroasis", inst)

end)

-- AddPrefabPostInit("oceantree_pillar", function (inst)
--     if not TheWorld.ismastersim then
--         return inst
--     end

--     inst:AddComponent("oasis")
--     inst.components.oasis.radius = TUNING.SHADE_CANOPY_RANGE_SMALL/4
--     TheWorld:PushEvent("ms_registeroasis", inst)
-- end)
