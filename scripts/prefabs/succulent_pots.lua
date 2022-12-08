require "prefabutil"

local assets_med =      {Asset("ANIM", "anim/succulent_medpot.zip")}
local assets_large =    {Asset("ANIM", "anim/succulent_farm.zip")}

local prefabs =
{
    "collapse_small",
}

local function onhammered_med(inst)
    local fx = SpawnPrefab("collapse_small")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("pot")
    inst.components.lootdropper:DropLoot()
    inst:Remove()
end

local function onbuilt_med(inst)
    -- inst.AnimState:PlayAnimation("idle")

    inst.SoundEmitter:PlaySound("dontstarve/common/together/succulent_craft")
end

------------------------------------------------------------------------
------------------------------------------------------------------------
local function onhammered_large(inst, worker)
    if inst.components.burnable ~= nil and inst.components.burnable:IsBurning() then
        inst.components.burnable:Extinguish()
    end

    inst.components.lootdropper:DropLoot()

    local fx = SpawnPrefab("collapse_small")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("wood")
    inst:Remove()
end

local function onignite_large(inst)
    DefaultBurnFn(inst)
end

local function onburnt_large(inst)
    DefaultBurntStructureFn(inst)
end

local function onextinguish_large(inst)
    DefaultExtinguishFn(inst)
end

local function onbuilt_large(inst)
    inst.SoundEmitter:PlaySound("dontstarve/common/together/succulent_craft")
end

local function onsave(inst, data)
    if inst:HasTag("burnt") or (inst.components.burnable ~= nil and inst.components.burnable:IsBurning()) then
        data.burnt = true
    end
end

local function onload(inst, data)
    if data ~= nil then
        if data.burnt then
            inst.components.burnable.onburnt(inst)
        end
    end
end

local function OnBasicSkin(inst)
    if not inst.components.burnable then
        MakeMediumBurnable(inst, nil, nil, true)
        inst.components.burnable:SetOnBurntFn(onburnt_large)
        inst.components.burnable:SetOnIgniteFn(onignite_large)
        inst.components.burnable:SetOnExtinguishFn(onextinguish_large)
        end

    if inst.components.workable then
        inst.components.workable:SetWorkLeft(3)
    end
end

local function OnWaterSkin(inst)
    if inst.components.burnable then
        if inst.components.burnable:IsBurning() then
            inst.components.burnable:Extinguish()
        end
        if inst.components.burnable:IsSmoldering() then
            inst.components.burnable:SmotherSmolder()
        end

        inst:RemoveComponent("burnable")
    end

    if inst.components.workable then
        inst.components.workable:SetWorkLeft(1)
    end
end

local function common()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddSoundEmitter()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst:AddTag("cavedweller")

    inst.entity:SetPristine()

    MakeSnowCoveredPristine(inst)

    inst._ismastersim = TheWorld.ismastersim

    if not inst._ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    MakeSmallPropagator(inst)

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)

    inst:AddComponent("lootdropper")

    return inst
end

local function medpot_fn()
    local inst = common()

    inst.AnimState:SetBank("succulent_medpot")
    inst.AnimState:SetBuild("succulent_medpot")
    inst.AnimState:PlayAnimation("idle")
    -- MakeSmallObstaclePhysics(inst, .1)

    MakeInventoryPhysics(inst, nil, 0.7)
    MakeInventoryFloatable(inst, nil, 0.2, {1, 0.9, 1.1})

    -- 浮动
    -- inst.components.floater.bob_percent = 0

    local land_time = (POPULATING and math.random()*5*FRAMES) or 0
    inst:DoTaskInTime(land_time, function(inst)
        inst.components.floater:OnLandedServer()
    end)

    inst:AddTag("extrabuilddist")

    if not inst._ismastersim then
        return inst
    end

    inst.components.workable:SetWorkLeft(1)
    inst.components.workable:SetOnFinishCallback(onhammered_med)

    MakeSmallBurnable(inst, TUNING.SMALL_FUEL)

    inst:ListenForEvent("onbuilt", onbuilt_med)

    return inst
end

local function largepot_fn()
    local inst = common()

    inst.AnimState:SetBank("succulent_farm")
    inst.AnimState:SetBuild("succulent_farm")
    inst.AnimState:PlayAnimation("plant_4")
    inst.AnimState:PushAnimation("plant_4_idle")

    MakeInventoryPhysics(inst, nil, 1)
    MakeInventoryFloatable(inst, "med", 0, {1.1, 0.9, 1.1})

    local land_time = (POPULATING and math.random()*5*FRAMES) or 0
    inst:DoTaskInTime(land_time, function(inst)
        inst.components.floater:OnLandedServer()
    end)

    inst:AddTag("structure")

    if not inst._ismastersim then
        return inst
    end

    inst.components.workable:SetWorkLeft(3)
    inst.components.workable:SetOnFinishCallback(onhammered_large)

    inst:ListenForEvent("onbuilt", onbuilt_large)
    -- inst:ListenForEvent("snowcoveredchanged", MakeSnowCovered)
    MakeSnowCovered(inst)

    MakeMediumBurnable(inst, nil, nil, true)
    inst.components.burnable:SetOnBurntFn(onburnt_large)
    inst.components.burnable:SetOnIgniteFn(onignite_large)
    inst.components.burnable:SetOnExtinguishFn(onextinguish_large)

    inst.SetBasic = OnBasicSkin
    inst.SetSkin = OnWaterSkin

    inst.OnSave = onsave
    inst.OnLoad = onload

    return inst
end

return Prefab("succulent_medpot", medpot_fn, assets_med, prefabs),
    MakePlacer("succulent_medpot_placer","succulent_medpot","succulent_medpot", "idle"),
    Prefab("succulent_largepot", largepot_fn, assets_large, prefabs),
    MakePlacer("succulent_largepot_placer","succulent_farm","succulent_farm", "plant_4_idle", nil, nil, nil, nil, nil, nil, function (inst)
        inst.AnimState:Hide("snow")
    end)
