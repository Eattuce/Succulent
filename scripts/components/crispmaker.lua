local function ontagswitch(self)
    if self.crisp == nil then
        self.inst:RemoveTag("crisped")
        self.inst:RemoveTag("crisping")
        self.inst:AddTag("cancrisp")
    elseif self.veggie == nil then
        self.inst:AddTag("crisped")
        self.inst:RemoveTag("crisping")
        self.inst:RemoveTag("cancrisp")
    else
        self.inst:RemoveTag("crisped")
        self.inst:AddTag("crisping")
        self.inst:RemoveTag("cancrisp")
    end
end

local Crispmaker = Class(function(self, inst)
    self.inst = inst

    self.veggie = nil
    self.crisp = nil

	self.buildfile = nil
    self.crisp_buildfile = nil
	self.foodtype = nil

    self.remainingtime = nil
    self.tasktotime = nil
    self.task = nil

    self.onstartcrisping = nil
    self.ondonecrisping = nil
    self.onfetch = nil

    self.protectedfromrain = nil
    self.watchingrain = nil
end,
nil,
{
    veggie = ontagswitch,
    crisp = ontagswitch,
})

--------------------------------------------------------------------------

local function OnIsRaining(self, israining)
    if israining then
        self:Pause()
    else
        self:Resume()
    end
end

local function StartWatchingRain(self)
    if not self.watchingrain then
        self.watchingrain = true
        self:WatchWorldState("israining", OnIsRaining)
    end
end

local function StopWatchingRain(self)
    if self.watchingrain then
        self.watchingrain = nil
        self:StopWatchingWorldState("israining", OnIsRaining)
    end
end

--------------------------------------------------------------------------

function Crispmaker:OnRemoveFromEntity()
    if self.task ~= nil then
        self.task:Cancel()
    end
    StopWatchingRain(self)
    self.inst:RemoveTag("crisped")
    self.inst:RemoveTag("crisping")
    self.inst:RemoveTag("cancrisp")
end

--------------------------------------------------------------------------

function Crispmaker:SetStartCrispingFn(fn)
    self.onstartcrisping = fn
end

function Crispmaker:SetDoneCrispingFn(fn)
    self.ondonecrisping = fn
end

function Crispmaker:SetOnFetchFn(fn)
    self.onfetch = fn
end

--------------------------------------------------------------------------
function Crispmaker:CanCrisp(veg)
    return self.crisp == nil and veg ~= nil and veg.components.crispable ~= nil
end

function Crispmaker:IsCrisping()
    return self.veggie ~= nil
end

function Crispmaker:IsDone()
    return self.crisp ~= nil and self.veggie == nil
end

function Crispmaker:GetTimeToCrisp()
    return self.veggie ~= nil and (self.tasktotime ~= nil and self.tasktotime - GetTime() or self.remainingtime) or 0
end

function Crispmaker:GetTimeToSpoil()
    return self.veggie == nil and (self.tasktotime ~= nil and self.tasktotime - GetTime() or self.remainingtime) or 0
end

function Crispmaker:IsPaused()
    return self.remainingtime ~= nil
end

--------------------------------------------------------------------------

local function DoCrisp(inst, self)
    self.veggie = nil
    self.remainingtime = TUNING.PERISH_PRESERVED
    self.tasktotime = nil
    self.task = nil
    StopWatchingRain(self)

    self:Resume()

    if self.ondonecrisping ~= nil then
        self.ondonecrisping(inst, self.crisp, self.crisp_buildfile)
    end
end

--------------------------------------------------------------------------

function Crispmaker:StartCrisping(veg)
    if not self:CanCrisp(veg) then
        return false
    end

    self.veggie = veg.prefab
	self.buildfile = veg.components.crispable:GetBuildFile()
    self.crisp_buildfile = veg.components.crispable:GetCrispBuildFile()
    self.veggieperish = veg.components.perishable:GetPercent()
	self.foodtype = veg.components.edible ~= nil and veg.components.edible.foodtype or nil
    self.crisp = veg.components.crispable:GetCrisp()
    self.remainingtime = veg.components.crispable:GetCrispTime()
    self.tasktotime = nil
    if self.task ~= nil then
        self.task:Cancel()
        self.task = nil
    end
    StopWatchingRain(self)

    if self.veggie == nil or self.crisp == nil or self.remainingtime == nil then
        self.veggie = nil
		self.buildfile = nil
        self.crisp_buildfile = nil
        self.crisp = nil
		self.foodtype = nil
        self.remainingtime = nil
        return false
    end

    veg:Remove()

    if not TheWorld.state.israining or self.protectedfromrain then
        self:Resume()
    end
    if not self.protectedfromrain then
        StartWatchingRain(self)
    end

    if self.onstartcrisping ~= nil then
        self.onstartcrisping(self.inst, self.veggie, self.buildfile)
    end
    return true
end

function Crispmaker:Pause()
    if self.tasktotime ~= nil then
        self.remainingtime = math.max(0, self.tasktotime - GetTime())
        self.tasktotime = nil
        if self.task ~= nil then
            self.task:Cancel()
            self.task = nil
        end
    end
end

function Crispmaker:Resume()
    if self.remainingtime ~= nil then
        if self.task ~= nil then
            self.task:Cancel()
        end
        self.task = self.inst:DoTaskInTime(self.remainingtime, DoCrisp, self)
        self.tasktotime = GetTime() + self.remainingtime
        self.remainingtime = nil
    end
