
local assets =
{
    Asset( "ANIM", "anim/permit_demolition.zip" ),
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

local function pond_deploy_fn(inst, pt, mouseover, deployer, rot)
	local ground_tile = TheWorld.Map:GetTileAtPoint(pt.x, pt.y, pt.z)
    local GROUND_FLOORING = GROUND_FLOORING or {}
    return ground_tile and GROUND_FLOORING[ground_tile] and not TheWorld.Map:IsDockAtPoint(pt.x, 0, pt.z)
end

local function MakeStoneMadeDeployableKitItem(name, prefab_to_deploy, tags, deployable_data)
	deployable_data = deployable_data or {}

	return Prefab(name, function()
		local inst = CreateEntity()

		inst.entity:AddTransform()
		inst.entity:AddAnimState()
		inst.entity:AddNetwork()

		MakeInventoryPhysics(inst)

		inst.AnimState:SetBank("permit_demolition")
		inst.AnimState:SetBuild("permit_demolition")
		inst.AnimState:PlayAnimation("idle")

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
		-- inst.components.inventoryitem.atlasname = "images/inventoryimages/constructionpermit.xml"
		-- inst.components.inventoryitem.imagename = "images/inventoryimages/constructionpermit.tex"

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
    MakeStoneMadeDeployableKitItem("python_fountain_item",              "python_fountain",          nil, {deployspacing = 1}),
    MakeStoneMadeDeployableKitItem("treasurechest_succulent_item",      "treasurechest_succulent",  nil, {deployspacing = 2}),
    MakeStoneMadeDeployableKitItem("vegrack_item",                      "vegrack",                  nil, {deployspacing = 2}),
    MakeStoneMadeDeployableKitItem("totem_item",                        "totem",                    nil, {deployspacing = 2}),
    MakeStoneMadeDeployableKitItem("pond_succulent_item",          		"pond_succulent",			nil, {deployspacing = 4, deploymode = DEPLOYMODE.CUSTOM, custom_candeploy_fn = pond_deploy_fn})