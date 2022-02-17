require "prefabutil"

local assets =
{
    Asset("ANIM", "anim/python_fountain.zip"),
    Asset("IMAGE", "minimap/fountain_minimapicon.tex" ),
    Asset("ATLAS", "minimap/fountain_minimapicon.xml" ),
    Asset("ANIM", "anim/python_fountain_item.zip"),
    Asset("IMAGE", "images/inventoryimages/python_fountain_item.tex" ),
    Asset("ATLAS", "images/inventoryimages/python_fountain_item.xml" ),

}
local assets_item =
{
    Asset("ANIM", "anim/bundle.zip"),
}
local prefabs =
{
    "collapse_big",
}
local prefabs_item =
{
    "python_fountain",
}


local function onhammered(inst, worker)
    inst.components.lootdropper:DropLoot()
    local fx = SpawnPrefab("collapse_big")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("stone")
    inst:Remove()
end

local function turnon(inst)
    if not inst.AnimState:IsCurrentAnimation("flow_loop") then
        inst.AnimState:PlayAnimation("flow_pre")
        inst.AnimState:PushAnimation("flow_loop")

        inst.SoundEmitter:PlaySound("dripple/dripple/dripple", "on_loop", 0.8)
        inst.components.watersource.available = true
    end
end

local function turnoff(inst)
    if not inst.AnimState:IsCurrentAnimation("off") then
        inst.AnimState:PlayAnimation("flow_pst")
        inst.AnimState:PushAnimation("off")
        inst.components.watersource.available = false
        inst.SoundEmitter:KillSound("on_loop")
    end
end

local function ondeploy(inst, pt, doer)
    inst = inst.components.stackable:Get()
    inst:Remove()

    local fountain = SpawnPrefab("python_fountain")
    if fountain ~= nil then
        fountain.Physics:Teleport(pt.x, 0, pt.z)
        fountain.Physics:SetCollides(true)
        fountain.AnimState:PlayAnimation("flow_pre")
        fountain.AnimState:PushAnimation("flow_loop")
        fountain.SoundEmitter:PlaySound("dontstarve/common/place_structure_stone")
    end
end

local function structure_fn()

    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    inst.MiniMapEntity:SetIcon("fountain_minimapicon.tex")

    inst.AnimState:SetBuild("python_fountain")
    inst.AnimState:SetBank("fountain")
    inst.AnimState:PlayAnimation("flow_loop", true)

    inst.SoundEmitter:PlaySound("dripple/dripple/dripple", "on_loop", 0.5)
    inst.entity:SetPristine()

    MakeInventoryPhysics(inst)

    inst:AddTag("python_fountain")
    -- inst:AddTag("antlion_sinkhole_blocker")
    inst:AddTag("structure")
    inst:AddTag("watersource")

    MakeObstaclePhysics(inst, 1)


    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")
    inst:AddComponent("lootdropper")

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(4)
    inst.components.workable:SetOnFinishCallback(onhammered)

    inst:AddComponent("machine")
    inst.components.machine.turnonfn = turnon
    inst.components.machine.turnofffn = turnoff
    inst.components.machine.cooldowntime = 1
    inst.components.machine.ison = true

    inst:AddComponent("watersource")

    return inst
end

local function item_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    -- inst.AnimState:SetBuild("python_fountain_item")
    -- inst.AnimState:SetBank("python_fountain_item")
    inst.AnimState:SetBuild("bundle")
    inst.AnimState:SetBank("bundle")
    inst.AnimState:PlayAnimation("idle_large")

    inst.entity:SetPristine()

    inst:AddTag("usedeploystring")
    inst:AddTag("python_fountain_item")

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

return Prefab("python_fountain", structure_fn, assets, prefabs),
    Prefab("python_fountain_item", item_fn, assets_item, prefabs_item),
    MakePlacer("python_fountain_item_placer", "fountain", "python_fountain", "off")
    --                                  bank (entity name) build (file name)