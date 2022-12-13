local assets =
{
    Asset("ANIM", "anim/totem_placer_idle.zip"),
    Asset("ANIM", "anim/floating_rock_build.zip"),
    Asset("IMAGE", "images/inventoryimages/totem_item.tex"),
    Asset("ATLAS", "images/inventoryimages/totem_item.xml"),
    Asset("ANIM", "anim/totem_lv0.zip"),
    Asset("ANIM", "anim/totem_lv1.zip"),
    Asset("ANIM", "anim/totem_lv2.zip"),
    Asset("ANIM", "anim/totem_lv3.zip"),
    Asset("ANIM", "anim/totem_lv4.zip"),
    Asset("ANIM", "anim/totem_lv5.zip"),
    Asset("ANIM", "anim/totem_lv6.zip"),
    Asset("ANIM", "anim/totem_lv7.zip"),
    Asset("ANIM", "anim/totem_lv8.zip"),

}

local prefabs =
{
    "totem_lowervine",
    "totem_uppervine",
    "totem_floatingrock",
    "totem_vine",
    "collapse_small",
}

local Construction_data = {
	{level = 0, name = "totem", construction_product = "totem_construction1" },
	{level = 1, name = "totem_construction1", construction_product = "totem_construction2" },
	{level = 2, name = "totem_construction2", construction_product = "totem_construction3" },
	{level = 3, name = "totem_construction3", construction_product = "totem_construction4" },  -- 1A
	{level = 4, name = "totem_construction4", construction_product = "totem_construction5" },  -- 2A
	{level = 5, name = "totem_construction5", construction_product = "totem_construction6" },  -- 2B 3A 
	{level = 6, name = "totem_construction6", construction_product = "totem_construction7" },
	{level = 7, name = "totem_construction7", construction_product = "totem_construction8" },  -- (Level 8) 1B 2C 3B
}

local function OnConstructed(inst, doer)
    local concluded = true
    for i, v in ipairs(CONSTRUCTION_PLANS[inst.prefab] or {}) do
        if inst.components.constructionsite:GetMaterialCount(v.type) < v.amount then
            concluded = false
            break
        end
    end

	if concluded then
        local new_structure = ReplacePrefab(inst, inst._construction_product)
        new_structure.AnimState:PlayAnimation("idle_3", true)
        new_structure.AnimState:SetTime(inst.AnimState:GetCurrentAnimationTime() % inst.AnimState:GetCurrentAnimationLength())

        if inst.rock1 ~= nil then
            new_structure.rock1.AnimState:SetTime(inst.rock1.AnimState:GetCurrentAnimationTime() % inst.rock1.AnimState:GetCurrentAnimationLength())
        end
        if inst.rock2 ~= nil then
            new_structure.rock2.AnimState:SetTime(inst.rock2.AnimState:GetCurrentAnimationTime() % inst.rock2.AnimState:GetCurrentAnimationLength())
        end
        if inst.rock3 ~= nil then
            new_structure.rock3.AnimState:SetTime(inst.rock3.AnimState:GetCurrentAnimationTime() % inst.rock3.AnimState:GetCurrentAnimationLength())
        end
    end
end

local function onconstruction_built(inst)
    -- PreventCharacterCollisionsWithPlacedObjects(inst)
    -- inst.level = 0
    -- inst.SoundEmitter:PlaySound("hookline_2/characters/hermit/house/stage".. inst.level.."_place")
end

local function OnWorkFinished(inst, worker)
    inst.components.lootdropper:DropLoot()
    -- inst.components.lootdropper:SetLoot({"cutstone", "cutstone"})
    local fx = SpawnPrefab("collapse_small")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("stone")
    inst:Remove()
end

local function AddFollowSymbol(inst, child, symbol, x, y, z)
    child.entity:SetParent(inst.entity)
    child.Follower:FollowSymbol(inst.GUID, symbol, x, y, z)
    return child
end

local function onload( inst )
    inst.AnimState:SetTime(math.random() * inst.AnimState:GetCurrentAnimationLength())
end

