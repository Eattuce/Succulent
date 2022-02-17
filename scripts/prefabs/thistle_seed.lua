require "prefabutil"

local assets =
{
    Asset("ANIM", "anim/thistle_bush.zip"),
    Asset("ANIM", "anim/thistle_seed.zip"),
    Asset("IMAGE", "images/inventoryimages/thistle_seed.tex"),
    Asset("ATLAS", "images/inventoryimages/thistle_seed.xml")
}

local prefabs =
{
    "thistle_kid",
}

local seg_time = 30
local total_day_time = seg_time*16

local function ondeploy(inst, position)
    inst = inst.components.stackable:Get()
    inst:Remove()

    local sapling = SpawnPrefab("thistle_kid")
    sapling.Transform:SetPosition(position:Get())
    sapling.SoundEmitter:PlaySound("dontstarve/wilson/plant_tree")
    sapling.components.growable:SetStage(1)
    sapling.components.growable:StartGrowing(total_day_time)
    -- sapling.components.pickable:MakeBarren()
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("thistle_seed")
    inst.AnimState:SetBuild("thistle_seed")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("deployedplant")
    inst:AddTag("cattoy")
    inst:AddTag("treeseed")

    MakeInventoryFloatable(inst, "small", 0.05, 0.9)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("tradable")

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

    inst:AddComponent("inspectable")

    inst:AddComponent("fuel")
    inst.components.fuel.fuelvalue = TUNING.SMALL_FUEL

    MakeSmallBurnable(inst, TUNING.SMALL_BURNTIME)
    MakeSmallPropagator(inst)

    inst:AddComponent("inventoryitem")

    MakeHauntableLaunchAndIgnite(inst)

    inst:AddComponent("deployable")
    inst.components.deployable:SetDeployMode(DEPLOYMODE.PLANT)
    inst.components.deployable.ondeploy = ondeploy

    inst:AddComponent("forcecompostable")
    inst.components.forcecompostable.brown = true

    return inst
end

return Prefab("thistle_seed", fn, assets, prefabs),
    MakePlacer("thistle_seed_placer", "thistle_bush", "thistle_bush", "wither")