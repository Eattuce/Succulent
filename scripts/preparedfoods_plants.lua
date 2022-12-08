require("constants")

local function rockfn(inst, eater)
    local x, y, z = (eater ~= nil and eater or inst).Transform:GetWorldPosition()
    local refund = SpawnPrefab("townportaltalisman")

    if eater ~= nil and eater.components.inventory ~= nil --[[and not eater:HasTag("bat") and not eater:HasTag("mossling")]] then
        eater.components.inventory:GiveItem(refund, nil, Vector3(x, y, z))
    elseif eater.components.health and eater.components.lootdropper ~= nil then
        eater.components.lootdropper:AddChanceLoot("townportaltalisman", 1)
        eater.components.health:DoDelta(-525, nil, inst.prefab)
    end

    if eater:HasTag("player") then
        if eater.components.debuffable ~= nil and eater.components.debuffable:IsEnabled() then
            if not (eater.components.health ~= nil and eater.components.health:IsDead()) then
                eater.components.debuffable:AddDebuff("buff_safeteleport", "buff_safeteleport")
            end
        end
    end
end

local function GetDescription(food, viewer)
    local hunger = viewer.components.hunger:GetPercent()
    local sanity = viewer.components.sanity and viewer.components.sanity:GetPercent() or 1
    local health = viewer.components.oldager ~= nil and 1 or viewer.components.health:GetPercent()
    local modifier
    local s = STRINGS.CHARACTERS.GENERIC.DESCRIBE.PPF_SUCCULENTJELLY
    if sanity <= hunger and sanity <= health then
        modifier = "SAN"
    elseif health <= hunger and health <= sanity then
        modifier = "HEA"
    else
        modifier = "HUN"
    end
    return string.format(s["HELPER"], s[modifier])
end

