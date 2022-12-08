
table.insert(Assets, Asset("ANIM", "anim/crabkinggem.zip"))

-- local data = {slot = socketnum, itemprefab = item.prefab}

local function socket(inst)
    for k,data in pairs(inst.socketed) do
        if data.itemprefab == "emeraldgem" then
            inst.AnimState:OverrideSymbol("gem"..data.slot, "crabkinggem", "gems_emerald")
        end
    end
end


AddPrefabPostInit("crabking", function(inst)

    if not TheWorld.ismastersim then
        return inst
    end

    local _countgems = inst.countgems
    inst.countgems = function (inst)
        local gems = _countgems(inst)
        if gems and inst.socketed then
            for _,data in ipairs(inst.socketed) do
                if data.itemprefab == "emeraldgem" then
                    gems.red = gems.red + 2
                end
            end
        end
        return gems
    end
    inst:ListenForEvent("socket", socket)
end)