local function MakeTotem(name, client_postinit, master_postinit, construction_data, bb)
    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddNetwork()
        inst.entity:AddSoundEmitter()

        MakeObstaclePhysics(inst, 0.3)

        inst.AnimState:SetBank("totem_lv"..bb)
        inst.AnimState:SetBuild("totem_lv"..bb)
        inst.AnimState:PlayAnimation("idle_3", true)

        inst:AddTag("structure")
        inst:AddTag("totem")

        if construction_data then
            inst.level = construction_data.level
        else
            inst.level = 8
        end

		if construction_data then
            inst.AnimState:PlayAnimation("idle_3", true)
			inst:AddTag("constructionsite")
		end

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

---------------------------------------------

        inst.AnimState:SetDeltaTimeMultiplier(0.8)

        if construction_data then
			inst._construction_product = construction_data.construction_product

			inst:AddComponent("constructionsite")
			inst.components.constructionsite:SetConstructionPrefab("totem_construction_container")
			inst.components.constructionsite:SetOnConstructedFn(OnConstructed)
		end


        AddFollowSymbol(inst, SpawnPrefab("totem_snow"), "high", 0, 0, 0).AnimState:SetFinalOffset(1)

        if inst.level >= 3 then
            inst.rock1 = AddFollowSymbol(inst, SpawnPrefab("totem_floatingrock"), "shadow", 400, -420, 0)

            AddFollowSymbol(inst, SpawnPrefab("totem_vine"), "high", 40, -90, 0)
        end
        if inst.level >= 4 then
            inst.rock2 = AddFollowSymbol(inst, SpawnPrefab("totem_floatingrock"), "shadow", -520, -830, 0)
            inst.rock2.AnimState:OverrideSymbol("rock", "floating_rock_build", "rock4")
            inst.rock2.AnimState:SetFinalOffset(-1)

            AddFollowSymbol(inst, SpawnPrefab("totem_uppervine"), "high", 50, -100, 0).AnimState:SetFinalOffset(-1)
        end
        if inst.level >= 5 then
            inst.rock3 = SpawnPrefab("totem_floatingrock")
            inst.rock3.AnimState:OverrideSymbol("rock", "floating_rock_build", "rock2")
            inst.rock3.entity:SetParent(inst.entity)
            inst.rock3.Follower:FollowSymbol(inst.GUID, "shadow", 360, -900, 0)

            inst.rock2.AnimState:OverrideSymbol("rock", "floating_rock_build", "rock5")

            inst.lowervine = SpawnPrefab("totem_lowervine")
            inst.lowervine.entity:SetParent(inst.entity)
            inst.lowervine.Follower:FollowSymbol(inst.GUID, "high", -52, 220, 0)
            inst.lowervine.AnimState:SetFinalOffset(-1)
        end
        if inst.level >= 7 then
            inst.lowervine.AnimState:PlayAnimation("idle_2")
        end
        if inst.level >= 8 then
            inst.rock1.AnimState:OverrideSymbol("rock", "floating_rock_build", "rock1")
            inst.rock2.AnimState:OverrideSymbol("rock", "floating_rock_build", "rock6")
            inst.rock3.AnimState:OverrideSymbol("rock", "floating_rock_build", "rock3")
        end

		inst:SetPrefabNameOverride("totem")

        inst:AddComponent("inspectable")
        inst:AddComponent("lootdropper")

        inst:AddComponent("workable")
        inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
        inst.components.workable:SetWorkLeft(4)
        inst.components.workable:SetOnFinishCallback(OnWorkFinished)

        inst:ListenForEvent("onbuilt", onconstruction_built)
        inst.OnLoadPostPass = onload

        return inst
    end

    local product = construction_data and construction_data.construction_product or nil
    return Prefab(name, fn, assets, prefabs, product)
end


local ret = {}
table.insert(ret, MakeTotem("totem_construction8", nil, nil, nil, "8"))
for i = 1, #Construction_data do
	table.insert(ret, MakeTotem(Construction_data[i].name, nil, nil, Construction_data[i], Construction_data[i].level))
end
table.insert(ret, MakePlacer("totem_item_placer", "totem", "totem_placer_idle", "idle"))

return unpack(ret)



-- .._placer, "bank", "build", "idle"
--  spriter  entity动画集  scml文件名
