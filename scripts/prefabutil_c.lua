require "prefabutil"
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

function MakeStoneMadeDeployableKitItem(name, prefab_to_deploy, bank, build, anim, assets, floatable_data, tags, deployable_data, stack_size)
	deployable_data = deployable_data or {}

	return Prefab(name, function()
		local inst = CreateEntity()

		inst.entity:AddTransform()
		inst.entity:AddAnimState()
		inst.entity:AddNetwork()

		MakeInventoryPhysics(inst)

		inst.AnimState:SetBank(bank)
		inst.AnimState:SetBuild(build or bank)
		inst.AnimState:PlayAnimation(anim or "idle")

		if floatable_data ~= nil then
		    MakeInventoryFloatable(inst, floatable_data.size, floatable_data.y_offset, floatable_data.scale)
		end

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
		if floatable_data == nil then
			inst.components.inventoryitem:SetSinks(true)
		end

		if stack_size ~= nil then
			inst:AddComponent("stackable")
			inst.components.stackable.maxsize = stack_size
		end

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


-- local PLACER_SCALE = 0.7 -- min_spacing = 3
local function OnEnableHelper(inst, enabled)
    if enabled then
        if inst.helper == nil then
            inst.helper = CreateEntity()

            --[[Non-networked entity]]
            inst.helper.entity:SetCanSleep(false)
            inst.helper.persists = false

            inst.helper.entity:AddTransform()
            inst.helper.entity:AddAnimState()

            inst.helper:AddTag("CLASSIFIED")
            inst.helper:AddTag("NOCLICK")
            inst.helper:AddTag("placer")

            inst.helper.Transform:SetScale(inst.no_placing_helper_scale, inst.no_placing_helper_scale, inst.no_placing_helper_scale)

            inst.helper.AnimState:SetBank("firefighter_placement")
            inst.helper.AnimState:SetBuild("firefighter_placement")
            inst.helper.AnimState:PlayAnimation("idle")
            inst.helper.AnimState:SetLightOverride(1)
            inst.helper.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
            inst.helper.AnimState:SetLayer(LAYER_BACKGROUND)
            inst.helper.AnimState:SetSortOrder(1)
            inst.helper.AnimState:SetAddColour(0, .2, .5, 0)

            inst.helper.entity:SetParent(inst.entity)
        end
    elseif inst.helper ~= nil then
        inst.helper:Remove()
        inst.helper = nil
    end
end

function MakeHangingObject_client(inst, helper)
	inst:AddTag("hangingobject")
	inst:AddTag("NOBLOCK")
	if helper ~= nil then
		inst.no_placing_helper_scale = helper

		if not TheNet:IsDedicated() then
			inst:AddComponent("deployhelper")
			inst.components.deployhelper.onenablehelper = OnEnableHelper
		end
	end
end

function _PlacerPostInit(inst, scale, bank, build, anim, loop, fn)
    --Show the flingo placer on top of the flingo range ground placer

    local placer2 = CreateEntity()

    --[[Non-networked entity]]
    placer2.entity:SetCanSleep(false)
    placer2.persists = false

    placer2.entity:AddTransform()
    placer2.entity:AddAnimState()

    placer2:AddTag("CLASSIFIED")
    placer2:AddTag("NOCLICK")
    placer2:AddTag("placer")

    local s = 1 / scale
    placer2.Transform:SetScale(s, s, s)

    placer2.AnimState:SetBank(bank) -- prefab
    placer2.AnimState:SetBuild(build) -- prefab
    placer2.AnimState:PlayAnimation(anim or "idle", loop or false)
    placer2.AnimState:SetLightOverride(1)

    placer2.entity:SetParent(inst.entity)

    inst.components.placer:LinkEntity(placer2)

    if fn ~= nil then
        fn(placer2)
    end
end
