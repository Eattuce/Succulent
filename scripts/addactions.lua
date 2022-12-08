

local function IsReconstructor(item)
    return item:HasTag("bring_burnt_backtolife")
end








local RESURRECT_PLANT = Action({priority = 0, rmb = true, distance=2})
RESURRECT_PLANT.id = "RESURRECT_PLANT"
RESURRECT_PLANT.str = STRINGS.RESURRECT_PLANT
RESURRECT_PLANT.fn = function(act)
    local targ = act.invobject or act.target
    local doer = act.doer
    if targ:HasTag("burnt") and doer.components.inventory:EquipHasTag("bring_burnt_backtolife") then
        if doer.components.sanity ~= nil then
            act.doer.components.sanity:DoDelta(TUNING.SANITY_MED)
        end

        local newitem = SpawnPrefab(targ.prefab)
        local fx = SpawnPrefab("collapse_big")
        local pos = targ:GetPosition()
        fx.Transform:SetPosition(pos:Get())
        targ:Remove()
        newitem.Transform:SetPosition(pos:Get())
        -- newitem.AnimState:SetBuild(targ.AnimState:GetSkinBuild())
        local items = doer.components.inventory:FindItems(IsReconstructor)
        if items and next(items) then
            for _,item in pairs(items) do
                if item.components.finiteuses then
                    item.components.finiteuses:Use(1)
                end
            end
        end

        return true
    end
end
AddAction(RESURRECT_PLANT)

AddComponentAction("SCENE", "workable", function(inst, doer, actions)
    if inst:HasTag("structure") and inst:HasTag("burnt") and doer.components.inventory:EquipHasTag("bring_burnt_backtolife") then
        table.insert(actions, ACTIONS.RESURRECT_PLANT)
    end
end)

AddStategraphActionHandler("wilson",GLOBAL.ActionHandler(ACTIONS.RESURRECT_PLANT, "burntbacktolife"))
AddStategraphActionHandler("wilson_client",GLOBAL.ActionHandler(ACTIONS.RESURRECT_PLANT, "burntbacktolife"))














