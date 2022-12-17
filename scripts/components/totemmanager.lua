local TotemManager = Class(function(self, inst)
    self.inst = inst

    local function Change() return self:Change() end

    self.inst:ListenForEvent("", Change)

end)


function TotemManager:Change(name)
    CONSTRUCTION_PLANS[name] = { Ingredient("twigs", 1) }
end