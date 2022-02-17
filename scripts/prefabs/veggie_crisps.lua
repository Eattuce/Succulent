local assets =
{
    Asset("ANIM", "anim/veggie_crisps.zip"),
    Asset("IMAGE", "images/inventoryimages/veggie_crisps.tex"),
    Asset("ATLAS", "images/inventoryimages/veggie_crisps.xml")
}

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("veggie_crisps")
    inst.AnimState:SetBuild("veggie_crisps")
    inst.AnimState:PlayAnimation("idle")
    inst.AnimState:SetScale(1.4,1.4,1.4)

    MakeInventoryFloatable(inst, "small", 0.05, 0.9)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("tradable")

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_MEDITEM

    -- inst:AddComponent("perishable")
    -- inst.components.perishable:SetPerishTime(999)
    -- inst.components.perishable:StopPerishing()

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")

    inst:AddComponent("edible")
    -- inst.components.edible.healthvalue = 25
    -- inst.components.edible.hungervalue = 15
    -- inst.components.edible.sanityvalue = 20
    inst.components.edible.healthvalue = TUNING.HEALING_MED
    inst.components.edible.hungervalue = TUNING.CALORIES_MED
    inst.components.edible.sanityvalue = TUNING.SANITY_MED
    inst.components.edible.foodtype = FOODTYPE.VEGGIE

    return inst
end

return Prefab("veggie_crisps", fn, assets)
