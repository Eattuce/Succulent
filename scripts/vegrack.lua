
local veggies =
{
    "cave_banana",
    "carrot",
    "corn",
    "pumpkin",
    "eggplant",
    "durian",
    "pomegranate",
    "dragonfruit",
    -- "berries",
    -- "berries_juicy",
    "fig",
    "cactus_meat",
    "watermelon",
    "tomato",
    "potato",
    "asparagus",
    -- "onion",
    -- "garlic",
    -- "pepper",
}

for _,veggie in pairs(veggies) do
    AddPrefabPostInit(veggie, function (inst)
        inst:AddTag("dryable")
        inst:AddTag("dryableveg")
        if TheWorld.ismastersim then
			inst:AddComponent("dryable")
			inst.components.dryable:SetProduct("veggie_crisps")
			inst.components.dryable:SetDryTime(3*TUNING.PERISH_ONE_DAY)
        end
    end)
end

local function DryerModify(self)
    local _CanDry = self.CanDry
    function self:CanDry(dryable)
        return _CanDry(self, dryable) and (self.inst:HasTag("vegrack") and dryable:HasTag("dryableveg") or not dryable:HasTag("dryableveg") ) or false
    end
end

AddComponentPostInit("dryer", DryerModify)


-- 弃用
-- 因为加入了新的动作action和组件component
-- 导致Show me, Action queuer 以及空格不能直接兼容带来许多不方便
--[[
-- 收获
local HARVEST_CRISP = Action()
HARVEST_CRISP.id = "HARVEST_CRISP"
HARVEST_CRISP.str = STRINGS.HARVEST_CRISP
HARVEST_CRISP.fn = function(act)
    if act.target.components.crispmaker ~= nil then
        return act.target.components.crispmaker:Harvest(act.doer)
    end
end
AddAction(HARVEST_CRISP)

AddComponentAction("SCENE", "crispmaker", function(inst, doer, actions)
    if inst:HasTag("crisped") then
        table.insert(actions, ACTIONS.HARVEST_CRISP)
    end
end)

AddStategraphActionHandler("wilson",GLOBAL.ActionHandler(ACTIONS.HARVEST_CRISP, "dolongaction"))
AddStategraphActionHandler("wilson_client",GLOBAL.ActionHandler(ACTIONS.HARVEST_CRISP, "dolongaction"))

--------------------------------------------------------------------------

-- 晾晒
local CRISP = Action()
CRISP.id = "CRISP"
CRISP.str = STRINGS.CRISP
CRISP.fn = function(act)
    if act.target.components.crispmaker then
        if not act.target.components.crispmaker:CanCrisp(act.invobject) then
            return false
        end

        local ingredient = act.doer.components.inventory:RemoveItem(act.invobject)
        if not act.target.components.crispmaker:StartCrisping(ingredient) then
            act.doer.components.inventory:GiveItem(ingredient, nil, act.target:GetPosition())
            return false
        -- else
        --     TheWorld:PushEvent("CHEVO_starteddrying",{target=act.target,doer=act.doer})
        end
        return true
    end
end
AddAction(CRISP)

AddComponentAction("USEITEM", "crispable", function(inst, doer, target, actions)
    if target:HasTag("cancrisp") and inst:HasTag("crispable") then
        table.insert(actions, ACTIONS.CRISP)
    end
end)

AddStategraphActionHandler("wilson",GLOBAL.ActionHandler(ACTIONS.CRISP, "doshortaction"))
AddStategraphActionHandler("wilson_client",GLOBAL.ActionHandler(ACTIONS.CRISP, "doshortaction"))


for _,veggie in pairs(veggies) do
    AddPrefabPostInit(veggie, function (inst)
        inst:AddTag("crispable")
        if TheWorld.ismastersim then
            inst:AddComponent("crispable")
            inst.components.crispable:SetCrispTime(3*TUNING.PERISH_ONE_DAY)
        end
    end)
end
]]

--------------------------------------------------------------------------

