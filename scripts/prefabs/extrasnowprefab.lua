
local function MakeSnow(name)
    local assets =
    {
        Asset("ANIM", "anim/"..name..".zip"),
    }

    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddNetwork()
        inst.entity:AddFollower()

        inst.AnimState:SetBank(name)
        inst.AnimState:SetBuild(name)
        inst.AnimState:PlayAnimation("idle")
        inst.AnimState:SetFinalOffset(1)

        inst:AddTag("fx")
        inst:AddTag("NOCLICK")
        inst:AddTag("NOBLOCK")
        inst:AddTag("DECO")
        inst:AddTag("INLIMBO")

        MakeSnowCoveredPristine(inst)

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        MakeSnowCovered(inst)

        return inst
    end

    return Prefab(name, fn, assets)
end

return MakeSnow("totem_snow"),
    MakeSnow("rack_snow"),
    MakeSnow("succulentchest_snow")
