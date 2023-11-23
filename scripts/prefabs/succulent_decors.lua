
local function MakeDecor(data)
    local assets =
    {
        Asset("ANIM", "anim/"..data.name..".zip"),
        Asset("IMAGE", "images/inventoryimages/"..data.name..".tex" ),
        Asset("ATLAS", "images/inventoryimages/"..data.name..".xml" ),
    } or {}
    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddFollower()
        inst.entity:AddSoundEmitter()
        inst.entity:AddLight()
        inst.entity:AddNetwork()

        MakeInventoryPhysics(inst)

        inst.AnimState:SetBank(data.name)
        inst.AnimState:SetBuild(data.name)
        inst.AnimState:PlayAnimation("idle")

        inst:AddTag("furnituredecor") -- From "furnituredecor", for optimization

        MakeInventoryFloatable(inst, "small", data.float.x or 0.05, data.float.y or 0.65)

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst:AddComponent("furnituredecor")
        inst:AddComponent("inspectable")
        inst:AddComponent("inventoryitem")

        MakeHauntable(inst)
        MakeSmallBurnable(inst)
        MakeSmallPropagator(inst)

        return inst
    end

    return Prefab(data.name, fn, assets)
end

return MakeDecor({name = "succulent_decor_mushroom", float = {x = 0.05, y = 1}}),
    MakeDecor({name = "succulent_decor_egg", float = {x = 0.05, y = 1}})