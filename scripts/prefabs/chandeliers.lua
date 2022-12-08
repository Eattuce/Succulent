require "prefabutil"
require "prefabutil_c"

local assets =
{
	Asset("ANIM", "anim/rock_chandelier.zip"),
}

local prefabs =
{
    "fireflies",
}

local FADE_FRAMES = 10
local FADE_INTENSITY = .8
local FADE_FALLOFF = .7
local LIGHTRADIUS = 6

local function Reveal(inst)
    if not TheWorld.state.isday then
        inst:StopWatchingWorldState("isday", Reveal)
    end
end

local function HideForSomeTime(inst)
    inst:Hide()
    inst:WatchWorldState("isday", Reveal)
end


local function OnUpdateFade(inst)
    local k
    if inst._fade:value() <= FADE_FRAMES then
        inst._fade:set_local(math.min(inst._fade:value() + 1, FADE_FRAMES))
        k = inst._fade:value() / FADE_FRAMES
    else
        inst._fade:set_local(math.min(inst._fade:value() + 1, FADE_FRAMES * 2 + 1))
        k = (FADE_FRAMES * 2 + 1 - inst._fade:value()) / FADE_FRAMES
    end

    inst.Light:SetIntensity(FADE_INTENSITY * k)
    inst.Light:SetFalloff(1 - (1 - FADE_FALLOFF) * k)

    if TheWorld.ismastersim then
        local state = inst._fade:value() > 0 and inst._fade:value() <= FADE_FRAMES * 2
        inst.Light:Enable(state)
        -- if state then
        --     -- inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
        -- else
        --     -- inst.AnimState:ClearBloomEffectHandle()
        -- end
    end

    if inst._fade:value() == FADE_FRAMES or inst._fade:value() > FADE_FRAMES * 2 then
        if inst._fadetask then
            inst._fadetask:Cancel()
            inst._fadetask = nil
        end
    end
end

local function OnFadeDirty_shell(inst)
    if inst._fadetask == nil then
        inst._fadetask = inst:DoPeriodicTask(FRAMES, OnUpdateFade)
    end
    OnUpdateFade(inst)
end

local function FadeIn(inst, instant)
    if instant then
        inst._fade:set(FADE_FRAMES)
        OnFadeDirty_shell(inst)
    else
        inst._fade:set(
            inst._fade:value() <= FADE_FRAMES and
            inst._fade:value() or
            math.max(0, 2 * FRAMES + 1 - inst._fade:value())
        )
        if inst._fadetask == nil then
            inst._fadetask = inst:DoPeriodicTask(FRAMES, OnUpdateFade)
        end
    end

    if inst._light then
        inst._light:Show()
        SendModRPCToClient(GetClientModRPC("Succulent_RPC", "Chandelier_FadeIn"), nil, inst._light)
    end
    if inst._sparklet then
        inst._sparklet:Show()
        SendModRPCToClient(GetClientModRPC("Succulent_RPC", "Chandelier_FadeIn"), nil, inst._sparklet)
    end

end

local function FadeOut(inst, instant)
    if instant then
        inst._fade:set(FADE_FRAMES * 2 + 1)
        OnFadeDirty_shell(inst)
    else
        inst._fade:set(
            inst._fade:value() > FADE_FRAMES and
            inst._fade:value() or
            2 * FADE_FRAMES + 1 - inst._fade:value()
        )
        if inst._fadetask == nil then
            inst._fadetask = inst:DoPeriodicTask(FRAMES, OnUpdateFade)
        end
    end

    if inst._light then
        SendModRPCToClient(GetClientModRPC("Succulent_RPC", "Chandelier_FadeOut"), nil, inst._light)
    end
    if inst._sparklet then
        SendModRPCToClient(GetClientModRPC("Succulent_RPC", "Chandelier_FadeOut"), nil, inst._sparklet)
    end

end

local function OnIsDay(inst, isday, delayed)
    if inst._daytask ~= nil then
        if not delayed then
            inst._daytask:Cancel()
        end
        inst._daytask = nil
    end

    if not delayed then
        inst._daytask = inst:DoTaskInTime(2 + math.random(), OnIsDay, isday, true)
    elseif isday then
        FadeOut(inst)
    else
        FadeIn(inst)
    end
end

local function OnLoad(inst)
    if inst._daytask ~= nil then
        inst._daytask:cancel()
        inst._daytask = nil
    end

    if TheWorld.state.isday then
        FadeOut(inst, true)
        if inst._light then
            HideForSomeTime(inst._light)
        end
        if inst._sparklet then
            HideForSomeTime(inst._sparklet)
        end
    else
        FadeIn(inst, true)
    end
end

local function onbuilt(inst)
    inst.AnimState:PlayAnimation("place")
    inst.AnimState:PushAnimation("sway_pre", false)
    inst.AnimState:PushAnimation("idle_sway")
    if TheWorld.state.isday then
        if inst._light then
            HideForSomeTime(inst._light)
        end
        if inst._sparklet then
            HideForSomeTime(inst._sparklet)
        end
    end

    local function animover()
        if inst.AnimState:IsCurrentAnimation("sway_pre") then
            if inst._sparklet then
                if not TheWorld.state.isday then
                    inst._sparklet:Show()
                end
            end
            inst:RemoveEventCallback("animover", animover)
        end
    end
    inst:ListenForEvent("animover", animover)
