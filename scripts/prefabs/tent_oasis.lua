require "prefabutil"

local assets =
{
    Asset("ANIM", "anim/tent_leaves.zip"),
    Asset("IMAGE", "images/inventoryimages/tent_leaves_item.tex"),
    Asset("ATLAS", "images/inventoryimages/tent_leaves_item.xml"),
}

local prefabs =
{
    "collapse_small",
    "tent_plant_fx",
}


local function OnHammered(inst)--, worker)
    if inst.components.burnable ~= nil and inst.components.burnable:IsBurning() then
        inst.components.burnable:Extinguish()
    end

    local fx = SpawnPrefab("collapse_small")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("wood")
    inst:Remove()

    -- inst.kill_fx(inst)

    inst.components.lootdropper:DropLoot()
end

local function OnHit(inst)--, worker)
    if not inst:HasTag("burnt") then
        inst.AnimState:PlayAnimation("hit")
        inst.AnimState:PushAnimation("idle", false)
    end

    if inst.components.sleepingbag ~= nil and inst.components.sleepingbag.sleeper ~= nil then
        inst.components.sleepingbag:DoWakeUp()
    end
end

local function OnSave(inst, data)
    if inst:HasTag("burnt") or (inst.components.burnable ~= nil and inst.components.burnable:IsBurning()) then
        data.burnt = true
    end
end

local function OnLoad(inst, data)
    if data ~= nil and data.burnt then
        inst.components.burnable.onburnt(inst)
    end
end

local function OnBurnt(inst)
    DefaultBurntStructureFn(inst)
    RemovePhysicsColliders(inst)
    inst.kill_fx(inst)
end

-----------------------------------------------------------------------
--For regular tents

local function PlaySleepLoopSoundTask(inst, stopfn)
    inst.SoundEmitter:PlaySound("dontstarve/common/tent_sleep")
end

local function StopSleepSound(inst)
    if inst.sleep_tasks ~= nil then
        for i, v in ipairs(inst.sleep_tasks) do
            v:Cancel()
        end
        inst.sleep_tasks = nil
    end
end

local function StartSleepSound(inst, len)
    StopSleepSound(inst)
    inst.sleep_tasks =
    {
        inst:DoPeriodicTask(len, PlaySleepLoopSoundTask, 33 * FRAMES),
        inst:DoPeriodicTask(len, PlaySleepLoopSoundTask, 47 * FRAMES),
    }
end

-----------------------------------------------------------------------

local function OnIgnite(inst)
    inst.components.sleepingbag:DoWakeUp()
end

local function OnSleep(inst, sleeper)
    sleeper:ListenForEvent("onignite", OnIgnite, inst)

    if inst.sleep_anim ~= nil then
        inst.AnimState:PlayAnimation(inst.sleep_anim, true)
        StartSleepSound(inst, inst.AnimState:GetCurrentAnimationLength())
    end
end

local function OnWake(inst, sleeper, nostatechange)
    sleeper:RemoveEventCallback("onignite", OnIgnite, inst)

    if inst.sleep_anim ~= nil then
        inst.AnimState:PushAnimation("idle", true)
        StopSleepSound(inst)
    end

end

local function TemperatureTick(inst, sleeper)
    if sleeper.components.temperature ~= nil then
        if inst.is_cooling then
            if sleeper.components.temperature:GetCurrent() > TUNING.SLEEP_TARGET_TEMP_TENT then
                sleeper.components.temperature:SetTemperature(sleeper.components.temperature:GetCurrent() - TUNING.SLEEP_TEMP_PER_TICK)
            end
        elseif sleeper.components.temperature:GetCurrent() < TUNING.SLEEP_TARGET_TEMP_TENT then
            sleeper.components.temperature:SetTemperature(sleeper.components.temperature:GetCurrent() + TUNING.SLEEP_TEMP_PER_TICK)
        end
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    -- inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    inst:SetPhysicsRadiusOverride(.5)
    MakeObstaclePhysics(inst, inst.physicsradiusoverride)

    -- inst.MiniMapEntity:SetIcon("tent_leaves.png")

    inst:AddTag("tent")
    inst:AddTag("tent_leaves")
    inst:AddTag("structure")

    inst.AnimState:SetBank("tent_leaves")
    inst.AnimState:SetBuild("tent_leaves")
    inst.AnimState:PlayAnimation("place")
    inst.AnimState:PushAnimation("idle")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

