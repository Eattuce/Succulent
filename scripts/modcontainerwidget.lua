
GLOBAL.setmetatable(env, { __index = function(t, k) return GLOBAL.rawget(GLOBAL, k) end })
------------------------------------------------------------------------
----------------------- 增加特殊的放大格子 ------------------------------
------------------------------------------------------------------------
local scale = 2.2
local InvSlot = require "widgets/invslot"
local ImageButton = require "widgets/imagebutton"

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
--[[ 
        if widget.switchbutton ~= nil then
            if doer ~= nil and doer.components.playeractionpicker ~= nil then
                doer.components.playeractionpicker:RegisterContainer(container)
            end

            -- sb: Switch Button
            self.sb = self:AddChild(ImageButton("images/button_icons.xml", "refresh.tex", "refresh.tex", "refresh.tex", nil, nil, {1, 1}, {0,0}))
            -- self.sb:SetFocusScale(0.5,0.5)
            -- self.sb:SetNormalScale(0.4,0.4)
            self.sb:SetScale(0.2, 0.2, 0.2)
            self.sb:SetImageFocusColour(254/255,216/255,42/255,1)
            self.sb:SetImageNormalColour(254/255,216/255,42/255,1)
            self.sb:SetHoverText(widget.switchbutton.hovertext)
            self.sb.image:SetScale(1)
            -- self.sb.text:SetPosition(2,-2)
            self.sb:SetPosition(widget.switchbutton.position)
            -- self.sb:SetText(widget.switchbutton.text)
            if widget.switchbutton.fn ~= nil then
                self.sb:SetOnClick(function()
                    if doer ~= nil then
                        if doer:HasTag("busy") then
                            --Ignore button click when doer is busy
                            return
                        elseif doer.components.playercontroller ~= nil then
                            local iscontrolsenabled, ishudblocking = doer.components.playercontroller:IsEnabled()
                            if not (iscontrolsenabled or ishudblocking) then
                                --Ignore button click when controls are disabled
                                --but not just because of the HUD blocking input
                                return
                            end
                        end
                    end
                    widget.switchbutton.fn(container, doer)
                end)
            end
            self.sb:SetFont(BUTTONFONT)
            self.sb:SetDisabledFont(BUTTONFONT)
            -- self.sb:SetTextSize(33)
            -- self.sb.text:SetVAlign(ANCHOR_MIDDLE)
            -- self.sb.text:SetColour(0, 0, 0, 1)

            if widget.switchbutton.validfn ~= nil then
                if widget.switchbutton.validfn(container) then
                    self.sb:Enable()
                else
                    self.sb:Disable()
                end
            end

        --     if TheInput:ControllerAttached() then
        --         self.sb:Hide()
        --     end

        --     self.sb.inst:ListenForEvent("continuefrompause", function()
        --         if TheInput:ControllerAttached() then
        --             self.sb:Hide()
        --         else
        --             self.sb:Show()
        --         end
        --     end, TheWorld)
       end
 ]] 

        self:Refresh()
    end

--[[ 
    -- Destory Button immediately on quit
    local _close = self.Close
    function self:Close()
        if self.isopen then
            if self.sb ~= nil then
                self.sb:Kill()
                self.sb = nil
            end
        end
        return _close(self)
    end

 ]]end)
------------------------------------------------------------------------
