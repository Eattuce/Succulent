require "prefabutil"

local assets =
{
    Asset("ANIM", "anim/totem_real.zip"),
    Asset("IMAGE", "minimap/totem_minimap_icon.tex"),
    Asset("ATLAS", "minimap/totem_minimap_icon.xml"),
}

local assets_fx =
{
    Asset("ANIM", "anim/totem_bubble_fx.zip"),
}

local prefabs =
{
    "collapse_small",
}

-- PROTOTYPER
local function onturnon(inst)
    SendModRPCToClient(GetClientModRPC("Succulent_RPC", "Chandelier_FadeIn"), nil, inst.fx)

end

local function onturnoff(inst)
    SendModRPCToClient(GetClientModRPC("Succulent_RPC", "Chandelier_FadeOut"), nil, inst.fx)
end

local function onactivate(inst)
    if not inst.SoundEmitter:PlayingSound("sound") then
        inst.SoundEmitter:PlaySound("dontstarve/common/ancienttable_craft", "sound")
    end
end

local function Disappear(inst)
    ErodeAway(inst.fx)
    inst.components.totemterraformer:ChangeTiles(true)
    ErodeAway(inst, 2)
    inst:PushEvent("Disappear")
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

    inst.AnimState:SetBank("totem_real")
    inst.AnimState:SetBuild("totem_real")
    inst.AnimState:PlayAnimation("idle_loop", true)

    inst:AddTag("structure")
    inst:AddTag("totem_real")
    inst:AddTag("prototyper")
    inst:AddTag("antlion_sinkhole_blocker")

    inst:AddComponent("gradualfader")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.reversemat = {}

    inst.fx = SpawnPrefab("totem_bubble_fx")
    inst.fx.entity:SetParent(inst.entity)
    inst.fx.Follower:FollowSymbol(inst.GUID, "high", 20, 20, 0)

    inst:AddComponent("totemterraformer")

    inst:DoTaskInTime(0, function ()
        if not (TheWorld.components.sandstorms ~= nil and TheWorld.components.sandstorms:IsSandstormActive()) then
            Disappear(inst)
        end
    end)

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
    inst.entity:AddFollower()

    inst.AnimState:SetBank("totem_bubble_fx")
    inst.AnimState:SetBuild("totem_bubble_fx")
    inst.AnimState:PlayAnimation("idle_loop", true)
    inst.AnimState:OverrideMultColour(0, 0, 0, 0)
    inst.AnimState:SetFinalOffset(-1)

    inst.entity:SetPristine()

    inst:AddTag("fx")
	inst:AddTag("NOCLICK")

    inst:AddComponent("gradualfader")
    inst.components.gradualfader:SetFadeTime(1)
    if not TheWorld.ismastersim then
        return inst
    end

    return inst
end

return Prefab("totem_bubble_fx", fx_fn, assets_fx),
    Prefab("totem_real", prototyper_fn, assets)
    -- Prefab("totem", normal_fn, assets, prefabs),
    -- MakePlacer("totem_item_placer", "totem", "totem", "idle_fake")
