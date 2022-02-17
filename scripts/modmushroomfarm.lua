table.insert(Assets, Asset("ANIM", "anim/mushroom_farm_succulent_picked_build.zip"))

local IsServer = TheNet:GetIsServer() or TheNet:IsDedicated()

if IsServer then
    local newplants =
    {
        succulent_picked = { product = "succulent_picked", produce = 4, produce_summ = 6},
    }

    AddPrefabPostInit("mushroom_farm", function(inst)
        local AbleToAcceptTest_old = inst.components.trader.abletoaccepttest
        inst.components.trader:SetAbleToAcceptTest(function(farm, item, ...)
            if item ~= nil then
                if farm.remainingharvests == 0 then
                    if item.prefab == "livlinglog" then
                        return true
                    end
                elseif newplants[item.prefab] ~= nil then
                    return true
                end
            end
            return AbleToAcceptTest_old(farm, item, ...)
        end)

        local OnAccept_old = inst.components.trader.onaccept
        inst.components.trader.onaccept = function(farm, giver, item, ...)
            if farm.remainingharvests ~= 0 and newplants[item.prefab] ~= nil then
                if farm.components.harvestable ~= nil then
                    local data = newplants[item.prefab]
                    farm.AnimState:OverrideSymbol("swap_mushroom", "mushroom_farm_"..data.product.."_build", "swap_mushroom")
                    if TheWorld.state.issummer then
                        farm.components.harvestable:SetProduct(data.product, data.produce_summ)
                        farm.components.harvestable:SetGrowTime(TUNING.MUSHROOMFARM_FULL_GROW_TIME / data.produce_summ)
                    else
                        farm.components.harvestable:SetProduct(data.product, data.produce)
                        farm.components.harvestable:SetGrowTime(TUNING.MUSHROOMFARM_FULL_GROW_TIME / data.produce)
                    end
                    farm.components.harvestable:Grow()

                    TheWorld:PushEvent("itemplanted", { doer = giver, pos = farm:GetPosition() }) --this event is pushed in other places too
                end
            else
                OnAccept_old(farm, giver, item, ...)
            end
        end

        local OnLoad_old = inst.OnLoad
        inst.OnLoad = function(farm, data)
            OnLoad_old(farm, data)
            if data ~= nil and not data.burnt and data.product ~= nil then
                for k,v in pairs(newplants) do
                    if v.product == data.product then
                        farm.AnimState:OverrideSymbol("swap_mushroom", "mushroom_farm_"..data.product.."_build", "swap_mushroom")
                        break
                    end
                end
            end
        end

    end)
end
