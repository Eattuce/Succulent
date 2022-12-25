local assets =
{
    Asset("ANIM", "anim/pond_succulent_plant.zip"),
}

local function SetVariation(inst, variation)
    if inst.variation ~= variation then
        inst.variation = variation
        inst.AnimState:PlayAnimation("idle_"..tostring(variation))
    end
end

local function fn(bank, build)
    return function()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddNetwork()

        inst.AnimState:SetBank(bank)
        inst.AnimState:SetBuild(build)
        inst.AnimState:PlayAnimation("idle_1", true)
        inst.AnimState:SetScale(1.5,1.5,1.5)

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        MakeMediumBurnable(inst)
        MakeSmallPropagator(inst)
        MakeHauntableIgnite(inst)

        inst:AddComponent("inspectable")

        inst.variation = 1
        inst.SetVariation = SetVariation

        return inst
    end
end

return Prefab("pond_succulent_plant", fn("pond_succulent_plant", "pond_succulent_plant"), assets)