local MakePlayerCharacter = require "prefabs/player_common"

local assets =
{
    Asset("SCRIPT", "scripts/prefabs/player_common.lua"),
}

TUNING.WHITNEY_HEALTH = 150
TUNING.WHITNEY_HUNGER = 150
TUNING.WHITNEY_SANITY = 175

local whitney_items =
{
	"emeraldamulet",
}

TUNING.GAMEMODE_STARTING_ITEMS.DEFAULT.WHITNEY = whitney_items

local start_inv = {}
for k, v in pairs(TUNING.GAMEMODE_STARTING_ITEMS) do
    start_inv[string.lower(k)] = v.WHITNEY
end
local prefabs = FlattenTree(start_inv, true)

-- When the character is revived from human
local function onbecamehuman(inst)
	-- Set speed when not a ghost (optional)
	inst.components.locomotor:SetExternalSpeedMultiplier(inst, "whitney_speed_mod", 1)
end

local function onbecameghost(inst)
	-- Remove speed modifier when becoming a ghost
   inst.components.locomotor:RemoveExternalSpeedMultiplier(inst, "whitney_speed_mod")
end

-- When loading or spawning the character
local function onload(inst)
    inst:ListenForEvent("ms_respawnedfromghost", onbecamehuman)
    inst:ListenForEvent("ms_becameghost", onbecameghost)

    if inst:HasTag("playerghost") then
        onbecameghost(inst)
    else
        onbecamehuman(inst)
    end
end

local function SucculentPreserverRate(inst, item)
	return (item ~= nil and item.prefab == "succulent_picked") and 1/3
		or (item ~= nil and item:HasTag("succulentfood") and 2/3 or nil)
end

local function WhitneyEatModify(inst, health_delta, hunger_delta, sanity_delta, food, feeder)
	if food ~= nil and food.prefab == "succulent_picked" then
		hunger_delta = hunger_delta+TUNING.CALORIES_TINY
	end
	return health_delta, hunger_delta, sanity_delta
end

------------------------------------------------------------------------
------------------------------------------------------------------------
local function KillOffSnares(inst)
	local snares = inst.snares
	if snares ~= nil then
		inst.snares = nil

		for _, v in ipairs(snares) do
			if v:IsValid() then
				v.owner = nil
				v:KillOff()
			end
		end
	end
end

local function onsnaredeath(snare)
	local inst = (snare.owner ~= nil and snare.owner:IsValid()) and snare.owner or nil
	if inst ~= nil then
		KillOffSnares(inst)
	end
end

local function dosnaredamage(inst, target)
	if target:IsValid() and target.components.health ~= nil and not target.components.health:IsDead() and target.components.combat ~= nil then
		target.components.combat:GetAttacked(inst, TUNING.WEED_IVY_SNARE_DAMAGE)
		-- target:PushEvent("snared", { attacker = inst, announce = "ANNOUNCE_SNARED_IVY" })
	end
end

local function SpawnSnare(inst, x, z, r, num, target)
    local count = 0
    local dtheta = PI * 2 / num
    local thetaoffset = math.random() * PI * 2
    local delaytoggle = 0
    local map = TheWorld.Map
    for theta = math.random() * dtheta, PI * 2, dtheta do
        local x1 = x + r * math.cos(theta)
        local z1 = z + r * math.sin(theta)
        if map:IsPassableAtPoint(x1, 0, z1, false, true) and not map:IsPointNearHole(Vector3(x1, 0, z1)) then
            local snare = SpawnPrefab("snare_whit")
            snare.Transform:SetPosition(x1, 0, z1)

            local delay = delaytoggle == 0 and 0 or .2 + delaytoggle * math.random() * .2
            delaytoggle = delaytoggle == 1 and -1 or 1

			snare.owner = inst
			snare.target = target
			snare.target_max_dist = r + 1.0
            snare:RestartSnare(delay)

			table.insert(inst.snares, snare)
			inst:ListenForEvent("death", onsnaredeath, snare)
            count = count + 1
        end
    end

	-- if count > 0 then
	-- 	inst:DoTaskInTime(0.25, dosnaredamage, target)
	-- end
	return count > 0
end

local function dosnares(inst, target)
	if target ~= nil and target:IsValid() and not target:HasTag("plantkin") then
		if inst.snares ~= nil and #inst.snares > 0 then
			for _, snare in ipairs(inst.snares) do
				if snare:IsValid() and snare.components.health ~= nil and not snare.components.health:IsDead() then
					snare.components.health:Kill()
				end
			end
		end
		inst.snares = {}

        local x, y, z = target.Transform:GetWorldPosition()
        local islarge = target:HasTag("largecreature")
        local r = target:GetPhysicsRadius(0) + (islarge and .8 or .4)
        local num = islarge and 12 or 6
		if SpawnSnare(inst, x, z, r, num, target) then
			target:AddTag("trapped_by_whitney")
		end
	end
