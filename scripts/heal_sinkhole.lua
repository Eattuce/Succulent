local IsServer = TheNet:GetIsServer() or TheNet:IsDedicated()

local function accepttest(inst, item, giver)
    if item == nil then
        return false
    elseif item.prefab == "rock_cream" then
        return true
    else
        if giver and giver.components.talker ~= nil then
            giver.components.talker:ShutUp()
            giver:DoTaskInTime(0,function ()
                giver.components.talker:Say(GetString(giver, "FAIL_TO_HEAL_LAND"))
            end)
        end
        return false
    end
end

local function onacceptitem(inst, giver, item)
    local fx = SpawnPrefab("collapse_big")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("rock")
        inst:Remove()
    -- local state = inst.remainingrepairs or 3
    -- if inst.AnimState:IsCurrentAnimation("cracks_pre1") then
    --     inst:Remove()
    -- else
    --     inst.remainingrepairs = state - 1
    --     inst.AnimState:OverrideSymbol("cracks1", "antlion_sinkhole", "cracks_pre"..tostring(state))
    -- end
end

if IsServer then
    AddPrefabPostInit("antlion_sinkhole", function( inst )
        inst:RemoveTag("NOCLICK")

        inst:AddComponent("trader")
        inst.components.trader:SetAbleToAcceptTest(accepttest)
        inst.components.trader.onaccept = onacceptitem
        -- inst.components.trader.acceptnontradable = true
        -- local onsave_old = inst.
    end)
end