
-- data = {tree = tree, pt = pt}

local Dynamicoasis = Class(function(self, inst)
    self.inst = inst

    self.trees = {}

    self.inst:ListenForEvent("newtreeindesert", function(inst, data)
        if data.tree:GetDistanceSqToInst(self.inst) <= 25 then
            table.insert(self.trees, data)
            data.tree:ListenForEvent("ondie",function (inst, data)
            end)
        end
    end)

end)

return Dynamicoasis
