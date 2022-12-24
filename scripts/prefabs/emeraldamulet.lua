local assets =
{
    Asset("ANIM", "anim/emeraldamulet.zip"),
    Asset("ANIM", "anim/torso_emeraldamulet.zip"),
    Asset("ATLAS", "images/inventoryimages/emeraldamulet.xml"),
    Asset("IMAGE", "images/inventoryimages/emeraldamulet.tex"),
}

local prefabs =
{
    "succulent_plant_fx",
}


local PLANT_TAGS = {"tendable_farmplant"}
local function TendToPlantsAOE(inst, owner)
    if (owner.components.health and owner.components.health:GetPercent() >= 0.6 ) then
        local x, y, z = owner.Transform:GetWorldPosition()
        for _, v in pairs(TheSim:FindEntities(x, y, z, TUNING.WORMWOOD_BLOOM_FARM_PLANT_INTERACT_RANGE, PLANT_TAGS)) do
            if v.components.farmplanttendable ~= nil then
                v.components.farmplanttendable:TendTo(owner)
                -- inst.components.finiteuses:Use(1)
            end
        end
    end
end

local function healowner(inst, owner)
    if (owner.components.health and owner.components.health:GetPercent() <= 0.6 ) then
        owner.components.health:DoDelta(TUNING.REDAMULET_CONVERSION, false, "emeraldamulet")
        inst.components.finiteuses:Use(2)
    end
end

