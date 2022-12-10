
local function onload( inst )
    inst.AnimState:SetTime(math.random() * inst.AnimState:GetCurrentAnimationLength())
end

local function base(bb, anim)
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    inst.entity:AddFollower()

    inst.AnimState:SetBank(bb)
    inst.AnimState:SetBuild(bb)
    inst.AnimState:PlayAnimation(anim, true)

    inst:AddTag("fx")
    inst:AddTag("NOCLICK")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    return inst
end

local function MakeRock(name, asset, bb, anim)
    local assets =
    {
        Asset("ANIM", "anim/"..asset..".zip"),
    }

    local function fn()
        local inst = base(bb, anim)

        if not TheWorld.ismastersim then
            return inst
        end
    
        inst.AnimState:SetDeltaTimeMultiplier(1.2 + math.random()*0.3)
        inst.AnimState:SetTime(math.random() * inst.AnimState:GetCurrentAnimationLength())
        inst.OnLoadPostPass = onload
    
        return inst
    end

    return Prefab(name, fn, assets)
end

local function MakeVine(name, asset, bb, anim)
    local assets =
    {
        Asset("ANIM", "anim/"..asset..".zip"),
    }

    local function fn()
        local inst = base(bb, anim)

        if not TheWorld.ismastersim then
            return inst
        end
    
        inst.AnimState:SetDeltaTimeMultiplier(0.8 + math.random()*0.2)
        inst.AnimState:SetTime(math.random() * inst.AnimState:GetCurrentAnimationLength())
        inst.OnLoadPostPass = onload

        return inst
    end

    return Prefab(name, fn, assets)
end

local function MakeDeco(name, asset, bb, anim)
    local assets =
    {
        Asset("ANIM", "anim/"..asset..".zip"),
    }

    local function fn()
        return base(bb, anim)
    end

    return Prefab(name, fn, assets)
end

return MakeRock("totem_floatingrock", "floating_rock", "floating_rock", "easeInOut"),
    MakeVine("totem_vine", "totem_vine", "totem_vine", "idle"),
    MakeDeco("totem_uppervine", "totem_uppervine", "totem_uppervine", "idle"),
    MakeDeco("totem_lowervine", "totem_lowervine", "totem_lowervine", "idle_1")
