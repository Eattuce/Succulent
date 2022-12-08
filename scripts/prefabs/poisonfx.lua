local assets =
{
	Asset("ANIM", "anim/poisonfx.zip"),
}

local function kill(inst)
	inst:Remove()
end

local function StopBubbles(inst)
	inst:RemoveEventCallback("animqueueover", StopBubbles)
	inst:ListenForEvent("animqueueover", kill)
end

local function common(play, push)

	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
    inst.entity:AddNetwork()

	inst.AnimState:SetBank("poisonfx")
	inst.AnimState:SetBuild("poisonfx")
	-- inst.AnimState:SetScale(1.8,1.8,1.8)
    inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
	inst.AnimState:SetFinalOffset(2)
    inst.AnimState:SetLayer(LAYER_BACKGROUND)

	inst._ismastersim = TheWorld.ismastersim

	inst:AddTag("fx")
    inst:AddTag("NOCLICK")

	if not inst._ismastersim then
		return inst
	end

	inst.Kill = kill

	return inst
end

local function MakeFx(name, play, push)
    local function fn()
        local inst = common()

        inst.AnimState:PlayAnimation(play)
        if push then
            inst.AnimState:PushAnimation(push, false)
        end

        return inst
    end

    return Prefab(name, fn, assets)
end

return MakeFx("poisonfx_attached", "attached_idle"),

    MakeFx("poisonfx_center", "center", "center_idle"),
    MakeFx("poisonfx_center_idle", "center_idle"),

    MakeFx("poisonfx_left", "left", "left_idle"),
    MakeFx("poisonfx_left_idle", "left_idle"),

    MakeFx("poisonfx_right", "right", "right_idle"),
    MakeFx("poisonfx_right_idle", "right_idle"),

    MakeFx("poisonfx_confine", "confine")