local function spawnplants(inst, owner)
    local PLANTS_RANGE = 1.5
    local MAX_PLANTS = 15

    local PLANTFX_TAGS = { "succulent_plant_fx" }

    if owner.components.health:IsDead() or not owner.entity:IsVisible() then
        return
    end

    local x, y, z = owner.Transform:GetWorldPosition()
    if TheWorld.Map:GetPlatformAtPoint(x, z) ~= nil then
        return
    end

    if #TheSim:FindEntities(x, y, z, PLANTS_RANGE, PLANTFX_TAGS) < MAX_PLANTS then
        local map = TheWorld.Map
        local pt = Vector3(0, 0, 0)
        local offset = FindValidPositionByFan(
            math.random() * 2 * PI,
            math.random() * PLANTS_RANGE,
            3,
            function(offset)
                pt.x = x + offset.x
                pt.z = z + offset.z
                return map:CanPlantAtPoint(pt.x, 0, pt.z)
                    and #TheSim:FindEntities(pt.x, 0, pt.z, .5, PLANTFX_TAGS) < 3
                    and map:IsDeployPointClear(pt, nil, .5)
                    and not map:IsPointNearHole(pt, .4)
            end
        )
        owner.planttask = nil
        owner.plantpool = { 1, 2, 3, 4, 5 }
        for i = #owner.plantpool, 1, -1 do
            --randomize in place
            table.insert(owner.plantpool, table.remove(owner.plantpool, math.random(i)))
        end

        if offset ~= nil then
            local plant = SpawnPrefab("succulent_plant_fx")
            plant.Transform:SetPosition(x + offset.x, 0, z + offset.z)
            --randomize, favoring ones that haven't been used recently
            local rnd = math.random()
            rnd = table.remove(owner.plantpool, math.clamp(math.ceil(rnd * rnd * #owner.plantpool), 1, #owner.plantpool))
            table.insert(owner.plantpool, rnd)
            plant:SetVariation(rnd)
        end
    end
end

local function can_plant(inst)
    return inst.components.machine.ison
end

local function onequip_emerald(inst, owner)
    -- inst.onattach(owner)
    owner.AnimState:OverrideSymbol("swap_body", "torso_emeraldamulet", "torso_emeraldamulet")

    if inst.healtask == nil then
        inst.healtask = inst:DoPeriodicTask(5, healowner, nil, owner)
    end

    if inst.tendtoplantstask == nil then
        inst.tendtoplantstask = inst:DoPeriodicTask(1, TendToPlantsAOE, nil, owner)
    end

    if can_plant(inst) and inst.planttask == nil then
        inst.planttask = inst:DoPeriodicTask(0.25, spawnplants, nil, owner)
    end
end

local function onunequip_emerald(inst, owner)
    -- inst.ondetach(owner)
    if owner.sg == nil or owner.sg.currentstate.name ~= "amulet_rebirth" then
        owner.AnimState:ClearOverrideSymbol("swap_body")
    end

    if inst.healtask ~= nil then
        inst.healtask:Cancel()
        inst.healtask = nil
    end

    if inst.planttask ~= nil then
        inst.planttask:Cancel()
        inst.planttask = nil
    end

    if inst.tendtoplantstask ~= nil then
        inst.tendtoplantstask:Cancel()
        inst.tendtoplantstask = nil
    end
end

local function turnon( inst )
    if inst.components.equippable:IsEquipped() then
        local owner = inst.components.inventoryitem:GetGrandOwner()
        if inst.planttask == nil then
            inst.planttask = inst:DoPeriodicTask(0.25, spawnplants, nil, owner)
        end
    end
end

local function turnoff(inst)
    if inst.planttask ~= nil then
        inst.planttask:Cancel()
        inst.planttask = nil
    end
end


--[[ local function ruinshat_oncooldown(inst)
    inst._task = nil
end

local function ruinshat_unproc(inst)
    if inst:HasTag("forcefield") then
        inst:RemoveTag("forcefield")
        if inst._fx ~= nil then
            inst._fx:kill_fx()
            inst._fx = nil
        end

        if inst._task ~= nil then
            inst._task:Cancel()
        end
        inst._task = inst:DoTaskInTime(TUNING.ARMOR_RUINSHAT_COOLDOWN, ruinshat_oncooldown)
    end
end

local function ruinshat_proc(inst, owner)
    inst:AddTag("forcefield")
    if inst._fx ~= nil then
        inst._fx:kill_fx()
    end
    inst._fx = SpawnPrefab("green_forcefieldfx")
    inst._fx.entity:SetParent(owner.entity)
    inst._fx.Transform:SetPosition(0, 0.2, 0)


    if inst._task ~= nil then
        inst._task:Cancel()
    end
    inst._task = inst:DoTaskInTime(TUNING.ARMOR_RUINSHAT_DURATION, ruinshat_unproc)
end

local function tryproc(inst, owner, data)
    if inst._task == nil and
        not data.redirected then
        ruinshat_proc(inst, owner)
    end
end
local function ruins_onremove(inst)
    if inst._fx ~= nil then
        inst._fx:kill_fx()
        inst._fx = nil
    end
end

 ]]
local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("emeraldamulet")
    inst.AnimState:SetBuild("emeraldamulet")
    inst.AnimState:PlayAnimation("emeraldamulet")

    inst:AddTag("emeraldamulet")
    inst:AddTag("whitneypoison_item")
    -- inst:AddTag("bring_burnt_backtolife")

    inst.foleysound = "dontstarve/movement/foley/jewlery"

    MakeInventoryFloatable(inst, "med", nil, 0.6)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.NECK or EQUIPSLOTS.BODY
    inst.components.equippable.dapperness = TUNING.DAPPERNESS_SMALL
    inst.components.equippable.is_magic_dapperness = true

    inst:AddComponent("machine")
    inst.components.machine.turnonfn = turnon
    inst.components.machine.turnofffn = turnoff
    inst.components.machine.cooldowntime = 3
    inst.components.machine.ison = true

    inst:AddComponent("inventoryitem")

    inst.components.equippable:SetOnEquip(onequip_emerald)
    inst.components.equippable:SetOnUnequip(onunequip_emerald)

    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetOnFinished(inst.Remove)
    inst.components.finiteuses:SetMaxUses(160)
    inst.components.finiteuses:SetUses(160)


    -- inst._fx = nil
    -- inst._task = nil
    -- inst._owner = nil
    -- inst.procfn = function(owner, data) tryproc(inst, owner, data) end
    -- inst.onattach = function(owner)
    --     if inst._owner ~= nil then
    --         inst:RemoveEventCallback("attacked", inst.procfn, inst._owner)
    --         inst:RemoveEventCallback("onremove", inst.ondetach, inst._owner)
    --     end
    --     inst:ListenForEvent("attacked", inst.procfn, owner)
    --     inst:ListenForEvent("onremove", inst.ondetach, owner)
    --     inst._owner = owner
    --     inst._fx = nil
    -- end
    -- inst.ondetach = function()
    --     ruinshat_unproc(inst)
    --     if inst._owner ~= nil then
    --         inst:RemoveEventCallback("attacked", inst.procfn, inst._owner)
    --         inst:RemoveEventCallback("onremove", inst.ondetach, inst._owner)
    --         inst._owner = nil
    --         inst._fx = nil
    --     end
    -- end

    -- inst.OnRemoveEntity = ruins_onremove


    MakeHauntableLaunch(inst)

    return inst
end

return Prefab("emeraldamulet", fn, assets, prefabs)