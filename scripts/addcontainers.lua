
GLOBAL.setmetatable(env, { __index = function(t, k) return GLOBAL.rawget(GLOBAL, k) end })
------------------------------------------------------------------------
----------------------- 增加特殊的放大格子 ------------------------------
------------------------------------------------------------------------
local scale = 2.2
local InvSlot = require "widgets/invslot"
AddClassPostConstruct("widgets/containerwidget", function (self)
    local _open = self.Open

    function self:Open(container, doer)

        _open(self, container, doer)

        local widget = container.replica.container:GetWidget()
        if widget.spslotpos ~= nil then
            for i, v in ipairs(widget.spslotpos or {}) do
                local bgoverride = widget.slotbg ~= nil and widget.slotbg[i] or nil
                local slot = InvSlot(i,
                    bgoverride ~= nil and bgoverride.atlas or "images/hud.xml",
                    bgoverride ~= nil and bgoverride.image or "inv_slot.tex",
                    self.owner,
                    container.replica.container)

                self.inv[i] = self:AddChild(slot)
                slot:SetPosition(v)
                slot:SetScale(scale,scale,scale)
                slot.highlight_scale = 1.3 * 1.9
                slot.base_scale = 1 * scale

                if not container.replica.container:IsSideWidget() then
                    if widget.top_align_tip ~= nil then
                        slot.top_align_tip = widget.top_align_tip
                    else
                        slot.side_align_tip = (widget.side_align_tip or 0) - v.x
                    end
                end
            end

            for i, v in ipairs(widget.spslotpos2 or {}) do
                local bgoverride = widget.slotbg ~= nil and widget.slotbg[#widget.spslotpos + i] or nil
                local slot = InvSlot(#widget.spslotpos + i,
                    bgoverride ~= nil and bgoverride.atlas or "images/hud.xml",
                    bgoverride ~= nil and bgoverride.image or "inv_slot.tex",
                    self.owner,
                    container.replica.container
                )
                self.inv[#widget.spslotpos + i] = self:AddChild(slot)

                slot:SetPosition(v)

                if not container.replica.container:IsSideWidget() then
                    if widget.top_align_tip ~= nil then
                        slot.top_align_tip = widget.top_align_tip
                    else
                        slot.side_align_tip = (widget.side_align_tip or 0) - v.x
                    end
                end
            end
        end

        self:Refresh()
    end
end)
------------------------------------------------------------------------
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
------------------------------------------------------------------------

-- 大箱子
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

-- params.treasurechest.priorityfn = function (container, item, slot)
--     return item.prefab == "forgetmelots" or item.prefab == "tillweed" or item.prefab == "firenettles"
-- end

-- function params.treasurechest.itemtestfn(container, item, slot)
--     if (params.treasurechest.widget.slotpos ~= nil and #params.treasurechest.widget.slotpos or 0) + (params.treasurechest.widget.spslotpos ~= nil and #params.treasurechest.widget.spslotpos or 0) == slot then
--         return params.treasurechest.priorityfn
--     end
--     return false
-- end

-- params.chandelier_rock =
-- {
--     widget =
--     {
--         slotpos =
--         {
--             Vector3(0, 64 + 32 + 8 + 4, 0),
--             Vector3(0, 32 + 4, 0),
--             Vector3(0, -(32 + 4), 0),
--         },
--         animbank = "ui_lamp_1x4",
--         animbuild = "ui_lamp_1x4",
--         pos = Vector3(0, 200, 0),
--         side_align_tip = 100,
--     },
--     acceptsstacks = false,
--     type = "cooker",
-- }
-- function params.chandelier_rock.itemtestfn(container, item, slot)
--     return item.prefab == "moonbutterfly" or item.prefab == "lightcrab" or item.prefab == "lightflier" or item:HasTag("chandelier_lighter")
-- end

------------------------------------------------------------------------
-- 可升级界面
params.totem_construction_container = deepcopy(params.construction_container)
params.totem_construction_container.widget.slotpos = {}
params.totem_construction_container.widget.animbank = "ui_construction_5x1"
params.totem_construction_container.widget.animbuild = "ui_construction_5x1" -- ui_construction_4x1
for x = -2, 2, 1 do
    table.insert(params.totem_construction_container.widget.slotpos, Vector3(x * 110, 8, 0))
end










------------------------------------------------------------------------
------------------------------------------------------------------------
for k, v in pairs(params) do
    local total_slots = (v.widget.slotpos ~= nil and #v.widget.slotpos or 0) + (v.widget.spslotpos ~= nil and #v.widget.spslotpos or 0) + (v.widget.spslotpos2 ~= nil and #v.widget.spslotpos2 or 0)
    containers.MAXITEMSLOTS = math.max(containers.MAXITEMSLOTS, total_slots)
end