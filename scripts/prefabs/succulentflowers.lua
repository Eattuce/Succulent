
local prefabs =
{
    "succulent_plant_fx_flower"
}

-- 秋季节，绿色，dawn， 晨露莲花
local spring_colour = {R = 116/255, G = 194/255, B = 151/255}
-- 春季节，红色，sunset, 夕烧兰花
local autumn_coulour = {R = 209/255, G = 82/255, B = 101/255}

local function SpawnFX(x, y, z, name, scale)
    local fx = SpawnPrefab(name)
    fx.Transform:SetPosition(x, y, z)
    fx.Transform:SetScale(scale, scale, scale)

end
-- SpawnFX(x_farm, y_farm, z_farm, "carnival_sparkle_fx")


local function SmotherSmolder(inst)
	local x, y, z = inst.Transform:GetWorldPosition()
    local tar = TheSim:FindEntities(x, y, z, 25, nil, { "FX", "NOCLICK", "DECOR", "INLIMBO", "playerghost" }, { "smolder" })
    for i, v in pairs(tar) do
        if v.components.burnable ~= nil then
			if v.components.burnable:IsSmoldering() then
				v.components.burnable:SmotherSmolder()
				local x_farm, y_farm, z_farm = v.Transform:GetWorldPosition()
                SpawnFX(x_farm, y_farm + 0.2, z_farm, "crab_king_icefx", 0.65)
			end
        end
    end
end

 local function TendToPlantsAOE(inst)
    if inst.entity:IsVisible() then
        local x, y, z = inst.Transform:GetWorldPosition()
        for _, v in pairs(TheSim:FindEntities(x, y, z, 16, {"tendable_farmplant"})) do
            if v.components.farmplanttendable ~= nil then
                v.components.farmplanttendable:TendTo(inst)
            end
        end
    end
end

local function BoostAllCrops(inst)
    if inst.entity:IsVisible() then
        local x, y, z = inst.Transform:GetWorldPosition()
        for _, v in pairs(TheSim:FindEntities(x, y, z, 16, {"farm_plant"})) do
            local x_farm, y_farm, z_farm = v.Transform:GetWorldPosition()
            SpawnFX(x_farm, y_farm + 0.2, z_farm, "halloween_moonpuff", 0.65)
            if v and v.components.growable then
                if v.components.growable:GetCurrentStageData().name == "full" then
                    -- If the crop is in "full" stage, extend its lifespan
                    v.components.growable:ExtendGrowTime(100 + 20 * math.random())
                else
                    -- Reduce grow time (targettime) of growing crop
                    v.components.growable:ExtendGrowTime(- 100 - 20 * math.random()) -- Minus value reduces grow time
                end
            end
        end
    end
    inst.boostallcrops = inst:DoTaskInTime(200 + 40 * math.random(), BoostAllCrops)
end

local function ReduceStressAOE(inst)
    if inst.entity:IsVisible() then
        local x, y, z = inst.Transform:GetWorldPosition()
        for _, v in pairs(TheSim:FindEntities(x, y, z, 16, {"farm_plant"})) do
            if v:IsValid() and v.components.farmplantstress ~= nil and v.components.pickable == nil then
                if v.components.farmplantstress.stress_points > 0 then
                    v.components.farmplantstress.stress_points = v.components.farmplantstress.stress_points - 1
                    local x_farm, y_farm, z_farm = v.Transform:GetWorldPosition()
                    SpawnFX(x_farm, y_farm + 0.2, z_farm, "crab_king_shine", 0.65)
                end
            end
        end
    end
    inst.reducestresstask = inst:DoTaskInTime(200 + 40 * math.random(), ReduceStressAOE)
end

