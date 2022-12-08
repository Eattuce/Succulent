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

local function ondeploy(inst, pt, deployer)
    local tree = SpawnPrefab("thistle_kid")
    if tree ~= nil then
        tree.Transform:SetPosition(pt:Get())
        inst.components.stackable:Get():Remove()
        if tree.components.pickable ~= nil then
            tree.components.growable:SetStage(1)
            tree.components.growable:StartGrowing()
        end
        if deployer ~= nil and deployer.SoundEmitter ~= nil then
            deployer.SoundEmitter:PlaySound("dontstarve/common/plant")
        end
    end
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
    MakePlacer("thistle_seed_placer", "thistle_bush", "thistle_bush", "idle_1"),
    MakePlacer("dug_thistle_bush_placer", "thistle_bush", "thistle_bush", "idle_1")