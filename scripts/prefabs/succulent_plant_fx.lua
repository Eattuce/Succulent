local assets =
{
    Asset("ANIM", "anim/succulent_plant_fx.zip"),
}
--[[
    动画 1 原版grass深绿色较高
    动画 2 原版grass颜色较浅较低
    动画 3 新 淡绿 宽 多片
    动画 4 新 深色 两片
    动画 5 新 变花
]]--

local function OnAnimOver(inst)
    if inst.AnimState:IsCurrentAnimation("ungrow_"..tostring(inst.variation)) then
        inst:Remove()
    else
        local x, y, z = inst.Transform:GetWorldPosition()
        for i, v in ipairs(AllPlayers) do
            if not (v.components.health:IsDead() or v:HasTag("playerghost")) and
                v.entity:IsVisible() and
                v:GetDistanceSqToPoint(x, y, z) < 4 then
                inst.AnimState:PlayAnimation("idle_"..tostring(inst.variation))
                return
            end
        end
        inst.AnimState:PlayAnimation("ungrow_"..inst.variation)
    end
end

local function OnAnimOver_flower(inst)
    local x, y, z = inst.Transform:GetWorldPosition()

    if inst.AnimState:IsCurrentAnimation("ungrow_"..tostring(inst.variation)) then
            inst:Remove()
    else
        if #TheSim:FindEntities(x, y, z, 1.7, {"succulent_flower"}) ~= 0 then
            inst.AnimState:PlayAnimation("idle_"..tostring(inst.variation))
        else
            inst.AnimState:PlayAnimation("ungrow_"..inst.variation)
        end
    end
end

local function SetVariation(inst, variation)
    if inst.variation ~= variation then
        inst.variation = variation
        inst.AnimState:PlayAnimation("grow_"..tostring(variation))
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

local function common(persists)
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.AnimState:SetBuild("succulent_plant_fx")
    inst.AnimState:SetBank("succulent_plant_fx")
    inst.AnimState:PlayAnimation("grow_1")

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.variation = 1
    inst.SetVariation = SetVariation

    inst.persists = persists

    return inst
end

local function flower()
    local inst = common(true)

    inst:AddTag("succulent_plant_fx_flower")

    if not TheWorld.ismastersim then
        return inst
    end

    inst:ListenForEvent("animover", OnAnimOver_flower)

    inst.OnSave = onsave
    inst.OnLoad = onload

    return inst
end

local function player()
    local inst = common(false)

    inst:AddTag("succulent_plant_fx")

    if not TheWorld.ismastersim then
        return inst
    end

    inst:ListenForEvent("animover", OnAnimOver)

    return inst
end

local function tent()
    local inst = common(true)
    inst.AnimState:PlayAnimation("tent_1_right")
    -- inst.AnimState:PushAnimation("tent_1_right_idle")

    if not TheWorld.ismastersim then
        return inst
    end

    return inst
end


return Prefab("succulent_plant_fx", player, assets),
    Prefab("succulent_plant_fx_flower", flower, assets),
    Prefab("tent_plant_fx", tent, assets)