end
------------------------------------------------------------------------
------------------------------------------------------------------------

-------------------------------------
local function MakeWhitneypoisonableCharacter(inst)
    inst:AddComponent("whitneypoison")
    -- inst:AddTag("whitneypoison")
end


local IMMUNE_TAGS =
{
	"chess",
	"immune_plantvex",
	"companion",
	"shadowchesspiece",
	"shadowcreature",
	"player",
	"structure",
	"butterfly",
	"wall",
}

local function immune(inst)
	for _,v in pairs(IMMUNE_TAGS) do
		if inst:HasTag(v) then
			return true
		end
	end
	return false
end

local function onhitother(inst,data)
	if not inst.components.inventory:EquipHasTag("whitneypoison_item") then
		return
	end

	-- local amulet = {}
	-- for k, v in pairs(inst.components.inventory.equipslots) do
    --     if v:HasTag("whitneypoison_item") then
    --         table.insert(amulet, v)
    --     end
    -- end

	if data and data.target then
		local target = data.target
		if immune(target) then
			return
		end

		-- if target:HasTag("trapped_by_whitney") then
		-- 	return
		-- end
		-- dosnares(inst, target)


		if target.components.combat and target.components.health then
			if target.components.whitneypoison == nil then
				if TheWorld.ismastersim then
					MakeWhitneypoisonableCharacter(target)
				end
			end

			if target.components.whitneypoison then
				target.components.whitneypoison:Poison()
				-- inst:PushEvent("whitney_poison", {amulet = amulet})
				-- print("pushed")
			end

			target.components.combat:SuggestTarget(inst)
		end
	end
end
-------------------------------------

local function WhitneyCombatDamage(inst, target)
	return inst.components.inventory:EquipHasTag("whitneypoison_item") and 1 or 0.75
end



--------------------------------------------------------------------------

local common_postinit = function(inst)
	inst:AddTag("oasisenvoy")
	-- inst:AddTag("sandstormimmune")

	inst.MiniMapEntity:SetIcon( "whitney.tex" )
end

--------------------------------------------------------------------------

-- local function heard(inst, data)
-- 	if data then
-- 		inst.components.talker:Say("123")
-- 	end
-- end
local master_postinit = function(inst)

	inst.starting_inventory = start_inv[TheNet:GetServerGameMode()] or start_inv.default

	inst.components.health:SetMaxHealth(TUNING.WHITNEY_HEALTH)
	inst.components.hunger:SetMax(TUNING.WHITNEY_HUNGER)
	inst.components.sanity:SetMax(TUNING.WHITNEY_SANITY)

	inst.components.hunger.hungerrate = 1 * TUNING.WILSON_HUNGER_RATE

	inst.soundsname = "wendy"
	-- Uncomment if "wathgrithr"(Wigfrid) or "webber" voice is used
    -- inst.talker_path_override = "dontstarve_DLC001/characters/"
--------------------------------------------------------------------------

	-- FoodAffinity(hunger)
	inst.components.foodaffinity:AddPrefabAffinity("watermelonicle", TUNING.AFFINITY_15_CALORIES_SMALL)

	-- Eater
	-- inst.components.eater.custom_stats_mod_fn = WhitneyEatModify

	-- Itemaffinity(sanity)
	-- AddAffinity(prefab, tag, sanity_bonus, priority)
	inst:AddComponent("itemaffinity")
    inst.components.itemaffinity:AddAffinity("succulent_picked", nil, TUNING.DAPPERNESS_SMALL, 1)
    inst.components.itemaffinity:AddAffinity(nil, "succulentfood", TUNING.DAPPERNESS_MED, 1)

	-- Sanity
	inst.components.sanity:AddSanityAuraImmunity("ghost")
    inst.components.sanity:SetPlayerGhostImmunity(true)

	-- Preserver
	inst:AddComponent("preserver")
	inst.components.preserver:SetPerishRateMultiplier(SucculentPreserverRate)

	-- Comabt
	inst.components.combat.damagemultiplier = 1
	inst.components.combat.customdamagemultfn = WhitneyCombatDamage

	--------------------------------------------------------------------------

	-- inst.components.sandstormwatcher:SetSandstormSpeedMultiplier(1)

	-- Builder
	if inst.components.builder then
		for _,name in pairs({
			"dewdrop",
			"succulent_medpot",
			"succulent_largepot",
			"succulent_farm",
			"emeraldgem",
			"essence",
			"emeraldstaff",
			"emeraldamulet",
		}) do
			if not inst.components.builder:KnowsRecipe(name) then
				inst.components.builder:UnlockRecipe(name)
			end
		end
	end

	-- EventListeners
	inst:ListenForEvent("onhitother", onhitother)
	-- inst:ListenForEvent("succussabcd123", heard)

	inst.OnLoad = onload
    inst.OnNewSpawn = onload
end

return MakePlayerCharacter("whitney", prefabs, assets, common_postinit, master_postinit)