end

local function ondestory(inst)
    local fx = SpawnPrefab("collapse_small")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("pot")
    inst.components.lootdropper:DropLoot()

    -- if inst.components.container ~= nil then
    --     inst.components.container:DropEverything()
    --     inst.components.container:Close()
    -- end

    inst:Remove()
end

local function IsLowPriorityAction(act, force_inspect)
    return act == nil
        or act.action == ACTIONS.WALKTO
        or (act.action == ACTIONS.LOOKAT and not force_inspect)
end

local function CanMouseThrough(inst)
    if ThePlayer ~= nil and ThePlayer.components.playeractionpicker ~= nil then
        local force_inspect = ThePlayer.components.playercontroller ~= nil and ThePlayer.components.playercontroller:IsControlPressed(CONTROL_FORCE_INSPECT)
        local lmb, rmb = ThePlayer.components.playeractionpicker:DoGetMouseActions(inst:GetPosition(), inst)
        return IsLowPriorityAction(rmb, force_inspect) and IsLowPriorityAction(lmb, force_inspect), true
    end
end

local function fall(inst)
    ondestory(inst)
end

local PLACER_SCALE = 0.7 -- min_spacing = 3
local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()
    inst.entity:AddLight()
    inst.entity:AddNetwork()

    inst:AddTag("structure")
    inst:AddTag("lamp")
    inst:AddTag("chandelier")
    inst:AddTag("oceanvine")

    local phys = inst.entity:AddPhysics()
    phys:SetMass(0)
    phys:SetFriction(0)
    phys:SetDamping(5)
    phys:SetCollisionGroup(COLLISION.FLYERS)
    phys:ClearCollisionMask()
    phys:CollidesWith((TheWorld.has_ocean and COLLISION.GROUND) or COLLISION.WORLD)
    phys:CollidesWith(COLLISION.FLYERS)
    phys:SetCapsule(0.75, 1)

    inst.Light:SetFalloff(FADE_FALLOFF)
    inst.Light:SetIntensity(FADE_INTENSITY)
    inst.Light:SetRadius(LIGHTRADIUS)
    inst.Light:SetColour(125/255, 125/255, 150/255)
    inst.Light:Enable(false)
    inst.Light:EnableClientModulation(true)

	inst.AnimState:SetBank("rock_chandelier")
    inst.AnimState:SetBuild("rock_chandelier")
	inst.AnimState:PlayAnimation("idle_sway", true)
    inst.AnimState:SetScale(2,2,2)
    inst.AnimState:SetFinalOffset(0)

    inst._fade = net_smallbyte(inst.GUID, "chandelier_rock._fade", "chandelier_rock_fadedirty")
    inst._fade:set(FADE_FRAMES * 2 + 1)

    MakeHangingObject_client(inst, PLACER_SCALE)

    inst.CanMouseThrough = CanMouseThrough

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        inst:ListenForEvent("chandelier_rock_fadedirty", OnFadeDirty_shell)

        return inst
    end

    inst.AnimState:SetTime(math.random() * inst.AnimState:GetCurrentAnimationLength())

    inst._light = SpawnPrefab("chandelierlight")
    inst._light.entity:AddFollower()
    inst._light.entity:SetParent(inst.entity)
    inst._light.Follower:FollowSymbol(inst.GUID, "body", -10, 88, 0)

    inst._sparklet = SpawnPrefab("chandeliersparkle")
    inst._sparklet.entity:AddFollower()
    inst._sparklet.entity:SetParent(inst.entity)
    inst._sparklet.Follower:FollowSymbol(inst.GUID, "body", 0, 50, 0)
    inst._sparklet:SetVariation(tostring(math.clamp(math.ceil(math.random() * 5), 1, 5)))

    inst:AddComponent("inspectable")
    inst:AddComponent("lootdropper")

    -- inst:AddComponent("container")
    -- inst.components.container:WidgetSetup("chandelier_rock")
    -- inst.components.container.canbeopened = false

    -- inst:AddComponent("preserver")
    -- inst.components.preserver:SetPerishRateMultiplier(0.1)

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(3)
    inst.components.workable:SetOnFinishCallback(ondestory)

    -- inst:AddComponent("chandelier")

    inst:WatchWorldState("isday", OnIsDay)
    inst:ListenForEvent("onbuilt", onbuilt)

    -- inst:ListenForEvent("itemget", itemget)
    -- inst:ListenForEvent("itemlose", itemlose)

    if not TheWorld.state.isday then
        FadeIn(inst)
    end

    inst.OnLoad = OnLoad
    inst.fall = fall

    return inst
end

local function placer_postinit_fn(inst)
    local function sfn(ins)
        ins.AnimState:SetScale(2,2,2)
    end
    return _PlacerPostInit(inst, PLACER_SCALE, "rock_chandelier", "rock_chandelier", "idle_sway", true, sfn)
end

return Prefab("chandelier_rock", fn, assets, prefabs),
    MakePlacer("chandelier_rock_placer","firefighter_placement","firefighter_placement", "idle", true, nil, nil, PLACER_SCALE, nil, nil, placer_postinit_fn)