local preparedfoods =
{
    ppf_succulentjelly = -- 平凡果冻
    {
        test = function(cooker, names, tags)
            return (names.succulent_picked and names.succulent_picked == 3)
            and ((names.phlegm and names.phlegm == 1)
                -- or (names.slurtleslime and names.slurtleslime == 1)
                or (names.glommerfuel and names.glommerfuel == 1))
        end,
        priority = 30,
        foodtype = FOODTYPE.GOODIES,
        health = TUNING.HEALING_TINY, --1
        hunger = TUNING.SANITY_SUPERTINY, --1
        sanity = TUNING.SANITY_SUPERTINY, --1
        perishtime = TUNING.PERISH_SUPERSLOW, --40天
        cooktime = 2.5,
        potlevel = "low",
        floater = {"small", 0, 1},

        tags = {"succulentfood"},

        oneat_desc = STRINGS.UI.COOKBOOK.PPF_SUCCULENTJELLY,
        oneatenfn = function(inst, eater)   -- 角色低百分比的吃下去时会有额外回复属性
            if eater:HasTag("player") and eater.components.sanity ~= nil and eater.components.health ~= nil then
                local sanity_percent = eater.components.sanity:GetPercent() or 1
                local health_percent = eater.components.oldager and 1 or eater.components.health:GetPercent()
                local hunger_percent = eater.components.hunger:GetPercent() or 1

				if sanity_percent and (sanity_percent <= health_percent) and (sanity_percent <= hunger_percent) then -- 精神最低
                    eater.components.sanity:DoDelta(TUNING.SANITY_HUGE)   -- 加50精神
                    if eater.components.talker then
                        eater.components.talker:Say(GetString(eater, "DESCRIBE", { "PPF_SUCCULENTJELLY", "SANITY" }))
                    end
                elseif eater.components.oldager == nil and health_percent and (health_percent <= sanity_percent) and (health_percent <= hunger_percent) then  -- 血最低
                    eater.components.health:DoDelta(TUNING.HEALING_HUGE, nil, inst.prefab) -- 加60血
                    if eater.components.talker then
                        eater.components.talker:Say(GetString(eater, "DESCRIBE", { "PPF_SUCCULENTJELLY", "HEALTH" }))
                    end
                elseif hunger_percent and (hunger_percent <= sanity_percent) and (hunger_percent <= health_percent) then  -- 饥饿最低
                    eater.components.hunger:DoDelta(TUNING.CALORIES_HUGE)  -- 加75饱食
                    if eater.components.talker then
                        eater.components.talker:Say(GetString(eater, "DESCRIBE", { "PPF_SUCCULENTJELLY", "HUNGER" }))
                    end
                end
            end
        end,
        -- master_init = function (inst)
        --     inst.components.inspectable.getspecialdescription = GetDescription
        -- end,

    },

    ppf_succulentjuice =  -- 祛炎饮料
    {
        test = function (cooker, names, tags)
            return (names.succulent_picked and names.succulent_picked >= 2) and tags.frozen
             and not tags.meat and not tags.egg and not tags.fish and not names.twigs
        end,
        priority = 20,
        foodtype = FOODTYPE.GOODIES,
        health = TUNING.HEALING_SMALL, --3
        hunger = 0, -- TUNING.CALORIES_SMALL, --12.5
        sanity = TUNING.SANITY_TINY, --5
        perishtime = TUNING.PERISH_FAST, --6天
        cooktime = 1,
        potlevel = "low",
        floater = {"small", 0, 0.8},

        oneat_desc = STRINGS.UI.COOKBOOK.PPF_SUCCULENTJUICE,
        temperature = TUNING.COLD_FOOD_BONUS_TEMP,
		temperatureduration = TUNING.TOTAL_DAY_TIME/4,

        tags = {"succulentfood"},

        oneatenfn = function (inst, eater)
            local Temp = eater.components.temperature
            if Temp ~= nil then
                local currenttemp = Temp:GetCurrent()
                if currenttemp == nil then
                    return
                end
                if TheWorld.state.issummer and currenttemp > 12 then  -- 夏天
                    Temp:SetTemperature(12) -- 降温
                    if eater.components.talker ~= nil then
                        eater.components.talker:Say(GetString(eater, "DESCRIBE", { "PPF_SUCCULENTJUICE", "COOL" }))
                    end
                else
                    Temp:SetTemperature(-1) -- 过冷
                    if eater.components.talker ~= nil then
                        eater.components.talker:Say(GetString(eater, "DESCRIBE", { "PPF_SUCCULENTJUICE", "COLD" }))
                    end
                end
            end
        end,
    },

    ppf_greentongue =  -- 绿舌头
    {
        test = function (cooker, names, tags)
            return names.succulent_picked and names.twigs and tags.frozen and not tags.meat and not tags.egg and not tags.fish
        end,
        priority = 20,
        foodtype = FOODTYPE.GOODIES,
        health = 0,
        hunger = TUNING.CALORIES_TINY/2, -- 9.4/2
        sanity = TUNING.SANITY_MED, -- 15
        perishtime = TUNING.PERISH_FAST, -- 6天
        cooktime = 0.75,
        potlevel = "low",
        floater = { "small", 0.2, 0.8},

        oneat_desc = STRINGS.UI.COOKBOOK.PPF_GREENTONGUE,

        tags = {"succulentfood"},

        common_postinit = function (inst) inst:AddTag("frozen") end,
        master_init = function (inst) inst.components.edible.degrades_with_spoilage = false end,
    },

    ppf_pomegranate = --石榴汤
    {
        test = function (cooker, names, tags)
            return names.succulent_picked and names.townportaltalisman and names.pomegranate and not tags.meat and not tags.egg and not tags.fish
        end,
        priority = 20,
        foodtype = FOODTYPE.GOODIES,
        secondaryfoodtype = FOODTYPE.VEGGIE,
        health = TUNING.HEALING_MEDSMALL, --8
        hunger = TUNING.CALORIES_SMALL*5, --75-12.5=62.5
        sanity = 0,
        perishtime = TUNING.PERISH_SLOW, --15天
        cooktime = 2,
        potlevel = "low",
        floater = {"small", 0.2, 1},

        oneat_desc = STRINGS.UI.COOKBOOK.PPF_POMEGRANATE,

        tags = {"succulentfood"},

        prefabs = { "buff_safeteleport" },
        oneatenfn = rockfn
    },
}

preparedfoods.ppf_durian = deepcopy(preparedfoods.ppf_pomegranate)
preparedfoods.ppf_durian.test = function (cooker, names, tags)
    return names.succulent_picked and names.townportaltalisman and names.durian and not tags.meat and not tags.egg and not tags.fish
end

preparedfoods.ppf_watermelon = deepcopy(preparedfoods.ppf_pomegranate)
preparedfoods.ppf_watermelon.test = function (cooker, names, tags)
    return names.succulent_picked and names.townportaltalisman and names.watermelon and not tags.meat and not tags.egg and not tags.fish
end

preparedfoods.ppf_dragonfruit = deepcopy(preparedfoods.ppf_pomegranate)
preparedfoods.ppf_dragonfruit.test = function (cooker, names, tags)
    return names.succulent_picked and names.townportaltalisman and names.dragonfruit and not tags.meat and not tags.egg and not tags.fish
end

for k,v in pairs(preparedfoods) do
    v.name = k
    v.weight = v.weight or 1
    v.priority = v.priority or 0
end

return preparedfoods
