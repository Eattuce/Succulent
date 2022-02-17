local Crispable = Class(function(self, inst)
    self.inst = inst

    self.crisp = "veggie_crisps"
    self.crisptime = TUNING.DRY_MED*2
	self.buildfile = nil
    self.crisp_buildfile = nil--"veggie_crisps"

    inst:AddTag("crispable")
end)

function Crispable:OnRemoveFromEntity()
    self.inst:RemoveTag("crispable")
end

function Crispable:SetCrisp(crisp)
    self.crisp = crisp
end

function Crispable:GetCrisp()
    return self.crisp
end

function Crispable:SetCrispTime(time)
    self.crisptime = time
end

function Crispable:GetCrispTime()
    return self.crisptime
end

function Crispable:SetBuildFile(buildfile)
    self.buildfile = buildfile
end

function Crispable:GetBuildFile()
    return self.buildfile
end

function Crispable:SetDriedBuildFile(crisp_buildfile)
    self.crisp_buildfile = crisp_buildfile
end

function Crispable:GetCrispBuildFile()
    return self.crisp_buildfile or self.buildfile
end

return Crispable