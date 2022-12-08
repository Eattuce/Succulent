GLOBAL.setmetatable(env, { __index = function(t, k) return GLOBAL.rawget(GLOBAL, k) end })
local TIMEOUT = 2

local formsucculent_master = State{
    name = "formsucculent",
    tags = { "doing", "busy", "canrotate" },

    onenter = function(inst)
        if inst.components.playercontroller ~= nil then
            inst.components.playercontroller:Enable(false)
        end
        inst.AnimState:PlayAnimation("cointoss_pre")
        inst.AnimState:PushAnimation("cointoss", false)
        inst.components.locomotor:Stop()

        -- local coin = inst.bufferedaction ~= nil and inst.bufferedaction.invobject
        -- inst.sg.statemem.fxcolour = coin ~= nil and coin.fxcolour or { 1, 1, 1 }
        -- inst.sg.statemem.castsound = coin ~= nil and coin.castsound
        inst.sg.statemem.fxcolour = { 1, 1, 1 }
        inst.sg.statemem.castsound = "dontstarve/wilson/use_gemstaff"
    end,

    timeline =
    {
        TimeEvent(7 * FRAMES, function(inst)
            inst.sg.statemem.stafffx = SpawnPrefab((inst.components.rider ~= nil and inst.components.rider:IsRiding()) and "cointosscastfx_mount" or "cointosscastfx")
            inst.sg.statemem.stafffx.entity:SetParent(inst.entity)
            inst.sg.statemem.stafffx:SetUp(inst.sg.statemem.fxcolour)
        end),
        TimeEvent(15 * FRAMES, function(inst)
            inst.sg.statemem.stafflight = SpawnPrefab("staff_castinglight")
            inst.sg.statemem.stafflight.Transform:SetPosition(inst.Transform:GetWorldPosition())
            inst.sg.statemem.stafflight:SetUp(inst.sg.statemem.fxcolour, 1.2, .33)
        end),
        TimeEvent(13 * FRAMES, function(inst)
            if inst.sg.statemem.castsound then
                inst.SoundEmitter:PlaySound(inst.sg.statemem.castsound)
            end
        end),
        TimeEvent(53 * FRAMES, function(inst)
            inst.sg.statemem.stafffx = nil --Can't be cancelled anymore
            inst.sg.statemem.stafflight = nil --Can't be cancelled anymore
            inst:PerformBufferedAction()
        end),
    },

    events =
    {
        EventHandler("animqueueover", function(inst)
            if inst.AnimState:AnimDone() then
                inst.sg:GoToState("idle")
            end
        end),
    },

    onexit = function(inst)
        if inst.components.playercontroller ~= nil then
            inst.components.playercontroller:Enable(true)
        end
        if inst.sg.statemem.stafffx ~= nil and inst.sg.statemem.stafffx:IsValid() then
            inst.sg.statemem.stafffx:Remove()
        end
        if inst.sg.statemem.stafflight ~= nil and inst.sg.statemem.stafflight:IsValid() then
            inst.sg.statemem.stafflight:Remove()
        end
    end,
}

local formsucculent_client = State{
    name = "formsucculent",
    tags = { "doing", "busy", "canrotate" },

    onenter = function(inst)
        inst.components.locomotor:Stop()
        inst.AnimState:PlayAnimation("cointoss_pre")
        inst.AnimState:PushAnimation("cointoss_lag", false)

        inst:PerformPreviewBufferedAction()
        inst.sg:SetTimeout(TIMEOUT)
    end,

    onupdate = function(inst)
        if inst:HasTag("doing") then
            if inst.entity:FlattenMovementPrediction() then
                inst.sg:GoToState("idle", "noanim")
            end
        elseif inst.bufferedaction == nil then
            inst.sg:GoToState("idle")
        end
    end,

    ontimeout = function(inst)
        inst:ClearBufferedAction()
        inst.sg:GoToState("idle")
    end,
}

AddStategraphState("wilson", formsucculent_master)
AddStategraphState("wilson_client", formsucculent_client)






local burntbacktolife_master = State{
    name = "burntbacktolife",
    tags = { "doing", "busy", "nodangle" },

    onenter = function(inst)
        inst.components.locomotor:Stop()
        inst.AnimState:PlayAnimation("channel_pre")
        inst.AnimState:PushAnimation("channel_loop", true)
        inst.sg.statemem.action = inst.bufferedaction
        inst.sg:SetTimeout(3)
    end,

    timeline =
    {
        TimeEvent(7 * FRAMES, function(inst)
            inst.sg:RemoveStateTag("busy")
        end),
        -- TimeEvent(.7, function(inst)
        --     if inst.bufferedaction ~= nil and
        --         inst.components.talker ~= nil and
        --         inst.bufferedaction.target ~= nil and
        --         inst.bufferedaction.target:HasTag("moonportal") then
        --         inst.components.talker:Say(GetString(inst, "ANNOUNCE_DESPAWN"))
        --     end
        -- end),
    },


    ontimeout = function(inst)
        inst:PerformBufferedAction()
        -- if not inst:PerformBufferedAction() then
            inst.AnimState:PlayAnimation("channel_pst")
            inst.sg:GoToState("idle", true)
        -- end
    end,

    onexit = function(inst)
        if inst.bufferedaction == inst.sg.statemem.action and
        (inst.components.playercontroller == nil or inst.components.playercontroller.lastheldaction ~= inst.bufferedaction) then
            inst:ClearBufferedAction()
        end
    end,
}


local burntbacktolife_client = State{
    name = "burntbacktolife",
    tags = { "doing", "busy" },

    onenter = function(inst)
        inst.components.locomotor:Stop()
        inst.AnimState:PlayAnimation("channel_pre")
        inst.AnimState:PushAnimation("channel_loop", true)

        inst:PerformPreviewBufferedAction()
        inst.sg:SetTimeout(TIMEOUT)
    end,

    timeline =
    {
        TimeEvent(7 * FRAMES, function(inst)
            inst.sg:RemoveStateTag("busy")
        end),
    },

    onupdate = function(inst)
        if inst:HasTag("doing") then
            if inst.entity:FlattenMovementPrediction() then
                inst.sg:GoToState("idle", "noanim")
            end
        elseif inst.bufferedaction == nil then
            inst.AnimState:PlayAnimation("channel_pst")
            inst.sg:GoToState("idle", true)
        end
    end,

    ontimeout = function(inst)
        inst:ClearBufferedAction()
        inst.AnimState:PlayAnimation("channel_pst")
        inst.sg:GoToState("idle", true)
    end,
}
AddStategraphState("wilson", burntbacktolife_master)
AddStategraphState("wilson_client", burntbacktolife_client)
