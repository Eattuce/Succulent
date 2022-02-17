require "prefabutil"


local assets =
{
    Asset("ANIM", "anim/totem.zip"),
    Asset("ANIM", "anim/totem_item.zip"),
    Asset("ANIM", "anim/bundle.zip"),
    Asset("IMAGE", "images/inventoryimages/totem_item.tex"),
    Asset("ATLAS", "images/inventoryimages/totem_item.xml"),
    Asset("IMAGE", "minimap/totem_minimap_icon.tex"),
    Asset("ATLAS", "minimap/totem_minimap_icon.xml"),
}

local assets_fx =
{
    Asset("ANIM", "anim/totem_fx.zip"),

}

local prefabs =
{
    "collapse_small",
}

--------------------------------------------------------------------------
local CANT_TILE = GROUND.IMPASSABLE or GROUND.INVALID

local function is_land(pt)
    if TheWorld.Map:IsOceanAtPoint(pt.x, 0, pt.z) then
        return false
    elseif TheWorld.Map:GetTileAtPoint(pt.x, pt.y, pt.z) == CANT_TILE then
        return false
    end
    return true
end

local function _dochange(tiles, target)
    for _, v in ipairs(tiles) do
        local tile = TheWorld.Map:GetTileAtPoint(v.x, v.y, v.z)
        if tile ~= nil and is_land(v) then
            local original_tile_type = tile
            local x, y = TheWorld.Map:GetTileCoordsAtPoint(v.x, v.y, v.z)
            if x and y then
                TheWorld.Map:SetTile(x,y, target)
                TheWorld.Map:RebuildLayer( original_tile_type, x, y )
                TheWorld.Map:RebuildLayer( target, x, y )
            end
            local minimap = TheSim:FindFirstEntityWithTag("minimap")
            if minimap then
                minimap.MiniMap:RebuildLayer( original_tile_type, x, y )
                minimap.MiniMap:RebuildLayer( target, x, y )
            end
        end
    end
end

local function ChangeTileInDiamond(inst, length, target_tile_type, can_reverse)
    -- inst.reversemat = {}
    local tile_pts = {}
    local curve_tile_amt = length
    local len = curve_tile_amt - 1
    local pt = inst:GetPosition()
    for i = -len, len do
        if i <= 0 then
            for j = -i-len, i+len do
                table.insert( tile_pts,{x= pt.x+4*i, y=pt.y, z = pt.z+4*j} )
            end
        else
            for j = i- len, len - i do
                table.insert( tile_pts,{x= pt.x+4*i, y=pt.y, z = pt.z+4*j} )
            end
        end
    end

    if can_reverse then
        for _, v in pairs(tile_pts) do
            v.tile = TheWorld.Map:GetTileAtPoint(v.x, 0, v.z)
        end

    inst.reversemat = tile_pts
    end

    _dochange(tile_pts, target_tile_type)
end

local function ReverseTile(inst)
    if inst.reversemat and next(inst.reversemat) then
        for _, v in pairs(inst.reversemat) do
            if v.tile ~= nil then
                local target = v.tile
                local x, y = TheWorld.Map:GetTileCoordsAtPoint(v.x, v.y, v.z)
                if x and y then
                    TheWorld.Map:SetTile(x,y, target)
                    TheWorld.Map:RebuildLayer( v.tile, x, y )
                    TheWorld.Map:RebuildLayer( v.tile, x, y )
                end
                local minimap = TheSim:FindFirstEntityWithTag("minimap")
                if minimap then
                    minimap.MiniMap:RebuildLayer( v.tile, x, y )
                    minimap.MiniMap:RebuildLayer( target, x, y )
                end
            end
        end
    end
end
--------------------------------------------------------------------------

local function OnWorkFinished(inst, worker)
    if inst.components.burnable ~= nil and inst.components.burnable:IsBurning() then
        inst.components.burnable:Extinguish()
    end
    inst.components.lootdropper:DropLoot()
    inst.components.lootdropper:SetLoot({"cutstone", "cutstone"})
    local fx = SpawnPrefab("collapse_small")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("stone")
    inst:Remove()
end


-- PROTOTYPER
local function onturnon(inst)
    local fx = inst.fx
    fx.AnimState:PlayAnimation("turn_on")
    fx.AnimState:PushAnimation("idle_loop")
end

local function onturnoff(inst)
    local fx =inst.fx
    fx.AnimState:PlayAnimation("turn_off")
    fx.AnimState:PushAnimation("none")
end

local function onactivate(inst)
    -- inst.AnimState:PlayAnimation("idle_real")
    -- inst.AnimState:PushAnimation("idle_real", true)
    if not inst.SoundEmitter:PlayingSound("sound") then
        inst.SoundEmitter:PlaySound("dontstarve/common/ancienttable_craft", "sound")
    end
end

local function ToGrass(inst)
    if not inst.grass then
        inst.grass = not inst.grass
        ChangeTileInDiamond(inst, 5, GROUND.GRASS, true)
    end
end

local function ToDesert(inst)
    if not inst.grass then
        ReverseTile(inst)
        inst.grass = not inst.grass
    end
end

local function Appear(inst)
    inst:Show()
    inst.MiniMapEntity:SetEnabled(true)

    inst.AnimState:PlayAnimation("appear")
    inst.AnimState:PushAnimation("idle_loop")

    MakeObstaclePhysics(inst, .2)

    if inst.components.prototyper == nil then
        inst:AddComponent("prototyper")
        inst.components.prototyper.onturnon = onturnon
        inst.components.prototyper.onturnoff = onturnoff
        inst.components.prototyper.onactivate = onactivate
        inst.components.prototyper.trees = TUNING.PROTOTYPER_TREES.OASISTECH_TWO
    end

    ToGrass(inst)
