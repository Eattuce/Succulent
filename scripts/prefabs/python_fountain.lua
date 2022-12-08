require "prefabutil"

local assets =
{
    Asset("ANIM", "anim/python_fountain.zip"),
    Asset("IMAGE", "minimap/fountain_minimapicon.tex" ),
    Asset("ATLAS", "minimap/fountain_minimapicon.xml" ),
    Asset("ANIM", "anim/python_fountain_item.zip"),
    Asset("IMAGE", "images/inventoryimages/python_fountain_item.tex" ),
    Asset("ATLAS", "images/inventoryimages/python_fountain_item.xml" ),
    Asset("SOUNDPACKAGE", "sound/burble.fev"),
    Asset("SOUND", "sound/burble.fsb"),

}

local prefabs =
{
    "collapse_big",
}


local function onhammered(inst, worker)
    inst.components.lootdropper:DropLoot()
    local fx = SpawnPrefab("collapse_big")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("stone")
    inst:Remove()
end

local function turnon(inst)
    if not inst.AnimState:IsCurrentAnimation("flow_loop") then
        inst.AnimState:PlayAnimation("flow_pre")
        inst.AnimState:PushAnimation("flow_loop")

        inst.SoundEmitter:KillSound("burble")
        -- inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/boss/pugalisk/fountain_LP", "burble")
        inst.SoundEmitter:PlaySound("burble/burble/burble", "burble")

        inst.components.watersource.available = true
    end
end

local function turnoff(inst)
    if not inst.AnimState:IsCurrentAnimation("off") then
        inst.AnimState:PlayAnimation("flow_pst")
        inst.AnimState:PushAnimation("off")
        inst.components.watersource.available = false
        inst.SoundEmitter:KillSound("burble")
    end
end

local function structure_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()
    inst.entity:AddDynamicShadow()

    inst.MiniMapEntity:SetIcon("fountain_minimapicon.tex")

    inst.AnimState:SetBuild("python_fountain")
    inst.AnimState:SetBank("fountain")
    inst.AnimState:PlayAnimation("flow_pre")
    inst.AnimState:PushAnimation("flow_loop", true)

    -- inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/boss/pugalisk/fountain_LP", "burble")
    inst.SoundEmitter:PlaySound("burble/burble/burble", "burble")

    inst.entity:SetPristine()

    MakeInventoryPhysics(inst)

    inst:AddTag("python_fountain")
    -- inst:AddTag("antlion_sinkhole_blocker")
    inst:AddTag("structure")
    inst:AddTag("watersource")
    inst:AddTag("shelter")

    inst.DynamicShadow:Enable(true)
    inst.DynamicShadow:SetSize(7, 4)

    MakeObstaclePhysics(inst, 0.5)

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")
    inst:AddComponent("lootdropper")

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(4)
    inst.components.workable:SetOnFinishCallback(onhammered)

    inst:AddComponent("machine")
    inst.components.machine.turnonfn = turnon
    inst.components.machine.turnofffn = turnoff
    inst.components.machine.cooldowntime = 1
    inst.components.machine.ison = true

    -- inst:AddComponent("")

    inst:AddComponent("watersource")

    return inst
end

return Prefab("python_fountain", structure_fn, assets, prefabs),
    -- Prefab("python_fountain_item", item_fn, assets_item, prefabs_item), -- 科技物品都放到relic_items.lua
    MakePlacer("python_fountain_item_placer", "fountain", "python_fountain", "off")
    --                                  bank (entity name) build (file name)