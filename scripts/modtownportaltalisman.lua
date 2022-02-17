
local function killtask(inst)
    if inst.damagetask ~= nil then
        inst.damagetask:Cancel()
        inst.damagetask = nil
    end
end

local NO_HARM_TAGS =
{
    "player",
	"companion",
    "no_townportaltalisman_damage",
}

local function immune(inst)
    for _,tag in pairs(NO_HARM_TAGS) do
        if inst:HasTag(tag) then
            return true
        end
    end
end

local function HarmOwner(inst)
    local owner = inst.components.inventoryitem:GetGrandOwner()
    if owner and owner.components.health ~= nil then
        if immune(owner) then
            killtask(inst)
        else
            local amt = inst.components.stackable:StackSize()
            owner.components.health:DoDelta(-50*amt, nil, inst.prefab)
            inst.damagetask = inst:DoTaskInTime(1, HarmOwner)
        end
    end
end

local function OnLinkTownPortals(inst, other)
    if other ~= nil then
        inst.damagetask = inst:DoTaskInTime(1, HarmOwner)
    else
        killtask(inst)
    end
end




local function OnStartTeleporting(inst, doer)
    if doer:HasTag("player") then
        if doer.components.talker ~= nil then
            doer.components.talker:ShutUp()
        end
        if not doer:HasTag("buff_safeteleport") then
            if doer.components.sanity ~= nil then
                doer.components.sanity:DoDelta(-TUNING.SANITY_HUGE)
            end
        end
    end

    inst.components.stackable:Get():Remove()
end

local function SetTownPortaltalisman(inst)
    if TheWorld.ismastersim then
        inst.components.teleporter.onActivate = OnStartTeleporting

        inst:ListenForEvent("linktownportals", OnLinkTownPortals)
    end
end


AddPrefabPostInit("townportaltalisman",SetTownPortaltalisman)


