require "prefabutil"

local assets =
{
    Asset("ANIM", "anim/totem.zip"),
    Asset("IMAGE", "minimap/totem_minimap_icon.tex"),
    Asset("ATLAS", "minimap/totem_minimap_icon.xml"),
}

local assets_fx =
{
    Asset("ANIM", "anim/totem_fx.zip"),
}

local prefabs =
{
    "collapse_small",
}

-- PROTOTYPER
local function onturnon(inst)
    local fx = inst.fx
    fx.AnimState:PlayAnimation("turn_on")
    fx.AnimState:PushAnimation("idle_loop")
end

local function onturnoff(inst)
    local fx =inst.fx
    fx.AnimState:PlayAnimation("turn_off")
    fx.AnimState:PushAnimation("none")
end

local function onactivate(inst)
    if not inst.SoundEmitter:PlayingSound("sound") then
        inst.SoundEmitter:PlaySound("dontstarve/common/ancienttable_craft", "sound")
    end
end

local function Disappear(inst)
    inst:PushEvent("disappear", inst)
    inst:PushEvent("gradualfade_out")
    inst.components.totemterraformer:ChangeTiles(true)
    inst:DoTaskInTime(2, function () inst:Remove() end)
end

local function OnInit(inst)
    inst.inittask = nil

    if not (TheWorld.components.sandstorms ~= nil and TheWorld.components.sandstorms:IsSandstormActive()) then
        Disappear(inst)
    end
end

local function prototyper_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddSoundEmitter()

    inst.MiniMapEntity:SetIcon("totem_minimap_icon.tex")

    MakeObstaclePhysics(inst, .2)

    inst.AnimState:SetBank("totem")
    inst.AnimState:SetBuild("totem")
    inst.AnimState:PlayAnimation("idle_loop", true)

    inst:AddTag("structure")
    inst:AddTag("totem_real")
    inst:AddTag("prototyper")
    inst:AddTag("antlion_sinkhole_blocker")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.reversemat = {}

    inst.fx = SpawnPrefab("totem_fx")
    inst.fx.entity:SetParent(inst.entity)

    inst.inittask = inst:DoTaskInTime(0, OnInit)

    inst:AddComponent("totemterraformer")
    inst:AddComponent("gradualfader")

    inst:AddComponent("inspectable")
    inst:AddComponent("prototyper")
    inst.components.prototyper.onturnon = onturnon
    inst.components.prototyper.onturnoff = onturnoff
    inst.components.prototyper.onactivate = onactivate
    inst.components.prototyper.trees = TUNING.PROTOTYPER_TREES.OASISTECH_TWO

    inst:AddComponent("oasis")
    inst.components.oasis.radius = TUNING.SANDSTORM_OASIS_RADIUS

    TheWorld:PushEvent("ms_registeroasis", inst)

    inst.onsandstormchanged = function(src, data)
        if data.stormtype == STORM_TYPES.SANDSTORM and not data.setting then
            Disappear(inst)
        end
    end
    inst:ListenForEvent("ms_stormchanged", inst.onsandstormchanged, TheWorld)

    return inst
end

local function fx_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("totem_fx")
    inst.AnimState:SetBuild("totem_fx")
    inst.AnimState:PlayAnimation("none")

    inst.entity:SetPristine()

	-- inst:AddTag("DECOR")
    inst:AddTag("fx")
	inst:AddTag("NOCLICK")

    if not TheWorld.ismastersim then
        return inst
    end

    -- inst:ListenForEvent("animover", onanimover)

    return inst
end

local function normal_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    inst.entity:AddSoundEmitter()
    -- inst.entity:AddDynamicShadow()

    MakeObstaclePhysics(inst, .2)

    inst.AnimState:SetBank("totem")
    inst.AnimState:SetBuild("totem")
    inst.AnimState:PlayAnimation("idle_loop_fake")
    inst.AnimState:PushAnimation("idle_loop_fake")
    -- inst.DynamicShadow:Enable(true)
    -- inst.DynamicShadow:SetSize(3, 2)

    inst:AddTag("structure")
    inst:AddTag("totem")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")
    inst:AddComponent("lootdropper")

    -- inst:ListenForEvent("onbuilt", onbuilt)

    return inst
end


return Prefab("totem_fx", fx_fn, assets_fx),
    Prefab("totem_real", prototyper_fn, assets)
    -- Prefab("totem", normal_fn, assets, prefabs),
    -- MakePlacer("totem_item_placer", "totem", "totem", "idle_fake")
