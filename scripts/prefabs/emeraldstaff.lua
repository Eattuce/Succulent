
local assets =
{
    Asset("ANIM", "anim/emeraldstaff.zip"),
    Asset("ANIM", "anim/swap_emeraldstaff.zip"),
    Asset("ATLAS", "images/inventoryimages/emeraldstaff.xml"),
    Asset("IMAGE", "images/inventoryimages/emeraldstaff.tex"),
}

local prefabs =
{
    "succulent_flower_sunset",
    "succulent_flower_dawn",
}

local function GetFlower()
    if TUNING.EMERALDSTAFF_USEDAY then
        if TheWorld:HasTag("cave") then
            return "succulent_flower_dawn"
        end

        if TheWorld.state.isday then
            return "succulent_flower_dawn"
        elseif TheWorld.state.isdusk then
            return "succulent_flower_sunset"
        end
    else
        if TheWorld.state.isautumn then
            return "succulent_flower_dawn"
        elseif TheWorld.state.isspring then
            return "succulent_flower_sunset"
        end
    end

    return nil
end

local function createflower(staff, target, pos)
    local f = GetFlower()

    if f ~= nil then
        local flower = SpawnPrefab(f)
        flower.Transform:SetPosition(pos:Get())
        staff.components.finiteuses:Use(1)

        local caster = staff.components.inventoryitem.owner
        if caster ~= nil and caster.components.sanity ~= nil then
            caster.components.sanity:DoDelta(-TUNING.SANITY_MED) -- 15
        end
    end
end

local function onfinished(inst)
    inst.SoundEmitter:PlaySound("dontstarve/common/gem_shatter")
    inst:Remove()
end

local function onunequip(inst, owner)
    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")
end

local function OnPhase(inst, phase)
    if TUNING.EMERALDSTAFF_USEDAY then
        if TheWorld:HasTag("cave") then
            inst.components.spellcaster.canuseonpoint = true
            return
        end
        inst.components.spellcaster.canuseonpoint = not TheWorld.state.isnight
    end
end

local function OnSeasonChange(inst, season)
    if not TUNING.EMERALDSTAFF_USEDAY then
        inst.components.spellcaster.canuseonpoint = TheWorld.state.isspring or TheWorld.state.isautumn
    end
end

local function OnLoad(inst, data)
    if TUNING.EMERALDSTAFF_USEDAY then
        inst.components.spellcaster.canuseonpoint = TheWorld:HasTag("cave") and true or not TheWorld.state.isnight
    else
        inst.components.spellcaster.canuseonpoint = TheWorld.state.isspring or TheWorld.state.isautumn
    end
end

local function OnLongUpdate(inst, dt)
    OnLoad(inst)
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.Transform:SetScale(0.85,0.85,0.85)

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("emeraldstaff")
    inst.AnimState:SetBuild("emeraldstaff")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("nopunch")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    -------
    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetOnFinished(onfinished)

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")

    inst:AddComponent("tradable")

    inst:AddComponent("equippable")

    inst.components.equippable:SetOnEquip(function(inst, owner)
        owner.AnimState:OverrideSymbol("swap_object", "swap_emeraldstaff", "swap_emeraldstaff")
        owner.AnimState:Show("ARM_carry")
        owner.AnimState:Hide("ARM_normal")
        if TUNING.EMERALDSTAFF_USEDAY then
            OnPhase(inst)
        else
            OnSeasonChange(inst)
        end
    end)
    inst.components.equippable:SetOnUnequip(onunequip)

    inst.fxcolour = {100/255, 208/255, 100/255}

    inst.castsound = "dontstarve/common/staffteleport"

    inst:AddComponent("spellcaster")
    inst.components.spellcaster:SetSpellFn(createflower)
    inst.components.spellcaster.canuseonpoint = true
    inst.components.spellcaster.canuseonpoint_water = false

    inst.components.finiteuses:SetMaxUses(TUNING.YELLOWSTAFF_USES/2)
    inst.components.finiteuses:SetUses(TUNING.YELLOWSTAFF_USES/2)

    inst:WatchWorldState("phase", OnPhase)
    inst:WatchWorldState("season", OnSeasonChange)

    MakeHauntableLaunch(inst)

    inst.OnLoad = OnLoad
    inst.OnLongUpdate = OnLongUpdate

    return inst
end

return Prefab("emeraldstaff", fn, assets, prefabs)