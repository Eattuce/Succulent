

local function SetPortalChannaling(inst)
    if TheWorld.ismastersim then
        local _OnStartChanneling, _OnStopChanneling = inst.components.channelable.onchannelingfn, inst.components.channelable.onstopchannelingfn

        local function OnStartChanneling(portal,channeler)
            local sanity = 0
            if channeler and channeler:HasTag("buff_safeteleport") then
                portal.channeler = channeler.components.sanity ~= nil and channeler or nil
                if portal.channeler ~= nil then
                    sanity = channeler.components.sanity.current
                end
            end

            _OnStartChanneling(portal, channeler)

            if channeler and channeler:HasTag("buff_safeteleport") then
                if portal.channeler ~= nil then
                    portal.channeler.components.sanity:DoDelta(sanity > TUNING.SANITY_MED and TUNING.SANITY_MED or sanity)
                    portal.channeler.components.sanity.externalmodifiers:RemoveModifier(portal)
                end
            end
        end

        local function OnStopChanneling(portal, aborted)
            return _OnStopChanneling(portal, aborted)
        end

        inst.components.channelable:SetChannelingFn(OnStartChanneling, OnStopChanneling)

        local function OnStartTeleporting(arg, doer)
            if doer:HasTag("player") then
                if doer.components.talker ~= nil then
                    doer.components.talker:ShutUp()
                end
                if doer:HasTag("buff_safeteleport") then
                    return
                end
                if doer.components.sanity ~= nil then
                    doer.components.sanity:DoDelta(-TUNING.SANITY_HUGE)
                end
            end
        end
        inst.components.teleporter.onActivate = OnStartTeleporting
    end
end









AddPrefabPostInit("townportal",function (inst)

    if not TheWorld.ismastersim then
        return inst
    end

    local _OnStartChanneling,_OnStopChanneling = inst.components.channelable.onchannelingfn, inst.components.channelable.onstopchannelingfn
    inst.components.channelable.onchannelingfn = function (inst, channeler)
        if channeler and channeler:HasTag("buff_safeteleport") then
            channeler = {components = {sanity = nil}}
        end
        return _OnStartChanneling(inst, channeler)
    end

    local _OnStartTeleporting = inst.components.teleporter.onActivate
    inst.components.teleporter.onActivate = function (inst, doer)
        if doer:HasTag("player") and doer:HasTag("buff_safeteleport") then
            if doer.components.talker ~= nil then
                doer.components.talker:ShutUp()
                return
            end
        end
        return _OnStartTeleporting(inst, doer)
    end
end)








local function killtask(inst)
    if inst.tpstonedamagetask ~= nil then
        inst.tpstonedamagetask:Cancel()
        inst.tpstonedamagetask = nil
    end
end

local NO_HARM_TAGS =
{
    "player",
	"companion",
    "no_townportaltalisman_damage",
}

local function immune(inst)
    for _,tag in pairs(NO_HARM_TAGS) do
        if inst:HasTag(tag) then
            return true
        end
    end
end

local function HarmOwner(inst)
    local owner = inst.components.inventoryitem:GetGrandOwner()
    if owner and owner.components.health ~= nil then
        if immune(owner) then
            killtask(inst)
        else
            local amt = inst.components.stackable:StackSize()
            owner.components.health:DoDelta(-50*amt, nil, inst.prefab)
            inst.tpstonedamagetask = inst:DoTaskInTime(1, HarmOwner)
        end
    end
end

local function OnLinkTownPortals(inst, other)
    if other ~= nil then
        inst.tpstonedamagetask = inst:DoTaskInTime(1, HarmOwner)
    else
        killtask(inst)
    end
end

AddPrefabPostInit("townportaltalisman", function (inst)
    if not TheWorld.ismastersim then
        return inst
    end

    local _OnStartTeleporting = inst.components.teleporter.onActivate
    inst.components.teleporter.onActivate = function (inst, doer)
        if doer:HasTag("player") and doer:HasTag("buff_safeteleport") then
            if doer.components.talker ~= nil then
                doer.components.talker:ShutUp()
                return
            end
        end
        return _OnStartTeleporting(inst, doer)
    end

    -- 伤害
    inst:ListenForEvent("linktownportals", OnLinkTownPortals)

end)