local function HealPlayers(inst)
    local targets = {}
    local x, y, z = inst.Transform:GetWorldPosition()
    for i, v in ipairs(AllPlayers) do
        if not (v.components.health:IsDead() or v:HasTag("playerghost")) and
            v.entity:IsVisible() and
            v:GetDistanceSqToPoint(x, y, z) < 64 then
                if v.components.health:IsHurt() and not v:HasTag("health_as_oldage") then -- Wanda tag.
                table.insert(targets, v)
            end
        end
    end

    for i, v in ipairs(targets) do
        local amt = (TUNING.HEALING_MED/2) - math.min(8, #targets) + 1
        v.components.health:DoDelta(amt, nil, inst.prefab)
        if v.prefab == "wormwood" then
            v.components.health:DoDelta(amt, nil, inst.prefab)
        end
        local _x,_y,_z = v.Transform:GetWorldPosition()
        SpawnFX(_x,_y,_z, "spider_heal_target_fx", 1)
    end
end

local function ShadowProtection(inst)
    local x, y, z = inst.Transform:GetWorldPosition()

    for i, v in ipairs(AllPlayers) do
        if not (v.components.health:IsDead() or v:HasTag("playerghost")) and v.entity:IsVisible() and v:GetDistanceSqToPoint(x, y, z) < 16 then
            if v.components.debuffable ~= nil and v.components.debuffable:IsEnabled() then
                v.components.debuffable:AddDebuff("buff_shadowprotect", "buff_shadowprotect")
            end
        end
    end
end

local function AddBuffForPlayer(inst, player)
    if player.components.debuffable ~= nil and player.components.debuffable:IsEnabled() then
        player.components.debuffable:AddDebuff("buff_shadowprotect", "buff_shadowprotect")
    end
end


local function ontimer(inst, data)
    if data.name == "extinguish" then
        inst:DoTaskInTime(0, inst.Remove)
        local flower = SpawnPrefab(inst.prefab.."_b")
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
local function Spawnfx(inst)
    if not inst.entity:IsVisible() then
        return
    end

    local x, y, z = inst.Transform:GetWorldPosition()
    if TheWorld.Map:GetPlatformAtPoint(x, z) ~= nil then
        return
    end

    local map = TheWorld.Map
    local pt = Vector3(0, 0, 0)
    local offset = FindValidPositionByFan( math.random() * 2 * PI, GetRandomMinMax(PLANTS_RANGE_MIN, PLANTS_RANGE), 3,
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

        table.insert(inst.fxs, plant)

        if #inst.fxs <= MAX_PLANTS then
            inst.fxtask = inst:DoTaskInTime(0.33, Spawnfx)
        else
            if inst.fxtask ~= nil then
                inst.fxtask:Cancel()
                inst.fxtask = nil
            end
        end
    end
end

local function OnChop(inst, chopper)
    if not (chopper ~= nil and chopper:HasTag("playerghost")) then
        inst.SoundEmitter:PlaySound( chopper ~= nil and chopper:HasTag("beaver") and
            "dontstarve/characters/woodie/beaver_chop_tree" or
            "dontstarve/wilson/use_axe_tree" )
    end

    inst.AnimState:PlayAnimation("hit")
    inst.AnimState:PushAnimation("idle")
end

local function OnAnimOver(inst)
    if inst.AnimState:IsCurrentAnimation("idle") then
        inst.fxtask = inst:DoTaskInTime(0.33, Spawnfx)
    end
end

local function onloadpostpass(inst, newents, savedata)
    inst.AnimState:SetTime(math.random() * inst.AnimState:GetCurrentAnimationLength())
end

local function OnRemoveEntity(inst)
    if not IsTableEmpty(inst.fxs) then
        for _,fx in pairs(inst.fxs) do
            fx:fade()
        end
    end
end


local function common(name, scml)
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeObstaclePhysics(inst, .6)

    inst._ismastersim = TheWorld.ismastersim

    inst.AnimState:SetBank("bramble_core")
    inst.AnimState:SetBuild(scml)

    inst:AddTag(name)
    inst:AddTag("plant")
    inst:AddTag("tree")

    inst.entity:SetPristine()

    if not inst._ismastersim then
        return inst
    end

    MakeMediumBurnable(inst, TUNING.TREE_BURN_TIME*.6)
    MakeMediumPropagator(inst)

    inst:AddComponent("inspectable")

    inst.OnLoadPostPass = onloadpostpass

    return inst
end

local function makeflower(name, anim, tags, colour)
    local assets =
    {
        Asset("ANIM", "anim/"..anim..".zip"),
        Asset("ANIM", "anim/bramble_core.zip"),
    }

    local function fn()
        local inst = common(name, anim)

        inst.entity:AddLight()

        inst.AnimState:PlayAnimation("grow")
        inst.AnimState:PushAnimation("idle")
        inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")

        for k,v in pairs(tags) do
            inst:AddTag(v)
        end
        inst:AddTag("succulent_flower_active")

        inst.Light:SetFalloff(0.7)
        inst.Light:SetIntensity(.5)
        inst.Light:SetRadius(5)
        inst.Light:SetColour(colour.R, colour.G, colour.B)
        inst.Light:Enable(true)

        if not inst._ismastersim then
            return inst
        end

        inst:AddComponent("sanityaura")
        inst.components.sanityaura.aura = TUNING.SANITYAURA_SMALL
        inst.components.sanityaura.fallofffn = aurafallofffn

        inst:AddComponent("timer")
        inst.components.timer:StartTimer("extinguish", TUNING.TOTAL_DAY_TIME*3)
        inst:ListenForEvent("timerdone", ontimer)

        inst:AddComponent("workable")
        inst.components.workable:SetWorkAction(ACTIONS.CHOP)
        inst.components.workable:SetWorkLeft(3)
        inst.components.workable:SetOnWorkCallback(OnChop)
        inst.components.workable:SetOnFinishCallback(function()
            inst.AnimState:PlayAnimation("wither")
            inst.Physics:SetActive(false)
            inst:ListenForEvent("animqueueover", inst.Remove)
        end)

        if name == "succulent_flower_sunset" then
            inst.tendtoplantstask = inst:DoPeriodicTask(5, TendToPlantsAOE, nil, inst)
            inst.reducestresstask = inst:DoTaskInTime(200 + 40 * math.random(), ReduceStressAOE)
		    inst.boostallcrops = inst:DoTaskInTime(200 + 40 * math.random(), BoostAllCrops)
            -- inst.fxtask = inst:DoPeriodicTask(5 * math.random(), function ()
            --     local fx = SpawnPrefab("carnival_sparkle_fx")
            --     fx.entity:SetParent(inst.entity)
            --     fx.Transform:SetScale(0.5+0.5*math.random(),0.5+0.5*math.random(),0.5+0.5*math.random())
            --     fx.Transform:SetPosition(1*math.random() - 1*math.random(),1*math.random() - 1*math.random(),1*math.random() - 1*math.random())
            -- end)
        else
            inst.healtask = inst:DoPeriodicTask(20, HealPlayers)
            inst.cooltask = inst:DoPeriodicTask(2, SmotherSmolder)
            -- if TheWorld:HasTag("cave") then
            --     inst.protecttask = inst:DoPeriodicTask(5, ShadowProtection)
            --     inst:AddComponent("playerprox")
            --     inst.components.playerprox:SetDist(4, 6)
            --     inst.components.playerprox:SetOnPlayerNear(AddBuffForPlayer)
            -- end
            inst.fxs = {}
            inst:ListenForEvent("animover", OnAnimOver)
            inst.OnRemoveEntity = OnRemoveEntity
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
        inst:AddTag("succulent_flower_inactive")

        if not inst._ismastersim then
            return inst
        end

        inst:AddComponent("workable")
        inst.components.workable:SetWorkAction(ACTIONS.DIG)
        inst.components.workable:SetWorkLeft(1)
        inst.components.workable:SetOnFinishCallback(function()
            inst.AnimState:PlayAnimation("wither")
            inst.Physics:SetActive(false)
            inst:ListenForEvent("animqueueover", inst.Remove)
        end)
        return inst
    end

    return Prefab(name, fn, assets, prefabs)
end

return makeflower("succulent_flower_dawn", "flower_spring", {}, spring_colour),
    makeflower("succulent_flower_sunset", "flower_autumn", {}, autumn_coulour),
    makedeadflower("succulent_flower_dawn_b", "flower_spring"),
    makedeadflower("succulent_flower_sunset_b", "flower_autumn")
