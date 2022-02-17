require "prefabutil"

local assets =
{
    Asset("ANIM", "anim/succulent_farm.zip")
}

local prefabs =
{
    "succulent_picked",
    "collapse_small"
}

local levels =
{
    { amount=6, grow="plant_4", idle="plant_4_idle", hit="hit_plant_4" },
    { amount=4, grow="plant_3", idle="plant_3_idle", hit="hit_plant_3" },
    { amount=2, grow="plant_2", idle="plant_2_idle", hit="hit_plant_2" },
    { amount=1, grow="plant_1", idle="plant_1_idle", hit="hit_plant_1" },
    { amount=0, idle="idle", hit="hit_idle" },
}

local FULLY_REPAIRED_WORKLEFT = 3

local percent = 0.25

local function StartGrowing(inst, giver, product)
    if inst.components.harvestable ~= nil then
        local max_produce = levels[2].amount
        if TheWorld.state.issummer then
            max_produce = levels[1].amount
        elseif TheWorld.state.iswinter then
            max_produce  = levels[3].amount
        end
        local productname = product.prefab
        local totaltime = TUNING.MUSHROOMFARM_FULL_GROW_TIME / (max_produce * percent * inst.remainingharvests)

        inst.components.harvestable:SetProduct(productname, max_produce)
        inst.components.harvestable:SetGrowTime(5 * totaltime / max_produce)

        inst.components.harvestable:Grow()

        TheWorld:PushEvent("itemplanted", { doer = giver, pos = inst:GetPosition() })
    end
end

local function setlevel(inst, level, dotransition)
    if not inst:HasTag("burnt") then
        if inst.anims == nil then
            inst.anims = {}
        end
        if inst.anims.idle == level.idle then
            dotransition = false
        end

        inst.anims.idle = level.idle
        inst.anims.hit = level.hit

        if inst.components.harvestable:CanBeHarvested() then
            inst.components.trader:Disable()
        else
            inst.components.trader:Enable()
            inst.components.harvestable:SetGrowTime(nil)
        end

        if dotransition then
            inst.AnimState:PlayAnimation(level.grow)
            inst.AnimState:PushAnimation(inst.anims.idle, false)
            inst.SoundEmitter:PlaySound("dontstarve/common/together/mushroomfarm/grow") -- "dontstarve/common/together/mushroomfarm/spore_grow")
        else
            inst.AnimState:PlayAnimation(inst.anims.idle)
        end
    end
    -- snow(inst)
end

local function updatelevel(inst, dotransition)
    if not inst:HasTag("burnt") then
        for k, v in pairs(levels) do
            if inst.components.harvestable.produce >= v.amount then
                setlevel(inst, v, dotransition)
                break
            end
        end
    end
end

local function onharvest(inst, picker)
    if not inst:HasTag("burnt") then
        if inst.remainingharvests > 1 then
            inst.remainingharvests = inst.remainingharvests - 1
        end
        updatelevel(inst)
    end
end

local function ongrow(inst, produce)
    updatelevel(inst, true)
end


local function onhammered(inst, worker)
    if inst.components.burnable ~= nil and inst.components.burnable:IsBurning() then
        inst.components.burnable:Extinguish()
    end

    inst.components.lootdropper:DropLoot()

    local fx = SpawnPrefab("collapse_small")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("wood")
    inst:Remove()
end

local function onhit(inst, worker)
    if not inst:HasTag("burnt") then
        inst.AnimState:PlayAnimation(inst.anims.hit)
        inst.AnimState:PushAnimation(inst.anims.idle, false)
    end
end

local function onbuilt(inst)
    inst.AnimState:PlayAnimation("place")
    inst.AnimState:PushAnimation("idle", false)
    inst.SoundEmitter:PlaySound("dontstarve/common/together/mushroomfarm/craft")
end

local function getstatus(inst)
    if inst.components.harvestable == nil then
        return nil
    end

    return --[[TheWorld.state.issnowcovered and "SNOWCOVERED"
            or]] inst.components.harvestable.produce == levels[1].amount and "STUFFED"
            or inst.components.harvestable.produce == levels[2].amount and "LOTS"
            or inst.components.harvestable:CanBeHarvested() and "SOME"
            or "EMPTY"
end

local function lootsetfn(lootdropper)
    local inst = lootdropper.inst

    if inst:HasTag("burnt") or (inst.components.burnable ~= nil and inst.components.burnable:IsBurning()) or (not inst.components.harvestable:CanBeHarvested()) then
        return
    end

    local loot = {}
    for i= 1,inst.components.harvestable.produce do
        table.insert(loot, inst.components.harvestable.product)
    end
    lootdropper:SetLoot(loot)
end

local function onburnt(inst)
    DefaultBurntStructureFn(inst)
    if inst.components.trader ~= nil then
        inst:RemoveComponent("trader")
    end
    if TheWorld.state.issnowcovered then
        inst.AnimState:Show("snow")
    else
        inst.AnimState:Hide("snow")
    end
end

