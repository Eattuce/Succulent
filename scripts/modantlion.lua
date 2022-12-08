
-- antlion refers to inst

-- x2
AddPrefabPostInit("antlion", function(antlion)
    if not TheWorld.ismastersim then
        return antlion
    end

    local _GiveReward = antlion.GiveReward

    local function ExtraReward(inst)
        if inst.pendingrewarditem ~= nil and inst.pendingrewarditem == "townportaltalisman" then
            LaunchAt(SpawnPrefab(inst.pendingrewarditem), inst, (inst.tributer ~= nil and inst.tributer:IsValid()) and inst.tributer or nil, 1, 2, 1)
        end
        return _GiveReward(inst)
    end

    antlion.GiveReward = ExtraReward
end)
