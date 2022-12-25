GLOBAL.setmetatable(env, { __index = function(t, k) return GLOBAL.rawget(GLOBAL, k) end })
local containers = require "containers"
local params = containers.params
local _widgetsetup = containers.widgetsetup
function containers.widgetsetup(container, prefab, data, ...)
    local t = data or params[prefab or container.inst.prefab]
    if t ~= nil then
        for k, v in pairs(t) do
            container[k] = v
        end
        if container.widget.spslotpos ~= nil then
            container:SetNumSlots(#container.widget.spslotpos + (container.widget.slotpos ~= nil and #container.widget.slotpos or 0) + (container.widget.spslotpos2 ~= nil and #container.widget.spslotpos2 or 0))
        else
            return _widgetsetup(container, prefab, data, ...)
        end
    end
end

--------------------------------------------------------------------------
--[[ 大箱子 rock chest]]
--------------------------------------------------------------------------
params.treasurechest_succulent =
{
    widget =
    {
        slotpos = {},
        spslotpos = {GLOBAL.Vector3(80 * -0.5 - 80 * 2 + 80, 80 * 2.5 - 80 * 2 + 80, 0)},
        spslotpos2 = {},
        animbank = "ui_succulentchest_5x5",
        animbuild = "ui_succulentchest_5x5",
        pos = GLOBAL.Vector3(0, 200, 0),
        side_align_tip = 160,
    },
    type = "chest",
}

for y = 3, 2, -1 do
    for x = 1, 3 do
        table.insert(params.treasurechest_succulent.widget.spslotpos2, GLOBAL.Vector3(80 * x - 80 * 2 + 80, 80 * y - 80 * 2 + 80, 0))
    end
end
for y = 1, -1, -1 do
    for x = -1, 3 do
        table.insert(params.treasurechest_succulent.widget.spslotpos2, GLOBAL.Vector3(80 * x - 80 * 2 + 80, 80 * y - 80 * 2 + 80, 0))
    end
end


--------------------------------------------------------------------------
--[[ 遗迹 Relic]]
--------------------------------------------------------------------------
params.totem_construction_container = deepcopy(params.construction_container)
params.totem_construction_container.widget.slotpos = {}
params.totem_construction_container.widget.animbank = "ui_construction_5x1"
params.totem_construction_container.widget.animbuild = "ui_construction_5x1" -- ui_construction_4x1
for x = -2, 2, 1 do
    table.insert(params.totem_construction_container.widget.slotpos, Vector3(x * 110, 8, 0))
end

params.totem_construction_container.widget.switchbutton = {
    hovertext = STRINGS.TOTEM_HELP_STRING,
    position = Vector3(280, -110, 0),
}

-- function params.totem_construction_container.widget.switchbutton.fn(inst, doer)
--     -- if inst.components.container ~= nil then
--     --     BufferedAction(doer, inst, ACTIONS.APPLYCONSTRUCTION):Do()
--     -- elseif inst.replica.container ~= nil and not inst.replica.container:IsBusy() then
--     --     SendRPCToServer(RPC.DoWidgetButtonAction, ACTIONS.APPLYCONSTRUCTION.code, inst, ACTIONS.APPLYCONSTRUCTION.mod_name)
--     -- end
--     if inst.components.container ~= nil then
--         -- SendModRPCToServer(GetModRPC("Succulent_RPC", "eazy_upgrade"))
--         local target = doer.components.constructionbuilderuidata:GetTarget()
--         if target ~= nil then
--             CONSTRUCTION_PLANS[target.prefab] = { Ingredient("twigs", 1) }
--         end
--         BufferedAction(doer, inst, ACTIONS.STOPCONSTRUCTION):Do()
--     elseif inst.replica.container ~= nil and not inst.replica.container:IsBusy() then
--         SendModRPCToServer(GetModRPC("Succulent_RPC", "eazy_upgrade"), ACTIONS.STOPCONSTRUCTION.code, inst)
--     end
-- end

function params.totem_construction_container.widget.switchbutton.validfn(inst)
    -- return inst.replica.container ~= nil and not inst.replica.container:IsEmpty()
    return false
end







for k, v in pairs(params) do
    local total_slots = (v.widget.slotpos ~= nil and #v.widget.slotpos or 0) + (v.widget.spslotpos ~= nil and #v.widget.spslotpos or 0) + (v.widget.spslotpos2 ~= nil and #v.widget.spslotpos2 or 0)
    containers.MAXITEMSLOTS = math.max(containers.MAXITEMSLOTS, total_slots)
end