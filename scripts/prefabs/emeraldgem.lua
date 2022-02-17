local assets =
{
    Asset("ANIM", "anim/emeraldgem.zip"),
    Asset("IMAGE", "images/inventoryimages/emeraldgem.tex"),
    Asset("ATLAS", "images/inventoryimages/emeraldgem.xml")
}

local function Sparkle(inst)
    if not inst.AnimState:IsCurrentAnimation("emeraldgem_sparkle") then
        inst.AnimState:PlayAnimation("emeraldgem_sparkle")
        inst.AnimState:PushAnimation("emeraldgem_idle", true)
    end
    inst:DoTaskInTime(4 + math.random(), Sparkle)
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("gems")
    inst.AnimState:SetBuild("emeraldgem")
    inst.AnimState:PlayAnimation("emeraldgem_idle")

    inst:AddTag("molebait")
    -- inst:AddTag("quakedebris")
    inst:AddTag("gem")

    MakeInventoryFloatable(inst, "small", 0.10, 0.85)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("edible")
    inst.components.edible.foodtype = FOODTYPE.ELEMENTAL

    -- if TUNING.EMERALDMOONEYE_ENABLE or TUNING.FORCRABKING_EMEGEM then
        inst:AddComponent("tradable")
    -- end
    inst.components.edible.hungervalue = 5

    inst:AddComponent("bait")

    inst:AddComponent("repairer")
    inst.components.repairer.repairmaterial = MATERIALS.GEM
    inst.components.repairer.workrepairvalue = TUNING.REPAIR_GEMS_WORK

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")

    MakeHauntableLaunchAndSmash(inst)

    inst:DoTaskInTime(1, Sparkle)

    return inst
end
return Prefab("emeraldgem", fn, assets)