
local prefabs =
{
    "totem_real",
}

local function OnTimerDone(inst, data)
    if data.name == "spawndelay" then
        inst:RemoveEventCallback("timerdone", OnTimerDone)
        local totem = SpawnPrefab("totem_real")
        inst.components.entitytracker:TrackEntity("totem_real", totem)
        inst:ListenForEvent("disappear", inst._ontotem_disappear, totem)

        totem.Transform:SetPosition(inst.Transform:GetWorldPosition())
        totem:PushEvent("appear", totem)
        totem:PushEvent("gradualfade_in")
        SendModRPCToClient(GetClientModRPC("Succulent_RPC", "Chandelier_FadeIn"), nil, totem)
    end
end

local function OnSandstormChanged(inst, active)
    if active then
        -- if not (inst.spawned or inst.extinguished) then
            inst.spawned = true
            inst.components.timer:StopTimer("spawndelay")
            if inst.components.entitytracker:GetEntity("totem_real") == nil then
                inst:ListenForEvent("timerdone", OnTimerDone)
                local delay = GetRandomMinMax(5,10)
                inst.components.timer:StartTimer("spawndelay", delay)
            end
        -- end
    elseif inst.spawned then
        inst.spawned = nil
        -- inst.extinguished = nil
        inst:RemoveEventCallback("timerdone", OnTimerDone)
        inst.components.timer:StopTimer("spawndelay")
    end
end

local function OnStopSummer(inst)
    -- print("stopsummer")
    inst.extinguished = nil
    -- OnSandstormChanged(inst, TheWorld.components.sandstorms ~= nil and TheWorld.components.sandstorms:IsSandstormActive())
    -- inst.spawned = nil
end

local function OnInit(inst)
    inst:WatchWorldState("stopsummer", OnStopSummer)
    inst:ListenForEvent("ms_stormchanged", function(src, data)
            if data.stormtype == STORM_TYPES.SANDSTORM then
                OnSandstormChanged(inst, data.setting)
            end
        end, TheWorld)

    if not TheWorld.state.issummer then
        OnStopSummer(inst)
    end

    OnSandstormChanged(inst, TheWorld.components.sandstorms ~= nil and TheWorld.components.sandstorms:IsSandstormActive())
end

local function OnSave(inst, data)
    data.spawned = inst.spawned or nil
    data.extinguished = inst.extinguished or nil
end

local function OnLoad(inst, data)
    inst.extinguished = data ~= nil and data.extinguished or nil

    if data ~= nil and data.spawned then
        if not inst.spawned then
            inst.spawned = true
            if inst.components.timer:TimerExists("spawndelay") then
                inst:ListenForEvent("timerdone", OnTimerDone)
            end
        end
    else
        if inst.spawned then
            inst.spawned = nil
            inst:RemoveEventCallback("timerdone", OnTimerDone)
        end
        inst.components.timer:StopTimer("spawndelay")
    end
end

local function OnLoadPostPass(inst)--, ents, data)
    local totem = inst.components.entitytracker:GetEntity("totem_real")
    if totem ~= nil then
        inst:ListenForEvent("disappear", inst._ontotem_disappear, totem)
    end
end

local function RegisterToBottleManager(inst)
    if TheWorld.components.messagebottlemanager ~= nil then
        TheWorld.components.messagebottlemanager.totem = inst
    end
end

local function RegisterPlayer(inst, player)
    if TheWorld.components.messagebottlemanager ~= nil then
        TheWorld.components.messagebottlemanager:SetPlayerHasFoundTotem(player)
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    --[[Non-networked entity]]

    inst:AddTag("CLASSIFIED")

    inst:AddComponent("timer")
    inst:AddComponent("entitytracker")

    --------------------
    -- inst:AddComponent("playerprox")
    -- inst.components.playerprox:SetDist(5,10)
    -- inst.components.playerprox:SetOnPlayerNear(RegisterPlayer)
    -- -- inst.components.playerprox:SetOnPlayerFar(fn)


    inst:DoTaskInTime(0, OnInit)

    inst.OnSave = OnSave
    inst.OnLoad = OnLoad
    inst.OnLoadPostPass = OnLoadPostPass

    inst._ontotem_disappear = function(totem)
        if inst.components.entitytracker:GetEntity("totem_real") == totem then
            inst.extinguished = true
            inst.components.entitytracker:ForgetEntity("totem_real")
        end
    end

    -- RegisterToBottleManager(inst)
    return inst
end

return Prefab("totem_spawner", fn, nil, prefabs)
