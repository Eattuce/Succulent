
local prefabs =
{
    "succulent_plant_fx_flower"
}

-- 秋季节，绿色，dawn， 晨露莲花
local spring_tags = {"shelter", "healer", "cooler", "green", "haskids"} -- x,回血,灭烟
local spring_colour = {R = 116/255, G = 194/255, B = 151/255}
-- 春季节，红色，sunset, 夕烧兰花
local autumn_tags = {"shelter", "tendtoplants", "fragile", "red"} -- x,照顾植物,一砍就倒
local autumn_coulour = {R = 209/255, G = 82/255, B = 101/255}

local function Cool(inst)
	local x, y, z = inst.Transform:GetWorldPosition()
    local tar = TheSim:FindEntities(x, y, z, 9, nil, { "FX", "NOCLICK", "DECOR", "INLIMBO", "playerghost" }, { "smolder" })
    for i, v in pairs(tar) do
        if v.components.burnable ~= nil then
			if v.components.burnable:IsSmoldering() then
				v.components.burnable:SmotherSmolder()
			end
        end
    end
end

local PLANT_TAGS = {"tendable_farmplant"}
local function TendToPlantsAOE(inst)
    if inst.entity:IsVisible() then
        local x, y, z = inst.Transform:GetWorldPosition()
        for _, v in pairs(TheSim:FindEntities(x, y, z, --[[TUNING.WORMWOOD_BLOOM_FARM_PLANT_INTERACT_RANGE]]9, PLANT_TAGS)) do
            if v.components.farmplanttendable ~= nil then
                v.components.farmplanttendable:TendTo(inst)
            end
        end
    end
end