end

function Crispmaker:DropItem()
	if self.veggie == nil and self.crisp == nil then
		return
	end

    local loot = SpawnPrefab(self.veggie or self.crisp)
    if loot ~= nil then
		LaunchAt(loot, self.inst, nil, .25, 1)
        if loot.components.perishable ~= nil then
			if self.veggie ~= nil then
				loot.components.perishable:SetPercent(self.veggieperish * (self:GetTimeToCrisp() / loot.components.crispable:GetCrispTime()))
	        else
	            loot.components.perishable:SetPercent(self:GetTimeToSpoil() / TUNING.PERISH_PRESERVED)
	        end
            loot.components.perishable:StartPerishing()
        end
        if loot.components.inventoryitem ~= nil and not self.protectedfromrain then
            loot.components.inventoryitem:InheritMoisture(TheWorld.state.wetness, TheWorld.state.iswet)
        end
    end

    self.veggie = nil
	self.buildfile = nil
    self.crisp_buildfile = nil
    self.crisp = nil
	self.foodtype = nil
    self.remainingtime = nil
    self.tasktotime = nil
    if self.task ~= nil then
        self.task:Cancel()
        self.task = nil
    end
    StopWatchingRain(self)

    if self.onfetch ~= nil then
        self.onfetch(self.inst)
    end
    return true
end

function Crispmaker:Harvest(harvester)
    if not self:IsDone() or harvester == nil or harvester.components.inventory == nil then
        return false
    end

    local loot = SpawnPrefab(self.crisp)
    if loot ~= nil then
        if loot.components.perishable ~= nil then
            loot.components.perishable:SetPercent(self:GetTimeToSpoil() / TUNING.PERISH_PRESERVED)
            loot.components.perishable:StartPerishing()
        end
        if loot.components.inventoryitem ~= nil and not self.protectedfromrain then
            loot.components.inventoryitem:InheritMoisture(TheWorld.state.wetness, TheWorld.state.iswet)
        end
        harvester.components.inventory:GiveItem(loot, nil, self.inst:GetPosition())
    end

    self.veggie = nil
	self.buildfile = nil
    self.crisp_buildfile = nil
    self.crisp = nil
	self.foodtype = nil
    self.remainingtime = nil
    self.tasktotime = nil
    if self.task ~= nil then
        self.task:Cancel()
        self.task = nil
    end
    StopWatchingRain(self)

    if self.onfetch ~= nil then
        self.onfetch(self.inst)
    end
    return true
end

--------------------------------------------------------------------------
-- Update

function Crispmaker:LongUpdate(dt)
    if self.crisp == nil then
        return
    end

    self:Pause()

    if self.remainingtime > dt then
        self.remainingtime = self.remainingtime - dt
    elseif self.veggie ~= nil then
        DoCrisp(self.inst, self)
        self:Pause()
        self.remainingtime = math.max(0, self.remainingtime - dt)
    end

    if self:IsCrisping() then
        if not TheWorld.state.israining or self.protectedfromrain then
            self:Resume()
        end
        if not self.protectedfromrain then
            StartWatchingRain(self)
        end
    else
        self:Resume()
    end
end

--------------------------------------------------------------------------
-- Save/Load

function Crispmaker:OnSave()
    if self.crisp ~= nil then
        local remainingtime = (self.tasktotime ~= nil and self.tasktotime - GetTime() or self.remainingtime) or 0
        return
        {
            veggie = self.veggie,
			buildfile = self.buildfile,
            crisp_buildfile = self.crisp_buildfile,
            veggieperish = self.veggieperish,
            crisp = self.crisp,
			foodtype = self.foodtype,
            remainingtime = remainingtime > 0 and remainingtime or nil,
        }
    end
end

function Crispmaker:OnLoad(data)
    if data.crisp ~= nil then
        self.veggie = data.veggie
        self.veggieperish = data.veggieperish or 100 -- for old save files, assume 100%
		self.buildfile = data.buildfile
        self.crisp_buildfile = data.crisp_buildfile
        self.crisp = data.crisp
		self.foodtype = data.foodtype or FOODTYPE.GENERIC
        self.remainingtime = data.remainingtime or 0
        self.tasktotime = nil
        if self.task ~= nil then
            self.task:Cancel()
            self.task = nil
        end
        StopWatchingRain(self)

        if self:IsCrisping() then
            if not TheWorld.state.israining or self.protectedfromrain then
                self:Resume()
            end
            if not self.protectedfromrain then
                StartWatchingRain(self)
            end
            if self.onstartcrisping ~= nil then
                self.onstartcrisping(self.inst, self.veggie, self.buildfile)
            end
        else
            self:Resume()
            if self.ondonecrisping ~= nil then
                self.ondonecrisping(self.inst, self.crisp, self.crisp_buildfile)
            end
        end
    end
end

--------------------------------------------------------------------------
-- Debug

function Crispmaker:GetDebugString()
    return ((self:IsCrisping() and "DRYING ") or
            (self:IsDone() and "DRIED ") or
            "EMPTY ")
        ..(self.crisp or "<none>")
		.." "..(self.foodtype or "none")
        ..(self:IsPaused() and " PAUSED" or "")
        ..string.format(" drytime: %2.2f spoiltime: %2.2f", self:GetTimeToCrisp(), self:GetTimeToSpoil())
end

--------------------------------------------------------------------------

return Crispmaker