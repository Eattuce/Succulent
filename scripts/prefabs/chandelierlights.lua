
local function lightfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")

	inst.AnimState:SetBank("chandelierlight")
    inst.AnimState:SetBuild("chandelierlight")
	inst.AnimState:PlayAnimation("idle")
    inst.AnimState:SetFinalOffset(1)

    inst:AddComponent("gradualfader")
    inst.components.gradualfader:SetFadeTime(1)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    return inst
end


local function SetVariation(inst, variation)
    if inst.variation ~= variation then
        inst.variation = variation
        inst.AnimState:PlayAnimation("idle_"..tostring(variation), true)
    end
end

local function onsave(inst, data)
    data.variation = inst.variation
end

local function onload(inst, data)
    if data.variation then
        SetVariation(inst,data.variation)
    end
end

local function sparklefn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")
    inst:AddTag("DECOR")

	inst.AnimState:SetBank("chandeliersparkle")
    inst.AnimState:SetBuild("chandeliersparkle")
	inst.AnimState:PlayAnimation("idle_1", true)
    inst.AnimState:SetFinalOffset(2)
	inst.AnimState:SetScale(2.8,2.8,2.8)
	inst.AnimState:SetDeltaTimeMultiplier(1/2)

    inst:AddComponent("gradualfader")
    inst.components.gradualfader:SetFadeTime(1)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.AnimState:SetTime(math.random() * inst.AnimState:GetCurrentAnimationLength())

    inst.variation = 1
    inst.SetVariation = SetVariation

    inst.OnSave = onsave
    inst.OnLoad = onload

    inst.persists = true

    return inst
end





return Prefab("chandelierlight", lightfn, {Asset("ANIM", "anim/chandelierlight.zip")}),
    Prefab("chandeliersparkle", sparklefn, {Asset("ANIM", "anim/chandeliersparkle.zip")})