local function DoHeal(inst)
    local targets = {}
    local x, y, z = inst.Transform:GetWorldPosition()
    for i, v in ipairs(AllPlayers) do
        if not (v.components.health:IsDead() or v:HasTag("playerghost")) and
            v.entity:IsVisible() and
            v:GetDistanceSqToPoint(x, y, z) < (TUNING.WORTOX_SOULHEAL_RANGE * TUNING.WORTOX_SOULHEAL_RANGE)/4 then
            table.insert(targets, v)
        end
    end

    for i, v in ipairs(targets) do
        local amt = (TUNING.HEALING_MED/2) - math.min(8, #targets) + 1
        v.components.health:DoDelta(amt, nil, inst.prefab)
        if v.prefab == "wormwood" then
            v.components.health:DoDelta(amt, nil, inst.prefab)
        end
    end
end

local function ontimer(inst, data)
    if data.name == "extinguish" then
        inst:DoTaskInTime(0.66, inst.Remove)
        local flower = inst:HasTag("succulent_flower_dawn") and SpawnPrefab("succulent_flower_dawn_b") or SpawnPrefab("succulent_flower_sunset_b")
        local pos = inst:GetPosition()
        if flower ~= nil and pos ~= nil then
            flower.Transform:SetPosition(pos:Get())
            flower.flowered = true
        end
    end
end

local function aurafallofffn(inst, observer, distsq)
	distsq =  TUNING.SANITYAURA_SMALL_TINY + math.sqrt(math.max(2, distsq))
	return distsq
end

--
local MAX_PLANTS = 16
local PLANTS_RANGE = 1.3
local PLANTS_RANGE_MIN = 0.8
local PLANTFX_TAGS = { "succulent_plant_fx_flower" }
local function SpawnFX(inst)
    if not inst.entity:IsVisible() then
        return
    end

    local x, y, z = inst.Transform:GetWorldPosition()
    if TheWorld.Map:GetPlatformAtPoint(x, z) ~= nil then
        return
    end

    local map = TheWorld.Map
    local pt = Vector3(0, 0, 0)
    local offset = FindValidPositionByFan(
        math.random() * 2 * PI,
        GetRandomMinMax(PLANTS_RANGE_MIN, PLANTS_RANGE),
        --math.random() * PLANTS_RANGE,
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

    inst.plantpool = { 1, 2, 3, 4, 5 }
    for i = #inst.plantpool, 1, -1 do
        --randomize in place
        table.insert(inst.plantpool, table.remove(inst.plantpool, math.random(i)))
    end

    if offset ~= nil then
        local plant = SpawnPrefab("succulent_plant_fx_flower")
        plant.Transform:SetPosition(x + offset.x, 0, z + offset.z)
        --randomize, favoring ones that haven't been used recently
        local rnd = math.random()
        rnd = table.remove(inst.plantpool, math.clamp(math.ceil(rnd * rnd * #inst.plantpool), 1, #inst.plantpool))
        table.insert(inst.plantpool, rnd)
        plant:SetVariation(rnd)

        if inst.fx <= MAX_PLANTS then
            inst.fxtask = inst:DoTaskInTime(0.33, SpawnFX)
        else
            if inst.fxtask ~= nil then
                inst.fxtask:Cancel()
                inst.fxtask = nil
            end
        end
    end
end

-- local function OnChop(inst, chopper)
--     if not (chopper ~= nil and chopper:HasTag("playerghost")) then
--         inst.SoundEmitter:PlaySound(
--             chopper ~= nil and chopper:HasTag("beaver") and
--             "dontstarve/characters/woodie/beaver_chop_tree" or
--             "dontstarve/wilson/use_axe_tree"
--         )
--     end

--     inst.AnimState:PlayAnimation("chop")
--     inst.AnimState:PushAnimation("idle")
-- end

local function OnAnimOver(inst)
    if inst.AnimState:IsCurrentAnimation("idle") then
        inst.fxtask = inst:DoTaskInTime(0.33, SpawnFX)
    end
end

-- local function OverrideAllSimble(inst, scml)
--     inst.AnimState:OverrideSymbol("branch01", scml, "branch01")
--     inst.AnimState:OverrideSymbol("bulb01", scml, "branch01")
--     inst.AnimState:OverrideSymbol("flower01", scml, "branch01")
--     inst.AnimState:OverrideSymbol("needle01", scml, "branch01")
--     inst.AnimState:OverrideSymbol("stalk01", scml, "branch01")
--     inst.AnimState:OverrideSymbol("stalk02", scml, "branch01")
-- end

local function common(name, scml)
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeObstaclePhysics(inst, .6)

    inst._ismastersim = TheWorld.ismastersim

    inst.AnimState:SetBank(scml)
    inst.AnimState:SetBuild(scml)
    -- inst.AnimState:SetBank("bramble_core")
    -- inst.AnimState:SetBuild("bramble_core")
    -- OverrideAllSimble(inst, scml)

    inst:AddTag(name)
    inst:AddTag("plant")
    inst:AddTag("tree")

    inst.entity:SetPristine()

    if not inst._ismastersim then
        return inst
    end

    MakeMediumBurnable(inst, TUNING.TREE_BURN_TIME*.6)
    inst.components.burnable:SetFXLevel(1)

    inst:AddComponent("inspectable")

    return inst
end

local function makeflower(name, anim, tags, colour)
    local assets =
    {
        Asset("ANIM", "anim/"..anim..".zip"),
        -- Asset("ANIM", "anim/bramble_core.zip"),
    }

    local function fn()
        local inst = common(name, anim)

        inst.entity:AddLight()

        inst.AnimState:PlayAnimation("grow")
        inst.AnimState:PushAnimation("idle")
        inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")

        for k,v in ipairs(tags) do
            inst:AddTag(v)
        end
        inst:AddTag("succulent_flower")

        inst.Light:SetFalloff(0.7)
        inst.Light:SetIntensity(.5)
        inst.Light:SetRadius(3)
        inst.Light:SetColour(colour.R, colour.G, colour.B)
        inst.Light:Enable(true)

        -- inst._ismastersim = TheWorld.ismastersim
        if not inst._ismastersim then
            return inst
        end

        inst:AddComponent("sanityaura")
        inst.components.sanityaura.aura = TUNING.SANITYAURA_SMALL
        inst.components.sanityaura.fallofffn = aurafallofffn

        inst:AddComponent("timer")
        inst.components.timer:StartTimer("extinguish", TUNING.OPALSTAFF_STAR_DURATION*3)

        inst:ListenForEvent("timerdone", ontimer)
        inst:AddComponent("workable")
        inst.components.workable:SetWorkAction(ACTIONS.CHOP)
        inst.components.workable:SetWorkLeft(inst:HasTag("fragile") and 1 or 3)
        -- inst.components.workable:SetOnWorkCallback(OnChop)
        inst.components.workable:SetOnFinishCallback(function()
            inst.AnimState:PlayAnimation("wither")
            inst:ListenForEvent("animqueueover", inst.Remove)
        end)

        if inst:HasTag("tendtoplants") then
            inst.tendtoplantstask = inst:DoPeriodicTask(3, TendToPlantsAOE, nil, inst)
        end

        if inst:HasTag("healer") then
            inst.healtask = inst:DoPeriodicTask(20, DoHeal)
        end

        if inst:HasTag("cooler") then
            inst.cooltask = inst:DoPeriodicTask(1, Cool)
        end

        if inst:HasTag("haskids") then
            inst.fx = 0
            inst:ListenForEvent("animover", OnAnimOver)
        end

        return inst
    end
    return Prefab(name, fn, assets, prefabs)

end

local function makedeadflower(name, anim)
    local assets =
    {
        Asset("ANIM", "anim/"..anim..".zip"),
    }

    local function fn()
        local inst = common(name, anim)

        inst.AnimState:PushAnimation("idle")

        -- inst._ismastersim = TheWorld.ismastersim
        if not inst._ismastersim then
            return inst
        end

        inst:AddComponent("workable")
        inst.components.workable:SetWorkAction(ACTIONS.DIG)
        inst.components.workable:SetWorkLeft(1)
        inst.components.workable:SetOnFinishCallback(function()
            inst.AnimState:PlayAnimation("wither")
            inst:ListenForEvent("animqueueover", inst.Remove)
        end)
        return inst
    end

    return Prefab(name, fn, assets, prefabs)
end

-- return makeflower("succulent_flower_dawn", "sucflower_spr", spring_tags, spring_colour),
--     makeflower("succulent_flower_sunset", "sucflower_fall", autumn_tags, autumn_coulour),
--     makedeadflower("succulent_flower_dawn_b", "sucflower_spr"),
--     makedeadflower("succulent_flower_sunset_b", "sucflower_fall")

return makeflower("succulent_flower_dawn", "flower_spring", spring_tags, spring_colour),
    makeflower("succulent_flower_sunset", "flower_autumn", autumn_tags, autumn_coulour),
    makedeadflower("succulent_flower_dawn_b", "flower_spring"),
    makedeadflower("succulent_flower_sunset_b", "flower_autumn")