local function onignite(inst)
    DefaultBurnFn(inst)
    if inst.components.harvestable ~= nil then
        if inst.components.harvestable:CanBeHarvested() then
            for i= 1,inst.components.harvestable.produce do
                inst.components.lootdropper:SpawnLootPrefab("ash")
            end
        end

        inst.components.harvestable.produce = 0
        inst.components.harvestable:StopGrowing()
        updatelevel(inst)
    end

    if inst.components.trader ~= nil then
        inst.components.trader:Disable()
    end
end

local function onextinguish(inst)
    DefaultExtinguishFn(inst)
    updatelevel(inst)
end

local function accepttest(inst, item, giver)
    if item == nil then
        return false
    elseif item.components and item.components.fertilizer ~= nil then
        if inst.remainingharvests < TUNING.MUSHROOMFARM_MAX_HARVESTS then
            return true
        end
        -- giver.components.talker:ShutUp()
        -- giver:DoTaskInTime(0, function () giver.components.talker:Say(GetString(giver, "NO_NEED_TO_FERTILIZE")) end)
        return false, "NONEEDFERTILIZE"
    elseif item.prefab == "succulent_picked" then
        return true
    end
    -- giver.components.talker:ShutUp()
    -- giver:DoTaskInTime(0,function () giver.components.talker:Say(GetString(giver, "MUST_BE_SUCCULENT")) end)
    return false, "MUSTBESUCCULENT"
end

local function onacceptitem(inst, giver, item)
    if item ~= nil then
        if item.components and item.components.fertilizer ~= nil then
            inst.remainingharvests = TUNING.MUSHROOMFARM_MAX_HARVESTS
            inst.SoundEmitter:PlaySound("dontstarve/common/together/mushroomfarm/grow")
            updatelevel(inst)
        else
            StartGrowing(inst, giver, item)
        end
    end
end

local function onsave(inst, data)
    if inst:HasTag("burnt") or (inst.components.burnable ~= nil and inst.components.burnable:IsBurning()) then
        data.burnt = true
    elseif inst.components.harvestable ~= nil then
        data.growtime = inst.components.harvestable.growtime
        data.product = inst.components.harvestable.product
        data.maxproduce = inst.components.harvestable.maxproduce
        data.remainingharvests = inst.remainingharvests
    end
end


local function onload(inst, data)
    if data ~= nil then
        if data.burnt then
            inst.components.burnable.onburnt(inst)
        else
            inst.components.harvestable.growtime = data.growtime
            inst.components.harvestable.product = data.product
            inst.components.harvestable.maxproduce = data.maxproduce

            inst.remainingharvests = data.remainingharvests or 1

            updatelevel(inst)
        end
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()
    inst.entity:AddLightWatcher()

    MakeObstaclePhysics(inst, .25)

    inst.MiniMapEntity:SetIcon("mini.tex")

    inst.AnimState:SetBank("succulent_farm")
    inst.AnimState:SetBuild("succulent_farm")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("structure")
    inst:AddTag("playerowned")

    --trader, alltrader (from trader component) added to pristine state for optimization
    inst:AddTag("trader")
    inst:AddTag("alltrader")
    inst:AddTag("mushroom_farm")
    inst:AddTag("succulent_farm")

    MakeSnowCoveredPristine(inst)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    ---------------------
    inst:AddComponent("harvestable")
    inst.components.harvestable:SetOnGrowFn(ongrow)
    inst.components.harvestable:SetOnHarvestFn(onharvest)
    -------------------

    inst:AddComponent("trader")
    inst.components.trader:SetAbleToAcceptTest(accepttest)
    inst.components.trader.onaccept = onacceptitem
    inst.components.trader.acceptnontradable = true

    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = getstatus

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetLootSetupFn(lootsetfn)

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(FULLY_REPAIRED_WORKLEFT)
    inst.components.workable:SetOnFinishCallback(onhammered)
    inst.components.workable:SetOnWorkCallback(onhit)

    -- inst:AddComponent("grower")
    -- inst.components.grower.setfertility = setfertilityfn


    inst:WatchWorldState("snowcoveredchanged", MakeSnowCovered)

    MakeHauntableWork(inst)

    -- MakeSnowCovered(inst)
    inst:ListenForEvent("onbuilt", onbuilt)

    MakeMediumBurnable(inst, nil, nil, true)
    MakeSmallPropagator(inst)
    inst.components.burnable:SetOnBurntFn(onburnt)
    inst.components.burnable:SetOnIgniteFn(onignite)
    inst.components.burnable:SetOnExtinguishFn(onextinguish)

    inst.remainingharvests = TUNING.MUSHROOMFARM_MAX_HARVESTS

    inst.OnSave = onsave
    inst.OnLoad = onload

    updatelevel(inst)

    return inst
end

return Prefab("succulent_farm", fn, assets, prefabs),
    MakePlacer("succulent_farm_placer", "succulent_farm", "succulent_farm", "idle", nil, nil, nil, nil, nil, nil,
    function (inst)
        inst.AnimState:Hide("snow")
    end)