--------------------------------------------------------------------------
    inst.fx = {}

    local function genfx(anim, order)
        local fx = SpawnPrefab("tent_plant_fx")
        fx.entity:SetParent(inst.entity)

        fx.AnimState:PlayAnimation(anim.."_idle")

        if order ~= nil then
            fx.AnimState:SetLayer(LAYER_BACKGROUND)
        end
        table.insert( inst.fx, fx )
    end

    genfx("tent_1_left")
    genfx("tent_1_right")
    genfx("tent_2_left")
    genfx("tent_2_right", 0)

    inst.kill_fx = function()
        for _,fx in ipairs(inst.fx) do
            fx:Remove()
        end
    end
--------------------------------------------------------------------------

    inst:AddComponent("inspectable")

    inst:AddComponent("lootdropper")
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(4)
    inst.components.workable:SetOnFinishCallback(OnHammered)
    inst.components.workable:SetOnWorkCallback(OnHit)

    inst:AddComponent("sleepingbag")
    inst.components.sleepingbag.onsleep = OnSleep
    inst.components.sleepingbag.onwake = OnWake
    inst.components.sleepingbag.health_tick = TUNING.SLEEP_HEALTH_PER_TICK
    --convert wetness delta to drying rate
    inst.components.sleepingbag.dryingrate = math.max(0, -TUNING.SLEEP_WETNESS_PER_TICK / TUNING.SLEEP_TICK_PERIOD)
    inst.components.sleepingbag:SetTemperatureTickFn(TemperatureTick)
    inst.components.sleepingbag.hunger_tick = TUNING.SLEEP_HUNGER_PER_TICK

    inst.sleep_anim = "sleep_loop"

    MakeHauntableWork(inst)

    MakeLargeBurnable(inst, nil, nil, true)
    inst.components.burnable:SetOnBurntFn(OnBurnt)

    MakeMediumPropagator(inst)

    inst.OnSave = OnSave
    inst.OnLoad = OnLoad

    return inst
end

---------------------------------------------------------------
---------------- Inventory Portable Tent  -------------------
---------------------------------------------------------------
local function OnDeploy(inst, pt, deployer)
    local tent = SpawnPrefab("tent_leaves")
    if tent ~= nil then
        tent.Physics:SetCollides(false)
        tent.Physics:Teleport(pt.x, 0, pt.z)
        tent.Physics:SetCollides(true)

        tent.AnimState:PlayAnimation("place")
        tent.AnimState:PushAnimation("idle")
        -- tent.AnimState:PlayAnimation("idle")

        tent.SoundEmitter:PlaySound("dontstarve/characters/walter/tent/open")

        PreventCharacterCollisionsWithPlacedObjects(tent)

        inst:Remove()
    end
end

local function itemfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("tent_leaves")
    inst.AnimState:SetBuild("tent_leaves")
    inst.AnimState:PlayAnimation("idle_item")

    inst:AddTag("usedeploystring")

    MakeInventoryFloatable(inst, nil, 0.05, 0.7)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")
    inst:AddComponent("inventoryitem")

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_LARGEITEM

    inst:AddComponent("deployable")
    inst.components.deployable.ondeploy = OnDeploy

    inst:AddComponent("hauntable")
    inst.components.hauntable:SetHauntValue(TUNING.HAUNT_TINY)

    MakeMediumBurnable(inst)
    MakeSmallPropagator(inst)

    return inst
end

return Prefab("tent_leaves", fn, assets, prefabs),
    MakePlacer("tent_leaves_item_placer", "tent_leaves", "tent_leaves", "idle"),
    Prefab("tent_leaves_item", itemfn, assets, prefabs)