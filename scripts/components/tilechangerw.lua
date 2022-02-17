local Tilechangerw = Class(function(self, inst)
    self.inst = inst
    self.targettile = GROUND.DIRT
    self.canreverse = false

    -- self.position = self.inst:GetPosition()
    self.matrix = {}
    self.reversematrix = {}
    self.shape = "diamond" or "square"
    self.length = 2
end)


--------------------------------------------------------------------------
local CANT_TILE = GROUND.IMPASSABLE or GROUND.INVALID
local function clearnoneland(tiles)
    for i, v in ipairs(tiles) do
        if not TheWorld.Map:IsOceanAtPoint(v.x, 0, v.z) then
            local tile = TheWorld.Map:GetTileAtPoint(v.x, v.y, v.z)
            if tile == CANT_TILE then
                table.remove( tiles,i )
            end
        else
            table.remove( tiles,i )
        end
    end
    return tiles
end
--------------------------------------------------------------------------
-- Set
--!
function Tilechangerw:SetTargetTileType(type)
    self.targettile = type or self.targettile
end

function Tilechangerw:SetForm(shape, length)
    self.shape = shape
    self.length = length
end

function Tilechangerw:SetReversible(able)
    self.canreverse = able
end

function Tilechangerw:SetReverseMat()
    if not self.canreverse then
        return
    end
    if next(self.matrix) == nil then
        return
    end
    local landmat = self.matrix
    landmat = clearnoneland(landmat)
    for _, v in pairs(landmat) do
        v.tile = TheWorld.Map:GetTileAtPoint(v.x, 0, v.z)
    end
    self.reversematrix = landmat
end

--------------------------------------------------------------------------
-- Get
function Tilechangerw:CanReverse()
    return self.canreverse
end

function Tilechangerw:GetForm()
    return self.shape,self.lenght
end

function Tilechangerw:GetReverseMatix()
    return self.reversematrix
end
--------------------------------------------------------------------------

-- Work
--!
function Tilechangerw:SetMatrix(shape,length)
    self:SetForm(shape,length)
    local pt = self.inst:GetPosition()
    if shape == "diamond" then
        length = length-1
        for i = -length, length do
            if i <= 0 then
                for j = -i-length, i+length do
                    table.insert( self.matrix,{x= pt.x+4*i, y=pt.y, z = pt.z+4*j} )
                end
            else
                for j = i- length, length - i do
                    table.insert( self.matrix,{x= pt.x+4*i, y=pt.y, z = pt.z+4*j} )
                end
            end
        end
    else
        for i = -length, length do
            for j = -length, length do
                table.insert( self.matrix,{x= pt.x+4*i, y=pt.y, z = pt.z+4*j} )
            end
        end
    end
end

function Tilechangerw:DoChange()
    if self:CanReverse() then
        self:SetReverseMat()
    end
    for _, v in ipairs(self.matrix) do
        local tile = TheWorld.Map:GetTileAtPoint(v.x, v.y, v.z)
        if tile ~= nil then
            local original_tile_type = tile
            local x, y = TheWorld.Map:GetTileCoordsAtPoint(v.x, v.y, v.z)
            if x and y then
                TheWorld.Map:SetTile(x,y, self.targettile)
                TheWorld.Map:RebuildLayer( original_tile_type, x, y )
                TheWorld.Map:RebuildLayer( self.targettile, x, y )
            end
            local minimap = TheSim:FindFirstEntityWithTag("minimap")
            if minimap then
                minimap.MiniMap:RebuildLayer( original_tile_type, x, y )
                minimap.MiniMap:RebuildLayer( self.targettile, x, y )
            end
        end
    end
end

function Tilechangerw:ReverseTile()
    if next(self.reversematrix) ~= nil  then
        for _, v in pairs(self.reversematrix) do
            if v.tile ~= nil then
                local x, y = TheWorld.Map:GetTileCoordsAtPoint(v.x, v.y, v.z)
                if x and y then
                    TheWorld.Map:SetTile(x,y, v.tile)
                    TheWorld.Map:RebuildLayer( v.tile, x, y )
                    TheWorld.Map:RebuildLayer( v.tile, x, y )
                end
                local minimap = TheSim:FindFirstEntityWithTag("minimap")
                if minimap then
                    minimap.MiniMap:RebuildLayer( v.tile, x, y )
                    minimap.MiniMap:RebuildLayer( v.tile, x, y )
                end
            end
        end
    end
    self.reversematrix = {}
end


function Tilechangerw:OnSave()
    if next(self.reversematrix) ~= nil then
        return
        {
            matrix = self.matrix,
            reversematrix = self.reversematrix,
            shape = self.shape,
            length = self.length,
        }
    end
end

function Tilechangerw:OnLoad(data)
    if data.reversematrix ~= nil then
        self.matrix = data.matrix
        self.reversematrix = data.reversematrix
        self.shape = data.shape
        self.length = data.length
    end
end


return Tilechangerw