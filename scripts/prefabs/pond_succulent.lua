
require("worldsettingsutil")
require "prefabutil"

local assets =
{
    Asset("ANIM", "anim/marsh_tile.zip"),
    Asset("ANIM", "anim/splash.zip"),
    Asset("ANIM", "anim/pond_succulent_build.zip"),
    Asset("IMAGE", "images/inventoryimages/pond_succulent.tex"),
    Asset("ATLAS", "images/inventoryimages/pond_succulent.xml"),

}

local prefabs =
{
	"pondfish",
	"pondeel",
}

local function SpawnPlants(inst)
    -- inst.task = nil

    if inst.plant_ents ~= nil then
        return
    end

    if inst.plants == nil then
        inst.plants = {}
        for i = 1, math.random(2, 4) do
            local theta = math.random() * 2 * PI
            table.insert(inst.plants,
            {
                offset =
                {
                    math.sin(theta) * 2.1 + math.random() * .3,
                    0,
                    math.cos(theta) * 2.3 + math.random() * .3,
                },
            })
        end
    end

    inst.plant_ents = {}

    for i, v in pairs(inst.plants) do
        if type(v.offset) == "table" and #v.offset == 3 then
            local plant = SpawnPrefab(inst.planttype)
            if plant ~= nil then
                plant.entity:SetParent(inst.entity)
                plant.Transform:SetPosition(unpack(v.offset))
                plant.persists = false
                plant:SetVariation(math.random() > 0.5 and 2 or 1)
                table.insert(inst.plant_ents, plant)
            end
        end
    end
end

local function DespawnPlants(inst)
    if inst.plant_ents ~= nil then
        for i, v in ipairs(inst.plant_ents) do
            if v:IsValid() then
                v:Remove()
            end
        end

        inst.plant_ents = nil
    end

    inst.plants = nil
end

local function ondestory(inst)
    local fx = SpawnPrefab("collapse_small")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("stone")
    inst.components.lootdropper:DropLoot()

    inst:Remove()
end

local function OnSnowLevel(inst, snowlevel)
    if snowlevel > .02 then
        if not inst.frozen then
            inst.frozen = true
            inst.AnimState:PlayAnimation("frozen")
            inst.SoundEmitter:PlaySound("dontstarve/winter/pondfreeze")
            inst.components.fishable:Freeze()

            inst.Physics:SetCollisionGroup(COLLISION.LAND_OCEAN_LIMITS)
            inst.Physics:ClearCollisionMask()
            inst.Physics:CollidesWith(COLLISION.WORLD)
            inst.Physics:CollidesWith(COLLISION.ITEMS)

            inst.components.watersource.available = false
        end
    elseif inst.frozen then
        inst.frozen = false
        inst.AnimState:PlayAnimation("idle", true)
        inst.components.fishable:Unfreeze()

        inst.Physics:SetCollisionGroup(COLLISION.LAND_OCEAN_LIMITS)
        inst.Physics:ClearCollisionMask()
        inst.Physics:CollidesWith(COLLISION.WORLD)
        inst.Physics:CollidesWith(COLLISION.ITEMS)
        inst.Physics:CollidesWith(COLLISION.CHARACTERS)
        inst.Physics:CollidesWith(COLLISION.GIANTS)

        inst.components.watersource.available = true
    elseif inst.frozen == nil then
        inst.frozen = false
    end
end

local function OnSave(inst, data)
    data.plants = inst.plants
end

local function OnLoad(inst, data)
    if data ~= nil and data.plants ~= nil and inst.plants == nil and inst.task ~= nil then
        inst.plants = data.plants
    end
end

local function OnInit(inst)
    inst.task = nil
    inst:WatchWorldState("snowlevel", OnSnowLevel)
    OnSnowLevel(inst, TheWorld.state.snowlevel)
    SpawnPlants(inst)
end

local fish = {}
for i = 1, 9 do
    table.insert(fish, "oceanfish_small_"..tostring(i).."_inv")
end
local function GetFish(inst)
    local rnd = math.random()
    return rnd < 0.2 and GetRandomItem(fish) or (rnd < 0.5 and "pondeel" or "pondfish")
end

local function commonfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    local phys = inst.entity:AddPhysics()
    phys:SetMass(0) --Bullet wants 0 mass for static objects
    phys:SetCollisionGroup(COLLISION.LAND_OCEAN_LIMITS)
    phys:ClearCollisionMask()
    phys:CollidesWith(COLLISION.ITEMS)
    phys:CollidesWith(COLLISION.CHARACTERS)
    phys:CollidesWith(COLLISION.GIANTS)
    phys:SetCapsule(1.5, 1.6)
    inst:AddTag("blocker")

    inst.AnimState:SetBuild("pond_succulent_build")
    inst.AnimState:SetBank("marsh_tile")
    inst.AnimState:PlayAnimation("idle", true)
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(LAYER_BACKGROUND)
    inst.AnimState:SetSortOrder(3)

    inst.MiniMapEntity:SetIcon("pond_succulent.tex")

    -- From watersource component
    inst:AddTag("watersource")
    inst:AddTag("pond")
    inst:AddTag("antlion_sinkhole_blocker")
    inst:AddTag("birdblocker")

    inst.no_wet_prefix = true

    inst:SetDeployExtraSpacing(2)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.frozen = nil
    inst.plants = nil
    inst.plant_ents = nil

    inst:AddComponent("inspectable")
    inst.components.inspectable.nameoverride = "pond"

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.DIG)
    inst.components.workable:SetWorkLeft(5)
    inst.components.workable:SetOnFinishCallback(ondestory)

    inst:AddComponent("fishable")
    inst.components.fishable:SetRespawnTime(TUNING.FISH_RESPAWN_TIME)
    inst.components.fishable:SetGetFishFn(GetFish)

    inst:AddComponent("hauntable")
    inst.components.hauntable:SetHauntValue(TUNING.HAUNT_TINY)

    inst:AddComponent("watersource")
    inst:AddComponent("lootdropper")

    inst.OnSave = OnSave
    inst.OnLoad = OnLoad

    return inst
end

local function fn()
    local inst = commonfn()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.components.fishable:AddFish("pondfish")

    inst.planttype = "pond_succulent_plant"
    inst.task = inst:DoTaskInTime(0, OnInit)

    --These spawn nothing at this time.
    return inst
end

local function invalid_placement_fn(player, placer)
    if placer and placer.mouse_blocked then
        return
    end

    if player and player.components.talker then
        player.components.talker:Say(GetString(player, "ANNOUNCE_SUCCULENT_POND"))
    end
end

return Prefab("pond_succulent", fn, assets, prefabs),
    MakePlacer("pond_succulent_item_placer", "marsh_tile", "pond_succulent_build", "idle", nil, nil, nil, nil, nil, nil,
    function (inst)
        inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
        inst.AnimState:SetLayer(LAYER_BACKGROUND)
    end, nil, invalid_placement_fn)
