

local function SetPortalChannaling(inst)
    if TheWorld.ismastersim then
        local old_onchannelingfn, old_onstopchannelingfn = inst.components.channelable.onchannelingfn, inst.components.channelable.onstopchannelingfn

        local function OnStartChanneling(portal,channeler)
            local sanity = 0
            if channeler and channeler:HasTag("buff_safeteleport") then
                portal.channeler = channeler.components.sanity ~= nil and channeler or nil
                if portal.channeler ~= nil then
                    sanity = channeler.components.sanity.current
                end
            end

            old_onchannelingfn(portal, channeler)

            if channeler and channeler:HasTag("buff_safeteleport") then
                if portal.channeler ~= nil then
                    portal.channeler.components.sanity:DoDelta(sanity > TUNING.SANITY_MED and TUNING.SANITY_MED or sanity)
                    portal.channeler.components.sanity.externalmodifiers:RemoveModifier(portal)
                end
            end
        end

        local function OnStopChanneling(portal, aborted)
            return old_onstopchannelingfn(portal, aborted)
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

AddPrefabPostInit("townportal",SetPortalChannaling)
