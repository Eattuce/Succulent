local assets =
{
    Asset("ANIM", "anim/thistle_bush.zip"),
    Asset("SOUND", "sound/common.fsb"),
}

local prefabs =
{
    "cactus_flower",
    "spoiled_food",
    "thistle_seed",
}

--
local function onpickedfn(inst, picker)
    local probability = math.random()
    -- print(probability)
    -- print(inst.components.pickable.cycles_left)
    local canseed = inst.components.growable.stage
    -- print(canseed)
    local picked_anim = "idle3_2_idle1"
--------------------------------------------------------------------------
    if picker ~= nil and canseed >= 4 then
        if probability <= 0.05 then
            local seed = SpawnPrefab("thistle_seed")
            seed.components.inventoryitem:InheritMoisture(TheWorld.state.wetness, TheWorld.state.iswet)
            if picker.components.inventory ~= nil then
                picker.components.inventory:GiveItem(seed, nil, inst:GetPosition())
            end
        end
    end
--------------------------------------------------------------------------
    inst.components.growable:SetStage(2)
--------------------------------------------------------------------------
    inst.AnimState:PlayAnimation(picked_anim)
    if inst.components.pickable:IsBarren() then
        -- NOTE: IsBarren just tests cycles_left; MakeBarren hasn't actually been called!
        -- So we need to do the relevant parts of that function. Copied here just to not overload SetStage/animations.
        inst.AnimState:PushAnimation("idle1_2_wither", false)
        inst.AnimState:PushAnimation("wither")
        inst.components.growable:StopGrowing()
        inst.components.growable.magicgrowable = false
    else
        inst.AnimState:PushAnimation("idle_1")
        inst.components.growable:StartGrowing()
    end
end

local function onregenfn(inst)
    -- If we got here via debug and we're not at pickable yet, just skip us ahead to the first pickable stage.
    if inst.components.growable.stage < 3 then
        inst.components.growable:SetStage(3)
    end
end

local function makeemptyfn(inst)
    if not POPULATING then
        -- SetStage(1) will change the animation, so store whether we came into this function dead first.
        local emptying_dead = inst.AnimState:IsCurrentAnimation("wither")

        inst.components.growable:SetStage(2)
        inst.components.growable:StartGrowing()
        inst.components.growable.magicgrowable = true

        -- if not (inst:HasTag("withered") or emptying_dead) then
        if not (inst.components.pickable:IsBarren() or emptying_dead) then
            inst.AnimState:PlayAnimation("idle_1")
            inst.AnimState:PushAnimation("idle_1")
        else
            inst.AnimState:PlayAnimation("wither_2_idle1")
            inst.AnimState:PushAnimation("idle_1")
        end
    end
end

--------------------------------------------------------------------------

local function set_stage1(inst)
    inst.components.pickable:ChangeProduct(nil)

    inst.components.pickable.canbepicked = false

    inst.AnimState:PlayAnimation("wither",true)
end

local function grow_to_stage1(inst)
    inst.AnimState:PlayAnimation("wither",true)
end

local function set_stage2(inst)
    inst.components.pickable:ChangeProduct(nil)

    inst.components.pickable.canbepicked = false

    inst.AnimState:PlayAnimation("idle_1",true)
end

local function grow_to_stage2(inst)
    inst.AnimState:PlayAnimation("wither_2_idle1")
    inst.AnimState:PushAnimation("idle_1")
end

local function set_stage3(inst)
    inst.components.pickable:ChangeProduct("cactus_flower")

    inst.components.pickable.canbepicked = true
    inst.components.pickable.numtoharvest = 2
    inst.components.pickable:Regen()

    inst.AnimState:PlayAnimation("idle_2",true)
end

local function grow_to_stage3(inst)
    inst.AnimState:PlayAnimation("idle1_2_idle2")
    inst.AnimState:PushAnimation("idle_2")
end

local function set_stage4(inst)
    inst.components.pickable:ChangeProduct("cactus_flower")

    inst.components.pickable.canbepicked = true
    inst.components.pickable.numtoharvest = 2 + math.random(3)
    inst.components.pickable:Regen()
    inst.components.growable:StopGrowing()

    inst.AnimState:PlayAnimation("idle_3",true)
end

local function grow_to_stage4(inst)
    inst.AnimState:PlayAnimation("idle2_2_idle3")
    inst.AnimState:PushAnimation("idle_3")
end

local STAGE1 = "stage_1"
local STAGE2 = "stage_2"
local STAGE3 = "stage_3"
local STAGE4 = "stage_4"

local seg_time = 30
local total_day_time = seg_time*16

local growth_stages =
{
    {
        name = STAGE1,
        time = function(inst) return GetRandomWithVariance(total_day_time, 2*seg_time) end,
        fn = set_stage1,
        growfn = grow_to_stage1,
    },
    {
        name = STAGE2,
        time = function(inst) return GetRandomWithVariance(3*total_day_time, 2*seg_time) end,
        fn = set_stage2,
        growfn = grow_to_stage2,
    },
    {
        name = STAGE3,
        time = function(inst) return GetRandomWithVariance(5*total_day_time, 2*seg_time) end,
        fn = set_stage3,
        growfn = grow_to_stage3,
    },
    {
        name = STAGE4,
        time = function(inst) return GetRandomWithVariance(total_day_time, 2*seg_time) end,
        fn = set_stage4,
        growfn = grow_to_stage4,
    },
}

