
return Class(function(self, inst)

self.inst = inst
self.target_tile_type = WORLD_TILES.GRASS

local original_tile_data = {}
local tile_pts = {}

local function OnSelfAppear()
    if TheWorld.components.sandstorms ~= nil and TheWorld.components.sandstorms:IsSandstormActive() then
        return self:ChangeTiles()
    end
end

inst:ListenForEvent("appear", OnSelfAppear)

function self:SetTilePositionsToChange()
    local t = {}
    local tilepts =
    {
                                        {0, 4},
                                {-1, 3},{0, 3}, {1, 3},
                        {-2, 2},{-1, 2},{0, 2}, {1, 2}, {2, 2},
                {-3, 1},{-2, 1},{-1, 1},{0, 1}, {1, 1}, {2, 1}, {3, 1},
        {-4,0}, {-3,0}, {-2,0}, {-1, 0},{0, 0}, {1, 0}, {2, 0}, {3, 0}, {4,0},
                {-3,-1},{-2,-1},{-1,-1},{0,-1}, {1,-1}, {2,-1}, {3,-1},
                        {-2,-2},{-1,-2},{0,-2}, {1,-2}, {2,-2},
                                {-1,-3},{0,-3}, {1,-3},
                                        {0,-4}
    }

    for _,coord in pairs(tilepts) do
        local x,z = 4*coord[1], 4*coord[2]
        local _x,_y,_z = self.inst.Transform:GetWorldPosition()
        local tx,ty,tz = _x+x,_y,_z+z
        if TheWorld.Map:IsAboveGroundAtPoint(tx,ty,tz) then
            table.insert( t, { x = tx, z = tz} )
        end
    end

    tile_pts = t
    return t
end

local function FromOuterToInner()
    
end


function self:ChangeTiles(back)
    if back then
        for _, v in pairs(original_tile_data) do
            local tile = TheWorld.Map:GetTileAtPoint(v.x, 0, v.z)
            if tile then
                local x, y = TheWorld.Map:GetTileCoordsAtPoint(v.x, 0, v.z)
                TheWorld.Map:SetTile(x,y, v.tile)
            end
        end
    else
        local target = self.target_tile_type
        for _, real in pairs(self:SetTilePositionsToChange()) do
            local tile = TheWorld.Map:GetTileAtPoint(real.x, 0, real.z)
            if tile and tile ~= WORLD_TILES.MONKEY_DOCK then
                self:RecordOriginalTileType(real.x, real.z, tile)
                local x, y = TheWorld.Map:GetTileCoordsAtPoint(real.x, 0, real.z)
                TheWorld.Map:SetTile(x, y, target)
            end
        end
    end
end

function self:RecordOriginalTileType(x, z, tile)
    table.insert(original_tile_data, { x = x, z = z, tile = tile})
end

function self:OnSave()
    local data = {}
    data.tile_pts = tile_pts
    data.original_tile_type = original_tile_data
    return data
end

function self:OnLoad(data)
    if data then
        tile_pts = data.tile_pts
        original_tile_data = data.original_tile_type
    end
end

function self:GetDebugString()
    local s = {}
    for _,v in pairs(tile_pts) do
        table.insert(s, v.x)
        table.insert(s, ",")
        table.insert(s, v.y)
    end
    return table.concat(s, "|")
end

end)
