
GLOBAL.setmetatable(env, { __index = function(t, k) return GLOBAL.rawget(GLOBAL, k) end })


local seg_time = 30
local total_day_time = 16*seg_time


TUNING.PLANTVEX_IMMUNE_DURATION = 30

TUNING.PLANTVEX_MAXLEVEL = 8

TUNING.PLANTVEX_DURATION = 10
TUNING.PLANTVEX_DAMAGE_PER_INTERVAL = 8
TUNING.PLANTVEX_INTERVAL = 2

TUNING.PLANTVEX_DAMAGE_RAMP =
{
    {level = 0,     damage_scale = 0,       interval_scale = 1.0},
    {level = 1,     damage_scale = 0,       interval_scale = 1.0},
    {level = 2,     damage_scale = 1, 	    interval_scale = 1.0},
    {level = 3,     damage_scale = 1, 	    interval_scale = 1.0},
    {level = 4,     damage_scale = 2,       interval_scale = 0.75},
    {level = 5,     damage_scale = 2, 	    interval_scale = 0.75},
    {level = 6,     damage_scale = 3, 	    interval_scale = 0.5},
    {level = 7,     damage_scale = 3, 	    interval_scale = 0.5},
    {level = 8,     damage_scale = 3, 	    interval_scale = 0.5},
}


local function set(inst, scale)
    inst:AddComponent("whitneypoison")
    if scale then
        inst.components.whitneypoison:SetFXScale(scale,scale,scale)
    end
end

local function offset(inst, off)
    if off then
	    inst.components.whitneypoison:SetFXOffset(off or Vector3(0, 0, 0))
    end
end


local function UsePigmanScale(inst)
    set(inst, 1.3)
end

local pigman = {
    "pigman",
    "pigguard",
    "bunnyman",
    "moonpig",
    "merm",
    "mermguard",
    "hound",
    "firehound",
    "icehound",
    "moonhound",
    "clayhound",
    "mutatedhound",
    -- ""
}

for _,v in pairs(pigman) do
    AddPrefabPostInit(v, function (inst)
        if not TheWorld.ismastersim then
            return inst
        end
        UsePigmanScale(inst)
    end)
end

local function SmallCreature(inst)
    set(inst, 0.4)
end

local bee = {
    "bee",
    "mosquito",
    "killerbee",
}

for _,v in pairs(bee) do
    AddPrefabPostInit(v, function (inst)
        if not TheWorld.ismastersim then
            return inst
        end
        SmallCreature(inst)
    end)
end


local function MediumCreature(inst)
    set(inst, 1.7)
    offset(inst, {x=0,y=-0.1,z=0})
end

local med = {
    "beefalo",
    "koalefant_summer",
    "koalefant_winter",
    "warg",
    "claywarg",
    "gingerbreadwarg",
    "spat",
}

for _,v in pairs(med) do
    AddPrefabPostInit(v, function (inst)
        if not TheWorld.ismastersim then
            return inst
        end
        MediumCreature(inst)
    end)
end

local function EpicCreature(inst)
    set(inst, 2.5)
end

local epic = {
    "bearger",
    "deerclops",
    "dragonfly",
    "beequeen",
    "claus"
}

for _,v in pairs(epic) do
    AddPrefabPostInit(v, function (inst)
        if not TheWorld.ismastersim then
            return inst
        end
        EpicCreature(inst)
    end)
end








AddPrefabPostInit("moose", function (inst)
    if not TheWorld.ismastersim then
        return inst
    end
    set(inst, 1.8)
    offset(inst, {x=0,y=-0.1,z=0})
end)

AddPrefabPostInit("deerclops", function (inst)
    if not TheWorld.ismastersim then
        return inst
    end
    set(inst, 1.2)
    -- offset({x=0,y=-1,z=0})
end)

AddPrefabPostInit("beeguard", function (inst)
    if not TheWorld.ismastersim then
        return inst
    end
    set(inst, 0.5)
end)