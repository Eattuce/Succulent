
local assets = { Asset("ANIM", "anim/hat_skeleton.zip") }

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("skeletonhat")
    inst.AnimState:SetBuild("hat_skeleton")
    inst.AnimState:PlayAnimation("anim")
    inst.AnimState:SetAddColour(0.5, 0.5, 0.5, 0.5)

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    return inst
end

return Prefab("shadowprotect_fx", fn, assets)
