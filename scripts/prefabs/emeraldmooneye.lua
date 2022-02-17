local assets =
{
    Asset("ANIM", "anim/emeraldmooneye.zip"),
    Asset("IMAGE", "images/inventoryimages/emeraldmooneye.tex"),
    Asset("ATLAS", "images/inventoryimages/emeraldmooneye.xml")
}

local prefabs =
{
    "ememooneyemapicon",
}

local function Sparkle(inst)
    if not inst.AnimState:IsCurrentAnimation("sparkle") then
        inst.AnimState:PlayAnimation("sparkle")
        inst.AnimState:PushAnimation("idle", false)
    end
    inst:DoTaskInTime(4 + math.random(), Sparkle)
end

local function topocket(inst)
    if inst.icon ~= nil then
        inst.icon:Remove()
        inst.icon = nil
    end
end

local function toground(inst)
    if inst.icon == nil then
        inst.icon = SpawnPrefab("ememooneyemapicon")
        inst.icon:TrackEntity(inst)
    end
end

local function init(inst)
    if not inst.components.inventoryitem:IsHeld() then
        toground(inst)
    end
end

local function fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    inst.MiniMapEntity:SetIcon("minieme.tex")
    inst.MiniMapEntity:SetCanUseCache(false)
    inst.MiniMapEntity:SetDrawOverFogOfWar(true)

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("emeraldmooneye")
    inst.AnimState:SetBuild("emeraldmooneye")
    inst.AnimState:PlayAnimation("idle")
    inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")

    MakeInventoryFloatable(inst, "small", 0.05, {0.8, 0.75, 0.8})

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("tradable")

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")

    MakeHauntableLaunch(inst)

    inst.icon = nil
    inst:ListenForEvent("onputininventory", topocket)
    inst:ListenForEvent("ondropped", toground)
    inst:DoTaskInTime(0, init)

    inst.OnRemoveEntity = OnRemoveEntity

    inst:DoTaskInTime(0, Sparkle)

    return inst
end

return Prefab("emeraldmooneye", fn, assets, prefabs)

