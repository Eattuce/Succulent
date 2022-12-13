require("mathutil")

local GradualFader = Class(function(self, inst)
    self.inst = inst

    self.fadetime = 2
    self.timesincefadestart = 0
    self.mode = "IN"

    local function _fadein () return self:FadeIn() end
    local function _fadeout () return self:FadeOut() end
    self.inst:ListenForEvent("gradualfade_in", _fadein)
    self.inst:ListenForEvent("gradualfade_out", _fadeout)
end)

function GradualFader:SetTransParent(alpha)
    local _alpha = alpha or 0
    self.inst.AnimState:OverrideMultColour(_alpha, _alpha, _alpha, _alpha)
end

function GradualFader:FadeIn()
    self:SetMode("IN")
    self:StartUpdating()
end

function GradualFader:FadeOut()
    self:SetMode("OUT")
    self:StartUpdating()
end

function GradualFader:SetFadeTime(time)
    self.fadetime = time or 2
end

function GradualFader:SetMode(mode)
    self.mode = mode
    self.timesincefadestart = 0
end

function GradualFader:GetMode()
    if self.mode == "IN" then
        return 0,1
    else
        return 1,0
    end
end

local function _OnUpdate(inst, self, dt)
    self:OnUpdate(dt)
end

function GradualFader:StartUpdating()
    if self.task == nil then
        self.task = self.inst:DoPeriodicTask(FRAMES, _OnUpdate, FRAMES, self, FRAMES)
    end
end

function GradualFader:StopUpdating()
    if self.task ~= nil then
        self.task:Cancel()
        self.task = nil
    end
end

function GradualFader:OnUpdate(dt)
    self.timesincefadestart = self.timesincefadestart + dt

    local scale = self.timesincefadestart / self.fadetime
    local x,y = self:GetMode()
    if scale >= 0 and scale <= 1 then
        local alpha = Lerp(x, y, scale)
        self.inst.AnimState:OverrideMultColour(alpha, alpha, alpha, alpha)
    else
        self.inst.AnimState:OverrideMultColour(y, y, y, y)
        self.timesincefadestart = 0
        self:StopUpdating()
    end
end

function GradualFader:GetDebugString()
    return string.format("MODE: %s", self.mode)
end

return GradualFader