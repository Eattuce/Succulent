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

local foods_plants =
{
    ppf_succulentjelly = --平凡果冻
    {
        test = function(cooker, names, tags)
            return (names.succulent_picked and names.succulent_picked == 3)
            and ((names.phlegm and names.phlegm == 1)
                or (names.slurtleslime and names.slurtleslime == 1)
                or (names.glommerfuel and names.glommerfuel == 1))
        end,
        priority = 20,
        foodtype = FOODTYPE.GOODIES,
        health = TUNING.HEALING_TINY, --1
        hunger = TUNING.SANITY_SUPERTINY, --1
        sanity = TUNING.SANITY_SUPERTINY, --1
        perishtime = TUNING.PERISH_SUPERSLOW, --40天
        cooktime = 2.5,
        potlevel = "low",
        float = {nil, "small", 0.2, 1.05},

        tags = {"succulentfood"},

        cook_need = "多肉植物x3 格罗姆粘液x1",
        cook_cant = nil,
        recipe_count = 4,

        oneat_desc = STRINGS.UI.COOKBOOK.PPF_SUCCULENTJELLY,
        oneatenfn = function(inst, eater)   --角色低百分比的吃下去时会有额外回复属性
            if eater:HasTag("player") then
                local Health = eater.components.health
                local Hunger = eater.components.hunger
                local Sanity = eater.components.sanity

				local Healthrate = (Health.currenthealth - 1)/Health.maxhealth
				local Hungerrate = (Hunger.current - 1)/Hunger.max
				local Sanityrate = (Sanity.current - 1)/Sanity.max
                --吃之前百分比低的，增加回复
				if Sanity ~= nil and (Sanityrate <= Healthrate) and (Sanityrate <= Hungerrate) then --精神最低
                    Sanity:DoDelta(TUNING.SANITY_HUGE)   --加50精神
                    if eater.components.talker ~= nil then
                        eater.components.talker:Say(GetString(eater, "DESCRIBE", { "PPF_SUCCULENTJELLY", "SANITY" }))
                    end
                elseif Health ~= nil and (Healthrate <= Sanityrate) and (Healthrate <= Hungerrate) then  --血最低
                    Health:DoDelta(TUNING.HEALING_HUGE, nil, inst.prefab) --加60血
                    if eater.components.talker ~= nil then
                        eater.components.talker:Say(GetString(eater, "DESCRIBE", { "PPF_SUCCULENTJELLY", "HEALTH" }))
                    end
                elseif Hunger ~= nil and (Hungerrate <= Sanityrate) and (Hungerrate <= Healthrate) then  --饥饿最低
                    Hunger:DoDelta(TUNING.CALORIES_HUGE)  --加75饱食
                    if eater.components.talker ~= nil then
                        eater.components.talker:Say(GetString(eater, "DESCRIBE", { "PPF_SUCCULENTJELLY", "HUNGER" }))
                    end
                end
            end
        end,
    },

    ppf_succulentjuice =  --祛炎饮料
    {
        test = function (cooker, names, tags)
            return (names.succulent_picked and names.succulent_picked >= 2) and tags.frozen
             and not tags.meat and not tags.egg and not tags.inedible
        end,
        priority = 20,
        foodtype = FOODTYPE.VEGGIE,
        health = TUNING.HEALING_SMALL, --3
        hunger = 0, -- TUNING.CALORIES_SMALL, --12.5
        sanity = TUNING.SANITY_TINY, --5
        perishtime = TUNING.PERISH_FAST, --6天
        cooktime = 1,
        potlevel = "low",
        float = {nil, "small", 0.2, 1},
        cook_need = "",
        cook_cant = "",
        recipe_count = 6,
        oneaten_desc = STRINGS.UI.COOKBOOK.PPF_SUCCULENTJUICE,
        temperature = TUNING.COLD_FOOD_BONUS_TEMP,
		temperatureduration = TUNING.TOTAL_DAY_TIME/4,

        tags = {"succulentfood"},


        oneatenfn = function (inst, eater)
            local Temp = eater.components.temperature
            -- local Sanity = eater.components.sanity
            if Temp ~= nil then
                local currenttemp = Temp:GetCurrent()
                if currenttemp == nil then
                    return
                end
                if TheWorld.state.issummer and currenttemp > 12 then  --夏天吃如果温度高于12度
                    -- Sanity:DoDelta(10) --加10脑残
                    Temp:SetTemperature(12) --降温
                    if eater.components.talker ~= nil then
                        eater.components.talker:Say(GetString(eater, "DESCRIBE", { "PPF_SUCCULENTJUICE", "COOL" }))
                    end
                else --不是夏天
                --     Sanity:DoDelta(-10) --减脑残
                    Temp:SetTemperature(-1) --过冷
                    if eater.components.talker ~= nil then
                        eater.components.talker:Say(GetString(eater, "DESCRIBE", { "PPF_SUCCULENTJUICE", "COLD" }))
                    end
                end
            end
        end,
    },

    ppf_greentongue =  --绿舌头
    {
        test = function (cooker, names, tags)
            return (names.succulent_picked and names.succulent_picked >= 1)
             and (names.twigs and names.twigs >= 1) and (tags.frozen and tags.frozen >= 1)
            and not (tags.meat) and not (tags.egg)
        end,
        priority = 20,
        foodtype = FOODTYPE.VEGGIE,
        health = 0,
        hunger = TUNING.CALORIES_TINY/2, --9.4/2
        sanity = TUNING.SANITY_MED, --15
        perishtime = TUNING.PERISH_FAST, --6天
        cooktime = 0.75,
        potlevel = "low",
        float = {nil, "small", 0.2, 1},
        cook_need = "",
        cook_cant = "",
        recipe_count = 6,
        oneaten_desc = STRINGS.UI.COOKBOOK.PPF_GREENTONGUE,

        tags = {"succulentfood"},


		-- temperature = TUNING.COLD_FOOD_BONUS_TEMP,
		-- temperatureduration = TUNING.FOOD_TEMP_AVERAGE,

        -- oneatenfn = function(inst, eater)   --食用25%概率产生多肉植物
        --     local Pos = eater:GetPosition()
        --     local Plant = nil

        --     if math.random() <= 0.25 then
        --         Plant = SpawnPrefab("succulent_plant")
        --     end

        --     if Plant ~= nil and Pos ~= nil then
        --         Plant.Transform:SetPosition(Pos:Get())
        --         Plant.planted = true
        --     end
        -- end,
    },

    ppf_pomegranate = --石榴汤
    {
        test = function (cooker, names, tags)
            return names.succulent_picked and names.townportaltalisman and not tags.meat and not tags.egg and names.pomegranate
        end,
        priority = 20,
        foodtype = FOODTYPE.VEGGIE,
        secondaryfoodtype = FOODTYPE.GOODIES,
        health = TUNING.HEALING_MEDSMALL, --8
        hunger = TUNING.CALORIES_SMALL*5, --75-12.5=62.5
        sanity = 0,
        perishtime = TUNING.PERISH_SLOW, --15天
        cooktime = 2,
        potlevel = "low",
        float = {nil, "small", 0.2, 1},
        cook_need = "",
        cook_cant = "",
        recipe_count = 6,
        oneaten_desc = STRINGS.UI.COOKBOOK.PPF_POMEGRANATE,

        tags = {"succulentfood"},


        prefabs = { "buff_safeteleport" },
        oneatenfn = rockfn
    },

    ppf_durian = --榴莲汤
    {
        test = function (cooker, names, tags)
            return names.succulent_picked and names.townportaltalisman and not tags.meat and not tags.egg and names.durian
        end,
        priority = 20,
        foodtype = FOODTYPE.VEGGIE,
        secondaryfoodtype = FOODTYPE.GOODIES,
        health = TUNING.HEALING_MEDSMALL, --8
        hunger = TUNING.CALORIES_SMALL*5, --75-12.5=62.5
        sanity = 0,
        perishtime = TUNING.PERISH_SLOW, --15天
        cooktime = 2,
        potlevel = "low",
        float = {nil, "small", 0.2, 1},
        cook_need = "",
        cook_cant = "",
        recipe_count = 6,
        oneaten_desc = STRINGS.UI.COOKBOOK.PPF_DURIAN,

        tags = {"succulentfood"},


        prefabs = { "buff_safeteleport" },
        oneatenfn = rockfn
    },

    ppf_watermelon = --西瓜汤
    {
        test = function (cooker, names, tags)
            return names.succulent_picked and names.townportaltalisman and not tags.meat and not tags.egg and names.watermelon
        end,
        priority = 20,
        foodtype = FOODTYPE.VEGGIE,
        secondaryfoodtype = FOODTYPE.GOODIES,
        health = TUNING.HEALING_MEDSMALL, --8
        hunger = TUNING.CALORIES_SMALL*5, --75-12.5=62.5
        sanity = 0,
        perishtime = TUNING.PERISH_SLOW, --15天
        cooktime = 2,
        potlevel = "low",
        float = {nil, "small", 0.2, 1},
        cook_need = "",
        cook_cant = "",
        recipe_count = 6,
        oneaten_desc = STRINGS.UI.COOKBOOK.PPF_WATERMELON,

        prefabs = { "buff_safeteleport" },
        oneatenfn = rockfn
    },

    ppf_dragonfruit = --火龙果汤
    {
        test = function (cooker, names, tags)
            return names.succulent_picked and names.townportaltalisman and not tags.meat and not tags.egg and names.dragonfruit
        end,
        priority = 20,
        foodtype = FOODTYPE.VEGGIE,
        secondaryfoodtype = FOODTYPE.GOODIES,
        health = TUNING.HEALING_MEDSMALL, --8
        hunger = TUNING.CALORIES_SMALL*5, --75-12.5=62.5
        sanity = 0,
        perishtime = TUNING.PERISH_SLOW, --15天
        cooktime = 2,
        potlevel = "low",
        float = {nil, "small", 0.2, 1},
        cook_need = "",
        cook_cant = "",
        recipe_count = 6,
        oneaten_desc = STRINGS.UI.COOKBOOK.PPF_DRAGONFRUIT,

        tags = {"succulentfood"},


        prefabs = { "buff_safeteleport" },
        oneatenfn = rockfn
    },

}

for k,v in pairs(foods_plants) do
    v.name = k
    v.weight = v.weight or 1
    v.priority = v.priority or 0
end

return foods_plants
