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

    inst:AddTag("show_spoilage")
    inst:AddTag("veggie_crisps")
    -- inst:AddTag("AlawysShowSpoilage")
    -- inst.always_spoilage_colour = 0

    MakeInventoryFloatable(inst, "small", 0.05, 0.9)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("tradable")

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_MEDITEM

    inst:AddComponent("perishable")
    inst.components.perishable:SetPerishTime(TUNING.PERISH_SUPERSLOW)
    inst.components.perishable.onperishreplacement = "veggie_crisps"

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")

    inst:AddComponent("edible")
    inst.components.edible.healthvalue = TUNING.HEALING_MED
    inst.components.edible.hungervalue = TUNING.CALORIES_MED
    inst.components.edible.sanityvalue = TUNING.SANITY_MED
    inst.components.edible.foodtype = FOODTYPE.VEGGIE
    inst.components.edible.degrades_with_spoilage = false

    return inst
end

return Prefab("veggie_crisps", fn, assets)
