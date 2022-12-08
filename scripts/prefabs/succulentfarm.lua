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
    {   amount = 6, grow = "plant_4",   idle = "plant_4_idle",  hit = "hit_plant_4" },
    {   amount = 4, grow = "plant_3",   idle = "plant_3_idle",  hit = "hit_plant_3" },
    {   amount = 2, grow = "plant_2",   idle = "plant_2_idle",  hit = "hit_plant_2" },
    {   amount = 1, grow = "plant_1",   idle = "plant_1_idle",  hit = "hit_plant_1" },
    {   amount = 0,                     idle = "idle",          hit = "hit_idle"    },
}

local function StartGrowing(inst, giver, product)
    if inst.components.harvestable ~= nil then

        inst.components.harvestable:SetProduct("succulent_picked", 6)
        inst.components.harvestable:SetGrowTime(TUNING.TOTAL_DAY_TIME - TUNING.SEG_TIME + math.random() * TUNING.SEG_TIME) -- every stage
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

        inst:PushEvent("levelchange", level)

    end
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
    local skin_build = inst:GetSkinBuild()
    local material = skin_build ~= nil and "pot" or "wood"
    fx:SetMaterial(material)
    inst:Remove()
end

local function onhit(inst, worker)
    if not inst:HasTag("burnt") then
        inst.AnimState:PlayAnimation(inst.anims.hit)
        inst.AnimState:PushAnimation(inst.anims.idle, false)
    end
end

local function onbuilt(inst)
    inst.AnimState:PushAnimation("idle", false)
    inst.SoundEmitter:PlaySound("dontstarve/common/together/mushroomfarm/craft")
end

local function getstatus(inst)
    if inst.components.harvestable == nil then
        return nil
    end

    return  inst.components.harvestable.produce == levels[1].amount and "STUFFED"
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
    elseif item.prefab == "succulent_picked" then
        return true
    end
    return false, "MUSTBESUCCULENT"
end

local function onacceptitem(inst, giver, item)
    if item and item.prefab == "succulent_picked" then
        StartGrowing(inst, giver, item)
    end
end

local function onsave(inst, data)
    if inst:HasTag("burnt") or (inst.components.burnable ~= nil and inst.components.burnable:IsBurning()) then
        data.burnt = true
    elseif inst.components.harvestable ~= nil then
        data.growtime = inst.components.harvestable.growtime
        data.product = inst.components.harvestable.product
        data.maxproduce = inst.components.harvestable.maxproduce
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

            updatelevel(inst)
        end
    end
end

local function OnSeasonChange(inst, season)
    if season == SEASONS.WINTER then
        inst.components.harvestable:StopGrowing()
        -- print(1)
    elseif inst.components.harvestable.produce >= 4 and season ~= SEASONS.SUMMER then
        inst.components.harvestable:StopGrowing()
        -- print(2)
    else
        inst.components.harvestable:StartGrowing()
        -- print(3)
    end
end

local function levelchange(inst, level)
    if level.amount >= 4 and not TheWorld.state.issummer then
        inst:DoTaskInTime(math.random(),function () inst.components.harvestable:StopGrowing() end) -- wait one frame or a little bit more
    end
end

local function OnBasicSkin(inst)
    if not inst.components.burnable then
        MakeSmallBurnable(inst, nil, nil, true)
        MakeSmallPropagator(inst)
        inst.components.burnable:SetOnBurntFn(onburnt)
        inst.components.burnable:SetOnIgniteFn(onignite)
        inst.components.burnable:SetOnExtinguishFn(onextinguish)
    end

    if inst.components.workable then
        inst.components.workable:SetWorkLeft(4)
    end
    updatelevel(inst)
    -- SendModRPCToClient(GetClientModRPC("Succulent_RPC", "SetFloater_Scale"), nil, {0.9, 0.8, 0.9})
end

local function OnWaterSkin(inst)
    if inst.components.burnable then
        if inst.components.burnable:IsBurning() then
            inst.components.burnable:Extinguish()
        end
        if inst.components.burnable:IsSmoldering() then
            inst.components.burnable:SmotherSmolder()
        end

        inst:RemoveComponent("burnable")
        inst:RemoveComponent("propagator")
    end

    if inst.components.workable then
        inst.components.workable:SetWorkLeft(1)
    end
    updatelevel(inst)
    -- SendModRPCToClient(GetClientModRPC("Succulent_RPC", "SetFloater_Scale"), nil, {1.4, 0.9, 1.4})
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()
    inst.entity:AddLightWatcher()

    MakeObstaclePhysics(inst, .3)
    MakeWaterObstaclePhysics(inst, 0.3, 2, 0.75)
    MakeInventoryPhysics(inst, nil, 1)
    MakeInventoryFloatable(inst, "med", 0, {1.1, 0.9, 1.1})

    inst.MiniMapEntity:SetIcon("mini.tex")

    inst.AnimState:SetBank("succulent_farm")
    inst.AnimState:SetBuild("succulent_farm")
    inst.AnimState:PlayAnimation("idle")

    local land_time = (POPULATING and math.random()*5*FRAMES) or 0
    inst:DoTaskInTime(land_time, function(inst)
        inst.components.floater:OnLandedServer()
    end)

    inst:AddTag("structure")
    inst:AddTag("playerowned")
    inst:AddTag("trader")
    inst:AddTag("succulent_farm")
    -- inst:AddTag("silviculture")

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
    inst.components.workable:SetWorkLeft(4)
    inst.components.workable:SetOnFinishCallback(onhammered)
    inst.components.workable:SetOnWorkCallback(onhit)

    inst:WatchWorldState("season", OnSeasonChange)
    inst:ListenForEvent("levelchange", levelchange)

    MakeHauntableWork(inst)

    MakeSnowCovered(inst)
    inst:ListenForEvent("onbuilt", onbuilt)

    MakeSmallBurnable(inst, nil, nil, true)
    MakeSmallPropagator(inst)
    inst.components.burnable:SetOnBurntFn(onburnt)
    inst.components.burnable:SetOnIgniteFn(onignite)
    inst.components.burnable:SetOnExtinguishFn(onextinguish)

    inst.OnSave = onsave
    inst.OnLoad = onload

    inst.SetBasic = OnBasicSkin
    inst.SetSkin = OnWaterSkin

    updatelevel(inst)

    return inst
end

return Prefab("succulent_farm", fn, assets, prefabs),
    MakePlacer("succulent_farm_placer", "succulent_farm", "succulent_farm", "idle", nil, nil, nil, nil, nil, nil,
    function (inst)
        inst.AnimState:Hide("snow")
    end)
