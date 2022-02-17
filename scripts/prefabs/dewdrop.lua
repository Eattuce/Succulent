local assets =
{
    Asset("ANIM", "anim/dewdrop.zip"),
    Asset("IMAGE", "images/inventoryimages/dewdrop.tex"),
    Asset("ATLAS", "images/inventoryimages/dewdrop.xml")
}

local function OnPutInInventory(inst, owner)
    if owner ~= nil and owner:IsValid() then
        owner:PushEvent("learncookbookstats", inst.prefab)
    end
end

local function ondropped(inst)
    if inst.components.workable ~= nil then
        inst.components.workable:SetWorkLeft(1)
    end

    if inst.components.stackable ~= nil then
        while inst.components.stackable:StackSize() > 1 do
            local item = inst.components.stackable:Get()
            if item ~= nil then
                if item.components.inventoryitem ~= nil then
                    item.components.inventoryitem:OnDropped()
                end
                item.Physics:Teleport(inst.Transform:GetWorldPosition())
            end
        end
    end

end

local function onworked(inst, worker)
    if worker.components.inventory ~= nil then
        worker.components.inventory:GiveItem(inst, nil, inst:GetPosition())
        worker.SoundEmitter:PlaySound("dontstarve/common/butterfly_trap")
    end
    local x, y, z = inst.Transform:GetWorldPosition()
    for _, v in pairs(TheSim:FindEntities(x, y, z, 1, {"dewdrop"})) do
        if v.entity:IsVisible() and worker.components.inventory ~= nil then
            worker.components.inventory:GiveItem(v, nil, inst:GetPosition())
        end
    end

end

-- local function updatelight(inst)
--     if TheWorld.state.isnight and inst.components.inventoryitem.owner == nil then
--         fadein(inst)
--     else
--         fadeout(inst)
--     end
-- end

-- local function OnIsNight(inst)
--     inst:DoTaskInTime(2 + math.random(), updatelight)
-- end

local function onload(inst)
    -- If we loaded, then just turn the light on
    inst.Light:Enable(true)
    inst.DynamicShadow:Enable(true)
end


local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    inst.entity:AddPhysics()
    inst.entity:AddLight()
    inst.entity:AddDynamicShadow()
    inst.entity:AddSoundEmitter()

    -- MakeInventoryPhysics(inst)  -- 注释掉就不会被船影响

    inst.AnimState:SetBank("dewdrop")
    inst.AnimState:SetBuild("dewdrop")
    inst.AnimState:PlayAnimation("ground", true)
    inst.AnimState:OverrideSymbol("swap_food", "dewdrop", "dewdrop")

    inst:AddTag("flying")
    inst:AddTag("ignorewalkableplatforms")
    inst:AddTag("ignorewalkableplatformdrowning")


    inst.DynamicShadow:Enable(false)
    inst.DynamicShadow:SetSize(.8, .5)


    --light--
    inst.Light:SetColour(146/255, 225/255, 146/255)
    inst.Light:SetIntensity(0.5)
    inst.Light:SetFalloff(0.5)
    inst.Light:SetRadius(0.2)
    inst.Light:Enable(false)
    ---------
    inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")

    inst:AddTag("dewdrop")

    -- MakeInventoryFloatable(inst, "small", 0.05, 0.8)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_MEDITEM
    inst.components.stackable.forcedropsingle = false -- true

    inst:AddComponent("inspectable")

    inst:AddComponent("knownlocations")
    inst:AddComponent("tradable")


    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "dewdrop"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/dewdrop.xml"
    inst.components.inventoryitem.canbepickedup = false

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.NET)
    inst.components.workable:SetWorkLeft(1)
    inst.components.workable:SetOnFinishCallback(onworked)

    inst:AddComponent("fuel")
    inst.components.fuel.fueltype = FUELTYPE.MAGIC
    inst.components.fuel.fuelvalue = 16*TUNING.LARGE_FUEL


    MakeHauntableLaunchAndSmash(inst)

    inst:ListenForEvent("onputininventory", OnPutInInventory)
    inst:ListenForEvent("ondropped", ondropped)
    -- inst:WatchWorldState("isnight", OnIsNight)


    inst.OnLoad = onload

    return inst
end

return Prefab("dewdrop", fn, assets)
