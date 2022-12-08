
local Chandelier = Class(function(self, inst)
    self.inst = inst
    self.currentchild = 0
    self.maxchild = 3

    local function _UpdateChild() return self:UpdateChild() end
    self.inst:ListenForEvent("itemget", _UpdateChild)
    self.inst:ListenForEvent("itemlose", _UpdateChild)

end)

function Chandelier:CanGoHome()
    return not self.inst.components.container:IsFull()
end

function Chandelier:GetChild()
    return #self.inst.components.container:FindItems(function (inst) return inst:IsValid() end)
end

function Chandelier:UpdateChild()
    self.currentchild = self:GetChild()
    if self.currentchild >= self.maxchild then
        self.inst:RemoveTag("notfull_chandelier")
        self.inst:AddTag("isfull_chandelier")
    else
        self.inst:RemoveTag("isfull_chandelier")
        self.inst:AddTag("notfull_chandelier")
    end
end

function Chandelier:GoHome(child)
    if self:CanGoHome() then
        self.inst.components.container:GiveItem(child)
    else
        -- 正常情况下满员无法选择这个灯为目标, 也无法进入到这部分, 以防万一
        child:Remove()
    end
end

function Chandelier:OnLoad()
    self.currentchild = self:GetChild()
end

function Chandelier:GetDebugString(data)
    return tostring(self.currentchild).." is current inside chandelier, Max: "..tostring(self.maxchild)
end

return Chandelier