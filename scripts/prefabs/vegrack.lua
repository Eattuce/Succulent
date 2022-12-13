require "prefabutil"

local assets =
{
    Asset("ANIM", "anim/vegrack.zip"),
    Asset("ANIM", "anim/vegrack_food.zip"),
}
local assets_item =
{
    Asset("ANIM", "anim/bundle.zip"),
    Asset("IMAGE", "images/inventoryimages/vegrack_item.tex"),
    Asset("ATLAS", "images/inventoryimages/vegrack_item.xml"),
}
local prefabs_item =
{
    "vegrack",
}
local prefabs =
{
    -- everything it can "produce" and might need symbol swaps from
    "collapse_small",
    "veggie_crisps",
}

local function onhammered(inst, worker)
    inst.components.lootdropper:DropLoot()
    if inst.components.crispmaker ~= nil then
        inst.components.crispmaker:DropItem()
    end
    local fx = SpawnPrefab("collapse_small")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("wood")
    inst:Remove()
end

local function onhit(inst, worker)
    if inst.components.crispmaker ~= nil and inst.components.crispmaker:IsCrisping() then
        inst.AnimState:PlayAnimation("hit_full")
        inst.AnimState:PushAnimation("drying_pre", false)
        inst.AnimState:PushAnimation("drying_loop", true)
    elseif inst.components.crispmaker ~= nil and inst.components.crispmaker:IsDone() then
        inst.AnimState:PlayAnimation("hit_full")
        inst.AnimState:PushAnimation("idle_full", false)
    else
        inst.AnimState:PlayAnimation("hit_empty")
        inst.AnimState:PushAnimation("idle_empty", false)
    end
end

local function getstatus(inst)
    if inst.components.dryer ~= nil then
        return (inst.components.dryer:IsDone() and "DONE")
            or (inst.components.dryer:IsDrying() and
                (TheWorld.state.israining and "DRYINGINRAIN" or "DRYING"))
            or nil
    end
end

local function onstartdrying(inst, ingredient, buildfile)
    -- if POPULATING then
    --     inst.AnimState:PlayAnimation("drying_loop", true)
    -- else
    --     inst.AnimState:PlayAnimation("drying_pre")
    --     inst.AnimState:PushAnimation("drying_loop", true)
    -- end
    inst.SoundEmitter:PlaySound("dontstarve/common/together/put_meat_rack")
    inst.AnimState:PlayAnimation("idle_crisp")
    inst.AnimState:OverrideSymbol("swap_veggie", "vegrack_food", ingredient)
    inst.AnimState:Show("swap_veggie")
end

local function ondonedrying(inst, product, buildfile)
    inst.AnimState:PlayAnimation("idle_crisp")
    -- inst.AnimState:OverrideSymbol("swap_veggie", "vegrack", "swap_veggie")
    inst.AnimState:ClearOverrideSymbol("swap_veggie")
    inst.AnimState:Show("swap_veggie")
end

local function onharvested(inst)
    inst.AnimState:PlayAnimation("idle")
end

local function onbuilt(inst)
    inst.AnimState:PlayAnimation("place")
    inst.AnimState:PushAnimation("idle", false)
    inst.SoundEmitter:PlaySound("dontstarve/common/place_structure_stone")
end

local function onanimover(inst)
    if inst.AnimState:IsCurrentAnimation("idle") then
        if inst._snow ~= nil then return end
        inst._snow = SpawnPrefab("rack_snow")
        inst._snow.entity:SetParent(inst.entity)
        inst._snow.Follower:FollowSymbol(inst.GUID, "rack", 0, 0, 0)
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()
    inst.entity:AddDynamicShadow()
    -- inst.entity:AddMiniMapEntity()

    inst.DynamicShadow:Enable(true)
    inst.DynamicShadow:SetSize(3, 1)

    -- inst.MiniMapEntity:SetIcon("meatrack.png")

    inst:AddTag("structure")
    inst:AddTag("vegrack")

    inst.AnimState:Hide("mouseover")
    inst.AnimState:Hide("swap_veggie")

    -- MakeSnowCoveredPristine(inst)

    inst.AnimState:SetBank("vegrack")
    inst.AnimState:SetBuild("vegrack")
    inst.AnimState:PlayAnimation("idle")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    MakeHauntableWork(inst)

    inst:AddComponent("dryer")
    inst.components.dryer:SetStartDryingFn(onstartdrying)
    inst.components.dryer:SetDoneDryingFn(ondonedrying)
    inst.components.dryer:SetOnHarvestFn(onharvested)

    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = getstatus


    -- MakeSnowCovered(inst)
    inst:ListenForEvent("onbuilt", onbuilt)

    inst:AddComponent("lootdropper")
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER) -- should be DRY
    inst.components.workable:SetWorkLeft(4)
    inst.components.workable:SetOnFinishCallback(onhammered)
    -- inst.components.workable:SetOnWorkCallback(onhit)

    inst:ListenForEvent("animover", onanimover)

    return inst
end

local function ondeploy(inst, pt, doer)
    inst = inst.components.stackable:Get()
    inst:Remove()

    local vegrack = SpawnPrefab("vegrack")
    if vegrack ~= nil then
        vegrack.Transform:SetPosition(pt:Get())
        vegrack.AnimState:Hide("swap_veggie")
        vegrack.AnimState:PlayAnimation("place")
        vegrack.AnimState:PushAnimation("idle")
        vegrack.SoundEmitter:PlaySound("dontstarve/common/place_structure_stone")
    end
end

local function itemfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBuild("bundle")
    inst.AnimState:SetBank("bundle")
    inst.AnimState:PlayAnimation("idle_large")

    inst.entity:SetPristine()

    inst:AddTag("usedeploystring")
    inst:AddTag("vegrack_item")

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_LARGEITEM

    inst:AddComponent("inspectable")
    inst:AddComponent("inventoryitem")

    inst:AddComponent("deployable")
    inst.components.deployable.ondeploy = ondeploy

    MakeHauntableLaunch(inst)

    return inst
end


return Prefab("vegrack", fn, assets, prefabs),
    Prefab("vegrack_item", itemfn, assets_item, prefabs_item),
    MakePlacer("vegrack_item_placer", "vegrack", "vegrack", "idle",
    nil, nil, nil, nil, nil, nil,
    function(inst)
        inst.AnimState:Hide("mouseover")
        inst.AnimState:Hide("swap_veggie")
    end)