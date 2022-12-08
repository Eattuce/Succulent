
local assets =
{
    Asset( "ANIM", "anim/relic_item_bundle.zip" ),
    Asset( "ANIM", "anim/items_for_bundle.zip" ),

}

local function deployablekititem_ondeploy(inst, pt, deployer, rot)
    local structure = SpawnPrefab(inst._prefab_to_deploy, inst.linked_skinname, inst.skin_id )
    if structure ~= nil then
        structure.Transform:SetPosition(pt:Get())
		structure:PushEvent("onbuilt", { builder = deployer, pos = pt, rot = rot, deployable = inst })
        inst:Remove()
		if structure.SoundEmitter then
			structure.SoundEmitter:PlaySound("dontstarve/common/place_structure_stone")
		end
    end
end

local function MakeStoneMadeDeployableKitItem(name, prefab_to_deploy, tags, deployable_data, symbol)
	deployable_data = deployable_data or {}

	return Prefab(name, function()
		local inst = CreateEntity()

		inst.entity:AddTransform()
		inst.entity:AddAnimState()
		inst.entity:AddNetwork()

		MakeInventoryPhysics(inst)

		inst.AnimState:SetBank("bundle_items")
		inst.AnimState:SetBuild("relic_item_bundle")
		inst.AnimState:PlayAnimation("idle")
        inst.AnimState:OverrideSymbol("swap_item", "items_for_bundle", symbol)


		if tags ~= nil then
			for _, tag in pairs(tags) do
				inst:AddTag(tag)
			end
        end
        inst:AddTag("deploykititem")

        if deployable_data.custom_candeploy_fn ~= nil then
            inst._custom_candeploy_fn = deployable_data.custom_candeploy_fn
        end

		inst.entity:SetPristine()

		if not TheWorld.ismastersim then
			return inst
		end

		inst:AddComponent("inspectable")

		inst:AddComponent("inventoryitem")
		inst.components.inventoryitem:SetSinks(true)

        inst:AddComponent("stackable")
        inst.components.stackable.maxsize = TUNING.STACK_SIZE_LARGEITEM

		inst._prefab_to_deploy = prefab_to_deploy
		inst:AddComponent("deployable")
		inst.components.deployable.ondeploy = deployablekititem_ondeploy
        if deployable_data.deploymode ~= nil then
            inst.components.deployable:SetDeployMode(deployable_data.deploymode)
        end
        if deployable_data.deployspacing ~= nil then
			inst.components.deployable:SetDeploySpacing(deployable_data.deployspacing)
		end

        if deployable_data.master_postinit ~= nil then
            deployable_data.master_postinit(inst)
        end

		MakeHauntableLaunch(inst)

		inst.OnSave = deployable_data.OnSave
		inst.OnLoad = deployable_data.OnLoad

		return inst
	end,
	assets,
	{prefab_to_deploy})
end


return 
    MakeStoneMadeDeployableKitItem("python_fountain_item",              "python_fountain",          nil, {deployspacing = 1}, "fountain"),
    MakeStoneMadeDeployableKitItem("treasurechest_succulent_item",      "treasurechest_succulent",  nil, {deployspacing = 2}, "chest"),
    MakeStoneMadeDeployableKitItem("vegrack_item",                      "vegrack",                  nil, {deployspacing = 2}, "vegrack"),
    MakeStoneMadeDeployableKitItem("totem_item",                        "totem",                    nil, {deployspacing = 2}, "totem")