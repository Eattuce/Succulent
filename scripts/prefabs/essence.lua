local assets =
{
    Asset("ANIM", "anim/refreshessence.zip"),
    Asset("IMAGE", "images/inventoryimages/essence_inactive.tex"),
    Asset("ATLAS", "images/inventoryimages/essence_inactive.xml"),
    Asset("IMAGE", "images/inventoryimages/essence_active.tex"),
    Asset("ATLAS", "images/inventoryimages/essence_active.xml"),
}

local Refresh_threshold = 0.9


local function GetOwner(inst)
    local owner = inst.components.inventoryitem and inst.components.inventoryitem.owner or nil
    if not owner and inst.components.occupier then
        owner = inst.components.occupier:GetContainer() --owner是容器
    end
    return owner
end

local function activeimage(inst)
    inst.components.inventoryitem:ChangeImageName("essence_active")
    inst.components.inventoryitem.atlasname = "images/inventoryimages/essence_active.xml"
end

local function inactiveimage(inst)
    inst.components.inventoryitem:ChangeImageName("essence_inactive")
    inst.components.inventoryitem.atlasname = "images/inventoryimages/essence_inactive.xml"
end

local function StopWorking(inst) --停止工作
    -- print("Stop")
    inst.components.fueled:StopConsuming()
    if inst.components.fueled.rate_modifiers then
        inst.components.fueled.rate_modifiers:RemoveModifier(inst)
    end

    inactiveimage(inst)
    inst:DoTaskInTime(0, inactiveimage)

    if inst.freshtask ~= nil then
        inst.freshtask:Cancel()
        inst.freshtask = nil
        -- print("Cancel")
    end
end

-- local function StartWorking(inst)
    
-- end


local function onperish(inst)
    inst:DoTaskInTime(1, StopWorking)
    inactiveimage(inst)
end

local function CountFood(owner) --记录食物和数量
    local amt = 0
    local foods = {}
    if owner and owner.components.container then
        for k, v in pairs(owner.components.container.slots) do
            if v.components.edible --可食用
                and v.components.perishable ~= nil and v.components.perishable:GetPercent() <= Refresh_threshold --有新鲜度且小于90%
                and not v:HasTag("frozen") --不是冰
            then
                amt = amt + (v.components.stackable ~= nil and v.components.stackable:StackSize() or 1) --计算
                table.insert(foods, v)
            end
        end
    end
    return amt, foods
end

local function Refresh(foods)
    for k, v in pairs(foods) do
        local percent = v.components.perishable:GetPercent()
        if percent <= Refresh_threshold then
            if TheWorld.state.iswinter then --冬天
                percent = percent + 0.009 --每10秒 返还9%的新鲜度
            elseif TheWorld.state.issummer then --夏天
                percent = percent + 0.011 --每10秒 返还11%的新鲜度
            else
                percent = percent + 0.01 --每10秒 返还10%的新鲜度
            end
        v.components.perishable:SetPercent(percent)
        end
    end
    -- print("fresh")
end
------------------------------------------------------------------------
local function Isessence(inst)
    return inst:HasTag("essence")
end

local function itemget(owner, data)
    if data then
        local item = data.item
        if item and item.components then
            if item.components.edible and item.components.perishable then
                local essences = owner.components.container:FindItems(Isessence)
                for _,v in pairs(essences) do
                    v:Startfreshtask(v, owner)
                end
                owner:RemoveEventCallback("itemget", itemget)
            end
        end
    end
end

local function Pause(inst, owner)
    StopWorking(inst)
    owner:ListenForEvent("itemget", itemget)
    print("Paused")
end
------------------------------------------------------------------------
local function Startfreshtask(inst, owner)
    inst.freshtask = inst:DoPeriodicTask(1, function()
        if inst.components.fueled:GetPercent() <= 0 then
            StopWorking(inst)
            return
        end

        local amt, foods = CountFood(owner)

        if amt ~= 0 then
            inst:DoTaskInTime(0, activeimage)
            inst.components.fueled.rate_modifiers:SetModifier(inst, amt)
            inst.components.fueled:StartConsuming()
            Refresh(foods)
        else
            if inst.components.fueled.rate_modifiers then
                inst.components.fueled.rate_modifiers:RemoveModifier(inst)
            end
            inst.components.fueled:StopConsuming()
            inst:DoTaskInTime(0, inactiveimage)
            -- print("No target")
            -- Pause(inst, owner)
        end
    end)
end

local function OnPutInInventory(inst)
    local owner = GetOwner(inst)
    if owner == nil then
        return
    end

    if inst.components.fueled:GetPercent() <= 0 then
        StopWorking(inst)
        return
    end

    if owner:HasTag("player") or (owner.components and owner.components.inventory) then
        StopWorking(inst)
        return
    end

    Startfreshtask(inst, owner)
end

local function OnDropped(inst)
    StopWorking(inst)
end

local function onacceptfuel(inst)
    -- print("Accepted")
    local owner = GetOwner(inst)

    if not owner or owner:HasTag("player") or (owner.components and owner.components.inventory) then
        return
    end

    if not inst.freshtask then
        Startfreshtask(inst, owner)
    end
end

local function getstatus(inst)
    if inst.components.fueled.consuming then
        return "WORK"
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("refreshessence")
    inst.AnimState:SetBuild("refreshessence")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("icebox_valid") --为了能放在冰箱
    inst:AddTag("saltbox_valid") --为了能放在盐箱
    inst:AddTag("treeseed") --为了能放在种子袋
    inst:AddTag("essence")

    MakeInventoryFloatable(inst, "small", 0.05, 0.8)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end
    ---------------------

    inst.Startfreshtask = Startfreshtask

    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = getstatus

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem:SetOnDroppedFn(OnDropped)
    inst.components.inventoryitem:SetOnPutInInventoryFn(OnPutInInventory)
    inst.components.inventoryitem.imagename = "essence_inactive"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/essence_inactive.xml"

    inst:AddComponent("fueled")
    inst.components.fueled.fueltype = FUELTYPE.MAGIC
    inst.components.fueled.accepting = true
    inst.components.fueled:InitializeFuelLevel(TUNING.TOTAL_DAY_TIME)
    inst.components.fueled:SetFirstPeriod(TUNING.TURNON_FUELED_CONSUMPTION, TUNING.TURNON_FULL_FUELED_CONSUMPTION)
    inst.components.fueled:SetDepletedFn(onperish)
    inst.components.fueled:SetTakeFuelFn(onacceptfuel)
    inst.components.fueled.rate_modifiers:SetModifier("restriction", 1/8)

    MakeHauntableLaunch(inst)

    return inst
end

return Prefab("essence", fn, assets)