local function makebarrenfn(inst, wasempty)
    inst.components.growable:SetStage(1)
    inst.components.growable:StopGrowing()
    inst.components.growable.magicgrowable = false

    -- if not POPULATING and inst:HasTag("withered") then
    -- if not POPULATING and inst.components.pickable:IsBarren() then
    --     inst.AnimState:PlayAnimation("idle1_2_wither")
    --     inst.AnimState:PushAnimation("wither", false)
    -- else
        inst.AnimState:PlayAnimation("wither",true)
        -- inst.AnimState:PushAnimation("wither")
    -- end
end

-- local function on_bush_burnt(inst)
--     -- The bush, of course, stops growing once it's been burnt.
--     inst.components.growable:StopGrowing()

--     DefaultBurntFn(inst)
-- end

local function on_ignite(inst)
    -- Function empty; we make a custom function just to bypass the persists = false portion of the default ignite function.
end

-- local function on_save(inst, data)
--     if inst.components.burnable ~= nil and inst.components.burnable:IsBurning() then
--         data.burning = true
--     end
-- end

-- local function on_load(inst, data)
--     if data == nil then
--         return
--     end

--     if data.burning then
--         on_bush_burnt(inst)
--     -- elseif inst.components.witherable:IsWithered() then
--     --     inst.components.witherable:ForceWither()
--     elseif not inst.components.pickable:IsBarren() and data.growable ~= nil and data.growable.stage == nil then
--         -- growable doesn't call SetStage on load if the stage was saved out as nil (assuming initial state is ok).
--         -- Since we randomly choose a stage on prefab creation, we want to explicitly call SetStage(1) for that case.
--         inst.components.growable:SetStage(1)
--     end
-- end

local function commonfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()
    -- inst.entity:AddMiniMapEntity()
    -- inst.MiniMapEntity:SetIcon("reeds.png")

    inst:AddTag("plant")
    inst:AddTag("thistle_bush")

    -- MakeObstaclePhysics(inst, .1)

    inst.AnimState:SetBank("thistle_bush")
    inst.AnimState:SetBuild("thistle_bush")
    inst.AnimState:PlayAnimation("idle_1")
    inst.AnimState:PushAnimation("idle_1")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("pickable")
    inst.components.pickable.picksound = "dontstarve/wilson/harvest_berries"
    inst.components.pickable.makeemptyfn = makeemptyfn
    inst.components.pickable.onregenfn = onregenfn
    inst.components.pickable.onpickedfn = onpickedfn
    inst.components.pickable.makebarrenfn = makebarrenfn
    inst.components.pickable.max_cycles = 5
    inst.components.pickable.cycles_left = inst.components.pickable.max_cycles

    inst:AddComponent("growable")
    inst.components.growable.stages = growth_stages
    inst.components.growable.springgrowth = true
    inst.components.growable.magicgrowable = true
    inst.components.growable:SetStage(math.random(2,3))
    -- inst.components.growable:StartGrowing()
    -- inst.components.growable.loopstages = true

    -- MakeMediumBurnable(inst)
    -- inst.components.burnable:SetOnBurntFn(on_bush_burnt)
    -- inst.components.burnable:SetOnIgniteFn(on_ignite)
    -- MakeMediumPropagator(inst)
    inst:AddComponent("lootdropper")
    inst:AddComponent("inspectable")

    -- MakeHauntableIgnite(inst)

    -- inst.OnSave = on_save
    -- inst.OnLoad = on_load

    return inst
end

local function OnIsSummer(inst, issummer)
    if issummer then
        inst:DoTaskInTime(5*math.random(),function ()
            inst:Show()
            if inst.components.pickable.product ~= nil then
                inst.components.pickable.canbepicked = true
            end
        end)
    else
        inst:DoTaskInTime(5*math.random(),function ()
            inst:Hide()
            inst.components.pickable.canbepicked = false
        end)
    end
end

local function OnInit(inst)
    -- OnIsSummer(inst)
    if TheWorld.state.issummer then
        inst:Show()
        if inst.components.pickable.product ~= nil then
            inst.components.pickable.canbepicked = true
        end
    else
        inst:Hide()
        inst.components.pickable.canbepicked = false
    end
end

local function digup(inst)
    if inst.components.growable.stage == 1 then
        inst.components.lootdropper:SpawnLootPrefab("thistle_seed")
    elseif inst.components.pickable.canbepicked then
        for i=1, inst.components.pickable.numtoharvest do
            inst.components.lootdropper:SpawnLootPrefab("cactus_flower")
        end
    end
    inst:Remove()
end

local function MakeThistleBush(prefab)
    local function fn()
        local inst = commonfn()

        if not TheWorld.ismastersim then
            return inst
        end

        if prefab == "thistle_bush" then
            inst.task = inst:DoTaskInTime(0,OnInit)
            inst:WatchWorldState("issummer", OnIsSummer)
            inst.components.growable:StartGrowing()
        else
            inst:AddComponent("workable")
            inst.components.workable:SetWorkAction(ACTIONS.DIG)
            inst.components.workable:SetWorkLeft(1)
            inst.components.workable:SetOnFinishCallback(digup)
        end
        -- inst:AddComponent("witherable") -- OverHeat?
        -- MakeNoGrowInWinter(inst)

        return inst
    end

    return Prefab(prefab, fn, assets, prefabs)
end

return MakeThistleBush("thistle_bush"),
    MakeThistleBush("thistle_kid")