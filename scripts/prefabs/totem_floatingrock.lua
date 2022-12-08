
local function onload( inst )
    inst.AnimState:SetTime(math.random() * inst.AnimState:GetCurrentAnimationLength())
end

local function MakeDeco(name, asset, bb, anim)
    local assets =
    {
        Asset("ANIM", "anim/"..asset..".zip"),
    }

    local function fn()
        local inst = CreateEntity()
    
        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddNetwork()
        inst.entity:AddFollower()
    
        inst.AnimState:SetBank(bb)
        inst.AnimState:SetBuild(bb)
        inst.AnimState:PlayAnimation(anim, true)

        inst.entity:SetPristine()
    
        inst:AddTag("fx")
        inst:AddTag("NOCLICK")
    
        if not TheWorld.ismastersim then
            return inst
        end
    
        inst.AnimState:SetTime(math.random() * inst.AnimState:GetCurrentAnimationLength())
        inst.AnimState:SetDeltaTimeMultiplier(1 + math.random()*0.5)

        inst.OnLoadPostPass = onload
    
        return inst
    end

    return Prefab(name, fn, assets)
end


return MakeDeco("totem_floatingrock", "floating_rock", "floating_rock", "easeInOut"),
    MakeDeco("totem_vine", "totem_vine", "totem_vine", "idle")
