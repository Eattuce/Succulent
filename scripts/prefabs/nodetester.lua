
local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    -- inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst:AddTag("NOCLICK")
    inst:AddTag("NODETESTER")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    return inst
end

return Prefab("nodetester", fn)