end

local function Disappear(inst)
    inst.AnimState:PushAnimation("disappear")
    inst:ListenForEvent("animover", function ()
        inst.fx.AnimState:PlayAnimation("turn_off")

        ToDesert(inst)
        inst:Hide()
        RemovePhysicsColliders(inst)
        inst.MiniMapEntity:SetEnabled(false)

        if inst.components.prototyper ~= nil then
            inst:RemoveComponent("prototyper")
        end
    end)
end

local function OnInit(inst)
    inst.inittask = nil

    if TheWorld.components.sandstorms ~= nil and TheWorld.components.sandstorms:IsSandstormActive() then
        Appear(inst)
    else
        Disappear(inst)
    end
end

local function onsave(inst,data)
    if next(inst.reversemat) ~= nil then
        data.reversemat = inst.reversemat
        data.grass = inst.grass
    end
end

local function onload(inst,data)
    if data.reversemat ~= nil then
        inst.reversemat = data.reversemat
        inst.grass = data.grass
    end
end

local function normal_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    inst.entity:AddSoundEmitter()
    -- inst.entity:AddDynamicShadow()

    MakeObstaclePhysics(inst, .2)

    inst.AnimState:SetBank("totem")
    inst.AnimState:SetBuild("totem")
    inst.AnimState:PlayAnimation("idle_loop_fake")
    inst.AnimState:PushAnimation("idle_loop_fake")
    -- inst.DynamicShadow:Enable(true)
    -- inst.DynamicShadow:SetSize(3, 2)

    inst:AddTag("structure")
    inst:AddTag("totem")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")
    inst:AddComponent("lootdropper")

    -- inst:ListenForEvent("onbuilt", onbuilt)

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(4)
    inst.components.workable:SetOnFinishCallback(OnWorkFinished)

    return inst
end

local function prototyper_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddSoundEmitter()
    -- inst.entity:AddDynamicShadow()

    inst.MiniMapEntity:SetIcon("totem_minimap_icon.tex")
    inst.MiniMapEntity:SetEnabled(false)

    MakeObstaclePhysics(inst, .2)

    inst.AnimState:SetBank("totem")
    inst.AnimState:SetBuild("totem")
    inst.AnimState:PlayAnimation("appear")
    inst.AnimState:PushAnimation("idle_loop")

    -- inst.DynamicShadow:Enable(true)
    -- inst.DynamicShadow:SetSize(3, 2)

    inst:AddTag("structure")
    inst:AddTag("totem_real")
    inst:AddTag("prototyper")
    inst:AddTag("antlion_sinkhole_blocker")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.reversemat = {}

    inst.fx = SpawnPrefab("totem_fx")
    inst.fx.entity:SetParent(inst.entity)

    inst.inittask = inst:DoTaskInTime(0, OnInit)

    inst:AddComponent("inspectable")
    -- inst:AddComponent("prototyper")
    -- inst.components.prototyper.onturnon = onturnon
    -- inst.components.prototyper.onturnoff = onturnoff
    -- inst.components.prototyper.onactivate = onactivate
    -- inst.components.prototyper.trees = TUNING.PROTOTYPER_TREES.OASISTECH_TWO

    inst.grass = false

    inst:AddComponent("oasis")
    inst.components.oasis.radius = TUNING.SANDSTORM_OASIS_RADIUS
    TheWorld:PushEvent("ms_registeroasis", inst)

    inst.onsandstormchanged = function(src, data)
        if data.stormtype == STORM_TYPES.SANDSTORM and data.setting then
            Appear(inst)
        else
            Disappear(inst)
        end
    end
    inst:ListenForEvent("ms_stormchanged", inst.onsandstormchanged, TheWorld)

    inst:Hide()

    inst.OnSave = onsave
    inst.OnLoad = onload

    return inst
end

local function ondeploy(inst, pt)
    inst = inst.components.stackable:Get()
    inst:Remove()

    local totem = SpawnPrefab("totem")
    if totem ~= nil then
        totem.Physics:Teleport(pt.x, 0, pt.z)
        totem.Physics:SetCollides(true)
        totem.SoundEmitter:PlaySound("dontstarve/common/place_structure_stone")
    end
end

local function itemfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst:AddTag("usedeploystring")

    -- inst.AnimState:SetBank("totem_item")
    -- inst.AnimState:SetBuild("totem_item")
    inst.AnimState:SetBank("bundle")
    inst.AnimState:SetBuild("bundle")
    inst.AnimState:PlayAnimation("idle_large")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_LARGEITEM

    inst:AddComponent("inspectable")
    inst:AddComponent("inventoryitem")

    inst:AddComponent("deployable")
    inst.components.deployable.ondeploy = ondeploy

    MakeHauntableLaunch(inst)

    return inst
end


local function fx_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("totem_fx")
    inst.AnimState:SetBuild("totem_fx")
    inst.AnimState:PlayAnimation("none")

    inst.entity:SetPristine()

	-- inst:AddTag("DECOR")
    inst:AddTag("fx")
	inst:AddTag("NOCLICK")

    if not TheWorld.ismastersim then
        return inst
    end

    -- inst:ListenForEvent("animover", onanimover)

    return inst
end

return Prefab("totem", normal_fn, assets, prefabs),
                -- .._placer, "bank", "build", "idle"
                --  spriter  entity动画集  scml文件名
    Prefab("totem_item", itemfn, assets),
    MakePlacer("totem_item_placer", "totem", "totem", "idle_fake"),
    Prefab("totem_fx", fx_fn, assets_fx),
    Prefab("totem_real", prototyper_fn, assets)
