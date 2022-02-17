
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

local function knowflower(inst)
    return TheWorld.state.isautumn and SpawnPrefab("succulent_flower_dawn") or (TheWorld.state.isspring and SpawnPrefab("succulent_flower_sunset") or nil)
end

local function createflower(staff, target, pos)
    local flower = knowflower(staff)

    if flower == nil then
        return
    end

    flower.Transform:SetPosition(pos:Get())
    staff.components.finiteuses:Use(1)

    local caster = staff.components.inventoryitem.owner
    if caster ~= nil and caster.components.sanity ~= nil then
        caster.components.sanity:DoDelta(-TUNING.SANITY_MED) -- 15
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

local function OnSeasonChanged(inst, season)
    if season == SEASONS.SPRING or season == SEASONS.AUTUMN then
        inst.components.spellcaster.canuseonpoint = true
    else
        inst.components.spellcaster.canuseonpoint = false
    end
end

local function OnLoad(inst)
    if TheWorld.state.isspring or TheWorld.state.isautumn then
        inst.components.spellcaster.canuseonpoint = true
    else
        inst.components.spellcaster.canuseonpoint = false
    end
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

    inst:WatchWorldState("season", OnSeasonChanged)
    MakeHauntableLaunch(inst)

    inst.OnLoad = OnLoad

    return inst
end

return Prefab("emeraldstaff", fn, assets, prefabs)