
require "prefabutil"

local assets =
{
    Asset("ANIM", "anim/treasurechest_succulent.zip"),
    -- Asset("ANIM", "anim/treasure_chest.zip"),
    Asset("ANIM", "anim/ui_succulentchest_5x5.zip"),
}

local prefabs = {"collapse_small"}

local function onopen(inst)
    if inst._snow then inst._snow:Hide() end
    inst.AnimState:PlayAnimation("open")
    inst.SoundEmitter:PlaySound("succulent_chest/chest/open")
end

local function onclose(inst)
    if inst._snow then inst._snow:Show() end
    inst.AnimState:PlayAnimation("close")
    inst.AnimState:PushAnimation("closed", false)
    inst.SoundEmitter:PlaySound("succulent_chest/chest/close")
end

local function onhammered(inst, worker)
    if inst._snow then inst._snow:Show() end

    inst.components.lootdropper:DropLoot()
    if inst.components.container ~= nil then
        inst.components.container:DropEverything()
    end
    local fx = SpawnPrefab("collapse_small")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("stone")
    inst:Remove()
end

local function onhit(inst, worker)
    inst.AnimState:PlayAnimation("hit")
    inst.AnimState:PushAnimation("closed", false)
    if inst.components.container ~= nil then
        inst.components.container:DropEverything()
        inst.components.container:Close()
    end
end

local function onbuilt(inst)
    inst.AnimState:PlayAnimation("place")
    inst.AnimState:PushAnimation("closed", false)
    -- inst.SoundEmitter:PlaySound("dontstarve/common/chest_craft")
    inst.SoundEmitter:PlaySound("dontstarve/common/place_structure_stone")
end

local function onanimover(inst)
    if inst._snow == nil then
        if inst.AnimState:IsCurrentAnimation("closed") then
            inst._snow = SpawnPrefab("succulentchest_snow")
            inst._snow.entity:SetParent(inst.entity)
            inst._snow.Follower:FollowSymbol(inst.GUID, "chest01", 0, 0, 0)
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

    inst.MiniMapEntity:SetIcon("succulentchest_minimapicon.tex")
    MakeObstaclePhysics(inst, .1)

    inst:AddTag("structure")
    inst:AddTag("chest")

    inst.AnimState:SetBank("chest")
    inst.AnimState:SetBuild("treasurechest_succulent")
    inst.AnimState:PlayAnimation("closed")
    -- inst.AnimState:SetFinalOffset(1)

    inst.entity:SetPristine()

    inst.widget_name = "treasurechest_succulent"
    if not TheWorld.ismastersim then
        -- inst.OnEntityReplicated = function () inst.replica.container:WidgetSetup(inst.widget_name) end
        return inst
    end

    inst:AddComponent("inspectable")
    inst:AddComponent("container")

    inst.components.container:WidgetSetup(inst.widget_name)
    inst.components.container.onopenfn = onopen
    inst.components.container.onclosefn = onclose
    inst.components.container.skipclosesnd = true
    inst.components.container.skipopensnd = true

    inst:AddComponent("lootdropper")
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(3)
    inst.components.workable:SetOnFinishCallback(onhammered)
    inst.components.workable:SetOnWorkCallback(onhit)

    inst:AddComponent("hauntable")
    inst.components.hauntable:SetHauntValue(TUNING.HAUNT_TINY)

    inst:ListenForEvent("onbuilt", onbuilt)
    inst.ListenForEvent("animover", onanimover)

    return inst
end

return Prefab("treasurechest_succulent", fn, assets, prefabs),
    MakePlacer("treasurechest_succulent_item_placer", "chest", "treasurechest_succulent", "closed")
    -- (name, prefab_to_deploy, bank, build, anim, assets, floatable_data, tags, deployable_data, stack_size)
    -- Prefab("treasurechest_succulent_item", itemfn, {Asset("ANIM", "anim/bundle.zip")})