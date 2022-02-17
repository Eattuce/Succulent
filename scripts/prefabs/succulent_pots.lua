require "prefabutil"

-- local assets =
-- {
--     Asset("ANIM", "anim/succulent_medpot.zip"),
--     Asset("ANIM", "anim/medpot_spa.zip"),
-- }

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
    -- inst.AnimState:PlayAnimation("plant_4")
    -- inst.AnimState:PushAnimation("plant_4_idle")
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

local function MakePot(prefab, data)
    local function fn()
        local inst = common()

        inst.AnimState:SetBank(data.bank)
        inst.AnimState:SetBuild(data.build)
        inst.AnimState:PlayAnimation(data.anim)
        if data.loop then
            inst.AnimState:PushAnimation(data.loop, false)
        end

        if data.tags then
            for _,tag in pairs(data.tags) do
                inst:AddTag(tag)
            end
        end

        if data.common_init_fn then
            data.common_init_fn(inst)
        end

        if not inst._ismastersim then
            return inst
        end

        inst.components.workable:SetWorkLeft(data.workleft)
        inst.components.workable:SetOnFinishCallback(data.onhammered)

        inst:ListenForEvent("onbuilt", data.onbuilt)

        if data.master_init_fn then
            data.master_init_fn(inst)
        end

        inst:ListenForEvent("snowcoveredchanged", MakeSnowCovered)

        return inst
    end

    return Prefab(prefab, fn, data.assets, prefabs)
end

local defs =
{
    succulent_medpot =
    {
        bank = "succulent_medpot",
        build = "succulent_medpot",
        anim = "idle",
        placer_anim = "idle",
        workleft = 1,
        tags = {"structure"},
        onhammered = onhammered_med,
        onbuilt = onbuilt_med,
        master_init_fn = function (inst) MakeSmallBurnable(inst) end,
        assets = {Asset("ANIM", "anim/succulent_medpot.zip"),Asset("ANIM", "anim/medpot_spa.zip")}
    },
    succulent_largepot =
    {
        bank = "succulent_farm",
        build = "succulent_farm",
        anim = "plant_4",
        loop = "plant_4_idle",
        placer_anim = "plant_4_idle",
        workleft = 3,
        placer_fn = function (inst)
            inst.AnimState:Hide("snow")
        end,
        onhammered = onhammered_large,
        onbuilt = onbuilt_large,
        common_init_fn = function (inst) MakeObstaclePhysics(inst, .5) end,
        master_init_fn = function (inst)
            MakeMediumBurnable(inst, nil, nil, true)
            inst.components.burnable:SetOnBurntFn(onburnt_large)
            inst.components.burnable:SetOnIgniteFn(onignite_large)
            inst.components.burnable:SetOnExtinguishFn(onextinguish_large)

            inst.OnSave = onsave
            inst.OnLoad = onload
        end,
        assets = {Asset("ANIM", "anim/succulent_farm.zip")}
    },

}

local objects = {}
for prefabname, data in pairs(defs) do
    table.insert(objects, MakePot(prefabname, data))
    table.insert(objects, MakePlacer(prefabname.."_placer", data.bank, data.build, data.placer_anim, nil, nil, nil, nil, nil, nil, data.placer_fn))
end

return unpack(objects)
